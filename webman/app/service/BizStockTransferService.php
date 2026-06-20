<?php

namespace app\service;

use app\model\BizStockTransfer;
use app\model\BizStockTransferItem;
use app\model\BizInventory;
use app\model\BizProduct;
use support\Db;

/**
 * 调拨服务层，处理调拨单的增删改查和确认，确认时自动扣减源仓库库存并增加目标仓库库存
 */
class BizStockTransferService
{
    // 按条件分页查询调拨单列表
    // 注意：调拨单(biz_stock_transfer)没有 enterprise_id 字段，无法直接通过 DataScopeService 进行企业数据权限过滤。
    // 但仓库权限已限制了用户只能看到授权仓库的调拨单，因此暂不需要添加数据权限过滤。
    public function selectTransferList($params = [])
    {
        $query = BizStockTransfer::query();
        if (!empty($params['transfer_no'])) {
            $query->where('transfer_no', 'like', '%' . $params['transfer_no'] . '%');
        }
        if (!empty($params['from_warehouse_id'])) {
            $query->where('from_warehouse_id', $params['from_warehouse_id']);
        }
        if (!empty($params['to_warehouse_id'])) {
            $query->where('to_warehouse_id', $params['to_warehouse_id']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where(function ($q) use ($params) {
                $q->where('from_warehouse_id', $params['warehouse_id'])
                  ->orWhere('to_warehouse_id', $params['warehouse_id']);
            });
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $list = $query->orderBy('transfer_id', 'desc')
            ->paginate($pageSize, ['*'], 'page', $pageNum);
        return $list;
    }

    // 根据ID查询调拨单详情，含明细列表
    public function selectTransferById($transferId, $params = [])
    {
        $transfer = BizStockTransfer::find($transferId);
        if ($transfer) {
            $items = BizStockTransferItem::where('transfer_id', $transferId)->get()->toArray();
            $transfer->items = array_map(function ($item) {
                return [
                    'itemId' => $item['item_id'] ?? null,
                    'transferId' => $item['transfer_id'],
                    'productId' => $item['product_id'],
                    'productName' => $item['product_name'],
                    'spec' => $item['spec'],
                    'unit' => $item['unit'],
                    'packQty' => $item['pack_qty'] ?? 1,
                    'unitType' => $item['unit_type'] ?? '1',
                    'originalQuantity' => $item['original_quantity'] ?? $item['quantity'],
                    'quantity' => $item['quantity'],
                    'remark' => $item['remark'],
                ];
            }, $items);
        }
        return $transfer;
    }

    // 生成调拨单编号：DB + 日期 + 3位序号
    public function generateTransferNo()
    {
        $prefix = 'DB' . date('Ymd');
        $last = BizStockTransfer::where('transfer_no', 'like', $prefix . '%')
            ->orderBy('transfer_id', 'desc')
            ->first();
        $seq = 1;
        if ($last) {
            $lastSeq = intval(substr($last->transfer_no, -3));
            $seq = $lastSeq + 1;
        }
        return $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);
    }

    // 新增调拨单，生成调拨编号并创建明细
    public function addTransfer($data)
    {
        if (!empty($data['from_warehouse_id']) && !empty($data['to_warehouse_id'])
            && $data['from_warehouse_id'] == $data['to_warehouse_id']) {
            return ['success' => false, 'msg' => '源仓库和目标仓库不能相同'];
        }
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['transfer_no'] = $this->generateTransferNo();
        $data['create_time'] = date('Y-m-d H:i:s');
        $data['status'] = '0';
        $totalQuantity = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);

            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['quantity']);
                $item['quantity'] = intval($item['quantity']) * $packQty;
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }

            $totalQuantity += intval($item['quantity'] ?? 0);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        $transfer = Db::transaction(function () use ($data, $items) {
            $transfer = BizStockTransfer::create($data);
            foreach ($items as $item) {
                $item['transfer_id'] = $transfer->transfer_id;
                BizStockTransferItem::create($item);
            }
            return $transfer;
        });
        return ['success' => true, 'data' => $transfer];
    }

    // 更新调拨单信息
    public function updateTransfer($data)
    {
        $transferId = $data['transfer_id'] ?? 0;
        $transfer = BizStockTransfer::find($transferId);
        if (!$transfer) {
            return false;
        }
        if ($transfer->status === '1') {
            return false;
        }
        if (!empty($data['from_warehouse_id']) && !empty($data['to_warehouse_id'])
            && $data['from_warehouse_id'] == $data['to_warehouse_id']) {
            return false;
        }
        $items = $data['items'] ?? [];
        unset($data['items']);
        $data['update_time'] = date('Y-m-d H:i:s');
        $totalQuantity = 0;
        foreach ($items as &$item) {
            $unitType = $item['unit_type'] ?? '1';
            $packQty = intval($item['pack_qty'] ?? 1);

            if ($unitType === '1' && $packQty > 1) {
                $item['original_quantity'] = intval($item['quantity']);
                $item['quantity'] = intval($item['quantity']) * $packQty;
            } else {
                $item['original_quantity'] = intval($item['quantity']);
            }

            $totalQuantity += intval($item['quantity'] ?? 0);
        }
        unset($item);
        $data['total_quantity'] = $totalQuantity;
        Db::transaction(function () use ($transferId, $data, $items) {
            BizStockTransfer::where('transfer_id', $transferId)->update($data);
            BizStockTransferItem::where('transfer_id', $transferId)->delete();
            foreach ($items as $item) {
                $item['transfer_id'] = $transferId;
                BizStockTransferItem::create($item);
            }
        });
        return true;
    }

    // 批量删除调拨单，只能删除待确认状态的
    public function deleteTransferByIds($transferIds, $params = [])
    {
        foreach ($transferIds as $id) {
            $transfer = BizStockTransfer::find($id);
            if ($transfer && $transfer->status === '1') {
                return false;
            }
        }
        return Db::transaction(function () use ($transferIds) {
            BizStockTransferItem::whereIn('transfer_id', $transferIds)->delete();
            return BizStockTransfer::whereIn('transfer_id', $transferIds)->delete();
        });
    }

    // 确认调拨，扣减源仓库库存并增加目标仓库库存
    public function confirmTransfer($transferId, $params = [])
    {
        $transfer = BizStockTransfer::find($transferId);
        if (!$transfer) {
            return ['success' => false, 'msg' => '调拨单不存在'];
        }
        if ($transfer->status === '1') {
            return ['success' => false, 'msg' => '调拨单已确认，请勿重复操作'];
        }
        $items = BizStockTransferItem::where('transfer_id', $transferId)->get();
        if ($items->isEmpty()) {
            return ['success' => false, 'msg' => '调拨单明细为空'];
        }
        $fromWarehouseId = $transfer->from_warehouse_id;
        $toWarehouseId = $transfer->to_warehouse_id;
        try {
            Db::transaction(function () use ($transferId, $fromWarehouseId, $toWarehouseId, $items) {
                foreach ($items as $item) {
                    $productId = $item->product_id;
                    $quantity = intval($item->quantity);

                    // 查找源仓库库存并校验
                    $fromInventory = BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $fromWarehouseId)
                        ->lockForUpdate()
                        ->first();
                    if (!$fromInventory || $fromInventory->quantity < $quantity) {
                        $product = BizProduct::find($productId);
                        $productName = $product ? $product->product_name : $productId;
                        $currentQty = $fromInventory ? $fromInventory->quantity : 0;
                        throw new \Exception("货品【{$productName}】源仓库库存不足，当前库存：{$currentQty}，需调拨数量：{$quantity}");
                    }

                    // 源仓库扣减
                    BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $fromWarehouseId)
                        ->decrement('quantity', $quantity, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);

                    // 目标仓库增加：查找或创建库存记录
                    $toInventory = BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $toWarehouseId)
                        ->first();
                    if (!$toInventory) {
                        $product = BizProduct::find($productId);
                        BizInventory::create([
                            'product_id' => $productId,
                            'warehouse_id' => $toWarehouseId,
                            'quantity' => 0,
                            'warn_qty' => $product ? ($product->warn_qty ?? 0) : 0,
                            'create_time' => date('Y-m-d H:i:s'),
                        ]);
                    }
                    BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $toWarehouseId)
                        ->increment('quantity', $quantity, [
                            'last_stock_in_time' => date('Y-m-d H:i:s'),
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);
                }

                // 更新调拨单状态为已确认
                BizStockTransfer::where('transfer_id', $transferId)->update([
                    'status' => '1',
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            });
        } catch (\Exception $e) {
            return ['success' => false, 'msg' => $e->getMessage()];
        }
        return ['success' => true, 'msg' => '调拨确认成功'];
    }

    // 取消确认调拨，回退库存
    public function cancelConfirmTransfer($transferId, $params = [])
    {
        $transfer = BizStockTransfer::find($transferId);
        if (!$transfer) {
            return ['success' => false, 'msg' => '调拨单不存在'];
        }
        if ($transfer->status === '0') {
            return ['success' => false, 'msg' => '调拨单未确认，无需取消'];
        }
        $items = BizStockTransferItem::where('transfer_id', $transferId)->get();
        $fromWarehouseId = $transfer->from_warehouse_id;
        $toWarehouseId = $transfer->to_warehouse_id;
        try {
            Db::transaction(function () use ($transferId, $fromWarehouseId, $toWarehouseId, $items) {
                foreach ($items as $item) {
                    $productId = $item->product_id;
                    $quantity = intval($item->quantity);

                    // 目标仓库扣减
                    $toInventory = BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $toWarehouseId)
                        ->lockForUpdate()
                        ->first();
                    if (!$toInventory || $toInventory->quantity < $quantity) {
                        $product = BizProduct::find($productId);
                        $productName = $product ? $product->product_name : $productId;
                        $currentQty = $toInventory ? $toInventory->quantity : 0;
                        throw new \Exception("货品【{$productName}】目标仓库库存不足，当前库存：{$currentQty}，需回退数量：{$quantity}");
                    }
                    BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $toWarehouseId)
                        ->decrement('quantity', $quantity, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);

                    // 源仓库增加
                    $fromInventory = BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $fromWarehouseId)
                        ->first();
                    if (!$fromInventory) {
                        $product = BizProduct::find($productId);
                        BizInventory::create([
                            'product_id' => $productId,
                            'warehouse_id' => $fromWarehouseId,
                            'quantity' => 0,
                            'warn_qty' => $product ? ($product->warn_qty ?? 0) : 0,
                            'create_time' => date('Y-m-d H:i:s'),
                        ]);
                    }
                    BizInventory::where('product_id', $productId)
                        ->where('warehouse_id', $fromWarehouseId)
                        ->increment('quantity', $quantity, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);
                }

                // 更新调拨单状态为待确认
                BizStockTransfer::where('transfer_id', $transferId)->update([
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
