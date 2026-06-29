<?php

namespace app\controller\business;

use support\Request;
use app\service\BizSalesOrderService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizSalesOrder;

/**
 * 销售订单控制器
 *
 * 负责销售订单的增删改查、企业审核和财务审核等功能，
 * 订单创建时自动关联客户套餐并生成操作记录
 */
class BizSalesOrderController
{
    // 分页查询销售订单列表，支持按客户、企业、门店、状态等条件筛选
    public function list(Request $request)
    {
        $service = new BizSalesOrderService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectOrderList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取订单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $orderId = intval(end($parts));
        $service = new BizSalesOrderService();
        $order = $service->selectOrderById($orderId);
        if (!$order) return AjaxResult::error('订单不存在');
        return AjaxResult::success($order);
    }

    // 新增销售订单，包含订单明细项，自动填充创建人信息并记录错误日志
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:sales:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $items = $data['items'] ?? [];
            unset($data['items']);
            $data['create_by'] = $request->loginUser->user->user_name ?? '';
            $data['creator_user_id'] = $request->loginUser->user->user_id ?? 0;
            $data['creator_user_name'] = $request->loginUser->user->nick_name ?? $request->loginUser->user->user_name ?? '';
            $service = new BizSalesOrderService();
            $result = $service->insertOrder($data, $items);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            \support\Log::error('销售开单失败', [
                'message' => $e->getMessage(),
                'code' => $e->getCode(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
                'post_data' => $request->post()
            ]);
            return AjaxResult::error('开单失败: ' . $e->getMessage(), 500);
        }
    }

    // 修改销售订单及明细项，自动填充更新人信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:sales:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $items = $data['items'] ?? [];
            unset($data['items']);
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $service = new BizSalesOrderService();
            $result = $service->updateOrder($data, $items);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 批量删除销售订单
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:sales:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $orderIds = $request->input('orderIds');
        if (empty($orderIds)) {
            $parts = explode('/', $request->path());
            $orderIds = end($parts);
        }
        $orderIds = explode(',', $orderIds);
        $orderIds = array_map('intval', array_filter($orderIds));
        $service = new BizSalesOrderService();
        $result = $service->deleteOrderByIds($orderIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 企业审核销售订单
    public function enterpriseAudit(Request $request)
    {
        try {
            if (PermissionService::lacksPermi($request->loginUser, 'business:sales:enterpriseAudit')) { return json(['code' => 403, 'msg' => '没有操作权限']); }
            $orderId = $request->post('orderId');
            $auditBy = $request->loginUser->user->nick_name ?? $request->loginUser->user->user_name ?? '';
            $service = new BizSalesOrderService();
            $result = $service->enterpriseAudit($orderId, $auditBy);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 财务审核销售订单
    public function financeAudit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:sales:financeAudit')) { return json(['code' => 403, 'msg' => '没有操作权限']); }
        $orderId = $request->post('orderId');
        $auditBy = $request->loginUser->user->nick_name ?? $request->loginUser->user->user_name ?? '';
        $service = new BizSalesOrderService();
        $result = $service->financeAudit($orderId, $auditBy);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function cancel(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:sales:cancel')) { return json(['code' => 403, 'msg' => '没有操作权限']); }
        $orderId = $request->post('orderId');
        $service = new BizSalesOrderService();
        $result = $service->cancelOrder($orderId);
        if (!$result) return AjaxResult::error('取消失败，仅待确认订单可取消');
        return AjaxResult::success('取消成功');
    }

    // 导出订单数据
    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $service = new BizSalesOrderService();
        $result = $service->selectOrderList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizSalesOrder::class);
        return $excelUtil->exportExcel($list, '订单数据');
    }
}
