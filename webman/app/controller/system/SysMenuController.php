<?php

namespace app\controller\system;

use support\Request;
use app\service\SysMenuService;
use app\service\PermissionService;
use app\common\AjaxResult;

/**
 * 菜单管理控制器
 *
 * 负责菜单的增删改查、菜单树下拉选择、角色菜单树、
 * 菜单排序更新等功能，存在子菜单时不允许删除
 */
class SysMenuController
{
    // 查询菜单列表，管理员返回全部菜单，普通用户返回有权限的菜单
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:menu:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysMenuService();
        $userId = $request->loginUser ? $request->loginUser->userId : null;
        $params = convert_to_snake_case($request->all());
        $menus = $service->selectMenuList($params, $userId);
        return AjaxResult::success($menus);
    }

    // 根据ID获取菜单详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:menu:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $menuId = intval(end($parts));
        $service = new SysMenuService();
        $menu = $service->selectMenuById($menuId);
        if (!$menu) {
            return AjaxResult::error('菜单不存在');
        }
        return AjaxResult::success($menu);
    }

    // 获取菜单树下拉选择数据（用于新增/编辑菜单时选择上级菜单）
    public function treeselect(Request $request)
    {
        $service = new SysMenuService();
        return AjaxResult::success($service->treeselect());
    }

    // 获取角色菜单树（含角色已勾选的菜单ID列表），用于角色菜单授权
    public function roleMenuTreeselect(Request $request)
    {
        $parts = explode('/', $request->path());
        $roleId = intval(end($parts));
        $service = new SysMenuService();
        return AjaxResult::success($service->roleMenuTreeselect($roleId));
    }

    // 新增菜单
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:menu:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysMenuService();
        $result = $service->insertMenu($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改菜单信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:menu:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysMenuService();
        $result = $service->updateMenu($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量更新菜单排序
    public function updateSort(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $service = new SysMenuService();
        if (!empty($data['menus'])) {
            foreach ($data['menus'] as $menu) {
                $menu = convert_to_snake_case($menu);
                if (isset($menu['menu_id']) && isset($menu['order_num'])) {
                    \app\model\SysMenu::where('menu_id', $menu['menu_id'])->update(['order_num' => $menu['order_num']]);
                }
            }
        } elseif (!empty($data['menu_ids']) && !empty($data['order_nums'])) {
            $menuIds = explode(',', $data['menu_ids']);
            $orderNums = explode(',', $data['order_nums']);
            foreach ($menuIds as $index => $menuId) {
                if (isset($orderNums[$index])) {
                    \app\model\SysMenu::where('menu_id', intval($menuId))->update(['order_num' => intval($orderNums[$index])]);
                }
            }
        }
        return AjaxResult::success();
    }

    // 删除菜单，存在子菜单时不允许删除
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:menu:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $menuId = intval($request->input('menuId', 0));
        $service = new SysMenuService();
        $result = $service->deleteMenuById($menuId);
        if (!$result) {
            return AjaxResult::error('存在子菜单,不允许删除');
        }
        return AjaxResult::success();
    }
}
