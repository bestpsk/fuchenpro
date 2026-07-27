<?php

namespace app\controller\business;

use support\Request;
use app\service\BizLeaveService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 请假管理控制器
 * 包含请假单CRUD、审批（通过/驳回）、撤销、日历查询
 */
class BizLeaveController
{
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizLeaveService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $leaveId = intval(end($parts));
        $service = new BizLeaveService();
        $leave = $service->selectById($leaveId);
        if (!$leave) return AjaxResult::error('请假单不存在');
        return AjaxResult::success($leave);
    }

    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;
        $data['user_id'] = $data['user_id'] ?? $loginUser->user->user_id;
        $data['user_name'] = $loginUser->user->nick_name ?? $loginUser->user->user_name ?? '';
        $data['dept_id'] = $loginUser->user->dept_id ?? null;
        $data['create_by'] = $loginUser->user->user_name ?? '';
        try {
            $service = new BizLeaveService();
            $result = $service->insert($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 审核通过
     */
    public function approve(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:approve')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $leaveId = intval($data['leave_id'] ?? 0);
        $remark = $data['approve_remark'] ?? '';
        $loginUser = $request->loginUser;
        try {
            $service = new BizLeaveService();
            $service->approve($leaveId, $loginUser->user->user_id, $loginUser->user->nick_name ?? $loginUser->user->user_name, $remark);
            return AjaxResult::success('审核通过');
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 审核驳回
     */
    public function reject(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:approve')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $leaveId = intval($data['leave_id'] ?? 0);
        $remark = $data['approve_remark'] ?? '';
        $loginUser = $request->loginUser;
        try {
            $service = new BizLeaveService();
            $service->reject($leaveId, $loginUser->user->user_id, $loginUser->user->nick_name ?? $loginUser->user->user_name, $remark);
            return AjaxResult::success('已驳回');
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    /**
     * 撤销请假单
     */
    public function cancel(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $leaveId = intval($data['leave_id'] ?? 0);
        $loginUser = $request->loginUser;
        try {
            $service = new BizLeaveService();
            $service->cancel($leaveId, $loginUser->user->user_id);
            return AjaxResult::success('已撤销');
        } catch (\Exception $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:leave:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $leaveIds = $request->input('leaveIds', '');
        if (!is_array($leaveIds)) {
            $leaveIds = explode(',', $leaveIds);
        }
        $leaveIds = array_map('intval', array_filter($leaveIds));
        if (empty($leaveIds)) {
            return AjaxResult::error('请选择要删除的请假单');
        }
        $service = new BizLeaveService();
        $result = $service->deleteByIds($leaveIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    /**
     * 获取员工某月的休假日期列表（供行程安排日历集成使用）
     * GET /business/leave/calendar?yearMonth=2026-07&userIds=1,2,3
     */
    public function calendar(Request $request)
    {
        $yearMonth = $request->input('yearMonth', date('Y-m'));
        $userIdsParam = $request->input('userIds', '');
        if (empty($userIdsParam)) {
            return AjaxResult::success([]);
        }
        $userIds = array_map('intval', explode(',', $userIdsParam));
        $service = new BizLeaveService();
        $result = $service->getLeaveCalendar($userIds, $yearMonth);
        // 直接返回json，避免AjaxResult::success对整数key关联数组执行array_merge破坏userId映射
        return json(['code' => 200, 'msg' => '操作成功', 'data' => $result]);
    }
}
