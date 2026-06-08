<?php

namespace app\model;

use support\Model;

/**
 * 产品模型，存储产品基本信息、价格、保质期及库存预警设置
 */
class BizProduct extends Model
{
    protected $table = 'biz_product';
    protected $primaryKey = 'product_id';
    public $timestamps = false;

    protected $fillable = [
        'product_name', 'product_code', 'supplier_id', 'category',
        'unit', 'spec', 'pack_qty', 'purchase_price', 'sale_price', 'sale_price_spec',
        'shelf_life_days', 'has_expiry',
        'warn_qty', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联所属供应商
    public function supplier()
    {
        return $this->belongsTo(BizSupplier::class, 'supplier_id', 'supplier_id');
    }

    // 关联产品的库存记录
    public function inventory()
    {
        return $this->hasOne(BizInventory::class, 'product_id', 'product_id');
    }

    // 关联产品的入库明细
    public function stockInItems()
    {
        return $this->hasMany(BizStockInItem::class, 'product_id', 'product_id');
    }
}
