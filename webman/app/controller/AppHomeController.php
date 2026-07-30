<?php

namespace app\controller;

use support\Request;
use app\service\HomeStatsService;
use app\service\EnterpriseStatsService;
use app\service\FinanceStatsService;
use app\service\CustomerStatsService;
use app\service\WmsStatsService;
use app\service\ProductStatsService;
use app\common\AjaxResult;

class AppHomeController
{
    public function stats(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = HomeStatsService::getTodayStats($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    public function enterpriseStats(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = EnterpriseStatsService::getEnterpriseStats($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 待办事项
    public function todoItems(Request $request)
    {
        $result = HomeStatsService::getTodoItems($request->loginUser);
        return AjaxResult::success($result);
    }

    // 销售趋势（支持固定天数或自定义日期范围）
    public function salesTrend(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if ($startDate && $endDate) {
            $result = HomeStatsService::getSalesTrend($request->loginUser, 7, $startDate, $endDate);
        } else {
            $days = (int) $request->input('days', 7);
            if ($days < 1 || $days > 90) {
                $days = 7;
            }
            $result = HomeStatsService::getSalesTrend($request->loginUser, $days);
        }
        return AjaxResult::success($result);
    }

    // 经营概览（4 项核心指标，AppV3 简化版）
    public function statsOverview(Request $request)
    {
        try {
            // 应收账款总额
            $receivableData = FinanceStatsService::getReceivableStats([]);
            $totalReceivable = $receivableData['total']['owed_amount'] ?? 0;

            // 流失预警客户数
            $churnList = CustomerStatsService::getChurnWarning(90);
            $churnCount = count($churnList);

            // 库存预警数
            $warningList = WmsStatsService::getInventoryWarnings();
            $warningCount = count($warningList);

            // 销售排行 TOP3
            $rankingList = ProductStatsService::getSalesRanking(3);
            $top3 = array_map(function ($item) {
                return [
                    'product_name' => $item['product_name'],
                    'total_amount' => $item['total_amount'],
                    'total_qty' => $item['total_qty'],
                ];
            }, $rankingList);

            return AjaxResult::success([
                'receivable_amount' => round($totalReceivable, 2),
                'churn_count' => $churnCount,
                'inventory_warning_count' => $warningCount,
                'sales_top3' => $top3,
            ]);
        } catch (\Throwable $e) {
            return AjaxResult::error('获取经营概览失败：' . $e->getMessage());
        }
    }
}
