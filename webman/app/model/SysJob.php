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
}
