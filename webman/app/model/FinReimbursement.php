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

    public static function getExcelFields(): array
    {
        return [
            'reimbursement_no' => ['name' => '报销单号', 'sort' => 1],
            'applicant_name' => ['name' => '申请人', 'sort' => 2],
            'dept_name' => ['name' => '部门', 'sort' => 3],
            'apply_date' => ['name' => '申请日期', 'dateFormat' => 'Y-m-d', 'sort' => 4],
            'category' => ['name' => '分类', 'dictType' => 'fin_reimbursement_category', 'sort' => 5],
            'expense_amount' => ['name' => '支出金额', 'cellType' => 'numeric', 'sort' => 6],
            'expense_type' => ['name' => '支出类型', 'dictType' => 'fin_reimbursement_expense_type', 'sort' => 7],
            'status' => ['name' => '状态', 'readConverterExp' => '0=待审核,1=已审核,2=已拒绝,3=已支付', 'sort' => 8],
            'audit_by' => ['name' => '审核人', 'sort' => 9],
            'audit_time' => ['name' => '审核时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 10],
            'pay_by' => ['name' => '支付人', 'sort' => 11],
            'pay_time' => ['name' => '支付时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 12],
            'remark' => ['name' => '备注', 'sort' => 13],
        ];
    }
}
