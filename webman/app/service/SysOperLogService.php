<?php

namespace app\service;

use app\model\SysOperLog;

/**
 * 操作日志服务层，处理操作日志的查询、新增和清理
 */
class SysOperLogService
{
    // 按条件分页查询操作日志列表
    public function selectOperLogList($params = [])
    {
        $query = SysOperLog::query();

        if (!empty($params['title'])) {
            $query->where('title', 'like', '%' . $params['title'] . '%');
        }
        if (isset($params['business_type']) && $params['business_type'] !== '') {
            $query->where('business_type', $params['business_type']);
        }
        if (!empty($params['oper_name'])) {
            $query->where('oper_name', 'like', '%' . $params['oper_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['begin_time'])) {
            $query->where('oper_time', '>=', $params['begin_time']);
        }
        if (!empty($params['end_time'])) {
            $query->where('oper_time', '<=', $params['end_time']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('oper_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 新增操作日志

    public function insertOperLog($data)
    {
        return SysOperLog::create($data);
    }

    // 批量删除操作日志

    public function deleteOperLogByIds($operIds)
    {
        return SysOperLog::whereIn('oper_id', $operIds)->delete();
    }

    // 清空操作日志

    public function cleanOperLog()
    {
        return SysOperLog::truncate();
    }
}
