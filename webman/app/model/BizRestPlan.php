<?php

namespace app\model;

use support\Model;

/**
 * 休息日方案模型
 */
class BizRestPlan extends Model
{
    protected $table = 'biz_rest_plan';
    protected $primaryKey = 'plan_id';
    public $timestamps = false;

    protected $fillable = [
        'plan_name', 'config_type',
        'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
        'effective_date', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    /**
     * 关联员工
     */
    public function employees()
    {
        return $this->hasMany(BizRestPlanEmployee::class, 'plan_id', 'plan_id');
    }

    /**
     * 关联日期（按日期模式）
     */
    public function dates()
    {
        return $this->hasMany(BizRestPlanDate::class, 'plan_id', 'plan_id');
    }
}
