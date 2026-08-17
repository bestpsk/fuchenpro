<?php

namespace app\controller\goal;

use support\Request;
use app\service\BizGoalService;
use app\service\BizGoalProgressService;
use app\service\PermissionService;
use app\service\SysConfigService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizGoal;

/**
 * 目标管理控制器（独立顶级模块，权限标识 goal:*）
 * 数据可见范围以 sys_role.data_scope 为依据
 */
class GoalController
{
    // 分页查询目标列表
    public function list(Request $request)
    {
        $service = new BizGoalService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectGoalList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 目标详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $goalId = intval(end($parts));
        $service = new BizGoalService();
        $goal = $service->selectGoalById($goalId);
        if (!$goal) return AjaxResult::error('目标不存在');
        return AjaxResult::success($goal);
    }

    // 新增目标
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'goal:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $loginUser = $request->loginUser;

            // 归属范围校验
            $service = new BizGoalService();
            if (!$service->checkOwnerScope($data['owner_type'] ?? '4', $data['owner_id'] ?? 0, $loginUser)) {
                return AjaxResult::error('归属对象不在您的数据权限范围内');
            }

            $data['creator_user_id'] = $loginUser->user->user_id ?? 0;
            $data['create_by'] = $loginUser->user->user_name ?? '';
            $data['create_time'] = date('Y-m-d H:i:s');

            $goal = $service->insertGoal($data);
            return AjaxResult::success($goal);
        } catch (\Throwable $e) {
            return AjaxResult::error('新增失败：' . $e->getMessage());
        }
    }

    // 修改目标（非目标值，目标值调整走 adjust）
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'goal:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $service = new BizGoalService();
            $result = $service->updateGoal($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error('修改失败：' . $e->getMessage());
        }
    }

    // 删除目标
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'goal:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $goalIds = $request->input('goalIds');
        if (empty($goalIds)) {
            $parts = explode('/', $request->path());
            $goalIds = end($parts);
        }
        $goalIds = explode(',', $goalIds);
        $goalIds = array_map('intval', array_filter($goalIds));
        $service = new BizGoalService();
        $result = $service->deleteGoalByIds($goalIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取目标进度（单个或批量看板）
    public function getProgress(Request $request)
    {
        $goalId = $request->get('goalId');
        $progressService = new BizGoalProgressService();

        if ($goalId) {
            // 单个目标进度
            $service = new BizGoalService();
            $goal = $service->selectGoalById(intval($goalId));
            if (!$goal) return AjaxResult::error('目标不存在');
            return AjaxResult::success($progressService->calculateProgress($goal));
        }

        // 批量：当前用户可见目标的进度看板
        $service = new BizGoalService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['page_size'] = 1000; // 看板不分页
        $result = $service->selectGoalList($params);
        $progressList = $progressService->batchProgress($result->items());
        return AjaxResult::success($progressList);
    }

    // 排名（按完成率排序）
    public function getRanking(Request $request)
    {
        $service = new BizGoalService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['page_size'] = 1000;
        $result = $service->selectGoalList($params);

        $progressService = new BizGoalProgressService();
        $progressList = $progressService->batchProgress($result->items());

        // 按完成率降序
        usort($progressList, function ($a, $b) {
            return ($b['completion_rate'] ?? 0) <=> ($a['completion_rate'] ?? 0);
        });

        return AjaxResult::success($progressList);
    }

    // 个人日视图（AppV3 用）
    public function getDailyView(Request $request)
    {
        $userId = $request->loginUser->userId;
        $progressService = new BizGoalProgressService();
        try {
            $view = $progressService->getPersonalDailyView($userId);
            return AjaxResult::success($view);
        } catch (\Throwable $e) {
            return AjaxResult::success(['has_goal' => false]);
        }
    }

    // 目标调整（留痕）
    public function adjust(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'goal:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $goalId = intval($request->post('goalId'));
            $newValue = floatval($request->post('newValue'));
            $reason = trim($request->post('reason', ''));
            $adjustBy = $request->loginUser->user->user_name ?? '';

            $service = new BizGoalService();
            $goal = $service->adjustGoal($goalId, $newValue, $reason, $adjustBy);
            return AjaxResult::success($goal);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 目标拆解
    public function split(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'goal:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $parentGoalId = intval($request->post('parentGoalId'));
            $children = $request->post('children', []);
            $service = new BizGoalService();
            $service->splitGoal($parentGoalId, $children);
            return AjaxResult::success('拆解成功');
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 查询父目标已拆解的子目标列表（拆解弹窗回显用）
    public function splitChildren(Request $request)
    {
        $parentGoalId = intval($request->get('parentGoalId'));
        if ($parentGoalId <= 0) {
            return AjaxResult::error('参数 parentGoalId 不能为空');
        }
        $service = new BizGoalService();
        $list = $service->getChildrenGoals($parentGoalId);
        return AjaxResult::success(['children' => $list]);
    }

    // 手动触发日目标生成
    public function generateDaily(Request $request)
    {
        $goalId = intval($request->post('goalId'));
        if ($goalId <= 0) {
            $parts = explode('/', $request->path());
            $goalId = intval(end($parts));
        }
        $service = new BizGoalService();
        $result = $service->generateDailyGoals($goalId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取当前用户的个人目标列表（含进度，PC端"我的目标"用）
    public function myGoals(Request $request)
    {
        $periodType = $request->get('periodType');
        $progressService = new BizGoalProgressService();
        try {
            $list = $progressService->getMyGoalsProgress($request->loginUser, $periodType);
            return AjaxResult::success($list);
        } catch (\Throwable $e) {
            // 降级：直接用当前用户ID查询个人目标
            try {
                $list = $progressService->getMyGoalsProgressFallback($request->loginUser, $periodType);
                return AjaxResult::success($list);
            } catch (\Throwable $e2) {
                return AjaxResult::error('获取个人目标失败：' . $e2->getMessage());
            }
        }
    }

    // 获取当前用户可见部门的团队目标进度（部门负责人"团队目标"Tab 用）
    public function teamGoals(Request $request)
    {
        $periodType = $request->get('periodType');
        $topLevelOnly = $request->get('topLevelOnly', 'false') === 'true';
        $progressService = new BizGoalProgressService();
        try {
            $list = $progressService->getTeamGoalsProgress($request->loginUser, $periodType, $topLevelOnly);
            return AjaxResult::success($list);
        } catch (\Throwable $e) {
            return AjaxResult::error('获取团队目标失败：' . $e->getMessage());
        }
    }

    // 目标调整记录列表（分页）
    public function adjustLog(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $service = new BizGoalService();
        $result = $service->selectAdjustLogs($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 日目标明细
    public function dailyDetail(Request $request)
    {
        $goalId = intval($request->get('goalId'));
        if ($goalId <= 0) {
            return AjaxResult::error('参数 goalId 不能为空');
        }
        $service = new BizGoalService();
        $data = $service->selectDailyDetail($goalId);
        if (!$data) {
            return AjaxResult::error('目标不存在');
        }
        return AjaxResult::success($data);
    }

    // 导出目标列表
    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['page_size'] = 10000;
        $service = new BizGoalService();
        $result = $service->selectGoalList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizGoal::class);
        return $excelUtil->exportExcel($list, '目标数据');
    }
}
