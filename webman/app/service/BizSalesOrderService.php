<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizCustomerPackage;
use app\model\BizPackageItem;
use app\model\BizCardItem;
use app\service\BizCustomerArchiveService;
use app\service\BizStockPrepareService;
use app\service\DataScopeService;
use app\service\SysConfigService;
use support\Db;

/**
 * 销售订单服务层，处理订单的增删改查、审核、自动生成客户套餐和写入客户档案
 */
class BizSalesOrderService
{
    // 按条件分页查询销售订单列表
    public function selectOrderList($params = [])
    {
        $query = BizSalesOrder::query();
        if (!empty($params['customer_id'])) $query->where('customer_id', $params['customer_id']);
        if (!empty($params['order_no'])) $query->where('order_no', 'like', '%' . $params['order_no'] . '%');
        if (!empty($params['customer_name'])) $query->where('customer_name', 'like', '%' . $params['customer_name'] . '%');
        if (!empty($params['enterprise_id'])) $query->where('enterprise_id', $params['enterprise_id']);
        if (!empty($params['store_id'])) $query->where('store_id', $params['store_id']);
        if (isset($params['order_status']) && $params['order_status'] !== '') $query->where('order_status', $params['order_status']);
        if (!empty($params['creator_user_id'])) $query->where('creator_user_id', $params['creator_user_id']);
        if (isset($params['enterprise_audit_status']) && $params['enterprise_audit_status'] !== '') $query->where('enterprise_audit_status', $params['enterprise_audit_status']);
        if (isset($params['finance_audit_status']) && $params['finance_audit_status'] !== '') $query->where('finance_audit_status', $params['finance_audit_status']);
        if (!empty($params['start_date'])) $query->where('create_time', '>=', $params['start_date'] . ' 00:00:00');
        if (!empty($params['end_date'])) $query->where('create_time', '<=', $params['end_date'] . ' 23:59:59');
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('creator_user_id', $visibleUserIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->with('items')->orderBy('order_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
        return $result;
    }

    // 根据ID查询销售订单详情，含明细列表

    public function selectOrderById($orderId)
    {
        return BizSalesOrder::with('items')->find($orderId);
    }

    public function generateOrderNo()
    {
        $date = date('Ymd');
        $key = 'order_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'SO' . $date . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }

    // 新增销售订单，生成订单编号并创建明细

    public function insertOrder($data, $items = [])
    {
        return Db::transaction(function () use ($data, $items) {
            $data['order_no'] = $this->generateOrderNo();
            $data['create_time'] = date('Y-m-d H:i:s');
            $data['enterprise_audit_status'] = '0';
            $data['finance_audit_status'] = '0';

            $dealAmount = 0;
            $paidAmount = 0;
            $paymentMethodCount = [];

            // 读取业务配置
            $quantityEditable = SysConfigService::getConfigValue('biz.sales.packageQuantityEditable', 'true') !== 'false';
            $dealAmountEditable = SysConfigService::getConfigValue('biz.sales.packageDealAmountEditable', 'true') !== 'false';
            $paidAmountEditable = SysConfigService::getConfigValue('biz.sales.packagePaidAmountEditable', 'true') !== 'false';

            $convertedItems = [];
            foreach ($items as $item) {
                // 配置校验：如果品项关联了卡项，检查是否允许修改次数/金额
                $cardItemId = $item['card_item_id'] ?? $item['cardItemId'] ?? null;
                if (!empty($cardItemId)) {
                    $cardItem = BizCardItem::find($cardItemId);
                    if ($cardItem) {
                        $itemQuantity = intval($item['count'] ?? $item['quantity'] ?? 1);
                        $itemDealAmount = floatval($item['price'] ?? $item['deal_amount'] ?? $item['dealPrice'] ?? 0);
                        $itemPaidAmount = floatval($item['paid_amount'] ?? $item['paidAmount'] ?? 0);
                        // 如果不允许修改次数，校验提交的次数是否与默认次数一致
                        if (!$quantityEditable && $itemQuantity != $cardItem->default_quantity) {
                            throw new \Exception('系统配置不允许修改套餐次数');
                        }
                        // 如果不允许修改成交金额，校验提交的成交金额是否与建议价格一致
                        if (!$dealAmountEditable && $itemDealAmount != $cardItem->suggested_price) {
                            throw new \Exception('系统配置不允许修改套餐成交金额');
                        }
                        // 如果不允许修改实付金额，校验提交的实付金额是否与成交金额一致
                        if (!$paidAmountEditable && $itemPaidAmount != $itemDealAmount) {
                            throw new \Exception('系统配置不允许修改套餐实付金额');
                        }
                    }
                }

                $itemPaymentMethod = $item['payment_method'] ?? $item['paymentMethod'] ?? 'cash';

                if ($itemPaymentMethod === 'gift') {
                    $item['price'] = 0;
                    $item['deal_amount'] = 0;
                    $item['paid_amount'] = 0;
                    $item['paidAmount'] = 0;
                    $item['dealPrice'] = 0;
                }

                $quantity = intval($item['count'] ?? $item['quantity'] ?? 1);
                $itemDealAmount = floatval($item['price'] ?? $item['deal_amount'] ?? $item['dealPrice'] ?? 0);
                $itemPaidAmount = floatval($item['paid_amount'] ?? $item['paidAmount'] ?? 0);
                $itemOwedAmount = $itemDealAmount - $itemPaidAmount;
                $unitPrice = $quantity > 0 ? round($itemDealAmount / $quantity, 2) : 0;

                $convertedItem = [
                    'card_item_id' => $item['card_item_id'] ?? $item['cardItemId'] ?? null,
                    'product_name' => $item['item_name'] ?? $item['product_name'] ?? $item['productName'] ?? '',
                    'quantity' => $quantity,
                    'deal_amount' => $itemDealAmount,
                    'paid_amount' => $itemPaidAmount,
                    'unit_price' => $unitPrice,
                    'owed_amount' => $itemOwedAmount,
                    'payment_method' => $itemPaymentMethod,
                    'remark' => $item['remark'] ?? null,
                    'create_time' => date('Y-m-d H:i:s')
                ];
                $convertedItems[] = $convertedItem;

                $dealAmount += $itemDealAmount;
                $paidAmount += $itemPaidAmount;
                $paymentMethodCount[$itemPaymentMethod] = ($paymentMethodCount[$itemPaymentMethod] ?? 0) + 1;
            }

            $data['deal_amount'] = $dealAmount;
            $data['paid_amount'] = $paidAmount;
            $data['owed_amount'] = $dealAmount - $paidAmount;

            if (empty($data['payment_method']) && !empty($paymentMethodCount)) {
                arsort($paymentMethodCount);
                $data['payment_method'] = array_key_first($paymentMethodCount);
            }

            if (!isset($data['order_status'])) {
                $data['order_status'] = '0';
            }

            $order = BizSalesOrder::create($data);

            foreach ($convertedItems as $item) {
                $item['order_id'] = $order->order_id;
                BizOrderItem::create($item);
            }

            if (!empty($convertedItems)) {
                $this->generatePackage($order, $convertedItems);
            }

            try {
                $archiveService = new BizCustomerArchiveService();
                $archiveService->insertArchiveFromOrder($order);
            } catch (\Exception $e) {
                \support\Log::error('写入开单档案失败: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            }

            return $order;
        });
    }

    // 更新销售订单信息

    public function updateOrder($data, $items = [])
    {
        return Db::transaction(function () use ($data, $items) {
            $order = BizSalesOrder::find($data['order_id']);
            if (!$order) {
                throw new \Exception('订单不存在');
            }
            if (in_array($order->enterprise_audit_status, ['1', '2']) || in_array($order->finance_audit_status, ['1', '2'])) {
                throw new \Exception('订单已审核，不可修改');
            }

            $data['update_time'] = date('Y-m-d H:i:s');

            if (!empty($items)) {
                $dealAmount = 0;
                $paidAmount = 0;
                $paymentMethodCount = [];
                foreach ($items as &$item) {
                    $itemPaymentMethod = $item['payment_method'] ?? $item['paymentMethod'] ?? 'cash';
                    if ($itemPaymentMethod === 'gift') {
                        $item['deal_amount'] = 0;
                        $item['paid_amount'] = 0;
                        $item['owed_amount'] = 0;
                        $item['unit_price'] = 0;
                    }
                    $item['payment_method'] = $itemPaymentMethod;
                    $dealAmount += floatval($item['deal_amount'] ?? 0);
                    $paidAmount += floatval($item['paid_amount'] ?? 0);
                    $paymentMethodCount[$itemPaymentMethod] = ($paymentMethodCount[$itemPaymentMethod] ?? 0) + 1;
                }
                unset($item);
                $data['deal_amount'] = $dealAmount;
                $data['paid_amount'] = $paidAmount;
                $data['owed_amount'] = $dealAmount - $paidAmount;
                if (empty($data['payment_method']) && !empty($paymentMethodCount)) {
                    arsort($paymentMethodCount);
                    $data['payment_method'] = array_key_first($paymentMethodCount);
                }
            }

            $result = BizSalesOrder::where('order_id', $data['order_id'])->update($data);

            if (!empty($items)) {
                BizOrderItem::where('order_id', $data['order_id'])->delete();
                foreach ($items as $item) {
                    $item['order_id'] = $data['order_id'];
                    $item['create_time'] = date('Y-m-d H:i:s');
                    BizOrderItem::create($item);
                }
            }

            return $result;
        });
    }

    // 批量删除销售订单

    public function deleteOrderByIds($orderIds)
    {
        return Db::transaction(function () use ($orderIds) {
            BizOrderItem::whereIn('order_id', $orderIds)->delete();
            return BizSalesOrder::whereIn('order_id', $orderIds)->delete();
        });
    }

    // 企业审核订单

    public function enterpriseAudit($orderId, $auditBy)
    {
        $order = BizSalesOrder::find($orderId);
        if (!$order) {
            throw new \Exception('订单不存在');
        }
        if ($order->enterprise_audit_status !== '0') {
            throw new \Exception('订单已审核，不可重复审核');
        }

        return BizSalesOrder::where('order_id', $orderId)->update([
            'enterprise_audit_status' => '1',
            'enterprise_audit_by' => $auditBy,
            'enterprise_audit_time' => date('Y-m-d H:i:s'),
            'order_status' => '1'
        ]);
    }

    // 财务审核订单

    public function financeAudit($orderId, $auditBy)
    {
        return Db::transaction(function () use ($orderId, $auditBy) {
            $order = BizSalesOrder::where('order_id', $orderId)->lockForUpdate()->first();
            if (!$order) return false;
            if ($order->enterprise_audit_status !== '1') return false;
            $result = BizSalesOrder::where('order_id', $orderId)->update([
                'finance_audit_status' => '1',
                'finance_audit_by' => $auditBy,
                'finance_audit_time' => date('Y-m-d H:i:s'),
                'order_status' => '2'
            ]);
            if ($result) {
                try {
                    $order = BizSalesOrder::with('items')->find($orderId);
                    if ($order) {
                        \support\Log::info('财务审核-开始生成企业库存', [
                            'order_id' => $orderId,
                            'order_no' => $order->order_no,
                            'items_count' => $order->items->count(),
                            'items_card_item_ids' => $order->items->pluck('card_item_id')->toArray(),
                        ]);
                        $prepareService = new BizStockPrepareService();
                        $prepareResult = $prepareService->addToEnterprisePrepare($order);
                        \support\Log::info('财务审核-企业库存生成结果', [
                            'order_id' => $orderId,
                            'prepare_result' => $prepareResult ? 'success: prepare_id=' . ($prepareResult->prepare_id ?? 'merged') : 'null',
                        ]);
                    }
                } catch (\Exception $e) {
                    \support\Log::error('生成企业库存失败: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
                }
            }
            return $result;
        });
    }

    public function cancelOrder($orderId)
    {
        $order = BizSalesOrder::find($orderId);
        if (!$order) return false;
        if ($order->order_status !== '0') return false;
        return BizSalesOrder::where('order_id', $orderId)->update([
            'order_status' => '4',
            'update_time' => date('Y-m-d H:i:s')
        ]);
    }

    public function generatePackage($order, $items)
    {
        if (empty($items)) return;

        $packageNo = $this->generatePackageNo();
        $packageName = !empty($order->package_name) ? $order->package_name : ($order->customer_name . ' ' . date('Y-m-d') . ' 持卡记录');

        $paidAmount = 0;
        foreach ($items as $item) {
            $paidAmount += floatval($item['paid_amount'] ?? 0);
        }
        $owedAmount = floatval($order->deal_amount) - $paidAmount;

        $package = BizCustomerPackage::create([
            'package_no' => $packageNo,
            'customer_id' => $order->customer_id,
            'customer_name' => $order->customer_name,
            'order_id' => $order->order_id,
            'order_no' => $order->order_no,
            'enterprise_id' => $order->enterprise_id,
            'enterprise_name' => $order->enterprise_name ?? '',
            'store_id' => $order->store_id,
            'store_name' => $order->store_name ?? '',
            'package_name' => $packageName,
            'total_amount' => $order->deal_amount,
            'paid_amount' => $paidAmount,
            'owed_amount' => $owedAmount,
            'status' => '1',
            'remark' => $order->remark ?? null,
            'create_by' => $order->create_by,
            'create_time' => date('Y-m-d H:i:s')
        ]);

        foreach ($items as $item) {
            $quantity = intval($item['quantity'] ?? 1);
            $dealPrice = floatval($item['deal_amount'] ?? 0);
            $itemPaidAmount = floatval($item['paid_amount'] ?? 0);
            $itemOwedAmount = floatval($item['owed_amount'] ?? 0);
            $unitPrice = floatval($item['unit_price'] ?? ($quantity > 0 ? round($dealPrice / $quantity, 2) : 0));
            BizPackageItem::create([
                'package_id' => $package->package_id,
                'card_item_id' => $item['card_item_id'] ?? null,
                'product_name' => $item['product_name'],
                'unit_price' => $unitPrice,
                'plan_price' => floatval($item['plan_price'] ?? $dealPrice),
                'deal_price' => $dealPrice,
                'paid_amount' => $itemPaidAmount,
                'owed_amount' => $itemOwedAmount,
                'total_quantity' => $quantity,
                'used_quantity' => 0,
                'remaining_quantity' => $quantity,
                'remark' => $item['remark'] ?? null
            ]);
        }
    }

    private function generatePackageNo()
    {
        $date = date('Ymd');
        $key = 'package_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'PK' . $date . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }
}
