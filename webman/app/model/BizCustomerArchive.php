<?php

namespace app\model;

use support\Model;

/**
 * 客户档案模型，记录客户的消费/回访等归档信息，含方案项目快照和满意度
 */
class BizCustomerArchive extends Model
{
    protected $table = 'biz_customer_archive';
    protected $primaryKey = 'archive_id';
    public $timestamps = false;

    protected $fillable = [
        'customer_id', 'customer_name', 'enterprise_id', 'enterprise_name', 'store_id', 'store_name',
        'archive_date', 'archive_type', 'source_type', 'source_id',
        'plan_items', 'amount', 'satisfaction', 'photos',
        'customer_feedback', 'operator_user_id', 'operator_user_name',
        'remark', 'create_by', 'create_time'
    ];
}
