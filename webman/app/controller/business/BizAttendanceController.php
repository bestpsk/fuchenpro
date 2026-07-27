<?php

namespace app\controller\business;

use support\Request;
use app\service\BizAttendanceRuleService;
use app\service\BizAttendanceRecordService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizAttendanceRecord;

/**
 * 考勤打卡控制器
 *
 * 负责员工考勤打卡（上班/下班）、今日打卡记录查询、
 * 月度考勤统计、考勤记录管理和考勤规则管理等功能
 */
class BizAttendanceController
{
    // 获取当前用户今日考勤记录
    public function todayRecord(Request $request)
    {
        $userId = $request->loginUser->user->user_id;
        try {
            $service = new BizAttendanceRecordService();
            $record = $service->getTodayRecord($userId);
            return AjaxResult::success($record);
        } catch (\Throwable $e) {
            return AjaxResult::error('获取今日考勤记录失败');
        }
    }

    // 通用打卡接口（上班或下班）
    public function clock(Request $request)
    {
        $user = $request->loginUser->user;
        $data = convert_to_snake_case($request->post());
        $data['user_id'] = $user->user_id;
        $data['user_name'] = $user->nick_name ?? $user->user_name;

        try {
            $service = new BizAttendanceRecordService();
            $result = $service->clock($data);

            if (isset($result['error'])) {
                return AjaxResult::error($result['error']);
            }

            return AjaxResult::success('打卡成功', $result);
        } catch (\Throwable $e) {
            return AjaxResult::error('打卡失败：' . $e->getMessage());
        }
    }

    // 获取当前用户今日打卡流水列表
    public function todayClockList(Request $request)
    {
        $userId = $request->loginUser->user->user_id;
        try {
            $service = new BizAttendanceRecordService();
            $list = $service->getTodayClockList($userId);
            return AjaxResult::success($list);
        } catch (\Throwable $e) {
            return AjaxResult::error('获取打卡流水失败');
        }
    }

    // 根据考勤记录ID查询打卡流水
    public function clockList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:record:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $recordId = $request->get('record_id');
        if (!$recordId) {
            return AjaxResult::error('缺少参数：record_id');
        }

        try {
            $clocks = \app\model\BizAttendanceClock::where('record_id', $recordId)
                ->orderBy('clock_time', 'asc')
                ->get();

            return AjaxResult::success($clocks);
        } catch (\Throwable $e) {
            return AjaxResult::error('查询打卡流水失败');
        }
    }

    // 获取指定月份的考勤统计数据（出勤天数、迟到次数等）
    public function monthStats(Request $request)
    {
        $userId = $request->input('user_id', $request->loginUser->user->user_id);
        $month = $request->input('month', date('Y-m'));

        // 非管理员只能查看自己的考勤统计
        if ($userId != $request->loginUser->user->user_id) {
            if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:record:list')) {
                return json(['code' => 403, 'msg' => '没有操作权限']);
            }
        }

        try {
            $service = new BizAttendanceRecordService();
            $stats = $service->getMonthStats($userId, $month);
            return AjaxResult::success($stats);
        } catch (\Throwable $e) {
            return AjaxResult::error('获取考勤统计失败');
        }
    }

    // 分页查询考勤记录列表（管理端）
    public function recordList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:record:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizAttendanceRecordService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectRecordList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 导出考勤记录Excel
    public function exportRecord(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:record:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $service = new BizAttendanceRecordService();
            $params = convert_to_snake_case($request->all());
            $params['login_user'] = $request->loginUser;
            $params['page_size'] = 10000;
            $result = $service->selectRecordList($params);
            $list = $result->items();
            $excelUtil = new ExcelUtil(BizAttendanceRecord::class);
            return $excelUtil->exportExcel($list, '考勤记录');
        } catch (\Throwable $e) {
            return AjaxResult::error('导出考勤记录失败：' . $e->getMessage());
        }
    }

    // 根据ID获取考勤记录详情
    public function recordInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:record:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $recordId = intval(end($parts));
        $service = new BizAttendanceRecordService();
        $record = $service->selectRecordById($recordId);
        if (!$record) {
            return AjaxResult::error('记录不存在');
        }
        return AjaxResult::success($record);
    }

    // 分页查询考勤规则列表
    public function ruleList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:rule:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizAttendanceRuleService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectRuleList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取考勤规则详情
    public function ruleInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:rule:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $ruleId = intval(end($parts));
        $service = new BizAttendanceRuleService();
        $rule = $service->selectRuleById($ruleId);
        if (!$rule) {
            return AjaxResult::error('规则不存在');
        }
        return AjaxResult::success($rule);
    }

    // 新增考勤规则
    public function addRule(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:rule:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['create_by'] = $request->loginUser->user->user_name ?? '';
            $service = new BizAttendanceRuleService();
            $result = $service->insertRule($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error('新增考勤规则失败：' . $e->getMessage());
        }
    }

    // 修改考勤规则
    public function editRule(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:rule:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $service = new BizAttendanceRuleService();
            $result = $service->updateRule($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error('修改考勤规则失败：' . $e->getMessage());
        }
    }

    // 批量删除考勤规则
    public function removeRule(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:rule:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $ruleIds = $request->input('ruleIds', '');
            if (!is_array($ruleIds)) {
                $ruleIds = explode(',', $ruleIds);
            }
            $ruleIds = array_map('intval', array_filter($ruleIds));
            $service = new BizAttendanceRuleService();
            $result = $service->deleteRuleByIds($ruleIds);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error('删除考勤规则失败：' . $e->getMessage());
        }
    }
}
