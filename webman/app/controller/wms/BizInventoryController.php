<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizInventoryService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 库存管理控制器
 *
 * 负责库存查询和库存预警功能，库存数据由入库/出库确认时自动更新
 */
class BizInventoryController
{
    // 分页查询库存列表，支持按货品名称、分类等条件筛选
    public function list(Request $request)
    {
        $service = new BizInventoryService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectInventoryList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 分页查询库存预警列表（低于安全库存量的货品）
    public function warn(Request $request)
    {
        $service = new BizInventoryService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectWarnList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据货品ID获取库存详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $productId = intval(end($parts));
        $params['login_user'] = $request->loginUser;
        $service = new BizInventoryService();
        $inventory = $service->selectInventoryByProductId($productId, $params);
        if (!$inventory) return AjaxResult::error('库存记录不存在');
        return AjaxResult::success($inventory);
    }
}
