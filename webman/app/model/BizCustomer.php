<?php

namespace app\model;

use support\Model;

/**
 * 客户模型，存储客户基本信息及所属企业、门店关联
 */
class BizCustomer extends Model
{
    protected $table = 'biz_customer';
    protected $primaryKey = 'customer_id';
    public $timestamps = false;

    protected $fillable = [
        'enterprise_id', 'enterprise_name', 'store_id', 'store_name',
        'customer_name', 'avatar', 'phone', 'wechat', 'gender', 'age', 'tag',
        'remark', 'status', 'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
