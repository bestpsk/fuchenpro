<?php

namespace app\model;

use support\Model;

/**
 * 系统参数配置模型，存储系统级别的键值对配置项
 */
class SysConfig extends Model
{
    protected $table = 'sys_config';
    protected $primaryKey = 'config_id';
    public $timestamps = false;

    protected $fillable = [
        'config_name', 'config_key', 'config_value', 'config_type', 'create_by',
        'create_time', 'update_by', 'update_time', 'remark'
    ];
}
