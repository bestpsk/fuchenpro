<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizProduct;
use support\Db;

/**
 * 货品统计服务
 *
 * 提供货品销售排行、取消率、利润分析（双利润率展示）
 */
class ProductStatsService
{
    /**
     * 货品销售排行 TOP N
     *
     * @param int $limit 返回数量（默认20）
     * @param string $startDate 开始日期
     * @param string $endDate 结束日期
     * @return array 销售排行列表
     */
    public static function getSalesRanking($limit = 20, $startDate = null, $endDate = null)
    {
        $query = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->where('biz_order_item.is_our_operation', 1)
            ->where('biz_order_item.product_name', 'not like', '还款-%');

        if ($startDate && $endDate) {
            $query->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                  ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59');
        }

        $list = $query->selectRaw('biz_order_item.product_name,
                                    SUM(biz_order_item.quantity) as total_qty,
                                    SUM(biz_order_item.deal_amount) as total_amount,
                                    AVG(biz_order_item.unit_price) as avg_price,
                                    COUNT(*) as order_count')
            ->groupBy('biz_order_item.product_name')
            ->orderBy('total_amount', 'desc')
            ->limit($limit)
            ->get()
            ->toArray();

        foreach ($list as &$item) {
            $item['total_qty'] = (int) $item['total_qty'];
            $item['total_amount'] = round(floatval($item['total_amount']), 2);
            $item['avg_price'] = round(floatval($item['avg_price']), 2);
        }

        return $list;
    }

    /**
     * 货品取消率统计（基于已取消订单）
     *
     * @param string $startDate
     * @param string $endDate
     * @return array 含总览和按货品明细
     */
    public static function getCancelRate($startDate = null, $endDate = null)
    {
        // 已成交订单（status 1/2/3）的货品统计
        $queryDeal = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->where('biz_order_item.is_our_operation', 1)
            ->where('biz_order_item.product_name', 'not like', '还款-%');

        if ($startDate && $endDate) {
            $queryDeal->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                      ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59');
        }

        $dealList = $queryDeal->selectRaw('biz_order_item.product_name,
                                             SUM(biz_order_item.quantity) as deal_qty,
                                             COUNT(*) as deal_count')
            ->groupBy('biz_order_item.product_name')
            ->get()
            ->keyBy('product_name')
            ->toArray();

        // 已取消订单（status 4）的货品统计
        $queryCancel = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->where('biz_sales_order.order_status', '4')
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->where('biz_order_item.is_our_operation', 1)
            ->where('biz_order_item.product_name', 'not like', '还款-%');

        if ($startDate && $endDate) {
            $queryCancel->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                        ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59');
        }

        $cancelList = $queryCancel->selectRaw('biz_order_item.product_name,
                                                 SUM(biz_order_item.quantity) as cancel_qty,
                                                 COUNT(*) as cancel_count')
            ->groupBy('biz_order_item.product_name')
            ->get()
            ->keyBy('product_name')
            ->toArray();

        $result = [];
        foreach ($dealList as $name => $deal) {
            $cancel = $cancelList[$name] ?? ['cancel_qty' => 0, 'cancel_count' => 0];
            $dealQty = (int) $deal['deal_qty'];
            $cancelQty = (int) $cancel['cancel_qty'];
            $totalQty = $dealQty + $cancelQty;
            $result[] = [
                'product_name' => $name,
                'deal_qty' => $dealQty,
                'cancel_qty' => $cancelQty,
                'total_qty' => $totalQty,
                'cancel_rate' => $totalQty > 0 ? round(($cancelQty / $totalQty) * 100, 2) : 0,
            ];
        }

        // 按取消率降序
        usort($result, function ($a, $b) {
            return $b['cancel_rate'] <=> $a['cancel_rate'];
        });

        $totalDeal = array_sum(array_column($result, 'deal_qty'));
        $totalCancel = array_sum(array_column($result, 'cancel_qty'));
        $grandTotal = $totalDeal + $totalCancel;

        return [
            'list' => $result,
            'total' => [
                'deal_qty' => $totalDeal,
                'cancel_qty' => $totalCancel,
                'total_qty' => $grandTotal,
                'cancel_rate' => $grandTotal > 0 ? round(($totalCancel / $grandTotal) * 100, 2) : 0,
            ],
        ];
    }

    /**
     * 货品利润分析（双利润率展示）
     *
     * 同时返回：
     * - profit_actual / profit_rate_actual：基于订单实际售价（unit_price）
     * - profit_listed / profit_rate_listed：基于货品挂牌价（sale_price）
     *
     * @param string $startDate
     * @param string $endDate
     * @return array 利润分析列表
     */
    public static function getProfitAnalysis($startDate = null, $endDate = null)
    {
        // 注：biz_order_item 表无 product_id 字段，只能按 product_name JOIN biz_product。
        // 若货品改名，历史订单利润分析会失真。后续如新增 product_id 字段可改为按 ID 关联。
        $query = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->leftJoin('biz_product', 'biz_order_item.product_name', '=', 'biz_product.product_name')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->where('biz_order_item.is_our_operation', 1)
            ->where('biz_order_item.payment_method', '!=', 'gift')
            ->where('biz_order_item.product_name', 'not like', '还款-%');

        if ($startDate && $endDate) {
            $query->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                  ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59');
        }

        $list = $query->selectRaw('biz_order_item.product_name,
                                    biz_product.product_code,
                                    biz_product.spec,
                                    biz_product.purchase_price,
                                    biz_product.sale_price,
                                    SUM(biz_order_item.quantity) as total_qty,
                                    SUM(biz_order_item.deal_amount) as total_revenue,
                                    AVG(biz_order_item.unit_price) as avg_actual_price')
            ->groupBy('biz_order_item.product_name', 'biz_product.product_code', 'biz_product.spec',
                      'biz_product.purchase_price', 'biz_product.sale_price')
            ->orderBy('total_revenue', 'desc')
            ->limit(50)
            ->get()
            ->toArray();

        $result = [];
        foreach ($list as $item) {
            $qty = (int) $item['total_qty'];
            $revenue = round(floatval($item['total_revenue']), 2);
            $purchasePrice = floatval($item['purchase_price'] ?? 0);
            $salePrice = floatval($item['sale_price'] ?? 0);
            $avgActualPrice = round(floatval($item['avg_actual_price']), 2);

            // 实际利润（基于订单实际售价）
            $cost = $purchasePrice * $qty;
            $profitActual = $revenue - $cost;
            $profitRateActual = $revenue > 0 ? round(($profitActual / $revenue) * 100, 2) : 0;

            // 挂牌利润（基于货品挂牌价）
            $listedRevenue = $salePrice * $qty;
            $profitListed = $listedRevenue - $cost;
            $profitRateListed = $listedRevenue > 0 ? round(($profitListed / $listedRevenue) * 100, 2) : 0;

            $result[] = [
                'product_name' => $item['product_name'],
                'product_code' => $item['product_code'] ?: '-',
                'spec' => $item['spec'] ?: '-',
                'total_qty' => $qty,
                'purchase_price' => round($purchasePrice, 2),
                'sale_price' => round($salePrice, 2),
                'avg_actual_price' => $avgActualPrice,
                'total_revenue' => $revenue,
                'total_cost' => round($cost, 2),
                'profit_actual' => round($profitActual, 2),
                'profit_rate_actual' => $profitRateActual,
                'listed_revenue' => round($listedRevenue, 2),
                'profit_listed' => round($profitListed, 2),
                'profit_rate_listed' => $profitRateListed,
                'discount_impact' => round($profitActual - $profitListed, 2),
            ];
        }

        return $result;
    }
}
