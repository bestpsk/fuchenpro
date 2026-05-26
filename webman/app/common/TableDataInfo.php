<?php

namespace app\common;

/**
 * 分页查询结果封装
 *
 * 将分页数据统一封装为{total, rows, code, msg}格式，
 * 自动将数据键名从蛇形命名转换为驼峰命名
 */
class TableDataInfo
{
    // 构建分页查询响应，包含总记录数、数据列表、状态码和消息
    public static function result($list, $total = null, $code = 200, $msg = '查询成功')
    {
        if ($total === null) {
            $total = is_array($list) ? count($list) : $list->count();
        }

        $list = self::convertToCamelCase($list);

        return json([
            'total' => $total,
            'rows' => $list,
            'code' => $code,
            'msg' => $msg,
        ]);
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
