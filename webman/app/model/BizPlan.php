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

    public static function getExcelFields(): array
    {
        return [
            'plan_no' => ['name' => '方案编号', 'sort' => 1],
            'plan_name' => ['name' => '方案名称', 'sort' => 2],
            'enterprise_name' => ['name' => '企业名称', 'type' => 'export', 'sort' => 3],
            'commission_rate' => ['name' => '分成比例(%)', 'cellType' => 'numeric', 'sort' => 4],
            'plan_amount' => ['name' => '方案金额', 'cellType' => 'numeric', 'sort' => 5],
            'gift_amount' => ['name' => '配赠金额', 'cellType' => 'numeric', 'sort' => 6],
            'remaining_amount' => ['name' => '剩余金额', 'cellType' => 'numeric', 'sort' => 7],
            'audit_status' => ['name' => '审核状态', 'readConverterExp' => '0=草稿,1=待审核,2=已审核,3=已完成,4=已驳回', 'sort' => 8],
            'status' => ['name' => '启用', 'dictType' => 'sys_normal_disable', 'sort' => 9],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 10],
        ];
    }
}
