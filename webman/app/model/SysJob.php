<?php

namespace app\model;

use support\Model;

/**
 * 定时任务模型，存储任务名称、Cron表达式、调用目标及执行策略
 */
class SysJob extends Model
{
    protected $table = 'sys_job';
    protected $primaryKey = 'job_id';
    public $timestamps = false;

    protected $fillable = [
        'job_name', 'job_group', 'invoke_target', 'cron_expression', 'misfire_policy',
        'concurrent', 'status', 'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];

    public static function getExcelFields(): array
    {
        return [
            'job_id' => ['name' => '任务编号', 'sort' => 1],
            'job_name' => ['name' => '任务名称', 'sort' => 2],
            'job_group' => ['name' => '任务组名', 'sort' => 3],
            'invoke_target' => ['name' => '调用目标字符串', 'sort' => 4],
            'cron_expression' => ['name' => 'cron执行表达式', 'sort' => 5],
            'misfire_policy' => ['name' => '执行策略', 'readConverterExp' => '1=立即执行,2=执行一次,3=放弃执行', 'sort' => 6],
            'concurrent' => ['name' => '是否并发', 'readConverterExp' => '0=允许,1=禁止', 'sort' => 7],
            'status' => ['name' => '状态', 'readConverterExp' => '0=正常,1=暂停', 'sort' => 8],
            'create_by' => ['name' => '创建者', 'sort' => 9],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 10],
        ];
    }
}
