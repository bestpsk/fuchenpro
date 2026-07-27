<?php

namespace app\model;

use support\Model;

/**
 * 培训学习日志模型，记录用户学习会话及有效时长
 */
class BizTrainStudyLog extends Model
{
    protected $table = 'biz_train_study_log';
    protected $primaryKey = 'log_id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'material_id', 'session_id', 'start_time', 'end_time',
        'valid_duration', 'pause_count', 'switch_count', 'status', 'create_time'
    ];
}
