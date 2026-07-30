<?php

namespace app\controller\system;

use support\Request;
use app\service\SysDeptService;
use app\service\PermissionService;
use app\common\AjaxResult;

/**
 * 部门管理控制器
 *
 * 负责部门的增删改查、部门树下拉选择、排序更新等功能，
 * 存在下级部门或关联用户时不允许删除
 */
class SysDeptController
{
    // 查询部门列表（树形结构）
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysDeptService();
        $params = convert_to_snake_case($request->all());
        $depts = $service->selectDeptList($params);
        return AjaxResult::success($depts);
    }

    // 查询排除指定部门及其子部门的部门列表（用于修改上级部门时排除自身）
    public function excludeChild(Request $request)
    {
        $parts = explode('/', $request->path());
        $deptId = intval(end($parts));
        $service = new SysDeptService();
        return AjaxResult::success($service->excludeChildDeptList($deptId));
    }

    // 根据ID获取部门详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $deptId = intval(end($parts));
        $service = new SysDeptService();
        $dept = $service->selectDeptById($deptId);
        if (!$dept) {
            return AjaxResult::error('部门不存在');
        }
        return AjaxResult::success($dept);
    }

    // 新增部门
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDeptService();
        $result = $service->insertDept($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改部门信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDeptService();
        $result = $service->updateDept($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量更新部门排序
    public function updateSort(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        if (!empty($data['depts'])) {
            foreach ($data['depts'] as $dept) {
                $dept = convert_to_snake_case($dept);
                if (isset($dept['dept_id']) && isset($dept['order_num'])) {
                    \app\model\SysDept::where('dept_id', $dept['dept_id'])->update(['order_num' => $dept['order_num']]);
                }
            }
        }
        return AjaxResult::success();
    }

    // 删除部门，存在下级部门或关联用户时不允许删除
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:dept:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $deptId = intval($request->input('deptId', 0));
        $service = new SysDeptService();
        $result = $service->deleteDeptById($deptId);
        if (!$result) {
            return AjaxResult::error('存在下级部门或关联用户，不允许删除');
        }
        return AjaxResult::success();
    }

    // 获取部门树下拉选择数据
    public function treeselect(Request $request)
    {
        $service = new SysDeptService();
        $depts = $service->selectDeptList();
        $tree = $service->buildDeptTreeSelect($depts, 0);
        return AjaxResult::success($tree);
    }
}
