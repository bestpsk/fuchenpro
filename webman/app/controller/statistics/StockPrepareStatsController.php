<?php

namespace app\controller\statistics;

use support\Request;
use app\service\StockPrepareStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 备货统计控制器
 */
class StockPrepareStatsController
{
    // 备货金额统计（按状态）
    public function amountStats(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:prepare:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $result = StockPrepareStatsService::getPrepareAmountStats();
        return AjaxResult::success($result);
    }

    // 方案执行统计
    public function planExecution(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:prepare:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $result = StockPrepareStatsService::getPlanExecutionStats();
        return AjaxResult::success($result);
    }

    // 备货出库率（按企业）
    public function shipmentRate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:prepare:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = StockPrepareStatsService::getShipmentRate($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 导出方案执行统计
    public function exportPlanExecution(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:prepare:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $list = StockPrepareStatsService::getPlanExecutionStats();

        $fields = [
            'plan_no' => ['name' => '方案编号', 'sort' => 1],
            'plan_name' => ['name' => '方案名称', 'sort' => 2],
            'enterprise_name' => ['name' => '企业名称', 'sort' => 3],
            'gift_amount' => ['name' => '配赠金额', 'cellType' => 'numeric', 'sort' => 4],
            'active_amount' => ['name' => '备货中金额', 'cellType' => 'numeric', 'sort' => 5],
            'stock_prepare_shipped' => ['name' => '已出库金额', 'cellType' => 'numeric', 'sort' => 6],
            'remaining_available' => ['name' => '剩余可备货', 'cellType' => 'numeric', 'sort' => 7],
            'execution_rate' => ['name' => '执行率(%)', 'cellType' => 'numeric', 'sort' => 8],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '方案执行统计');
    }
}
