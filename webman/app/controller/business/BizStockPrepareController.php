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
        } catch (\Exception $e) {
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
}
