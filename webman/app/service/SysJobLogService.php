<?php

namespace app\service;

use app\model\SysJobLog;

/**
 * 任务执行日志服务层，处理任务日志的查询和清理
 */
class SysJobLogService
{
    // 按条件分页查询定时任务日志列表
    public function selectJobLogList($params = [])
    {
        $query = SysJobLog::query();

        if (!empty($params['job_name'])) {
            $query->where('job_name', 'like', '%' . $params['job_name'] . '%');
        }
        if (!empty($params['job_group'])) {
            $query->where('job_group', $params['job_group']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['invoke_target'])) {
            $query->where('invoke_target', 'like', '%' . $params['invoke_target'] . '%');
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('job_log_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 批量删除定时任务日志

    public function deleteJobLogByIds($jobLogIds)
    {
        return SysJobLog::whereIn('job_log_id', $jobLogIds)->delete();
    }

    // 清空定时任务日志（使用delete代替truncate，保留自增ID便于审计追溯）

    public function cleanJobLog()
    {
        return SysJobLog::query()->delete();
    }
}
