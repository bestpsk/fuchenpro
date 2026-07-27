<?php

namespace app\controller\business;

use support\Request;
use app\service\BizRestPlanService;
use app\service\BizHolidayService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 休息日方案控制器
 */
class BizRestPlanController
{
    /**
     * 方案列表
     */
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizRestPlanService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    /**
     * 批量获取员工某月休息日（供行程安排日历使用）
     * 参数：userIds（逗号分隔）, yearMonth（如 2026-07）
     * 返回：{userId: ['2026-07-04', '2026-07-05', ...]}
     */
    public function restCalendar(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userIdsParam = $request->input('userIds', '');
        $yearMonth = $request->input('yearMonth', date('Y-m'));
        if (empty($userIdsParam)) {
            return AjaxResult::success([]);
        }
        $userIds = array_map('intval', explode(',', $userIdsParam));
        $service = new BizRestPlanService();
        $result = $service->getRestDatesByMonth($userIds, $yearMonth);
        return AjaxResult::success($result);
    }

    /**
     * 方案详情（含关联员工和日期）
     */
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $planId = intval(end($parts));
        $service = new BizRestPlanService();
        $plan = $service->selectById($planId);
        if (!$plan) return AjaxResult::error('方案不存在');
        return AjaxResult::success($plan);
    }

    /**
     * 新增方案
     */
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizRestPlanService();
            $planId = $service->insert($data);
            return AjaxResult::success($planId);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 修改方案
     */
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizRestPlanService();
            $result = $service->update($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 删除方案（级联删除关联）
     */
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $planIds = $request->input('planIds', '');
        if (!is_array($planIds)) {
            $planIds = explode(',', $planIds);
        }
        $planIds = array_map('intval', array_filter($planIds));
        if (empty($planIds)) {
            return AjaxResult::error('请选择要删除的方案');
        }
        try {
            $service = new BizRestPlanService();
            $count = $service->deleteByIds($planIds);
            return AjaxResult::toAjax($count ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 获取部门树+员工列表（供前端勾选弹窗用）
     */
    public function deptTreeWithUsers(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:rest:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizRestPlanService();
        $data = $service->getDeptTreeWithUsers();
        return AjaxResult::success($data);
    }

    /**
     * 获取部门下员工
     */
    public function deptUsers(Request $request)
    {
        $parts = explode('/', $request->path());
        $deptId = intval(end($parts));
        if (!$deptId) return AjaxResult::error('请选择部门');
        $service = new BizRestPlanService();
        $users = $service->getDeptUsers($deptId);
        return AjaxResult::success($users);
    }

    /**
     * 获取当前员工某月的休息日和假期（供 AppV3 考勤日历标注使用）
     * GET /business/leave/restPlan/myRestCalendar?yearMonth=2026-07
     * 返回: { restDates: ['2026-07-04', ...], holidays: [{holidayName, startDate, endDate}, ...] }
     */
    public function myRestCalendar(Request $request)
    {
        $userId = $request->loginUser->user->user_id ?? 0;
        if (!$userId) {
            return AjaxResult::error('用户未登录');
        }
        $yearMonth = $request->input('yearMonth', date('Y-m'));
        // 校验 yearMonth 格式
        if (!preg_match('/^\d{4}-\d{2}$/', $yearMonth)) {
            return AjaxResult::error('yearMonth 参数格式应为 YYYY-MM');
        }

        try {
            $service = new BizRestPlanService();
            // 传 true：保留默认周末休息逻辑，用于"我的考勤记录"页面显示当前用户的休息日标记
            $restResult = $service->getRestDatesByMonth([$userId], $yearMonth, true);
            $myRestDates = [];
            foreach ($restResult as $item) {
                if (isset($item['userId']) && $item['userId'] == $userId) {
                    $myRestDates = $item['restDates'] ?? [];
                    break;
                }
            }

            // 查询本月法定假期
            $holidayService = new BizHolidayService();
            $startDate = $yearMonth . '-01';
            $endDate = date('Y-m-t', strtotime($startDate));
            $holidays = \app\model\BizHoliday::where('status', '0')
                ->where(function ($q) use ($startDate, $endDate) {
                    $q->whereBetween('start_date', [$startDate, $endDate])
                      ->orWhereBetween('end_date', [$startDate, $endDate])
                      ->orWhere(function ($q2) use ($startDate, $endDate) {
                          $q2->where('start_date', '<=', $startDate)
                             ->where('end_date', '>=', $endDate);
                      });
                })
                ->get(['holiday_name', 'start_date', 'end_date'])
                ->toArray();

            // 转为驼峰命名
            $holidayList = array_map(function ($h) {
                return [
                    'holidayName' => $h['holiday_name'],
                    'startDate' => $h['start_date'],
                    'endDate' => $h['end_date'],
                ];
            }, $holidays);

            return AjaxResult::success([
                'restDates' => $myRestDates,
                'holidays' => $holidayList,
            ]);
        } catch (\Throwable $e) {
            // 表不存在或查询异常时，返回空数据而非报错，避免影响考勤记录页加载
            return AjaxResult::success([
                'restDates' => [],
                'holidays' => []
            ]);
        }
    }

    /**
     * 获取当前员工某月的休息日和假期（带类型信息，供 AppV3 "我的休息日"页面使用）
     * GET /business/leave/restPlan/myRestCalendarDetailed?yearMonth=2026-07
     * 返回: { dates: [{date, type, typeName, color}, ...], typeList: [{type, name, color, count}, ...] }
     */
    public function myRestCalendarDetailed(Request $request)
    {
        $userId = $request->loginUser->user->user_id ?? 0;
        if (!$userId) {
            return AjaxResult::error('用户未登录');
        }
        $yearMonth = $request->input('yearMonth', date('Y-m'));
        if (!preg_match('/^\d{4}-\d{2}$/', $yearMonth)) {
            return AjaxResult::error('yearMonth 参数格式应为 YYYY-MM');
        }

        $startDate = $yearMonth . '-01';
        $endDate = date('Y-m-t', strtotime($startDate));
        $daysInMonth = date('t', strtotime($startDate));

        try {
            $restPlanService = new BizRestPlanService();

            // 1. 获取每周固定休息日和指定休息日
            $userPlan = $restPlanService->getUserEffectivePlan($userId, $startDate);
            $weeklyDates = [];
            $specifiedDates = [];
            $dayMap = [1 => 'monday', 2 => 'tuesday', 3 => 'wednesday', 4 => 'thursday', 5 => 'friday', 6 => 'saturday', 7 => 'sunday'];

            if ($userPlan) {
                if ($userPlan->config_type === '0') {
                    for ($day = 1; $day <= $daysInMonth; $day++) {
                        $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                        $weekday = date('N', strtotime($dateStr));
                        $field = $dayMap[$weekday] ?? 'sunday';
                        if ($userPlan->$field === '1') {
                            $weeklyDates[] = $dateStr;
                        }
                    }
                } else {
                    $specifiedDates = \app\model\BizRestPlanDate::where('plan_id', $userPlan->plan_id)
                        ->whereBetween('rest_date', [$startDate, $endDate])
                        ->pluck('rest_date')
                        ->toArray();
                }
            } else {
                // 无方案：默认周六日休息
                for ($day = 1; $day <= $daysInMonth; $day++) {
                    $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                    if (date('N', strtotime($dateStr)) >= 6) {
                        $weeklyDates[] = $dateStr;
                    }
                }
            }

            // 2. 获取请假通过的假期
            $leaves = \app\model\BizLeave::where('user_id', $userId)
                ->where('status', '1')
                ->where(function ($q) use ($startDate, $endDate) {
                    $q->whereBetween('start_date', [$startDate, $endDate])
                      ->orWhereBetween('end_date', [$startDate, $endDate])
                      ->orWhere(function ($q2) use ($startDate, $endDate) {
                          $q2->where('start_date', '<=', $startDate)
                             ->where('end_date', '>=', $endDate);
                      });
                })
                ->with('leaveType')
                ->get();
            $leaveDates = [];
            $leaveTypeMap = [];
            foreach ($leaves as $leave) {
                $start = max(strtotime($leave->start_date), strtotime($startDate));
                $end = min(strtotime($leave->end_date), strtotime($endDate));
                for ($date = $start; $date <= $end; $date += 86400) {
                    $dateStr = date('Y-m-d', $date);
                    $leaveDates[] = $dateStr;
                    $leaveTypeMap[$dateStr] = $leave->leaveType->type_name ?? '请假';
                }
            }

            // 3. 获取法定假期
            $holidays = \app\model\BizHoliday::where('status', '0')
                ->where(function ($q) use ($startDate, $endDate) {
                    $q->whereBetween('start_date', [$startDate, $endDate])
                      ->orWhereBetween('end_date', [$startDate, $endDate])
                      ->orWhere(function ($q2) use ($startDate, $endDate) {
                          $q2->where('start_date', '<=', $startDate)
                             ->where('end_date', '>=', $endDate);
                      });
                })
                ->get();
            $holidayDates = [];
            $holidayNameMap = [];
            foreach ($holidays as $holiday) {
                $start = max(strtotime($holiday->start_date), strtotime($startDate));
                $end = min(strtotime($holiday->end_date), strtotime($endDate));
                for ($date = $start; $date <= $end; $date += 86400) {
                    $dateStr = date('Y-m-d', $date);
                    $holidayDates[] = $dateStr;
                    $holidayNameMap[$dateStr] = $holiday->holiday_name;
                }
            }

            // 4. 合并所有休息日（带类型），优先级：法定假期 > 请假 > 指定休息 > 每周休息
            $allDates = [];
            foreach ($weeklyDates as $date) {
                $allDates[$date] = [
                    'date' => $date,
                    'type' => 'weekly',
                    'typeName' => '每周休息',
                    'color' => '#3D6DF7'
                ];
            }
            foreach ($specifiedDates as $date) {
                $allDates[$date] = [
                    'date' => $date,
                    'type' => 'specified',
                    'typeName' => '指定休息',
                    'color' => '#00B42A'
                ];
            }
            foreach ($leaveDates as $date) {
                if (!isset($allDates[$date])) {
                    $allDates[$date] = [
                        'date' => $date,
                        'type' => 'leave',
                        'typeName' => $leaveTypeMap[$date] ?? '请假',
                        'color' => '#FF9900'
                    ];
                }
            }
            foreach ($holidayDates as $date) {
                $allDates[$date] = [
                    'date' => $date,
                    'type' => 'holiday',
                    'typeName' => $holidayNameMap[$date] ?? '法定假期',
                    'color' => '#F53F3F'
                ];
            }

            ksort($allDates);
            $allDates = array_values($allDates);

            // 类型汇总
            $typeCount = [];
            foreach ($allDates as $item) {
                $type = $item['type'];
                if (!isset($typeCount[$type])) {
                    $typeCount[$type] = [
                        'type' => $type,
                        'name' => $item['typeName'],
                        'color' => $item['color'],
                        'count' => 0
                    ];
                }
                $typeCount[$type]['count']++;
            }

            return AjaxResult::success([
                'dates' => $allDates,
                'typeList' => array_values($typeCount),
                'yearMonth' => $yearMonth
            ]);
        } catch (\Throwable $e) {
            return AjaxResult::success([
                'dates' => [],
                'typeList' => [],
                'yearMonth' => $yearMonth
            ]);
        }
    }

    /**
     * 获取当前员工的有效休息日方案（供 AppV3 "我的休息日"页面使用）
     * GET /business/leave/restPlan/myPlan
     */
    public function myPlan(Request $request)
    {
        $userId = $request->loginUser->user->user_id ?? 0;
        if (!$userId) {
            return AjaxResult::error('用户未登录');
        }

        $service = new BizRestPlanService();
        $today = date('Y-m-d');
        $plan = $service->getUserEffectivePlan($userId, $today);
        if (!$plan) {
            return AjaxResult::success(null);
        }

        // 加载方案详情（含员工和日期配置）
        $planDetail = $service->selectById($plan->plan_id);
        return AjaxResult::success($planDetail);
    }
}
