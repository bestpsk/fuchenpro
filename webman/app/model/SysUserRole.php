<?php

namespace app\model;

use support\Model;

/**
 * 用户-角色关联中间表模型，用于用户角色的多对多关系
 */
class SysUserRole extends Model
{
    protected $table = 'sys_user_role';
    public $timestamps = false;
    public $incrementing = false;
    protected $primaryKey = null;

    protected $fillable = ['user_id', 'role_id'];
}
