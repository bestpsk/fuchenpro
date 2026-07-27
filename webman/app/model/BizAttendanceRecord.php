<?php

namespace app\model;

use support\Model;

/**
 * 考勤日记录模型，存储员工每日考勤汇总（上下班时间、状态、打卡次数等）
 */
class BizAttendanceRecord extends Model
{
    protected $table = 'biz_attendance_record';
    protected $primaryKey = 'record_id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'user_name', 'attendance_date',
        'clock_in_time', 'clock_out_time',
        'clock_in_latitude', 'clock_in_longitude', 'clock_in_address', 'clock_in_photo',
        'clock_out_latitude', 'clock_out_longitude', 'clock_out_address', 'clock_out_photo',
        'attendance_status', 'clock_type', 'outside_reason', 'rule_id', 'remark',
        'clock_count',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'user_name' => ['name' => '员工姓名', 'sort' => 1],
            'attendance_date' => ['name' => '考勤日期', 'dateFormat' => 'Y-m-d', 'sort' => 2],
            'clock_in_time' => ['name' => '上班时间', 'dateFormat' => 'Y-m-d H:i', 'sort' => 3],
            'clock_out_time' => ['name' => '下班时间', 'dateFormat' => 'Y-m-d H:i', 'sort' => 4],
            'attendance_status' => ['name' => '考勤状态', 'dictType' => 'biz_attendance_status', 'sort' => 5],
            'clock_type' => ['name' => '打卡类型', 'readConverterExp' => '0=坐班,1=外勤', 'sort' => 6],
            'clock_in_address' => ['name' => '上班打卡地址', 'sort' => 7],
            'clock_out_address' => ['name' => '下班打卡地址', 'sort' => 8],
            'outside_reason' => ['name' => '外勤事由', 'sort' => 9],
            'remark' => ['name' => '备注', 'sort' => 10],
        ];
    }
}
