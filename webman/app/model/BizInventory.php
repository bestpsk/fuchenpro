<?php

namespace app\model;

use support\Model;

/**
 * 库存模型，记录产品的当前库存数量、预警数量及最近出入库时间
 */
class BizInventory extends Model
{
    protected $table = 'biz_inventory';
    protected $primaryKey = 'inventory_id';
    public $timestamps = false;

    protected $fillable = [
        'product_id', 'quantity', 'warn_qty', 'earliest_expiry',
        'last_stock_in_time', 'last_stock_out_time',
        'create_time', 'update_time'
    ];

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
