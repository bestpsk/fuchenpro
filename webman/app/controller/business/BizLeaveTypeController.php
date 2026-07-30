<?php

namespace app\controller\business;

use support\Request;
use app\service\BizLeaveTypeService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 休假类型控制器
 */
class BizLeaveTypeController
{
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:type:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizLeaveTypeService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    /**
     * 查询全部启用的休假类型（下拉选择用）
     */
    public function listAll(Request $request)
    {
        try {
            $service = new BizLeaveTypeService();
            $result = $service->selectAllEnabled();
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            // 表不存在或查询异常时，返回空数组而非报错
            return AjaxResult::success([]);
        }
    }

    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:type:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $typeId = intval(end($parts));
        $service = new BizLeaveTypeService();
        $type = $service->selectById($typeId);
        if (!$type) return AjaxResult::error('类型不存在');
        return AjaxResult::success($type);
    }

    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:type:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizLeaveTypeService();
            $result = $service->insert($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:type:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizLeaveTypeService();
            $result = $service->update($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:type:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $typeIds = $request->input('typeIds', '');
        if (!is_array($typeIds)) {
            $typeIds = explode(',', $typeIds);
        }
        $typeIds = array_map('intval', array_filter($typeIds));
        if (empty($typeIds)) {
            return AjaxResult::error('请选择要删除的类型');
        }
        $service = new BizLeaveTypeService();
        $result = $service->deleteByIds($typeIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
