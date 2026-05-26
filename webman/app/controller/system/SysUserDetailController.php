<?php

namespace app\controller\system;

use support\Request;
use app\service\SysUserDetailService;
use app\common\AjaxResult;

/**
 * 用户详情控制器
 *
 * 负责用户扩展详情的查询、新增和修改，用户详情包含额外的个人信息字段
 */
class SysUserDetailController
{
    // 根据用户ID获取用户扩展详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $userId = intval(end($parts));
        $service = new SysUserDetailService();
        $detail = $service->selectDetailByUserId($userId);
        return AjaxResult::success($detail);
    }

    // 新增用户扩展详情
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysUserDetailService();
        $result = $service->insertDetail($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改用户扩展详情
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysUserDetailService();
        $result = $service->updateDetail($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function getWelcomeSlogan(Request $request)
    {
        $userId = $request->loginUser->userId;
        $service = new SysUserDetailService();
        $detail = $service->selectDetailByUserId($userId);
        return AjaxResult::success('', $detail ? $detail->welcome_slogan : '');
    }

    public function setWelcomeSlogan(Request $request)
    {
        $userId = $request->loginUser->userId;
        $welcomeSlogan = $request->input('welcomeSlogan') ?? $request->post('welcomeSlogan');
        $service = new SysUserDetailService();
        $result = $service->setWelcomeSlogan($userId, $welcomeSlogan);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
