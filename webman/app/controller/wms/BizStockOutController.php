<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizStockOutService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 出库管理控制器
 *
 * 负责出库单的增删改查、确认出库和取消确认等功能，
 * 确认出库时自动扣减库存数量，已确认的出库单不可修改或删除
 */
class BizStockOutController
{
    // 分页查询出库单列表
    public function list(Request $request)
    {
        $service = new BizStockOutService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectStockOutList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取出库单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $stockOutId = intval(end($parts));
        $service = new BizStockOutService();
        $stockOut = $service->selectStockOutById($stockOutId);
        if (!$stockOut) return AjaxResult::error('出库单不存在');
        return AjaxResult::success($stockOut);
    }

    // 新增出库单，含出库明细项，自动填充操作人信息
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $realName = trim($request->loginUser->user->nick_name ?? '');
        $userName = trim($request->loginUser->user->user_name ?? '');
        $data['create_by'] = $realName ?: $userName;
        if (isset($data['items'])) {
            $data['items'] = convert_to_snake_case($data['items']);
        }
        $service = new BizStockOutService();
        $result = $service->insertStockOut($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改出库单及明细项，已确认的出库单不可修改
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        if (isset($data['items'])) {
            $data['items'] = convert_to_snake_case($data['items']);
        }
        $service = new BizStockOutService();
        $result = $service->updateStockOut($data);
        if (!$result) return AjaxResult::error('修改失败，出库单不存在或已确认');
        return AjaxResult::success();
    }

    // 批量删除出库单，已确认的出库单不可删除
    public function remove(Request $request)
    {
        $stockOutIds = $request->input('stockOutIds', '');
        if (!is_array($stockOutIds)) {
            $stockOutIds = explode(',', $stockOutIds);
        }
        $stockOutIds = array_map('intval', array_filter($stockOutIds));
        $service = new BizStockOutService();
        $result = $service->deleteStockOutByIds($stockOutIds);
        if (!$result) return AjaxResult::error('删除失败，已确认的出库单不可删除');
        return AjaxResult::success();
    }

    // 确认出库，从库存中扣减出库数量
    public function confirm(Request $request)
    {
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $service = new BizStockOutService();
        $result = $service->confirmStockOut($id);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }

    // 取消确认出库，将已扣减的数量归还库存
    public function cancelConfirm(Request $request)
    {
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $service = new BizStockOutService();
        $result = $service->cancelConfirmStockOut($id);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }
}
