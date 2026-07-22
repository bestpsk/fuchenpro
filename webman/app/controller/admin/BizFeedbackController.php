<?php

namespace app\controller\admin;

use support\Request;
use app\service\BizFeedbackService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

class BizFeedbackController
{
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizFeedbackService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectFeedbackList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $feedbackId = intval(end($parts));
        $service = new BizFeedbackService();
        $feedback = $service->selectFeedbackById($feedbackId);
        if (!$feedback) return AjaxResult::error('反馈不存在');
        return AjaxResult::success($feedback);
    }

    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizFeedbackService();
        $result = $service->insertFeedback($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizFeedbackService();
        $result = $service->updateFeedback($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $feedbackIds = $request->input('feedbackIds', '');
        if (!is_array($feedbackIds)) {
            $feedbackIds = explode(',', $feedbackIds);
        }
        $feedbackIds = array_map('intval', array_filter($feedbackIds));
        $service = new BizFeedbackService();
        $result = $service->deleteFeedbackByIds($feedbackIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function handle(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:handle')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizFeedbackService();
        $result = $service->updateFeedback($data);
        if ($result && !empty($data['reply_content'])) {
            $service->insertReply([
                'feedback_id' => $data['feedback_id'],
                'content' => $data['reply_content'],
                'create_by' => $request->loginUser->user->user_name ?? '',
            ]);
        }
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function reply(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:handle')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizFeedbackService();
        $result = $service->insertReply($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function replyList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'admin:feedback:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $feedbackId = intval($request->input('feedback_id', 0));
        $service = new BizFeedbackService();
        $list = $service->selectReplyList($feedbackId);
        return AjaxResult::success($list);
    }
}
