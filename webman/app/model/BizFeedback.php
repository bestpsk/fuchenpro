<?php

namespace app\model;

use support\Model;

class BizFeedback extends Model
{
    protected $table = 'biz_feedback';
    protected $primaryKey = 'feedback_id';
    public $timestamps = false;

    protected $fillable = [
        'title', 'content', 'feedback_type', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
