<?php

namespace app\model;

use support\Model;

/**
 * 入库单模型，记录入库类型、供应商、总数量及审核状态
 */
class BizStockIn extends Model
{
    protected $table = 'biz_stock_in';
    protected $primaryKey = 'stock_in_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_in_no', 'stock_in_type', 'supplier_id', 'total_quantity', 'total_amount',
        'stock_in_date', 'operator_id', 'operator_name', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联入库单下的所有产品明细
    public function items()
    {
        return $this->hasMany(BizStockInItem::class, 'stock_in_id', 'stock_in_id');
    }

    // 关联所属供应商
    public function supplier()
    {
        return $this->belongsTo(BizSupplier::class, 'supplier_id', 'supplier_id');
    }
}
