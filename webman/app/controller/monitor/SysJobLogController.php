<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysJobLogService;
use app\service\PermissionService;
use app\model\SysJobLog;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;

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
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:jobLog:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysJobLogService();
        $result = $service->selectJobLogList($request->all());
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 批量删除任务执行日志
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:jobLog:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $jobLogIds = explode(',', $request->input('jobLogIds', ''));
        $jobLogIds = array_map('intval', array_filter($jobLogIds));
        $service = new SysJobLogService();
        return AjaxResult::toAjax($service->deleteJobLogByIds($jobLogIds) ? 1 : 0);
    }

    // 清空全部任务执行日志
    public function clean(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:jobLog:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysJobLogService();
        $service->cleanJobLog();
        return AjaxResult::success();
    }

    // 导出任务执行日志为Excel
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:jobLog:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = $request->all();
        $params['page_size'] = 10000;
        $service = new SysJobLogService();
        $result = $service->selectJobLogList($params);
        $list = $result->items();

        $excelUtil = new ExcelUtil(SysJobLog::class);
        return $excelUtil->exportExcel($list, '任务日志');
    }
}
