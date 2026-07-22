<?php

namespace app\service;

use app\model\SysPost;

/**
 * 岗位服务层，处理岗位的增删改查
 */
class SysPostService
{
    // 按条件分页查询岗位列表
    public function selectPostList($params = [])
    {
        $query = SysPost::query();

        if (!empty($params['keyword'])) {
            $kw = '%' . $params['keyword'] . '%';
            $query->where(function ($q) use ($kw) {
                $q->where('post_code', 'like', $kw)
                  ->orWhere('post_name', 'like', $kw);
            });
        }
        if (!empty($params['post_code'])) {
            $query->where('post_code', 'like', '%' . $params['post_code'] . '%');
        }
        if (!empty($params['post_name'])) {
            $query->where('post_name', 'like', '%' . $params['post_name'] . '%');
        }
        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('post_sort', 'asc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询岗位详情

    public function selectPostById($postId)
    {
        return SysPost::find($postId);
    }

    // 查询所有岗位

    public function selectPostAll()
    {
        return SysPost::where('status', '0')->orderBy('post_sort', 'asc')->get();
    }

    // 新增岗位

    public function insertPost($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysPost::create($data);
    }

    // 更新岗位信息

    public function updatePost($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return SysPost::where('post_id', $data['post_id'])->update($data);
    }

    // 批量删除岗位

    public function deletePostByIds($postIds)
    {
        return SysPost::whereIn('post_id', $postIds)->delete();
    }
}
