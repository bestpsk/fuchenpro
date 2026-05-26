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

        $pageNum = intval($params['pageNum'] ?? 1);
        $pageSize = intval($params['pageSize'] ?? 10);
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
        return BizAttendanceRule::where('rule_id', $data['rule_id'])->update($data);
    }

    // 批量删除考勤规则

    public function deleteRuleByIds($ruleIds)
    {
        return BizAttendanceRule::whereIn('rule_id', $ruleIds)->delete();
    }

    public function getActiveRule()
    {
        return BizAttendanceRule::where('status', '0')->first();
    }
}
