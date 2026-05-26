<?php

namespace app\controller\system;

use support\Request;
use app\service\SysBannerService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

class SysBannerController
{
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = SysBannerService::selectBannerList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
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
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        return AjaxResult::toAjax(SysBannerService::insertBanner($data) ? 1 : 0);
    }

    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        return AjaxResult::toAjax(SysBannerService::updateBanner($data) ? 1 : 0);
    }

    public function remove(Request $request)
    {
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
