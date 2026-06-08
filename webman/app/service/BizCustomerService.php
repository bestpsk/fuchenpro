<?php

namespace app\service;

use app\model\BizCustomer;
use app\model\BizSalesOrder;
use app\model\BizCustomerPackage;
use app\model\BizPackageItem;
use app\model\BizOperationRecord;
use app\service\DataScopeService;


/**
 * 客户服务层
 *
 * 处理客户的增删改查和搜索（含成交状态和套餐耗尽判断）
 */
class BizCustomerService
{
    // 按条件分页查询客户列表，支持按企业、门店、姓名、电话、标签、状态筛选
    public function selectCustomerList($params = [])
    {
        $query = BizCustomer::query();
        if (!empty($params['enterprise_id'])) $query->where('enterprise_id', $params['enterprise_id']);
        if (!empty($params['store_id'])) $query->where('store_id', $params['store_id']);
        if (!empty($params['customer_name'])) $query->where('customer_name', 'like', '%' . $params['customer_name'] . '%');
        if (!empty($params['phone'])) $query->where('phone', 'like', '%' . $params['phone'] . '%');
        if (!empty($params['tag'])) $query->where('tag', $params['tag']);
        if (!empty($params['status'])) $query->where('status', $params['status']);
        DataScopeService::applyUserScope($query, $params['login_user'], 'enterprise_id', 'enterprise');
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('customer_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询客户信息
    public function selectCustomerById($customerId)
    {
        return BizCustomer::find($customerId);
    }

    // 搜索客户，附加成交状态、消费金额、套餐耗尽情况和平均满意度
    public function searchCustomer($keyword, $enterpriseId, $storeId = null, $hasDeal = null, $satisfaction = null, $loginUser = null)
    {
        $query = BizCustomer::query();
        $query->where('enterprise_id', $enterpriseId);
        if ($storeId) $query->where('store_id', $storeId);
        if ($keyword) {
            $query->where(function ($q) use ($keyword) {
                $q->where('customer_name', 'like', '%' . $keyword . '%')
                  ->orWhere('phone', 'like', '%' . $keyword . '%');
            });
        }
        DataScopeService::applyUserScope($query, $loginUser, 'enterprise_id', 'enterprise');
        $customers = $query->where('status', '0')->orderBy('customer_name', 'asc')->limit(100)->get();

        $result = [];
        foreach ($customers as $customer) {
            $customerId = $customer->customer_id;

            $customerHasDeal = BizSalesOrder::where('customer_id', $customerId)
                ->whereIn('order_status', ['1', '2'])->exists();
            $customer->has_deal = $customerHasDeal;

            $dealAmount = BizSalesOrder::where('customer_id', $customerId)
                ->whereIn('order_status', ['1', '2'])
                ->sum('deal_amount');
            $customer->deal_amount = round(floatval($dealAmount), 2);

            $dealPackageIds = BizCustomerPackage::where('customer_id', $customerId)
                ->whereIn('status', ['1', '2'])
                ->pluck('package_id')
                ->toArray();

            if (!empty($dealPackageIds)) {
                $allUsedUp = BizPackageItem::whereIn('package_id', $dealPackageIds)
                    ->where('remaining_quantity', '>', 0)
                    ->doesntExist();
                $customer->all_exhausted = $allUsedUp;
            } else {
                $customer->all_exhausted = false;
            }

            $totalConsumed = BizOperationRecord::where('customer_id', $customerId)
                ->sum('consume_amount');
            $customer->total_consumed = round(floatval($totalConsumed), 2);

            $avgSatisfaction = BizOperationRecord::where('customer_id', $customerId)
                ->whereNotNull('satisfaction')
                ->avg('satisfaction');
            $customer->avg_satisfaction = $avgSatisfaction ? round(floatval($avgSatisfaction), 1) : null;

            if ($hasDeal !== null && $hasDeal !== '') {
                $dealFilter = $hasDeal === '1' ? true : false;
                if ($customerHasDeal !== $dealFilter) continue;
            }

            if ($satisfaction !== null && $satisfaction !== '') {
                $satFilter = floatval($satisfaction);
                if ($customer->avg_satisfaction === null || $customer->avg_satisfaction < $satFilter) continue;
            }

            $result[] = $customer;
        }

        return collect($result);
    }

    // 新增客户，自动设置创建时间
    public function insertCustomer($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizCustomer::create($data);
    }

    // 更新客户信息，自动设置更新时间
    public function updateCustomer($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return BizCustomer::where('customer_id', $data['customer_id'])->update($data);
    }

    // 根据ID批量删除客户
    public function deleteCustomerByIds($customerIds)
    {
        return BizCustomer::whereIn('customer_id', $customerIds)->delete();
    }
}
