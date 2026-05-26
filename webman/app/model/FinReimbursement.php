<?php

namespace app\model;

use support\Model;

/**
 * 报销单模型，记录员工报销申请、审核和支付信息
 */
class FinReimbursement extends Model
{
    protected $table = 'fin_reimbursement';
    protected $primaryKey = 'reimbursement_id';
    public $timestamps = false;

    protected $fillable = [
        'reimbursement_no', 'applicant_id', 'applicant_name', 'dept_id', 'dept_name',
        'apply_date', 'category', 'income_amount', 'expense_amount', 'expense_type',
        'status', 'voucher_images', 'remark',
        'audit_by', 'audit_time', 'audit_remark',
        'pay_by', 'pay_time',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    protected $casts = [
        'apply_date' => 'date:Y-m-d',
        'expense_amount' => 'decimal:2',
        'income_amount' => 'decimal:2',
        'audit_time' => 'datetime:Y-m-d H:i:s',
        'pay_time' => 'datetime:Y-m-d H:i:s',
        'create_time' => 'datetime:Y-m-d H:i:s',
        'update_time' => 'datetime:Y-m-d H:i:s',
    ];

    // 关联报销明细
    public function items()
    {
        return $this->hasMany(FinReimbursementItem::class, 'reimbursement_id', 'reimbursement_id');
    }

    // 关联申请人
    public function applicant()
    {
        return $this->belongsTo(SysUser::class, 'applicant_id', 'user_id');
    }

    // 关联部门
    public function dept()
    {
        return $this->belongsTo(SysDept::class, 'dept_id', 'dept_id');
    }
}
