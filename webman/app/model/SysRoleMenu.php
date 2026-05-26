<?php

namespace app\model;

use support\Model;

/**
 * 角色-菜单关联中间表模型，用于角色菜单权限的多对多关系
 */
class SysRoleMenu extends Model
{
    protected $table = 'sys_role_menu';
    public $timestamps = false;
    public $incrementing = false;
    protected $primaryKey = null;

    protected $fillable = ['role_id', 'menu_id'];
}
