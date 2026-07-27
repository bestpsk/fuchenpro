<?php

namespace app\controller\business;

use support\Request;
use app\service\BizAttendanceStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;

/**
 * 考勤统计控制器
 */
class BizAttendanceStatsController
{
    /**
     * 按员工+日期范围统计考勤汇总
     */
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:stats:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $service = new BizAttendanceStatsService();
            $params = convert_to_snake_case($request->all());
            $params['login_user'] = $request->loginUser;
            $result = $service->selectStatsList($params);
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            return AjaxResult::error('查询考勤统计失败');
        }
    }

    /**
     * 日历视图统计：返回每个员工每天的考勤状态
     */
    public function calendar(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:stats:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $service = new BizAttendanceStatsService();
            $params = convert_to_snake_case($request->all());
            $params['login_user'] = $request->loginUser;
            $result = $service->selectCalendarStats($params);
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            return AjaxResult::error('查询考勤日历统计失败');
        }
    }

    /**
     * 导出统计报表（预留，后续可实现）
     */
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:stats:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        // 导出功能预留
        return AjaxResult::error('导出功能开发中');
    }
}
