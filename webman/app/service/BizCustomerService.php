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
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('customer_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        // 批量查询成交额和满意度，避免N+1查询
        $customerIds = $result->getCollection()->pluck('customer_id')->all();

        $dealAmounts = BizSalesOrder::whereIn('customer_id', $customerIds)
            ->whereIn('order_status', ['1', '2'])
            ->selectRaw('customer_id, SUM(deal_amount) as total')
            ->groupBy('customer_id')
            ->pluck('total', 'customer_id');

        $satisfactions = BizOperationRecord::whereIn('customer_id', $customerIds)
            ->whereNotNull('satisfaction')
            ->selectRaw('customer_id, AVG(satisfaction) as avg_sat')
            ->groupBy('customer_id')
            ->pluck('avg_sat', 'customer_id');

        foreach ($result as $customer) {
            $customer->deal_amount = round(floatval($dealAmounts[$customer->customer_id] ?? 0), 2);
            $sat = $satisfactions[$customer->customer_id] ?? null;
            $customer->avg_satisfaction = $sat ? round(floatval($sat), 1) : null;
        }

        return $result;
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
        $customers = $query->where('status', '0')->orderBy('customer_name', 'asc')->limit(100)->get();

        // 批量查询所有关联数据，避免N+1查询
        $customerIds = $customers->pluck('customer_id')->all();

        // 1. 批量查成交状态和金额
        $dealMap = BizSalesOrder::whereIn('customer_id', $customerIds)
            ->whereIn('order_status', ['1', '2'])
            ->selectRaw('customer_id, SUM(deal_amount) as total, COUNT(*) as cnt')
            ->groupBy('customer_id')
            ->get()
            ->keyBy('customer_id');

        // 2. 批量查有效套餐
        $packageMap = BizCustomerPackage::whereIn('customer_id', $customerIds)
            ->whereIn('status', ['1', '2'])
            ->selectRaw('customer_id, GROUP_CONCAT(package_id) as package_ids')
            ->groupBy('customer_id')
            ->pluck('package_ids', 'customer_id');

        // 3. 批量查套餐剩余数量
        $allPackageIds = $packageMap->flatMap(function ($ids) {
            return explode(',', $ids);
        })->unique()->values()->all();
        $packagesWithRemaining = BizPackageItem::whereIn('package_id', $allPackageIds)
            ->where('remaining_quantity', '>', 0)
            ->pluck('package_id')
            ->unique()
            ->toArray();

        // 4. 批量查消费和满意度
        $consumeMap = BizOperationRecord::whereIn('customer_id', $customerIds)
            ->selectRaw('customer_id, SUM(consume_amount) as total, AVG(satisfaction) as avg_sat')
            ->groupBy('customer_id')
            ->get()
            ->keyBy('customer_id');

        $result = [];
        foreach ($customers as $customer) {
            $customerId = $customer->customer_id;

            $dealInfo = $dealMap->get($customerId);
            $customerHasDeal = $dealInfo && $dealInfo->cnt > 0;
            $customer->has_deal = $customerHasDeal;

            $customer->deal_amount = round(floatval($dealInfo->total ?? 0), 2);

            $packageIdsStr = $packageMap->get($customerId);
            $dealPackageIds = $packageIdsStr ? explode(',', $packageIdsStr) : [];

            if (!empty($dealPackageIds)) {
                $allUsedUp = true;
                foreach ($dealPackageIds as $pid) {
                    if (in_array($pid, $packagesWithRemaining)) {
                        $allUsedUp = false;
                        break;
                    }
                }
                $customer->all_exhausted = $allUsedUp;
            } else {
                $customer->all_exhausted = false;
            }

            $consumeInfo = $consumeMap->get($customerId);
            $customer->total_consumed = round(floatval($consumeInfo->total ?? 0), 2);

            $sat = $consumeInfo->avg_sat ?? null;
            $customer->avg_satisfaction = $sat ? round(floatval($sat), 1) : null;

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
        $updateData = array_intersect_key($data, array_flip((new BizCustomer())->getFillable()));
        return BizCustomer::where('customer_id', $data['customer_id'])->update($updateData);
    }

    // 根据ID批量删除客户
    public function deleteCustomerByIds($customerIds)
    {
        return BizCustomer::whereIn('customer_id', $customerIds)->delete();
    }
}
