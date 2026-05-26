<?php

namespace app\controller\business;

use support\Request;
use app\service\BizPlanService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 方案管理控制器
 *
 * 负责方案的增删改查、提交审核、审核通过/驳回、状态变更等功能，
 * 已审核的方案不可修改或删除
 */
class BizPlanController
{
    protected $planService;

    public function __construct()
    {
        $this->planService = new BizPlanService();
    }

    // 分页查询企业维度的方案列表
    public function enterpriseList(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = $this->planService->selectEnterpriseList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 分页查询方案列表，支持按企业、门店、状态等条件筛选
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = $this->planService->selectPlanList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取方案详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $planId = intval(end($parts));
        $plan = $this->planService->selectPlanById($planId);
        if (!$plan) return AjaxResult::error('方案不存在');
        return AjaxResult::success($plan);
    }

    // 新增方案，含方案明细项
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->planService->insertPlan($data);
        if (isset($result['error'])) {
            return AjaxResult::error($result['error']);
        }
        return AjaxResult::success($result, '新增成功');
    }

    // 修改方案信息，已审核的方案不可修改
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->planService->updatePlan($data);
        if (!$result) {
            return AjaxResult::error('修改失败，方案已审核不可修改');
        }
        return AjaxResult::success(null, '修改成功');
    }

    // 批量删除方案，已审核的方案不可删除
    public function remove(Request $request)
    {
        $planIds = $request->input('planIds', '');
        if (!is_array($planIds)) {
            $planIds = explode(',', $planIds);
        }
        $planIds = array_map('intval', array_filter($planIds));
        $result = $this->planService->deletePlanByIds($planIds);
        if (!$result) {
            return AjaxResult::error('删除失败，已审核的方案不可删除');
        }
        return AjaxResult::success(null, '删除成功');
    }

    // 提交方案审核
    public function submitAudit(Request $request)
    {
        $parts = explode('/', $request->path());
        $planId = intval(end($parts));
        $submitBy = $request->loginUser->user->user_name ?? '';
        $result = $this->planService->submitAudit($planId, $submitBy);
        if (!$result) {
            return AjaxResult::error('提交审核失败');
        }
        return AjaxResult::success(null, '提交审核成功');
    }

    // 审核方案（通过或驳回）
    public function audit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['audit_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->planService->audit($data);
        if (!$result) {
            return AjaxResult::error('审核失败');
        }
        return AjaxResult::success(null, '审核成功');
    }

    // 变更方案状态
    public function changeStatus(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $planId = intval($data['plan_id'] ?? 0);
        $status = $data['status'] ?? '';
        $statusChangeBy = $request->loginUser->user->user_name ?? '';
        $result = $this->planService->changeStatus($planId, $status, $statusChangeBy);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
