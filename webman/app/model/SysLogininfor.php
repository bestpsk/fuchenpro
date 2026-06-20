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
        'user_name', 'ipaddr', 'login_location', 'browser', 'os', 'status', 'msg', 'login_source', 'login_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'user_name' => ['name' => '用户名称', 'sort' => 1],
            'ipaddr' => ['name' => '登录地址', 'sort' => 2],
            'login_location' => ['name' => '登录地点', 'sort' => 3],
            'browser' => ['name' => '浏览器', 'sort' => 4],
            'os' => ['name' => '操作系统', 'sort' => 5],
            'status' => ['name' => '登录状态', 'readConverterExp' => '0=成功,1=失败', 'sort' => 6],
            'msg' => ['name' => '描述', 'sort' => 7],
            'login_source' => ['name' => '登录来源', 'readConverterExp' => 'web=Web端,app=App端', 'sort' => 8],
            'login_time' => ['name' => '访问时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 9],
        ];
    }
}
