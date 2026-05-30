<?php

namespace app\service;

use app\model\BizFeedback;
use app\model\BizFeedbackReply;
use app\model\SysUser;

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
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('feedback_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    public function selectFeedbackById($feedbackId)
    {
        $feedback = BizFeedback::find($feedbackId);
        if ($feedback) {
            $user = SysUser::where('user_name', $feedback->create_by)->first();
            $feedback->create_nick_name = $user ? $user->nick_name : $feedback->create_by;
            $feedback->replies = BizFeedbackReply::where('feedback_id', $feedbackId)
                ->orderBy('reply_id', 'asc')->get()->map(function ($reply) {
                    $replyUser = SysUser::where('user_name', $reply->create_by)->first();
                    $reply->create_nick_name = $replyUser ? $replyUser->nick_name : $reply->create_by;
                    return $reply;
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
        $data['update_time'] = date('Y-m-d H:i:s');
        return BizFeedback::where('feedback_id', $data['feedback_id'])->update(
            collect($data)->only(['title', 'content', 'feedback_type', 'status', 'update_by', 'update_time'])->toArray()
        );
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
        return BizFeedbackReply::where('feedback_id', $feedbackId)
            ->orderBy('reply_id', 'asc')->get()->map(function ($reply) {
                $user = SysUser::where('user_name', $reply->create_by)->first();
                $reply->create_nick_name = $user ? $user->nick_name : $reply->create_by;
                return $reply;
            });
    }
}
