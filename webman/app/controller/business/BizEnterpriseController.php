<?php

namespace app\controller\business;

use support\Request;
use app\service\BizEnterpriseService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 企业管理控制器
 *
 * 负责企业的增删改查、企业搜索、企业状态变更（启用/停用）等功能
 */
class BizEnterpriseController
{
    // 分页查询企业列表，支持按企业名称、状态等条件筛选
    public function list(Request $request)
    {
        $service = new BizEnterpriseService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectEnterpriseList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取企业详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $enterpriseId = intval(end($parts));
        $service = new BizEnterpriseService();
        $enterprise = $service->selectEnterpriseById($enterpriseId);
        if (!$enterprise) return AjaxResult::error('企业不存在');
        return AjaxResult::success($enterprise);
    }

    // 模糊搜索企业，用于下拉选择框
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $service = new BizEnterpriseService();
        $result = $service->selectEnterpriseForSearch($keyword);
        return AjaxResult::success($result);
    }

    // 新增企业，自动填充创建人信息
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEnterpriseService();
        $result = $service->insertEnterprise($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改企业信息，自动填充更新人信息
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEnterpriseService();
        $result = $service->updateEnterprise($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除企业
    public function remove(Request $request)
    {
        $enterpriseIds = explode(',', $request->input('enterpriseIds', ''));
        $enterpriseIds = array_map('intval', array_filter($enterpriseIds));
        $service = new BizEnterpriseService();
        $result = $service->deleteEnterpriseByIds($enterpriseIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 变更企业状态（启用/停用）
    public function changeStatus(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $enterpriseId = intval($data['enterprise_id'] ?? 0);
        $status = $data['status'] ?? '';
        $service = new BizEnterpriseService();
        $result = $service->updateEnterpriseStatus($enterpriseId, $status);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
