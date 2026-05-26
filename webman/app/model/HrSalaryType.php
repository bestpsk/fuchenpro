<?php

namespace app\model;

use support\Model;

/**
 * 薪资类型模型，定义薪资类型的编码、名称及计算公式
 */
class HrSalaryType extends Model
{
    protected $table = 'hr_salary_type';
    protected $primaryKey = 'type_id';
    public $timestamps = false;

    protected $fillable = [
        'type_code', 'type_name', 'calc_formula', 'status',
        'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];

    protected $casts = [
        'create_time' => 'datetime',
        'update_time' => 'datetime',
    ];

    // 关联该类型下的所有用户薪资配置
    public function userSalaries()
    {
        return $this->hasMany(HrUserSalary::class, 'type_id', 'type_id');
    }
}
