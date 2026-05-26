<?php

namespace app\model;

use support\Model;

/**
 * 角色模型，存储角色名称、权限标识、数据范围及菜单/部门关联
 */
class SysRole extends Model
{
    protected $table = 'sys_role';
    protected $primaryKey = 'role_id';
    public $timestamps = false;

    protected $fillable = [
        'role_name', 'role_key', 'role_sort', 'data_scope', 'menu_check_strictly',
        'dept_check_strictly', 'status', 'del_flag', 'create_by', 'create_time',
        'update_by', 'update_time', 'remark'
    ];

    // 多对多关联：角色拥有的菜单权限
    public function menus()
    {
        return $this->belongsToMany(SysMenu::class, SysRoleMenu::class, 'role_id', 'menu_id', 'role_id', 'menu_id');
    }

    // 多对多关联：角色数据范围关联的部门
    public function depts()
    {
        return $this->belongsToMany(SysDept::class, SysRoleDept::class, 'role_id', 'dept_id', 'role_id', 'dept_id');
    }

    // 多对多关联：角色下的用户列表
    public function users()
    {
        return $this->belongsToMany(SysUser::class, SysUserRole::class, 'role_id', 'user_id', 'role_id', 'user_id');
    }

    // 判断当前角色是否为超级管理员（role_id=1）
    public function isAdmin()
    {
        return $this->role_id === 1;
    }
}
