<?php

namespace app\model;

use support\Model;

class AppMenuConfig extends Model
{
    protected $table = 'app_menu_config';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'group_name', 'group_key', 'group_sort', 'title', 'icon', 'path',
        'icon_color', 'bg_color', 'sort_order', 'visible', 'status',
        'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];
}
