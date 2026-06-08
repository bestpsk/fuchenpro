<?php

namespace app\model;

use support\Model;

/**
 * 出库明细模型，记录出库单中每个产品的数量、售价及金额
 */
class BizStockOutItem extends Model
{
    protected $table = 'biz_stock_out_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_out_id', 'product_id', 'product_name', 'plan_item_id', 'supplier_id', 'supplier_name',
        'spec', 'unit', 'unit_type', 'pack_qty',
        'original_quantity', 'quantity', 'sale_price', 'discount_price', 'amount', 'remark'
    ];

    // 关联所属出库单
    public function stockOut()
    {
        return $this->belongsTo(BizStockOut::class, 'stock_out_id', 'stock_out_id');
    }

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
