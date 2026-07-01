<?php

namespace app\controller\system;

use support\Request;
use app\service\SysPostService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 岗位管理控制器
 *
 * 负责岗位的增删改查功能
 */
class SysPostController
{
    // 分页查询岗位列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:post:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysPostService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectPostList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取岗位详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:post:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $postId = intval(end($parts));
        $service = new SysPostService();
        $post = $service->selectPostById($postId);
        if (!$post) return AjaxResult::error('岗位不存在');
        return AjaxResult::success($post);
    }

    // 新增岗位
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:post:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysPostService();
        $result = $service->insertPost($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改岗位信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:post:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysPostService();
        $result = $service->updatePost($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除岗位
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:post:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $postIds = explode(',', $request->input('postIds', ''));
        $postIds = array_map('intval', array_filter($postIds));
        $service = new SysPostService();
        $result = $service->deletePostByIds($postIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
