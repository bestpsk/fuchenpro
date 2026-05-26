<?php

// 递归将数组的键名从驼峰转为蛇形命名，支持嵌套数组和索引数组
if (!function_exists('convert_to_snake_case')) {
    function convert_to_snake_case($data)
    {
        $result = [];
        foreach ($data as $key => $value) {
            $newKey = is_string($key) ? to_snake_case($key) : $key;
            if (is_array($value) && !empty($value)) {
                if (is_associative_array($value)) {
                    $result[$newKey] = convert_to_snake_case($value);
                } else {
                    $result[$newKey] = array_map(function ($item) {
                        return is_array($item) ? convert_to_snake_case($item) : $item;
                    }, $value);
                }
            } else {
                $result[$newKey] = $value;
            }
        }
        return $result;
    }
}

// 将驼峰命名字符串转为蛇形命名（如 userName → user_name）
if (!function_exists('to_snake_case')) {
    function to_snake_case($key)
    {
        return strtolower(preg_replace('/([a-z])([A-Z])/', '$1_$2', $key));
    }
}

// 判断数组是否为关联数组（键名不是从0开始的连续整数）
if (!function_exists('is_associative_array')) {
    function is_associative_array($arr)
    {
        if (empty($arr) || !is_array($arr)) {
            return false;
        }
        return array_keys($arr) !== range(0, count($arr) - 1);
    }
}
