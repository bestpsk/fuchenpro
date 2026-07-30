<?php

namespace app\model;

use support\Model;

/**
 * 定时任务日志模型，记录任务执行的消息、状态及异常信息
 */
class SysJobLog extends Model
{
    protected $table = 'sys_job_log';
    protected $primaryKey = 'job_log_id';
    public $timestamps = false;

    protected $fillable = [
        'job_name', 'job_group', 'invoke_target', 'job_message', 'status',
        'exception_info', 'start_time', 'end_time', 'create_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'job_log_id' => ['name' => '日志编号', 'sort' => 1],
            'job_name' => ['name' => '任务名称', 'sort' => 2],
            'job_group' => ['name' => '任务组名', 'sort' => 3],
            'invoke_target' => ['name' => '调用目标字符串', 'sort' => 4],
            'job_message' => ['name' => '日志信息', 'sort' => 5],
            'status' => ['name' => '执行状态', 'readConverterExp' => '0=成功,1=失败', 'sort' => 6],
            'exception_info' => ['name' => '异常信息', 'sort' => 7],
            'start_time' => ['name' => '开始时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 8],
            'end_time' => ['name' => '结束时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 9],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 10],
        ];
    }
}
