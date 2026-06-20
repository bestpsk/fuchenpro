<?php

namespace app\model;

use support\Model;

/**
 * 门店模型，存储门店基本信息、营业时间及服务人员
 */
class BizStore extends Model
{
    protected $table = 'biz_store';
    protected $primaryKey = 'store_id';
    public $timestamps = false;

    protected $fillable = [
        'enterprise_id', 'enterprise_name', 'store_name', 'manager_name', 'phone',
        'wechat', 'address', 'business_hours', 'annual_performance', 'regular_customers',
        'creator_name', 'server_user_id', 'server_user_name',
        'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'store_name' => ['name' => '门店名称', 'sort' => 1],
            'enterprise_name' => ['name' => '所属企业', 'sort' => 2],
            'manager_name' => ['name' => '负责人', 'sort' => 3],
            'phone' => ['name' => '联系电话', 'sort' => 4],
            'wechat' => ['name' => '微信', 'sort' => 5],
            'address' => ['name' => '地址', 'width' => 30, 'sort' => 6],
            'business_hours' => ['name' => '营业时间', 'sort' => 7],
            'annual_performance' => ['name' => '年业绩', 'cellType' => 'numeric', 'sort' => 8],
            'regular_customers' => ['name' => '常来顾客数', 'cellType' => 'numeric', 'sort' => 9],
            'server_user_name' => ['name' => '服务员工', 'sort' => 10],
            'creator_name' => ['name' => '创建人', 'sort' => 11],
            'status' => ['name' => '状态', 'dictType' => 'sys_normal_disable', 'sort' => 12],
            'create_time' => ['name' => '创建时间', 'dateFormat' => 'Y-m-d H:i:s', 'sort' => 13],
        ];
    }
}
