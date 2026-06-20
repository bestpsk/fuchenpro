<?php

namespace app\model;

use support\Model;

class BizCardItem extends Model
{
    protected $table = 'biz_card_item';
    protected $primaryKey = 'card_item_id';
    public $timestamps = false;

    protected $fillable = [
        'card_item_name', 'card_item_code', 'category',
        'default_quantity', 'suggested_price', 'default_unit_price',
        'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public function products()
    {
        return $this->hasMany(BizCardItemProduct::class, 'card_item_id', 'card_item_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'card_item_code' => ['name' => '卡项编码', 'sort' => 1],
            'card_item_name' => ['name' => '卡项名称', 'sort' => 2],
            'category' => ['name' => '类别', 'dictType' => 'biz_card_item_category', 'sort' => 3],
            'default_quantity' => ['name' => '默认次数', 'cellType' => 'numeric', 'sort' => 4],
            'suggested_price' => ['name' => '建议成交价', 'cellType' => 'numeric', 'sort' => 5],
            'default_unit_price' => ['name' => '默认单次价', 'cellType' => 'numeric', 'sort' => 6],
            'status' => ['name' => '状态', 'dictType' => 'sys_normal_disable', 'sort' => 7],
            'remark' => ['name' => '备注', 'sort' => 8],
        ];
    }
}
