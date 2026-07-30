<?php

namespace app\service;

use app\model\BizRestPlan;
use app\model\SysUser;
use app\model\SysDept;
use support\Db;

/**
 * 休息日方案服务层（仅按周模板）
 * 一个方案关联多员工（通过 user_ids 字段存储），按 monday~sunday 配置每周休息日
 * 按日期休息日统一由 BizRestDayService 管理（biz_rest_day 表）
 */
class BizRestPlanService
{
    /**
     * 分页查询方案列表（含员工数）
     */
    public function selectList($params = [])
    {
        $query = BizRestPlan::query();

        if (!empty($params['plan_name'])) {
            $query->where('plan_name', 'like', '%' . $params['plan_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['effective_date'])) {
            $query->where('effective_date', '<=', $params['effective_date']);
        }

        $query->orderBy('plan_id', 'desc');

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $page = $query->paginate($pageSize, ['*'], 'page', $pageNum);

        // 附加员工数和员工简要信息（从 user_ids 字段读取）
        foreach ($page->items() as $plan) {
            $userIds = $this->parseUserIds($plan->user_ids);
            $userNames = $this->parseUserNames($plan->user_names);
            $plan->employee_count = count($userIds);
            $plan->employee_names = implode('、', array_slice($userNames, 0, 5));
            $plan->user_ids_arr = $userIds;
            $plan->user_names_arr = $userNames;
        }

        return $page;
    }

    /**
     * 方案详情（含关联员工）
     */
    public function selectById($planId)
    {
        $plan = BizRestPlan::find($planId);
        if (!$plan) return null;

        // 从 user_ids 字段读取关联员工
        $userIds = $this->parseUserIds($plan->user_ids);
        $userNames = $this->parseUserNames($plan->user_names);
        $employees = [];
        foreach ($userIds as $idx => $uid) {
            $employees[] = [
                'user_id' => $uid,
                'user_name' => $userNames[$idx] ?? '',
            ];
        }
        $plan->employees = $employees;
        $plan->user_ids_arr = $userIds;

        return $plan;
    }

    /**
     * 新建方案（按周模板）
     */
    public function insert($data)
    {
        $now = date('Y-m-d H:i:s');
        $userIds = $data['user_ids'] ?? [];

        if (empty($userIds)) {
            throw new \Exception('请选择员工');
        }
        if (empty($data['plan_name'])) {
            throw new \Exception('请填写方案名称');
        }

        // 验证：检查员工是否已有生效的重叠方案
        $effectiveDate = $data['effective_date'] ?? date('Y-m-d');
        $this->checkOverlappingPlans($userIds, $effectiveDate);

        // 获取员工姓名
        $userNames = $this->getUserNames($userIds);
        $userIdsStr = implode(',', $userIds);
        $userNamesStr = implode(',', $userNames);

        $plan = BizRestPlan::create([
            'plan_name' => $data['plan_name'],
            'monday' => $data['monday'] ?? '0',
            'tuesday' => $data['tuesday'] ?? '0',
            'wednesday' => $data['wednesday'] ?? '0',
            'thursday' => $data['thursday'] ?? '0',
            'friday' => $data['friday'] ?? '0',
            'saturday' => $data['saturday'] ?? '1',
            'sunday' => $data['sunday'] ?? '1',
            'effective_date' => $data['effective_date'] ?? date('Y-m-d'),
            'user_ids' => $userIdsStr,
            'user_names' => $userNamesStr,
            'status' => $data['status'] ?? '0',
            'create_by' => $data['create_by'] ?? '',
            'create_time' => $now,
            'update_by' => $data['update_by'] ?? '',
            'update_time' => $now,
        ]);

        return $plan->plan_id;
    }

    /**
     * 修改方案
     */
    public function update($data)
    {
        $planId = $data['plan_id'] ?? 0;
        if (!$planId) throw new \Exception('方案ID不能为空');

        $plan = BizRestPlan::find($planId);
        if (!$plan) throw new \Exception('方案不存在');

        $now = date('Y-m-d H:i:s');
        $userIds = $data['user_ids'] ?? [];

        if (empty($userIds)) {
            throw new \Exception('请选择员工');
        }

        // 验证：检查员工是否已有生效的重叠方案（排除自身）
        $effectiveDate = $data['effective_date'] ?? $plan->effective_date;
        $this->checkOverlappingPlans($userIds, $effectiveDate, $planId);

        // 获取员工姓名
        $userNames = $this->getUserNames($userIds);

        $updateData = [
            'plan_name' => $data['plan_name'] ?? $plan->plan_name,
            'effective_date' => $data['effective_date'] ?? $plan->effective_date,
            'user_ids' => implode(',', $userIds),
            'user_names' => implode(',', $userNames),
            'status' => $data['status'] ?? $plan->status,
            'update_by' => $data['update_by'] ?? '',
            'update_time' => $now,
        ];

        // 周配置字段
        foreach (['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] as $day) {
            if (isset($data[$day])) {
                $updateData[$day] = $data[$day];
            }
        }

        $plan->fill($updateData)->save();
        return true;
    }

    /**
     * 删除方案（级联删除 biz_rest_day 中 source='plan' 的记录）
     */
    public function deleteByIds($planIds)
    {
        if (empty($planIds)) return 0;

        Db::beginTransaction();
        try {
            $count = BizRestPlan::whereIn('plan_id', $planIds)->delete();
            // 删除 biz_rest_day 中关联的按日期休息日
            \app\model\BizRestDay::whereIn('source_id', $planIds)->where('source_type', 'plan')->delete();
            Db::commit();
            return $count;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 检查员工是否已有生效的重叠休息方案
     * @param array $userIds 员工ID列表
     * @param string $effectiveDate 新方案生效日期
     * @param int|null $excludePlanId 排除的方案ID（更新时排除自身）
     * @throws \Exception 如有重叠则抛出异常
     */
    protected function checkOverlappingPlans($userIds, $effectiveDate, $excludePlanId = null)
    {
        // 查询所有生效方案（status='0' 且 effective_date <= 新方案生效日）
        $query = BizRestPlan::where('status', '0')
            ->where('effective_date', '<=', $effectiveDate);
        if ($excludePlanId) {
            $query->where('plan_id', '!=', $excludePlanId);
        }
        $existingPlans = $query->get(['plan_id', 'plan_name', 'user_ids', 'user_names']);

        // 检查每个员工是否已在其他方案中
        $conflictUsers = [];
        foreach ($existingPlans as $plan) {
            $planUserIds = $this->parseUserIds($plan->user_ids);
            $planUserNames = $this->parseUserNames($plan->user_names);
            foreach ($planUserIds as $idx => $uid) {
                if (in_array($uid, $userIds)) {
                    $name = $planUserNames[$idx] ?? '';
                    $conflictUsers[] = $name . '(已存在于方案"' . $plan->plan_name . '")';
                }
            }
        }

        if (!empty($conflictUsers)) {
            throw new \Exception('以下员工已有生效的休息方案：' . implode('、', array_unique($conflictUsers)));
        }
    }

    /**
     * 解析逗号分隔的 user_ids 字段
     */
    protected function parseUserIds($userIdsStr)
    {
        if (empty($userIdsStr)) return [];
        return array_filter(array_map('intval', explode(',', $userIdsStr)), fn($v) => $v > 0);
    }

    /**
     * 解析逗号分隔的 user_names 字段
     */
    protected function parseUserNames($userNamesStr)
    {
        if (empty($userNamesStr)) return [];
        return array_filter(explode(',', $userNamesStr), fn($v) => $v !== '');
    }

    /**
     * 批量查询员工姓名
     */
    protected function getUserNames($userIds)
    {
        if (empty($userIds)) return [];
        $users = SysUser::whereIn('user_id', $userIds)->get()->keyBy('user_id');
        $names = [];
        foreach ($userIds as $uid) {
            $user = $users->get($uid);
            $names[] = $user ? ($user->nick_name ?? $user->user_name) : '';
        }
        return $names;
    }

    /**
     * 获取部门下员工列表（供前端勾选用）
     */
    public function getDeptUsers($deptId)
    {
        return SysUser::where('dept_id', $deptId)
            ->where('status', '0')
            ->where('del_flag', '0')
            ->select(['user_id', 'nick_name', 'user_name', 'dept_id'])
            ->get();
    }

    /**
     * 获取部门树+员工列表（供前端勾选弹窗用）
     */
    public function getDeptTreeWithUsers()
    {
        $depts = SysDept::where('status', '0')
            ->orderBy('order_num')
            ->get(['dept_id', 'parent_id', 'dept_name', 'order_num']);

        $users = SysUser::where('status', '0')
            ->where('del_flag', '0')
            ->get(['user_id', 'nick_name', 'user_name', 'dept_id']);

        return [
            'depts' => $depts,
            'users' => $users,
        ];
    }

    /**
     * 检查某员工某天是否休息日（按周模板判断）
     * 注意：仅判断按周方案，custom/leave 类型的休息日请查 biz_rest_day
     * @param int $userId
     * @param string $date Y-m-d格式
     * @return bool
     */
    public function isRestDay($userId, $date)
    {
        $weekday = date('N', strtotime($date));
        $dayMap = [
            1 => 'monday', 2 => 'tuesday', 3 => 'wednesday',
            4 => 'thursday', 5 => 'friday', 6 => 'saturday', 7 => 'sunday'
        ];
        $field = $dayMap[$weekday] ?? 'sunday';

        // 查询该员工关联的有效方案
        $plan = $this->getUserEffectivePlan($userId, $date);
        if (!$plan) {
            // 无配置默认周六日休息
            return $weekday >= 6;
        }

        return $plan->$field === '1';
    }

    /**
     * 获取员工某天有效的休息方案（通过 FIND_IN_SET 查询 user_ids 字段）
     */
    public function getUserEffectivePlan($userId, $date)
    {
        return BizRestPlan::where('status', '0')
            ->where('effective_date', '<=', $date)
            ->whereRaw('FIND_IN_SET(?, user_ids)', [$userId])
            ->orderBy('effective_date', 'desc')
            ->first();
    }

    /**
     * 批量获取员工某月的休息日列表（按周模板）
     * @param array $userIds
     * @param string $yearMonth 如 2026-07
     * @param bool $returnDefaultRest 是否对未配置方案的员工返回默认周末休息
     *                                - false（默认）：未配置则返回空数组，用于行程安排/考勤统计避免误显示
     *                                - true：未配置则返回默认周六日休息，用于"我的考勤"等用户视角页面
     * @return array [{userId, restDates}]
     */
    public function getRestDatesByMonth($userIds, $yearMonth, $returnDefaultRest = false)
    {
        if (empty($userIds)) return [];

        $result = [];
        $startDate = $yearMonth . '-01';
        $endDate = date('Y-m-t', strtotime($startDate));
        $daysInMonth = date('t', strtotime($startDate));

        $dayMap = [
            1 => 'monday', 2 => 'tuesday', 3 => 'wednesday',
            4 => 'thursday', 5 => 'friday', 6 => 'saturday', 7 => 'sunday'
        ];

        // 查询所有包含目标员工的按周方案（通过 FIND_IN_SET 匹配 user_ids 字段）
        $plans = BizRestPlan::where('status', '0')
            ->where('effective_date', '<=', $endDate)
            ->where(function ($q) use ($userIds) {
                foreach ($userIds as $uid) {
                    $q->orWhereRaw('FIND_IN_SET(?, user_ids)', [$uid]);
                }
            })
            ->orderBy('effective_date', 'desc')
            ->get();

        if ($plans->isEmpty()) {
            // 无方案：根据 $returnDefaultRest 决定是否返回默认周末休息
            foreach ($userIds as $userId) {
                $restDates = [];
                if ($returnDefaultRest) {
                    for ($day = 1; $day <= $daysInMonth; $day++) {
                        $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                        if (date('N', strtotime($dateStr)) >= 6) {
                            $restDates[] = $dateStr;
                        }
                    }
                }
                $result[] = ['userId' => $userId, 'restDates' => $restDates];
            }
            return $result;
        }

        // 构建员工-方案映射（通过 user_ids 字段）
        $userPlansMap = [];
        foreach ($userIds as $userId) {
            $effectivePlans = [];
            foreach ($plans as $plan) {
                $planUserIds = $this->parseUserIds($plan->user_ids);
                if (in_array($userId, $planUserIds)) {
                    $effectivePlans[] = $plan;
                }
            }
            $userPlansMap[$userId] = $effectivePlans;
        }

        foreach ($userIds as $userId) {
            $restDates = [];
            $userPlans = $userPlansMap[$userId] ?? [];
            if (empty($userPlans)) {
                // 无配置：根据 $returnDefaultRest 决定是否返回默认周末休息
                if ($returnDefaultRest) {
                    for ($day = 1; $day <= $daysInMonth; $day++) {
                        $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                        if (date('N', strtotime($dateStr)) >= 6) {
                            $restDates[] = $dateStr;
                        }
                    }
                }
            } else {
                // 合并所有有效方案的按周休息日
                foreach ($userPlans as $plan) {
                    for ($day = 1; $day <= $daysInMonth; $day++) {
                        $dateStr = sprintf('%s-%02d', $yearMonth, $day);
                        $weekday = date('N', strtotime($dateStr));
                        $field = $dayMap[$weekday] ?? 'sunday';
                        if ($plan->$field === '1' && !in_array($dateStr, $restDates)) {
                            $restDates[] = $dateStr;
                        }
                    }
                }
            }
            // 返回数组格式，避免 PHP 整数 key 在 JSON 序列化时被重新索引
            $result[] = ['userId' => $userId, 'restDates' => $restDates];
        }

        return $result;
    }

    /**
     * 按日期范围获取员工的按周模板休息日（供配置弹窗跨月查看）
     * 逻辑与 getRestDatesByMonth 一致，只是迭代范围从单月扩展到 [$startDate, $endDate]
     */
    public function getRestDatesByRange($userIds, $startDate, $endDate, $returnDefaultRest = false)
    {
        if (empty($userIds)) return [];

        $result = [];

        $dayMap = [
            1 => 'monday', 2 => 'tuesday', 3 => 'wednesday',
            4 => 'thursday', 5 => 'friday', 6 => 'saturday', 7 => 'sunday'
        ];

        // 查询所有包含目标员工的按周方案（effective_date <= endDate）
        $plans = BizRestPlan::where('status', '0')
            ->where('effective_date', '<=', $endDate)
            ->where(function ($q) use ($userIds) {
                foreach ($userIds as $uid) {
                    $q->orWhereRaw('FIND_IN_SET(?, user_ids)', [$uid]);
                }
            })
            ->orderBy('effective_date', 'desc')
            ->get();

        // 构建员工-方案映射
        $userPlansMap = [];
        foreach ($userIds as $userId) {
            $effectivePlans = [];
            foreach ($plans as $plan) {
                $planUserIds = $this->parseUserIds($plan->user_ids);
                if (in_array($userId, $planUserIds)) {
                    $effectivePlans[] = $plan;
                }
            }
            $userPlansMap[$userId] = $effectivePlans;
        }

        // 迭代日期范围内的每一天
        $startTs = strtotime($startDate);
        $endTs = strtotime($endDate);

        foreach ($userIds as $userId) {
            $restDates = [];
            $userPlans = $userPlansMap[$userId] ?? [];
            if (empty($userPlans)) {
                if ($returnDefaultRest) {
                    for ($ts = $startTs; $ts <= $endTs; $ts += 86400) {
                        if (date('N', $ts) >= 6) {
                            $restDates[] = date('Y-m-d', $ts);
                        }
                    }
                }
            } else {
                foreach ($userPlans as $plan) {
                    for ($ts = $startTs; $ts <= $endTs; $ts += 86400) {
                        $dateStr = date('Y-m-d', $ts);
                        $weekday = date('N', $ts);
                        $field = $dayMap[$weekday] ?? 'sunday';
                        if ($plan->$field === '1' && !in_array($dateStr, $restDates)) {
                            $restDates[] = $dateStr;
                        }
                    }
                }
            }
            $result[] = ['userId' => $userId, 'restDates' => $restDates];
        }

        return $result;
    }
}
