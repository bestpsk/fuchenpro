<?php

namespace app\model;

use support\Model;

/**
 * 休息日方案模型（仅按周模板）
 * 关联员工通过 user_ids 字段（逗号分隔）存储，不再使用 biz_rest_plan_employee 关联表
 * 按日期休息日统一存入 biz_rest_day（source='plan'）
 */
class BizRestPlan extends Model
{
    protected $table = 'biz_rest_plan';
    protected $primaryKey = 'plan_id';
    public $timestamps = false;

    protected $fillable = [
        'plan_name',
        'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
        'effective_date', 'user_ids', 'user_names', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
