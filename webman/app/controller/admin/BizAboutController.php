<?php

namespace app\controller\admin;

use support\Request;
use app\service\BizAboutService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 企业小报管理控制器
 *
 * 负责企业小报的增删改查，list和getInfo对所有登录用户开放，
 * add/edit/remove需要admin:about:*权限
 */
class BizAboutController
{
    // 分页查询企业小报列表（所有登录用户可访问）
    public function list(Request $request)
    {
        $service = new BizAboutService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectAboutList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取企业小报详情（所有登录用户可访问）
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $aboutId = intval(end($parts));
        $service = new BizAboutService();
        $about = $service->selectAboutById($aboutId);
        if (!$about) return AjaxResult::error('企业小报不存在');
        return AjaxResult::success($about);
    }

    // 新增企业小报
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:about:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizAboutService();
        return AjaxResult::toAjax($service->insertAbout($data) ? 1 : 0);
    }

    // 修改企业小报
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:about:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        if (empty($data['about_id'])) {
            return AjaxResult::error('介绍ID不能为空');
        }
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizAboutService();
        return AjaxResult::toAjax($service->updateAbout($data) ? 1 : 0);
    }

    // 批量删除企业小报
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:about:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $aboutIds = explode(',', $request->input('aboutIds', ''));
        $aboutIds = array_map('intval', array_filter($aboutIds));
        $service = new BizAboutService();
        return AjaxResult::toAjax($service->deleteAboutByIds($aboutIds) ? 1 : 0);
    }
}
