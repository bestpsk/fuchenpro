<?php

namespace app\model;

use support\Model;

class BizStockPrepare extends Model
{
    protected $table = 'biz_stock_prepare';
    protected $primaryKey = 'prepare_id';
    public $timestamps = false;

    protected $fillable = [
        'prepare_id', 'prepare_no', 'order_id', 'order_no', 'plan_id', 'plan_no', 'customer_id', 'customer_name',
        'enterprise_id', 'enterprise_name', 'store_id', 'store_name', 'warehouse_id',
        'total_quantity', 'total_amount', 'shipped_quantity', 'shipped_amount', 'remaining_quantity', 'remaining_amount',
        'status', 'remark', 'create_by', 'creator_user_id', 'create_time', 'update_by', 'update_time'
    ];

    public function items()
    {
        return $this->hasMany(BizStockPrepareItem::class, 'prepare_id', 'prepare_id');
    }

    public function orders()
    {
        return $this->hasMany(BizStockPrepareOrder::class, 'prepare_id', 'prepare_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'enterprise_name' => ['name' => '企业名称', 'sort' => 1],
            'prepare_no' => ['name' => '备货单号', 'sort' => 2],
            'store_name' => ['name' => '门店名称', 'sort' => 3],
            'product_count' => ['name' => '货品种类数', 'cellType' => 'numeric', 'type' => 'export', 'sort' => 4],
            'total_quantity' => ['name' => '总数量', 'cellType' => 'numeric', 'sort' => 5],
            'total_amount' => ['name' => '总金额', 'cellType' => 'numeric', 'sort' => 6],
            'shipped_quantity' => ['name' => '已出库数量', 'cellType' => 'numeric', 'sort' => 7],
            'shipped_amount' => ['name' => '已出库金额', 'cellType' => 'numeric', 'sort' => 8],
            'remaining_quantity' => ['name' => '待出库数量', 'cellType' => 'numeric', 'sort' => 9],
            'remaining_amount' => ['name' => '待出库金额', 'cellType' => 'numeric', 'sort' => 10],
            'status' => ['name' => '状态', 'dictType' => 'biz_stock_prepare_status', 'sort' => 11],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 12],
        ];
    }
}
