<?php

namespace app\service;

use app\model\SysNotice;
use app\model\SysNoticeRead;
use app\model\SysUser;

/**
 * 通知公告服务层，处理通知的增删改查、已读标记和已读用户查询
 */
class SysNoticeService
{
    // 按条件分页查询通知公告列表
    public function selectNoticeList($params = [], $userId = null)
    {
        $query = SysNotice::query();

        if (!empty($params['notice_title'])) {
            $query->where('notice_title', 'like', '%' . $params['notice_title'] . '%');
        }
        if (!empty($params['notice_type'])) {
            $query->where('notice_type', $params['notice_type']);
        }
        if (!empty($params['create_by'])) {
            $query->where('create_by', 'like', '%' . $params['create_by'] . '%');
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('notice_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        if ($userId) {
            $readIds = SysNoticeRead::where('user_id', $userId)->pluck('notice_id')->toArray();
            foreach ($result->items() as $item) {
                $item->is_read = in_array($item->notice_id, $readIds);
            }
        }

        return $result;
    }

    // 根据ID查询通知公告详情

    public function selectNoticeById($noticeId)
    {
        $notice = SysNotice::find($noticeId);
        if ($notice && $notice->create_by) {
            $user = SysUser::where('user_name', $notice->create_by)->first();
            $notice->create_nick_name = $user ? $user->nick_name : $notice->create_by;
        } else {
            $notice->create_nick_name = '';
        }
        return $notice;
    }

    // 新增通知公告

    public function insertNotice($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysNotice::create($data);
    }

    // 更新通知公告信息

    public function updateNotice($data)
    {
        $noticeId = $data['notice_id'] ?? null;
        if (!$noticeId) {
            return false;
        }
        $notice = SysNotice::find($noticeId);
        if (!$notice) {
            return false;
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        // 使用 fill()->save() 恢复 $fillable 过滤，避免非数据库字段（如 create_nick_name）触发 SQL 错误
        $notice->fill($data)->save();
        return true;
    }

    // 批量删除通知公告

    public function deleteNoticeByIds($noticeIds)
    {
        SysNoticeRead::whereIn('notice_id', $noticeIds)->delete();
        return SysNotice::whereIn('notice_id', $noticeIds)->delete();
    }

    public function listTop($userId)
    {
        $notices = SysNotice::where('status', '0')
            ->orderBy('create_time', 'desc')
            ->limit(10)
            ->get();

        $readIds = SysNoticeRead::where('user_id', $userId)->pluck('notice_id')->toArray();

        $unreadCount = 0;
        $list = [];
        foreach ($notices as $notice) {
            $isRead = in_array($notice->notice_id, $readIds);
            $item = $notice->toArray();
            $item['is_read'] = $isRead;
            $list[] = $item;
            if (!$isRead) {
                $unreadCount++;
            }
        }

        return [
            'list' => $list,
            'unreadCount' => $unreadCount
        ];
    }

    public function markRead($userId, $noticeId)
    {
        $exists = SysNoticeRead::where('user_id', $userId)->where('notice_id', $noticeId)->exists();
        if (!$exists) {
            SysNoticeRead::create([
                'user_id' => $userId,
                'notice_id' => $noticeId,
                'read_time' => date('Y-m-d H:i:s'),
            ]);
        }
        return true;
    }

    public function markReadAll($userId)
    {
        $notices = SysNotice::where('status', '0')->pluck('notice_id')->toArray();
        $readIds = SysNoticeRead::where('user_id', $userId)->pluck('notice_id')->toArray();
        $unreadIds = array_diff($notices, $readIds);

        $data = [];
        foreach ($unreadIds as $noticeId) {
            $data[] = [
                'user_id' => $userId,
                'notice_id' => $noticeId,
                'read_time' => date('Y-m-d H:i:s'),
            ];
        }
        if (!empty($data)) {
            SysNoticeRead::insert($data);
        }
        return true;
    }

    public function readUsersList($noticeId, $params = [])
    {
        $query = SysNoticeRead::join('sys_user', 'sys_notice_read.user_id', '=', 'sys_user.user_id')
            ->leftJoin('sys_dept', 'sys_user.dept_id', '=', 'sys_dept.dept_id')
            ->where('sys_notice_read.notice_id', $noticeId)
            ->where('sys_user.del_flag', '0')
            ->select(
                'sys_user.user_id',
                'sys_user.user_name',
                'sys_user.nick_name',
                'sys_user.phonenumber',
                'sys_dept.dept_name as deptName',
                'sys_notice_read.read_time'
            );

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->paginate($pageSize, ['*'], 'page', $pageNum);
    }
}
