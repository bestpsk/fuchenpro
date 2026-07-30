<?php

namespace app\controller\statistics;

use support\Request;
use app\service\WmsStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 库存统计控制器
 *
 * 提供库存金额汇总、周转率、滞销预警、库存预警查询及导出功能
 */
class WmsStatsController
{
    // 库存金额汇总（按仓库）
    public function inventorySummary(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $result = WmsStatsService::getInventorySummary();
        return AjaxResult::success($result);
    }

    // 滞销货品预警
    public function slowMoving(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $days = (int) $request->input('days', 90);
        if ($days < 1 || $days > 365) {
            $days = 90;
        }
        $result = WmsStatsService::getSlowMovingProducts($days);
        return AjaxResult::success($result);
    }

    // 库存预警
    public function inventoryWarning(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $result = WmsStatsService::getInventoryWarnings();
        return AjaxResult::success($result);
    }

    // 库存周转率
    public function turnover(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = WmsStatsService::getInventoryTurnover($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 导出滞销货品
    public function exportSlowMoving(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $days = (int) $request->input('days', 90);
        if ($days < 1 || $days > 365) {
            $days = 90;
        }
        $list = WmsStatsService::getSlowMovingProducts($days);

        $fields = [
            'warehouse_name' => ['name' => '仓库', 'sort' => 1],
            'product_name' => ['name' => '货品名称', 'sort' => 2],
            'product_code' => ['name' => '货品编码', 'sort' => 3],
            'quantity' => ['name' => '库存数量', 'cellType' => 'numeric', 'sort' => 4],
            'purchase_price' => ['name' => '进货价', 'cellType' => 'numeric', 'sort' => 5],
            'stock_amount' => ['name' => '库存金额', 'cellType' => 'numeric', 'sort' => 6],
            'last_stock_out_time' => ['name' => '最后出库时间', 'sort' => 7],
            'days_no_out' => ['name' => '未出库天数', 'cellType' => 'numeric', 'sort' => 8],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '滞销货品预警');
    }

    // 导出库存预警
    public function exportWarning(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:inventory:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $list = WmsStatsService::getInventoryWarnings();

        $fields = [
            'warehouse_name' => ['name' => '仓库', 'sort' => 1],
            'product_name' => ['name' => '货品名称', 'sort' => 2],
            'product_code' => ['name' => '货品编码', 'sort' => 3],
            'quantity' => ['name' => '当前库存', 'cellType' => 'numeric', 'sort' => 4],
            'warn_qty' => ['name' => '预警数量', 'cellType' => 'numeric', 'sort' => 5],
            'shortage_qty' => ['name' => '缺口数量', 'cellType' => 'numeric', 'sort' => 6],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '库存预警');
    }
}
