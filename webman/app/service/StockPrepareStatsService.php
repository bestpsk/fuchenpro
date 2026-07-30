<?php

namespace app\service;

use app\model\BizStockPrepare;
use app\model\BizPlan;
use support\Db;

/**
 * 备货统计服务
 *
 * 提供备货金额统计、出库率、方案执行统计等功能
 */
class StockPrepareStatsService
{
    /**
     * 备货金额统计（按状态分组）
     *
     * @return array 各状态的备货金额分布
     */
    public static function getPrepareAmountStats()
    {
        $statusMap = ['0' => '待备货', '1' => '部分出库', '2' => '已出完', '3' => '已取消'];

        $list = BizStockPrepare::selectRaw('
                status,
                COUNT(*) as prepare_count,
                SUM(total_amount) as total_amount,
                SUM(shipped_amount) as shipped_amount,
                SUM(remaining_amount) as remaining_amount
            ')
            ->groupBy('status')
            ->get()
            ->toArray();

        $result = [];
        $totalCount = 0;
        $totalAmount = 0;
        $totalShipped = 0;
        $totalRemaining = 0;
        foreach ($statusMap as $code => $name) {
            $item = collect($list)->firstWhere('status', $code);
            $count = $item ? intval($item['prepare_count']) : 0;
            $amount = $item ? floatval($item['total_amount']) : 0;
            $shipped = $item ? floatval($item['shipped_amount']) : 0;
            $remaining = $item ? floatval($item['remaining_amount']) : 0;
            $result[] = [
                'status' => $code,
                'status_name' => $name,
                'prepare_count' => $count,
                'total_amount' => round($amount, 2),
                'shipped_amount' => round($shipped, 2),
                'remaining_amount' => round($remaining, 2),
            ];
            $totalCount += $count;
            $totalAmount += $amount;
            $totalShipped += $shipped;
            $totalRemaining += $remaining;
        }

        return [
            'list' => $result,
            'total' => [
                'status_name' => '合计',
                'prepare_count' => $totalCount,
                'total_amount' => round($totalAmount, 2),
                'shipped_amount' => round($totalShipped, 2),
                'remaining_amount' => round($totalRemaining, 2),
                'shipment_rate' => $totalAmount > 0 ? round($totalShipped / $totalAmount, 4) : 0,
            ]
        ];
    }

    /**
     * 方案执行统计
     *
     * 统计各方案的配赠金额、已出库金额、备货中金额、剩余可备货金额
     *
     * @return array 方案执行统计列表
     */
    public static function getPlanExecutionStats()
    {
        // 查询有备货的方案（通过 JOIN biz_enterprise 获取企业名称）
        $list = BizPlan::leftJoin('biz_enterprise', 'biz_plan.enterprise_id', '=', 'biz_enterprise.enterprise_id')
            ->leftJoin('biz_stock_prepare', function ($join) {
                $join->on('biz_plan.plan_id', '=', 'biz_stock_prepare.plan_id')
                     ->whereIn('biz_stock_prepare.status', ['0', '1', '2']);
            })
            ->selectRaw('
                biz_plan.plan_id,
                biz_plan.plan_name,
                biz_plan.plan_no,
                biz_enterprise.enterprise_name,
                biz_plan.gift_amount,
                biz_plan.shipped_amount,
                COUNT(DISTINCT biz_stock_prepare.prepare_id) as prepare_count,
                COALESCE(SUM(CASE WHEN biz_stock_prepare.status IN (0,1) THEN biz_stock_prepare.total_amount - biz_stock_prepare.shipped_amount ELSE 0 END), 0) as active_amount,
                COALESCE(SUM(CASE WHEN biz_stock_prepare.status IN (1,2) THEN biz_stock_prepare.shipped_amount ELSE 0 END), 0) as stock_prepare_shipped
            ')
            ->where('biz_plan.audit_status', '2')
            ->groupBy('biz_plan.plan_id', 'biz_plan.plan_name', 'biz_plan.plan_no', 'biz_enterprise.enterprise_name', 'biz_plan.gift_amount', 'biz_plan.shipped_amount')
            ->orderBy('biz_plan.create_time', 'desc')
            ->limit(50)
            ->get()
            ->toArray();

        // 计算剩余可备货金额 = 配赠金额 - 备货中金额 - 已出库金额
        foreach ($list as &$item) {
            $item['active_amount'] = round(floatval($item['active_amount']), 2);
            $item['stock_prepare_shipped'] = round(floatval($item['stock_prepare_shipped']), 2);
            $item['remaining_available'] = round(floatval($item['gift_amount']) - $item['active_amount'] - $item['stock_prepare_shipped'], 2);
            $item['execution_rate'] = $item['gift_amount'] > 0 ? round(($item['stock_prepare_shipped'] / floatval($item['gift_amount'])) * 100, 2) : 0;
        }

        return $list;
    }

    /**
     * 备货出库率统计（按企业分组）
     *
     * @param string $startDate 开始日期
     * @param string $endDate 结束日期
     * @return array 各企业的出库率
     */
    public static function getShipmentRate($startDate = null, $endDate = null)
    {
        $query = BizStockPrepare::selectRaw('
                enterprise_id,
                enterprise_name,
                COUNT(*) as prepare_count,
                SUM(total_amount) as total_amount,
                SUM(shipped_amount) as shipped_amount,
                SUM(remaining_amount) as remaining_amount
            ')
            ->whereNotIn('status', ['3'])
            ->groupBy('enterprise_id', 'enterprise_name')
            ->orderBy('total_amount', 'desc');

        if ($startDate && $endDate) {
            $query->where('create_time', '>=', $startDate . ' 00:00:00')
                  ->where('create_time', '<=', $endDate . ' 23:59:59');
        }

        $list = $query->get()->toArray();

        foreach ($list as &$item) {
            $item['shipment_rate'] = $item['total_amount'] > 0 ? round($item['shipped_amount'] / $item['total_amount'], 4) : 0;
        }

        return $list;
    }
}
