<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizOperationRecord;
use app\model\BizEnterprise;
use app\model\BizStore;
use app\model\SysUser;
use app\model\SysDept;

class PerformanceStatsService
{
    /**
     * 按部门统计业绩
     */
    public static function getDeptPerformance($loginUser, $startDate, $endDate)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        // 获取可见用户ID对应的部门
        $userDeptMap = SysUser::whereIn('user_id', $userIds)
            ->where('del_flag', '0')
            ->pluck('dept_id', 'user_id')
            ->toArray();

        if (empty($userDeptMap)) {
            return [];
        }

        $deptIds = array_unique(array_values($userDeptMap));

        // 销售统计 - 按部门分组
        $dealStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('creator_user_id, COUNT(DISTINCT customer_id) as deal_customer_count, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->groupBy('creator_user_id')
            ->get();

        // 支付方式统计 - 按用户分组
        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('biz_sales_order.creator_user_id, biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as amount')
            ->groupBy('biz_sales_order.creator_user_id', 'biz_order_item.payment_method')
            ->get();

        // 赠送次数统计 - 按用户分组
        $giftCountStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->where('biz_order_item.payment_method', 'gift')
            ->selectRaw('biz_sales_order.creator_user_id, COUNT(*) as gift_count')
            ->groupBy('biz_sales_order.creator_user_id')
            ->get()
            ->keyBy('creator_user_id');

        // 操作记录统计 - 按用户分组
        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('operator_user_id, COUNT(DISTINCT customer_id) as operation_customer_count')
            ->groupBy('operator_user_id')
            ->get()
            ->keyBy('operator_user_id');

        // 按用户汇总支付方式
        $paymentByUser = [];
        foreach ($paymentStats as $ps) {
            $uid = $ps->creator_user_id;
            if (!isset($paymentByUser[$uid])) {
                $paymentByUser[$uid] = ['cash' => 0, 'card' => 0];
            }
            if ($ps->payment_method === 'cash') {
                $paymentByUser[$uid]['cash'] = round((float)$ps->amount, 2);
            } elseif ($ps->payment_method === 'card') {
                $paymentByUser[$uid]['card'] = round((float)$ps->amount, 2);
            }
        }

        // 按用户汇总销售数据
        $dealByUser = [];
        foreach ($dealStats as $ds) {
            $dealByUser[$ds->creator_user_id] = $ds;
        }

        // 按部门汇总
        $deptData = [];
        foreach ($userDeptMap as $uid => $deptId) {
            if (!isset($deptData[$deptId])) {
                $deptData[$deptId] = [
                    'deal_customer_count' => 0,
                    'deal_amount' => 0,
                    'paid_amount' => 0,
                    'owed_amount' => 0,
                    'cash_amount' => 0,
                    'card_amount' => 0,
                    'gift_count' => 0,
                    'operation_customer_count' => 0,
                ];
            }
            $deal = $dealByUser[$uid] ?? null;
            $payment = $paymentByUser[$uid] ?? ['cash' => 0, 'card' => 0];
            $giftCount = $giftCountStats->get($uid);
            $op = $operationStats->get($uid);

            $deptData[$deptId]['deal_customer_count'] += $deal ? (int)$deal->deal_customer_count : 0;
            $deptData[$deptId]['deal_amount'] += $deal ? round((float)$deal->deal_amount, 2) : 0;
            $deptData[$deptId]['paid_amount'] += $deal ? round((float)$deal->paid_amount, 2) : 0;
            $deptData[$deptId]['owed_amount'] += $deal ? round((float)$deal->owed_amount, 2) : 0;
            $deptData[$deptId]['cash_amount'] += $payment['cash'];
            $deptData[$deptId]['card_amount'] += $payment['card'];
            $deptData[$deptId]['gift_count'] += $giftCount ? (int)$giftCount->gift_count : 0;
            $deptData[$deptId]['operation_customer_count'] += $op ? (int)$op->operation_customer_count : 0;
        }

        // 查询部门名称
        $depts = SysDept::whereIn('dept_id', $deptIds)->pluck('dept_name', 'dept_id')->toArray();

        $result = [];
        foreach ($deptData as $deptId => $data) {
            $result[] = [
                'deptId' => $deptId,
                'deptName' => $depts[$deptId] ?? '未知部门',
                'dealCustomerCount' => $data['deal_customer_count'],
                'dealAmount' => round($data['deal_amount'], 2),
                'paidAmount' => round($data['paid_amount'], 2),
                'owedAmount' => round($data['owed_amount'], 2),
                'cashAmount' => round($data['cash_amount'], 2),
                'cardAmount' => round($data['card_amount'], 2),
                'giftCount' => $data['gift_count'],
                'operationCustomerCount' => $data['operation_customer_count'],
            ];
        }

        usort($result, function ($a, $b) {
            return $b['dealAmount'] <=> $a['dealAmount'];
        });

        return $result;
    }

    /**
     * 按个人统计业绩
     */
    public static function getUserPerformance($loginUser, $startDate, $endDate)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        // 销售统计 - 按用户分组
        $dealStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('creator_user_id, COUNT(DISTINCT customer_id) as deal_customer_count, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->groupBy('creator_user_id')
            ->get()
            ->keyBy('creator_user_id');

        // 支付方式统计 - 按用户分组
        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('biz_sales_order.creator_user_id, biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as amount')
            ->groupBy('biz_sales_order.creator_user_id', 'biz_order_item.payment_method')
            ->get();

        // 赠送次数统计 - 按用户分组
        $giftCountStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->where('biz_order_item.payment_method', 'gift')
            ->selectRaw('biz_sales_order.creator_user_id, COUNT(*) as gift_count')
            ->groupBy('biz_sales_order.creator_user_id')
            ->get()
            ->keyBy('creator_user_id');

        // 操作记录统计 - 按用户分组
        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('operator_user_id, COUNT(DISTINCT customer_id) as operation_customer_count')
            ->groupBy('operator_user_id')
            ->get()
            ->keyBy('operator_user_id');

        // 按用户汇总支付方式
        $paymentByUser = [];
        foreach ($paymentStats as $ps) {
            $uid = $ps->creator_user_id;
            if (!isset($paymentByUser[$uid])) {
                $paymentByUser[$uid] = ['cash' => 0, 'card' => 0];
            }
            if ($ps->payment_method === 'cash') {
                $paymentByUser[$uid]['cash'] = round((float)$ps->amount, 2);
            } elseif ($ps->payment_method === 'card') {
                $paymentByUser[$uid]['card'] = round((float)$ps->amount, 2);
            }
        }

        // 查询用户信息
        $users = SysUser::whereIn('user_id', $userIds)
            ->where('del_flag', '0')
            ->select(['user_id', 'nick_name', 'dept_id'])
            ->get()
            ->keyBy('user_id');

        $deptIds = $users->pluck('dept_id')->unique()->filter()->toArray();
        $depts = SysDept::whereIn('dept_id', $deptIds)->pluck('dept_name', 'dept_id')->toArray();

        $result = [];
        foreach ($userIds as $uid) {
            $user = $users->get($uid);
            if (!$user) continue;

            $deal = $dealStats->get($uid);
            $payment = $paymentByUser[$uid] ?? ['cash' => 0, 'card' => 0];
            $giftCount = $giftCountStats->get($uid);
            $op = $operationStats->get($uid);

            // 只显示有数据的用户
            $hasData = $deal || isset($paymentByUser[$uid]) || $giftCount || $op;
            if (!$hasData) continue;

            $result[] = [
                'userId' => $uid,
                'userName' => $user->nick_name,
                'deptName' => $depts[$user->dept_id] ?? '',
                'dealCustomerCount' => $deal ? (int)$deal->deal_customer_count : 0,
                'dealAmount' => $deal ? round((float)$deal->deal_amount, 2) : 0,
                'paidAmount' => $deal ? round((float)$deal->paid_amount, 2) : 0,
                'owedAmount' => $deal ? round((float)$deal->owed_amount, 2) : 0,
                'cashAmount' => $payment['cash'],
                'cardAmount' => $payment['card'],
                'giftCount' => $giftCount ? (int)$giftCount->gift_count : 0,
                'operationCustomerCount' => $op ? (int)$op->operation_customer_count : 0,
            ];
        }

        usort($result, function ($a, $b) {
            return $b['dealAmount'] <=> $a['dealAmount'];
        });

        return $result;
    }

    /**
     * 按企业统计业绩
     */
    public static function getEnterprisePerformance($loginUser, $startDate, $endDate)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        $dealStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('enterprise_id, COUNT(DISTINCT customer_id) as deal_customer_count, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->groupBy('enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('biz_sales_order.enterprise_id, biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as amount')
            ->groupBy('biz_sales_order.enterprise_id', 'biz_order_item.payment_method')
            ->get();

        $giftCountStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->where('biz_order_item.payment_method', 'gift')
            ->selectRaw('biz_sales_order.enterprise_id, COUNT(*) as gift_count')
            ->groupBy('biz_sales_order.enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $paymentByEnterprise = [];
        foreach ($paymentStats as $ps) {
            $eid = $ps->enterprise_id;
            if (!isset($paymentByEnterprise[$eid])) {
                $paymentByEnterprise[$eid] = ['cash' => 0, 'card' => 0];
            }
            if ($ps->payment_method === 'cash') {
                $paymentByEnterprise[$eid]['cash'] = round((float)$ps->amount, 2);
            } elseif ($ps->payment_method === 'card') {
                $paymentByEnterprise[$eid]['card'] = round((float)$ps->amount, 2);
            }
        }

        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('enterprise_id, COUNT(DISTINCT customer_id) as operation_customer_count')
            ->groupBy('enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $allEnterpriseIds = $dealStats->keys()
            ->merge($operationStats->keys())
            ->unique()
            ->values()
            ->toArray();

        if (empty($allEnterpriseIds)) {
            return [];
        }

        $enterprises = BizEnterprise::whereIn('enterprise_id', $allEnterpriseIds)
            ->select(['enterprise_id', 'enterprise_name'])
            ->get()
            ->keyBy('enterprise_id');

        $result = [];
        foreach ($allEnterpriseIds as $eid) {
            $deal = $dealStats->get($eid);
            $op = $operationStats->get($eid);
            $enterprise = $enterprises->get($eid);
            $payment = $paymentByEnterprise[$eid] ?? ['cash' => 0, 'card' => 0];
            $giftCountItem = $giftCountStats->get($eid);

            $result[] = [
                'enterpriseId' => $eid,
                'enterpriseName' => $enterprise ? $enterprise->enterprise_name : ($deal ? ($deal->enterprise_name ?? '未知企业') : '未知企业'),
                'dealCustomerCount' => $deal ? (int)$deal->deal_customer_count : 0,
                'dealAmount' => $deal ? round((float)$deal->deal_amount, 2) : 0,
                'paidAmount' => $deal ? round((float)$deal->paid_amount, 2) : 0,
                'owedAmount' => $deal ? round((float)$deal->owed_amount, 2) : 0,
                'cashAmount' => $payment['cash'],
                'cardAmount' => $payment['card'],
                'giftCount' => $giftCountItem ? (int)$giftCountItem->gift_count : 0,
                'operationCustomerCount' => $op ? (int)$op->operation_customer_count : 0,
            ];
        }

        usort($result, function ($a, $b) {
            return $b['dealAmount'] <=> $a['dealAmount'];
        });

        return $result;
    }

    /**
     * 按门店统计业绩
     */
    public static function getStorePerformance($loginUser, $startDate, $endDate)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        $dealStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('store_id, enterprise_id, COUNT(DISTINCT customer_id) as deal_customer_count, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->groupBy('store_id', 'enterprise_id')
            ->get();

        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('biz_sales_order.store_id, biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as amount')
            ->groupBy('biz_sales_order.store_id', 'biz_order_item.payment_method')
            ->get();

        $giftCountStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->where('biz_order_item.payment_method', 'gift')
            ->selectRaw('biz_sales_order.store_id, COUNT(*) as gift_count')
            ->groupBy('biz_sales_order.store_id')
            ->get()
            ->keyBy('store_id');

        $paymentByStore = [];
        foreach ($paymentStats as $ps) {
            $sid = $ps->store_id;
            if (!isset($paymentByStore[$sid])) {
                $paymentByStore[$sid] = ['cash' => 0, 'card' => 0];
            }
            if ($ps->payment_method === 'cash') {
                $paymentByStore[$sid]['cash'] = round((float)$ps->amount, 2);
            } elseif ($ps->payment_method === 'card') {
                $paymentByStore[$sid]['card'] = round((float)$ps->amount, 2);
            }
        }

        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('store_id, COUNT(DISTINCT customer_id) as operation_customer_count')
            ->groupBy('store_id')
            ->get()
            ->keyBy('store_id');

        // 汇总门店数据
        $storeData = [];
        foreach ($dealStats as $ds) {
            $sid = $ds->store_id;
            if (!isset($storeData[$sid])) {
                $storeData[$sid] = [
                    'enterprise_id' => $ds->enterprise_id,
                    'deal_customer_count' => 0,
                    'deal_amount' => 0,
                    'paid_amount' => 0,
                    'owed_amount' => 0,
                ];
            }
            $storeData[$sid]['deal_customer_count'] += (int)$ds->deal_customer_count;
            $storeData[$sid]['deal_amount'] += round((float)$ds->deal_amount, 2);
            $storeData[$sid]['paid_amount'] += round((float)$ds->paid_amount, 2);
            $storeData[$sid]['owed_amount'] += round((float)$ds->owed_amount, 2);
        }

        $allStoreIds = array_keys($storeData);
        // 也加入操作记录中的门店
        foreach ($operationStats as $sid => $op) {
            if (!in_array($sid, $allStoreIds)) {
                $allStoreIds[] = $sid;
                $storeData[$sid] = [
                    'enterprise_id' => null,
                    'deal_customer_count' => 0,
                    'deal_amount' => 0,
                    'paid_amount' => 0,
                    'owed_amount' => 0,
                ];
            }
        }

        if (empty($allStoreIds)) {
            return [];
        }

        $stores = BizStore::whereIn('store_id', $allStoreIds)
            ->select(['store_id', 'store_name', 'enterprise_name'])
            ->get()
            ->keyBy('store_id');

        $result = [];
        foreach ($allStoreIds as $sid) {
            $data = $storeData[$sid] ?? null;
            $store = $stores->get($sid);
            $payment = $paymentByStore[$sid] ?? ['cash' => 0, 'card' => 0];
            $giftCount = $giftCountStats->get($sid);
            $op = $operationStats->get($sid);

            $result[] = [
                'storeId' => $sid,
                'storeName' => $store ? $store->store_name : '未知门店',
                'enterpriseName' => $store ? $store->enterprise_name : '',
                'dealCustomerCount' => $data ? $data['deal_customer_count'] : 0,
                'dealAmount' => $data ? round($data['deal_amount'], 2) : 0,
                'paidAmount' => $data ? round($data['paid_amount'], 2) : 0,
                'owedAmount' => $data ? round($data['owed_amount'], 2) : 0,
                'cashAmount' => $payment['cash'],
                'cardAmount' => $payment['card'],
                'giftCount' => $giftCount ? (int)$giftCount->gift_count : 0,
                'operationCustomerCount' => $op ? (int)$op->operation_customer_count : 0,
            ];
        }

        usort($result, function ($a, $b) {
            return $b['dealAmount'] <=> $a['dealAmount'];
        });

        return $result;
    }
}
