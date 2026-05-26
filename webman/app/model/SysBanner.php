<?php

namespace app\model;

use support\Model;

class SysBanner extends Model
{
    protected $table = 'sys_banner';
    protected $primaryKey = 'banner_id';
    public $timestamps = false;

    protected $fillable = [
        'title',
        'image',
        'link_url',
        'sort_order',
        'status',
        'remark',
        'create_by',
        'create_time',
        'update_by',
        'update_time'
    ];
}
