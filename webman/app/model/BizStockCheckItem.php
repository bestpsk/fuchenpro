<?php

namespace app\model;

use support\Model;

/**
 * 盘点明细模型，记录盘点单中每个产品的系统数量、实际数量及差异数量
 */
class BizStockCheckItem extends Model
{
    protected $table = 'biz_stock_check_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_check_id', 'product_id', 'product_name', 'spec', 'unit',
        'unit_type', 'pack_qty', 'original_quantity',
        'system_quantity', 'actual_quantity', 'diff_quantity', 'remark'
    ];

    // 关联所属盘点单
    public function stockCheck()
    {
        return $this->belongsTo(BizStockCheck::class, 'stock_check_id', 'stock_check_id');
    }

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
