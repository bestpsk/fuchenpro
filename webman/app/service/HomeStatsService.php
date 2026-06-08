<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOrderItem;
use app\model\BizOperationRecord;

class HomeStatsService
{
    public static function getTodayStats($loginUser, $startDate = null, $endDate = null)
    {
        $today = date('Y-m-d');
        $monthStart = date('Y-m-01');

        $userIds = DataScopeService::getVisibleUserIds($loginUser);

        $todayDealCustomers = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->distinct()->count('customer_id');

        $monthDealCustomers = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->distinct()->count('customer_id');

        $todayDealAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->sum('deal_amount');

        $monthDealAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->sum('deal_amount');

        $todayPaidAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->sum('paid_amount');

        $monthPaidAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->sum('paid_amount');

        $todayOwedAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->sum('owed_amount');

        $monthOwedAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
            ->whereIn('source_type', ['0', '2'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->sum('owed_amount');

        $todayCashAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->whereDate('biz_sales_order.create_time', $today)
            ->where('biz_order_item.payment_method', 'cash')
            ->sum('biz_order_item.deal_amount');

        $monthCashAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $monthStart . ' 00:00:00')
            ->where('biz_order_item.payment_method', 'cash')
            ->sum('biz_order_item.deal_amount');

        $todayCardAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->whereDate('biz_sales_order.create_time', $today)
            ->where('biz_order_item.payment_method', 'card')
            ->sum('biz_order_item.deal_amount');

        $monthCardAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $monthStart . ' 00:00:00')
            ->where('biz_order_item.payment_method', 'card')
            ->sum('biz_order_item.deal_amount');

        $todayGiftCount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->whereDate('biz_sales_order.create_time', $today)
            ->where('biz_order_item.payment_method', 'gift')
            ->count();

        $monthGiftCount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
            ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
            ->whereIn('biz_sales_order.source_type', ['0', '2'])
            ->whereIn('biz_sales_order.creator_user_id', $userIds)
            ->where('biz_sales_order.create_time', '>=', $monthStart . ' 00:00:00')
            ->where('biz_order_item.payment_method', 'gift')
            ->count();

        $todayOperationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->whereDate('operation_date', $today)
            ->distinct()->count('customer_id');

        $monthOperationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $monthStart)
            ->distinct()->count('customer_id');

        $todayOperationAmount = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->whereDate('operation_date', $today)
            ->selectRaw('COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as total')
            ->value('total');

        $monthOperationAmount = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $monthStart)
            ->selectRaw('COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as total')
            ->value('total');

        $result = [
            'dealCustomerCount' => ['today' => $todayDealCustomers, 'month' => $monthDealCustomers],
            'dealAmount' => ['today' => $todayDealAmount, 'month' => $monthDealAmount],
            'paidAmount' => ['today' => $todayPaidAmount, 'month' => $monthPaidAmount],
            'owedAmount' => ['today' => $todayOwedAmount, 'month' => $monthOwedAmount],
            'cashAmount' => ['today' => $todayCashAmount, 'month' => $monthCashAmount],
            'cardAmount' => ['today' => $todayCardAmount, 'month' => $monthCardAmount],
            'giftCount' => ['today' => $todayGiftCount, 'month' => $monthGiftCount],
            'operationCustomerCount' => ['today' => $todayOperationCustomers, 'month' => $monthOperationCustomers],
            'operationAmount' => ['today' => $todayOperationAmount, 'month' => $monthOperationAmount],
        ];

        if ($startDate && $endDate) {
            $customDealCustomers = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
                ->whereIn('source_type', ['0', '2'])
                ->whereIn('creator_user_id', $userIds)
                ->where('create_time', '>=', $startDate . ' 00:00:00')
                ->where('create_time', '<=', $endDate . ' 23:59:59')
                ->distinct()->count('customer_id');

            $customDealAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
                ->whereIn('source_type', ['0', '2'])
                ->whereIn('creator_user_id', $userIds)
                ->where('create_time', '>=', $startDate . ' 00:00:00')
                ->where('create_time', '<=', $endDate . ' 23:59:59')
                ->sum('deal_amount');

            $customPaidAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
                ->whereIn('source_type', ['0', '2'])
                ->whereIn('creator_user_id', $userIds)
                ->where('create_time', '>=', $startDate . ' 00:00:00')
                ->where('create_time', '<=', $endDate . ' 23:59:59')
                ->sum('paid_amount');

            $customOwedAmount = BizSalesOrder::whereIn('order_status', ['1', '2', '3'])
                ->whereIn('source_type', ['0', '2'])
                ->whereIn('creator_user_id', $userIds)
                ->where('create_time', '>=', $startDate . ' 00:00:00')
                ->where('create_time', '<=', $endDate . ' 23:59:59')
                ->sum('owed_amount');

            $customCashAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
                ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
                ->whereIn('biz_sales_order.source_type', ['0', '2'])
                ->whereIn('biz_sales_order.creator_user_id', $userIds)
                ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
                ->where('biz_order_item.payment_method', 'cash')
                ->sum('biz_order_item.deal_amount');

            $customCardAmount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
                ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
                ->whereIn('biz_sales_order.source_type', ['0', '2'])
                ->whereIn('biz_sales_order.creator_user_id', $userIds)
                ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
                ->where('biz_order_item.payment_method', 'card')
                ->sum('biz_order_item.deal_amount');

            $customGiftCount = BizOrderItem::join('biz_sales_order', 'biz_order_item.order_id', '=', 'biz_sales_order.order_id')
                ->whereIn('biz_sales_order.order_status', ['1', '2', '3'])
                ->whereIn('biz_sales_order.source_type', ['0', '2'])
                ->whereIn('biz_sales_order.creator_user_id', $userIds)
                ->where('biz_sales_order.create_time', '>=', $startDate . ' 00:00:00')
                ->where('biz_sales_order.create_time', '<=', $endDate . ' 23:59:59')
                ->where('biz_order_item.payment_method', 'gift')
                ->count();

            $customOperationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
                ->where('operation_date', '>=', $startDate)
                ->where('operation_date', '<=', $endDate)
                ->distinct()->count('customer_id');

            $customOperationAmount = BizOperationRecord::whereIn('operator_user_id', $userIds)
                ->where('operation_date', '>=', $startDate)
                ->where('operation_date', '<=', $endDate)
                ->selectRaw('COALESCE(SUM(consume_amount), 0) + COALESCE(SUM(trial_price), 0) as total')
                ->value('total');

            $result['dealCustomerCount']['custom'] = $customDealCustomers;
            $result['dealAmount']['custom'] = $customDealAmount;
            $result['paidAmount']['custom'] = $customPaidAmount;
            $result['owedAmount']['custom'] = $customOwedAmount;
            $result['cashAmount']['custom'] = $customCashAmount;
            $result['cardAmount']['custom'] = $customCardAmount;
            $result['giftCount']['custom'] = $customGiftCount;
            $result['operationCustomerCount']['custom'] = $customOperationCustomers;
            $result['operationAmount']['custom'] = $customOperationAmount;
        }

        return $result;
    }
}
