<?php

namespace app\service;

use app\model\BizStockCheck;
use app\model\BizStockCheckItem;
use app\model\BizInventory;
use app\model\BizProduct;
use app\service\DataScopeService;
use support\Db;

/**
 * 库存盘点服务层，处理盘点单的增删改查和确认，确认时按差异自动调整库存
 */
class BizStockCheckService
{
    // 按条件分页查询盘点单列表
    public function selectStockCheckList($params = [])
    {
        $query = BizStockCheck::query();
        if (!empty($params['stock_check_no'])) {
            $query->where('stock_check_no', 'like', '%' . $params['stock_check_no'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['check_date_start'])) {
            $query->where('check_date', '>=', $params['check_date_start']);
        }
        if (!empty($params['check_date_end'])) {
            $query->where('check_date', '<=', $params['check_date_end']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->whereIn('operator_id', $visibleUserIds);
        // }
        // 仓库权限过滤：非管理员只能查看授权仓库的数据
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('warehouse_id', $authorizedWhIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('stock_check_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询盘点单详情，含明细列表

    public function selectStockCheckById($stockCheckId, $params = [])
    {
        $stockCheck = BizStockCheck::find($stockCheckId);
        if ($stockCheck) {
            $items = BizStockCheckItem::where('stock_check_id', $stockCheckId)->get()->toArray();
            $stockCheck->items = array_map(function ($item) {
                $product = BizProduct::find($item['product_id']);
                return [
                    'itemId' => $item['item_id'] ?? null,
                    'productId' => $item['product_id'],
                    'productName' => $product ? $product->product_name : ($item['product_name'] ?? ''),
                    'productCode' => $product ? $product->product_code : '',
                    'spec' => $product ? $product->spec : ($item['spec'] ?? ''),
                    'unit' => $product ? $product->unit : ($item['unit'] ?? ''),
                    'unitType' => $item['unit_type'] ?? '2',
                    'packQty' => $product ? ($product->pack_qty ?? 1) : ($item['pack_qty'] ?? 1),
                    'originalQuantity' => $item['original_quantity'] ?? 0,
                    'systemQuantity' => $item['system_quantity'] ?? 0,
                    'actualQuantity' => $item['actual_quantity'] ?? 0,
                    'diffQuantity' => $item['diff_quantity'] ?? 0,
                    'remark' => $item['remark'] ?? '',
                    'productionDate' => $item['production_date'] ?? null,
                    'expiryDate' => $item['expiry_date'] ?? null,
                ];
            }, $items);
        }
        return $stockCheck;
    }

    public function generateStockCheckNo()
    {
        return BizWmsHelper::generateDocNo(
            'PD' . date('Ymd'),
            'stock_check_no:' . date('Ymd'),
            BizStockCheck::class,
            'stock_check_no'
        );
    }

    // 新增盘点单，生成盘点编号并创建明细

    public function insertStockCheck($data)
    {
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['stock_check_no'] = $this->generateStockCheckNo();
        $data['create_time'] = date('Y-m-d H:i:s');
        $data['status'] = '0';
        $totalQuantity = 0;
        $totalDiffQuantity = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);

            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['actual_quantity'] ?? 0);
                $item['actual_quantity'] = intval($item['actual_quantity'] ?? 0) * $packQty;
            } else {
                $item['original_quantity'] = intval($item['actual_quantity'] ?? 0);
            }

            $item['diff_quantity'] = intval($item['actual_quantity'] ?? 0) - intval($item['system_quantity'] ?? 0);
            $totalQuantity += intval($item['actual_quantity'] ?? 0);
            $totalDiffQuantity += $item['diff_quantity'];
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_diff_quantity'] = $totalDiffQuantity;
        $stockCheck = Db::transaction(function () use ($data, $items) {
            $stockCheck = BizStockCheck::create($data);
            foreach ($items as $item) {
                $item['stock_check_id'] = $stockCheck->stock_check_id;
                BizStockCheckItem::create($item);
            }
            return $stockCheck;
        });
        return $stockCheck;
    }

    // 更新盘点单信息

    public function updateStockCheck($data)
    {
        $stockCheckId = $data['stock_check_id'] ?? 0;
        $stockCheck = BizStockCheck::find($stockCheckId);
        if (!$stockCheck) {
            return false;
        }
        if ($stockCheck->status === '1') {
            return false;
        }
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['update_time'] = date('Y-m-d H:i:s');
        $totalQuantity = 0;
        $totalDiffQuantity = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);

            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['actual_quantity'] ?? 0);
                $item['actual_quantity'] = intval($item['actual_quantity'] ?? 0) * $packQty;
            } else {
                $item['original_quantity'] = intval($item['actual_quantity'] ?? 0);
            }

            $item['diff_quantity'] = intval($item['actual_quantity'] ?? 0) - intval($item['system_quantity'] ?? 0);
            $totalQuantity += intval($item['actual_quantity'] ?? 0);
            $totalDiffQuantity += $item['diff_quantity'];
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_diff_quantity'] = $totalDiffQuantity;
        // 按 fillable 过滤，移除 login_user 等非数据库字段，避免触发 SQL 错误
        $fillable = (new BizStockCheck())->getFillable();
        $filteredData = array_intersect_key($data, array_flip($fillable));
        Db::transaction(function () use ($stockCheckId, $filteredData, $items) {
            BizStockCheck::where('stock_check_id', $stockCheckId)->update($filteredData);
            BizStockCheckItem::where('stock_check_id', $stockCheckId)->delete();
            foreach ($items as $item) {
                $item['stock_check_id'] = $stockCheckId;
                BizStockCheckItem::create($item);
            }
        });
        return true;
    }

    // 批量删除盘点单

    public function deleteStockCheckByIds($stockCheckIds, $params = [])
    {
        foreach ($stockCheckIds as $id) {
            $stockCheck = BizStockCheck::find($id);
            if ($stockCheck && $stockCheck->status === '1') {
                return false;
            }
        }
        return Db::transaction(function () use ($stockCheckIds) {
            BizStockCheckItem::whereIn('stock_check_id', $stockCheckIds)->delete();
            return BizStockCheck::whereIn('stock_check_id', $stockCheckIds)->delete();
        });
    }

    public function confirmStockCheck($stockCheckId, $params = [])
    {
        $stockCheck = BizStockCheck::find($stockCheckId);
        if (!$stockCheck) {
            return ['success' => false, 'msg' => '盘点单不存在'];
        }
        if ($stockCheck->status === '1') {
            return ['success' => false, 'msg' => '盘点单已确认，请勿重复操作'];
        }
        $items = BizStockCheckItem::where('stock_check_id', $stockCheckId)->get();
        if ($items->isEmpty()) {
            return ['success' => false, 'msg' => '盘点单明细为空'];
        }
        try {
            Db::transaction(function () use ($stockCheckId, $stockCheck, $items) {
                $warehouseId = $stockCheck->warehouse_id;
                if (empty($warehouseId)) {
                    throw new \Exception('盘点单未指定仓库');
                }
                foreach ($items as $item) {
                    if ($item->diff_quantity == 0) {
                        continue;
                    }

                    $diffQuantity = intval($item->diff_quantity);

                    $inventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->lockForUpdate()->first();
                    if (!$inventory) {
                        $product = BizProduct::find($item->product_id);
                        BizInventory::create([
                            'product_id' => $item->product_id,
                            'warehouse_id' => $warehouseId,
                            'quantity' => 0,
                            'warn_qty' => $product->warn_qty ?? 0,
                            'create_time' => date('Y-m-d H:i:s'),
                        ]);
                    }

                    if ($diffQuantity > 0) {
                        BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->increment('quantity', $diffQuantity, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);
                    } else {
                        $absDiff = abs($diffQuantity);
                        $currentInventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->lockForUpdate()->first();
                        if ($currentInventory->quantity < $absDiff) {
                            $product = BizProduct::find($item->product_id);
                            $productName = $product ? $product->product_name : $item->product_id;
                            throw new \Exception("产品【{$productName}】调整后库存为负数，当前库存：{$currentInventory->quantity}，调整数量：-{$absDiff}");
                        }
                        BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->decrement('quantity', $absDiff, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);

                        // 盘亏时按FIFO原则扣减批次shipped_quantity（与出库逻辑一致）
                        $batches = \app\model\BizStockInItem::where('product_id', $item->product_id)
                            ->where('warehouse_id', $warehouseId)
                            ->whereRaw('quantity > shipped_quantity')
                            ->orderBy('expiry_date', 'asc')
                            ->orderBy('item_id', 'asc')
                            ->lockForUpdate()
                            ->get();
                        $remainingToShip = $absDiff;
                        foreach ($batches as $batch) {
                            if ($remainingToShip <= 0) break;
                            $batchRemaining = $batch->quantity - $batch->shipped_quantity;
                            $shipFromBatch = min($batchRemaining, $remainingToShip);
                            $batch->shipped_quantity += $shipFromBatch;
                            $batch->save();
                            $remainingToShip -= $shipFromBatch;
                        }
                        if ($remainingToShip > 0) {
                            \support\Log::warning("盘点批次库存不足，产品ID:{$item->product_id}，仓库ID:{$warehouseId}，缺口:{$remainingToShip}");
                        }
                    }

                    // 更新最早有效期
                    BizWmsHelper::updateEarliestExpiry($item->product_id, $warehouseId);
                }
                BizStockCheck::where('stock_check_id', $stockCheckId)->update([
                    'status' => '1',
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            });
        } catch (\Throwable $e) {
            return ['success' => false, 'msg' => $e->getMessage()];
        }
        return ['success' => true, 'msg' => '盘点确认成功'];
    }

    public function loadInventoryData($params = [])
    {
        $warehouseId = $params['warehouse_id'] ?? 1;
        $products = BizProduct::where('status', '0')->get();
        // 批量查询该仓库所有库存，避免 N+1 查询
        $inventoryMap = BizInventory::where('warehouse_id', $warehouseId)
            ->get()
            ->keyBy('product_id');
        $items = [];
        foreach ($products as $product) {
            $inventory = $inventoryMap->get($product->product_id);
            $items[] = [
                'product_id' => $product->product_id,
                'product_name' => $product->product_name,
                'spec' => $product->spec,
                'unit' => $product->unit,
                'unit_type' => '2',
                'pack_qty' => $product->pack_qty ?? 1,
                'system_quantity' => $inventory ? $inventory->quantity : 0,
                'actual_quantity' => $inventory ? $inventory->quantity : 0,
                'diff_quantity' => 0,
            ];
        }
        return $items;
    }
}
