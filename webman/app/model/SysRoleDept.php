<?php

namespace app\model;

use support\Model;

/**
 * 角色-部门关联中间表模型，用于角色数据范围的多对多关系
 */
class SysRoleDept extends Model
{
    protected $table = 'sys_role_dept';
    public $timestamps = false;
    public $incrementing = false;
    protected $primaryKey = null;

    protected $fillable = ['role_id', 'dept_id'];
}
