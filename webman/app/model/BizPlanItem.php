<?php

namespace app\model;

use support\Model;

/**
 * 方案明细模型，记录方案中每个产品的数量、价格及发货进度
 */
class BizPlanItem extends Model
{
    protected $table = 'biz_plan_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'plan_id', 'product_id', 'product_name', 'supplier_id', 'supplier_name',
        'unit_type', 'pack_qty', 'quantity', 'spec', 'sale_price', 'amount',
        'shipped_quantity', 'remaining_quantity', 'remark'
    ];

    // 关联所属方案
    public function plan()
    {
        return $this->belongsTo(BizPlan::class, 'plan_id', 'plan_id');
    }

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }
}
