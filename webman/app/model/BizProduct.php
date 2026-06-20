<?php

namespace app\model;

use support\Model;

/**
 * 产品模型，存储产品基本信息、价格、保质期及库存预警设置
 */
class BizProduct extends Model
{
    protected $table = 'biz_product';
    protected $primaryKey = 'product_id';
    public $timestamps = false;

    protected $fillable = [
        'product_name', 'product_code', 'supplier_id', 'category',
        'unit', 'spec', 'pack_qty', 'purchase_price', 'sale_price', 'sale_price_spec',
        'shelf_life_days', 'has_expiry',
        'warn_qty', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联所属供应商
    public function supplier()
    {
        return $this->belongsTo(BizSupplier::class, 'supplier_id', 'supplier_id');
    }

    // 关联产品的库存记录
    public function inventory()
    {
        return $this->hasOne(BizInventory::class, 'product_id', 'product_id');
    }

    // 关联产品的入库明细
    public function stockInItems()
    {
        return $this->hasMany(BizStockInItem::class, 'product_id', 'product_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'product_code' => ['name' => '货品编码', 'sort' => 1],
            'product_name' => ['name' => '品名', 'sort' => 2],
            'supplier_name' => ['name' => '供货商', 'type' => 'export', 'sort' => 3],
            'category' => ['name' => '类别', 'dictType' => 'biz_product_category', 'sort' => 4],
            'unit' => ['name' => '单位(整)', 'dictType' => 'biz_product_unit', 'sort' => 5],
            'spec' => ['name' => '规格(拆)', 'dictType' => 'biz_product_spec', 'sort' => 6],
            'pack_qty' => ['name' => '包装数量', 'cellType' => 'numeric', 'sort' => 7],
            'purchase_price' => ['name' => '进货价', 'cellType' => 'numeric', 'sort' => 8],
            'sale_price' => ['name' => '出货价(整)', 'cellType' => 'numeric', 'sort' => 9],
            'sale_price_spec' => ['name' => '出货价(拆)', 'cellType' => 'numeric', 'sort' => 10],
            'warn_qty' => ['name' => '预警数量', 'cellType' => 'numeric', 'sort' => 11],
            'status' => ['name' => '状态', 'readConverterExp' => '0=正常,1=停用', 'sort' => 12],
        ];
    }
}
