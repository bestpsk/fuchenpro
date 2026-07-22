<?php

namespace app\service;

use app\model\SysLogininfor;

/**
 * 登录日志服务层，处理登录日志的查询、新增、清理和用户解锁
 */
class SysLogininforService
{
    // 按条件分页查询登录日志列表
    public function selectLogininforList($params = [])
    {
        $query = SysLogininfor::query();

        if (!empty($params['keyword'])) {
            $query->where(function($q) use ($params) {
                $q->where('user_name', 'like', '%' . $params['keyword'] . '%')
                  ->orWhere('ipaddr', 'like', '%' . $params['keyword'] . '%');
            });
        }
        if (!empty($params['ipaddr'])) {
            $query->where('ipaddr', 'like', '%' . $params['ipaddr'] . '%');
        }
        if (!empty($params['user_name'])) {
            $query->where('user_name', 'like', '%' . $params['user_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['login_source'])) {
            $query->where('login_source', $params['login_source']);
        }
        if (!empty($params['begin_time'])) {
            $query->where('login_time', '>=', $params['begin_time']);
        }
        if (!empty($params['end_time'])) {
            $query->where('login_time', '<=', $params['end_time']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('info_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 新增登录日志

    public function insertLogininfor($data)
    {
        return SysLogininfor::create($data);
    }

    // 批量删除登录日志

    public function deleteLogininforByIds($infoIds)
    {
        return SysLogininfor::whereIn('info_id', $infoIds)->delete();
    }

    // 清空登录日志

    public function cleanLogininfor()
    {
        return SysLogininfor::truncate();
    }

    public function unlock($userName)
    {
        $redis = \support\Redis::connection();
        $redis->del(\app\common\Constants::PWD_ERR_CNT_KEY . $userName);
        return true;
    }
}
