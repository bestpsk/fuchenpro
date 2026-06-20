<?php

namespace app\model;

use support\Model;

/**
 * 仓库用户关联模型，记录仓库与用户的授权关系
 */
class BizWarehouseUser extends Model
{
    protected $table = 'biz_warehouse_user';
    public $timestamps = false;
    protected $fillable = ['warehouse_id', 'user_id'];
}
