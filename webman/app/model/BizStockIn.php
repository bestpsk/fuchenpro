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
        'stock_in_no', 'stock_in_type', 'supplier_id', 'warehouse_id', 'total_quantity', 'total_amount',
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

    public static function getExcelFields(): array
    {
        return [
            'stock_in_no' => ['name' => '入库单号', 'sort' => 1],
            'stock_in_type' => ['name' => '入库类型', 'dictType' => 'biz_stock_in_type', 'sort' => 2],
            'warehouse_name' => ['name' => '仓库', 'type' => 'export', 'sort' => 3],
            'total_quantity' => ['name' => '总数量', 'cellType' => 'numeric', 'sort' => 4],
            'total_amount' => ['name' => '总金额', 'cellType' => 'numeric', 'sort' => 5],
            'stock_in_date' => ['name' => '入库日期', 'dateFormat' => 'Y-m-d', 'sort' => 6],
            'operator_name' => ['name' => '操作人', 'sort' => 7],
            'status' => ['name' => '状态', 'readConverterExp' => '0=待确认,1=已确认', 'sort' => 8],
            'remark' => ['name' => '备注', 'sort' => 9],
        ];
    }
}
