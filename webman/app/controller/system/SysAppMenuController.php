<?php

namespace app\controller\system;

use support\Request;
use app\service\SysAppMenuService;
use app\common\AjaxResult;

class SysAppMenuController
{
    public function list(Request $request)
    {
        $service = new SysAppMenuService();
        $params = convert_to_snake_case($request->all());
        $list = $service->selectAppMenuList($params);
        return AjaxResult::success($list);
    }

    public function grouped(Request $request)
    {
        $service = new SysAppMenuService();
        $userId = $request->loginUser->user->user_id ?? null;
        $menus = $service->getGroupedAppMenus($userId);
        return AjaxResult::success($menus);
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $menuId = intval(end($parts));
        $service = new SysAppMenuService();
        $appMenu = $service->getAppMenuByMenuId($menuId);
        return AjaxResult::success($appMenu);
    }

    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysAppMenuService();
        $result = $service->addAppMenu($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysAppMenuService();
        $result = $service->editAppMenu($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function remove(Request $request)
    {
        $appMenuId = intval($request->input('appMenuId', 0));
        $service = new SysAppMenuService();
        $result = $service->removeAppMenu($appMenuId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
