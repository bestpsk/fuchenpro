<?php

namespace app\model;

use support\Model;

/**
 * 数据库备份记录模型，存储备份文件信息、执行状态及COS存储路径
 */
class SysDbBackup extends Model
{
    protected $table = 'sys_db_backup';
    protected $primaryKey = 'backup_id';
    public $timestamps = false;

    protected $fillable = [
        'file_name', 'file_size', 'cos_path', 'cos_url',
        'backup_type', 'status', 'duration', 'error_message', 'create_time'
    ];
}
