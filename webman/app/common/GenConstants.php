<?php

namespace app\common;

/**
 * 代码生成器常量定义
 *
 * 定义代码生成功能所需的模板类型、字段类型、查询方式、
 * HTML表单控件类型、数据库列类型分类、字段排除规则等常量
 */
class GenConstants
{
    // 代码生成模板类型：crud=单表 tree=树表 sub=主子表
    const TPL_CRUD = 'crud';
    const TPL_TREE = 'tree';
    const TPL_SUB = 'sub';

    // Java字段类型映射
    const TYPE_STRING = 'String';
    const TYPE_INTEGER = 'Integer';
    const TYPE_LONG = 'Long';
    const TYPE_DOUBLE = 'Double';
    const TYPE_BIGDECIMAL = 'BigDecimal';
    const TYPE_DATE = 'Date';

    // 查询方式：EQ=等于 NE=不等于 GT=大于 GTE=大于等于 LT=小于 LTE=小于等于 LIKE=模糊 BETWEEN=范围
    const QUERY_EQ = 'EQ';
    const QUERY_NE = 'NE';
    const QUERY_GT = 'GT';
    const QUERY_GTE = 'GTE';
    const QUERY_LT = 'LT';
    const QUERY_LTE = 'LTE';
    const QUERY_LIKE = 'LIKE';
    const QUERY_BETWEEN = 'BETWEEN';

    // HTML表单控件类型
    const HTML_INPUT = 'input';               // 文本输入框
    const HTML_TEXTAREA = 'textarea';         // 文本域
    const HTML_SELECT = 'select';             // 下拉选择框
    const HTML_RADIO = 'radio';               // 单选框
    const HTML_CHECKBOX = 'checkbox';         // 复选框
    const HTML_DATETIME = 'datetime';         // 日期时间选择器
    const HTML_IMAGE_UPLOAD = 'imageUpload';  // 图片上传
    const HTML_FILE_UPLOAD = 'fileUpload';    // 文件上传
    const HTML_EDITOR = 'editor';             // 富文本编辑器

    // 必填标识
    const REQUIRE = '1';

    // 数据库列类型分类
    const COLUMNTYPE_STR = ['char', 'varchar', 'nvarchar', 'varchar2', 'tinytext'];      // 字符串类型
    const COLUMNTYPE_TEXT = ['tinytext', 'text', 'mediumtext', 'longtext'];               // 长文本类型
    const COLUMNTYPE_TIME = ['datetime', 'time', 'date', 'timestamp'];                    // 时间类型
    const COLUMNTYPE_NUMBER = ['tinyint', 'smallint', 'mediumint', 'int', 'number', 'integer', 'bigint', 'float', 'double', 'decimal']; // 数值类型

    // 字段排除规则：不需要在编辑/列表/查询中显示的字段名
    const COLUMNNAME_NOT_EDIT = ['id', 'create_by', 'create_time', 'del_flag'];           // 编辑时排除
    const COLUMNNAME_NOT_LIST = ['id', 'create_by', 'create_time', 'update_by', 'update_time', 'del_flag', 'remark']; // 列表时排除
    const COLUMNNAME_NOT_QUERY = ['id', 'create_by', 'create_time', 'update_by', 'update_time', 'del_flag', 'remark']; // 查询时排除

    // 基础实体公共字段（所有表都有的审计字段）
    const BASE_ENTITY_FIELDS = ['create_by', 'create_time', 'update_by', 'update_time', 'remark'];

    // 判断数组中是否包含指定值
    public static function arraysContains(array $arr, string $targetValue): bool
    {
        return in_array($targetValue, $arr);
    }
}
