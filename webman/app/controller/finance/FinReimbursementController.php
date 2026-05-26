<?php

namespace app\controller\finance;

use support\Request;
use app\service\FinReimbursementService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\model\SysDept;

/**
 * 报销管理控制器，提供报销单的增删改查、审核和支付接口
 */
class FinReimbursementController
{
    protected $service;

    public function __construct()
    {
        $this->service = new FinReimbursementService();
    }

    // 获取当前登录用户的显示名称（优先真实姓名）
    private function getUserName($loginUser)
    {
        $user = $loginUser->user;
        return $user ? ($user->nick_name ?: $user->user_name) : '';
    }

    // 获取当前用户所属部门名称
    private function getDeptName($loginUser)
    {
        $user = $loginUser->user;
        if (!$user || empty($user->dept_id)) {
            return '';
        }
        $dept = SysDept::find($user->dept_id);
        return $dept ? $dept->dept_name : '';
    }

    // 查询报销单列表
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = $this->service->selectReimbursementList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 查询报销单详情
    public function info(Request $request, $id)
    {
        $result = $this->service->selectReimbursementById($id);
        if (!$result) return AjaxResult::error('数据不存在');
        return AjaxResult::success($result);
    }

    // 新增报销单
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;
        $userName = $this->getUserName($loginUser);
        $user = $loginUser->user;

        $data['applicant_id'] = $loginUser->userId;
        $data['applicant_name'] = $userName;
        $data['dept_id'] = $user ? $user->dept_id : null;
        $data['dept_name'] = $this->getDeptName($loginUser);
        $data['create_by'] = $userName;

        $result = $this->service->insertReimbursement($data);
        return AjaxResult::success('新增成功', $result);
    }

    // 编辑报销单
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;

        $data['update_by'] = $this->getUserName($loginUser);

        $result = $this->service->updateReimbursement($data);
        if ($result === false) {
            return AjaxResult::error('修改失败，只有待审核状态才能修改');
        }
        return AjaxResult::success('修改成功');
    }

    // 删除报销单
    public function remove(Request $request)
    {
        $ids = $request->input('ids', []);
        if (!is_array($ids)) {
            $ids = explode(',', $ids);
        }
        $ids = array_map('intval', $ids);

        $result = $this->service->deleteReimbursementByIds($ids);
        if ($result === false) {
            return AjaxResult::error('删除失败，只有待审核状态才能删除');
        }
        return AjaxResult::success('删除成功');
    }

    // 审核报销单
    public function audit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;

        $data['audit_by'] = $this->getUserName($loginUser);

        $result = $this->service->audit($data);
        if ($result === false) {
            return AjaxResult::error('审核失败，只有待审核状态才能审核');
        }
        return AjaxResult::success('审核成功');
    }

    // 确认支付
    public function pay(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;

        $data['pay_by'] = $this->getUserName($loginUser);

        $result = $this->service->pay($data);
        if ($result === false) {
            return AjaxResult::error('支付失败，只有已审核状态才能支付');
        }
        return AjaxResult::success('支付成功');
    }

    // 按月统计
    public function reportByMonth(Request $request)
    {
        $params = convert_to_snake_case($request->get());
        $result = $this->service->reportByMonth($params);
        return AjaxResult::success('', $result);
    }

    // 按分类统计
    public function reportByCategory(Request $request)
    {
        $params = convert_to_snake_case($request->get());
        $result = $this->service->reportByCategory($params);
        return AjaxResult::success('', $result);
    }

    // 按部门统计
    public function reportByDept(Request $request)
    {
        $params = convert_to_snake_case($request->get());
        $result = $this->service->reportByDept($params);
        return AjaxResult::success('', $result);
    }

    // 按人员统计
    public function reportByUser(Request $request)
    {
        $params = convert_to_snake_case($request->get());
        $result = $this->service->reportByUser($params);
        return AjaxResult::success('', $result);
    }

    // 按支出类型统计
    public function reportByExpenseType(Request $request)
    {
        $params = convert_to_snake_case($request->get());
        $result = $this->service->reportByExpenseType($params);
        return AjaxResult::success('', $result);
    }
}
