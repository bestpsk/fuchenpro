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
        // 用户级配置校验：同一用户不能出现在多个用户级配置中
        $this->checkUserConfigConflict($data['user_ids'] ?? '', $data['config_type'] ?? 1);
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
        // 用户级配置校验：排除自身后检查同一用户是否已在其他用户级配置中
        $this->checkUserConfigConflict($data['user_ids'] ?? '', $data['config_type'] ?? 1, $data['config_id'] ?? null);
        $data['update_time'] = date('Y-m-d H:i:s');

        $fillable = [
            'config_name', 'rule_id', 'config_type', 'user_ids', 'dept_ids',
            'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
        ];
        $updateData = array_intersect_key($data, array_flip($fillable));

        return BizAttendanceConfig::where('config_id', $data['config_id'])->update($updateData);
    }

    /**
     * 校验用户级配置中同一用户是否已在其他配置中（防止多配置冲突）
     * @param string $userIdsStr 逗号分隔的用户ID
     * @param int $configType 配置类型（仅用户级需校验）
     * @param int|null $excludeConfigId 排除的配置ID（更新时排除自身）
     * @throws \Exception 如有冲突则抛出异常
     */
    protected function checkUserConfigConflict($userIdsStr, $configType, $excludeConfigId = null)
    {
        if ((int)$configType !== 1 || empty($userIdsStr)) return;
        $userIds = array_filter(array_map('intval', explode(',', $userIdsStr)), fn($v) => $v > 0);
        if (empty($userIds)) return;

        // 查询其他用户级配置中关联的员工
        $query = BizAttendanceConfig::where('config_type', 1)->where('status', '0');
        if ($excludeConfigId) {
            $query->where('config_id', '!=', $excludeConfigId);
        }
        $existingConfigs = $query->get(['config_id', 'config_name', 'user_ids']);
        $conflictUsers = [];
        foreach ($existingConfigs as $config) {
            $existingUserIds = array_filter(array_map('intval', explode(',', $config->user_ids ?? '')), fn($v) => $v > 0);
            foreach ($existingUserIds as $uid) {
                if (in_array($uid, $userIds)) {
                    $user = SysUser::find($uid);
                    $name = $user ? ($user->nick_name ?? $user->user_name) : ('用户' . $uid);
                    $conflictUsers[] = $name . '(已存在于配置"' . $config->config_name . '")';
                }
            }
        }
        if (!empty($conflictUsers)) {
            throw new \Exception('以下员工已有考勤配置：' . implode('、', array_unique($conflictUsers)));
        }
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
     * 未找到时降级到所有活跃规则中按 clock_type 查找；仍无则返回 null
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

        // 找不到对应 clock_type 的规则时返回 null，避免使用错误类型的规则
        // （例如坐班打卡误用外勤规则，导致跳过距离校验）
        return $rule;
    }
}
