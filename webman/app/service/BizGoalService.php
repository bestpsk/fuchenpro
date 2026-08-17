<?php

namespace app\service;

use app\model\BizGoal;
use app\model\BizGoalDaily;
use app\model\BizGoalAdjustLog;
use app\model\BizStore;
use app\model\BizEnterprise;
use app\model\BizRestDay;
use app\service\DataScopeService;
use app\service\SysConfigService;
use support\Db;
use support\Log;

/**
 * 目标管理服务层
 * 数据可见范围以 sys_role.data_scope 为依据，复用 DataScopeService
 */
class BizGoalService
{
    /**
     * 分页查询目标列表（叠加数据权限）
     */
    public function selectGoalList($params = [])
    {
        $query = BizGoal::query();

        if (!empty($params['goal_name'])) $query->where('goal_name', 'like', '%' . $params['goal_name'] . '%');
        if (!empty($params['owner_type'])) $query->where('owner_type', $params['owner_type']);
        if (!empty($params['owner_id'])) $query->where('owner_id', $params['owner_id']);
        if (!empty($params['period_type'])) $query->where('period_type', $params['period_type']);
        if (!empty($params['metric_type'])) $query->where('metric_type', $params['metric_type']);
 if (isset($params['status']) && $params['status'] !== '') $query->where('status', $params['status']);
        if (!empty($params['activity_name'])) $query->where('activity_name', 'like', '%' . $params['activity_name'] . '%');
        if (!empty($params['card_item_id'])) $query->where('card_item_id', $params['card_item_id']);

        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $this->applyGoalScope($query, $params['login_user']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('goal_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    /**
     * 目标专属数据权限过滤（以 sys_role.data_scope 为依据）
     * 可见范围 = 我管辖用户创建的目标 OR 归属我个人的目标 OR 归属我可见部门的目标
     */
    public function applyGoalScope($query, $loginUser)
    {
        if (empty($loginUser) || $loginUser->isAdmin()) {
            return $query;
        }

        $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
        $myUserId = $loginUser->userId;
        $visibleDeptIds = DataScopeService::getVisibleDeptIds($loginUser);

        // 我管辖的门店IDs（通过 biz_store.server_user_id FIND_IN_SET）
        $myStoreIds = BizStore::where(function ($q) use ($visibleUserIds) {
            foreach ($visibleUserIds as $uid) {
                $q->orWhereRaw('FIND_IN_SET(?, server_user_id)', [$uid]);
            }
        })->pluck('store_id')->toArray();

        $query->where(function ($q) use ($visibleUserIds, $myUserId, $myStoreIds, $visibleDeptIds) {
            // 我管辖用户创建的目标
            $q->whereIn('creator_user_id', $visibleUserIds)
              // 归属我个人的目标
              ->orWhere(function ($q2) use ($myUserId) {
                  $q2->where('owner_type', '4')->where('owner_id', $myUserId);
              })
              // 归属我管辖门店的目标（旧数据兼容）
              ->orWhere(function ($q2) use ($myStoreIds) {
                  $q2->where('owner_type', '3')->whereIn('owner_id', $myStoreIds);
              })
              // 归属我可见部门的目标
              ->orWhere(function ($q2) use ($visibleDeptIds) {
                  $q2->where('owner_type', '2')->whereIn('owner_id', $visibleDeptIds);
              })
              // 公司级目标（旧数据）：有可见部门的用户可查看
              ->orWhere(function ($q2) use ($visibleDeptIds) {
                  if (!empty($visibleDeptIds)) {
                      $q2->where('owner_type', '1');
                  }
              });
        });

        return $query;
    }

    // 根据ID查询目标详情
    public function selectGoalById($goalId)
    {
        return BizGoal::find($goalId);
    }

    /**
     * 新增目标
     */
    public function insertGoal($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $goal = BizGoal::create($data);

        // 自动生成日目标
        if ($goal && in_array($goal->period_type, ['3', '4'])) {
            $this->generateDailyGoals($goal->goal_id);
        }
        return $goal;
    }

    /**
     * 更新目标（非目标值调整，目标值调整走 adjustGoal 留痕）
     */
    public function updateGoal($data)
    {
        $goal = BizGoal::find($data['goal_id']);
        if (!$goal) {
            throw new \RuntimeException('目标不存在');
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        $goal->fill($data)->save();

        // 周期变更后重算日目标
        if (in_array($goal->period_type, ['3', '4'])) {
            $this->generateDailyGoals($goal->goal_id);
        }
        return $goal;
    }

    // 批量删除目标
    public function deleteGoalByIds($goalIds)
    {
        BizGoalDaily::whereIn('goal_id', $goalIds)->delete();
        BizGoalAdjustLog::whereIn('goal_id', $goalIds)->delete();
        return BizGoal::whereIn('goal_id', $goalIds)->delete();
    }

    /**
     * 生成日目标明细
     * 个人目标(owner_type=4)：排除该用户休息日，工作日均分
     * 公司/区域/门店目标：按周期日历日均分（每日均分）
     */
    public function generateDailyGoals($goalId)
    {
        $goal = BizGoal::find($goalId);
        if (!$goal) return false;

        $startDate = new \DateTime($goal->start_date);
        $endDate = new \DateTime($goal->end_date);
        $interval = new \DateInterval('P1D');
        $dateRange = new \DatePeriod($startDate, $interval, $endDate->modify('+1 day'));

        // 个人目标：获取该用户周期内休息日集合
        $restDates = [];
        if ($goal->owner_type === '4') {
            $restRecords = BizRestDay::where('user_id', $goal->owner_id)
                ->whereBetween('rest_date', [$goal->start_date, $goal->end_date])
                ->pluck('rest_date')
                ->toArray();
            $restDates = array_flip($restRecords);
        }

        // 计算工作日数量
        $workDays = [];
        foreach ($dateRange as $date) {
            $dateStr = $date->format('Y-m-d');
            if (isset($restDates[$dateStr])) continue;
            $workDays[] = $dateStr;
        }

        $workDayCount = count($workDays);
        $dailyValue = $workDayCount > 0 ? round($goal->target_value / $workDayCount, 2) : 0;

        // 删除旧的日目标（重算）
        BizGoalDaily::where('goal_id', $goalId)->delete();

        // 生成所有日期记录（休息日目标为0）
        $rows = [];
        foreach ($dateRange as $date) {
            $dateStr = $date->format('Y-m-d');
            $isRest = isset($restDates[$dateStr]) ? 1 : 0;
            $rows[] = [
                'goal_id' => $goalId,
                'target_date' => $dateStr,
                'target_value' => $isRest ? 0 : $dailyValue,
                'is_rest_day' => $isRest,
                'remark' => null,
            ];
        }

        // 批量插入（分批避免超限）
        foreach (array_chunk($rows, 500) as $chunk) {
            BizGoalDaily::insert($chunk);
        }

        // 末位误差补齐到最后一日
        if ($workDayCount > 0) {
            $sumDaily = bcmul($dailyValue, $workDayCount, 2);
            $diff = bcsub($goal->target_value, $sumDaily, 2);
            if (bccomp($diff, '0', 2) !== 0) {
                $lastWorkDate = end($workDays);
                BizGoalDaily::where('goal_id', $goalId)
                    ->where('target_date', $lastWorkDate)
                    ->update(['target_value' => bcadd($dailyValue, $diff, 2)]);
            }
        }

        return true;
    }

    /**
     * 目标调整（留痕）
     */
    public function adjustGoal($goalId, $newValue, $reason, $adjustBy)
    {
        $goal = BizGoal::find($goalId);
        if (!$goal) {
            throw new \RuntimeException('目标不存在');
        }
        if (empty($reason)) {
            throw new \RuntimeException('调整原因不能为空');
        }

        $oldValue = $goal->target_value;

        Db::beginTransaction();
        try {
            BizGoalAdjustLog::create([
                'goal_id' => $goalId,
                'old_value' => $oldValue,
                'new_value' => $newValue,
                'reason' => $reason,
                'adjust_by' => $adjustBy,
                'adjust_time' => date('Y-m-d H:i:s'),
            ]);

            $goal->target_value = $newValue;
            $goal->update_time = date('Y-m-d H:i:s');
            $goal->save();

            // 重新生成日目标
            if (in_array($goal->period_type, ['3', '4'])) {
                $this->generateDailyGoals($goalId);
            }

            Db::commit();
            return $goal;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 查询父目标已拆解的子目标列表（拆解弹窗回显用）
     * @param int $parentGoalId 父目标ID
     * @return array 子目标列表（仅拆解回显所需字段）
     */
    public function getChildrenGoals($parentGoalId)
    {
        return BizGoal::where('parent_goal_id', $parentGoalId)
            ->orderBy('goal_id', 'asc')
            ->get(['goal_id', 'owner_type', 'owner_id', 'owner_name', 'target_value'])
            ->toArray();
    }

    /**
     * 目标拆解：将父目标按比例拆解到子节点（覆盖式：先删除原拆解子目标，再插入新子目标）
     * @param int $parentGoalId 父目标ID
     * @param array $children [{owner_type, owner_id, owner_name, ratio}] 比例(0-1)
     */
    public function splitGoal($parentGoalId, $children)
    {
        $parent = BizGoal::find($parentGoalId);
        if (!$parent) {
            throw new \RuntimeException('父目标不存在');
        }

        // 允许浮动比例
        $tolerance = floatval(SysConfigService::getConfigValue('goal.split.tolerance') ?? '0.05');
        $totalRatio = 0;
        foreach ($children as $child) {
            $totalRatio += floatval($child['ratio']);
        }
        if (abs($totalRatio - 1) > $tolerance) {
            throw new \RuntimeException(sprintf('子项比例之和 %.2f 不在允许浮动范围(±%.0f%%)', $totalRatio, $tolerance * 100));
        }

        Db::beginTransaction();
        try {
            // 覆盖式重拆解：先删除原拆解子目标及其关联数据（日目标、调整日志）
            $oldChildIds = BizGoal::where('parent_goal_id', $parentGoalId)->pluck('goal_id')->toArray();
            if (!empty($oldChildIds)) {
                BizGoalDaily::whereIn('goal_id', $oldChildIds)->delete();
                BizGoalAdjustLog::whereIn('goal_id', $oldChildIds)->delete();
                BizGoal::whereIn('goal_id', $oldChildIds)->delete();
            }

            foreach ($children as $child) {
                $childValue = bcmul($parent->target_value, $child['ratio'], 2);
                $goalData = [
                    'goal_name' => $parent->goal_name . '-' . ($child['owner_name'] ?? ''),
                    'owner_type' => $child['owner_type'],
                    'owner_id' => $child['owner_id'],
                    'owner_name' => $child['owner_name'] ?? '',
                    'period_type' => $parent->period_type,
                    'period_name' => $parent->period_name,
                    'start_date' => $parent->start_date,
                    'end_date' => $parent->end_date,
                    'metric_type' => $parent->metric_type,
                    'target_value' => $childValue,
                    'unit' => $parent->unit,
                    'card_item_id' => $parent->card_item_id,
                    'activity_name' => $parent->activity_name,
                    'parent_goal_id' => $parentGoalId,
                    'status' => '0',
                    'creator_user_id' => $parent->creator_user_id,
                    'create_by' => $parent->create_by,
                    'create_time' => date('Y-m-d H:i:s'),
                ];
                $newGoal = BizGoal::create($goalData);
                if (in_array($parent->period_type, ['3', '4'])) {
                    $this->generateDailyGoals($newGoal->goal_id);
                }
            }
            Db::commit();
            return true;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 查询目标调整记录列表（分页）
     * @param array $params goal_id(可选)、page_num、page_size
     */
    public function selectAdjustLogs($params = [])
    {
        $query = Db::table('biz_goal_adjust_log as log')
            ->leftJoin('biz_goal as g', 'log.goal_id', '=', 'g.goal_id')
            ->select('log.*', 'g.goal_name', 'g.owner_name', 'g.metric_type', 'g.unit');

        if (!empty($params['goal_id'])) {
            $query->where('log.goal_id', intval($params['goal_id']));
        }
        if (!empty($params['goal_name'])) {
            $query->where('g.goal_name', 'like', '%' . $params['goal_name'] . '%');
        }
        if (!empty($params['adjust_by'])) {
            $query->where('log.adjust_by', 'like', '%' . $params['adjust_by'] . '%');
        }
        if (!empty($params['start_date'])) {
            $query->where('log.adjust_time', '>=', $params['start_date'] . ' 00:00:00');
        }
        if (!empty($params['end_date'])) {
            $query->where('log.adjust_time', '<=', $params['end_date'] . ' 23:59:59');
        }

        // 数据权限过滤：只看自己可见目标的调整记录
        if (!empty($params['login_user'])) {
            $loginUser = $params['login_user'];
            if (!$loginUser->isAdmin()) {
                $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
                $myUserId = $loginUser->userId;
                $visibleDeptIds = DataScopeService::getVisibleDeptIds($loginUser);
                $query->where(function ($q) use ($visibleUserIds, $myUserId, $visibleDeptIds) {
                    $q->whereIn('g.creator_user_id', $visibleUserIds)
                      ->orWhere(function ($q2) use ($myUserId) {
                          $q2->where('g.owner_type', '4')->where('g.owner_id', $myUserId);
                      })
                      ->orWhere(function ($q2) use ($visibleDeptIds) {
                          $q2->where('g.owner_type', '2')->whereIn('g.owner_id', $visibleDeptIds);
                      });
                });
            }
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('log.adjust_time', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    /**
     * 查询日目标明细
     * @param int $goalId 目标ID
     * @return array ['goal' => 目标对象, 'dailyList' => 日目标列表, 'today' => 今日日期]
     */
    public function selectDailyDetail($goalId)
    {
        $goal = BizGoal::find($goalId);
        if (!$goal) return null;

        $dailyList = BizGoalDaily::where('goal_id', $goalId)
            ->orderBy('target_date', 'asc')
            ->get()
            ->toArray();

        return [
            'goal' => $goal,
            'daily_list' => $dailyList,
            'today' => date('Y-m-d'),
        ];
    }

    /**
     * 校验归属范围是否在当前用户数据权限内
     */
    public function checkOwnerScope($ownerType, $ownerId, $loginUser)
    {
        if (empty($loginUser) || $loginUser->isAdmin()) return true;

        $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);

        switch ($ownerType) {
            case '1': // 公司级，仅全部数据权限可创建
                return in_array('1', $this->getUserDataScopes($loginUser));
            case '2': // 部门=dept_id
                $visibleDeptIds = DataScopeService::getVisibleDeptIds($loginUser);
                return in_array($ownerId, $visibleDeptIds);
            case '3': // 门店
                $store = BizStore::find($ownerId);
                if (!$store) return false;
                foreach ($visibleUserIds as $uid) {
                    if (false !== strpos(',' . $store->server_user_id . ',', ',' . $uid . ',')) {
                        return true;
                    }
                }
                return false;
            case '4': // 个人
                return $ownerId == $loginUser->userId || in_array($ownerId, $visibleUserIds);
            default:
                return false;
        }
    }

    // 获取用户所有角色的 data_scope 数组
    private function getUserDataScopes($loginUser)
    {
        $scopes = [];
        $roles = $loginUser->user ? $loginUser->user->roles : [];
        foreach ($roles as $role) {
            $scopes[] = is_array($role) ? ($role['data_scope'] ?? '5') : ($role->data_scope ?? '5');
        }
        return $scopes;
    }
}
