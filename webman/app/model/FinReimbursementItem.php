<?php

namespace app\model;

use support\Model;

/**
 * 报销明细模型，记录报销单中的具体项目明细
 */
class FinReimbursementItem extends Model
{
    protected $table = 'fin_reimbursement_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'reimbursement_id', 'item_name', 'amount', 'description'
    ];

    // 关联所属报销单
    public function reimbursement()
    {
        return $this->belongsTo(FinReimbursement::class, 'reimbursement_id', 'reimbursement_id');
    }
}
