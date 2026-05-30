<?php

namespace app\model;

use support\Model;

class SysAppMenu extends Model
{
    protected $table = 'sys_app_menu';
    protected $primaryKey = 'app_menu_id';
    public $timestamps = false;

    protected $fillable = [
        'menu_id', 'app_path', 'app_icon', 'bg_color', 'icon_color',
        'sort_order', 'visible', 'create_by', 'create_time', 'update_by', 'update_time'
    ];
}
