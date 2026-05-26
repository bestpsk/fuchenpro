<?php

namespace app\model;

use support\Model;

/**
 * 薪资阶梯模型，定义薪资的阶梯等级、金额范围及提成比例
 */
class HrSalaryTier extends Model
{
    protected $table = 'hr_salary_tier';
    protected $primaryKey = 'tier_id';
    public $timestamps = false;

    protected $fillable = [
        'salary_id', 'tier_level', 'min_amount', 'max_amount', 'commission_rate', 'create_time'
    ];

    protected $casts = [
        'min_amount' => 'decimal:2',
        'max_amount' => 'decimal:2',
        'commission_rate' => 'decimal:4',
        'create_time' => 'datetime',
    ];

    // 关联所属用户薪资配置
    public function userSalary()
    {
        return $this->belongsTo(HrUserSalary::class, 'salary_id', 'salary_id');
    }
}
