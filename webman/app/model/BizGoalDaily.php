<?php

namespace app\model;

use support\Model;

/**
 * 目标日明细模型，由月度目标+排班数据自动生成
 */
class BizGoalDaily extends Model
{
    protected $table = 'biz_goal_daily';
    protected $primaryKey = 'daily_id';
    public $timestamps = false;

    protected $fillable = [
        'goal_id', 'target_date', 'target_value', 'is_rest_day', 'remark'
    ];

    public function goal()
    {
        return $this->belongsTo(BizGoal::class, 'goal_id', 'goal_id');
    }
}
