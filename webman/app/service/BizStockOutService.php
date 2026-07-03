<?php

namespace app\service;

use app\model\BizStockOut;
use app\model\BizStockOutItem;
use app\model\BizInventory;
use app\model\BizProduct;
use app\model\SysUser;
use app\model\BizEnterprise;
use app\service\DataScopeService;
use support\Db;

/**
 * 出库服务层，处理出库单的增删改查和确认，确认时校验库存并扣减
 */
class BizStockOutService
{
    // 按条件分页查询出库单列表
    public function selectStockOutList($params = [])
    {
        $query = BizStockOut::query();
        if (!empty($params['stock_out_no'])) {
            $query->where('stock_out_no', 'like', '%' . $params['stock_out_no'] . '%');
        }
        if (isset($params['stock_out_type']) && $params['stock_out_type'] !== '') {
            $query->where('stock_out_type', $params['stock_out_type']);
        }
        if (!empty($params['enterprise_id'])) {
            $query->where('enterprise_id', $params['enterprise_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['stock_out_date_start'])) {
            $query->where('stock_out_date', '>=', $params['stock_out_date_start']);
        }
        if (!empty($params['stock_out_date_end'])) {
            $query->where('stock_out_date', '<=', $params['stock_out_date_end']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $userName = $params['login_user']->user->user_name ?? '';
        //     $query->where(function ($q) use ($visibleUserIds, $userName) {
        //         $q->whereIn('responsible_id', $visibleUserIds)
        //           ->orWhere('create_by', $userName);
        //     });
        // }
        // 仓库权限过滤：非管理员只能查看授权仓库的数据
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            // warehouse_id 为 NULL 的出库单（备货自动创建，待确认选仓库）对所有用户可见
            $query->where(function ($q) use ($authorizedWhIds) {
                $q->whereIn('warehouse_id', $authorizedWhIds)->orWhereNull('warehouse_id');
            });
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $list = $query->orderBy('stock_out_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
        
        $stockOutIds = $list->pluck('stock_out_id')->toArray();
        $firstItemsMap = BizStockOutItem::whereIn('stock_out_id', $stockOutIds)
            ->orderBy('item_id', 'asc')
            ->get()
            ->groupBy('stock_out_id');
        foreach ($list->items() as $stockOut) {
            $items = $firstItemsMap->get($stockOut->stock_out_id);
            if ($items && $items->isNotEmpty()) {
                $firstItem = $items->first();
                $stockOut->display_unit_type = $firstItem->unit_type ?? '1';
                $stockOut->display_original_qty = $firstItem->original_quantity ?? $firstItem->quantity;
                $stockOut->display_pack_qty = $firstItem->pack_qty ?? 1;
                $stockOut->display_unit = $firstItem->unit;
                $stockOut->display_spec = $firstItem->spec;
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

    // 根据ID查询出库单详情，含明细列表

    public function selectStockOutById($stockOutId, $params = [])
    {
        $stockOut = BizStockOut::find($stockOutId);
        if ($stockOut) {
            $items = BizStockOutItem::where('stock_out_id', $stockOutId)->get()->toArray();
            $stockOut->items = array_map(function ($item) {
                return [
                    'itemId' => $item['item_id'] ?? null,
                    'productId' => $item['product_id'],
                    'productName' => $item['product_name'],
                    'spec' => $item['spec'],
                    'supplierId' => $item['supplier_id'] ?? null,
                    'supplierName' => $item['supplier_name'] ?? null,
                    'unit' => $item['unit'],
                    'unitType' => $item['unit_type'] ?? '1',
                    'packQty' => $item['pack_qty'] ?? 1,
                    'originalQuantity' => $item['original_quantity'] ?? $item['quantity'],
                    'quantity' => $item['quantity'],
                    'salePrice' => floatval($item['sale_price']),
                    'amount' => $item['amount'],
                    'remark' => $item['remark'],
                ];
            }, $items);

            $stockOutArray = $stockOut->toArray();
            $warehouseName = '';
            if (!empty($stockOut->warehouse_id)) {
                $warehouse = \app\model\BizWarehouse::find($stockOut->warehouse_id);
                $warehouseName = $warehouse ? $warehouse->warehouse_name : '';
            }

            $planName = null;
            if (!empty($stockOut->plan_id)) {
                $plan = \app\model\BizPlan::find($stockOut->plan_id);
                $planName = $plan ? $plan->plan_name : null;
            }

            return [
                'stockOutId' => $stockOutArray['stock_out_id'],
                'stockOutNo' => $stockOutArray['stock_out_no'],
                'stockOutType' => $stockOutArray['stock_out_type'],
                'outTargetType' => $stockOutArray['out_target_type'] ?? '1',
                'enterpriseId' => $stockOutArray['enterprise_id'],
                'enterpriseName' => $stockOutArray['enterprise_name'] ?? '-',
                'warehouseId' => $stockOutArray['warehouse_id'] ?? null,
                'warehouseName' => $warehouseName,
                'contactEmployeeId' => $stockOutArray['contact_employee_id'],
                'contactEmployeeName' => $stockOutArray['contact_employee_name'] ?? '-',
                'contactPerson' => $stockOutArray['contact_person'] ?? null,
                'contactPhone' => $stockOutArray['contact_phone'] ?? null,
                'shippingAddress' => $stockOutArray['shipping_address'] ?? null,
                'responsibleId' => $stockOutArray['responsible_id'],
                'responsibleName' => $stockOutArray['responsible_name'] ?? '-',
                'totalQuantity' => $stockOutArray['total_quantity'],
                'totalAmount' => $stockOutArray['total_amount'],
                'stockOutDate' => $stockOutArray['stock_out_date'],
                'status' => $stockOutArray['status'],
                'shipType' => isset($stockOutArray['ship_type']) ? strval($stockOutArray['ship_type']) : '2',
                'shipStatus' => $stockOutArray['ship_status'] ?? null,
                'logisticsCompany' => $stockOutArray['logistics_company'] ?? null,
                'logisticsNo' => $stockOutArray['logistics_no'] ?? null,
                'shipmentDate' => $stockOutArray['shipment_date'] ?? null,
                'receiptDate' => $stockOutArray['receipt_date'] ?? null,
                'shipmentImages' => $stockOutArray['shipment_images'] ?? null,
                'planId' => $stockOutArray['plan_id'] ?? null,
                'planName' => $planName,
                'prepareId' => $stockOutArray['prepare_id'] ?? null,
                'remark' => $stockOutArray['remark'],
                'createBy' => $stockOutArray['create_by'],
                'createTime' => $stockOutArray['create_time'],
                'updateBy' => $stockOutArray['update_by'] ?? null,
                'updateTime' => $stockOutArray['update_time'] ?? null,
                'items' => $stockOut->items,
            ];
        }
        return null;
    }

    public function generateStockOutNo()
    {
        $prefix = 'CK' . date('Ymd');
        $key = 'stock_out_no:' . date('Ymd');
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        $stockOutNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);

        // 数据库兜底：如果序号已存在，从数据库最大序号继续
        $exists = BizStockOut::where('stock_out_no', $stockOutNo)->exists();
        if ($exists) {
            $last = BizStockOut::where('stock_out_no', 'like', $prefix . '%')
                ->orderBy('stock_out_id', 'desc')->first();
            if ($last) {
                $lastSeq = intval(substr($last->stock_out_no, -3));
                $seq = $lastSeq + 1;
                \support\Redis::set($key, $seq);
                \support\Redis::expire($key, 86400);
            }
            $stockOutNo = $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);
        }
        return $stockOutNo;
    }

    // 新增出库单，生成出库编号并扣减库存

    public function insertStockOut($data)
    {
        $items = $data['items'] ?? [];
        unset($data['items']);

        $data['stock_out_no'] = $this->generateStockOutNo();
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
                    $item['sale_price'] = bcdiv($item['_main_price'], $packQty, 4);
                }
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }
            
            $item['amount'] = bcmul($item['quantity'] ?? 0, $item['sale_price'] ?? 0, 2);
            $totalQuantity += intval($item['quantity'] ?? 0);
            $totalAmount = bcadd($totalAmount, $item['amount'], 2);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_amount'] = $totalAmount;
        $stockOut = Db::transaction(function () use ($data, $items) {
            $stockOut = BizStockOut::create($data);
            foreach ($items as $item) {
                $item['stock_out_id'] = $stockOut->stock_out_id;
                BizStockOutItem::create($item);
            }
            return $stockOut;
        });
        return $stockOut;
    }

    // 更新出库单信息

    public function updateStockOut($data)
    {
        $stockOutId = $data['stock_out_id'] ?? 0;
        $stockOut = BizStockOut::find($stockOutId);
        if (!$stockOut) {
            return false;
        }
        if ($stockOut->status === '1') {
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
                    $item['sale_price'] = bcdiv($item['_main_price'], $packQty, 4);
                }
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }
            
            $item['amount'] = bcmul($item['quantity'] ?? 0, $item['sale_price'] ?? 0, 2);
            $totalQuantity += intval($item['quantity'] ?? 0);
            $totalAmount = bcadd($totalAmount, $item['amount'], 2);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $data['total_amount'] = $totalAmount;
        $fillable = (new BizStockOut())->getFillable();
        $filteredData = array_intersect_key($data, array_flip($fillable));
        Db::transaction(function () use ($stockOutId, $filteredData, $items) {
            BizStockOut::where('stock_out_id', $stockOutId)->update($filteredData);
            BizStockOutItem::where('stock_out_id', $stockOutId)->delete();
            foreach ($items as $item) {
                $item['stock_out_id'] = $stockOutId;
                BizStockOutItem::create($item);
            }
        });
        return true;
    }

    // 批量删除出库单

    public function deleteStockOutByIds($stockOutIds, $params = [])
    {
        foreach ($stockOutIds as $id) {
            $stockOut = BizStockOut::find($id);
            if ($stockOut && $stockOut->status === '1') {
                return false;
            }
        }
        return Db::transaction(function () use ($stockOutIds) {
            BizStockOutItem::whereIn('stock_out_id', $stockOutIds)->delete();
            return BizStockOut::whereIn('stock_out_id', $stockOutIds)->delete();
        });
    }

    public function confirmStockOut($stockOutId, $params = [])
    {
        $stockOut = BizStockOut::find($stockOutId);
        if (!$stockOut) {
            return ['success' => false, 'msg' => '出库单不存在'];
        }
        if ($stockOut->status !== '0') {
            return ['success' => false, 'msg' => '出库单已确认，请勿重复操作'];
        }
        $items = BizStockOutItem::where('stock_out_id', $stockOutId)->get();
        if ($items->isEmpty()) {
            return ['success' => false, 'msg' => '出库单明细为空'];
        }
        try {
            Db::transaction(function () use ($stockOutId, $stockOut, $items, $params) {
            $warehouseId = $stockOut->warehouse_id;
            // 如果出库单未指定仓库，从确认参数中获取
            if (empty($warehouseId) && !empty($params['warehouse_id'])) {
                $warehouseId = $params['warehouse_id'];
                $stockOut->warehouse_id = $warehouseId;
                $stockOut->save();
            }
            if (empty($warehouseId)) {
                throw new \Exception('出库单未指定仓库，请先选择出库仓库');
            }
            // 仓库权限校验：非管理员只能确认授权仓库的出库单，防止跨公司误操作
            $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
            if ($authorizedWhIds !== null && !in_array($warehouseId, $authorizedWhIds)) {
                throw new \Exception('您没有该仓库的操作权限，无法确认出库');
            }
                foreach ($items as $item) {
                    $itemQuantity = intval($item->quantity);
                    $inventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->lockForUpdate()->first();
                    if (!$inventory || $inventory->quantity < $itemQuantity) {
                        $product = BizProduct::find($item->product_id);
                        $productName = $product ? $product->product_name : $item->product_name;
                        $currentQty = $inventory ? $inventory->quantity : 0;
                        throw new \Exception("货品【{$productName}】库存不足，当前库存：{$currentQty}，出库数量：{$itemQuantity}");
                    }

                    // 按FIFO原则扣减批次库存：有效期升序（即将到期的优先出库）
                    $batches = \app\model\BizStockInItem::where('product_id', $item->product_id)
                        ->where('warehouse_id', $warehouseId)
                        ->whereRaw('quantity > shipped_quantity')
                        ->orderBy('expiry_date', 'asc')
                        ->orderBy('item_id', 'asc')
                        ->lockForUpdate()
                        ->get();

                    $remainingToShip = $itemQuantity;
                    foreach ($batches as $batch) {
                        if ($remainingToShip <= 0) break;
                        $batchRemaining = $batch->quantity - $batch->shipped_quantity;
                        $shipFromBatch = min($batchRemaining, $remainingToShip);
                        $batch->shipped_quantity += $shipFromBatch;
                        $batch->save();
                        $remainingToShip -= $shipFromBatch;
                    }
                    // 批次总量不够时仅记录日志，不阻断出库（库存可能通过直接调整等方式增加，无批次记录）

                    // 扣减库存总数量
                    BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->decrement('quantity', $itemQuantity, [
                        'last_stock_out_time' => date('Y-m-d H:i:s'),
                        'update_time' => date('Y-m-d H:i:s'),
                    ]);

                    // 更新最早有效期
                    $earliestExpiry = \app\model\BizStockInItem::where('product_id', $item->product_id)
                        ->where('warehouse_id', $warehouseId)
                        ->whereRaw('quantity > shipped_quantity')
                        ->whereNotNull('expiry_date')
                        ->min('expiry_date');
                    BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->update([
                        'earliest_expiry' => $earliestExpiry,
                        'update_time' => date('Y-m-d H:i:s'),
                    ]);

                    $updatedInventory = BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->first();
                    if ($updatedInventory->quantity < 0) {
                        $product = BizProduct::find($item->product_id);
                        $productName = $product ? $product->product_name : $item->product_name;
                        throw new \Exception("货品【{$productName}】扣减后库存为负数，请检查库存数据");
                    }
                }
                $newStatus = intval($stockOut->ship_type) === 0 ? '3' : '1';
                BizStockOut::where('stock_out_id', $stockOutId)->update([
                    'status' => $newStatus,
                    'update_time' => date('Y-m-d H:i:s'),
                ]);

                // 确认出库时更新方案明细剩余数量（从发货/确认收货移至此处，避免遗漏）
                if ($stockOut->plan_id) {
                    \support\Log::info("confirmStockOut: calling updatePlanShippedAmount, stock_out_id={$stockOutId}, plan_id={$stockOut->plan_id}");
                    $this->updatePlanShippedAmount($stockOut);
                } else {
                    \support\Log::info("confirmStockOut: no plan_id, skip updatePlanShippedAmount, stock_out_id={$stockOutId}");
                }
            });
        } catch (\Exception $e) {
            return ['success' => false, 'msg' => $e->getMessage()];
        }
        return ['success' => true, 'msg' => '出库确认成功'];
    }

    public function cancelConfirmStockOut($stockOutId, $params = [])
    {
        $stockOut = BizStockOut::find($stockOutId);
        if (!$stockOut) {
            return ['success' => false, 'msg' => '出库单不存在'];
        }
        if ($stockOut->status !== '1' && !($stockOut->status === '3' && $stockOut->ship_type === '0')) {
            return ['success' => false, 'msg' => '该出库单无法取消确认'];
        }

        $items = BizStockOutItem::where('stock_out_id', $stockOutId)->get();
        $warehouseId = $stockOut->warehouse_id;
        if (empty($warehouseId)) {
            return ['success' => false, 'msg' => '出库单未指定仓库'];
        }
        Db::transaction(function () use ($stockOutId, $stockOut, $items, $warehouseId) {
            foreach ($items as $item) {
                $actualQty = intval($item->quantity);

                // 按LIFO原则回退批次shipped_quantity：有效期降序（后扣的先回退）
                $batches = \app\model\BizStockInItem::where('product_id', $item->product_id)
                    ->where('warehouse_id', $warehouseId)
                    ->whereRaw('shipped_quantity > 0')
                    ->orderBy('expiry_date', 'desc')
                    ->orderBy('item_id', 'desc')
                    ->lockForUpdate()
                    ->get();

                $remainingToRestore = $actualQty;
                foreach ($batches as $batch) {
                    if ($remainingToRestore <= 0) break;
                    $canRestore = min($batch->shipped_quantity, $remainingToRestore);
                    $batch->shipped_quantity -= $canRestore;
                    $batch->save();
                    $remainingToRestore -= $canRestore;
                }

                // 恢复库存总数量
                BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->increment('quantity', $actualQty, [
                    'last_stock_out_time' => date('Y-m-d H:i:s'),
                    'update_time' => date('Y-m-d H:i:s'),
                ]);

                // 更新最早有效期
                $earliestExpiry = \app\model\BizStockInItem::where('product_id', $item->product_id)
                    ->where('warehouse_id', $warehouseId)
                    ->whereRaw('quantity > shipped_quantity')
                    ->whereNotNull('expiry_date')
                    ->min('expiry_date');
                BizInventory::where('product_id', $item->product_id)->where('warehouse_id', $warehouseId)->update([
                    'earliest_expiry' => $earliestExpiry,
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            }

            BizStockOut::where('stock_out_id', $stockOutId)->update([
                'status' => '0',
                'ship_status' => '0',
                'update_time' => date('Y-m-d H:i:s'),
            ]);
        });

        return ['success' => true, 'msg' => '已取消确认'];
    }

    public function shipStockOut($stockOutId, $data)
    {
        $stockOut = BizStockOut::find($stockOutId);
        if (!$stockOut) {
            return ['success' => false, 'msg' => '出库单不存在'];
        }
        if ($stockOut->status !== '1') {
            return ['success' => false, 'msg' => '只有已确认待发货的出库单才能发货'];
        }

        $shipType = intval($data['ship_type'] ?? 1);
        $updateData = [
            'ship_type' => strval($shipType),
            'ship_status' => '1',
            'shipment_images' => $data['shipment_images'] ?? null,
            'remark' => $data['remark'] ?? $stockOut->remark,
            'update_time' => date('Y-m-d H:i:s'),
        ];

        if ($shipType === 1) {
            $updateData['status'] = '3';
            $updateData['shipment_date'] = date('Y-m-d H:i:s');
        } else if ($shipType === 2) {
            $updateData['status'] = '2';
            $updateData['logistics_company'] = $data['logistics_company'] ?? null;
            $updateData['logistics_no'] = $data['logistics_no'] ?? null;
            $updateData['shipment_date'] = date('Y-m-d H:i:s');
        }

        Db::transaction(function () use ($stockOutId, $stockOut, $updateData, $shipType) {
            BizStockOut::where('stock_out_id', $stockOutId)->update($updateData);

            // 发货时更新备货主表（实际出库）
            if ($stockOut->prepare_id) {
                $prepare = \app\model\BizStockPrepare::find($stockOut->prepare_id);
                if ($prepare) {
                    $shipQty = intval($stockOut->total_quantity);
                    $shipAmount = floatval($stockOut->total_amount);
                    $newShipped = intval($prepare->shipped_quantity) + $shipQty;
                    $newRemaining = intval($prepare->remaining_quantity) - $shipQty;
                    $newShippedAmount = bcadd(floatval($prepare->shipped_amount), $shipAmount, 2);
                    $newRemainingAmount = bcsub(floatval($prepare->remaining_amount), $shipAmount, 2);
                    $newStatus = $newRemaining <= 0 ? '2' : '1';

                    \app\model\BizStockPrepare::where('prepare_id', $prepare->prepare_id)->update([
                        'shipped_quantity' => $newShipped,
                        'remaining_quantity' => $newRemaining,
                        'shipped_amount' => $newShippedAmount,
                        'remaining_amount' => $newRemainingAmount,
                        'status' => $newStatus,
                        'update_time' => date('Y-m-d H:i:s'),
                    ]);
                }
            }

            // 方案明细已在确认出库时更新，此处不再重复扣减
        });

        return ['success' => true, 'msg' => '发货成功'];
    }

    public function confirmReceipt($stockOutId, $params = [])
    {
        $stockOut = BizStockOut::find($stockOutId);
        if (!$stockOut) {
            return ['success' => false, 'msg' => '出库单不存在'];
        }
        if ($stockOut->status !== '2') {
            return ['success' => false, 'msg' => '只有已发货的出库单才能确认收货'];
        }

        $updateData = [
            'status' => '3',
            'ship_status' => '2',
            'receipt_date' => date('Y-m-d H:i:s'),
            'update_time' => date('Y-m-d H:i:s'),
        ];

        Db::transaction(function () use ($stockOutId, $stockOut, $updateData) {
            // 方案明细已在确认出库时更新，此处不再重复扣减
            BizStockOut::where('stock_out_id', $stockOutId)->update($updateData);
        });
        return ['success' => true, 'msg' => '确认收货成功'];
    }

    /**
     * 更新方案已出金额和方案明细已出数量（同时扣减剩余）
     */
    private function updatePlanShippedAmount($stockOut)
    {
        $planId = $stockOut->plan_id;
        $totalAmount = floatval($stockOut->total_amount);

        \support\Log::info("updatePlanShippedAmount called, stock_out_id={$stockOut->stock_out_id}, plan_id={$planId}, total_amount={$totalAmount}");

        // 更新方案主表：shipped_amount++，remaining_amount--
        $plan = \app\model\BizPlan::find($planId);
        if ($plan) {
            \app\model\BizPlan::where('plan_id', $planId)->increment('shipped_amount', $totalAmount);
            \app\model\BizPlan::where('plan_id', $planId)->decrement('remaining_amount', $totalAmount);
            $plan->refresh();
            \support\Log::info("Plan updated, plan_id={$planId}, shipped_amount={$plan->shipped_amount}, remaining_amount={$plan->remaining_amount}");
            if (bccomp($plan->remaining_amount, 0, 2) <= 0) {
                \app\model\BizPlan::where('plan_id', $planId)->update([
                    'remaining_amount' => 0,
                    'audit_status' => '3',
                    'update_time' => date('Y-m-d H:i:s')
                ]);
            }
        } else {
            \support\Log::warning("updatePlanShippedAmount: plan not found, plan_id={$planId}");
        }

        // 更新方案明细：shipped_quantity++，remaining_quantity--
        $items = BizStockOutItem::where('stock_out_id', $stockOut->stock_out_id)->get();
        \support\Log::info("updatePlanShippedAmount: found " . count($items) . " stock out items");
        foreach ($items as $item) {
            if ($item->plan_item_id) {
                $qty = intval($item->quantity);
                \app\model\BizPlanItem::where('item_id', $item->plan_item_id)->increment('shipped_quantity', $qty);
                \app\model\BizPlanItem::where('item_id', $item->plan_item_id)->decrement('remaining_quantity', $qty);
                $updatedPlanItem = \app\model\BizPlanItem::find($item->plan_item_id);
                \support\Log::info("PlanItem updated, item_id={$item->plan_item_id}, qty={$qty}, shipped={$updatedPlanItem->shipped_quantity}, remaining={$updatedPlanItem->remaining_quantity}");
            } else {
                \support\Log::warning("updatePlanShippedAmount: stock_out_item_id={$item->item_id} has empty plan_item_id, product={$item->product_name}");
            }
        }
    }
}
