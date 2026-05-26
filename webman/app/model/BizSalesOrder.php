<?php

namespace app\model;

use support\Model;

/**
 * 销售订单模型，记录客户订单金额、审核状态及关联套餐
 */
class BizSalesOrder extends Model
{
    protected $table = 'biz_sales_order';
    protected $primaryKey = 'order_id';
    public $timestamps = false;

    protected $fillable = [
        'order_no', 'customer_id', 'customer_name', 'enterprise_id', 'enterprise_name',
        'store_id', 'store_name', 'store_dealer', 'deal_amount', 'paid_amount', 'owed_amount', 'payment_method', 'order_status', 'source_type', 'operation_batch_id', 'package_name',
        'enterprise_audit_status', 'finance_audit_status',
        'enterprise_audit_by', 'enterprise_audit_time', 'finance_audit_by', 'finance_audit_time',
        'creator_user_id', 'creator_user_name', 'customer_feedback', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联订单下的所有产品明细
    public function items()
    {
        return $this->hasMany(BizOrderItem::class, 'order_id', 'order_id');
    }
}
