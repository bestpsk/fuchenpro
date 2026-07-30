<?php

namespace app\service;

use app\model\BizAttendanceRule;

/**
 * 考勤规则服务层，处理考勤规则的增删改查
 */
class BizAttendanceRuleService
{
    // 按条件分页查询考勤规则列表
    public function selectRuleList($params = [])
    {
        $query = BizAttendanceRule::query();

        if (!empty($params['rule_name'])) {
            $query->where('rule_name', 'like', '%' . $params['rule_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (isset($params['clock_type']) && $params['clock_type'] !== '') {
            $query->where('clock_type', $params['clock_type']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('rule_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询考勤规则详情

    public function selectRuleById($ruleId)
    {
        return BizAttendanceRule::find($ruleId);
    }

    // 新增考勤规则

    public function insertRule($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizAttendanceRule::create($data);
    }

    // 更新考勤规则信息

    public function updateRule($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        $rule = BizAttendanceRule::find($data['rule_id']);
        if (!$rule) {
            throw new \Exception('考勤规则不存在');
        }
        $rule->fill($data)->save();
        return true;
    }

    // 批量删除考勤规则

    public function deleteRuleByIds($ruleIds)
    {
        if (empty($ruleIds)) return 0;
        // 检查是否有考勤配置引用了待删除的规则
        $referencedCount = \app\model\BizAttendanceConfig::whereIn('rule_id', $ruleIds)->count();
        if ($referencedCount > 0) {
            throw new \Exception('该规则已被考勤配置引用，请先解除关联后再删除');
        }
        return BizAttendanceRule::whereIn('rule_id', $ruleIds)->delete();
    }
}
