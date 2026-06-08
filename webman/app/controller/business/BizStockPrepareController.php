<?php

namespace app\controller\business;

use support\Request;
use app\service\BizStockPrepareService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

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
        if (!$prepareId) return AjaxResult::error('备货ID不能为空');
        if (empty($items)) return AjaxResult::error('出库明细不能为空');
        $service = new BizStockPrepareService();
        $result = $service->createStockOutFromPrepare($prepareId, $items);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['data']);
    }
}
