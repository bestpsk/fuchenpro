<?php

namespace app\model;

use support\Model;

/**
 * 培训材料授权模型
 * target_type: 1=用户 2=部门
 */
class BizTrainMaterialAuth extends Model
{
    protected $table = 'biz_train_material_auth';
    protected $primaryKey = 'auth_id';
    public $timestamps = false;

    protected $fillable = [
        'material_id', 'target_type', 'target_id', 'create_by', 'create_time'
    ];
}
