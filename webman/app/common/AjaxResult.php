<?php

namespace app\common;

/**
 * 统一API响应封装
 *
 * 提供标准化的接口响应格式，支持成功、失败、警告等响应类型，
 * 自动将数据键名从蛇形命名(snake_case)转换为驼峰命名(camelCase)
 */
class AjaxResult
{
    // 返回成功响应，支持传入数据对象或成功消息
    public static function success($msg = '操作成功', $data = null)
    {
        if (is_array($msg) || is_object($msg)) {
            $data = $msg;
            $msg = '操作成功';
        }

        $result = ['code' => 200, 'msg' => $msg];
        if ($data !== null) {
            if (is_array($data)) {
                $data = self::convertToCamelCase($data);
                if (self::isAssociative($data)) {
                    $result = array_merge($result, $data);
                } else {
                    $result['data'] = $data;
                }
            } elseif (is_object($data)) {
                $result['data'] = self::convertToCamelCase($data->toArray());
            } else {
                $result['data'] = $data;
            }
        }
        return json($result);
    }

    // 返回失败响应，可自定义错误消息和状态码
    public static function error($msg = '操作失败', $code = 500)
    {
        return json(['code' => $code, 'msg' => $msg]);
    }

    // 返回警告响应（状态码601），用于业务校验不通过等场景
    public static function warn($msg = '')
    {
        return json(['code' => 601, 'msg' => $msg]);
    }

    // 返回自定义状态码和消息的响应，支持携带数据
    public static function result($code, $msg, $data = null)
    {
        $result = ['code' => $code, 'msg' => $msg];
        if ($data !== null) {
            if (is_array($data)) {
                $data = self::convertToCamelCase($data);
                if (self::isAssociative($data)) {
                    $result = array_merge($result, $data);
                } else {
                    $result['data'] = $data;
                }
            } elseif (is_object($data)) {
                $result['data'] = self::convertToCamelCase($data->toArray());
            } else {
                $result['data'] = $data;
            }
        }
        return json($result);
    }

    // 根据影响行数判断返回成功或失败（rows>0返回成功，否则返回失败）
    public static function toAjax($rows)
    {
        return $rows > 0 ? self::success() : self::error();
    }

    // 判断数组是否为关联数组（键名非连续数字索引）
    private static function isAssociative(array $arr)
    {
        if (empty($arr)) {
            return false;
        }
        return array_keys($arr) !== range(0, count($arr) - 1);
    }

    // 递归将数据键名从蛇形命名转换为驼峰命名，支持数组、对象和Collection
    private static function convertToCamelCase($data)
    {
        if ($data === null) {
            return null;
        }

        if ($data instanceof \Illuminate\Support\Collection) {
            return $data->map(function ($item) {
                return self::convertToCamelCase($item);
            })->toArray();
        }

        if (is_object($data)) {
            $data = method_exists($data, 'toArray') ? $data->toArray() : (array) $data;
        }

        if (!is_array($data)) {
            return $data;
        }

        $result = [];
        foreach ($data as $key => $value) {
            $newKey = is_string($key) ? self::toCamelCase($key) : $key;
            if (is_array($value) || is_object($value)) {
                $result[$newKey] = self::convertToCamelCase($value);
            } else {
                $result[$newKey] = $value;
            }
        }
        return $result;
    }

    // 将单个蛇形命名键名转换为驼峰命名
    private static function toCamelCase($key)
    {
        return lcfirst(str_replace('_', '', ucwords($key, '_')));
    }
}
