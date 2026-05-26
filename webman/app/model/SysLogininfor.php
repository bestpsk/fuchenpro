<?php

namespace app\model;

use support\Model;

/**
 * 登录日志模型，记录用户登录的IP、浏览器、操作系统及登录状态
 */
class SysLogininfor extends Model
{
    protected $table = 'sys_logininfor';
    protected $primaryKey = 'info_id';
    public $timestamps = false;

    protected $fillable = [
        'user_name', 'ipaddr', 'login_location', 'browser', 'os', 'status', 'msg', 'login_time'
    ];
}
