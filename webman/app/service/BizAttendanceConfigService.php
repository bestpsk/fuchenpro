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

        $pageNum = intval($params['pageNum'] ?? 1);
        $pageSize = intval($params['pageSize'] ?? 10);
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
        $userConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, user_ids)", [$userId])
            ->where('config_type', 1)
            ->where('status', '0')
            ->first();

        if ($userConfig) {
            return BizAttendanceRule::find($userConfig->rule_id);
        }

        $user = SysUser::find($userId);
        if ($user && $user->dept_id) {
            $deptConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, dept_ids)", [$user->dept_id])
                ->where('config_type', 2)
                ->where('status', '0')
                ->first();

            if ($deptConfig) {
                return BizAttendanceRule::find($deptConfig->rule_id);
            }
        }

        $ruleService = new BizAttendanceRuleService();
        return $ruleService->getActiveRule();
    }
}
