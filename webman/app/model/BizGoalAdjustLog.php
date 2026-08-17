<?php

namespace app\model;

use support\Model;

/**
 * 目标调整日志模型，记录每次目标值变更
 */
class BizGoalAdjustLog extends Model
{
    protected $table = 'biz_goal_adjust_log';
    protected $primaryKey = 'log_id';
    public $timestamps = false;

    protected $fillable = [
        'goal_id', 'old_value', 'new_value', 'reason', 'adjust_by', 'adjust_time'
    ];

    public function goal()
    {
        return $this->belongsTo(BizGoal::class, 'goal_id', 'goal_id');
    }
}
