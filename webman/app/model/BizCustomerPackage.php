<?php

namespace app\model;

use support\Model;

/**
 * 客户套餐模型，记录客户购买的套餐及金额、欠款、到期日等信息
 */
class BizCustomerPackage extends Model
{
    protected $table = 'biz_customer_package';
    protected $primaryKey = 'package_id';
    public $timestamps = false;

    protected $fillable = [
        'package_no', 'customer_id', 'customer_name', 'order_id', 'order_no',
        'enterprise_id', 'store_id', 'package_name', 'total_amount',
        'paid_amount', 'owed_amount',
        'status', 'expire_date', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联套餐下的所有项目明细
    public function items()
    {
        return $this->hasMany(BizPackageItem::class, 'package_id', 'package_id');
    }
}
