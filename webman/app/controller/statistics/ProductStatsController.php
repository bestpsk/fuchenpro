<?php

namespace app\controller\statistics;

use support\Request;
use app\service\ProductStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 货品统计控制器
 *
 * 提供货品销售排行、取消率、利润分析（双利润率）查询及导出
 */
class ProductStatsController
{
    // 货品销售排行
    public function salesRanking(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:product:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $limit = (int) $request->input('limit', 20);
        if ($limit < 1 || $limit > 100) {
            $limit = 20;
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = ProductStatsService::getSalesRanking($limit, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 货品取消率
    public function cancelRate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:product:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = ProductStatsService::getCancelRate($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 货品利润分析（双利润率）
    public function profitAnalysis(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:product:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = ProductStatsService::getProfitAnalysis($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 导出销售排行
    public function exportRanking(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:product:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $limit = (int) $request->input('limit', 20);
        if ($limit < 1 || $limit > 100) {
            $limit = 20;
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $list = ProductStatsService::getSalesRanking($limit, $startDate, $endDate);

        $fields = [
            'product_name' => ['name' => '货品名称', 'sort' => 1],
            'total_qty' => ['name' => '销售数量', 'cellType' => 'numeric', 'sort' => 2],
            'total_amount' => ['name' => '销售金额', 'cellType' => 'numeric', 'sort' => 3],
            'avg_price' => ['name' => '平均单价', 'cellType' => 'numeric', 'sort' => 4],
            'order_count' => ['name' => '订单数', 'cellType' => 'numeric', 'sort' => 5],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '货品销售排行');
    }
}
