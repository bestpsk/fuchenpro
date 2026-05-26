<?php

namespace app\model;

use support\Model;

/**
 * 用户薪资模型，记录员工的薪资配置、提成比例及生效/失效日期
 */
class HrUserSalary extends Model
{
    protected $table = 'hr_user_salary';
    protected $primaryKey = 'salary_id';
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'type_id', 'base_amount', 'commission_rate', 'tier_config',
        'effective_date', 'expire_date', 'status',
        'create_by', 'create_time', 'update_by', 'update_time', 'remark'
    ];

    protected $casts = [
        'base_amount' => 'decimal:2',
        'commission_rate' => 'decimal:4',
        'effective_date' => 'date',
        'expire_date' => 'date',
        'create_time' => 'datetime',
        'update_time' => 'datetime',
    ];

    // 关联所属用户
    public function user()
    {
        return $this->belongsTo(SysUser::class, 'user_id', 'user_id');
    }

    // 关联所属薪资类型
    public function salaryType()
    {
        return $this->belongsTo(HrSalaryType::class, 'type_id', 'type_id');
    }

    // 关联该薪资配置下的所有阶梯
    public function tiers()
    {
        return $this->hasMany(HrSalaryTier::class, 'salary_id', 'salary_id')->orderBy('tier_level');
    }

    // 访问器：将tier_config字段的JSON字符串解码为数组
    public function getTierConfigAttribute($value)
    {
        return $value ? json_decode($value, true) : [];
    }

    // 修改器：将数组编码为JSON字符串存入tier_config字段
    public function setTierConfigAttribute($value)
    {
        $this->attributes['tier_config'] = is_array($value) ? json_encode($value) : $value;
    }
}
