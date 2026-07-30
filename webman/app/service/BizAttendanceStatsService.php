<?php

namespace app\service;

use app\model\BizAttendanceRecord;
use app\model\BizRestDay;
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
            Db::raw('COUNT(*) as total_records')
        );

        $query->groupBy('r.user_id', 'd.dept_name');
        $query->orderBy('d.dept_name', 'asc')->orderBy('user_name', 'asc');

        $list = $query->get();

        // 补充查询：休息日/请假/法定假日天数（考勤记录不含这些状态，从 biz_rest_day/biz_leave/biz_holiday 补充）
        $userIds = $list->pluck('user_id')->toArray();
        $restDaysMap = $this->getRestDaysCount($userIds, $dateStart, $dateEnd);
        $leaveDaysMap = $this->getLeaveDaysCount($userIds, $dateStart, $dateEnd);
        $holidayDays = $this->getHolidayDaysCount($dateStart, $dateEnd);

        // 计算出勤率和汇总
        $result = [];
        $totals = [
            'normal_days' => 0, 'late_days' => 0, 'early_leave_days' => 0,
            'late_early_days' => 0, 'absent_days' => 0, 'holiday_days' => 0,
            'rest_days' => 0, 'leave_days' => 0, 'total_records' => 0,
        ];

        foreach ($list as $item) {
            $item = (array) $item;
            $userId = $item['user_id'];
            // 补充休息日、请假、法定假日天数
            $item['rest_days'] = $restDaysMap[$userId] ?? 0;
            $item['leave_days'] = $leaveDaysMap[$userId] ?? 0;
            $item['holiday_days'] = $holidayDays;
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
     * 批量查询员工在日期范围内的休息日天数（custom + plan 来源，不含请假和法定假日）
     */
    public function getRestDaysCount($userIds, $dateStart, $dateEnd)
    {
        if (empty($userIds)) return [];
        $rows = BizRestDay::whereIn('user_id', $userIds)
            ->whereBetween('rest_date', [$dateStart, $dateEnd])
            ->whereIn('source_type', ['custom', 'plan'])
            ->selectRaw('user_id, COUNT(*) as cnt')
            ->groupBy('user_id')
            ->get();
        $map = [];
        foreach ($rows as $row) {
            $map[$row->user_id] = $row->cnt;
        }
        return $map;
    }

    /**
     * 批量查询员工在日期范围内的已通过请假天数
     * 注意：不使用 SUM(leave_days)，因为 leave_days 是整个请假单总天数，
     * 跨月请假时需按查询范围裁剪计算实际天数
     */
    public function getLeaveDaysCount($userIds, $dateStart, $dateEnd)
    {
        if (empty($userIds)) return [];
        $leaves = BizLeave::whereIn('user_id', $userIds)
            ->where('status', '1') // 已通过
            ->where(function ($q) use ($dateStart, $dateEnd) {
                $q->whereBetween('start_date', [$dateStart, $dateEnd])
                  ->orWhereBetween('end_date', [$dateStart, $dateEnd])
                  ->orWhere(function ($q2) use ($dateStart, $dateEnd) {
                      $q2->where('start_date', '<=', $dateStart)
                         ->where('end_date', '>=', $dateEnd);
                  });
            })
            ->get();
        $map = [];
        foreach ($leaves as $leave) {
            // 计算请假在查询范围内的实际天数（跨月请假裁剪）
            $start = max(strtotime($leave->start_date), strtotime($dateStart));
            $end = min(strtotime($leave->end_date), strtotime($dateEnd));
            if ($end >= $start) {
                $days = (int) (($end - $start) / 86400) + 1;
                $map[$leave->user_id] = ($map[$leave->user_id] ?? 0) + $days;
            }
        }
        return $map;
    }

    /**
     * 查询日期范围内的法定假日总天数（影响全员）
     */
    public function getHolidayDaysCount($dateStart, $dateEnd)
    {
        $holidays = BizHoliday::where('status', '0')
            ->where(function ($q) use ($dateStart, $dateEnd) {
                $q->whereBetween('start_date', [$dateStart, $dateEnd])
                  ->orWhereBetween('end_date', [$dateStart, $dateEnd])
                  ->orWhere(function ($q2) use ($dateStart, $dateEnd) {
                      $q2->where('start_date', '<=', $dateStart)
                         ->where('end_date', '>=', $dateEnd);
                  });
            })
            ->get();
        $totalDays = 0;
        foreach ($holidays as $holiday) {
            $start = max(strtotime($holiday->start_date), strtotime($dateStart));
            $end = min(strtotime($holiday->end_date), strtotime($dateEnd));
            if ($end >= $start) {
                $totalDays += (int) (($end - $start) / 86400) + 1;
            }
        }
        return $totalDays;
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
     * 批量获取员工某月休息日（custom + plan 来源 + 按周方案）
     * 注意：leave 来源的休息日由调用方单独查询 BizLeave 处理（优先级高于休息日）
     */
    protected function batchGetRestDates($userIds, $yearMonth, $dateStart, $dateEnd)
    {
        $result = array_fill_keys($userIds, []);

        // 1. 查询 biz_rest_day 中 custom + plan 来源的休息日
        $restDays = BizRestDay::whereIn('user_id', $userIds)
            ->whereIn('source_type', ['custom', 'plan'])
            ->whereBetween('rest_date', [$dateStart, $dateEnd])
            ->get();
        foreach ($restDays as $rd) {
            if (!in_array($rd->rest_date, $result[$rd->user_id] ?? [])) {
                $result[$rd->user_id][] = $rd->rest_date;
            }
        }

        // 2. 查询按周方案动态生成的休息日（未配置方案的员工不返回默认周末）
        $restPlanService = new BizRestPlanService();
        $weeklyResult = $restPlanService->getRestDatesByMonth($userIds, $yearMonth, false);
        foreach ($weeklyResult as $item) {
            $uid = $item['userId'] ?? null;
            if (!$uid) continue;
            foreach ($item['restDates'] ?? [] as $date) {
                if (!in_array($date, $result[$uid] ?? [])) {
                    $result[$uid][] = $date;
                }
            }
        }

        return $result;
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
