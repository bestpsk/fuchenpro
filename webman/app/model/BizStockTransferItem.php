<?php

namespace app\model;

use support\Model;

class BizStockTransferItem extends Model
{
    protected $table = 'biz_stock_transfer_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'item_id', 'transfer_id', 'product_id', 'product_name',
        'spec', 'unit', 'pack_qty', 'unit_type', 'original_quantity', 'quantity', 'remark'
    ];
}
