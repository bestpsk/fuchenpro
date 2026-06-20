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
        'warehouse_id',
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

    public static function getExcelFields(): array
    {
        return [
            'stock_out_no' => ['name' => '出库单号', 'sort' => 1],
            'stock_out_type' => ['name' => '出库类型', 'dictType' => 'biz_stock_out_type', 'sort' => 2],
            'warehouse_name' => ['name' => '仓库', 'type' => 'export', 'sort' => 3],
            'enterprise_name' => ['name' => '出库企业', 'sort' => 4],
            'contact_employee_name' => ['name' => '对接员工', 'sort' => 5],
            'responsible_name' => ['name' => '出库员工', 'sort' => 6],
            'total_quantity' => ['name' => '总数量', 'cellType' => 'numeric', 'sort' => 7],
            'total_amount' => ['name' => '总金额', 'cellType' => 'numeric', 'sort' => 8],
            'stock_out_date' => ['name' => '出库日期', 'dateFormat' => 'Y-m-d', 'sort' => 9],
            'status' => ['name' => '状态', 'readConverterExp' => '0=待确认,1=已确认,2=已发货,3=已完成', 'sort' => 10],
            'remark' => ['name' => '备注', 'sort' => 11],
        ];
    }
}
