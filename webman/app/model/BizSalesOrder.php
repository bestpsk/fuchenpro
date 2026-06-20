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

    public static function getExcelFields(): array
    {
        return [
            'order_no' => ['name' => '订单编号', 'sort' => 1],
            'source_type' => ['name' => '类别', 'readConverterExp' => '0=开单,1=操作,2=还款,3=手动', 'sort' => 2],
            'customer_name' => ['name' => '客户姓名', 'sort' => 3],
            'enterprise_name' => ['name' => '企业名称', 'sort' => 4],
            'store_name' => ['name' => '门店名称', 'sort' => 5],
            'store_dealer' => ['name' => '门店成交人', 'sort' => 6],
            'package_name' => ['name' => '套餐名称', 'sort' => 7],
            'deal_amount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 8],
            'paid_amount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 9],
            'owed_amount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 10],
            'order_status' => ['name' => '订单状态', 'readConverterExp' => '0=待确认,1=企业已审,2=财务已审,4=已取消', 'sort' => 11],
            'enterprise_audit_status' => ['name' => '企业审核', 'readConverterExp' => '0=待审核,1=已审核,2=已驳回', 'sort' => 12],
            'finance_audit_status' => ['name' => '财务审核', 'readConverterExp' => '0=待审核,1=已审核,2=已驳回', 'sort' => 13],
            'creator_user_name' => ['name' => '开单员工', 'sort' => 14],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 15],
        ];
    }
}
