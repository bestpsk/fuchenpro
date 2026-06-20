<?php

namespace app\model;

use support\Model;

/**
 * 盘点单模型，记录库存盘点的日期、总数量及差异数量
 */
class BizStockCheck extends Model
{
    protected $table = 'biz_stock_check';
    protected $primaryKey = 'stock_check_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_check_no', 'warehouse_id', 'check_date', 'total_quantity', 'total_diff_quantity',
        'operator_id', 'operator_name', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联盘点单下的所有产品明细
    public function items()
    {
        return $this->hasMany(BizStockCheckItem::class, 'stock_check_id', 'stock_check_id');
    }
}
