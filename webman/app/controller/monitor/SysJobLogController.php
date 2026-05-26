<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysJobLogService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 任务执行日志控制器
 *
 * 负责定时任务执行日志的查询、批量删除和清空全部日志功能
 */
class SysJobLogController
{
    // 分页查询任务执行日志列表
    public function list(Request $request)
    {
        $service = new SysJobLogService();
        $result = $service->selectJobLogList($request->all());
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 批量删除任务执行日志
    public function remove(Request $request)
    {
        $jobLogIds = explode(',', $request->input('jobLogIds', ''));
        $jobLogIds = array_map('intval', array_filter($jobLogIds));
        $service = new SysJobLogService();
        return AjaxResult::toAjax($service->deleteJobLogByIds($jobLogIds) ? 1 : 0);
    }

    // 清空全部任务执行日志
    public function clean(Request $request)
    {
        $service = new SysJobLogService();
        $service->cleanJobLog();
        return AjaxResult::success();
    }
}
