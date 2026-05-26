<?php

namespace app\controller\system;

use support\Request;
use app\service\SysNoticeService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 通知公告管理控制器
 *
 * 负责通知公告的增删改查、顶部通知列表、已读标记、
 * 全部已读标记和已读用户列表等功能
 */
class SysNoticeController
{
    // 分页查询通知公告列表
    public function list(Request $request)
    {
        $service = new SysNoticeService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectNoticeList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取通知公告详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $noticeId = intval(end($parts));
        $service = new SysNoticeService();
        $notice = $service->selectNoticeById($noticeId);
        if (!$notice) return AjaxResult::error('公告不存在');
        return AjaxResult::success($notice);
    }

    // 新增通知公告
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysNoticeService();
        return AjaxResult::toAjax($service->insertNotice($data) ? 1 : 0);
    }

    // 修改通知公告
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysNoticeService();
        return AjaxResult::toAjax($service->updateNotice($data) ? 1 : 0);
    }

    // 批量删除通知公告
    public function remove(Request $request)
    {
        $noticeIds = explode(',', $request->input('noticeIds', ''));
        $noticeIds = array_map('intval', array_filter($noticeIds));
        $service = new SysNoticeService();
        return AjaxResult::toAjax($service->deleteNoticeByIds($noticeIds) ? 1 : 0);
    }

    // 获取当前用户顶部未读通知列表
    public function listTop(Request $request)
    {
        $service = new SysNoticeService();
        return AjaxResult::success($service->listTop($request->loginUser->userId));
    }

    // 标记指定通知为已读
    public function markRead(Request $request)
    {
        $noticeId = $request->post('noticeId') ?? $request->input('noticeId');
        $service = new SysNoticeService();
        return AjaxResult::toAjax($service->markRead($request->loginUser->userId, $noticeId) ? 1 : 0);
    }

    // 标记当前用户所有通知为已读
    public function markReadAll(Request $request)
    {
        $service = new SysNoticeService();
        return AjaxResult::toAjax($service->markReadAll($request->loginUser->userId) ? 1 : 0);
    }

    // 分页查询指定通知的已读用户列表
    public function readUsersList(Request $request)
    {
        $parts = explode('/', $request->path());
        $noticeId = 0;
        foreach ($parts as $i => $p) {
            if ($p === 'readUsers' && isset($parts[$i + 1]) && $parts[$i + 1] === 'list') {
                $noticeId = intval($parts[$i - 1] ?? 0);
                break;
            }
        }
        $service = new SysNoticeService();
        $result = $service->readUsersList($noticeId, $request->all());
        return TableDataInfo::result($result->items(), $result->total());
    }
}
