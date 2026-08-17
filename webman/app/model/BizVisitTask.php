<?php

namespace app\model;

use support\Model;

/**
 * 满意度回访任务模型，记录回访对象、方式、状态及H5链接凭证
 */
class BizVisitTask extends Model
{
    protected $table = 'biz_visit_task';
    protected $primaryKey = 'visit_id';
    public $timestamps = false;

    protected $fillable = [
        'template_id', 'enterprise_id', 'enterprise_name', 'store_id', 'store_name',
        'visit_type', 'visit_mode', 'visit_status',
        'visitor_user_id', 'visitor_user_name', 'visit_time',
        'contact_name', 'contact_phone', 'visit_token', 'token_expire_time',
        'satisfaction_score', 'remark', 'del_flag',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    // 关联模板
    public function template()
    {
        return $this->belongsTo(BizVisitTemplate::class, 'template_id', 'template_id');
    }

    // 关联模板题目（通过模板）
    public function items()
    {
        return $this->hasManyThrough(
            BizVisitTemplateItem::class,
            BizVisitTemplate::class,
            'template_id', 'template_id', 'template_id', 'template_id'
        )->orderBy('sort_order', 'asc');
    }

    // 关联回访答案
    public function answers()
    {
        return $this->hasMany(BizVisitAnswer::class, 'visit_id', 'visit_id');
    }
}
