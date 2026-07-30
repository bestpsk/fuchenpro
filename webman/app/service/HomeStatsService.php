<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizOperationRecord;
use app\model\BizStockPrepare;
use app\model\BizInventory;

class HomeStatsService
{
    /**
     * 获取待办事项统计
     *
     * @param mixed $loginUser 当前登录用户
     * @return array 待办事项数组
     */
    public static function getTodoItems($loginUser)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        // 待确认订单数（order_status=0 且为开单/还款类型）
        $pendingOrderCount = BizSalesOrder::where('order_status', '0')
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->count();

        // 待出库备货数（status=0 待出库 或 status=1 部分出库）
        $pendingPrepareCount = BizStockPrepare::whereIn('status', ['0', '1'])
            ->count();

        // 库存预警数（库存数量 <= 预警数量 且 预警数量 > 0）
        $inventoryWarnCount = BizInventory::where('warn_qty', '>', 0)
            ->whereColumn('quantity', '<=', 'warn_qty')
            ->count();

        return [
            ['key' => 'pendingOrder', 'label' => '待确认订单', 'count' => $pendingOrderCount, 'path' => '/business/order'],
            ['key' => 'pendingPrepare', 'label' => '待出库备货', 'count' => $pendingPrepareCount, 'path' => '/business/stockPrepare'],
            ['key' => 'inventoryWarn', 'label' => '库存预警', 'count' => $inventoryWarnCount, 'path' => '/wms/inventory'],
        ];
    }

    /**
     * 获取近N天销售趋势数据
     *
     * @param mixed $loginUser 当前登录用户
     * @param int $days 天数（默认7天）
     * @return array ['dates' => ['2026-07-01', ...], 'amounts' => [1234.56, ...], 'orderCounts' => [12, ...]]
     */
    public static function getSalesTrend($loginUser, $days = 7, $startDate = null, $endDate = null)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        // 计算日期范围
        if ($startDate && $endDate) {
            $start = $startDate . ' 00:00:00';
            $end = $endDate . ' 23:59:59';
        } else {
            $endDate = date('Y-m-d');
            $startDate = date('Y-m-d', strtotime("-" . ($days - 1) . " days"));
            $start = $startDate . ' 00:00:00';
            $end = $endDate . ' 23:59:59';
        }

        // 查询每天的销售金额和订单数
        $dailyStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->selectRaw('DATE(create_time) as stat_date, SUM(deal_amount) as total_amount, COUNT(*) as order_count')
            ->groupBy('stat_date')
            ->pluck('total_amount', 'stat_date')
            ->toArray();

        $dailyCounts = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->selectRaw('DATE(create_time) as stat_date, COUNT(*) as order_count')
            ->groupBy('stat_date')
            ->pluck('order_count', 'stat_date')
            ->toArray();

        // 填充所有日期（包括没有数据的日期）
        $dates = [];
        $amounts = [];
        $orderCounts = [];
        $startTs = strtotime($startDate);
        $endTs = strtotime($endDate);
        $dayCount = (int) (($endTs - $startTs) / 86400);
        for ($i = 0; $i <= $dayCount; $i++) {
            $date = date('Y-m-d', strtotime($startDate . " +{$i} days"));
            $dates[] = $date;
            $amounts[] = isset($dailyStats[$date]) ? round(floatval($dailyStats[$date]), 2) : 0;
            $orderCounts[] = isset($dailyCounts[$date]) ? intval($dailyCounts[$date]) : 0;
        }

        return [
            'dates' => $dates,
            'amounts' => $amounts,
            'orderCounts' => $orderCounts,
        ];
    }

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

        // 合并4次 BizSalesOrder 查询为1次聚合查询（原为 dealCustomers/dealAmount/paidAmount/owedAmount 各一次）
        $orderStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $start)
            ->where('create_time', '<=', $end)
            ->selectRaw('COUNT(DISTINCT customer_id) as deal_customers, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->first();

        $dealCustomers = $orderStats->deal_customers ?? 0;
        $dealAmount = floatval($orderStats->deal_amount ?? 0);
        $paidAmount = floatval($orderStats->paid_amount ?? 0);
        $owedAmount = floatval($orderStats->owed_amount ?? 0);

        // 合并3次 BizOrderItem JOIN 查询为1次分组聚合查询（原为 cashAmount/cardAmount/giftCount 各一次）
        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $start)
            ->where('biz_sales_order.create_time', '<=', $end)
            ->whereIn('biz_order_item.payment_method', ['cash', 'card', 'gift'])
            ->selectRaw('biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as total_amount, COUNT(*) as item_count')
            ->groupBy('biz_order_item.payment_method')
            ->get()
            ->keyBy('payment_method');

        $cashAmount = floatval($paymentStats->get('cash')->total_amount ?? 0);
        $cardAmount = floatval($paymentStats->get('card')->total_amount ?? 0);
        $giftCount = intval($paymentStats->get('gift')->item_count ?? 0);

        // 合并2次 BizOperationRecord 查询为1次聚合查询（原为 operationCustomers/operationAmount 各一次）
        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('COUNT(DISTINCT customer_id) as operation_customers, COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as total_amount')
            ->first();

        $operationCustomers = $operationStats->operation_customers ?? 0;
        $operationAmount = floatval($operationStats->total_amount ?? 0);

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
