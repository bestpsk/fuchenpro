<?php

namespace app\model;

use support\Model;

class BizStockPrepareItem extends Model
{
    protected $table = 'biz_stock_prepare_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'item_id', 'prepare_id', 'card_item_id', 'plan_item_id', 'product_id', 'product_name', 'unit', 'spec',
        'unit_type', 'pack_qty', 'sale_price', 'quantity', 'amount',
        'shipped_quantity', 'shipped_amount', 'remaining_quantity', 'remaining_amount', 'remark'
    ];

    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
