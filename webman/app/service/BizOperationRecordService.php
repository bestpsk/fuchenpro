<?php

namespace app\service;

use app\model\BizOperationRecord;
use app\model\BizPackageItem;
use app\model\BizCustomerPackage;
use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\service\BizCustomerArchiveService;
use app\service\DataScopeService;
use support\Db;

/**
 * 操作记录服务层
 *
 * 处理操作记录的核心业务逻辑，包括列表查询、新增记录（含套餐扣减和档案写入）、
 * 批量删除、详情查询（含批次聚合和企业/门店名称回填）
 */
class BizOperationRecordService
{
    // 按条件分页查询操作记录列表，关联客户套餐表获取套餐名称
    public function selectRecordList($params = [])
    {
        $query = BizOperationRecord::query();
        if (!empty($params['customer_id'])) $query->where('biz_operation_record.customer_id', $params['customer_id']);
        if (!empty($params['enterprise_id'])) $query->where('biz_operation_record.enterprise_id', $params['enterprise_id']);
        if (!empty($params['store_id'])) $query->where('biz_operation_record.store_id', $params['store_id']);
        if (!empty($params['package_id'])) $query->where('biz_operation_record.package_id', $params['package_id']);
        if (!empty($params['operation_date'])) $query->where('operation_date', $params['operation_date']);
        if (isset($params['operation_type']) && $params['operation_type'] !== '') $query->where('operation_type', $params['operation_type']);
        if (!empty($params['start_date'])) $query->where('operation_date', '>=', $params['start_date']);
        if (!empty($params['end_date'])) $query->where('operation_date', '<=', $params['end_date']);
        if (!empty($params['product_name'])) $query->where('product_name', 'like', '%' . $params['product_name'] . '%');
        if (!empty($params['operator_user_id'])) $query->where('operator_user_id', $params['operator_user_id']);
        if (!empty($params['satisfaction'])) $query->where('satisfaction', $params['satisfaction']);
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('operator_user_id', $visibleUserIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $query->leftJoin('biz_customer_package as cp', 'biz_operation_record.package_id', '=', 'cp.package_id')
            ->addSelect('biz_operation_record.*', 'cp.package_name');
        return $query->orderBy('record_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 新增操作记录：自动生成批次号，套餐消费时扣减套餐项目次数并检查套餐是否用完，非套餐消费时清空套餐关联字段，最后写入客户档案
    public function insertRecord($data)
    {
        return Db::transaction(function () use ($data) {
            $data['create_time'] = date('Y-m-d H:i:s');
            if (empty($data['operation_date'])) $data['operation_date'] = date('Y-m-d');
            if (empty($data['operation_type'])) $data['operation_type'] = '0';

            if (empty($data['operation_batch_id'])) {
                $data['operation_batch_id'] = 'OB' . date('YmdHis') . str_pad(random_int(0, 9999), 4, '0', STR_PAD_LEFT);
            }

            if ($data['operation_type'] === '0' && !empty($data['package_item_id'])) {
                $packageItem = BizPackageItem::find($data['package_item_id']);
                if ($packageItem) {
                    if (empty($data['consume_amount'])) {
                        $data['consume_amount'] = round($packageItem->unit_price * intval($data['operation_quantity'] ?? 1), 2);
                    }

                    $qty = intval($data['operation_quantity'] ?? 1);

                    // 条件increment，原子检查+扣减
                    $affected = BizPackageItem::where('package_item_id', $packageItem->package_item_id)
                        ->whereRaw('used_quantity + ? <= total_quantity', [$qty])
                        ->increment('used_quantity', $qty);
                    if ($affected === 0) {
                        throw new \Exception('套餐项目剩余次数不足');
                    }

                    // 更新 remaining_quantity
                    $freshItem = BizPackageItem::find($packageItem->package_item_id);
                    $remaining = $freshItem->total_quantity - $freshItem->used_quantity;
                    if ($remaining < 0) $remaining = 0;
                    BizPackageItem::where('package_item_id', $packageItem->package_item_id)->update(['remaining_quantity' => $remaining]);

                    if ($remaining <= 0) {
                        $allUsed = BizPackageItem::where('package_id', $packageItem->package_id)
                            ->where('remaining_quantity', '>', 0)->count();
                        if ($allUsed === 0) {
                            BizCustomerPackage::where('package_id', $packageItem->package_id)
                                ->update(['status' => '2', 'update_time' => date('Y-m-d H:i:s')]);
                        }
                    }

                    if (empty($data['enterprise_name']) || empty($data['store_name'])) {
                        $package = BizCustomerPackage::find($packageItem->package_id);
                        if ($package) {
                            if (empty($data['enterprise_name'])) $data['enterprise_name'] = $package->enterprise_name ?? '';
                            if (empty($data['store_name'])) $data['store_name'] = $package->store_name ?? '';
                        }
                    }
                }
            }

            if ($data['operation_type'] === '1') {
                $data['package_id'] = null;
                $data['package_no'] = null;
                $data['package_item_id'] = null;
                $data['consume_amount'] = 0;
            }

            if (empty($data['enterprise_id']) || empty($data['enterprise_name']) || empty($data['store_id']) || empty($data['store_name'])) {
                if (!empty($data['customer_id'])) {
                    $customer = \app\model\BizCustomer::find($data['customer_id']);
                    if ($customer) {
                        if (empty($data['enterprise_id'])) $data['enterprise_id'] = $customer->enterprise_id;
                        if (empty($data['enterprise_name'])) $data['enterprise_name'] = $customer->enterprise_name ?? '';
                        if (empty($data['store_id'])) $data['store_id'] = $customer->store_id;
                        if (empty($data['store_name'])) $data['store_name'] = $customer->store_name ?? '';
                    }
                }
            }

            $record = BizOperationRecord::create($data);

            try {
                $this->createOperationOrder($record, $data);
            } catch (\Throwable $e) {
                \support\Log::error('创建操作订单失败: ' . $e->getMessage(), [
                    'record_id' => $record->record_id ?? 'unknown',
                    'file' => $e->getFile(),
                    'line' => $e->getLine()
                ]);
            }

            try {
                $archiveService = new BizCustomerArchiveService();
                $result = $archiveService->insertArchiveFromOperation($record);
                if (!$result) {
                    \support\Log::warning('操作档案返回null', [
                        'record_id' => $record->record_id,
                        'customer_id' => $record->customer_id ?? 'NULL'
                    ]);
                }
            } catch (\Throwable $e) {
                \support\Log::error('写入操作档案失败: ' . $e->getMessage(), [
                    'record_id' => $record->record_id ?? 'unknown',
                    'file' => $e->getFile(),
                    'line' => $e->getLine()
                ]);
            }

            return $record;
        });
    }

    // 根据ID批量删除操作记录
    public function deleteRecordByIds($recordIds)
    {
        return BizOperationRecord::whereIn('record_id', $recordIds)->delete();
    }

    // 根据ID获取操作记录基本信息
    public function getRecordById($id)
    {
        return BizOperationRecord::find($id);
    }

    // 获取操作记录详情，聚合同一批次的所有操作项目，并回填企业名称和门店名称
    public function getRecordDetailById($id)
    {
        $record = BizOperationRecord::find($id);
        if (!$record) return null;

        if (!empty($record->operation_batch_id)) {
            $batchRecords = BizOperationRecord::where('operation_batch_id', $record->operation_batch_id)
                ->orderBy('record_id', 'asc')
                ->get();
        } elseif ($record->operation_type === '1') {
            $batchRecords = collect([$record]);
        } else {
            $batchRecords = collect([$record]);
        }

        $enterpriseName = $record->enterprise_name;
        $storeName = $record->store_name;

        if (!$enterpriseName || !$storeName) {
            if (!empty($record->package_id)) {
                $pkg = \app\model\BizCustomerPackage::where('package_id', $record->package_id)->first();
                if ($pkg) {
                    if (!$enterpriseName) $enterpriseName = $pkg->enterprise_name;
                    if (!$storeName) $storeName = $pkg->store_name;
                    if (!$storeName && !empty($pkg->order_id)) {
                        $order = \app\model\BizSalesOrder::find($pkg->order_id);
                        if ($order) {
                            if (!$enterpriseName) $enterpriseName = $order->enterprise_name;
                            $storeName = $order->store_name;
                        }
                    }
                }
            }
            if ((!$enterpriseName || !$storeName) && !empty($record->customer_id)) {
                $customer = \app\model\BizCustomer::find($record->customer_id);
                if ($customer) {
                    if (!$enterpriseName) $enterpriseName = $customer->enterprise_name;
                    if (!$storeName) $storeName = $customer->store_name;
                }
            }
        }

        return [
            'record' => $record->toArray(),
            'items' => $batchRecords->toArray(),
            'enterprise_name' => $enterpriseName,
            'store_name' => $storeName,
            'total_amount' => $batchRecords->sum('consume_amount') + $batchRecords->sum('trial_price'),
            'item_count' => $batchRecords->count()
        ];
    }

    private function createOperationOrder($record, $data)
    {
        $orderNo = $this->generateOperationOrderNo();
        $amount = floatval($record->consume_amount ?? 0) + floatval($record->trial_price ?? 0);

        $enterpriseName = $record->enterprise_name ?? '';
        $storeName = $record->store_name ?? '';

        if (empty($enterpriseName) || empty($storeName)) {
            if (!empty($record->package_id)) {
                $pkg = \app\model\BizCustomerPackage::where('package_id', $record->package_id)->first();
                if ($pkg) {
                    if (empty($enterpriseName)) $enterpriseName = $pkg->enterprise_name ?? '';
                    if (empty($storeName)) $storeName = $pkg->store_name ?? '';
                    if (empty($storeName) && !empty($pkg->order_id)) {
                        $order = \app\model\BizSalesOrder::find($pkg->order_id);
                        if ($order) {
                            if (empty($enterpriseName)) $enterpriseName = $order->enterprise_name ?? '';
                            $storeName = $order->store_name ?? '';
                        }
                    }
                }
            }
            if ((empty($enterpriseName) || empty($storeName)) && !empty($record->customer_id)) {
                $customer = \app\model\BizCustomer::find($record->customer_id);
                if ($customer) {
                    if (empty($enterpriseName)) $enterpriseName = $customer->enterprise_name ?? '';
                    if (empty($storeName)) $storeName = $customer->store_name ?? '';
                }
            }
        }

        $order = BizSalesOrder::create([
            'order_no' => $orderNo,
            'customer_id' => $record->customer_id,
            'customer_name' => $record->customer_name ?? '',
            'enterprise_id' => $record->enterprise_id ?? null,
            'enterprise_name' => $enterpriseName,
            'store_id' => $record->store_id ?? null,
            'store_name' => $storeName,
            'deal_amount' => $amount,
            'paid_amount' => 0,
            'owed_amount' => $amount,
            'order_status' => '1',
            'source_type' => '1',
            'operation_batch_id' => $record->operation_batch_id,
            'package_name' => $record->product_name ?? '',
            'enterprise_audit_status' => '1',
            'finance_audit_status' => '1',
            'creator_user_id' => $record->operator_user_id ?? null,
            'creator_user_name' => $record->operator_user_name ?? '',
            'create_by' => $record->operator_user_name ?? '',
            'create_time' => date('Y-m-d H:i:s'),
            'remark' => '[操作订单] ' . ($record->operation_type === '1' ? '体验操作' : '持卡操作')
        ]);

        if ($order && !empty($record->product_name)) {
            $consumeAmount = floatval($record->consume_amount ?? 0);
            $trialPrice = floatval($record->trial_price ?? 0);
            $itemDealAmount = $consumeAmount + $trialPrice;
            $quantity = intval($record->operation_quantity ?? 1);
            BizOrderItem::create([
                'order_id' => $order->order_id,
                'product_name' => $record->product_name,
                'quantity' => $quantity,
                'deal_amount' => $itemDealAmount,
                'paid_amount' => 0,
                'unit_price' => $quantity > 0 ? round($itemDealAmount / $quantity, 2) : 0,
                'owed_amount' => $itemDealAmount,
                'create_time' => date('Y-m-d H:i:s')
            ]);
        }

        return $order;
    }

    private function generateOperationOrderNo()
    {
        $date = date('Ymd');
        $key = 'operation_order_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'OP' . $date . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }
}
