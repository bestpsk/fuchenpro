<?php

namespace app\service;

use app\model\BizCustomerPackage;
use app\model\BizPackageItem;

/**
 * 客户套餐服务层
 *
 * 处理客户已购套餐的查询
 */
class BizCustomerPackageService
{
    // 按条件分页查询客户套餐列表，关联查询套餐明细
    public function selectPackageList($params = [])
    {
        $query = BizCustomerPackage::query();
        if (!empty($params['customer_id'])) $query->where('customer_id', $params['customer_id']);
        if (!empty($params['enterprise_id'])) $query->where('enterprise_id', $params['enterprise_id']);
        if (!empty($params['store_id'])) $query->where('store_id', $params['store_id']);
        if (isset($params['status']) && $params['status'] !== '') $query->where('status', $params['status']);
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->with('items')->orderBy('package_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询套餐及明细
    public function selectPackageById($packageId)
    {
        return BizCustomerPackage::with('items')->find($packageId);
    }

    // 查询指定客户的所有套餐，可按状态筛选（0=未使用 1=使用中 2=已用完）
    public function selectPackagesByCustomer($customerId, $status = null)
    {
        $query = BizCustomerPackage::query();
        $query->where('customer_id', $customerId);
        if ($status !== null && $status !== '') {
            $query->where('status', $status);
        } else {
            $query->whereIn('status', ['1', '2']);
        }
        return $query->with('items')->orderBy('package_id', 'desc')->get();
    }
}
