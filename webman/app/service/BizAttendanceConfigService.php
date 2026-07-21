<?php

namespace app\service;

use app\model\BizAttendanceConfig;
use app\model\BizAttendanceRule;
use app\model\SysUser;

class BizAttendanceConfigService
{
    public function selectConfigList($params = [])
    {
        $query = BizAttendanceConfig::with(['rule']);

        if (!empty($params['config_name'])) {
            $query->where('config_name', 'like', '%' . $params['config_name'] . '%');
        }
        if (!empty($params['config_type'])) {
            $query->where('config_type', $params['config_type']);
        }
        if (!empty($params['rule_id'])) {
            $query->where('rule_id', $params['rule_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('config_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    public function selectConfigById($configId)
    {
        return BizAttendanceConfig::with(['rule'])->find($configId);
    }

    public function insertConfig($data)
    {
        if (isset($data['user_ids']) && is_array($data['user_ids'])) {
            $data['user_ids'] = !empty($data['user_ids']) ? implode(',', $data['user_ids']) : null;
        }
        if (isset($data['dept_ids']) && is_array($data['dept_ids'])) {
            $data['dept_ids'] = !empty($data['dept_ids']) ? implode(',', $data['dept_ids']) : null;
        }
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizAttendanceConfig::create($data);
    }

    public function updateConfig($data)
    {
        if (isset($data['user_ids']) && is_array($data['user_ids'])) {
            $data['user_ids'] = !empty($data['user_ids']) ? implode(',', $data['user_ids']) : null;
        }
        if (isset($data['dept_ids']) && is_array($data['dept_ids'])) {
            $data['dept_ids'] = !empty($data['dept_ids']) ? implode(',', $data['dept_ids']) : null;
        }
        $data['update_time'] = date('Y-m-d H:i:s');

        $fillable = [
            'config_name', 'rule_id', 'config_type', 'user_ids', 'dept_ids',
            'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
        ];
        $updateData = array_intersect_key($data, array_flip($fillable));

        return BizAttendanceConfig::where('config_id', $data['config_id'])->update($updateData);
    }

    public function deleteConfigByIds($configIds)
    {
        return BizAttendanceConfig::whereIn('config_id', $configIds)->delete();
    }

    public function getUserRule($userId)
    {
        return $this->getUserRuleByClockType($userId, '0');
    }

    /**
     * 根据打卡类型获取用户考勤规则
     * 优先从配置查找关联规则（用户级→部门级），且规则 clock_type 匹配
     * 未找到时降级到 getActiveRule() 并按 clock_type 过滤
     */
    public function getUserRuleByClockType($userId, $clockType = '0')
    {
        // 1. 用户级配置：查找关联的且 clock_type 匹配的规则
        $userConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, user_ids)", [$userId])
            ->where('config_type', 1)
            ->where('status', '0')
            ->get();

        foreach ($userConfig as $config) {
            $rule = BizAttendanceRule::find($config->rule_id);
            if ($rule && (string)$rule->clock_type === (string)$clockType) {
                return $rule;
            }
        }

        // 2. 部门级配置
        $user = SysUser::find($userId);
        if ($user && $user->dept_id) {
            $deptConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, dept_ids)", [$user->dept_id])
                ->where('config_type', 2)
                ->where('status', '0')
                ->get();

            foreach ($deptConfig as $config) {
                $rule = BizAttendanceRule::find($config->rule_id);
                if ($rule && (string)$rule->clock_type === (string)$clockType) {
                    return $rule;
                }
            }
        }

        // 3. 降级：从所有活跃规则中按 clock_type 查找
        $rule = BizAttendanceRule::where('status', '0')
            ->where('clock_type', $clockType)
            ->first();

        if ($rule) {
            return $rule;
        }

        // 4. 最终降级：返回默认活跃规则（不区分 clock_type）
        $ruleService = new BizAttendanceRuleService();
        return $ruleService->getActiveRule();
    }
}
