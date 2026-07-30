<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysOperLogService;
use app\service\PermissionService;
use app\model\SysOperLog;
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
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:operlog:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysOperLogService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectOperLogList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 批量删除操作日志
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:operlog:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $operIds = $request->input('operIds', '') ?: $request->input('operId', '');
        $operIds = explode(',', $operIds);
        $operIds = array_map('intval', array_filter($operIds));
        $service = new SysOperLogService();
        return AjaxResult::toAjax($service->deleteOperLogByIds($operIds) ? 1 : 0);
    }

    // 清空全部操作日志
    public function clean(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:operlog:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysOperLogService();
        $service->cleanOperLog();
        return AjaxResult::success();
    }

    // 导出操作日志为Excel
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:operlog:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['pageSize'] = 5000;
        $service = new SysOperLogService();
        $result = $service->selectOperLogList($params);
        $list = $result->items();

        $excelUtil = new \app\common\ExcelUtil(SysOperLog::class);
        return $excelUtil->exportExcel($list, '操作日志');
    }
}
