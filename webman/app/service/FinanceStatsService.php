<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use support\Db;

/**
 * 财务统计服务
 *
 * 提供应收账款、账龄分析、支付方式占比、回款率统计
 * 所有方法统一支持 $filter 参数（enterprise_id/store_id/creator_user_id/date_start/date_end）
 */
class FinanceStatsService
{
    /**
     * 应收账款统计（按企业/门店分组）
     *
     * @param array $filter 筛选条件
     * @return array 含 list（明细）和 total（合计）
     */
    public static function getReceivableStats($filter = [])
    {
        $query = BizSalesOrder::where('owed_amount', '>', 0)
            ->whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2']);

        self::applyFilter($query, $filter);

        $list = $query->selectRaw('enterprise_id, enterprise_name, store_id, store_name, creator_user_id, creator_user_name,
                                   SUM(owed_amount) as owed_amount,
                                   SUM(deal_amount) as deal_amount,
                                   SUM(paid_amount) as paid_amount,
                                   MAX(create_time) as last_order_time,
                                   COUNT(*) as order_count')
            ->groupBy('enterprise_id', 'enterprise_name', 'store_id', 'store_name', 'creator_user_id', 'creator_user_name')
            ->orderBy('owed_amount', 'desc')
            ->get()
            ->toArray();

        $totalOwed = 0;
        $totalDeal = 0;
        $totalPaid = 0;
        foreach ($list as $item) {
            $totalOwed += floatval($item['owed_amount']);
            $totalDeal += floatval($item['deal_amount']);
            $totalPaid += floatval($item['paid_amount']);
        }

        return [
            'list' => $list,
            'total' => [
                'owed_amount' => round($totalOwed, 2),
                'deal_amount' => round($totalDeal, 2),
                'paid_amount' => round($totalPaid, 2),
                'order_count' => count($list),
            ],
        ];
    }

    /**
     * 账龄分析（30/60/90/90+天）
     *
     * @param array $filter 筛选条件
     * @return array 含分布统计和明细列表
     */
    public static function getAgingAnalysis($filter = [])
    {
        $query = BizSalesOrder::where('owed_amount', '>', 0)
            ->whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2']);

        self::applyFilter($query, $filter);

        $list = $query->selectRaw('order_id, order_no, customer_id, customer_name, enterprise_name, store_name,
                                   creator_user_name, owed_amount, deal_amount, paid_amount, create_time')
            ->orderBy('create_time', 'asc')
            ->get()
            ->toArray();

        $now = time();
        $buckets = [
            ['range' => '30天内', 'min' => 0, 'max' => 30, 'count' => 0, 'amount' => 0],
            ['range' => '30-60天', 'min' => 30, 'max' => 60, 'count' => 0, 'amount' => 0],
            ['range' => '60-90天', 'min' => 60, 'max' => 90, 'count' => 0, 'amount' => 0],
            ['range' => '90天以上', 'min' => 90, 'max' => 9999, 'count' => 0, 'amount' => 0],
        ];

        foreach ($list as &$item) {
            $days = (int) floor(($now - strtotime($item['create_time'])) / 86400);
            $item['aging_days'] = $days;
            foreach ($buckets as &$bucket) {
                if ($days >= $bucket['min'] && $days < $bucket['max']) {
                    $bucket['count']++;
                    $bucket['amount'] += floatval($item['owed_amount']);
                    break;
                }
            }
        }

        foreach ($buckets as &$bucket) {
            $bucket['amount'] = round($bucket['amount'], 2);
        }

        return [
            'distribution' => $buckets,
            'list' => $list,
        ];
    }

    /**
     * 支付方式统计（现金/耗卡/赠送占比）
     *
     * @param array $filter 筛选条件
     * @return array 含分布统计
     */
    public static function getPaymentMethodStats($filter = [])
    {
        $query = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2']);

        self::applyFilter($query, $filter, 'biz_sales_order');

        $list = $query->selectRaw('biz_order_item.payment_method,
                                    SUM(biz_order_item.deal_amount) as deal_amount,
                                    SUM(biz_order_item.paid_amount) as paid_amount,
                                    COUNT(*) as item_count')
            ->groupBy('biz_order_item.payment_method')
            ->get()
            ->toArray();

        $methodLabels = [
            'cash' => '现金',
            'card' => '耗卡',
            'gift' => '赠送',
        ];

        $result = [];
        $totalAmount = 0;
        foreach ($list as $item) {
            $method = $item['payment_method'] ?: 'cash';
            $result[] = [
                'method' => $method,
                'label' => $methodLabels[$method] ?? $method,
                'deal_amount' => round(floatval($item['deal_amount']), 2),
                'paid_amount' => round(floatval($item['paid_amount']), 2),
                'item_count' => (int) $item['item_count'],
            ];
            $totalAmount += floatval($item['deal_amount']);
        }

        // 计算占比
        foreach ($result as &$item) {
            $item['rate'] = $totalAmount > 0 ? round(($item['deal_amount'] / $totalAmount) * 100, 2) : 0;
        }

        return [
            'list' => $result,
            'total_amount' => round($totalAmount, 2),
        ];
    }

    /**
     * 回款率统计（实付/成交）
     *
     * @param array $filter 筛选条件
     * @return array 含总体回款率和按企业分组列表
     */
    public static function getCollectionRate($filter = [])
    {
        $query = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2']);

        self::applyFilter($query, $filter);

        // 按企业分组
        $list = $query->selectRaw('enterprise_id, enterprise_name,
                                    SUM(deal_amount) as deal_amount,
                                    SUM(paid_amount) as paid_amount,
                                    SUM(owed_amount) as owed_amount,
                                    COUNT(*) as order_count')
            ->groupBy('enterprise_id', 'enterprise_name')
            ->orderBy('deal_amount', 'desc')
            ->get()
            ->toArray();

        $totalDeal = 0;
        $totalPaid = 0;
        $totalOwed = 0;
        foreach ($list as &$item) {
            $deal = floatval($item['deal_amount']);
            $paid = floatval($item['paid_amount']);
            $item['collection_rate'] = $deal > 0 ? round(($paid / $deal) * 100, 2) : 0;
            $item['deal_amount'] = round($deal, 2);
            $item['paid_amount'] = round($paid, 2);
            $item['owed_amount'] = round(floatval($item['owed_amount']), 2);
            $totalDeal += $deal;
            $totalPaid += $paid;
            $totalOwed += floatval($item['owed_amount']);
        }

        return [
            'list' => $list,
            'total' => [
                'deal_amount' => round($totalDeal, 2),
                'paid_amount' => round($totalPaid, 2),
                'owed_amount' => round($totalOwed, 2),
                'collection_rate' => $totalDeal > 0 ? round(($totalPaid / $totalDeal) * 100, 2) : 0,
            ],
        ];
    }

    /**
     * 应用筛选条件（私有方法，复用）
     *
     * @param mixed $query 查询构造器
     * @param array $filter 筛选条件
     * @param string $prefix 表前缀（join 时使用）
     */
    private static function applyFilter($query, $filter, $prefix = '')
    {
        $field = function ($name) use ($prefix) {
            return $prefix ? "{$prefix}.{$name}" : $name;
        };

        if (!empty($filter['enterprise_id'])) {
            $query->where($field('enterprise_id'), $filter['enterprise_id']);
        }
        if (!empty($filter['store_id'])) {
            $query->where($field('store_id'), $filter['store_id']);
        }
        if (!empty($filter['creator_user_id'])) {
            $query->where($field('creator_user_id'), $filter['creator_user_id']);
        }
        if (!empty($filter['date_start'])) {
            $query->where($field('create_time'), '>=', $filter['date_start'] . ' 00:00:00');
        }
        if (!empty($filter['date_end'])) {
            $query->where($field('create_time'), '<=', $filter['date_end'] . ' 23:59:59');
        }
        // 数据范围过滤：非管理员仅可见可见范围内的业务员数据
        if (!empty($filter['login_user']) && !$filter['login_user']->isAdmin()) {
            DataScopeService::applyUserScope($query, $filter['login_user'], $field('creator_user_id'), 'user');
        }
    }
}
