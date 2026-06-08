<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizWmsReportService;
use app\common\AjaxResult;

/**
 * 仓储报表控制器
 *
 * 提供入库汇总统计、出库汇总统计、库存周转分析和货品流水明细等报表查询功能
 */
class BizWmsReportController
{
    // 入库汇总统计，按日期范围和货品维度统计入库数量和金额
    public function stockInSummary(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->stockInSummary($params);
        return AjaxResult::success($result);
    }

    // 出库汇总统计，按日期范围和货品维度统计出库数量和金额
    public function stockOutSummary(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->stockOutSummary($params);
        return AjaxResult::success($result);
    }

    // 库存周转分析，计算各货品的周转率和周转天数
    public function inventoryTurnover(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->inventoryTurnover($params);
        return AjaxResult::success($result);
    }

    // 货品流水明细，查询指定货品的入库/出库/盘点流水记录
    public function productFlow(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->productFlow($params);
        return AjaxResult::success($result);
    }
}
