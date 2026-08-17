<?php

namespace app\model;

use support\Model;

/**
 * 目标主表模型，记录目标归属、周期、口径及目标值
 */
class BizGoal extends Model
{
    protected $table = 'biz_goal';
    protected $primaryKey = 'goal_id';
    public $timestamps = false;

    protected $fillable = [
        'goal_name', 'owner_type', 'owner_id', 'owner_name',
        'period_type', 'period_name', 'start_date', 'end_date',
        'metric_type', 'target_value', 'unit', 'card_item_id', 'activity_name',
        'parent_goal_id', 'status', 'creator_user_id', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联日目标明细
    public function dailyGoals()
    {
        return $this->hasMany(BizGoalDaily::class, 'goal_id', 'goal_id');
    }

    // 关联调整日志
    public function adjustLogs()
    {
        return $this->hasMany(BizGoalAdjustLog::class, 'goal_id', 'goal_id');
    }

    // 关联父目标
    public function parent()
    {
        return $this->belongsTo(BizGoal::class, 'parent_goal_id', 'goal_id');
    }
}
