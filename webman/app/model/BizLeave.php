<?php

namespace app\model;

use support\Model;

/**
 * 休假记录/请假单模型
 */
class BizLeave extends Model
{
    protected $table = 'biz_leave';
    protected $primaryKey = 'leave_id';
    public $timestamps = false;

    protected $fillable = [
        'leave_no', 'user_id', 'user_name', 'dept_id',
        'leave_type_id', 'start_date', 'end_date',
        'start_time_type', 'end_time_type', 'leave_days',
        'reason', 'status',
        'approver_id', 'approver_name', 'approve_time', 'approve_remark',
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
