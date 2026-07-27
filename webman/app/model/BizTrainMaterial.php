<?php

namespace app\model;

use support\Model;

/**
 * 培训学习材料模型
 */
class BizTrainMaterial extends Model
{
    protected $table = 'biz_train_material';
    protected $primaryKey = 'material_id';
    public $timestamps = false;

    protected $fillable = [
        'title', 'category', 'file_type', 'file_url', 'file_size',
        'cover_url', 'description', 'study_duration', 'sort', 'status',
        'del_flag', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'title' => ['name' => '材料标题', 'sort' => 1],
            'category' => ['name' => '分类', 'dictType' => 'biz_train_material_category', 'sort' => 2],
            'file_type' => ['name' => '文件类型', 'dictType' => 'biz_train_material_file_type', 'sort' => 3],
            'study_duration' => ['name' => '建议时长(秒)', 'cellType' => 'numeric', 'sort' => 4],
            'sort' => ['name' => '排序', 'cellType' => 'numeric', 'sort' => 5],
            'status' => ['name' => '状态', 'dictType' => 'sys_normal_disable', 'sort' => 6],
            'create_time' => ['name' => '创建时间', 'sort' => 7],
        ];
    }
}
