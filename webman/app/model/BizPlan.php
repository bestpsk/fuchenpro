<?php

namespace app\model;

use support\Model;

/**
 * 方案模型，记录企业方案信息、金额、审核状态及发货进度
 */
class BizPlan extends Model
{
    protected $table = 'biz_plan';
    protected $primaryKey = 'plan_id';
    public $timestamps = false;

    protected $fillable = [
        'plan_no', 'enterprise_id', 'plan_name', 'commission_rate',
        'plan_amount', 'gift_amount', 'shipped_amount', 'remaining_amount',
        'effective_date', 'expiry_date', 'audit_status', 'audit_by',
        'audit_time', 'audit_remark', 'submit_by', 'submit_time',
        'status_change_by', 'status_change_time', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联所属企业
    public function enterprise()
    {
        return $this->belongsTo(BizEnterprise::class, 'enterprise_id', 'enterprise_id');
    }

    // 关联方案下的所有产品明细
    public function items()
    {
        return $this->hasMany(BizPlanItem::class, 'plan_id', 'plan_id');
    }

    // 关联方案下的所有发货单
    public function shipments()
    {
        return $this->hasMany(BizShipment::class, 'plan_id', 'plan_id');
    }
}
