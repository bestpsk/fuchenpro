<?php

namespace app\model;

use support\Model;

/**
 * 企业模型，存储企业基本信息、合作状态及服务人员
 */
class BizEnterprise extends Model
{
    protected $table = 'biz_enterprise';
    protected $primaryKey = 'enterprise_id';
    public $timestamps = false;

    protected $fillable = [
        'enterprise_name', 'pinyin', 'boss_name', 'phone', 'address', 'enterprise_type',
        'store_count', 'annual_performance', 'enterprise_level', 'server_user_id',
        'server_user_name', 'cooperation_start_date', 'cooperation_end_date',
        'contract_status', 'contract_files',
        'status', 'remark', 'create_by', 'create_time',
        'update_by', 'update_time'
    ];

    // 关联企业下的所有方案
    public function plans()
    {
        return $this->hasMany(BizPlan::class, 'enterprise_id', 'enterprise_id');
    }

    public static function getExcelFields(): array
    {
        return [
            'enterprise_name' => ['name' => '企业名称', 'sort' => 1],
            'boss_name' => ['name' => '老板姓名', 'sort' => 2],
            'phone' => ['name' => '联系电话', 'sort' => 3],
            'enterprise_type' => ['name' => '企业类型', 'dictType' => 'biz_enterprise_type', 'sort' => 4],
            'store_count' => ['name' => '门店数量', 'cellType' => 'numeric', 'sort' => 5],
            'enterprise_level' => ['name' => '企业级别', 'dictType' => 'biz_enterprise_level', 'sort' => 6],
            'server_user_name' => ['name' => '服务人', 'sort' => 7],
            'cooperation_start_date' => ['name' => '合作开始', 'dateFormat' => 'Y-m-d', 'sort' => 8],
            'cooperation_end_date' => ['name' => '合作结束', 'dateFormat' => 'Y-m-d', 'sort' => 9],
            'status' => ['name' => '状态', 'dictType' => 'sys_normal_disable', 'sort' => 10],
            'plan_count' => ['name' => '方案数量', 'cellType' => 'numeric', 'type' => 'export', 'sort' => 11],
        ];
    }
}
