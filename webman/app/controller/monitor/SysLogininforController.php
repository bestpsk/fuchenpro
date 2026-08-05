<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysLogininforService;
use app\service\PermissionService;
use app\model\SysLogininfor;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 登录日志控制器
 *
 * 负责登录日志的查询、批量删除、清空全部日志和用户解锁功能
 */
class SysLogininforController
{
    // 分页查询登录日志列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:logininfor:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysLogininforService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectLogininforList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 批量删除登录日志
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:logininfor:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $infoIds = $request->input('infoIds', '') ?: $request->input('infoId', '');
        $infoIds = explode(',', $infoIds);
        $infoIds = array_map('intval', array_filter($infoIds));
        $service = new SysLogininforService();
        return AjaxResult::toAjax($service->deleteLogininforByIds($infoIds) ? 1 : 0);
    }

    // 清空全部登录日志
    public function clean(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:logininfor:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysLogininforService();
        $service->cleanLogininfor();
        return AjaxResult::success();
    }

    // 解除指定用户的登录锁定（清除密码错误计数缓存）
    public function unlock(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:logininfor:unlock')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $userName = end($parts);
        $service = new SysLogininforService();
        $service->unlock($userName);
        return AjaxResult::success();
    }

    // 导出登录日志为Excel
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:logininfor:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['page_size'] = 5000;
        $service = new SysLogininforService();
        $result = $service->selectLogininforList($params);
        $list = $result->items();

        $excelUtil = new \app\common\ExcelUtil(SysLogininfor::class);
        return $excelUtil->exportExcel($list, '登录日志');
    }
}
