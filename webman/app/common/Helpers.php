<?php

namespace app\common;

/**
 * 通用辅助函数集合
 *
 * 提供命名风格转换等通用工具方法，主要用于数据输出时的键名格式化
 */
class Helpers
{
    // 将单个蛇形命名键名转换为驼峰命名
    public static function toCamelCase($key)
    {
        return lcfirst(str_replace('_', '', ucwords($key, '_')));
    }

    // 递归将数组中所有键名从蛇形命名转换为驼峰命名
    public static function arrayKeysToCamelCase($array)
    {
        $result = [];
        foreach ($array as $key => $value) {
            $newKey = self::toCamelCase($key);
            if (is_array($value)) {
                $result[$newKey] = self::arrayKeysToCamelCase($value);
            } else {
                $result[$newKey] = $value;
            }
        }
        return $result;
    }

    // 将用户数据（含关联的部门、角色、岗位）的键名统一转换为驼峰命名
    public static function userToCamelCase($userData)
    {
        $user = self::arrayKeysToCamelCase($userData);
        
        if (isset($user['dept']) && is_array($user['dept'])) {
            $user['dept'] = self::arrayKeysToCamelCase($user['dept']);
        }
        
        if (isset($user['roles']) && is_array($user['roles'])) {
            $user['roles'] = array_map(function ($role) {
                $r = self::arrayKeysToCamelCase($role);
                if (isset($r['pivot'])) {
                    $r['pivot'] = self::arrayKeysToCamelCase($r['pivot']);
                }
                return $r;
            }, $user['roles']);
        }
        
        if (isset($user['posts']) && is_array($user['posts'])) {
            $user['posts'] = array_map(function ($post) {
                $p = self::arrayKeysToCamelCase($post);
                if (isset($p['pivot'])) {
                    $p['pivot'] = self::arrayKeysToCamelCase($p['pivot']);
                }
                return $p;
            }, $user['posts']);
        }
        
        return $user;
    }
}
