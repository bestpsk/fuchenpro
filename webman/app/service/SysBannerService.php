<?php

namespace app\service;

use app\model\SysBanner;

class SysBannerService
{
    public static function selectBannerList($params = [])
    {
        $query = SysBanner::query();

        if (!empty($params['title'])) {
            $query->where('title', 'like', '%' . $params['title'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('sort_order', 'asc')->orderBy('banner_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    public static function selectBannerById($bannerId)
    {
        return SysBanner::find($bannerId);
    }

    public static function insertBanner($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysBanner::create($data);
    }

    public static function updateBanner($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return SysBanner::where('banner_id', $data['banner_id'])->update($data);
    }

    public static function deleteBannerByIds($bannerIds)
    {
        return SysBanner::whereIn('banner_id', $bannerIds)->delete();
    }

    public static function selectEnabledBanners()
    {
        return SysBanner::where('status', '0')
            ->orderBy('sort_order', 'asc')
            ->orderBy('banner_id', 'desc')
            ->get();
    }
}
