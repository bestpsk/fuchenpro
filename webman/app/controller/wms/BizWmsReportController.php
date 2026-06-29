<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizWmsReportService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

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

    // 有效期盘点报表，查询有有效期货品的到期情况
    public function expiryInventory(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->expiryInventory($params);
        return AjaxResult::success($result);
    }

    // 导出入库汇总
    public function exportStockInSummary(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->stockInSummary($params);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'productName' => ['name' => '品名', 'sort' => 1],
            'category' => ['name' => '类别', 'dictType' => 'biz_product_category', 'sort' => 2],
            'totalQuantity' => ['name' => '入库数量', 'cellType' => 'numeric', 'sort' => 3],
            'totalAmount' => ['name' => '入库金额', 'cellType' => 'numeric', 'sort' => 4],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '入库汇总');
    }

    // 导出出库汇总
    public function exportStockOutSummary(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->stockOutSummary($params);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'productName' => ['name' => '品名', 'sort' => 1],
            'category' => ['name' => '类别', 'dictType' => 'biz_product_category', 'sort' => 2],
            'totalQuantity' => ['name' => '出库数量', 'cellType' => 'numeric', 'sort' => 3],
            'totalAmount' => ['name' => '出库金额', 'cellType' => 'numeric', 'sort' => 4],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '出库汇总');
    }

    // 导出库存周转
    public function exportTurnover(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->inventoryTurnover($params);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'productCode' => ['name' => '货品编码', 'sort' => 1],
            'productName' => ['name' => '品名', 'sort' => 2],
            'category' => ['name' => '类别', 'dictType' => 'biz_product_category', 'sort' => 3],
            'beginQuantity' => ['name' => '期初库存', 'cellType' => 'numeric', 'sort' => 4],
            'periodInQuantity' => ['name' => '期间入库', 'cellType' => 'numeric', 'sort' => 5],
            'periodOutQuantity' => ['name' => '期间出库', 'cellType' => 'numeric', 'sort' => 6],
            'endQuantity' => ['name' => '期末库存', 'cellType' => 'numeric', 'sort' => 7],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '库存周转');
    }

    // 导出货品收发存
    public function exportProductFlow(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->productFlow($params);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'docNo' => ['name' => '单号', 'sort' => 1],
            'flowDate' => ['name' => '日期', 'sort' => 2],
            'flowType' => ['name' => '类型', 'sort' => 3],
            'quantity' => ['name' => '数量', 'cellType' => 'numeric', 'sort' => 4],
            'amount' => ['name' => '金额', 'cellType' => 'numeric', 'sort' => 5],
            'balance' => ['name' => '结存', 'cellType' => 'numeric', 'sort' => 6],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '货品收发存');
    }

    // 导出有效期盘点
    public function exportExpiryInventory(Request $request)
    {
        $service = new BizWmsReportService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->expiryInventory($params);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'stockInNo' => ['name' => '单据编号', 'sort' => 1],
            'productName' => ['name' => '货品名称', 'sort' => 2],
            'category' => ['name' => '类别', 'dictType' => 'biz_product_category', 'sort' => 3],
            'remainingQuantity' => ['name' => '批次数量', 'cellType' => 'numeric', 'sort' => 4],
            'productionDate' => ['name' => '生产日期', 'dateFormat' => 'Y-m-d', 'sort' => 5],
            'expiryDate' => ['name' => '到期日期', 'dateFormat' => 'Y-m-d', 'sort' => 6],
            'remainingDays' => ['name' => '剩余天数', 'cellType' => 'numeric', 'sort' => 7],
            'expiryStatusText' => ['name' => '到期状态', 'sort' => 8],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '有效期盘点');
    }
}
