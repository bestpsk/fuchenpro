<?php

namespace app\model;

use support\Model;

/**
 * 统一休息日模型
 * 合并了 biz_employee_rest_date + biz_rest_plan_date + biz_rest_plan_employee 的功能
 * 三种来源：custom(自定义) / plan(方案按日期) / leave(请假通过)
 */
class BizRestDay extends Model
{
    protected $table = 'biz_rest_day';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'rest_date', 'source_type', 'source_id',
        'type_id', 'type_name', 'color', 'create_time'
    ];

    /**
     * 休假类型关联
     */
    public function leaveType()
    {
        return $this->belongsTo(BizLeaveType::class, 'type_id', 'type_id');
    }
}
