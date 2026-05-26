<?php

namespace app\model;

use support\Model;

/**
 * 通知公告模型，存储公告标题、类型及富文本内容
 */
class SysNotice extends Model
{
    protected $table = 'sys_notice';
    protected $primaryKey = 'notice_id';
    public $timestamps = false;

    protected $fillable = [
        'notice_title', 'notice_type', 'notice_content', 'status', 'create_by',
        'create_time', 'update_by', 'update_time', 'remark'
    ];

    protected $casts = [
        'notice_content' => 'string',
    ];

    // 关联已读该公告的用户记录
    public function readUsers()
    {
        return $this->hasMany(SysNoticeRead::class, 'notice_id', 'notice_id');
    }
}
