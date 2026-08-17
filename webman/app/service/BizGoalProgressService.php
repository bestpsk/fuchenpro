<?php

namespace app\service;

use app\model\BizGoal;
use app\model\BizGoalDaily;
use app\model\BizStore;
use app\model\BizEnterprise;
use app\service\DataScopeService;
use support\Db;

/**
 * 目标进度计算服务
 * 按 metric_type 聚合对应数据源，计算核心行动指标
 */
class BizGoalProgressService
{
    /**
     * 计算单个目标的完整进度
     */
    public function calculateProgress($goal)
    {
        if (!$goal) return null;

        $completed = $this->aggregateCompleted($goal);
        $targetValue = floatval($goal->target_value);

        // 日目标统计
        $today = date('Y-m-d');
        $dailyStats = $this->getDailyStats($goal, $today);

        $completionRate = $targetValue > 0 ? round($completed / $targetValue, 4) : 0;
        $diff = round($targetValue - $completed, 2);

        // 当前日均产出
        $passedDays = intval($dailyStats['passed_work_days']);
        $remainDays = intval($dailyStats['remain_work_days']);
        $currentDaily = $passedDays > 0 ? round($completed / $passedDays, 2) : 0;

        // 剩余日均需完成
        $remainDailyNeed = $remainDays > 0 ? round(($targetValue - $completed) / $remainDays, 2) : 0;

        // 月末预测完成率 = (已完成 + 剩余天数 * 当前日均) / 目标
        $forecastTotal = $completed + $remainDays * $currentDaily;
        $forecastRate = $targetValue > 0 ? round($forecastTotal / $targetValue, 4) : 0;

        // 预计达成日（按当前日均线性推算）
        $expectedAchieveDate = null;
        if ($currentDaily > 0 && $completed < $targetValue) {
            $daysNeeded = ceil(($targetValue - $completed) / $currentDaily);
            $expectedAchieveDate = date('Y-m-d', strtotime("+{$daysNeeded} days"));
        } elseif ($completed >= $targetValue && $targetValue > 0) {
            $expectedAchieveDate = $today;
        }

        return [
            'goal_id' => $goal->goal_id,
            'goal_name' => $goal->goal_name,
            'owner_type' => $goal->owner_type,
            'owner_id' => $goal->owner_id,
            'owner_name' => $goal->owner_name,
            'metric_type' => $goal->metric_type,
            'unit' => $goal->unit,
            'period_type' => $goal->period_type,
            'start_date' => $goal->start_date,
            'end_date' => $goal->end_date,
            'target_value' => $targetValue,
            'completed' => round($completed, 2),
            'diff' => $diff,
            'completion_rate' => $completionRate,
            'completion_rate_text' => round($completionRate * 100, 1) . '%',
            'passed_work_days' => $passedDays,
            'remain_work_days' => $remainDays,
            'current_daily' => $currentDaily,
            'remain_daily_need' => $remainDailyNeed,
            'expected_achieve_date' => $expectedAchieveDate,
            'forecast_rate' => $forecastRate,
            'forecast_rate_text' => round($forecastRate * 100, 1) . '%',
            'today_target' => $dailyStats['today_target'],
            'today_completed' => $this->aggregateCompleted($goal, $today, $today),
        ];
    }

    /**
     * 聚合已完成值
     * @param BizGoal $goal
     * @param string|null $startDate 起始日期（null用目标周期）
     * @param string|null $endDate 结束日期
     */
    public function aggregateCompleted($goal, $startDate = null, $endDate = null)
    {
        $startDate = $startDate ?: $goal->start_date;
        $endDate = $endDate ?: $goal->end_date;

        $ownerFilter = $this->getOwnerFilter($goal);

        switch ($goal->metric_type) {
            case '1': // 实收业绩
                $q = Db::table('biz_sales_order')
                    ->where('order_status', '1')
                    ->whereBetween('create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
                $this->applyOwnerFilter($q, $ownerFilter, 'biz_sales_order');
                return floatval($q->sum('paid_amount'));

            case '2': // 消耗业绩
                $q = Db::table('biz_operation_record')
                    ->whereBetween('operation_date', [$startDate, $endDate]);
                $this->applyOwnerFilter($q, $ownerFilter, 'biz_operation_record');
                return floatval($q->sum('consume_amount'));

            case '3': // 出货金额
                $q = Db::table('biz_stock_out')
                    ->where('status', '1')
                    ->where('stock_out_type', '1')
                    ->whereBetween('stock_out_date', [$startDate, $endDate]);
                $this->applyOwnerFilter($q, $ownerFilter, 'biz_stock_out');
                return floatval($q->sum('total_amount'));

            case '4': // 品项件数
                $q = Db::table('biz_order_item as oi')
                    ->join('biz_sales_order as o', 'oi.order_id', '=', 'o.order_id')
                    ->where('o.order_status', '1')
                    ->where('oi.card_item_id', $goal->card_item_id)
                    ->whereBetween('o.create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
                $this->applyOwnerFilter($q, $ownerFilter, 'o');
                return floatval($q->sum('oi.quantity'));

            case '5': // 品项金额
                $q = Db::table('biz_order_item as oi')
                    ->join('biz_sales_order as o', 'oi.order_id', '=', 'o.order_id')
                    ->where('o.order_status', '1')
                    ->where('oi.card_item_id', $goal->card_item_id)
                    ->whereBetween('o.create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
                $this->applyOwnerFilter($q, $ownerFilter, 'o');
                return floatval($q->sum('oi.paid_amount'));

            case '6': // 到店客次
                $q = Db::table('biz_sales_order')
                    ->where('order_status', '1')
                    ->whereBetween('create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
                $this->applyOwnerFilter($q, $ownerFilter, 'biz_sales_order');
                return floatval($q->distinct()->count('customer_id'));

            case '7': // 新客数
                $q = Db::table('biz_customer')
                    ->whereBetween('create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
                $this->applyOwnerFilter($q, $ownerFilter, 'biz_customer');
                return floatval($q->count());

            case '8': // 活跃门店数
                $orderStores = Db::table('biz_sales_order')
                    ->where('order_status', '1')
                    ->whereBetween('create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])
                    ->whereNotNull('store_id');
                $this->applyOwnerFilter($orderStores, $ownerFilter, 'biz_sales_order');
                $storeCount = $orderStores->distinct()->count('store_id');
                $opStores = Db::table('biz_operation_record')
                    ->whereBetween('operation_date', [$startDate, $endDate])
                    ->whereNotNull('store_id');
                $this->applyOwnerFilter($opStores, $ownerFilter, 'biz_operation_record');
                $opCount = $opStores->distinct()->count('store_id');
                return floatval($storeCount + $opCount - $this->countCommonStores($goal, $startDate, $endDate));

            default:
                return 0.0;
        }
    }

    // 活跃门店数去重：订单门店与操作记录门店交集
    private function countCommonStores($goal, $startDate, $endDate)
    {
        $ownerFilter = $this->getOwnerFilter($goal);
        $orderQ = Db::table('biz_sales_order')->where('order_status', '1')
            ->whereBetween('create_time', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])->whereNotNull('store_id');
        $this->applyOwnerFilter($orderQ, $ownerFilter, 'biz_sales_order');
        $orderStores = $orderQ->distinct()->pluck('store_id')->toArray();

        $opQ = Db::table('biz_operation_record')->whereBetween('operation_date', [$startDate, $endDate])->whereNotNull('store_id');
        $this->applyOwnerFilter($opQ, $ownerFilter, 'biz_operation_record');
        $opStores = $opQ->distinct()->pluck('store_id')->toArray();

        return count(array_intersect($orderStores, $opStores));
    }

    /**
     * 根据归属层级生成过滤条件
     * @return array ['type'=>'store/enterprise/user/all', 'value'=>...]
     */
    private function getOwnerFilter($goal)
    {
        switch ($goal->owner_type) {
            case '3': // 门店
                return ['type' => 'store', 'value' => $goal->owner_id];
            case '2': // 部门，取该部门及子部门下所有用户IDs
                $deptIds = Db::table('sys_dept')
                    ->where('dept_id', $goal->owner_id)
                    ->orWhereRaw('FIND_IN_SET(?, ancestors)', [$goal->owner_id])
                    ->pluck('dept_id')->toArray();
                $userIds = Db::table('sys_user')
                    ->whereIn('dept_id', $deptIds)
                    ->where('del_flag', '0')
                    ->pluck('user_id')->toArray();
                return ['type' => 'users', 'value' => $userIds];
            case '4': // 个人
                return ['type' => 'user', 'value' => $goal->owner_id];
            case '1': // 公司
            default:
                return ['type' => 'all', 'value' => null];
        }
    }

    // 应用归属过滤到查询
    private function applyOwnerFilter($query, $filter, $tableAlias)
    {
        switch ($filter['type']) {
            case 'store':
                $query->where($tableAlias . '.store_id', $filter['value']);
                break;
            case 'enterprise':
                if (!empty($filter['value'])) {
                    $query->whereIn($tableAlias . '.enterprise_id', $filter['value']);
                }
                break;
            case 'users':
                if (!empty($filter['value'])) {
                    $userField = ($tableAlias === 'biz_operation_record') ? 'operator_user_id' : 'creator_user_id';
                    $query->whereIn($tableAlias . '.' . $userField, $filter['value']);
                } else {
                    // 部门下无用户时，不应统计任何数据（否则会误统计全部数据）
                    $query->whereRaw('1 = 0');
                }
                break;
            case 'user':
                // 订单表用 creator_user_id，操作记录用 operator_user_id
                $userField = ($tableAlias === 'biz_operation_record') ? 'operator_user_id' : 'creator_user_id';
                $query->where($tableAlias . '.' . $userField, $filter['value']);
                break;
            case 'all':
            default:
                break;
        }
    }

    /**
     * 获取日目标统计（已过工作日、剩余工作日、今日目标）
     */
    private function getDailyStats($goal, $today)
    {
        $totalWorkDays = BizGoalDaily::where('goal_id', $goal->goal_id)->where('is_rest_day', 0)->count();
        $passedWorkDays = BizGoalDaily::where('goal_id', $goal->goal_id)
            ->where('is_rest_day', 0)
            ->where('target_date', '<=', $today)
            ->count();
        $remainWorkDays = max(0, $totalWorkDays - $passedWorkDays);

        $todayRecord = BizGoalDaily::where('goal_id', $goal->goal_id)
            ->where('target_date', $today)
            ->first();
        $todayTarget = $todayRecord ? floatval($todayRecord->target_value) : 0;

        // 如果今天还没生成日目标，按日均估算
        if (!$todayRecord && $totalWorkDays > 0) {
            $todayTarget = round(floatval($goal->target_value) / $totalWorkDays, 2);
        }

        return [
            'total_work_days' => $totalWorkDays,
            'passed_work_days' => $passedWorkDays,
            'remain_work_days' => $remainWorkDays,
            'today_target' => $todayTarget,
        ];
    }

    /**
     * 批量计算多个目标的进度（用于看板/排名）
     */
    public function batchProgress($goals)
    {
        $result = [];
        foreach ($goals as $goal) {
            try {
                $result[] = $this->calculateProgress($goal);
            } catch (\Throwable $e) {
                // 单个目标进度计算异常不应影响其他目标
                $result[] = [
                    'goal_id' => $goal->goal_id,
                    'goal_name' => $goal->goal_name,
                    'owner_type' => $goal->owner_type,
                    'owner_id' => $goal->owner_id,
                    'owner_name' => $goal->owner_name,
                    'metric_type' => $goal->metric_type,
                    'unit' => $goal->unit,
                    'period_type' => $goal->period_type,
                    'start_date' => $goal->start_date,
                    'end_date' => $goal->end_date,
                    'target_value' => floatval($goal->target_value),
                    'completed' => 0,
                    'diff' => floatval($goal->target_value),
                    'completion_rate' => 0,
                    'completion_rate_text' => '0%',
                    'error' => $e->getMessage(),
                ];
            }
        }
        return $result;
    }

    /**
     * 获取用户全部个人目标进度（PC端"我的目标"用）
     * @param int $userId 当前用户ID
     * @param string|null $periodType 周期类型筛选（1年度2季度3月度4自定义）
     * @return array 进度列表
     */
    public function getMyGoalsProgress($loginUser, $periodType = null)
    {
        $query = BizGoal::where('owner_type', '4')
            ->where('status', '0')
            ->orderBy('goal_id', 'desc');

        // admin 查所有个人目标，非 admin 查数据权限下的个人目标
        if (!$loginUser->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
            $query->whereIn('owner_id', $visibleUserIds);
        }

        if ($periodType !== null && $periodType !== '') {
            $query->where('period_type', $periodType);
        }

        $goals = $query->get();
        return $this->batchProgress($goals);
    }

    /**
     * 降级：仅查询当前用户自己的个人目标（绕过数据权限，用于getMyGoalsProgress异常时兜底）
     */
    public function getMyGoalsProgressFallback($loginUser, $periodType = null)
    {
        $query = BizGoal::where('owner_type', '4')
            ->where('status', '0')
            ->where('owner_id', $loginUser->userId)
            ->orderBy('goal_id', 'desc');

        if ($periodType !== null && $periodType !== '') {
            $query->where('period_type', $periodType);
        }

        $goals = $query->get();
        return $this->batchProgress($goals);
    }

    /**
     * 获取当前用户可见部门的团队目标进度（部门负责人视角）
     * 团队目标值 = 部门目标.target_value（拆解时已含员工份额）
     * 团队完成值 = 部门目标.completed（getOwnerFilter case '2' 已聚合部门+子部门所有用户业绩）
     * 员工子目标作为下钻明细，不参与团队汇总累加（避免重复计算）
     * @param mixed $loginUser 登录用户
     * @param string|null $periodType 周期筛选
     * @return array 部门目标进度列表，每项含 children 字段（子目标进度）
     */
    public function getTeamGoalsProgress($loginUser, $periodType = null, $topLevelOnly = false)
    {
        $visibleDeptIds = DataScopeService::getVisibleDeptIds($loginUser);
        if (empty($visibleDeptIds)) {
            return [];
        }

        $query = BizGoal::where('owner_type', '2')
            ->whereIn('owner_id', $visibleDeptIds)
            ->where('status', '0')
            ->orderBy('goal_id', 'desc');

        // 有 periodType 时，补本月日期过滤（对齐 getPersonalDailyView 逻辑）
        // periodType 为空时不过滤周期类型（兼容 Web 端"全部"Tab）
        if ($periodType !== null && $periodType !== '') {
            $monthStart = date('Y-m-01');
            $monthEnd = date('Y-m-t');
            $query->where('period_type', $periodType)
                  ->whereBetween('start_date', [$monthStart, $monthEnd]);
        }

        $deptGoals = $query->get();
        if ($deptGoals->isEmpty()) {
            return [];
        }

        // 仅在 $topLevelOnly=true 时做顶层过滤（AppV3首页汇总避免翻倍）
        // "我的目标-团队目标"Tab 传 false，显示所有可见部门
        if ($topLevelOnly) {
            $deptIdsWithGoals = $deptGoals->pluck('owner_id')->unique()->toArray();
            $visibleSet = array_flip($visibleDeptIds);
            $depts = \app\model\SysDept::whereIn('dept_id', $deptIdsWithGoals)
                ->get(['dept_id', 'ancestors']);

            $topLevelDeptIds = [];
            foreach ($depts as $dept) {
                $ancestorIds = explode(',', $dept->ancestors);
                $hasAncestorWithGoalInVisible = false;
                foreach ($ancestorIds as $ancestorId) {
                    if ($ancestorId !== '0'
                        && isset($visibleSet[$ancestorId])
                        && in_array((int)$ancestorId, $deptIdsWithGoals)) {
                        $hasAncestorWithGoalInVisible = true;
                        break;
                    }
                }
                if (!$hasAncestorWithGoalInVisible) {
                    $topLevelDeptIds[] = $dept->dept_id;
                }
            }
            $deptGoals = $deptGoals->whereIn('owner_id', $topLevelDeptIds);
        }

        $result = [];
        foreach ($deptGoals as $goal) {
            $progress = $this->calculateProgress($goal);

            // 下钻明细：该部门目标下拆解的子目标（员工目标 + 子部门目标）
            $children = BizGoal::where('parent_goal_id', $goal->goal_id)
                ->where('status', '0')
                ->orderBy('goal_id', 'asc')
                ->get();
            $progress['children'] = $this->batchProgress($children);

            $result[] = $progress;
        }
        return $result;
    }

    /**
     * 获取个人今日视图（AppV3 用）
     */
    public function getPersonalDailyView($userId)
    {
        $today = date('Y-m-d');
        $monthStart = date('Y-m-01');
        $monthEnd = date('Y-m-t');
        $yearStart = date('Y-01-01');
        $yearEnd = date('Y-12-31');

        // 1. 优先查本月月度个人目标
        $goal = BizGoal::where('owner_type', '4')
            ->where('owner_id', $userId)
            ->where('period_type', '3')
            ->where('status', '0')
            ->whereBetween('start_date', [$monthStart, $monthEnd])
            ->orderBy('goal_id', 'desc')
            ->first();

        // 2. 没有月度目标则查本年度年度个人目标
        if (!$goal) {
            $goal = BizGoal::where('owner_type', '4')
                ->where('owner_id', $userId)
                ->where('period_type', '1')
                ->where('status', '0')
                ->whereBetween('start_date', [$yearStart, $yearEnd])
                ->orderBy('goal_id', 'desc')
                ->first();
        }

        // 3. 仍没有则查任何当前生效的个人目标
        if (!$goal) {
            $goal = BizGoal::where('owner_type', '4')
                ->where('owner_id', $userId)
                ->where('status', '0')
                ->where('start_date', '<=', $today)
                ->where('end_date', '>=', $today)
                ->orderBy('goal_id', 'desc')
                ->first();
        }

        if (!$goal) {
            return ['has_goal' => false];
        }

        $progress = $this->calculateProgress($goal);
        $progress['has_goal'] = true;
        return $progress;
    }
}
