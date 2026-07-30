<?php

namespace app\service;

use support\Redis;

/**
 * 进销存公共辅助类
 * 抽取各 Service 中重复的单位换算、单号生成逻辑
 */
class BizWmsHelper
{
    /**
     * 处理明细项的单位换算（主单位且包装数>1时，数量×包装数，单价÷包装数）
     * 会修改 $item 的 quantity/original_quantity 及价格字段
     *
     * @param array  $item        明细项引用
     * @param string $priceField  价格字段名（purchase_price=入库, sale_price=出库）
     * @return void
     */
    public static function convertUnitQuantity(array &$item, string $priceField = 'purchase_price'): void
    {
        $unitType = $item['unit_type'] ?? '1';
        $packQty = intval($item['pack_qty'] ?? 1);

        if ($unitType === '1' && $packQty > 1) {
            $item['original_quantity'] = intval($item['quantity']);
            $item['quantity'] = intval($item['quantity']) * $packQty;
            $mainPriceKey = '_main_price';
            if (isset($item[$mainPriceKey]) && $item[$mainPriceKey] > 0) {
                $item[$priceField] = bcdiv($item[$mainPriceKey], $packQty, 4);
            }
        } else {
            $item['original_quantity'] = intval($item['quantity']);
        }
    }

    /**
     * 生成业务单号：前缀+日期+3位序号（Redis incr + 数据库兜底）
     *
     * @param string $prefix      单号前缀（含日期，如 RK20260730）
     * @param string $key         Redis 键名（如 stock_in_no:20260730）
     * @param string $modelClass  模型类全限定名（用于数据库兜底查询）
     * @param string $noField     单号字段名
     * @return string
     */
    public static function generateDocNo(string $prefix, string $key, string $modelClass, string $noField): string
    {
        $seq = Redis::incr($key);
        Redis::expire($key, 86400);
        $docNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);

        // 数据库兜底：如果序号已存在，从数据库最大序号继续
        if ($modelClass::where($noField, $docNo)->exists()) {
            $primaryKey = (new $modelClass())->getKeyName();
            $last = $modelClass::where($noField, 'like', $prefix . '%')
                ->orderBy($primaryKey, 'desc')
                ->first();
            if ($last) {
                $seq = intval(substr($last->{$noField}, -3)) + 1;
                Redis::set($key, $seq);
                Redis::expire($key, 86400);
            }
            $docNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);
        }
        return $docNo;
    }

    /**
     * 更新指定仓库+产品的最早有效期
     * 用于入库/出库/调拨/盘点后同步 earliest_expiry 字段
     *
     * @param int $productId   产品ID
     * @param int $warehouseId 仓库ID
     * @return void
     */
    public static function updateEarliestExpiry(int $productId, int $warehouseId): void
    {
        $earliestExpiry = \app\model\BizStockInItem::where('product_id', $productId)
            ->where('warehouse_id', $warehouseId)
            ->whereRaw('quantity > shipped_quantity')
            ->whereNotNull('expiry_date')
            ->min('expiry_date');

        \app\model\BizInventory::where('product_id', $productId)
            ->where('warehouse_id', $warehouseId)
            ->update([
                'earliest_expiry' => $earliestExpiry,
                'update_time' => date('Y-m-d H:i:s'),
            ]);
    }
}
