<?php

namespace app\service;

use app\model\BizStockPrepare;
use app\model\BizStockPrepareItem;
use app\model\BizStockPrepareOrder;
use app\model\BizCardItem;
use app\model\BizCardItemProduct;
use app\model\BizStockOut;
use app\model\BizStockOutItem;
use app\model\BizProduct;
use app\model\BizPlan;
use app\model\BizPlanItem;
use app\model\BizSalesOrder;
use app\service\DataScopeService;
use support\Db;


class BizStockPrepareService
{
    public function selectPrepareList($params = [])
    {
        $query = BizStockPrepare::query();
        if (!empty($params['enterprise_id'])) {
            $query->where('enterprise_id', $params['enterprise_id']);
        }
        if (!empty($params['store_id'])) {
            $query->where('store_id', $params['store_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['order_no'])) {
            $query->where('order_no', 'like', '%' . $params['order_no'] . '%');
        }
        if (!empty($params['prepare_no'])) {
            $query->where('prepare_no', 'like', '%' . $params['prepare_no'] . '%');
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('warehouse_id', $params['warehouse_id']);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->with('items.product', 'orders')->orderBy('prepare_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        // 补全字段
        // 批量获取方案信息，避免N+1查询
        $planIds = $result->pluck('plan_id')->filter()->unique()->toArray();
        $plans = BizPlan::whereIn('plan_id', $planIds)->get()->keyBy('plan_id');

        foreach ($result as $item) {
            $item->product_count = $item->items ? $item->items->count() : 0;
            $item->pending_quantity = $item->remaining_quantity;
            $item->pending_amount = $item->remaining_amount;
            // 补全方案关联信息
            $item->planId = $item->plan_id;
            $item->planNo = $item->plan_no;
            if ($item->plan_id) {
                $plan = $plans->get($item->plan_id);
                $item->planName = $plan ? $plan->plan_name : '';
            }
        }

        return $result;
    }

    public function selectPrepareById($prepareId)
    {
        $prepare = BizStockPrepare::with('items.product', 'orders')->find($prepareId);
        if (!$prepare) return null;

        // 补全主表字段
        $prepare->product_count = $prepare->items ? $prepare->items->count() : 0;
        $prepare->pending_quantity = $prepare->remaining_quantity;
        $prepare->pending_amount = $prepare->remaining_amount;
        // 补全方案关联信息
        $prepare->planId = $prepare->plan_id;
        $prepare->planNo = $prepare->plan_no;
        if ($prepare->plan_id) {
            $plan = BizPlan::where('plan_id', $prepare->plan_id)->first();
            $prepare->planName = $plan ? $plan->plan_name : '';
        }

        // 补全items字段
        if ($prepare->items) {
            // 批量获取字典值
            // 使用字典缓存接口，避免直接查表
            $unitDictList = SysDictTypeService::selectDictDataByType('biz_product_unit');
            $unitDicts = [];
            foreach ($unitDictList as $d) {
                $unitDicts[$d['dict_value']] = $d['dict_label'];
            }
            $specDictList = SysDictTypeService::selectDictDataByType('biz_product_spec');
            $specDicts = [];
            foreach ($specDictList as $d) {
                $specDicts[$d['dict_value']] = $d['dict_label'];
            }

            foreach ($prepare->items as $item) {
                $product = $item->product;
                $item->prepare_item_id = $item->item_id;
                $item->planItemId = $item->plan_item_id;
                $item->product_code = $product ? $product->product_code : '';
                $item->unit_label = isset($unitDicts[$item->unit]) ? $unitDicts[$item->unit] : '';
                $item->spec_label = isset($specDicts[$item->spec]) ? $specDicts[$item->spec] : '';
                $item->sale_price_spec = $product ? floatval($product->sale_price_spec) : 0;
                $item->main_sale_price = $product ? floatval($product->sale_price) : 0;
                $item->total_quantity = $item->quantity;
                $item->pending_quantity = $item->remaining_quantity;
                $item->pending_amount = $item->remaining_amount;
            }
        }

        if ($prepare->orders) {
            $orderIds = $prepare->orders->pluck('order_id')->toArray();
            $salesOrders = BizSalesOrder::whereIn('order_id', $orderIds)->get()->keyBy('order_id');
            foreach ($prepare->orders as $po) {
                $so = $salesOrders->get($po->order_id);
                if ($so) {
                    $po->deal_amount = $so->deal_amount;
                    $po->paid_amount = $so->paid_amount;
                    $po->owed_amount = $so->owed_amount;
                    $po->order_status = $so->order_status;
                    $po->source_type = $so->source_type;
                    $po->package_name = $so->package_name;
                    $po->creator_user_name = $so->creator_user_name;
                    $po->create_time = $so->create_time;
                }
            }
        }
        return $prepare;
    }

    public function addToEnterprisePrepare($order)
    {
        return Db::transaction(function () use ($order) {
            $existingOrder = BizStockPrepareOrder::where('order_id', $order->order_id)->first();
            if ($existingOrder) return null;

            $cardItemIds = [];
            $orderItemMap = [];

            foreach ($order->items as $orderItem) {
                $cardItemId = $orderItem->card_item_id ?? null;
                if ($cardItemId) {
                    $cardItemIds[] = $cardItemId;
                    if (!isset($orderItemMap[$cardItemId])) {
                        $orderItemMap[$cardItemId] = 0;
                    }
                    $orderItemMap[$cardItemId] += intval($orderItem->quantity ?? 1);
                }
            }

            if (empty($cardItemIds)) return null;

            $cardItemProducts = BizCardItemProduct::whereIn('card_item_id', $cardItemIds)->get();
            // 批量预加载卡项，避免循环内逐条查询（N+1）
            $cardItemMap = BizCardItem::whereIn('card_item_id', $cardItemIds)->get()->keyBy('card_item_id');

            $productQuantities = [];
            foreach ($cardItemProducts as $cip) {
                $orderItemQty = $orderItemMap[$cip->card_item_id] ?? 0;
                if ($orderItemQty <= 0) continue;

                $cardItem = $cardItemMap->get($cip->card_item_id);
                $defaultQty = $cardItem ? intval($cardItem->default_quantity) : 1;
                $perTimeQty = $defaultQty > 0 ? intval($cip->quantity) / $defaultQty : intval($cip->quantity);
                $quantity = $perTimeQty * $orderItemQty;

                $productId = $cip->product_id;
                if (!isset($productQuantities[$productId])) {
                    $productQuantities[$productId] = [
                        'product_id' => $productId,
                        'card_item_id' => $cip->card_item_id,
                        'unit_type' => $cip->unit_type,
                        'pack_qty' => $cip->pack_qty,
                        'quantity' => 0,
                    ];
                }
                $productQuantities[$productId]['quantity'] += $quantity;
            }

            if (empty($productQuantities)) return null;

            $newItemRecords = [];
            $totalQuantity = 0;
            $totalAmount = 0;

            foreach ($productQuantities as $pq) {
                $product = BizProduct::find($pq['product_id']);
                $packQty = intval($pq['pack_qty']) > 0 ? intval($pq['pack_qty']) : 1;

                // 统一存储为最小单位（副单位）：unit_type='1'时需要乘以pack_qty转换
                if ($pq['unit_type'] === '1' && $packQty > 1) {
                    $pq['quantity'] = $pq['quantity'] * $packQty;
                }

                // sale_price统一用副单位出货价（最小单位单价），与最小单位数量对应
                $salePrice = $product ? floatval($product->sale_price_spec) : 0;
                $amount = bcmul($pq['quantity'], $salePrice, 2);
                $totalQuantity += $pq['quantity'];
                $totalAmount = bcadd($totalAmount, $amount, 2);

                $newItemRecords[] = [
                    'product_id' => $pq['product_id'],
                    'product_name' => $product ? $product->product_name : '',
                    'unit' => $product ? $product->unit : null,
                    'spec' => $product ? $product->spec : null,
                    'unit_type' => $pq['unit_type'],
                    'pack_qty' => $pq['pack_qty'],
                    'sale_price' => $salePrice,
                    'quantity' => $pq['quantity'],
                    'amount' => $amount,
                    'remaining_quantity' => $pq['quantity'],
                    'remaining_amount' => $amount,
                ];
            }

            $existingPrepare = BizStockPrepare::where('enterprise_id', $order->enterprise_id)
                ->where('store_id', $order->store_id)
                ->whereIn('status', ['0', '1'])
                ->first();

            if ($existingPrepare) {
                $existingItems = BizStockPrepareItem::where('prepare_id', $existingPrepare->prepare_id)->get()->keyBy('product_id');

                foreach ($newItemRecords as $newItem) {
                    $productId = $newItem['product_id'];
                    if ($existingItems->has($productId)) {
                        $existingItem = $existingItems[$productId];
                        $newQuantity = intval($existingItem->quantity) + $newItem['quantity'];
                        $newAmount = bcadd(floatval($existingItem->amount), $newItem['amount'], 2);
                        $newRemainingQuantity = intval($existingItem->remaining_quantity) + $newItem['remaining_quantity'];
                        $newRemainingAmount = bcadd(floatval($existingItem->remaining_amount), $newItem['remaining_amount'], 2);

                        BizStockPrepareItem::where('item_id', $existingItem->item_id)->update([
                            'quantity' => $newQuantity,
                            'amount' => $newAmount,
                            'remaining_quantity' => $newRemainingQuantity,
                            'remaining_amount' => $newRemainingAmount,
                        ]);
                    } else {
                        $newItem['prepare_id'] = $existingPrepare->prepare_id;
                        $newItem['shipped_quantity'] = 0;
                        $newItem['shipped_amount'] = 0;
                        BizStockPrepareItem::create($newItem);
                    }
                }

                $newTotalQuantity = intval($existingPrepare->total_quantity) + $totalQuantity;
                $newTotalAmount = bcadd(floatval($existingPrepare->total_amount), $totalAmount, 2);
                $newRemainingQuantity = intval($existingPrepare->remaining_quantity) + $totalQuantity;
                $newRemainingAmount = bcadd(floatval($existingPrepare->remaining_amount), $totalAmount, 2);

                BizStockPrepare::where('prepare_id', $existingPrepare->prepare_id)->update([
                    'total_quantity' => $newTotalQuantity,
                    'total_amount' => $newTotalAmount,
                    'remaining_quantity' => $newRemainingQuantity,
                    'remaining_amount' => $newRemainingAmount,
                    'update_time' => date('Y-m-d H:i:s'),
                ]);

                BizStockPrepareOrder::create([
                    'prepare_id' => $existingPrepare->prepare_id,
                    'order_id' => $order->order_id,
                    'order_no' => $order->order_no,
                    'customer_id' => $order->customer_id,
                    'customer_name' => $order->customer_name,
                    'store_id' => $order->store_id,
                    'store_name' => $order->store_name,
                ]);

                return $existingPrepare;
            }

            $prepareNo = $this->generatePrepareNo();

            $prepare = BizStockPrepare::create([
                'prepare_no' => $prepareNo,
                'order_id' => $order->order_id,
                'order_no' => $order->order_no,
                'customer_id' => $order->customer_id,
                'customer_name' => $order->customer_name,
                'enterprise_id' => $order->enterprise_id,
                'enterprise_name' => $order->enterprise_name,
                'store_id' => $order->store_id,
                'store_name' => $order->store_name,
                'total_quantity' => $totalQuantity,
                'total_amount' => $totalAmount,
                'shipped_quantity' => 0,
                'shipped_amount' => 0,
                'remaining_quantity' => $totalQuantity,
                'remaining_amount' => $totalAmount,
                'status' => '0',
                'remark' => null,
                'create_by' => $order->create_by,
                'create_time' => date('Y-m-d H:i:s'),
            ]);

            foreach ($newItemRecords as $itemData) {
                $itemData['prepare_id'] = $prepare->prepare_id;
                $itemData['shipped_quantity'] = 0;
                $itemData['shipped_amount'] = 0;
                BizStockPrepareItem::create($itemData);
            }

            BizStockPrepareOrder::create([
                'prepare_id' => $prepare->prepare_id,
                'order_id' => $order->order_id,
                'order_no' => $order->order_no,
                'customer_id' => $order->customer_id,
                'customer_name' => $order->customer_name,
                'store_id' => $order->store_id,
                'store_name' => $order->store_name,
            ]);

            return $prepare;
        });
    }

    public function createStockOutFromPrepare($prepareId, $items, $warehouseId = null, $loginUser = null)
    {
        return Db::transaction(function () use ($prepareId, $items, $warehouseId, $loginUser) {
            $prepare = BizStockPrepare::find($prepareId);
            if (!$prepare) {
                return ['success' => false, 'msg' => '备货记录不存在'];
            }
            if ($prepare->status === '2') {
                return ['success' => false, 'msg' => '备货已出完，无法创建出库单'];
            }
            if ($prepare->status === '3') {
                return ['success' => false, 'msg' => '备货已取消，无法创建出库单'];
            }

            $prepareItems = BizStockPrepareItem::where('prepare_id', $prepareId)->get()->keyBy('item_id');

            $processedItems = [];
            $totalShipQuantity = 0;
            foreach ($items as $inputItem) {
                $itemId = $inputItem['item_id'] ?? 0;
                $originalQuantity = intval($inputItem['original_quantity'] ?? 0);
                if ($originalQuantity <= 0) continue;
                $prepareItem = $prepareItems->get($itemId);
                if (!$prepareItem) {
                    return ['success' => false, 'msg' => '备货明细不存在'];
                }

                $unitType = $inputItem['unit_type'] ?? '1';
                $packQty = intval($prepareItem->pack_qty ?? 1);
                $quantity = $originalQuantity;
                if ($unitType === '1' && $packQty > 1) {
                    $quantity = $originalQuantity * $packQty;
                }

                if ($quantity > intval($prepareItem->remaining_quantity)) {
                    return ['success' => false, 'msg' => '出库数量超过剩余数量'];
                }

                $processedItems[] = [
                    'item_id' => $itemId,
                    'unit_type' => $unitType,
                    'original_quantity' => $originalQuantity,
                    'quantity' => $quantity,
                    'prepare_item' => $prepareItem,
                ];
                $totalShipQuantity += $quantity;
            }

            if ($totalShipQuantity <= 0) {
                return ['success' => false, 'msg' => '出库数量不能为0'];
            }

            // warehouse_id 允许为空，在出库管理确认时再选择仓库

            $stockOutNo = $this->generateStockOutNo();
            $totalAmount = 0;
            $stockOutItemsData = [];

            foreach ($processedItems as $pi) {
                $prepareItem = $pi['prepare_item'];
                $product = BizProduct::find($prepareItem->product_id);
                $unitType = $pi['unit_type'];
                $packQty = intval($prepareItem->pack_qty ?? 1);

                $salePrice = $product ? floatval($product->sale_price_spec) : 0;

                $amount = bcmul($pi['quantity'], $salePrice, 2);
                $totalAmount = bcadd($totalAmount, $amount, 2);

                $stockOutItemsData[] = [
                    'product_id' => $prepareItem->product_id,
                    'product_name' => $prepareItem->product_name,
                    'plan_item_id' => $prepareItem->plan_item_id,
                    'spec' => $product ? $product->spec : '',
                    'unit' => $product ? $product->unit : '',
                    'unit_type' => $unitType,
                    'pack_qty' => $packQty,
                    'original_quantity' => $pi['original_quantity'],
                    'quantity' => $pi['quantity'],
                    'sale_price' => $salePrice,
                    'amount' => $amount,
                    'remark' => null,
                ];
            }

            $stockOut = BizStockOut::create([
                'stock_out_no' => $stockOutNo,
                'stock_out_type' => '1',
                'out_target_type' => '1',
                'prepare_id' => $prepareId,
                'plan_id' => $prepare->plan_id,
                'warehouse_id' => $warehouseId,
                'enterprise_id' => $prepare->enterprise_id,
                'enterprise_name' => $prepare->enterprise_name,
                'responsible_id' => $loginUser ? ($loginUser->user->user_id ?? null) : ($prepare->creator_user_id ?? null),
                'responsible_name' => $loginUser ? ($loginUser->user->nick_name ?? $loginUser->user->user_name ?? '') : ($prepare->create_by ?? ''),
                'total_quantity' => $totalShipQuantity,
                'total_amount' => $totalAmount,
                'stock_out_date' => date('Y-m-d'),
                'status' => '0',
                'ship_type' => '2',
                'remark' => null,
                'create_by' => $prepare->create_by,
                'create_time' => date('Y-m-d H:i:s'),
            ]);

            foreach ($stockOutItemsData as $itemData) {
                $itemData['stock_out_id'] = $stockOut->stock_out_id;
                BizStockOutItem::create($itemData);
            }

            $totalShippedAmount = 0;
            foreach ($processedItems as $pi) {
                $itemId = $pi['item_id'];
                $quantity = $pi['quantity'];
                $prepareItem = $pi['prepare_item'];

                $itemShippedAmount = bcmul($quantity, floatval($prepareItem->sale_price), 2);
                $totalShippedAmount = bcadd($totalShippedAmount, $itemShippedAmount, 2);

                BizStockPrepareItem::where('item_id', $itemId)->increment('shipped_quantity', $quantity);
                BizStockPrepareItem::where('item_id', $itemId)->decrement('remaining_quantity', $quantity);
                BizStockPrepareItem::where('item_id', $itemId)->increment('shipped_amount', $itemShippedAmount);
                BizStockPrepareItem::where('item_id', $itemId)->decrement('remaining_amount', $itemShippedAmount);
            }

            // 备货主表的 shipped/remaining/status 在出库单发货时更新，不在创建出库单时更新

            return ['success' => true, 'msg' => '出库单创建成功', 'data' => $stockOut];
        });
    }

    public function generatePrepareNo()
    {
        $date = date('Ymd');
        $key = 'prepare_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'SP' . $date . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }

    private function generateStockOutNo()
    {
        $date = date('Ymd');
        $key = 'stock_out_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'CK' . $date . str_pad($seq, 3, '0', STR_PAD_LEFT);
    }

    /**
     * 从方案创建备货记录（分批次备货）
     * @param int $planId 方案ID
     * @param array $items 备货明细数组，每项含：productId, quantity, planItemId(可选), unitType(可选)
     * @return bool
     */
    public function createFromPlan($planId, $items, $loginUser = null)
    {
        // 3.1 校验方案存在且 audit_status=2
        $plan = BizPlan::find($planId);
        if (!$plan) {
            throw new \Exception('方案不存在');
        }
        if ($plan->audit_status != 2) {
            throw new \Exception('方案未审核通过，无法备货');
        }

        // 3.2 校验备货金额
        $planService = new BizPlanService();
        $activePreparedAmount = $planService->getActivePreparedAmount($planId);

        // 计算本次备货总金额
        $totalAmount = 0;
        $totalQuantity = 0;
        $prepareItems = [];

        foreach ($items as $item) {
            $product = BizProduct::find($item['productId']);
            if (!$product) {
                throw new \Exception('货品不存在：' . ($item['productId'] ?? ''));
            }

            $unitType = $item['unitType'] ?? '1';
            $packQty = $product->pack_qty ?? 1;

            // 数量统一转为副单位（最小单位），与进销存一致
            $quantity = $item['quantity'];
            if ($unitType === '1') {
                $quantity = $item['quantity'] * $packQty;
            }

            // sale_price 统一用副单位价（与进销存一致）
            $salePrice = $product->sale_price_spec;

            // 金额 = 副单位数量 × 副单位价
            $amount = $quantity * $salePrice;

            // 3.5 如果方案有配赠明细，校验 plan_item_id 和数量
            $planItemId = $item['planItemId'] ?? null;
            if ($planItemId) {
                $planItem = BizPlanItem::find($planItemId);
                if (!$planItem || $planItem->plan_id != $planId) {
                    throw new \Exception('方案明细不存在或不属于该方案');
                }
                // 方案明细 remaining_quantity 换算成副单位（最小单位）比较
                $planItemPackQty = intval($planItem->pack_qty ?? 1);
                $planItemUnitType = $planItem->unit_type ?? '1';
                $planItemRemaining = intval($planItem->remaining_quantity);
                if ($planItemUnitType === '1' && $planItemPackQty > 1) {
                    $planItemRemaining = $planItemRemaining * $planItemPackQty;
                }
                if ($quantity > $planItemRemaining) {
                    throw new \Exception('备货数量超过方案明细剩余数量：' . $product->product_name);
                }
            }

            $totalAmount += $amount;
            $totalQuantity += $quantity;

            $prepareItems[] = [
                'plan_item_id' => $planItemId,
                'product_id' => $product->product_id,
                'product_name' => $product->product_name,
                'unit' => $product->unit,
                'spec' => $product->spec,
                'unit_type' => $unitType,
                'pack_qty' => $packQty,
                'sale_price' => $product->sale_price_spec, // 统一用最小单位单价
                'quantity' => $quantity,
                'amount' => $amount,
                'remaining_quantity' => $quantity,
                'remaining_amount' => $amount,
                'shipped_quantity' => 0,
                'shipped_amount' => 0,
            ];
        }

        if ($totalAmount + $activePreparedAmount + $plan->shipped_amount > $plan->gift_amount) {
            throw new \Exception('备货总金额超过方案配赠金额剩余额度');
        }

        // 3.3 创建备货主表 + 明细 + 自动创建出库单（事务保证原子性）
        $prepareNo = $this->generatePrepareNo();
        return Db::transaction(function () use ($prepareNo, $planId, $plan, $totalQuantity, $totalAmount, $prepareItems, $loginUser) {
            $prepare = BizStockPrepare::create([
                'prepare_no' => $prepareNo,
                'plan_id' => $planId,
                'plan_no' => $plan->plan_no,
                'enterprise_id' => $plan->enterprise_id,
                'enterprise_name' => $plan->enterprise->enterprise_name ?? '',
                'warehouse_id' => null,
                'total_quantity' => $totalQuantity,
                'total_amount' => $totalAmount,
                'remaining_quantity' => $totalQuantity,
                'remaining_amount' => $totalAmount,
                'shipped_quantity' => 0,
                'shipped_amount' => 0,
                'status' => '0',
                'create_by' => $loginUser ? ($loginUser->user->user_name ?? '') : ($plan->create_by ?? ''),
                'creator_user_id' => $loginUser ? ($loginUser->user->user_id ?? null) : null,
                'create_time' => date('Y-m-d H:i:s'),
            ]);

            // 创建备货明细
            $createdItems = [];
            foreach ($prepareItems as $item) {
                $item['prepare_id'] = $prepare->prepare_id;
                $createdItem = BizStockPrepareItem::create($item);
                $createdItems[] = $createdItem;
            }

            // 自动创建出库单（不选仓库，仓库在出库管理确认时选择）
            $stockOutItems = [];
            foreach ($createdItems as $createdItem) {
                $stockOutItems[] = [
                    'item_id' => $createdItem->item_id,
                    'unit_type' => $createdItem->unit_type ?? '1',
                    'original_quantity' => $createdItem->unit_type === '1' && intval($createdItem->pack_qty) > 1
                        ? intval($createdItem->quantity) / intval($createdItem->pack_qty)
                        : intval($createdItem->quantity),
                ];
            }
            $result = $this->createStockOutFromPrepare($prepare->prepare_id, $stockOutItems, null, $loginUser);
            if (!$result['success']) {
                throw new \Exception($result['msg']);
            }

            return true;
        });
    }
}
