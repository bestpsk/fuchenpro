<?php

namespace app\service;

use app\model\BizAttendanceRecord;
use app\model\BizRestPlan;
use app\model\BizRestPlanEmployee;
use app\model\BizRestPlanDate;
use app\model\BizLeave;
use app\model\BizHoliday;
use app\model\SysUser;
use app\model\SysDept;
use support\Db;

/**
 * 考勤统计服务层
 * 按员工+日期范围聚合统计各考勤状态天数
 */
class BizAttendanceStatsService
{
    /**
     * 状态颜色与标签映射
     */
    protected $statusMap = [
        '0' => ['label' => '正常',   'color' => '#67C23A'],
        '1' => ['label' => '迟到',   'color' => '#E6A23C'],
        '2' => ['label' => '早退',   'color' => '#F56C6C'],
        '3' => ['label' => '迟到早退','color' => '#F56C6C'],
        '4' => ['label' => '缺勤',   'color' => '#F56C6C'],
        '5' => ['label' => '公共假期','color' => '#9C27B0'],
        '6' => ['label' => '休息日', 'color' => '#909399'],
        '7' => ['label' => '请假',   'color' => '#3D6DF7'],
        'none' => ['label' => '', 'color' => '#FFFFFF'],
    ];

    /**
     * 按员工统计考勤汇总
     * @param array $params dateRangeStart, dateRangeEnd, userName, deptId
     * @return array
     */
    public function selectStatsList($params = [])
    {
        $dateStart = $params['date_range_start'] ?? date('Y-m-01');
        $dateEnd = $params['date_range_end'] ?? date('Y-m-t');

        $query = Db::table('biz_attendance_record as r')
            ->leftJoin('sys_user as u', 'r.user_id', '=', 'u.user_id')
            ->leftJoin('sys_dept as d', 'u.dept_id', '=', 'd.dept_id')
            ->whereBetween('r.attendance_date', [$dateStart, $dateEnd])
            ->where('u.del_flag', '0');

        if (!empty($params['user_name'])) {
            $query->where(function ($q) use ($params) {
                $q->where('r.user_name', 'like', '%' . $params['user_name'] . '%')
                  ->orWhere('u.nick_name', 'like', '%' . $params['user_name'] . '%');
            });
        }
        if (!empty($params['dept_id'])) {
            $query->where('u.dept_id', $params['dept_id']);
        }

        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $loginUser = $params['login_user'];
            if (!$loginUser->isAdmin()) {
                DataScopeService::applyUserScope($query, $loginUser, 'r.user_id');
            }
        }

        $query->select(
            'r.user_id',
            Db::raw('MAX(r.user_name) as user_name'),
            'd.dept_name',
            Db::raw("SUM(CASE WHEN r.attendance_status = '0' THEN 1 ELSE 0 END) as normal_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '1' THEN 1 ELSE 0 END) as late_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '2' THEN 1 ELSE 0 END) as early_leave_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '3' THEN 1 ELSE 0 END) as late_early_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '4' THEN 1 ELSE 0 END) as absent_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '5' THEN 1 ELSE 0 END) as holiday_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '6' THEN 1 ELSE 0 END) as rest_days"),
            Db::raw("SUM(CASE WHEN r.attendance_status = '7' THEN 1 ELSE 0 END) as leave_days"),
            Db::raw('COUNT(*) as total_records')
        );

        $query->groupBy('r.user_id', 'd.dept_name');
        $query->orderBy('d.dept_name', 'asc')->orderBy('user_name', 'asc');

        $list = $query->get();

        // 计算出勤率和汇总
        $result = [];
        $totals = [
            'normal_days' => 0, 'late_days' => 0, 'early_leave_days' => 0,
            'late_early_days' => 0, 'absent_days' => 0, 'holiday_days' => 0,
            'rest_days' => 0, 'leave_days' => 0, 'total_records' => 0,
        ];

        foreach ($list as $item) {
            $item = (array) $item;
            // 应出勤 = 正常+迟到+早退+迟到早退+缺勤+请假（不含休息日和公共假期）
            $shouldAttend = $item['normal_days'] + $item['late_days'] + $item['early_leave_days']
                          + $item['late_early_days'] + $item['absent_days'] + $item['leave_days'];
            // 实际出勤 = 正常+迟到+早退+迟到早退（来了就算出勤）
            $actualAttend = $item['normal_days'] + $item['late_days'] + $item['early_leave_days'] + $item['late_early_days'];
            $item['should_attend_days'] = $shouldAttend;
            $item['actual_attend_days'] = $actualAttend;
            $item['attendance_rate'] = $shouldAttend > 0 ? round($actualAttend / $shouldAttend * 100, 1) : 0;

            foreach (array_keys($totals) as $key) {
                $totals[$key] += $item[$key];
            }

            $result[] = $item;
        }

        // 汇总行
        $totals['should_attend_days'] = $totals['normal_days'] + $totals['late_days'] + $totals['early_leave_days']
                                      + $totals['late_early_days'] + $totals['absent_days'] + $totals['leave_days'];
        $totals['actual_attend_days'] = $totals['normal_days'] + $totals['late_days'] + $totals['early_leave_days'] + $totals['late_early_days'];
        $totals['attendance_rate'] = $totals['should_attend_days'] > 0
            ? round($totals['actual_attend_days'] / $totals['should_attend_days'] * 100, 1) : 0;
        $totals['user_name'] = '合计';

        return [
            'list' => $result,
            'totals' => $totals,
        ];
    }

    /**
     * 日历视图统计：返回每个员工每个日期的状态
     * @param array $params year_month, userName, deptId, login_user
     * @return array {list: [{userId, userName, deptName, days: [{date, status, statusLabel, color, remark}]}], summary: {...}}
     */
    public function selectCalendarStats($params = [])
    {
        $yearMonth = $params['year_month'] ?? date('Y-m');
        $dateStart = $yearMonth . '-01';
        $dateEnd = date('Y-m-t', strtotime($dateStart));
        $daysInMonth = date('t', strtotime($dateStart));

        // 1. 获取员工列表
        $userQuery = SysUser::query()->where('del_flag', '0')->where('status', '0');
        if (!empty($params['user_name'])) {
            $userQuery->where(function ($q) use ($params) {
                $q->where('nick_name', 'like', '%' . $params['user_name'] . '%')
                  ->orWhere('user_name', 'like', '%' . $params['user_name'] . '%');
            });
        }
        if (!empty($params['dept_id'])) {
            $userQuery->where('dept_id', $params['dept_id']);
        }
        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $loginUser = $params['login_user'];
            if (!$loginUser->isAdmin()) {
                $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
                if (!empty($visibleUserIds)) {
                    $userQuery->whereIn('user_id', $visibleUserIds);
                }
            }
        }
        $users = $userQuery->orderBy('dept_id')->orderBy('user_id')->get(['user_id', 'nick_name', 'user_name', 'dept_id']);
        if ($users->isEmpty()) {
            return ['list' => [], 'summary' => $this->emptySummary()];
        }

        $deptIds = $users->pluck('dept_id')->filter()->unique()->toArray();
        $deptMap = !empty($deptIds)
            ? SysDept::whereIn('dept_id', $deptIds)->pluck('dept_name', 'dept_id')->toArray()
            : [];

        $userIds = $users->pluck('user_id')->toArray();

        // 2. 批量查询考勤记录
        $attendanceMap = [];  // userId => [date => record]
        $records = BizAttendanceRecord::whereIn('user_id', $userIds)
            ->whereBetween('attendance_date', [$dateStart, $dateEnd])
            ->get();
        foreach ($records as $r) {
            $attendanceMap[$r->user_id][$r->attendance_date] = $r;
        }

        // 3. 批量查询休息日方案（restPlan）
        $restDatesByUser = $this->batchGetRestDates($userIds, $yearMonth, $dateStart, $dateEnd);

        // 4. 批量查询请假记录
        $leaveDatesByUser = [];  // userId => [date => leaveInfo]
        $leaves = BizLeave::with('leaveType')
            ->whereIn('user_id', $userIds)
            ->where('status', '1')  // 已通过
            ->where(function ($q) use ($dateStart, $dateEnd) {
                $q->whereBetween('start_date', [$dateStart, $dateEnd])
                  ->orWhereBetween('end_date', [$dateStart, $dateEnd])
                  ->orWhere(function ($q2) use ($dateStart, $dateEnd) {
                      $q2->where('start_date', '<=', $dateStart)->where('end_date', '>=', $dateEnd);
                  });
            })
            ->get();
        foreach ($leaves as $lv) {
            $start = max($lv->start_date, $dateStart);
            $end = min($lv->end_date, $dateEnd);
            $cur = strtotime($start);
            while ($cur <= strtotime($end)) {
                $dateStr = date('Y-m-d', $cur);
                $leaveDatesByUser[$lv->user_id][$dateStr] = $lv;
                $cur = strtotime('+1 day', $cur);
            }
        }

        // 5. 批量查询公共假期
        $holidayDates = [];  // dateStr => holiday
        $holidays = BizHoliday::where('status', '0')
            ->where(function ($q) use ($dateStart, $dateEnd) {
                $q->whereBetween('start_date', [$dateStart, $dateEnd])
                  ->orWhereBetween('end_date', [$dateStart, $dateEnd])
                  ->orWhere(function ($q2) use ($dateStart, $dateEnd) {
                      $q2->where('start_date', '<=', $dateStart)->where('end_date', '>=', $dateEnd);
                  });
            })
            ->get();
        foreach ($holidays as $h) {
            $start = max($h->start_date, $dateStart);
            $end = min($h->end_date, $dateEnd);
            $cur = strtotime($start);
            while ($cur <= strtotime($end)) {
                $holidayDates[date('Y-m-d', $cur)] = $h;
                $cur = strtotime('+1 day', $cur);
            }
        }

        // 6. 组装每个员工每天的格子状态
        $list = [];
        $summary = $this->emptySummary();

        foreach ($users as $user) {
            $userId = $user->user_id;
            $days = [];

            for ($day = 1; $day <= $daysInMonth; $day++) {
                $dateStr = sprintf('%s-%02d', $yearMonth, $day);

                // 优先级：公共假期 > 请假 > 休息日 > 考勤记录 > 默认（未打卡）
                if (isset($holidayDates[$dateStr])) {
                    $h = $holidayDates[$dateStr];
                    $status = '5';
                    $remark = $h->holiday_name ?? '';
                } elseif (isset($leaveDatesByUser[$userId][$dateStr])) {
                    $lv = $leaveDatesByUser[$userId][$dateStr];
                    $status = '7';
                    $remark = $lv->leaveType->type_name ?? '';
                } elseif (in_array($dateStr, $restDatesByUser[$userId] ?? [])) {
                    $status = '6';
                    $remark = '';
                } elseif (isset($attendanceMap[$userId][$dateStr])) {
                    $r = $attendanceMap[$userId][$dateStr];
                    $status = (string)($r->attendance_status ?? '0');
                    $remark = $r->remark ?? '';
                } else {
                    // 未打卡
                    $today = date('Y-m-d');
                    if ($dateStr > $today) {
                        // 未来日期：空白，不统计
                        $status = 'none';
                    } else {
                        // 过去或今天
                        $weekday = date('N', strtotime($dateStr));
                        if ($weekday >= 6) {
                            // 周末：未配置方案则空白，不显示休息日
                            $status = 'none';
                        } else {
                            // 工作日：缺勤
                            $status = '4';
                        }
                    }
                    $remark = '';
                }

                $info = $this->statusMap[$status] ?? ['label' => '未知', 'color' => '#909399'];
                // 请假状态使用具体类型名称（事假/病假等），而非笼统的"请假"
                $statusLabel = $info['label'];
                if ($status === '7' && !empty($remark)) {
                    $statusLabel = $remark;
                }
                $days[] = [
                    'date' => $dateStr,
                    'day' => $day,
                    'status' => $status,
                    'statusLabel' => $statusLabel,
                    'color' => $info['color'],
                    'remark' => $remark,
                ];

                // 统计累加
                $summary = $this->accumulateSummary($summary, $status);
            }

            $list[] = [
                'userId' => $userId,
                'userName' => $user->nick_name ?: $user->user_name,
                'deptId' => $user->dept_id,
                'deptName' => $user->dept_id ? ($deptMap[$user->dept_id] ?? '') : '',
                'days' => $days,
            ];
        }

        // 计算出勤率
        $summary['should_attend_days'] = $summary['normal_days'] + $summary['late_days']
            + $summary['early_leave_days'] + $summary['late_early_days']
            + $summary['absent_days'] + $summary['leave_days'];
        $summary['actual_attend_days'] = $summary['normal_days'] + $summary['late_days']
            + $summary['early_leave_days'] + $summary['late_early_days'];
        $summary['attendance_rate'] = $summary['should_attend_days'] > 0
            ? round($summary['actual_attend_days'] / $summary['should_attend_days'] * 100, 1) : 0;

        return [
            'list' => $list,
            'summary' => $summary,
            'daysInMonth' => intval($daysInMonth),
            'yearMonth' => $yearMonth,
        ];
    }

    /**
     * 批量获取员工某月休息日（基于 restPlan 方案）
     */
    protected function batchGetRestDates($userIds, $yearMonth, $dateStart, $dateEnd)
    {
        $result = array_fill_keys($userIds, []);

        $planIds = BizRestPlanEmployee::whereIn('user_id', $userIds)->pluck('plan_id')->unique()->toArray();
        if (empty($planIds)) {
            // 无方案：未配置则不显示休息日
            return $result;
        }

        $plans = BizRestPlan::whereIn('plan_id', $planIds)
            ->where('status', '0')
            ->where('effective_date', '<=', $dateEnd)
            ->orderBy('effective_date', 'desc')
            ->get()
            ->keyBy('plan_id');

        // 员工-方案映射（合并所有有效方案，避免只显示最新方案）
        $employeeRows = BizRestPlanEmployee::whereIn('user_id', $userIds)->get();
        $userPlansMap = [];
        foreach ($userIds as $uid) {
            $userPlanIds = $employeeRows->where('user_id', $uid)->pluck('plan_id')->toArray();
            $effectivePlans = [];
            foreach ($userPlanIds as $pid) {
                $plan = $plans->get($pid);
                if ($plan) {
                    $effectivePlans[] = $plan;
                }
            }
            $userPlansMap[$uid] = $effectivePlans;
        }

        // 批量查询日期配置
        $allDatePlans = BizRestPlanDate::whereIn('plan_id', $planIds)
            ->whereBetween('rest_date', [$dateStart, $dateEnd])
            ->get()
            ->groupBy('plan_id');

        $dayMap = [
            1 => 'monday', 2 => 'tuesday', 3 => 'wednesday',
            4 => 'thursday', 5 => 'friday', 6 => 'saturday', 7 => 'sunday'
        ];
        $daysInMonth = date('t', strtotime($dateStart));

        foreach ($userIds as $uid) {
            $restDates = [];
            $userPlans = $userPlansMap[$uid] ?? [];
            if (empty($userPlans)) {
                // 未配置方案则不显示休息日
                $restDates = [];
            } else {
                // 合并所有有效方案的休息日
                foreach ($userPlans as $plan) {
                    if ($plan->config_type === '0') {
                        // 按周配置：合并
                        for ($day = 1; $day <= $daysInMonth; $day++) {
                            $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                            $weekday = date('N', strtotime($dateStr));
                            $field = $dayMap[$weekday] ?? 'sunday';
                            if ($plan->$field === '1' && !in_array($dateStr, $restDates)) {
                                $restDates[] = $dateStr;
                            }
                        }
                    } else {
                        // 按日期配置：合并
                        $planDates = $allDatePlans->get($plan->plan_id, collect());
                        foreach ($planDates as $row) {
                            if (!in_array($row->rest_date, $restDates)) {
                                $restDates[] = $row->rest_date;
                            }
                        }
                    }
                }
            }
            $result[$uid] = $restDates;
        }
        return $result;
    }

    protected function getDefaultWeekendDates($yearMonth)
    {
        $daysInMonth = date('t', strtotime($yearMonth . '-01'));
        $restDates = [];
        for ($day = 1; $day <= $daysInMonth; $day++) {
            $dateStr = sprintf('%s-%02d', $yearMonth, $day);
            if (date('N', strtotime($dateStr)) >= 6) {
                $restDates[] = $dateStr;
            }
        }
        return $restDates;
    }

    protected function emptySummary()
    {
        return [
            'normal_days' => 0, 'late_days' => 0, 'early_leave_days' => 0,
            'late_early_days' => 0, 'absent_days' => 0, 'holiday_days' => 0,
            'rest_days' => 0, 'leave_days' => 0,
            'should_attend_days' => 0, 'actual_attend_days' => 0, 'attendance_rate' => 0,
        ];
    }

    protected function accumulateSummary($summary, $status)
    {
        $keyMap = [
            '0' => 'normal_days',
            '1' => 'late_days',
            '2' => 'early_leave_days',
            '3' => 'late_early_days',
            '4' => 'absent_days',
            '5' => 'holiday_days',
            '6' => 'rest_days',
            '7' => 'leave_days',
        ];
        $key = $keyMap[$status] ?? null;
        if ($key) {
            $summary[$key]++;
        }
        return $summary;
    }
}
