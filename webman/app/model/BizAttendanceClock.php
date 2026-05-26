<?php

namespace app\model;

use support\Model;

/**
 * 考勤打卡记录模型，记录员工每次打卡的时间、类型、位置及照片
 */
class BizAttendanceClock extends Model
{
    protected $table = 'biz_attendance_clock';
    protected $primaryKey = 'clock_id';
    public $timestamps = false;

    protected $fillable = [
        'record_id',
        'user_id',
        'user_name',
        'clock_time',
        'clock_type',
        'work_type',
        'latitude',
        'longitude',
        'address',
        'photo',
        'outside_reason',
        'remark',
    ];

    protected $casts = [
        'clock_time' => 'datetime',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    // 关联所属考勤日记录
    public function record()
    {
        return $this->belongsTo(BizAttendanceRecord::class, 'record_id', 'record_id');
    }
}
