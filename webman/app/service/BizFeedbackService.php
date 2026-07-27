<?php

namespace app\service;

use app\model\BizFeedback;
use app\model\BizFeedbackReply;
use app\model\SysUser;
use app\service\DataScopeService;

class BizFeedbackService
{
    public function selectFeedbackList($params = [])
    {
        $query = BizFeedback::query();
        if (!empty($params['status']) || (isset($params['status']) && $params['status'] === '0')) {
            $query->where('status', $params['status']);
        }
        if (!empty($params['feedback_type']) || (isset($params['feedback_type']) && $params['feedback_type'] === '0')) {
            $query->where('feedback_type', $params['feedback_type']);
        }
        if (!empty($params['create_by'])) {
            $query->where('create_by', 'like', '%' . $params['create_by'] . '%');
        }
        if (!empty($params['title'])) {
            $query->where('title', 'like', '%' . $params['title'] . '%');
        }
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                ->pluck('user_name')->toArray();
            $query->whereIn('create_by', $visibleUserNames);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('feedback_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    public function selectFeedbackById($feedbackId)
    {
        $feedback = BizFeedback::find($feedbackId);
        if ($feedback) {
            // 批量查询反馈和所有回复的用户昵称，避免N+1查询
            $userNames = collect([$feedback->create_by]);
            $feedback->replies = BizFeedbackReply::where('feedback_id', $feedbackId)
                ->orderBy('reply_id', 'asc')->get();
            $userNames = $userNames->merge($feedback->replies->pluck('create_by'))->filter()->unique()->values()->all();
            $userMap = SysUser::whereIn('user_name', $userNames)->pluck('nick_name', 'user_name');

            $feedback->create_nick_name = $userMap[$feedback->create_by] ?? $feedback->create_by;
            $feedback->replies->each(function ($reply) use ($userMap) {
                $reply->create_nick_name = $userMap[$reply->create_by] ?? $reply->create_by;
            });
        }
        return $feedback;
    }

    public function insertFeedback($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizFeedback::create($data);
    }

    public function updateFeedback($data)
    {
        $feedback = BizFeedback::find($data['feedback_id']);
        if (!$feedback) return false;
        $feedback->fill($data);
        $feedback->update_by = $data['update_by'] ?? '';
        $feedback->update_time = date('Y-m-d H:i:s');
        return $feedback->save();
    }

    public function deleteFeedbackByIds($feedbackIds)
    {
        BizFeedbackReply::whereIn('feedback_id', $feedbackIds)->delete();
        return BizFeedback::whereIn('feedback_id', $feedbackIds)->delete();
    }

    public function insertReply($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizFeedbackReply::create($data);
    }

    public function selectReplyList($feedbackId)
    {
        $replies = BizFeedbackReply::where('feedback_id', $feedbackId)
            ->orderBy('reply_id', 'asc')->get();
        // 批量查询用户昵称，避免N+1查询
        $userNames = $replies->pluck('create_by')->filter()->unique()->values()->all();
        $userMap = SysUser::whereIn('user_name', $userNames)->pluck('nick_name', 'user_name');
        return $replies->map(function ($reply) use ($userMap) {
            $reply->create_nick_name = $userMap[$reply->create_by] ?? $reply->create_by;
            return $reply;
        });
    }
}
