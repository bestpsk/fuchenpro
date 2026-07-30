<?php

namespace app\service;

use app\model\BizCustomer;
use app\model\BizSalesOrder;
use support\Db;

/**
 * 客户统计服务
 */
class CustomerStatsService
{
    /**
     * 客户新增趋势（按月统计）
     *
     * @param int $months 月数（默认12个月）
     * @return array 月度新增趋势
     */
    public static function getNewCustomerTrend($months = 12)
    {
        $startDate = date('Y-m-01', strtotime("-" . ($months - 1) . " months"));
        $endDate = date('Y-m-t');

        $list = BizCustomer::where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('DATE_FORMAT(create_time, "%Y-%m") as stat_month, COUNT(*) as new_count')
            ->groupBy('stat_month')
            ->pluck('new_count', 'stat_month')
            ->toArray();

        $result = [];
        for ($i = $months - 1; $i >= 0; $i--) {
            $month = date('Y-m', strtotime("-" . $i . " months"));
            $result[] = [
                'month' => $month,
                'new_count' => $list[$month] ?? 0,
            ];
        }

        return $result;
    }

    /**
     * 客户消费金额分布
     *
     * @param string $startDate 开始日期
     * @param string $endDate 结束日期
     * @return array 高/中/低价值客户分布
     */
    public static function getCustomerValueDistribution($startDate = null, $endDate = null)
    {
        $list = self::getCustomerValueList($startDate, $endDate);

        $highValue = 0;  // 10000+
        $midValue = 0;   // 1000-10000
        $lowValue = 0;   // <1000
        $totalCustomers = count($list);
        $totalAmount = 0;

        foreach ($list as $item) {
            $amount = floatval($item['total_amount']);
            $totalAmount += $amount;
            if ($amount >= 10000) $highValue++;
            elseif ($amount >= 1000) $midValue++;
            else $lowValue++;
        }

        return [
            'total_customers' => $totalCustomers,
            'total_amount' => round($totalAmount, 2),
            'high_value' => $highValue,
            'mid_value' => $midValue,
            'low_value' => $lowValue,
            'high_threshold' => 10000,
            'mid_threshold' => 1000,
        ];
    }

    /**
     * 按价值层级获取客户明细列表（支持下钻查看）
     *
     * @param string $level 层级：high/mid/low
     * @param string $startDate 开始日期（可选）
     * @param string $endDate 结束日期（可选）
     * @return array 客户明细列表
     */
    public static function getCustomerListByValueLevel($level, $startDate = null, $endDate = null)
    {
        $list = self::getCustomerValueList($startDate, $endDate);

        $filtered = [];
        foreach ($list as $item) {
            $amount = floatval($item['total_amount']);
            $match = false;
            if ($level === 'high' && $amount >= 10000) $match = true;
            elseif ($level === 'mid' && $amount >= 1000 && $amount < 10000) $match = true;
            elseif ($level === 'low' && $amount < 1000) $match = true;

            if ($match) {
                $filtered[] = $item;
            }
        }

        // 按累计消费金额降序
        usort($filtered, function ($a, $b) {
            return floatval($b['total_amount']) <=> floatval($a['total_amount']);
        });

        return $filtered;
    }

    /**
     * 获取客户消费汇总列表（私有，复用方法）
     *
     * @param string $startDate
     * @param string $endDate
     * @return array
     */
    private static function getCustomerValueList($startDate = null, $endDate = null)
    {
        $query = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->selectRaw('customer_id, customer_name, SUM(deal_amount) as total_amount, COUNT(*) as order_count, MAX(create_time) as last_order_time');

        if ($startDate && $endDate) {
            $query->where('create_time', '>=', $startDate . ' 00:00:00')
                  ->where('create_time', '<=', $endDate . ' 23:59:59');
        }

        $list = $query->groupBy('customer_id', 'customer_name')->get()->toArray();

        // 关联客户表获取联系电话、状态
        $customerIds = array_column($list, 'customer_id');
        $customers = [];
        if (!empty($customerIds)) {
            $customers = BizCustomer::whereIn('customer_id', $customerIds)
                ->select(['customer_id', 'phone', 'status'])
                ->get()
                ->keyBy('customer_id')
                ->toArray();
        }

        foreach ($list as &$item) {
            $cust = $customers[$item['customer_id']] ?? null;
            $item['phone'] = $cust['phone'] ?? '';
            $item['status'] = $cust['status'] ?? '0';
            $item['total_amount'] = round(floatval($item['total_amount']), 2);
        }

        return $list;
    }

    /**
     * 客户流失预警（90天未下单）
     *
     * @param int $days 未下单天数（默认90天）
     * @return array 流失预警客户列表
     */
    public static function getChurnWarning($days = 90)
    {
        $cutoffDate = date('Y-m-d', strtotime("-{$days} days"));

        // 查询所有有订单的客户最后一次下单时间
        $lastOrders = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->selectRaw('customer_id, customer_name, MAX(create_time) as last_order_time, SUM(deal_amount) as total_amount, COUNT(*) as order_count')
            ->groupBy('customer_id', 'customer_name')
            ->having('last_order_time', '<', $cutoffDate . ' 23:59:59')
            ->orderBy('last_order_time', 'asc')
            ->limit(50)
            ->get()
            ->toArray();

        // 关联客户表获取联系电话、状态
        $customerIds = array_column($lastOrders, 'customer_id');
        $customers = [];
        if (!empty($customerIds)) {
            $customers = BizCustomer::whereIn('customer_id', $customerIds)
                ->select(['customer_id', 'phone', 'status'])
                ->get()
                ->keyBy('customer_id')
                ->toArray();
        }

        foreach ($lastOrders as &$item) {
            $cust = $customers[$item['customer_id']] ?? null;
            $item['phone'] = $cust['phone'] ?? '';
            $item['status'] = $cust['status'] ?? '0';
            $item['days_since_order'] = (int) ((time() - strtotime($item['last_order_time'])) / 86400);
            $item['total_amount'] = round(floatval($item['total_amount']), 2);
        }

        return $lastOrders;
    }

    /**
     * 客户消费频次分布
     *
     * @param string $startDate 开始日期
     * @param string $endDate 结束日期
     * @return array 频次分布
     */
    public static function getOrderFrequencyDistribution($startDate = null, $endDate = null)
    {
        $query = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2']);

        if ($startDate && $endDate) {
            $query->where('create_time', '>=', $startDate . ' 00:00:00')
                  ->where('create_time', '<=', $endDate . ' 23:59:59');
        }

        $list = $query->selectRaw('customer_id, COUNT(*) as order_count')
            ->groupBy('customer_id')
            ->pluck('order_count')
            ->toArray();

        $oneTime = 0;
        $twoToFive = 0;
        $sixToTen = 0;
        $overTen = 0;

        foreach ($list as $count) {
            if ($count == 1) $oneTime++;
            elseif ($count <= 5) $twoToFive++;
            elseif ($count <= 10) $sixToTen++;
            else $overTen++;
        }

        return [
            'total_customers' => count($list),
            'one_time' => $oneTime,
            'two_to_five' => $twoToFive,
            'six_to_ten' => $sixToTen,
            'over_ten' => $overTen,
        ];
    }
}
