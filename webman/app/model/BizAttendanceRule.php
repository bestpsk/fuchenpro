<?php

namespace app\model;

use support\Model;

/**
 * 考勤规则模型，定义上下班时间、迟到阈值、工作地点坐标及允许距离
 */
class BizAttendanceRule extends Model
{
    protected $table = 'biz_attendance_rule';
    protected $primaryKey = 'rule_id';
    public $timestamps = false;

    protected $fillable = [
        'rule_name', 'work_start_time', 'work_end_time',
        'late_threshold', 'early_leave_threshold',
        'work_latitude', 'work_longitude', 'work_address', 'allowed_distance',
        'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
