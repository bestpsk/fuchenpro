<?php

namespace app\model;

use support\Model;

class BizCardItemProduct extends Model
{
    protected $table = 'biz_card_item_product';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'card_item_id', 'product_id', 'unit_type', 'pack_qty', 'quantity', 'remark'
    ];

    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
