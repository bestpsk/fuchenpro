<?php

namespace app\model;

use support\Model;

/**
 * 回访答案明细模型，存储每道题目的答案值及文本内容
 */
class BizVisitAnswer extends Model
{
    protected $table = 'biz_visit_answer';
    protected $primaryKey = 'answer_id';
    public $timestamps = false;

    protected $fillable = [
        'visit_id', 'item_id', 'question_title', 'question_type',
        'answer_value', 'answer_text', 'create_time'
    ];

    // 关联回访任务
    public function visit()
    {
        return $this->belongsTo(BizVisitTask::class, 'visit_id', 'visit_id');
    }

    // 关联模板题目
    public function item()
    {
        return $this->belongsTo(BizVisitTemplateItem::class, 'item_id', 'item_id');
    }
}
