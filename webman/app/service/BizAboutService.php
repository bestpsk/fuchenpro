<?php

namespace app\service;

use app\model\BizAbout;
use app\model\SysUser;

/**
 * 企业小报服务层，处理企业小报的增删改查
 */
class BizAboutService
{
    // 按条件分页查询企业小报列表
    public function selectAboutList($params = [])
    {
        $query = BizAbout::query();

        if (!empty($params['about_title'])) {
            $query->where('about_title', 'like', '%' . $params['about_title'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('sort', 'asc')->orderBy('about_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        return $result;
    }

    // 根据ID查询企业小报详情
    public function selectAboutById($aboutId)
    {
        $about = BizAbout::find($aboutId);
        if ($about && $about->create_by) {
            $user = SysUser::where('user_name', $about->create_by)->first();
            $about->create_nick_name = $user ? $user->nick_name : $about->create_by;
        } else {
            $about->create_nick_name = '';
        }
        return $about;
    }

    // 新增企业小报
    public function insertAbout($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizAbout::create($data);
    }

    // 更新企业小报信息
    public function updateAbout($data)
    {
        $aboutId = $data['about_id'] ?? null;
        if (!$aboutId) {
            return false;
        }
        $about = BizAbout::find($aboutId);
        if (!$about) {
            return false;
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        $about->fill($data)->save();
        return true;
    }

    // 批量删除企业小报
    public function deleteAboutByIds($aboutIds)
    {
        return BizAbout::whereIn('about_id', $aboutIds)->delete();
    }
}
