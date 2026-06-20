<?php

namespace app\model;

use support\Model;

/**
 * 库存模型，记录产品的当前库存数量、预警数量及最近出入库时间
 */
class BizInventory extends Model
{
    protected $table = 'biz_inventory';
    protected $primaryKey = 'inventory_id';
    public $timestamps = false;

    protected $fillable = [
        'inventory_id', 'warehouse_id', 'product_id', 'quantity', 'warn_qty', 'earliest_expiry',
        'last_stock_in_time', 'last_stock_out_time',
        'create_time', 'update_time'
    ];

    // 关联对应的产品
    public function product()
    {
        return $this->belongsTo(BizProduct::class, 'product_id', 'product_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'product_code' => ['name' => '货品编码', 'type' => 'export', 'sort' => 1],
            'product_name' => ['name' => '品名', 'type' => 'export', 'sort' => 2],
            'category' => ['name' => '类别', 'type' => 'export', 'dictType' => 'biz_product_category', 'sort' => 3],
            'warehouse_name' => ['name' => '仓库', 'type' => 'export', 'sort' => 4],
            'quantity' => ['name' => '当前库存', 'cellType' => 'numeric', 'sort' => 5],
            'warn_qty' => ['name' => '预警数量', 'cellType' => 'numeric', 'sort' => 6],
            'purchase_price' => ['name' => '进货价', 'type' => 'export', 'cellType' => 'numeric', 'sort' => 7],
            'sale_price' => ['name' => '出货价', 'type' => 'export', 'cellType' => 'numeric', 'sort' => 8],
            'last_stock_in_time' => ['name' => '最后入库', 'dateFormat' => 'Y-m-d H:i', 'sort' => 9],
            'last_stock_out_time' => ['name' => '最后出库', 'dateFormat' => 'Y-m-d H:i', 'sort' => 10],
        ];
    }
}
