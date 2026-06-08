<?php

namespace app\model;

use support\Model;

/**
 * 出库单模型，记录出库类型、目标企业、总数量及审核状态
 */
class BizStockOut extends Model
{
    protected $table = 'biz_stock_out';
    protected $primaryKey = 'stock_out_id';
    public $timestamps = false;

    protected $fillable = [
        'stock_out_no', 'stock_out_type', 'out_target_type', 'prepare_id', 'plan_id',
        'enterprise_id', 'enterprise_name',
        'contact_person', 'contact_phone', 'shipping_address',
        'contact_employee_id', 'contact_employee_name',
        'responsible_id', 'responsible_name', 'total_quantity', 'total_amount',
        'stock_out_date', 'status', 'ship_type', 'ship_status',
        'logistics_company', 'logistics_no', 'shipment_date', 'receipt_date',
        'audit_by', 'audit_time',
        'remark', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联出库单下的所有产品明细
    public function items()
    {
        return $this->hasMany(BizStockOutItem::class, 'stock_out_id', 'stock_out_id');
    }
}
