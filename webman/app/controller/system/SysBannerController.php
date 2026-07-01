<?php

namespace app\controller\system;

use support\Request;
use app\service\SysBannerService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

class SysBannerController
{
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:banner:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $result = SysBannerService::selectBannerList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:banner:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $bannerId = intval(end($parts));
        $banner = SysBannerService::selectBannerById($bannerId);
        if (!$banner) {
            return AjaxResult::error('轮播图不存在');
        }
        return AjaxResult::success($banner);
    }

    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:banner:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        return AjaxResult::toAjax(SysBannerService::insertBanner($data) ? 1 : 0);
    }

    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:banner:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        return AjaxResult::toAjax(SysBannerService::updateBanner($data) ? 1 : 0);
    }

    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:banner:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $bannerIds = explode(',', $request->input('bannerIds', ''));
        $bannerIds = array_map('intval', array_filter($bannerIds));
        return AjaxResult::toAjax(SysBannerService::deleteBannerByIds($bannerIds) ? 1 : 0);
    }

    public function appList(Request $request)
    {
        $banners = SysBannerService::selectEnabledBanners();
        return AjaxResult::success($banners);
    }
}
