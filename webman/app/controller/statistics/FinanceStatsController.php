<?php

namespace app\controller\statistics;

use support\Request;
use app\service\FinanceStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;

/**
 * 财务统计控制器
 *
 * 提供应收账款、账龄分析、支付方式占比、回款率查询及导出功能
 * 所有接口支持企业/门店/业务员/日期范围筛选
 */
class FinanceStatsController
{
    // 应收账款统计（按企业/门店/业务员分组）
    public function receivableStats(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:finance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $filter = $this->buildFilter($request);
        $result = FinanceStatsService::getReceivableStats($filter);
        return AjaxResult::success($result);
    }

    // 账龄分析（30/60/90/90+天）
    public function agingAnalysis(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:finance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $filter = $this->buildFilter($request);
        $result = FinanceStatsService::getAgingAnalysis($filter);
        return AjaxResult::success($result);
    }

    // 支付方式占比
    public function paymentMethod(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:finance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $filter = $this->buildFilter($request);
        $result = FinanceStatsService::getPaymentMethodStats($filter);
        return AjaxResult::success($result);
    }

    // 回款率统计
    public function collectionRate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:finance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $filter = $this->buildFilter($request);
        $result = FinanceStatsService::getCollectionRate($filter);
        return AjaxResult::success($result);
    }

    // 导出应收账款明细
    public function exportReceivable(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'statistics:finance:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $filter = $this->buildFilter($request);
        $data = FinanceStatsService::getReceivableStats($filter);
        $list = $data['list'] ?? [];

        $fields = [
            'enterprise_name' => ['name' => '企业名称', 'sort' => 1],
            'store_name' => ['name' => '门店名称', 'sort' => 2],
            'creator_user_name' => ['name' => '业务员', 'sort' => 3],
            'deal_amount' => ['name' => '成交金额', 'cellType' => 'numeric', 'sort' => 4],
            'paid_amount' => ['name' => '实付金额', 'cellType' => 'numeric', 'sort' => 5],
            'owed_amount' => ['name' => '欠款金额', 'cellType' => 'numeric', 'sort' => 6],
            'order_count' => ['name' => '订单数', 'cellType' => 'numeric', 'sort' => 7],
            'last_order_time' => ['name' => '最后下单时间', 'sort' => 8],
        ];
        $excelUtil = new ExcelUtil();
        $excelUtil->setFields($fields);
        return $excelUtil->exportExcel($list, '应收账款明细');
    }

    // 构建筛选条件
    private function buildFilter(Request $request)
    {
        return [
            'enterprise_id' => $request->input('enterprise_id'),
            'store_id' => $request->input('store_id'),
            'creator_user_id' => $request->input('creator_user_id'),
            'date_start' => $request->input('startDate'),
            'date_end' => $request->input('endDate'),
            'login_user' => $request->loginUser,
        ];
    }
}
