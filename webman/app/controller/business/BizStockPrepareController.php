<?php

namespace app\controller\business;

use support\Request;
use app\service\BizStockPrepareService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizStockPrepare;

class BizStockPrepareController
{
    public function list(Request $request)
    {
        $service = new BizStockPrepareService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectPrepareList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $prepareId = intval(end($parts));
        $service = new BizStockPrepareService();
        $prepare = $service->selectPrepareById($prepareId);
        if (!$prepare) return AjaxResult::error('备货记录不存在');
        return AjaxResult::success($prepare);
    }

    public function createStockOut(Request $request)
    {
        $prepareId = intval($request->input('prepareId', 0));
        $items = $request->input('items', []);
        // 统一转 snake_case，与 BizStockTransferController 约定一致
        $items = convert_to_snake_case($items);
        $warehouseId = $request->input('warehouseId');
        if (!$prepareId) return AjaxResult::error('备货ID不能为空');
        if (empty($items)) return AjaxResult::error('出库明细不能为空');
        $service = new BizStockPrepareService();
        $result = $service->createStockOutFromPrepare($prepareId, $items, $warehouseId, $request->loginUser);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['data']);
    }

    /**
     * 获取方案活跃备货金额
     */
    public function getActivePreparedAmount(Request $request)
    {
        $planId = $request->get('planId');
        if (empty($planId)) {
            return AjaxResult::error('方案ID不能为空');
        }
        $planService = new \app\service\BizPlanService();
        $amount = $planService->getActivePreparedAmount($planId);
        return AjaxResult::success(['activePreparedAmount' => $amount]);
    }

    /**
     * 查询可备货订单列表（已财务审核且未备货）
     */
    public function orderListForPrepare(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $loginUser = $request->loginUser;
        $service = new BizStockPrepareService();
        $result = $service->selectOrderListForPrepare($params, $loginUser);
        return TableDataInfo::result($result->items(), $result->total());
    }

    /**
     * 根据订单创建备货
     */
    public function createFromOrder(Request $request)
    {
        $orderId = $request->post('orderId');
        if (empty($orderId)) {
            return AjaxResult::error('订单ID不能为空');
        }
        $service = new BizStockPrepareService();
        try {
            $result = $service->createFromOrder($orderId, $request->loginUser);
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 批量根据订单创建备货
     */
    public function batchCreateFromOrder(Request $request)
    {
        $orderIds = $request->post('orderIds');
        if (empty($orderIds) || !is_array($orderIds)) {
            return AjaxResult::error('请选择订单');
        }
        $service = new BizStockPrepareService();
        $result = $service->batchCreateFromOrder($orderIds, $request->loginUser);
        return AjaxResult::success($result);
    }

    /**
     * 从方案创建备货记录
     */
    public function createFromPlan(Request $request)
    {
        $planId = $request->post('planId');
        $items = $request->post('items');

        if (empty($planId)) {
            return AjaxResult::error('方案ID不能为空');
        }
        if (empty($items) || !is_array($items)) {
            return AjaxResult::error('备货明细不能为空');
        }

        // 校验每个 item
        foreach ($items as $item) {
            if (empty($item['productId'])) {
                return AjaxResult::error('货品ID不能为空');
            }
            if (empty($item['quantity']) || $item['quantity'] <= 0) {
                return AjaxResult::error('备货数量必须大于0');
            }
        }

        $service = new BizStockPrepareService();
        try {
            $result = $service->createFromPlan($planId, $items, $request->loginUser);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 导出备货数据
    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $service = new BizStockPrepareService();
        $result = $service->selectPrepareList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizStockPrepare::class);
        return $excelUtil->exportExcel($list, '备货数据');
    }

    // 取消备货（仅未出库可取消）
    public function cancel(Request $request)
    {
        $prepareId = $request->input('prepareId');
        if (!$prepareId) {
            return AjaxResult::error('缺少备货ID');
        }
        $service = new BizStockPrepareService();
        $result = $service->cancelPrepare($prepareId, $request->loginUser);
        return $result['success'] ? AjaxResult::success($result['msg']) : AjaxResult::error($result['msg']);
    }

    // 删除备货（仅已取消状态可删除）
    public function delete(Request $request)
    {
        $parts = explode('/', $request->path());
        $prepareId = intval(end($parts));
        if (!$prepareId) return AjaxResult::error('缺少备货ID');
        $service = new BizStockPrepareService();
        $result = $service->deletePrepareByIds([$prepareId]);
        return $result['success'] ? AjaxResult::success($result['msg']) : AjaxResult::error($result['msg']);
    }
}
