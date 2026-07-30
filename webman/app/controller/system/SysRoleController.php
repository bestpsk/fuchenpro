<?php

namespace app\controller\system;

use support\Request;
use app\service\SysRoleService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 角色管理控制器
 *
 * 负责角色的增删改查、数据权限设置、状态变更、
 * 角色下拉选择、已分配/未分配用户管理、批量授权和部门树查询等功能
 */
class SysRoleController
{
    // 分页查询角色列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysRoleService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectRoleList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取角色详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $roleId = intval(end($parts));
        $service = new SysRoleService();
        $role = $service->selectRoleById($roleId);
        if (!$role) {
            return AjaxResult::error('角色不存在');
        }
        return AjaxResult::success('', $role);
    }

    // 新增角色，校验角色名称和权限字符唯一性
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $service = new SysRoleService();
        if ($service->checkRoleNameUnique($data['role_name'] ?? '')) {
            return AjaxResult::error('新增角色\'' . ($data['role_name'] ?? '') . '\'失败，角色名称已存在');
        }
        if ($service->checkRoleKeyUnique($data['role_key'] ?? '')) {
            return AjaxResult::error('新增角色\'' . ($data['role_name'] ?? '') . '\'失败，角色权限已存在');
        }
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $result = $service->insertRole($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改角色信息，校验唯一性并刷新在线用户权限缓存
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $service = new SysRoleService();
        if ($service->checkRoleNameUnique($data['role_name'] ?? '', $data['role_id'] ?? null)) {
            return AjaxResult::error('修改角色\'' . ($data['role_name'] ?? '') . '\'失败，角色名称已存在');
        }
        if ($service->checkRoleKeyUnique($data['role_key'] ?? '', $data['role_id'] ?? null)) {
            return AjaxResult::error('修改角色\'' . ($data['role_name'] ?? '') . '\'失败，角色权限已存在');
        }
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $result = $service->updateRole($data);

        $tokenService = new \app\service\TokenService();
        $tokenService->refreshPermissionByRoleId($data['role_id']);

        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除角色，不允许删除超级管理员角色(ID=1)
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $roleIds = explode(',', $request->input('roleIds', ''));
        $roleIds = array_map('intval', array_filter($roleIds));
        if (in_array(1, $roleIds)) {
            return AjaxResult::error('不允许删除超级管理员角色');
        }
        $service = new SysRoleService();
        // 删除前检查是否有用户关联该角色
        $userCount = $service->countUsersByRoleIds($roleIds);
        if ($userCount > 0) {
            return AjaxResult::error('该角色已分配给 ' . $userCount . ' 个用户，请先取消用户授权后再删除');
        }
        $result = $service->deleteRoleByIds($roleIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 设置角色数据权限范围（全部/自定义/本部门/本部门及以下/仅本人）
    public function dataScope(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $service = new SysRoleService();
        $result = $service->authDataScope(
            $data['role_id'] ?? 0,
            $data['data_scope'] ?? '1',
            $data['dept_ids'] ?? []
        );

        // 刷新在线用户缓存，使数据权限变更立即生效
        $tokenService = new \app\service\TokenService();
        $tokenService->refreshPermissionByRoleId($data['role_id'] ?? 0);

        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 变更角色状态（启用/停用）
    public function changeStatus(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $roleId = $request->post('roleId');
        $status = $request->post('status');
        $service = new SysRoleService();
        $result = $service->changeStatus($roleId, $status);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取所有角色列表（下拉选择用）
    public function optionselect(Request $request)
    {
        $service = new SysRoleService();
        return AjaxResult::success($service->selectAllRoles());
    }

    // 分页查询已分配该角色的用户列表
    public function allocatedList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $roleId = intval($params['role_id'] ?? 0);
        $service = new SysRoleService();
        $result = $service->allocatedUserList($roleId, $params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 分页查询未分配该角色的用户列表
    public function unallocatedList(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $roleId = intval($params['role_id'] ?? 0);
        $service = new SysRoleService();
        $result = $service->unallocatedUserList($roleId, $params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 取消单个用户的角色授权
    public function cancelAuthUser(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->post('userId');
        $roleId = $request->post('roleId');
        $service = new SysRoleService();
        $result = $service->cancelAuthUser($userId, $roleId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量取消用户的角色授权
    public function cancelAuthUserAll(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $roleId = $request->post('roleId');
        $userIds = $request->post('userIds', []);
        if (is_string($userIds)) {
            $userIds = explode(',', $userIds);
        }
        $service = new SysRoleService();
        $result = $service->cancelAuthUserAll($userIds, $roleId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量给用户授权指定角色
    public function selectAuthUserAll(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:role:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $roleId = $request->post('roleId');
        $userIds = $request->post('userIds', []);
        if (is_string($userIds)) {
            $userIds = explode(',', $userIds);
        }
        $service = new SysRoleService();
        $result = $service->selectAuthUserAll($userIds, $roleId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取部门树（含角色已勾选的部门ID列表），用于数据权限设置
    public function deptTree(Request $request)
    {
        $parts = explode('/', $request->path());
        $roleId = intval(end($parts));
        $deptService = new \app\service\SysDeptService();
        $depts = $deptService->selectDeptList([]);
        $roleDeptService = new SysRoleService();
        $checkedKeys = \app\model\SysRoleDept::where('role_id', $roleId)->pluck('dept_id')->toArray();
        return AjaxResult::success('', [
            'depts' => $deptService->buildDeptTreeSelect($depts, 0),
            'checkedKeys' => $checkedKeys,
        ]);
    }
}
