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
        
        $commandStats = [];
        foreach ($rawInfo as $key => $value) {
            if (str_starts_with($key, 'cmdstat_')) {
                $cmd = str_replace('cmdstat_', '', $key);
                if (is_string($value)) {
                    $parts = explode(',', $value);
                    $calls = 0;
                    foreach ($parts as $part) {
                        if (str_starts_with(trim($part), 'calls=')) {
                            $calls = intval(str_replace('calls=', '', trim($part)));
                        }
                    }
                    $commandStats[] = ['name' => $cmd, 'value' => $calls];
                } elseif (is_array($value) && isset($value['calls'])) {
                    $commandStats[] = ['name' => $cmd, 'value' => intval($value['calls'])];
                }
            }
            
            if (is_array($value)) {
                foreach ($value as $subKey => $subValue) {
                    if (str_starts_with($subKey, 'cmdstat_')) {
                        $cmd = str_replace('cmdstat_', '', $subKey);
                        if (is_string($subValue)) {
                            $parts = explode(',', $subValue);
                            $calls = 0;
                            foreach ($parts as $part) {
                                if (str_starts_with(trim($part), 'calls=')) {
                                    $calls = intval(str_replace('calls=', '', trim($part)));
                                }
                            }
                            $commandStats[] = ['name' => $cmd, 'value' => $calls];
                        } elseif (is_array($subValue) && isset($subValue['calls'])) {
                            $commandStats[] = ['name' => $cmd, 'value' => intval($subValue['calls'])];
                        }
                    }
                }
            }
        }
        
        return AjaxResult::success('', [
            'data' => [
                'info' => $info,
                'dbSize' => $dbSize,
                'commandStats' => $commandStats,
            ]
        ]);
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
        $redis = Redis::connection();
        $keys = $redis->keys('*');
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
        $redis = Redis::connection();
        $keys = $redis->keys($cacheName . '*');
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
        if ($value === null) {
            $value = $redis->get($cacheKey);
        }
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
        $redis = Redis::connection();
        $keys = $redis->keys($cacheName . '*');
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
}
