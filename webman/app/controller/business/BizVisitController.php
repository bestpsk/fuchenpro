<?php

namespace app\controller\business;

use support\Request;
use app\service\BizVisitService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\model\BizVisitTask;

/**
 * 满意度回访控制器（业务管理子模块，权限标识 business:visit:*）
 * 支持员工填写和H5链接填写两种模式
 * 数据可见范围以 sys_role.data_scope 为依据
 */
class BizVisitController
{
    // ==================== 模板管理 ====================

    // 模板列表（分页）
    public function templateList(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $service = new BizVisitService();
        $result = $service->selectTemplateList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 模板详情（含题目）
    public function getTemplateInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $templateId = intval(end($parts));
        $service = new BizVisitService();
        $data = $service->selectTemplateById($templateId);
        if (!$data) return AjaxResult::error('模板不存在');
        return AjaxResult::success($data);
    }

    // 新增模板
    public function addTemplate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:template:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['create_by'] = $request->loginUser->user->user_name ?? '';
            $items = $request->post('items', []);
            $service = new BizVisitService();
            $template = $service->insertTemplate($data, $items);
            return AjaxResult::success($template);
        } catch (\Throwable $e) {
            return AjaxResult::error('新增失败：' . $e->getMessage());
        }
    }

    // 修改模板
    public function editTemplate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:template:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $items = $request->post('items', []);
            $service = new BizVisitService();
            $template = $service->updateTemplate($data, $items);
            return AjaxResult::success($template);
        } catch (\Throwable $e) {
            return AjaxResult::error('修改失败：' . $e->getMessage());
        }
    }

    // 删除模板
    public function removeTemplate(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:template:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $templateIds = $request->input('templateIds');
        if (empty($templateIds)) {
            $parts = explode('/', $request->path());
            $templateIds = end($parts);
        }
        $templateIds = is_array($templateIds) ? $templateIds : explode(',', $templateIds);
        $service = new BizVisitService();
        try {
            $result = $service->deleteTemplateByIds($templateIds);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // ==================== 回访任务管理 ====================

    // 回访任务列表（分页）
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $service = new BizVisitService();
        $result = $service->selectVisitList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 回访任务详情（含题目+答案）
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $visitId = intval(end($parts));
        $service = new BizVisitService();
        $data = $service->selectVisitById($visitId);
        if (!$data) return AjaxResult::error('回访任务不存在');
        return AjaxResult::success($data);
    }

    // 新增回访任务
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['visitor_user_id'] = $request->loginUser->userId ?? 0;
            $data['visitor_user_name'] = $request->loginUser->user->user_name ?? '';
            $data['create_by'] = $request->loginUser->user->user_name ?? '';

            // 员工填写模式可附带答案
            $answers = $request->post('answers', []);

            $service = new BizVisitService();
            $task = $service->insertVisit($data, $answers);
            return AjaxResult::success($task);
        } catch (\Throwable $e) {
            return AjaxResult::error('新增失败：' . $e->getMessage());
        }
    }

    // 修改回访任务
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            // answers 从原始数据获取（前端已用 snake_case key）
            $answers = $request->post('answers');
            $service = new BizVisitService();
            $task = $service->updateVisit($data, $answers);
            return AjaxResult::success($task);
        } catch (\Throwable $e) {
            return AjaxResult::error('修改失败：' . $e->getMessage());
        }
    }

    // 删除回访任务（软删除）
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $visitIds = $request->input('visitIds');
        if (empty($visitIds)) {
            $parts = explode('/', $request->path());
            $visitIds = end($parts);
        }
        $visitIds = is_array($visitIds) ? $visitIds : explode(',', $visitIds);
        $service = new BizVisitService();
        $result = $service->deleteVisitByIds($visitIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 生成H5链接（为已有任务生成/刷新token）
    public function generateLink(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:visit:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $visitId = intval($request->post('visitId'));
            $service = new BizVisitService();
            $task = $service->generateLink($visitId);
            return AjaxResult::success($task);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 满意度统计（按企业汇总）
    public function stats(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $service = new BizVisitService();
        $stats = $service->selectVisitStats($params);
        return AjaxResult::success($stats);
    }

    // 导出回访记录
    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['page_size'] = 10000;
        $service = new BizVisitService();
        $result = $service->selectVisitList($params);
        $list = $result->items();

        // 简单CSV导出
        $headers = ['回访ID', '企业名称', '门店名称', '回访类型', '回访方式', '状态', '满意度', '回访员工', '回访时间'];
        $fileName = '满意度回访_' . date('YmdHis') . '.csv';

        return response()->withHeaders([
            'Content-Type' => 'text/csv; charset=utf-8',
            'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
        ])->withBody((function () use ($list, $headers) {
            $output = chr(0xEF) . chr(0xBB) . chr(0xBF); // UTF-8 BOM
            $output .= implode(',', $headers) . "\n";
            $visitTypeMap = ['after_service' => '服务后回访', 'monthly' => '月度回访', 'quarterly' => '季度回访', 'custom' => '自定义'];
            $modeMap = ['1' => '员工填写', '2' => 'H5链接'];
            $statusMap = ['0' => '待回访', '1' => '已完成', '2' => '已取消'];
            foreach ($list as $row) {
                $line = [
                    $row->visit_id,
                    $row->enterprise_name ?? '',
                    $row->store_name ?? '',
                    $visitTypeMap[$row->visit_type] ?? $row->visit_type,
                    $modeMap[$row->visit_mode] ?? $row->visit_mode,
                    $statusMap[$row->visit_status] ?? $row->visit_status,
                    $row->satisfaction_score ?? '',
                    $row->visitor_user_name ?? '',
                    $row->visit_time ?? '',
                ];
                $output .= implode(',', array_map(function ($v) {
                    $v = str_replace('"', '""', $v);
                    return '"' . $v . '"';
                }, $line)) . "\n";
            }
            return $output;
        })());
    }

    // ==================== H5公共接口（免认证，token凭证） ====================

    // 获取H5表单数据
    public function getPublicForm(Request $request)
    {
        $parts = explode('/', $request->path());
        $token = end($parts);
        $service = new BizVisitService();
        try {
            $data = $service->getPublicForm($token);
            return AjaxResult::success($data);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 提交回访问卷（H5公共提交）
    public function submitPublicForm(Request $request)
    {
        $token = $request->post('token', '');
        $answers = $request->post('answers', []);
        $contactInfo = [
            'contact_name' => $request->post('contactName', ''),
            'contact_phone' => $request->post('contactPhone', ''),
        ];

        if (empty($token)) {
            return AjaxResult::error('缺少回访凭证');
        }

        $service = new BizVisitService();
        try {
            $task = $service->submitVisitForm($token, $answers, $contactInfo);
            return AjaxResult::success('提交成功', ['visit_id' => $task->visit_id]);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }
}
