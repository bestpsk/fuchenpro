<?php

namespace app\model;

use support\Model;

/**
 * 通知已读记录模型，记录用户阅读公告的时间
 */
class SysNoticeRead extends Model
{
    protected $table = 'sys_notice_read';
    protected $primaryKey = 'read_id';
    public $timestamps = false;

    protected $fillable = [
        'notice_id', 'user_id', 'read_time'
    ];
}
