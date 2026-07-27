<?php

namespace app\service;

use app\model\BizRestPlan;
use app\model\BizRestPlanEmployee;
use app\model\BizRestPlanDate;
use app\model\SysUser;
use app\model\SysDept;
use support\Db;

/**
 * 休息日方案服务层
 * 一个方案关联多员工，支持按周配置或按日期配置
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
        if (isset($params['config_type']) && $params['config_type'] !== '') {
            $query->where('config_type', $params['config_type']);
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

        // 附加员工数和员工简要信息
        $planIds = $page->pluck('plan_id')->toArray();
        if (!empty($planIds)) {
            $employeeCounts = BizRestPlanEmployee::whereIn('plan_id', $planIds)
                ->selectRaw('plan_id, COUNT(*) AS cnt')
                ->groupBy('plan_id')
                ->pluck('cnt', 'plan_id')
                ->toArray();

            $employeeNames = BizRestPlanEmployee::whereIn('plan_id', $planIds)
                ->select(['plan_id', 'user_name'])
                ->get()
                ->groupBy('plan_id')
                ->map(function ($items) {
                    return $items->pluck('user_name')->take(5)->implode('、');
                })
                ->toArray();

            foreach ($page->items() as $plan) {
                $plan->employee_count = $employeeCounts[$plan->plan_id] ?? 0;
                $plan->employee_names = $employeeNames[$plan->plan_id] ?? '';
                $plan->config_type_label = $plan->config_type === '0' ? '按周配置' : '按日期配置';
            }
        }

        return $page;
    }

    /**
     * 方案详情（含关联员工和日期）
     */
    public function selectById($planId)
    {
        $plan = BizRestPlan::find($planId);
        if (!$plan) return null;

        $plan->employees = BizRestPlanEmployee::where('plan_id', $planId)
            ->get()
            ->toArray();

        if ($plan->config_type === '1') {
            $plan->dates = BizRestPlanDate::where('plan_id', $planId)
                ->orderBy('rest_date')
                ->get()
                ->toArray();
        } else {
            $plan->dates = [];
        }

        return $plan;
    }

    /**
     * 新建方案（含批量关联员工）
     */
    public function insert($data)
    {
        $now = date('Y-m-d H:i:s');
        $userIds = $data['user_ids'] ?? [];
        $dates = $data['dates'] ?? [];
        $reason = $data['reason'] ?? '';

        if (empty($userIds)) {
            throw new \Exception('请选择员工');
        }
        if (empty($data['plan_name'])) {
            throw new \Exception('请填写方案名称');
        }
        if ($data['config_type'] === '1' && empty($dates)) {
            throw new \Exception('按日期配置时请选择休息日期');
        }

        Db::beginTransaction();
        try {
            // 创建方案主表
            $plan = BizRestPlan::create([
                'plan_name' => $data['plan_name'],
                'config_type' => $data['config_type'] ?? '0',
                'monday' => $data['monday'] ?? '0',
                'tuesday' => $data['tuesday'] ?? '0',
                'wednesday' => $data['wednesday'] ?? '0',
                'thursday' => $data['thursday'] ?? '0',
                'friday' => $data['friday'] ?? '0',
                'saturday' => $data['saturday'] ?? '1',
                'sunday' => $data['sunday'] ?? '1',
                'effective_date' => $data['effective_date'] ?? date('Y-m-d'),
                'status' => $data['status'] ?? '0',
                'create_by' => $data['create_by'] ?? '',
                'create_time' => $now,
                'update_by' => $data['update_by'] ?? '',
                'update_time' => $now,
            ]);

            // 批量关联员工
            $this->syncEmployees($plan->plan_id, $userIds);

            // 按日期模式：保存日期
            if ($data['config_type'] === '1') {
                $this->syncDates($plan->plan_id, $dates, $reason);
            }

            Db::commit();
            return $plan->plan_id;
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
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
        $dates = $data['dates'] ?? [];
        $reason = $data['reason'] ?? '';

        if (empty($userIds)) {
            throw new \Exception('请选择员工');
        }
        if ($data['config_type'] === '1' && empty($dates)) {
            throw new \Exception('按日期配置时请选择休息日期');
        }

        Db::beginTransaction();
        try {
            $updateData = [
                'plan_name' => $data['plan_name'] ?? $plan->plan_name,
                'config_type' => $data['config_type'] ?? $plan->config_type,
                'effective_date' => $data['effective_date'] ?? $plan->effective_date,
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

            // 重新同步员工
            $this->syncEmployees($planId, $userIds, true);

            // 按日期模式：重新同步日期
            if (($data['config_type'] ?? $plan->config_type) === '1') {
                $this->syncDates($planId, $dates, $reason, true);
            } else {
                BizRestPlanDate::where('plan_id', $planId)->delete();
            }

            Db::commit();
            return true;
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 删除方案（级联删除关联）
     */
    public function deleteByIds($planIds)
    {
        if (empty($planIds)) return 0;

        Db::beginTransaction();
        try {
            $count = BizRestPlan::whereIn('plan_id', $planIds)->delete();
            BizRestPlanEmployee::whereIn('plan_id', $planIds)->delete();
            BizRestPlanDate::whereIn('plan_id', $planIds)->delete();
            Db::commit();
            return $count;
        } catch (\Exception $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 同步员工关联
     */
    protected function syncEmployees($planId, $userIds, $clearExisting = false)
    {
        if ($clearExisting) {
            BizRestPlanEmployee::where('plan_id', $planId)->delete();
        }

        if (empty($userIds)) return;

        // 批量查询用户和部门信息
        $users = SysUser::whereIn('user_id', $userIds)->get()->keyBy('user_id');
        $deptIds = $users->pluck('dept_id')->filter()->unique()->toArray();
        $depts = !empty($deptIds)
            ? SysDept::whereIn('dept_id', $deptIds)->pluck('dept_name', 'dept_id')->toArray()
            : [];

        $rows = [];
        $now = date('Y-m-d H:i:s');
        foreach ($userIds as $userId) {
            $user = $users->get($userId);
            $deptId = $user->dept_id ?? null;
            $rows[] = [
                'plan_id' => $planId,
                'user_id' => $userId,
                'user_name' => $user ? ($user->nick_name ?? $user->user_name) : '',
                'dept_id' => $deptId,
                'dept_name' => $deptId ? ($depts[$deptId] ?? '') : '',
            ];
        }
        BizRestPlanEmployee::insert($rows);
    }

    /**
     * 同步日期关联
     */
    protected function syncDates($planId, $dates, $reason, $clearExisting = false)
    {
        if ($clearExisting) {
            BizRestPlanDate::where('plan_id', $planId)->delete();
        }
        if (empty($dates)) return;

        $rows = [];
        foreach ($dates as $date) {
            $rows[] = [
                'plan_id' => $planId,
                'rest_date' => $date,
                'reason' => $reason,
            ];
        }
        BizRestPlanDate::insert($rows);
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
     * 检查某员工某天是否休息日
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

        if ($plan->config_type === '0') {
            // 按周配置
            return $plan->$field === '1';
        } else {
            // 按日期配置：检查 biz_rest_plan_date
            return BizRestPlanDate::where('plan_id', $plan->plan_id)
                ->where('rest_date', $date)
                ->exists();
        }
    }

    /**
     * 获取员工某天有效的休息方案
     */
    public function getUserEffectivePlan($userId, $date)
    {
        $planId = BizRestPlanEmployee::where('user_id', $userId)
            ->pluck('plan_id')
            ->toArray();
        if (empty($planId)) return null;

        return BizRestPlan::whereIn('plan_id', $planId)
            ->where('status', '0')
            ->where('effective_date', '<=', $date)
            ->orderBy('effective_date', 'desc')
            ->first();
    }

    /**
     * 批量获取员工某月的休息日列表
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

        // 一次性查询所有员工的方案
        $planIds = BizRestPlanEmployee::whereIn('user_id', $userIds)
            ->pluck('plan_id')
            ->unique()
            ->toArray();
        if (empty($planIds)) {
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
                // 返回数组格式，避免 PHP 整数 key 在 JSON 序列化时被重新索引
                $result[] = ['userId' => $userId, 'restDates' => $restDates];
            }
            return $result;
        }

        $plans = BizRestPlan::whereIn('plan_id', $planIds)
            ->where('status', '0')
            ->where('effective_date', '<=', $endDate)
            ->orderBy('effective_date', 'desc')
            ->get()
            ->keyBy('plan_id');

        // 员工-方案映射（合并所有有效方案，避免只显示最新方案）
        $userPlansMap = [];
        $employeeRows = BizRestPlanEmployee::whereIn('user_id', $userIds)->get();
        foreach ($userIds as $userId) {
            $userPlanIds = $employeeRows->where('user_id', $userId)->pluck('plan_id')->toArray();
            $effectivePlans = [];
            foreach ($userPlanIds as $pid) {
                $plan = $plans->get($pid);
                if ($plan) {
                    $effectivePlans[] = $plan;
                }
            }
            $userPlansMap[$userId] = $effectivePlans;
        }

        // 批量查询日期配置
        $allDatePlans = BizRestPlanDate::whereIn('plan_id', $planIds)
            ->whereBetween('rest_date', [$startDate, $endDate])
            ->get()
            ->groupBy('plan_id');

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
            // 返回数组格式，避免 PHP 整数 key 在 JSON 序列化时被重新索引
            $result[] = ['userId' => $userId, 'restDates' => $restDates];
        }

        return $result;
    }
}
