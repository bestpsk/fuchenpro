<?php

namespace app\model;

use support\Model;

/**
 * 供应商模型，存储供应商联系信息及合作状态
 */
class BizSupplier extends Model
{
    protected $table = 'biz_supplier';
    protected $primaryKey = 'supplier_id';
    public $timestamps = false;

    protected $fillable = [
        'supplier_name', 'contact_person', 'contact_phone', 'address',
        'cooperation_start_date', 'status', 'remark',
        'create_by', 'create_time', 'update_by', 'update_time'
    ];

    public static function getExcelFields(): array
    {
        return [
            'supplier_name' => ['name' => '供货商名称', 'sort' => 1],
            'contact_person' => ['name' => '联系人', 'sort' => 2],
            'contact_phone' => ['name' => '联系电话', 'sort' => 3],
            'address' => ['name' => '地址', 'sort' => 4],
            'cooperation_start_date' => ['name' => '合作起始日期', 'dateFormat' => 'Y-m-d', 'sort' => 5],
            'status' => ['name' => '状态', 'readConverterExp' => '0=正常,1=停用', 'sort' => 6],
            'remark' => ['name' => '备注', 'sort' => 7],
        ];
    }
}
