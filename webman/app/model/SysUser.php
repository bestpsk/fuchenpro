<?php

namespace app\model;

use support\Model;

/**
 * 系统用户模型，存储用户登录信息、部门关联及角色/岗位多对多关系
 */
class SysUser extends Model
{
    protected $table = 'sys_user';
    protected $primaryKey = 'user_id';
    public $timestamps = false;

    protected $fillable = [
        'dept_id', 'user_name', 'nick_name', 'user_type', 'email', 'phonenumber',
        'sex', 'avatar', 'password', 'status', 'del_flag',
        'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];

    // 定义用户数据的Excel导入导出字段映射配置
    public static function getExcelFields(): array
    {
        return [
            'user_id' => ['name' => '用户序号', 'type' => 'export', 'cellType' => 'numeric', 'prompt' => '用户编号', 'sort' => 1],
            'dept_id' => ['name' => '部门编号', 'type' => 'import', 'sort' => 2],
            'user_name' => ['name' => '登录名称', 'sort' => 3],
            'nick_name' => ['name' => '用户姓名', 'sort' => 4],
            'email' => ['name' => '用户邮箱', 'sort' => 5],
            'phonenumber' => ['name' => '手机号码', 'cellType' => 'text', 'sort' => 6],
            'sex' => ['name' => '用户性别', 'readConverterExp' => '0=男,1=女,2=未知', 'sort' => 7],
            'status' => ['name' => '账号状态', 'readConverterExp' => '0=正常,1=停用', 'sort' => 8],
            'login_ip' => ['name' => '最后登录IP', 'type' => 'export', 'sort' => 9],
            'login_date' => ['name' => '最后登录时间', 'width' => 30, 'dateFormat' => 'yyyy-mm-dd hh:mm:ss', 'type' => 'export', 'sort' => 10],
        ];
    }

    // 关联所属部门
    public function dept()
    {
        return $this->belongsTo(SysDept::class, 'dept_id', 'dept_id');
    }

    // 多对多关联：用户拥有的角色列表
    public function roles()
    {
        return $this->belongsToMany(SysRole::class, SysUserRole::class, 'user_id', 'role_id', 'user_id', 'role_id');
    }

    // 多对多关联：用户拥有的岗位列表
    public function posts()
    {
        return $this->belongsToMany(SysPost::class, SysUserPost::class, 'user_id', 'post_id', 'user_id', 'post_id');
    }

    // 判断当前用户是否为超级管理员（user_id=1）
    public function isAdmin()
    {
        return $this->user_id == 1;
    }

    // 一对一关联：用户的详细信息
    public function detail()
    {
        return $this->hasOne(SysUserDetail::class, 'user_id', 'user_id');
    }

    // 一对多关联：用户的薪资配置列表
    public function salaries()
    {
        return $this->hasMany(HrUserSalary::class, 'user_id', 'user_id');
    }
}
