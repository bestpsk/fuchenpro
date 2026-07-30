<?php

namespace app\controller\monitor;

use support\Request;
use support\Redis;
use app\service\RedisService;
use app\service\PermissionService;
use app\common\AjaxResult;

/**
 * 缓存监控控制器
 *
 * 负责Redis缓存信息的查看（服务器信息、命令统计）、
 * 缓存键名浏览、缓存值查看、按命名空间/键/全部清除缓存等功能
 */
class CacheController
{
    // 获取Redis服务器信息，包括内存使用、连接数、命令执行统计等
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $redis = Redis::connection();
        $rawInfo = $redis->info();
        $info = $this->flattenInfo($rawInfo);
        $dbSize = $redis->dbsize();

        $commandStats = $this->parseCommandStats($rawInfo);

        return AjaxResult::success('', [
            'data' => [
                'info' => $info,
                'dbSize' => $dbSize,
                'commandStats' => $commandStats,
            ]
        ]);
    }

    /**
     * 解析Redis命令统计信息
     * 支持phpredis两种返回格式：扁平数组（cmdstat_xxx 在顶层）或嵌套数组（按 Section 分组）
     */
    private function parseCommandStats(array $rawInfo): array
    {
        $commandStats = [];
        foreach ($rawInfo as $key => $value) {
            // 顶层 cmdstat_ 键（phpredis 默认 info() 返回格式）
            if (str_starts_with($key, 'cmdstat_')) {
                $this->addCommandStat($commandStats, $key, $value);
                continue;
            }
            // 嵌套分组下的 cmdstat_ 键（info('all') 等带 Section 的返回格式）
            if (is_array($value)) {
                foreach ($value as $subKey => $subValue) {
                    if (str_starts_with($subKey, 'cmdstat_')) {
                        $this->addCommandStat($commandStats, $subKey, $subValue);
                    }
                }
            }
        }
        return $commandStats;
    }

    // 将单个 cmdstat_ 条目解析为 {name, value} 结构
    private function addCommandStat(array &$commandStats, string $cmdstatKey, $value): void
    {
        $cmd = str_replace('cmdstat_', '', $cmdstatKey);
        $calls = 0;
        if (is_string($value)) {
            foreach (explode(',', $value) as $part) {
                if (str_starts_with(trim($part), 'calls=')) {
                    $calls = intval(str_replace('calls=', '', trim($part)));
                    break;
                }
            }
        } elseif (is_array($value) && isset($value['calls'])) {
            $calls = intval($value['calls']);
        }
        $commandStats[] = ['name' => $cmd, 'value' => $calls];
    }

    // 将嵌套的Redis info数据展平为一维关联数组
    private function flattenInfo(array $nestedInfo): array
    {
        $flatInfo = [];
        
        foreach ($nestedInfo as $section => $data) {
            if (is_array($data)) {
                foreach ($data as $key => $value) {
                    $snakeKey = $this->camelToSnake($key);
                    $flatInfo[$snakeKey] = $value;
                }
            } else {
                $snakeKey = $this->camelToSnake($section);
                $flatInfo[$snakeKey] = $data;
            }
        }
        
        return $flatInfo;
    }

    // 驼峰命名转蛇形命名
    private function camelToSnake(string $str): string
    {
        return strtolower(preg_replace('/([a-z])([A-Z])/', '$1_$2', $str));
    }

    // 获取所有缓存键名列表（按命名空间前缀分组）
    public function getNames(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $keys = $this->scanKeys('*');
        $names = [];
        foreach ($keys as $key) {
            $parts = explode(':', $key);
            if (count($parts) > 1) {
                $name = $parts[0] . ':' . $parts[1];
                $exists = false;
                foreach ($names as $item) {
                    if ($item['cacheName'] === $name) {
                        $exists = true;
                        break;
                    }
                }
                if (!$exists) {
                    $names[] = ['cacheName' => $name, 'remark' => ''];
                }
            }
        }
        return AjaxResult::success('', [
            'data' => $names
        ]);
    }

    // 根据缓存命名空间前缀获取该命名空间下的所有键名
    public function getKeys(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $cacheName = end($parts);
        // 使用冒号分隔符精确匹配命名空间下的键，避免 foo:bar* 误匹配 foo:barbaz
        $keys = $this->scanKeys($cacheName . ':*');
        return AjaxResult::success('', [
            'data' => $keys
        ]);
    }

    // 根据缓存命名空间和键名获取缓存值
    public function getValue(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $pathParts = explode('/', $request->path());
        $cacheName = $pathParts[count($pathParts) - 2] ?? '';
        $cacheKey = end($pathParts);
        $redis = Redis::connection();
        $fullKey = $cacheName . ':' . $cacheKey;
        $value = $redis->get($fullKey);
        return AjaxResult::success('', [
            'data' => [
                'cacheName' => $cacheName,
                'cacheKey' => $cacheKey,
                'cacheValue' => $value,
            ]
        ]);
    }

    // 清除指定命名空间下的所有缓存键
    public function clearCacheName(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $cacheName = $request->input('cacheName', '');
        $keys = $this->scanKeys($cacheName . ':*');
        $redis = Redis::connection();
        foreach ($keys as $key) {
            $redis->del($key);
        }
        return AjaxResult::success();
    }

    // 清除指定缓存键
    public function clearCacheKey(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $cacheKey = $request->input('cacheKey', '');
        $redis = Redis::connection();
        $redis->del($cacheKey);
        return AjaxResult::success();
    }

    // 清空当前Redis数据库的所有缓存
    public function clearCacheAll(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:cache:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $redis = Redis::connection();
        $redis->flushdb();
        return AjaxResult::success();
    }

    /**
     * 使用SCAN迭代器安全获取匹配pattern的键（替代阻塞的KEYS命令）
     * SCAN是O(N)但非阻塞，每次只返回一小批结果，适合生产环境
     */
    private function scanKeys(string $pattern): array
    {
        $redis = Redis::connection();
        $keys = [];
        $iterator = null;
        do {
            // rawCommand 调用 SCAN，返回 [iterator, keys[]]
            $result = $redis->rawCommand('SCAN', $iterator, 'MATCH', $pattern, 'COUNT', 1000);
            if ($result === false) {
                break;
            }
            $iterator = $result[0];
            if (!empty($result[1])) {
                foreach ($result[1] as $key) {
                    $keys[] = $key;
                }
            }
        } while ($iterator !== 0 && $iterator !== '0');
        return $keys;
    }
}
