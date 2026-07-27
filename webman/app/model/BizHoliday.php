<?php

namespace app\model;

use support\Model;

/**
 * 公共假期日历模型
 */
class BizHoliday extends Model
{
    protected $table = 'biz_holiday';
    protected $primaryKey = 'holiday_id';
    public $timestamps = false;

    protected $fillable = [
        'holiday_name', 'start_date', 'end_date',
        'leave_type_id', 'year', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    /**
     * 关联休假类型
     */
    public function leaveType()
    {
        return $this->belongsTo(BizLeaveType::class, 'leave_type_id', 'type_id');
    }
}
