<?php

namespace app\model;

use support\Model;

/**
 * 仓库模型，存储仓库基本信息及关联用户
 */
class BizWarehouse extends Model
{
    protected $table = 'biz_warehouse';
    protected $primaryKey = 'warehouse_id';
    public $timestamps = false;

    protected $fillable = [
        'warehouse_name', 'warehouse_code', 'address',
        'contact_person', 'contact_phone', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 多对多关联：仓库下的用户列表
    public function users()
    {
        return $this->belongsToMany(SysUser::class, 'biz_warehouse_user', 'warehouse_id', 'user_id', 'warehouse_id', 'user_id');
    }
}
