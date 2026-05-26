<?php

namespace app\common;

use app\model\GenTable;
use app\model\GenTableColumn;

/**
 * 代码生成工具类
 *
 * 提供代码生成器所需的表信息初始化、列字段智能推断、
 * 命名风格转换（驼峰/蛇形）等辅助方法
 */
class GenUtils
{
    // 初始化代码生成表信息，自动填充类名、模块名、业务名和功能名称
    public static function initTable(GenTable $genTable, string $operName = ''): void
    {
        $genTable->class_name = self::convertClassName($genTable->table_name);
        $genTable->package_name = 'com.ruoyi.project.system';
        $genTable->module_name = self::getModuleName($genTable->package_name);
        $genTable->business_name = self::getBusinessName($genTable->table_name);
        $genTable->function_name = self::replaceText($genTable->table_comment ?: '');
        $genTable->function_author = 'ruoyi';
    }

    // 根据数据库列类型智能推断Java字段类型、HTML控件类型和查询方式
    public static function initColumnField(GenTableColumn $column, GenTable $table): void
    {
        $dataType = self::getDbType($column->column_type);
        $columnName = $column->column_name;

        $column->table_id = $table->table_id;
        $column->java_field = self::toCamelCase($columnName);
        $column->java_type = GenConstants::TYPE_STRING;
        $column->query_type = GenConstants::QUERY_EQ;

        if (GenConstants::arraysContains(GenConstants::COLUMNTYPE_STR, $dataType) || GenConstants::arraysContains(GenConstants::COLUMNTYPE_TEXT, $dataType)) {
            $columnLength = self::getColumnLength($column->column_type);
            $htmlType = ($columnLength >= 500 || GenConstants::arraysContains(GenConstants::COLUMNTYPE_TEXT, $dataType))
                ? GenConstants::HTML_TEXTAREA : GenConstants::HTML_INPUT;
            $column->html_type = $htmlType;
        } elseif (GenConstants::arraysContains(GenConstants::COLUMNTYPE_TIME, $dataType)) {
            $column->java_type = GenConstants::TYPE_DATE;
            $column->html_type = GenConstants::HTML_DATETIME;
        } elseif (GenConstants::arraysContains(GenConstants::COLUMNTYPE_NUMBER, $dataType)) {
            $column->html_type = GenConstants::HTML_INPUT;
            $parenStr = self::getParenContent($column->column_type);
            if ($parenStr !== null) {
                $str = explode(',', $parenStr);
                if (count($str) == 2 && intval($str[1]) > 0) {
                    $column->java_type = GenConstants::TYPE_BIGDECIMAL;
                } elseif (count($str) == 1 && intval($str[0]) <= 10) {
                    $column->java_type = GenConstants::TYPE_INTEGER;
                } else {
                    $column->java_type = GenConstants::TYPE_LONG;
                }
            } else {
                $column->java_type = GenConstants::TYPE_LONG;
            }
        }

        $column->is_insert = GenConstants::REQUIRE;

        if (!GenConstants::arraysContains(GenConstants::COLUMNNAME_NOT_EDIT, $columnName) && !$column->is_pk) {
            $column->is_edit = GenConstants::REQUIRE;
        }
        if (!GenConstants::arraysContains(GenConstants::COLUMNNAME_NOT_LIST, $columnName) && !$column->is_pk) {
            $column->is_list = GenConstants::REQUIRE;
        }
        if (!GenConstants::arraysContains(GenConstants::COLUMNNAME_NOT_QUERY, $columnName) && !$column->is_pk) {
            $column->is_query = GenConstants::REQUIRE;
        }

        if (self::endsWithIgnoreCase($columnName, 'name')) {
            $column->query_type = GenConstants::QUERY_LIKE;
        }
        if (self::endsWithIgnoreCase($columnName, 'status')) {
            $column->html_type = GenConstants::HTML_RADIO;
        } elseif (self::endsWithIgnoreCase($columnName, 'type') || self::endsWithIgnoreCase($columnName, 'sex')) {
            $column->html_type = GenConstants::HTML_SELECT;
        } elseif (self::endsWithIgnoreCase($columnName, 'image')) {
            $column->html_type = GenConstants::HTML_IMAGE_UPLOAD;
        } elseif (self::endsWithIgnoreCase($columnName, 'file')) {
            $column->html_type = GenConstants::HTML_FILE_UPLOAD;
        } elseif (self::endsWithIgnoreCase($columnName, 'content')) {
            $column->html_type = GenConstants::HTML_EDITOR;
        }
    }

    // 从包名中提取最后一段作为模块名
    public static function getModuleName(string $packageName): string
    {
        $lastIndex = strrpos($packageName, '.');
        return $lastIndex !== false ? substr($packageName, $lastIndex + 1) : $packageName;
    }

    // 从表名中提取最后一段（下划线分隔）作为业务名
    public static function getBusinessName(string $tableName): string
    {
        $lastIndex = strrpos($tableName, '_');
        return $lastIndex !== false ? substr($tableName, $lastIndex + 1) : $tableName;
    }

    // 将表名转换为帕斯卡命名类名（首字母大写的驼峰）
    public static function convertClassName(string $tableName): string
    {
        return self::convertToCamelCase($tableName);
    }

    // 去除表注释中的"表"和"若依"等冗余文字
    public static function replaceText(string $text): string
    {
        return preg_replace('/(?:表|若依)/', '', $text);
    }

    // 从列类型定义中提取数据库类型（去掉括号内的长度和精度，如varchar(255) → varchar）
    public static function getDbType(string $columnType): string
    {
        $pos = strpos($columnType, '(');
        return $pos > 0 ? substr($columnType, 0, $pos) : $columnType;
    }

    // 从列类型定义中提取字段长度（如varchar(255) → 255）
    public static function getColumnLength(string $columnType): int
    {
        $parenStr = self::getParenContent($columnType);
        if ($parenStr !== null && is_numeric($parenStr)) {
            return intval($parenStr);
        }
        return 0;
    }

    // 提取列类型定义中括号内的内容（如decimal(10,2) → "10,2"）
    private static function getParenContent(string $columnType): ?string
    {
        if (preg_match('/\(([^)]+)\)/', $columnType, $matches)) {
            return $matches[1];
        }
        return null;
    }

    // 将蛇形命名转换为小驼峰命名（首字母小写）
    public static function toCamelCase(string $str): string
    {
        $parts = explode('_', $str);
        $result = array_shift($parts);
        foreach ($parts as $part) {
            $result .= ucfirst($part);
        }
        return $result;
    }

    // 将蛇形命名转换为帕斯卡命名（首字母大写的驼峰）
    public static function convertToCamelCase(string $str): string
    {
        $parts = explode('_', $str);
        $result = '';
        foreach ($parts as $part) {
            $result .= ucfirst($part);
        }
        return $result;
    }

    // 将驼峰命名转换为蛇形命名
    public static function toSnakeCase(string $str): string
    {
        return strtolower(preg_replace('/([a-z])([A-Z])/', '$1_$2', $str));
    }

    // 忽略大小写判断字符串是否以指定后缀结尾
    public static function endsWithIgnoreCase(string $str, string $suffix): bool
    {
        return str_ends_with(strtolower($str), strtolower($suffix));
    }

    // 判断字段是否为基础实体公共字段（create_by、create_time等审计字段）
    public static function isSuperColumn(string $javaField): bool
    {
        return in_array($javaField, GenConstants::BASE_ENTITY_FIELDS);
    }
}
