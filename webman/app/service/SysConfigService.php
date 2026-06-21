<?php

namespace app\service;

use app\model\SysConfig;
use support\Redis;
use app\common\Constants;

/**
 * 系统参数配置服务层，处理参数的增删改查和缓存管理
 */
class SysConfigService
{
    // 按条件分页查询系统参数配置列表
    public static function selectConfigList($params = [])
    {
        $query = SysConfig::query();

        if (!empty($params['config_name'])) {
            $query->where('config_name', 'like', '%' . $params['config_name'] . '%');
        }
        if (!empty($params['config_key'])) {
            $query->where('config_key', 'like', '%' . $params['config_key'] . '%');
        }
        if (!empty($params['config_type'])) {
            $query->where('config_type', $params['config_type']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('config_id', 'asc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询系统参数配置详情

    public static function selectConfigById($configId)
    {
        return SysConfig::find($configId);
    }

    // 根据参数键名查询参数值

    public static function selectConfigByKey($configKey)
    {
        $redis = Redis::connection();
        $cacheKey = Constants::SYS_CONFIG_KEY . $configKey;
        $cached = $redis->get($cacheKey);
        if ($cached !== null && $cached !== false) {
            return $cached;
        }

        $config = SysConfig::where('config_key', $configKey)->first();
        if ($config) {
            $redis->set($cacheKey, $config->config_value);
            return $config->config_value;
        }
        return null;
    }

    // 新增系统参数配置

    public static function insertConfig($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $result = SysConfig::create($data);
        if (!empty($data['config_key'])) {
            $redis = Redis::connection();
            $redis->set(Constants::SYS_CONFIG_KEY . $data['config_key'], $data['config_value']);
        }
        return $result;
    }

    // 更新系统参数配置信息

    public static function updateConfig($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        $result = SysConfig::where('config_id', $data['config_id'])->update($data);
        if (!empty($data['config_key'])) {
            $redis = Redis::connection();
            $redis->set(Constants::SYS_CONFIG_KEY . $data['config_key'], $data['config_value'] ?? '');
        }
        return $result;
    }

    // 批量删除系统参数配置

    public static function deleteConfigByIds($configIds)
    {
        $configs = SysConfig::whereIn('config_id', $configIds)->get();
        $redis = Redis::connection();
        foreach ($configs as $config) {
            $redis->del(Constants::SYS_CONFIG_KEY . $config->config_key);
        }
        return SysConfig::whereIn('config_id', $configIds)->delete();
    }

    public static function resetConfigCache()
    {
        $redis = Redis::connection();
        $keys = $redis->keys(Constants::SYS_CONFIG_KEY . '*');
        foreach ($keys as $key) {
            $redis->del($key);
        }
        $configs = SysConfig::all();
        foreach ($configs as $config) {
            $redis->set(Constants::SYS_CONFIG_KEY . $config->config_key, $config->config_value);
        }
    }

    /**
     * 根据参数键名获取参数值，支持默认值
     */
    public static function getConfigValue(string $configKey, $default = null)
    {
        $value = self::selectConfigByKey($configKey);
        return $value !== null ? $value : $default;
    }

    /**
     * 根据参数键名设置参数值，不存在则创建
     */
    public static function setConfigValue(string $configKey, string $configValue, string $configName = '', string $configType = 'Y')
    {
        $config = SysConfig::where('config_key', $configKey)->first();
        if ($config) {
            $config->config_value = $configValue;
            $config->update_time = date('Y-m-d H:i:s');
            $config->save();
        } else {
            SysConfig::create([
                'config_name' => $configName ?: $configKey,
                'config_key' => $configKey,
                'config_value' => $configValue,
                'config_type' => $configType,
                'create_time' => date('Y-m-d H:i:s'),
            ]);
        }
        $redis = Redis::connection();
        $redis->set(Constants::SYS_CONFIG_KEY . $configKey, $configValue);
    }

    // 查询验证码是否启用

    public static function selectCaptchaEnabled()
    {
        $value = self::selectConfigByKey('sys.account.captchaEnabled');
        return $value === 'true';
    }
}
