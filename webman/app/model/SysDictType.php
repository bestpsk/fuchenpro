<?php

namespace app\model;

use support\Model;

/**
 * 字典类型模型，定义字典的分类编码及状态
 */
class SysDictType extends Model
{
    protected $table = 'sys_dict_type';
    protected $primaryKey = 'dict_id';
    public $timestamps = false;

    protected $fillable = [
        'dict_name', 'dict_type', 'status', 'create_by', 'create_time',
        'update_by', 'update_time', 'remark'
    ];

    // 关联该类型下的所有字典数据
    public function dictData()
    {
        return $this->hasMany(SysDictData::class, 'dict_type', 'dict_type');
    }
}
