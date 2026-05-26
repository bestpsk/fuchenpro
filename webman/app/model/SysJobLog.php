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
}
