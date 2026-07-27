<?php

namespace app\model;

use support\Model;

/**
 * 休假类型配置模型
 */
class BizLeaveType extends Model
{
    protected $table = 'biz_leave_type';
    protected $primaryKey = 'type_id';
    public $timestamps = false;

    protected $fillable = [
        'type_name', 'type_code', 'need_approval', 'is_public',
        'color', 'sort', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
