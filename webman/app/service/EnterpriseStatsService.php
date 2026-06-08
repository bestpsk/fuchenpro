<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizOperationRecord;
use app\model\BizEnterprise;

class EnterpriseStatsService
{
    public static function getEnterpriseStats($loginUser, $startDate, $endDate)
    {
        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        $dealStats = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $startDate . ' 00:00:00')
            ->where('create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('enterprise_id, COUNT(DISTINCT customer_id) as deal_customer_count, COALESCE(SUM(deal_amount), 0) as deal_amount, COALESCE(SUM(paid_amount), 0) as paid_amount, COALESCE(SUM(owed_amount), 0) as owed_amount')
            ->groupBy('enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $paymentStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->selectRaw('biz_sales_order.enterprise_id, biz_order_item.payment_method, COALESCE(SUM(biz_order_item.deal_amount), 0) as amount')
            ->groupBy('biz_sales_order.enterprise_id', 'biz_order_item.payment_method')
            ->get();

        $giftCountStats = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
            ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
            ->where('biz_order_item.payment_method', 'gift')
            ->selectRaw('biz_sales_order.enterprise_id, COUNT(*) as gift_count')
            ->groupBy('biz_sales_order.enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $paymentByEnterprise = [];
        foreach ($paymentStats as $ps) {
            $eid = $ps->enterprise_id;
            if (!isset($paymentByEnterprise[$eid])) {
                $paymentByEnterprise[$eid] = ['cash' => 0, 'card' => 0];
            }
            if ($ps->payment_method !== 'gift') {
                $paymentByEnterprise[$eid][$ps->payment_method] = round((float)$ps->amount, 2);
            }
        }

        $operationStats = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $startDate)
            ->where('operation_date', '<=', $endDate)
            ->selectRaw('enterprise_id, COUNT(DISTINCT customer_id) as operation_customer_count, COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as operation_amount')
            ->groupBy('enterprise_id')
            ->get()
            ->keyBy('enterprise_id');

        $allEnterpriseIds = $dealStats->keys()
            ->merge($operationStats->keys())
            ->unique()
            ->values()
            ->toArray();

        if (empty($allEnterpriseIds)) {
            return [];
        }

        $enterprises = BizEnterprise::whereIn('enterprise_id', $allEnterpriseIds)
            ->select(['enterprise_id', 'enterprise_name'])
            ->get()
            ->keyBy('enterprise_id');

        $result = [];
        foreach ($allEnterpriseIds as $eid) {
            $deal = $dealStats->get($eid);
            $op = $operationStats->get($eid);
            $enterprise = $enterprises->get($eid);
            $payment = $paymentByEnterprise[$eid] ?? ['cash' => 0, 'card' => 0];
            $giftCountItem = $giftCountStats->get($eid);

            $result[] = [
                'enterpriseId' => $eid,
                'enterpriseName' => $enterprise ? $enterprise->enterprise_name : ($deal ? ($deal->enterprise_name ?? '未知企业') : '未知企业'),
                'dealCustomerCount' => $deal ? (int)$deal->deal_customer_count : 0,
                'dealAmount' => $deal ? round((float)$deal->deal_amount, 2) : 0,
                'paidAmount' => $deal ? round((float)$deal->paid_amount, 2) : 0,
                'owedAmount' => $deal ? round((float)$deal->owed_amount, 2) : 0,
                'cashAmount' => $payment['cash'],
                'cardAmount' => $payment['card'],
                'giftCount' => $giftCountItem ? (int)$giftCountItem->gift_count : 0,
                'operationCustomerCount' => $op ? (int)$op->operation_customer_count : 0,
                'operationAmount' => $op ? round((float)$op->operation_amount, 2) : 0,
            ];
        }

        usort($result, function ($a, $b) {
            return ($b['dealAmount'] + $b['operationAmount']) <=> ($a['dealAmount'] + $a['operationAmount']);
        });

        return $result;
    }
}
