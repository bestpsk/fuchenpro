<?php

namespace app\model;

use support\Model;

/**
 * 部门模型，存储部门树形结构信息及负责人
 */
class SysDept extends Model
{
    protected $table = 'sys_dept';
    protected $primaryKey = 'dept_id';
    public $timestamps = false;

    protected $fillable = [
        'parent_id', 'ancestors', 'dept_name', 'order_num', 'leader', 'phone',
        'email', 'status', 'del_flag', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联子部门列表
    public function children()
    {
        return $this->hasMany(SysDept::class, 'parent_id', 'dept_id');
    }

    // 关联父级部门
    public function parent()
    {
        return $this->belongsTo(SysDept::class, 'parent_id', 'dept_id');
    }
}
