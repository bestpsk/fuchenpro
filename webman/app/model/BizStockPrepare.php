<?php

namespace app\model;

use support\Model;

class BizStockPrepare extends Model
{
    protected $table = 'biz_stock_prepare';
    protected $primaryKey = 'prepare_id';
    public $timestamps = false;

    protected $fillable = [
        'prepare_id', 'prepare_no', 'order_id', 'order_no', 'customer_id', 'customer_name',
        'enterprise_id', 'enterprise_name', 'store_id', 'store_name',
        'total_quantity', 'total_amount', 'shipped_quantity', 'shipped_amount', 'remaining_quantity', 'remaining_amount',
        'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public function items()
    {
        return $this->hasMany(BizStockPrepareItem::class, 'prepare_id', 'prepare_id');
    }

    public function orders()
    {
        return $this->hasMany(BizStockPrepareOrder::class, 'prepare_id', 'prepare_id');
    }
}
