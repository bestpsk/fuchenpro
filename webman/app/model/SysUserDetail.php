<?php

namespace app\model;

use support\Model;

/**
 * 用户详情模型，存储用户的微信、身份证、入职日期及在职状态
 */
class SysUserDetail extends Model
{
    protected $table = 'sys_user_detail';
    protected $primaryKey = 'detail_id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'wechat', 'birthday', 'id_card', 'address', 'welcome_slogan',
        'hire_date', 'employment_status', 'resign_date',
        'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];

    protected $casts = [
        'birthday' => 'date',
        'hire_date' => 'date',
        'resign_date' => 'date',
        'create_time' => 'datetime',
        'update_time' => 'datetime',
    ];

    // 关联所属用户
    public function user()
    {
        return $this->belongsTo(SysUser::class, 'user_id', 'user_id');
    }
}
