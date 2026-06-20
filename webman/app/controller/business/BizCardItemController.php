<?php

namespace app\controller\business;

use support\Request;
use app\service\BizCardItemService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizCardItem;

class BizCardItemController
{
    public function list(Request $request)
    {
        $service = new BizCardItemService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectCardItemList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $cardItemId = intval(end($parts));
        $service = new BizCardItemService();
        $cardItem = $service->selectCardItemById($cardItemId);
        if (!$cardItem) return AjaxResult::error('卡项不存在');
        return AjaxResult::success($cardItem);
    }

    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $params = ['login_user' => $request->loginUser];
        $service = new BizCardItemService();
        $list = $service->searchCardItem($keyword, $params);
        return AjaxResult::success($list);
    }

    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizCardItemService();
        $result = $service->insertCardItem($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizCardItemService();
        $result = $service->updateCardItem($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function remove(Request $request)
    {
        $cardItemIds = $request->input('cardItemIds', '');
        if (!is_array($cardItemIds)) {
            $cardItemIds = explode(',', $cardItemIds);
        }
        $cardItemIds = array_map('intval', array_filter($cardItemIds));
        $service = new BizCardItemService();
        $result = $service->deleteCardItemByIds($cardItemIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['page_size'] = 10000;
        $service = new BizCardItemService();
        $result = $service->selectCardItemList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizCardItem::class);
        return $excelUtil->exportExcel($list, '卡项数据');
    }
}
