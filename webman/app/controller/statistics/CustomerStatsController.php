<?php

namespace app\controller\statistics;

use support\Request;
use app\service\CustomerStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 客户统计控制器
 *
 * 提供客户新增趋势、价值分布、流失预警、消费频次查询及导出功能
 */
class CustomerStatsController
{
    // 客户新增趋势（按月）
    public function newCustomerTrend(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $months = (int) $request->input('months', 12);
        if ($months < 1 || $months > 36) {
            $months = 12;
        }
        $result = CustomerStatsService::getNewCustomerTrend($months);
        return AjaxResult::success($result);
    }

    // 客户价值分布
    public function valueDistribution(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = CustomerStatsService::getCustomerValueDistribution($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 按价值层级获取客户明细列表（下钻查看）
    public function customerListByLevel(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $level = $request->input('level', 'high');
        if (!in_array($level, ['high', 'mid', 'low'])) {
            return AjaxResult::error('层级参数无效，可选：high/mid/low');
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = CustomerStatsService::getCustomerListByValueLevel($level, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 客户流失预警
    public function churnWarning(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $days = (int) $request->input('days', 90);
        if ($days < 30 || $days > 365) {
            $days = 90;
        }
        $result = CustomerStatsService::getChurnWarning($days);
        return AjaxResult::success($result);
    }

    // 客户消费频次分布
    public function orderFrequency(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = CustomerStatsService::getOrderFrequencyDistribution($startDate, $endDate);
        return AjaxResult::success($result);
    }

    // 导出流失客户
    public function exportChurn(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:customer:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $days = (int) $request->input('days', 90);
        if ($days < 30 || $days > 365) {
            $days = 90;
        }
        $list = CustomerStatsService::getChurnWarning($days);

        $fields = [
            'customer_name' => ['name' => '客户名称', 'sort' => 1],
            'phone' => ['name' => '联系电话', 'sort' => 2],
            'total_amount' => ['name' => '累计消费', 'cellType' => 'numeric', 'sort' => 3],
            'order_count' => ['name' => '订单数量', 'cellType' => 'numeric', 'sort' => 4],
            'last_order_time' => ['name' => '最后下单时间', 'sort' => 5],
            'days_since_order' => ['name' => '未下单天数', 'cellType' => 'numeric', 'sort' => 6],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '客户流失预警');
    }
}
