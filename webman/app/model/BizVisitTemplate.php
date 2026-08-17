<?php

namespace app\model;

use support\Model;

/**
 * 回访问卷模板模型，存储模板名称、回访类型及状态
 */
class BizVisitTemplate extends Model
{
    protected $table = 'biz_visit_template';
    protected $primaryKey = 'template_id';
    public $timestamps = false;

    protected $fillable = [
        'template_name', 'visit_type', 'description', 'status',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联模板题目
    public function items()
    {
        return $this->hasMany(BizVisitTemplateItem::class, 'template_id', 'template_id')
            ->orderBy('sort_order', 'asc');
    }

    // 关联回访任务
    public function tasks()
    {
        return $this->hasMany(BizVisitTask::class, 'template_id', 'template_id');
    }
}
