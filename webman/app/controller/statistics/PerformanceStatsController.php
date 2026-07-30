<?php

namespace app\controller\statistics;

use support\Request;
use app\service\PerformanceStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 数据统计控制器
 *
 * 提供业绩统计（按部门/按个人）和企业业绩（按企业/按门店）查询及导出功能
 */
class PerformanceStatsController
{
    // 按部门统计业绩
    public function deptPerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getDeptPerformance($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 按个人统计业绩
    public function userPerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getUserPerformance($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 按企业统计业绩
    public function enterprisePerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getEnterprisePerformance($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 按门店统计业绩
    public function storePerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getStorePerformance($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 导出部门业绩
    public function exportDeptPerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getDeptPerformance($request->loginUser, $startDate, $endDate);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'deptName' => ['name' => '部门名称', 'sort' => 1],
            'dealCustomerCount' => ['name' => '成交客数', 'cellType' => 'numeric', 'sort' => 2],
            'dealAmount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 3],
            'paidAmount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 4],
            'owedAmount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 5],
            'cashAmount' => ['name' => '现金金额', 'cellType' => 'numeric', 'sort' => 6],
            'cardAmount' => ['name' => '耗卡金额', 'cellType' => 'numeric', 'sort' => 7],
            'giftCount' => ['name' => '赠送次数', 'cellType' => 'numeric', 'sort' => 8],
            'operationCustomerCount' => ['name' => '操作客数', 'cellType' => 'numeric', 'sort' => 9],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '部门业绩统计');
    }

    // 导出个人业绩
    public function exportUserPerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getUserPerformance($request->loginUser, $startDate, $endDate);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'userName' => ['name' => '员工姓名', 'sort' => 1],
            'deptName' => ['name' => '所属部门', 'sort' => 2],
            'dealCustomerCount' => ['name' => '成交客数', 'cellType' => 'numeric', 'sort' => 3],
            'dealAmount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 4],
            'paidAmount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 5],
            'owedAmount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 6],
            'cashAmount' => ['name' => '现金金额', 'cellType' => 'numeric', 'sort' => 7],
            'cardAmount' => ['name' => '耗卡金额', 'cellType' => 'numeric', 'sort' => 8],
            'giftCount' => ['name' => '赠送次数', 'cellType' => 'numeric', 'sort' => 9],
            'operationCustomerCount' => ['name' => '操作客数', 'cellType' => 'numeric', 'sort' => 10],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '个人业绩统计');
    }

    // 导出企业业绩
    public function exportEnterprisePerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getEnterprisePerformance($request->loginUser, $startDate, $endDate);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'enterpriseName' => ['name' => '企业名称', 'sort' => 1],
            'dealCustomerCount' => ['name' => '成交客数', 'cellType' => 'numeric', 'sort' => 2],
            'dealAmount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 3],
            'paidAmount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 4],
            'owedAmount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 5],
            'cashAmount' => ['name' => '现金金额', 'cellType' => 'numeric', 'sort' => 6],
            'cardAmount' => ['name' => '耗卡金额', 'cellType' => 'numeric', 'sort' => 7],
            'giftCount' => ['name' => '赠送次数', 'cellType' => 'numeric', 'sort' => 8],
            'operationCustomerCount' => ['name' => '操作客数', 'cellType' => 'numeric', 'sort' => 9],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '企业业绩统计');
    }

    // 导出门店业绩
    public function exportStorePerformance(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:performance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = PerformanceStatsService::getStorePerformance($request->loginUser, $startDate, $endDate);
        $list = is_array($result) ? $result : ($result->toArray() ?? []);

        $fields = [
            'storeName' => ['name' => '门店名称', 'sort' => 1],
            'enterpriseName' => ['name' => '所属企业', 'sort' => 2],
            'dealCustomerCount' => ['name' => '成交客数', 'cellType' => 'numeric', 'sort' => 3],
            'dealAmount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 4],
            'paidAmount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 5],
            'owedAmount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 6],
            'cashAmount' => ['name' => '现金金额', 'cellType' => 'numeric', 'sort' => 7],
            'cardAmount' => ['name' => '耗卡金额', 'cellType' => 'numeric', 'sort' => 8],
            'giftCount' => ['name' => '赠送次数', 'cellType' => 'numeric', 'sort' => 9],
            'operationCustomerCount' => ['name' => '操作客数', 'cellType' => 'numeric', 'sort' => 10],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '门店业绩统计');
    }
}
