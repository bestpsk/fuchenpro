<?php

namespace app\controller\business;

use support\Request;
use app\service\BizHolidayService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 假期日历控制器
 */
class BizHolidayController
{
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:holiday:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizHolidayService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $holidayId = intval(end($parts));
        $service = new BizHolidayService();
        $holiday = $service->selectById($holidayId);
        if (!$holiday) return AjaxResult::error('假期不存在');
        return AjaxResult::success($holiday);
    }

    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:holiday:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizHolidayService();
            $result = $service->insert($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:holiday:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        try {
            $service = new BizHolidayService();
            $result = $service->update($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:holiday:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $holidayIds = $request->input('holidayIds', '');
        if (!is_array($holidayIds)) {
            $holidayIds = explode(',', $holidayIds);
        }
        $holidayIds = array_map('intval', array_filter($holidayIds));
        if (empty($holidayIds)) {
            return AjaxResult::error('请选择要删除的假期');
        }
        $service = new BizHolidayService();
        $result = $service->deleteByIds($holidayIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
