<?php

namespace app\model;

use support\Model;

/**
 * 套餐项目模型，记录套餐中每个产品的单价、次数及已用/剩余数量
 */
class BizPackageItem extends Model
{
    protected $table = 'biz_package_item';
    protected $primaryKey = 'package_item_id';
    public $timestamps = false;

    protected $fillable = [
        'package_id', 'product_name', 'unit_price', 'plan_price', 'deal_price',
        'paid_amount', 'owed_amount',
        'total_quantity', 'used_quantity', 'remaining_quantity', 'remark'
    ];
}
