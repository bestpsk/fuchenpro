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
}
