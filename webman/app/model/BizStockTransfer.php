<?php

namespace app\model;

use support\Model;

class BizStockTransfer extends Model
{
    protected $table = 'biz_stock_transfer';
    protected $primaryKey = 'transfer_id';
    public $timestamps = false;

    protected $fillable = [
        'transfer_id', 'transfer_no', 'from_warehouse_id', 'from_warehouse_name',
        'to_warehouse_id', 'to_warehouse_name', 'total_quantity', 'transfer_date',
        'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public function items()
    {
        return $this->hasMany(BizStockTransferItem::class, 'transfer_id', 'transfer_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'transfer_no' => ['name' => '调拨单号', 'sort' => 1],
            'from_warehouse_name' => ['name' => '源仓库', 'sort' => 2],
            'to_warehouse_name' => ['name' => '目标仓库', 'sort' => 3],
            'total_quantity' => ['name' => '总数量', 'cellType' => 'numeric', 'sort' => 4],
            'transfer_date' => ['name' => '调拨日期', 'dateFormat' => 'Y-m-d', 'sort' => 5],
            'status' => ['name' => '状态', 'readConverterExp' => '0=待确认,1=已确认', 'sort' => 6],
            'remark' => ['name' => '备注', 'sort' => 7],
        ];
    }
}
