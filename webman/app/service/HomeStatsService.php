<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizOperationRecord;

class HomeStatsService
{
    public static function getTodayStats($loginUser, $startDate = null, $endDate = null)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        $today = date('Y-m-d');
        $monthStart = date('Y-m-01');
        $monthEnd = date('Y-m-t');
        $yearStart = date('Y-01-01');
        $yearEnd = date('Y-12-31');

        $todayStats = self::computeRangeStats($userIds, $today, $today);
        $monthStats = self::computeRangeStats($userIds, $monthStart, $monthEnd);
        $yearStats = self::computeRangeStats($userIds, $yearStart, $yearEnd);

        $result = [
            'dealCustomerCount' => ['today' => $todayStats['dealCustomerCount'], 'month' => $monthStats['dealCustomerCount'], 'year' => $yearStats['dealCustomerCount']],
            'dealAmount' => ['today' => $todayStats['dealAmount'], 'month' => $monthStats['dealAmount'], 'year' => $yearStats['dealAmount']],
            'paidAmount' => ['today' => $todayStats['paidAmount'], 'month' => $monthStats['paidAmount'], 'year' => $yearStats['paidAmount']],
            'owedAmount' => ['today' => $todayStats['owedAmount'], 'month' => $monthStats['owedAmount'], 'year' => $yearStats['owedAmount']],
            'cashAmount' => ['today' => $todayStats['cashAmount'], 'month' => $monthStats['cashAmount'], 'year' => $yearStats['cashAmount']],
            'cardAmount' => ['today' => $todayStats['cardAmount'], 'month' => $monthStats['cardAmount'], 'year' => $yearStats['cardAmount']],
            'giftCount' => ['today' => $todayStats['giftCount'], 'month' => $monthStats['giftCount'], 'year' => $yearStats['giftCount']],
            'operationCustomerCount' => ['today' => $todayStats['operationCustomerCount'], 'month' => $monthStats['operationCustomerCount'], 'year' => $yearStats['operationCustomerCount']],
            'operationAmount' => ['today' => $todayStats['operationAmount'], 'month' => $monthStats['operationAmount'], 'year' => $yearStats['operationAmount']],
        ];

        if ($startDate && $endDate) {
            $customStats = self::computeRangeStats($userIds, $startDate, $endDate);
            $result['dealCustomerCount']['custom'] = $customStats['dealCustomerCount'];
            $result['dealAmount']['custom'] = $customStats['dealAmount'];
            $result['paidAmount']['custom'] = $customStats['paidAmount'];
            $result['owedAmount']['custom'] = $customStats['owedAmount'];
            $result['cashAmount']['custom'] = $customStats['cashAmount'];
            $result['cardAmount']['custom'] = $customStats['cardAmount'];
            $result['giftCount']['custom'] = $customStats['giftCount'];
            $result['operationCustomerCount']['custom'] = $customStats['operationCustomerCount'];
            $result['operationAmount']['custom'] = $customStats['operationAmount'];
        }

        return $result;
    }

    /**
     * 计算指定日期区间内的全部业务统计指标
     *
     * @param array $userIds 可见用户ID集合
     * @param string $startDate 开始日期 Y-m-d
     * @param string $endDate 结束日期 Y-m-d
     * @return array 包含 dealCustomerCount/dealAmount/paidAmount/owedAmount/cashAmount/cardAmount/giftCount/operationCustomerCount/operationAmount 的数组
     */
    private static function computeRangeStats($userIds, $startDate, $endDate)
    {
        $start = $startDate . ' 00:00:00';
        $end = $endDate . ' 23:59:59';

        $dealCustomers = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->distinct()->count('customer_id');

        $dealAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->sum('deal_amount');

        $paidAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->sum('paid_amount');

        $owedAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->sum('owed_amount');

        $cashAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $start)
            ->where('biz_sales_order.create_time', '<=', $end)
            ->where('biz_order_item.payment_method', 'cash')
            ->sum('biz_order_item.deal_amount');

        $cardAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $start)
            ->where('biz_sales_order.create_time', '<=', $end)
            ->where('biz_order_item.payment_method', 'card')
            ->sum('biz_order_item.deal_amount');

        $giftCount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $start)
            ->where('biz_sales_order.create_time', '<=', $end)
            ->where('biz_order_item.payment_method', 'gift')
            ->count();

        $operationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->distinct()->count('customer_id');

        $operationAmount = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as total')
            ->value('total');

        return [
            'dealCustomerCount' => $dealCustomers,
            'dealAmount' => $dealAmount,
            'paidAmount' => $paidAmount,
            'owedAmount' => $owedAmount,
            'cashAmount' => $cashAmount,
            'cardAmount' => $cardAmount,
            'giftCount' => $giftCount,
            'operationCustomerCount' => $operationCustomers,
            'operationAmount' => $operationAmount,
        ];
    }
}
