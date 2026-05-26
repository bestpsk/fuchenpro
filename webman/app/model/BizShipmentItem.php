<?php

namespace app\model;

use support\Model;

/**
 * 发货明细模型，记录发货单中每个产品的发货数量及折扣价格
 */
class BizShipmentItem extends Model
{
    protected $table = 'biz_shipment_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'shipment_id', 'plan_item_id', 'product_id', 'product_name',
        'supplier_id', 'supplier_name', 'unit_type', 'pack_qty',
        'quantity', 'spec', 'sale_price', 'discount_price', 'amount', 'remark'
    ];

    // 关联所属发货单
    public function shipment()
    {
        return $this->belongsTo(BizShipment::class, 'shipment_id', 'shipment_id');
    }

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
