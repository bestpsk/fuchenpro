<?php

namespace app\model;

use support\Model;

/**
 * 日程模型，记录员工的企业拜访日程及状态
 */
class BizSchedule extends Model
{
    protected $table = 'biz_schedule';
    protected $primaryKey = 'schedule_id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'user_name', 'enterprise_id', 'enterprise_name',
        'schedule_date', 'purpose', 'remark', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'user_name' => ['name' => '员工', 'sort' => 1],
            'post_name' => ['name' => '职位', 'type' => 'export', 'sort' => 2],
            'enterprise_name' => ['name' => '企业', 'sort' => 3],
            'schedule_date' => ['name' => '排班日期', 'dateFormat' => 'Y-m-d', 'sort' => 4],
            'purpose' => ['name' => '下店目的', 'dictType' => 'biz_schedule_purpose', 'sort' => 5],
            'status' => ['name' => '状态', 'dictType' => 'biz_schedule_status', 'sort' => 6],
            'remark' => ['name' => '备注', 'sort' => 7],
        ];
    }
}
