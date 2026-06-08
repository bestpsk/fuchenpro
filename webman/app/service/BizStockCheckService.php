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
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('operator_id', $visibleUserIds);
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
            $items = BizStockCheckItem::where('stock_check_id', $stockCheckId)->get();
            $stockCheck->items = $items->map(function ($item) {
                $product = BizProduct::find($item->product_id);
                $item->pack_qty = $product ? ($product->pack_qty ?? 1) : 1;
                return $item;
            });
        }
        return $stockCheck;
    }

    public function generateStockCheckNo()
    {
        $prefix = 'PD' . date('Ymd');
        $last = BizStockCheck::where('stock_check_no', 'like', $prefix . '%')
            ->orderBy('stock_check_id', 'desc')
            ->first();
        $seq = 1;
        if ($last) {
            $lastSeq = intval(substr($last->stock_check_no, -3));
            $seq = $lastSeq + 1;
        }
        return $prefix . str_pad($seq, 3, '0', STR_PAD_LEFT);
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
        Db::transaction(function () use ($stockCheckId, $data, $items) {
            BizStockCheck::where('stock_check_id', $stockCheckId)->update($data);
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
            Db::transaction(function () use ($stockCheckId, $items) {
                foreach ($items as $item) {
                    if ($item->diff_quantity == 0) {
                        continue;
                    }

                    $unitType = $item->unit_type ?? '1';
                    $packQty = intval($item->pack_qty ?? 1);
                    $actualQuantity = intval($item->actual_quantity);

                    if ($unitType === '1' && $packQty > 1) {
                        $actualQuantity = intval($item->original_quantity ?? $item->actual_quantity) * $packQty;
                    }

                    $systemQuantity = intval($item->system_quantity);
                    $diffQuantity = $actualQuantity - $systemQuantity;

                    $inventory = BizInventory::where('product_id', $item->product_id)->lockForUpdate()->first();
                    if (!$inventory) {
                        $product = BizProduct::find($item->product_id);
                        BizInventory::create([
                            'product_id' => $item->product_id,
                            'quantity' => 0,
                            'warn_qty' => $product->warn_qty ?? 0,
                            'create_time' => date('Y-m-d H:i:s'),
                        ]);
                    }

                    if ($diffQuantity > 0) {
                        BizInventory::where('product_id', $item->product_id)->increment('quantity', $diffQuantity, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);
                    } else {
                        $absDiff = abs($diffQuantity);
                        $currentInventory = BizInventory::where('product_id', $item->product_id)->lockForUpdate()->first();
                        if ($currentInventory->quantity < $absDiff) {
                            $product = BizProduct::find($item->product_id);
                            $productName = $product ? $product->product_name : $item->product_id;
                            throw new \Exception("产品【{$productName}】调整后库存为负数，当前库存：{$currentInventory->quantity}，调整数量：-{$absDiff}");
                        }
                        BizInventory::where('product_id', $item->product_id)->decrement('quantity', $absDiff, [
                            'update_time' => date('Y-m-d H:i:s'),
                        ]);
                    }
                }
                BizStockCheck::where('stock_check_id', $stockCheckId)->update([
                    'status' => '1',
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            });
        } catch (\Exception $e) {
            return ['success' => false, 'msg' => $e->getMessage()];
        }
        return ['success' => true, 'msg' => '盘点确认成功'];
    }

    public function loadInventoryData($params = [])
    {
        $products = BizProduct::where('status', '0')->get();
        $items = [];
        foreach ($products as $product) {
            $inventory = BizInventory::where('product_id', $product->product_id)->first();
            $items[] = [
                'product_id' => $product->product_id,
                'product_name' => $product->product_name,
                'spec' => $product->spec,
                'unit' => $product->unit,
                'unit_type' => '1',
                'pack_qty' => $product->pack_qty ?? 1,
                'system_quantity' => $inventory ? $inventory->quantity : 0,
                'actual_quantity' => $inventory ? $inventory->quantity : 0,
                'diff_quantity' => 0,
            ];
        }
        return $items;
    }
}
