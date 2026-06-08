<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizStockInService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 入库管理控制器
 *
 * 负责入库单的增删改查、确认入库和取消确认等功能，
 * 确认入库时自动更新库存数量，已确认的入库单不可修改或删除
 */
class BizStockInController
{
    // 分页查询入库单列表
    public function list(Request $request)
    {
        $service = new BizStockInService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectStockInList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取入库单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $stockInId = intval(end($parts));
        $service = new BizStockInService();
        $params['login_user'] = $request->loginUser;
        $stockIn = $service->selectStockInById($stockInId, $params);
        if (!$stockIn) return AjaxResult::error('入库单不存在');
        return AjaxResult::success($stockIn);
    }

    // 新增入库单，含入库明细项，自动填充操作人信息
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser->user;
        $realName = trim($loginUser->nick_name ?? '');
        $userName = trim($loginUser->user_name ?? '');
        $data['create_by'] = $realName ?: $userName;
        $data['operator_id'] = $request->loginUser->userId ?? 0;
        $data['operator_name'] = $realName ?: $userName;
        if (isset($data['items'])) {
            $data['items'] = convert_to_snake_case($data['items']);
        }
        $service = new BizStockInService();
        $result = $service->insertStockIn($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改入库单及明细项，已确认的入库单不可修改
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $data['login_user'] = $request->loginUser;
        if (isset($data['items'])) {
            $data['items'] = convert_to_snake_case($data['items']);
        }
        $service = new BizStockInService();
        $result = $service->updateStockIn($data);
        if (!$result) return AjaxResult::error('修改失败，入库单不存在或已确认');
        return AjaxResult::success();
    }

    // 批量删除入库单，已确认的入库单不可删除
    public function remove(Request $request)
    {
        $stockInIds = $request->input('stockInIds', '');
        if (!is_array($stockInIds)) {
            $stockInIds = explode(',', $stockInIds);
        }
        $stockInIds = array_map('intval', array_filter($stockInIds));
        $params['login_user'] = $request->loginUser;
        $service = new BizStockInService();
        $result = $service->deleteStockInByIds($stockInIds, $params);
        if (!$result) return AjaxResult::error('删除失败，已确认的入库单不可删除');
        return AjaxResult::success();
    }

    // 确认入库，将入库数量累加到库存表
    public function confirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockIn:confirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $params['login_user'] = $request->loginUser;
        $service = new BizStockInService();
        $result = $service->confirmStockIn($id, $params);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }

    // 取消确认入库，从库存中扣减已入库数量
    public function cancelConfirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockIn:cancelConfirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $params['login_user'] = $request->loginUser;
        $service = new BizStockInService();
        $result = $service->cancelConfirmStockIn($id, $params);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }
}
