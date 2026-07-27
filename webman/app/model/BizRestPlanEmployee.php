<?php

namespace app\model;

use support\Model;

/**
 * 休息日方案-员工关联模型
 */
class BizRestPlanEmployee extends Model
{
    protected $table = 'biz_rest_plan_employee';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'plan_id', 'user_id', 'user_name', 'dept_id', 'dept_name'
    ];

    public function plan()
    {
        return $this->belongsTo(BizRestPlan::class, 'plan_id', 'plan_id');
    }
}
