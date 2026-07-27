<?php

namespace app\model;

use support\Model;

/**
 * 企业小报模型，存储企业小报标题及富文本内容
 */
class BizAbout extends Model
{
    protected $table = 'biz_about';
    protected $primaryKey = 'about_id';
    public $timestamps = false;

    protected $fillable = [
        'about_title', 'cover_url', 'about_content', 'status', 'sort', 'create_by',
        'create_time', 'update_by', 'update_time', 'remark'
    ];

    protected $casts = [
        'about_content' => 'string',
    ];
}
