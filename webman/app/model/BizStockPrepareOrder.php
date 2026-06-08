<?php

namespace app\model;

use support\Model;

class BizStockPrepareOrder extends Model
{
    protected $table = 'biz_stock_prepare_order';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'id', 'prepare_id', 'order_id', 'order_no', 'customer_id', 'customer_name', 'store_id', 'store_name'
    ];
}
