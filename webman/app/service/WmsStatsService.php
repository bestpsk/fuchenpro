<?php

namespace app\service;

use app\model\BizInventory;
use app\model\BizProduct;
use app\model\BizWarehouse;
use app\model\BizStockOutItem;
use app\model\BizStockOut;
use support\Db;

/**
 * 库存统计服务
 *
 * 提供库存金额汇总、周转率、滞销预警、库存预警等统计功能
 */
class WmsStatsService
{
    /**
     * 库存金额汇总（按仓库分组）
     *
     * @return array 各仓库的库存数量和金额
     */
    public static function getInventorySummary()
    {
        // 查询各仓库库存数量和金额（数量×进货价）
        $warehouseStats = BizInventory::join('biz_product', 'biz_inventory.product_id', '=', 'biz_product.product_id')
            ->join('biz_warehouse', 'biz_inventory.warehouse_id', '=', 'biz_warehouse.warehouse_id')
            ->selectRaw('
                biz_inventory.warehouse_id,
                biz_warehouse.warehouse_name,
                SUM(biz_inventory.quantity) as total_qty,
                SUM(biz_inventory.quantity * biz_product.purchase_price) as total_amount,
                COUNT(DISTINCT biz_inventory.product_id) as product_count
            ')
            ->groupBy('biz_inventory.warehouse_id', 'biz_warehouse.warehouse_name')
            ->get()
            ->toArray();

        // 计算合计
        $totalQty = array_sum(array_column($warehouseStats, 'total_qty'));
        $totalAmount = array_sum(array_column($warehouseStats, 'total_amount'));
        $totalProducts = array_sum(array_column($warehouseStats, 'product_count'));

        return [
            'list' => $warehouseStats,
            'total' => [
                'warehouse_name' => '合计',
                'total_qty' => $totalQty,
                'total_amount' => round($totalAmount, 2),
                'product_count' => $totalProducts,
            ]
        ];
    }

    /**
     * 滞销货品预警（90天未出库）
     *
     * @param int $days 未出库天数（默认90天）
     * @return array 滞销货品列表
     */
    public static function getSlowMovingProducts($days = 90)
    {
        $cutoffDate = date('Y-m-d H:i:s', strtotime("-{$days} days"));

        // 查询有库存但超过N天未出库的货品（使用 whereNotExists 替代 LEFT JOIN + whereNull）
        $list = BizInventory::join('biz_product', 'biz_inventory.product_id', '=', 'biz_product.product_id')
            ->join('biz_warehouse', 'biz_inventory.warehouse_id', '=', 'biz_warehouse.warehouse_id')
            ->where('biz_inventory.quantity', '>', 0)
            ->whereNotExists(function ($query) use ($cutoffDate) {
                $query->select(Db::raw(1))
                    ->from('biz_stock_out_item')
                    ->join('biz_stock_out', 'biz_stock_out_item.stock_out_id', '=', 'biz_stock_out.stock_out_id')
                    ->whereColumn('biz_stock_out_item.product_id', 'biz_inventory.product_id')
                    ->where('biz_stock_out.create_time', '>=', $cutoffDate)
                    ->where('biz_stock_out.status', '1');
            })
            ->selectRaw('
                biz_inventory.inventory_id,
                biz_inventory.warehouse_id,
                biz_warehouse.warehouse_name,
                biz_inventory.product_id,
                biz_product.product_name,
                biz_product.product_code,
                biz_inventory.quantity,
                biz_product.purchase_price,
                (biz_inventory.quantity * biz_product.purchase_price) as stock_amount,
                biz_inventory.last_stock_out_time,
                COALESCE(DATEDIFF(NOW(), biz_inventory.last_stock_out_time), DATEDIFF(NOW(), biz_inventory.create_time)) as days_no_out
            ')
            ->orderBy('days_no_out', 'desc')
            ->limit(50)
            ->get()
            ->toArray();

        return $list;
    }

    /**
     * 库存预警（库存数量 <= 预警数量）
     *
     * @return array 预警货品列表
     */
    public static function getInventoryWarnings()
    {
        // 优先使用 biz_inventory.warn_qty，为0时使用 biz_product.warn_qty
        $list = BizInventory::join('biz_product', 'biz_inventory.product_id', '=', 'biz_product.product_id')
            ->join('biz_warehouse', 'biz_inventory.warehouse_id', '=', 'biz_warehouse.warehouse_id')
            ->where(function ($query) {
                $query->where(function ($q) {
                    $q->where('biz_inventory.warn_qty', '>', 0)
                      ->whereColumn('biz_inventory.quantity', '<=', 'biz_inventory.warn_qty');
                })->orWhere(function ($q) {
                    $q->where('biz_inventory.warn_qty', 0)
                      ->where('biz_product.warn_qty', '>', 0)
                      ->whereColumn('biz_inventory.quantity', '<=', 'biz_product.warn_qty');
                });
            })
            ->selectRaw('
                biz_inventory.inventory_id,
                biz_inventory.warehouse_id,
                biz_warehouse.warehouse_name,
                biz_inventory.product_id,
                biz_product.product_name,
                biz_product.product_code,
                biz_inventory.quantity,
                CASE WHEN biz_inventory.warn_qty > 0 THEN biz_inventory.warn_qty ELSE biz_product.warn_qty END as warn_qty,
                (CASE WHEN biz_inventory.warn_qty > 0 THEN biz_inventory.warn_qty ELSE biz_product.warn_qty END - biz_inventory.quantity) as shortage_qty
            ')
            ->orderBy('shortage_qty', 'desc')
            ->limit(50)
            ->get()
            ->toArray();

        return $list;
    }

    /**
     * 库存周转率统计（按仓库分组）
     *
     * 周转率 = 出库数量 / 平均库存数量
     *
     * @param string $startDate 开始日期
     * @param string $endDate 结束日期
     * @return array 各仓库周转率
     */
    public static function getInventoryTurnover($startDate, $endDate)
    {
        if (!$startDate || !$endDate) {
            return [];
        }

        $start = $startDate . ' 00:00:00';
        $end = $endDate . ' 23:59:59';

        // 查询各仓库的出库数量（已确认的出库单）
        $outStats = BizStockOutItem::join('biz_stock_out', 'biz_stock_out_item.stock_out_id', '=', 'biz_stock_out.stock_out_id')
            ->join('biz_warehouse', 'biz_stock_out.warehouse_id', '=', 'biz_warehouse.warehouse_id')
            ->where('biz_stock_out.status', '1')
            ->where('biz_stock_out.create_time', '>=', $start)
            ->where('biz_stock_out.create_time', '<=', $end)
            ->selectRaw('
                biz_stock_out.warehouse_id,
                biz_warehouse.warehouse_name,
                SUM(biz_stock_out_item.quantity) as total_out_qty,
                COUNT(DISTINCT biz_stock_out_item.product_id) as out_product_count
            ')
            ->groupBy('biz_stock_out.warehouse_id', 'biz_warehouse.warehouse_name')
            ->get()
            ->keyBy('warehouse_id')
            ->toArray();

        // 查询各仓库当前库存数量
        $stockStats = BizInventory::join('biz_warehouse', 'biz_inventory.warehouse_id', '=', 'biz_warehouse.warehouse_id')
            ->selectRaw('
                biz_inventory.warehouse_id,
                biz_warehouse.warehouse_name,
                SUM(biz_inventory.quantity) as current_stock_qty,
                COUNT(DISTINCT biz_inventory.product_id) as product_count
            ')
            ->groupBy('biz_inventory.warehouse_id', 'biz_warehouse.warehouse_name')
            ->get()
            ->keyBy('warehouse_id')
            ->toArray();

        // 合并数据计算周转率
        $result = [];
        $allWarehouseIds = array_unique(array_merge(array_keys($outStats), array_keys($stockStats)));
        foreach ($allWarehouseIds as $wid) {
            $out = $outStats[$wid] ?? null;
            $stock = $stockStats[$wid] ?? null;
            $warehouseName = $out['warehouse_name'] ?? ($stock['warehouse_name'] ?? '-');
            $outQty = $out ? intval($out['total_out_qty']) : 0;
            $stockQty = $stock ? intval($stock['current_stock_qty']) : 0;
            // 平均库存 = 当前库存（简化计算，实际应为每日库存平均值）
            $turnoverRate = $stockQty > 0 ? round($outQty / $stockQty, 4) : 0;

            $result[] = [
                'warehouse_id' => $wid,
                'warehouse_name' => $warehouseName,
                'total_out_qty' => $outQty,
                'current_stock_qty' => $stockQty,
                'out_product_count' => $out ? intval($out['out_product_count']) : 0,
                'product_count' => $stock ? intval($stock['product_count']) : 0,
                'turnover_rate' => $turnoverRate,
            ];
        }

        return $result;
    }
}
