<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizStockCheckService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 库存盘点控制器
 *
 * 负责盘点单的增删改查、确认盘点和加载当前库存快照等功能，
 * 确认盘点时按盘点差异自动调整库存数量
 */
class BizStockCheckController
{
    // 分页查询盘点单列表
    public function list(Request $request)
    {
        $service = new BizStockCheckService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectStockCheckList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取盘点单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $stockCheckId = intval(end($parts));
        $service = new BizStockCheckService();
        $params['login_user'] = $request->loginUser;
        $stockCheck = $service->selectStockCheckById($stockCheckId, $params);
        if (!$stockCheck) return AjaxResult::error('盘点单不存在');
        return AjaxResult::success($stockCheck);
    }

    // 新增盘点单，含盘点明细项，自动填充操作人信息
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockCheck:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['create_by'] = $request->loginUser->user->user_name ?? '';
            $data['operator_id'] = $request->loginUser->userId ?? 0;
            $data['operator_name'] = $request->loginUser->user->nick_name ?? '';
            $data['login_user'] = $request->loginUser;
            if (isset($data['items'])) {
                $data['items'] = convert_to_snake_case($data['items']);
            }
            $service = new BizStockCheckService();
            $result = $service->insertStockCheck($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            \support\Log::error('新增盘点单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 修改盘点单及明细项，已确认的盘点单不可修改
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockCheck:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $data['login_user'] = $request->loginUser;
            if (isset($data['items'])) {
                $data['items'] = convert_to_snake_case($data['items']);
            }
            $service = new BizStockCheckService();
            $result = $service->updateStockCheck($data);
            if (!$result) return AjaxResult::error('修改失败，盘点单不存在或已确认');
            return AjaxResult::success();
        } catch (\Throwable $e) {
            \support\Log::error('修改盘点单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 批量删除盘点单，已确认的盘点单不可删除
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockCheck:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $stockCheckIds = $request->input('stockCheckIds', '');
            if (!is_array($stockCheckIds)) {
                $stockCheckIds = explode(',', $stockCheckIds);
            }
            $stockCheckIds = array_map('intval', array_filter($stockCheckIds));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockCheckService();
            $result = $service->deleteStockCheckByIds($stockCheckIds, $params);
            if (!$result) return AjaxResult::error('删除失败，已确认的盘点单不可删除');
            return AjaxResult::success();
        } catch (\Throwable $e) {
            \support\Log::error('删除盘点单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 确认盘点，按盘点差异（实盘数-系统数）自动调整库存
    public function confirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockCheck:confirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $parts = explode('/', $request->path());
            $id = intval(end($parts));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockCheckService();
            $result = $service->confirmStockCheck($id, $params);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success($result['msg']);
        } catch (\Throwable $e) {
            \support\Log::error('确认盘点失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 加载当前所有货品的库存快照数据，用于新建盘点单时预填
    public function loadInventory(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockCheck:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params['login_user'] = $request->loginUser;
        $params['warehouse_id'] = $request->input('warehouse_id');
        $service = new BizStockCheckService();
        $items = $service->loadInventoryData($params);
        return AjaxResult::success($items);
    }
}
