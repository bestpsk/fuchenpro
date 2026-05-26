<?php

namespace app\controller\system;

use support\Request;
use app\service\AppMenuConfigService;
use app\common\AjaxResult;

class AppMenuConfigController
{
    public function list(Request $request)
    {
        $service = new AppMenuConfigService();
        $params = convert_to_snake_case($request->all());
        $menus = $service->list($params);
        return AjaxResult::success($menus);
    }

    public function grouped(Request $request)
    {
        $service = new AppMenuConfigService();
        $userId = $request->loginUser->user->user_id ?? null;
        $menus = $service->getGroupedMenus($userId);
        return AjaxResult::success($menus);
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $id = intval(end($parts));
        $service = new AppMenuConfigService();
        $menu = $service->getInfo($id);
        if (!$menu) {
            return AjaxResult::error('菜单配置不存在');
        }
        return AjaxResult::success($menu);
    }

    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new AppMenuConfigService();
        $result = $service->add($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new AppMenuConfigService();
        $result = $service->edit($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function remove(Request $request)
    {
        $id = intval($request->input('id', 0));
        $service = new AppMenuConfigService();
        $result = $service->remove($id);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function updateSort(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $service = new AppMenuConfigService();
        $service->updateSort($data);
        return AjaxResult::success();
    }

    public function changeStatus(Request $request)
    {
        $id = intval($request->post('id', 0));
        $visible = intval($request->post('visible', 1));
        $service = new AppMenuConfigService();
        $result = $service->changeStatus($id, $visible);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
