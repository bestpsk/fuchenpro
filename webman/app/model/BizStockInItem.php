<?php

namespace app\model;

use support\Model;

/**
 * 入库明细模型，记录入库单中每个产品的数量、进价及生产/过期日期
 */
class BizStockInItem extends Model
{
    protected $table = 'biz_stock_in_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_in_id', 'warehouse_id', 'product_id', 'product_name',
        'supplier_id', 'supplier_name',
        'spec', 'unit', 'unit_type', 'pack_qty',
        'original_quantity', 'quantity', 'purchase_price', 'amount',
        'production_date', 'expiry_date', 'remark',
        'shipped_quantity'
    ];

    // 关联所属入库单
    public function stockIn()
    {
        return $this->belongsTo(BizStockIn::class, 'stock_in_id', 'stock_in_id');
    }

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
