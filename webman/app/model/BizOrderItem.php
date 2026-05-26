<?php

namespace app\model;

use support\Model;

/**
 * 订单明细模型，存储销售订单中每个产品的数量、金额及欠款
 */
class BizOrderItem extends Model
{
    protected $table = 'biz_order_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'order_id', 'product_name', 'quantity',
        'deal_amount', 'paid_amount', 'unit_price', 'owed_amount', 'payment_method',
        'remark', 'create_time'
    ];
}
