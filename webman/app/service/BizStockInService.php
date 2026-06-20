<?php

namespace app\service;

use app\model\BizStockIn;
use app\model\BizStockInItem;
use app\model\BizInventory;
use app\model\BizProduct;
use app\model\SysUser;
use app\service\DataScopeService;
use support\Db;

/**
 * 入库服务层，处理入库单的增删改查和确认，确认时自动累加库存
 */
class BizStockInService
{
    // 按条件分页查询入库单列表
    public function selectStockInList($params = [])
    {
        $query = BizStockIn::query();
        if (!empty($params['stock_in_no'])) {
            $query->where('stock_in_no', 'like', '%' . $params['stock_in_no'] . '%');
        }
        if (isset($params['stock_in_type']) && $params['stock_in_type'] !== '') {
            $query->where('stock_in_type', $params['stock_in_type']);
        }
        if (!empty($params['supplier_id'])) {
            $query->where('supplier_id', $params['supplier_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['stock_in_date_start'])) {
            $query->where('stock_in_date', '>=', $params['stock_in_date_start']);
        }
        if (!empty($params['stock_in_date_end'])) {
            $query->where('stock_in_date', '<=', $params['stock_in_date_end']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('warehouse_id', $params['warehouse_id']);
        }
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('operator_id', $visibleUserIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $list = $query->orderBy('stock_in_id', 'desc')
            ->paginate($pageSize, ['*', Db::raw('(SELECT MIN(expiry_date) FROM biz_stock_in_item WHERE biz_stock_in_item.stock_in_id = biz_stock_in.stock_in_id) as earliest_expiry')], 'page', $pageNum);
        
        foreach ($list->items() as $stockIn) {
            $firstItem = BizStockInItem::where('stock_in_id', $stockIn->stock_in_id)->first();
            if ($firstItem) {
                $stockIn->display_pack_qty = $firstItem->pack_qty ?? 1;
                $stockIn->display_unit = $firstItem->unit;
                $stockIn->display_spec = $firstItem->spec;
            }
        }

        $warehouseIds = $list->pluck('warehouse_id')->filter()->unique()->toArray();
        $warehouses = \app\model\BizWarehouse::whereIn('warehouse_id', $warehouseIds)->get()->keyBy('warehouse_id');
        foreach ($list->items() as $item) {
            $warehouse = $warehouses->get($item->warehouse_id);
            $item->warehouseName = $warehouse ? $warehouse->warehouse_name : '';
        }

        return $list;
    }

    // 根据ID查询入库单详情，含明细列表

    public function selectStockInById($stockInId, $params = [])
    {
        $stockIn = BizStockIn::find($stockInId);
        if ($stockIn) {
            $items = BizStockInItem::where('stock_in_id', $stockInId)->get()->toArray();
            $stockIn->items = array_map(function ($item) {
                return [
                    'itemId' => $item['id'] ?? null,
                    'productId' => $item['product_id'],
                    'productName' => $item['product_name'],
                    'supplierId' => $item['supplier_id'],
                    'supplierName' => $item['supplier_name'],
                    'spec' => $item['spec'],
                    'unit' => $item['unit'],
                    'unitType' => $item['unit_type'] ?? '1',
                    'packQty' => $item['pack_qty'] ?? 1,
                    'originalQuantity' => $item['original_quantity'] ?? $item['quantity'],
                    'quantity' => $item['quantity'],
                    'purchasePrice' => floatval($item['purchase_price']),
                    '_mainPrice' => floatval($item['purchase_price']),
                    'amount' => $item['amount'],
                    'productionDate' => $item['production_date'],
                    'expiryDate' => $item['expiry_date'],
                    'remark' => $item['remark'],
                ];
            }, $items);

            $warehouseName = '';
            if (!empty($stockIn->warehouse_id)) {
                $warehouse = \app\model\BizWarehouse::find($stockIn->warehouse_id);
                $warehouseName = $warehouse ? $warehouse->warehouse_name : '';
            }
            $stockIn->warehouseName = $warehouseName;
        }

        return $stockIn;
    }

    public function generateStockInNo()
    {
        $prefix = 'RK' . date('Ymd');
        $key = 'stock_in_no:' . date('Ymd');
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        $stockInNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);

        // 数据库兜底：如果序号已存在，从数据库最大序号继续
        $exists = BizStockIn::where('stock_in_no', $stockInNo)->exists();
        if ($exists) {
            $last = BizStockIn::where('stock_in_no', 'like', $prefix . '%')
                ->orderBy('stock_in_id', 'desc')->first();
            if ($last) {
                $lastSeq = intval(substr($last->stock_in_no, -3));
                $seq = $lastSeq + 1;
                \support\Redis::set($key, $seq);
                \support\Redis::expire($key, 86400);
            }
            $stockInNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);
        }
        return $stockInNo;
    }

    // 新增入库单，生成入库编号并创建明细

    public function insertStockIn($data)
    {
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['stock_in_no'] = $this->generateStockInNo();
        $data['create_time'] = date('Y-m-d H:i:s');
        $data['status'] = '0';
        $totalQuantity = 0;
        $totalAmount = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);
            
            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['quantity']);
                $item['quantity'] = intval($item['quantity']) * $packQty;
                if (isset($item['_main_price']) && $item['_main_price'] > 0) {
                    $item['purchase_price'] = bcdiv($item['_main_price'], $packQty, 4);
                }
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }
            
            $item['amount'] = bcmul($item['quantity'] ?? 0, $item['purchase_price'] ?? 0, 2);
            $totalQuantity += intval($item['quantity'] ?? 0);
            $totalAmount = bcadd($totalAmount, $item['amount'], 2);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_amount'] = $totalAmount;
        $stockIn = Db::transaction(function () use ($data, $items) {
            $stockIn = BizStockIn::create($data);
            foreach ($items as $item) {
                $item['stock_in_id'] = $stockIn->stock_in_id;
                $item['warehouse_id'] = $data['warehouse_id'] ?? null;
                BizStockInItem::create($item);
            }
            return $stockIn;
        });
        return $stockIn;
    }

    // 更新入库单信息

    public function updateStockIn($data)
    {
        $stockInId = $data['stock_in_id'] ?? 0;
        $stockIn = BizStockIn::find($stockInId);
        if (!$stockIn) {
            return false;
        }
        if ($stockIn->status === '1') {
            return false;
        }
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['update_time'] = date('Y-m-d H:i:s');
        $totalQuantity = 0;
        $totalAmount = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);
            
            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['quantity']);
                $item['quantity'] = intval($item['quantity']) * $packQty;
                if (isset($item['_main_price']) && $item['_main_price'] > 0) {
                    $item['purchase_price'] = bcdiv($item['_main_price'], $packQty, 4);
                }
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }
            
            $item['amount'] = bcmul($item['quantity'] ?? 0, $item['purchase_price'] ?? 0, 2);
            $totalQuantity += intval($item['quantity'] ?? 0);
            $totalAmount = bcadd($totalAmount, $item['amount'], 2);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_amount'] = $totalAmount;
        Db::transaction(function () use ($stockInId, $data, $items) {
            BizStockIn::where('stock_in_id', $stockInId)->update($data);
            BizStockInItem::where('stock_in_id', $stockInId)->delete();
            foreach ($items as $item) {
                $item['stock_in_id'] = $stockInId;
                $item['warehouse_id'] = $data['warehouse_id'] ?? null;
                BizStockInItem::create($item);
            }
        });
        return true;
    }

    // 批量删除入库单

    public function deleteStockInByIds($stockInIds, $params = [])
    {
        foreach ($stockInIds as $id) {
            $stockIn = BizStockIn::find($id);
            if ($stockIn && $stockIn->status === '1') {
                return false;
            }
        }
        return Db::transaction(function () use ($stockInIds) {
            BizStockInItem::whereIn('stock_in_id', $stockInIds)->delete();
            return BizStockIn::whereIn('stock_in_id', $stockInIds)->delete();
        });
    }

    public function confirmStockIn($stockInId, $params = [])
    {
        $stockIn = BizStockIn::find($stockInId);
        if (!$stockIn) {
            return ['success' => false, 'msg' => '入库单不存在'];
        }
        if ($stockIn->status === '1') {
            return ['success' => false, 'msg' => '入库单已确认，请勿重复操作'];
        }
        $items = BizStockInItem::where('stock_in_id', $stockInId)->get();
        if ($items->isEmpty()) {
            return ['success' => false, 'msg' => '入库单明细为空'];
        }
        $warehouseId = $stockIn->warehouse_id;
        if (empty($warehouseId)) {
            return ['success' => false, 'msg' => '入库单未指定仓库'];
        }
        Db::transaction(function () use ($stockInId, $stockIn, $items, $warehouseId) {
            foreach ($items as $item) {
                // 自动计算有效期：如果 expiry_date 为空但有 production_date 和 shelf_life_days
                if (empty($item->expiry_date) && !empty($item->production_date)) {
                    $product = BizProduct::find($item->product_id);
                    if ($product && !empty($product->shelf_life_days)) {
                        $item->expiry_date = date('Y-m-d', strtotime($item->production_date . " +{$product->shelf_life_days} days"));
                        $item->save();
                    }
                }

                $actualQty = intval($item->quantity);
                $inventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->lockForUpdate()->first();
                if (!$inventory) {
                    $product = BizProduct::find($item->product_id);
                    $inventory = BizInventory::create([
                        'product_id' => $item->product_id,
                        'warehouse_id' => $warehouseId,
                        'quantity' => 0,
                        'warn_qty' => $product ? ($product->warn_qty ?? 0) : 0,
                        'create_time' => date('Y-m-d H:i:s'),
                    ]);
                }
                $inventory->quantity = intval($inventory->quantity) + $actualQty;
                $inventory->last_stock_in_time = date('Y-m-d H:i:s');
                $inventory->update_time = date('Y-m-d H:i:s');

                // 更新最早有效期
                $earliestExpiry = BizStockInItem::where('product_id', $item->product_id)
                    ->where('warehouse_id', $warehouseId)
                    ->whereRaw('quantity > shipped_quantity')
                    ->whereNotNull('expiry_date')
                    ->min('expiry_date');
                if ($earliestExpiry) {
                    $inventory->earliest_expiry = $earliestExpiry;
                }

                $inventory->save();
            }
            BizStockIn::where('stock_in_id', $stockInId)->update([
                'status' => '1',
                'update_time' => date('Y-m-d H:i:s'),
            ]);
        });
        return ['success' => true, 'msg' => '入库确认成功'];
    }

    public function cancelConfirmStockIn($stockInId, $params = [])
    {
        $stockIn = BizStockIn::find($stockInId);
        if (!$stockIn) {
            return ['success' => false, 'msg' => '入库单不存在'];
        }
        if ($stockIn->status === '0') {
            return ['success' => false, 'msg' => '入库单未确认，无需取消'];
        }

        $items = BizStockInItem::where('stock_in_id', $stockInId)->get();
        try {
            Db::transaction(function () use ($stockInId, $stockIn, $items) {
                $warehouseId = $stockIn->warehouse_id;
                if (empty($warehouseId)) {
                    throw new \Exception('入库单未指定仓库');
                }
                foreach ($items as $item) {
                    $actualQty = intval($item->quantity);
                    $inventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->lockForUpdate()->first();
                    if (!$inventory || $inventory->quantity < $actualQty) {
                        $product = BizProduct::find($item->product_id);
                        $productName = $product ? $product->product_name : $item->product_id;
                        $currentQty = $inventory ? $inventory->quantity : 0;
                        throw new \Exception("货品【{$productName}】库存不足，当前库存：{$currentQty}，需回退数量：{$actualQty}");
                    }
                    BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->decrement('quantity', $actualQty, [
                        'last_stock_in_time' => date('Y-m-d H:i:s'),
                        'update_time' => date('Y-m-d H:i:s'),
                    ]);
                }
                BizStockIn::where('stock_in_id', $stockInId)->update([
                    'status' => '0',
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            });
        } catch (\Exception $e) {
            return ['success' => false, 'msg' => $e->getMessage()];
        }

        return ['success' => true, 'msg' => '已取消确认'];
    }
}
