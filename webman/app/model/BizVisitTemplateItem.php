<?php

namespace app\model;

use support\Model;

/**
 * 回访问卷模板题目模型，存储题目内容、题型、选项及排序
 */
class BizVisitTemplateItem extends Model
{
    protected $table = 'biz_visit_template_item';
    protected $primaryKey = 'item_id';
    public $timestamps = false;

    protected $fillable = [
        'template_id', 'question_title', 'question_type', 'options',
        'sort_order', 'required', 'create_time'
    ];

    // 关联模板
    public function template()
    {
        return $this->belongsTo(BizVisitTemplate::class, 'template_id', 'template_id');
    }
}
