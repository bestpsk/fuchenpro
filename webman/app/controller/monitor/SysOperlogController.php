<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysOperLogService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 操作日志控制器
 *
 * 负责操作日志的查询、批量删除和清空全部日志功能
 */
class SysOperlogController
{
    // 分页查询操作日志列表
    public function list(Request $request)
    {
        $service = new SysOperLogService();
        $result = $service->selectOperLogList($request->all());
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 批量删除操作日志
    public function remove(Request $request)
    {
        $operIds = explode(',', $request->input('operIds', ''));
        $operIds = array_map('intval', array_filter($operIds));
        $service = new SysOperLogService();
        return AjaxResult::toAjax($service->deleteOperLogByIds($operIds) ? 1 : 0);
    }

    // 清空全部操作日志
    public function clean(Request $request)
    {
        $service = new SysOperLogService();
        $service->cleanOperLog();
        return AjaxResult::success();
    }
}
