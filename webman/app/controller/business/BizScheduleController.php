<?php

namespace app\controller\business;

use support\Request;
use app\service\BizScheduleService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizSchedule;

/**
 * 行程安排控制器
 *
 * 负责员工行程的增删改查、日历视图查询、按日期范围查询、
 * 员工维度和企业维度行程统计，支持批量新增行程
 */
class BizScheduleController
{
    // 分页查询行程列表
    public function list(Request $request)
    {
        $service = new BizScheduleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectScheduleList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取行程详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $scheduleId = intval(end($parts));
        $service = new BizScheduleService();
        $schedule = $service->selectScheduleById($scheduleId);
        if (!$schedule) return AjaxResult::error('行程不存在');
        return AjaxResult::success($schedule);
    }

    // 按日期范围查询行程，返回日历视图数据
    public function calendar(Request $request)
    {
        $service = new BizScheduleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectScheduleByDateRange($params);
        return AjaxResult::success($result);
    }

    // 查询有行程安排的日期列表（用于日历标记）
    public function dates(Request $request)
    {
        $service = new BizScheduleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectScheduleDates($params);
        return AjaxResult::success($result);
    }

    // 查询员工维度的行程安排
    public function employeeSchedule(Request $request)
    {
        $service = new BizScheduleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectEmployeeSchedule($params);
        return AjaxResult::success($result);
    }

    // 查询企业维度的行程安排
    public function enterpriseSchedule(Request $request)
    {
        $service = new BizScheduleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectEnterpriseSchedule($params);
        return AjaxResult::success($result);
    }

    // 新增单条行程
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:schedule:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizScheduleService();
        $result = $service->insertSchedule($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量新增行程
    public function addBatch(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:schedule:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $dataList = $request->post();
        $service = new BizScheduleService();
        
        $insertData = [];
        $createBy = $request->loginUser->user->user_name ?? '';
        
        foreach ($dataList as $item) {
            $item = convert_to_snake_case($item);
            $item['create_by'] = $createBy;
            $insertData[] = $item;
        }
        
        $result = $service->insertScheduleBatch($insertData);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改行程信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:schedule:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $service = new BizScheduleService();
            $result = $service->updateSchedule($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error('修改行程失败，请稍后重试');
        }
    }

    // 批量删除行程
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:schedule:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $scheduleIds = $request->input('scheduleIds', '');
        if (!is_array($scheduleIds)) {
            $scheduleIds = explode(',', $scheduleIds);
        }
        $scheduleIds = array_map('intval', array_filter($scheduleIds));
        
        if (empty($scheduleIds)) {
            return AjaxResult::error('请选择要删除的行程');
        }
        
        $service = new BizScheduleService();
        $result = $service->deleteScheduleByIds($scheduleIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 导出行程数据
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:schedule:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $service = new BizScheduleService();
        $result = $service->selectScheduleList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizSchedule::class);
        return $excelUtil->exportExcel($list, '行程数据');
    }
}
