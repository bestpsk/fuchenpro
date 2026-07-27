<?php

namespace app\model;

use support\Model;

/**
 * 休息日方案-日期模型（按日期模式用）
 */
class BizRestPlanDate extends Model
{
    protected $table = 'biz_rest_plan_date';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'plan_id', 'rest_date', 'reason'
    ];

    public function plan()
    {
        return $this->belongsTo(BizRestPlan::class, 'plan_id', 'plan_id');
    }
}
