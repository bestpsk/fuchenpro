<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizWarehouseService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 仓库管理控制器
 *
 * 负责仓库的增删改查、用户授权及当前用户授权仓库查询
 */
class BizWarehouseController
{
    // 分页查询仓库列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:warehouse:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizWarehouseService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectWarehouseList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取仓库详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $warehouseId = intval(end($parts));
        $service = new BizWarehouseService();
        $warehouse = $service->selectWarehouseById($warehouseId);
        if (!$warehouse) return AjaxResult::error('仓库不存在');
        return AjaxResult::success($warehouse);
    }

    // 新增仓库
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:warehouse:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizWarehouseService();
        $result = $service->addWarehouse($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 更新仓库信息
    public function update(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:warehouse:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $warehouseId = $data['warehouse_id'] ?? 0;
        $service = new BizWarehouseService();
        $result = $service->updateWarehouse($warehouseId, $data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除仓库
    public function delete(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:warehouse:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $warehouseIds = $request->input('warehouseIds', '');
        if (!is_array($warehouseIds)) {
            $warehouseIds = explode(',', $warehouseIds);
        }
        $warehouseIds = array_map('intval', array_filter($warehouseIds));
        $service = new BizWarehouseService();
        $result = $service->deleteWarehouse($warehouseIds);
        if (!$result) {
            return AjaxResult::error('该仓库下存在库存记录，无法删除');
        }
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取当前用户授权的仓库列表
    public function getUserWarehouses(Request $request)
    {
        $service = new BizWarehouseService();
        $list = $service->getUserWarehouses($request->loginUser);
        return AjaxResult::success($list);
    }

    // 分配用户到仓库
    public function assignUsers(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:warehouse:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $warehouseId = $request->input('warehouseId', 0);
        $userIds = $request->input('userIds', []);
        if (!is_array($userIds)) {
            $userIds = explode(',', $userIds);
        }
        $userIds = array_map('intval', array_filter($userIds));
        $service = new BizWarehouseService();
        $result = $service->assignUsers($warehouseId, $userIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取仓库下的用户列表
    public function getWarehouseUsers(Request $request)
    {
        $parts = explode('/', $request->path());
        // 路径格式: wms/warehouse/{warehouseId}/users
        $warehouseId = intval($parts[3] ?? 0);
        $service = new BizWarehouseService();
        $list = $service->getWarehouseUsers($warehouseId);
        return AjaxResult::success($list);
    }
}
