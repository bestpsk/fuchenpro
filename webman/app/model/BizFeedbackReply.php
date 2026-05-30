<?php

namespace app\model;

use support\Model;

class BizFeedbackReply extends Model
{
    protected $table = 'biz_feedback_reply';
    protected $primaryKey = 'reply_id';
    public $timestamps = false;

    protected $fillable = [
        'feedback_id', 'content', 'create_by', 'create_time'
    ];
}
