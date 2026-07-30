<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizStockOutService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizStockOut;

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
        $params['login_user'] = $request->loginUser;
        $result = $service->selectStockOutList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取出库单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $stockOutId = intval(end($parts));
        $service = new BizStockOutService();
        $params['login_user'] = $request->loginUser;
        $stockOut = $service->selectStockOutById($stockOutId, $params);
        if (!$stockOut) return AjaxResult::error('出库单不存在');
        return AjaxResult::success($stockOut);
    }

    // 新增出库单，含出库明细项，自动填充操作人信息
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $realName = trim($request->loginUser->user->nick_name ?? '');
            $userName = trim($request->loginUser->user->user_name ?? '');
            $data['create_by'] = $realName ?: $userName;
            $data['responsible_id'] = $request->loginUser->user->user_id;
            $data['responsible_name'] = $realName ?: $userName;
            $data['login_user'] = $request->loginUser;
            if (isset($data['items'])) {
                $data['items'] = convert_to_snake_case($data['items']);
            }
            $service = new BizStockOutService();
            $result = $service->insertStockOut($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            \support\Log::error('出库操作失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 修改出库单及明细项，已确认的出库单不可修改
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $data['login_user'] = $request->loginUser;
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
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $stockOutIds = $request->input('stockOutIds', '');
        if (!is_array($stockOutIds)) {
            $stockOutIds = explode(',', $stockOutIds);
        }
        $stockOutIds = array_map('intval', array_filter($stockOutIds));
        $params['login_user'] = $request->loginUser;
        $service = new BizStockOutService();
        $result = $service->deleteStockOutByIds($stockOutIds, $params);
        if (!$result) return AjaxResult::error('删除失败，已确认的出库单不可删除');
        return AjaxResult::success();
    }

    // 确认出库，从库存中扣减出库数量
    public function confirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:confirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $params['login_user'] = $request->loginUser;
        $params['warehouse_id'] = $request->post('warehouseId') ?: ($request->input('warehouseId') ?: null);
        $service = new BizStockOutService();
        $result = $service->confirmStockOut($id, $params);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }

    // 取消确认出库，将已扣减的数量归还库存
    public function cancelConfirm(Request $request)
    {
        try {
            if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:confirm')) {
                return json(['code' => 403, 'msg' => '没有操作权限']);
            }
            $parts = explode('/', $request->path());
            $id = intval(end($parts));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockOutService();
            $result = $service->cancelConfirmStockOut($id, $params);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success($result['msg']);
        } catch (\Throwable $e) {
            \support\Log::error('出库操作失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    public function ship(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:ship')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $data = convert_to_snake_case($request->post());
        $data['login_user'] = $request->loginUser;
        $service = new BizStockOutService();
        $result = $service->shipStockOut($id, $data);
        if (!$result['success']) return AjaxResult::error($result['msg']);
        return AjaxResult::success($result['msg']);
    }

    public function confirmReceipt(Request $request)
    {
        try {
            if (PermissionService::lacksPermi($request->loginUser, 'wms:stockOut:receipt')) {
                return json(['code' => 403, 'msg' => '没有操作权限']);
            }
            $parts = explode('/', $request->path());
            $id = intval(end($parts));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockOutService();
            $result = $service->confirmReceipt($id, $params);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success($result['msg']);
        } catch (\Throwable $e) {
            \support\Log::error('出库操作失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 导出出库数据
    public function export(Request $request)
    {
        $service = new BizStockOutService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $result = $service->selectStockOutList($params);
        $list = $result->items();
        // 批量查询warehouse_name（避免N+1查询）
        $warehouseIds = [];
        foreach ($list as $item) {
            if (!empty($item->warehouse_id)) {
                $warehouseIds[] = $item->warehouse_id;
            }
        }
        $warehouseIds = array_values(array_unique($warehouseIds));
        $warehouses = \app\model\BizWarehouse::whereIn('warehouse_id', $warehouseIds)->get()->keyBy('warehouse_id');
        foreach ($list as $item) {
            if (!empty($item->warehouse_id)) {
                $warehouse = $warehouses->get($item->warehouse_id);
                $item->warehouse_name = $warehouse ? $warehouse->warehouse_name : '';
            } else {
                $item->warehouse_name = '';
            }
        }
        $excelUtil = new ExcelUtil(BizStockOut::class);
        return $excelUtil->exportExcel($list, '出库数据');
    }
}
