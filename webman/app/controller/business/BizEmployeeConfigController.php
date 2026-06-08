<?php

namespace app\controller\business;

use support\Request;
use app\service\BizEmployeeConfigService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 员工配置控制器
 *
 * 负责员工工作配置的增删改查，包括是否可排班、休息日期管理、
 * 员工搜索等功能，用于行程排班和考勤管理
 */
class BizEmployeeConfigController
{
    // 分页查询员工配置列表
    public function list(Request $request)
    {
        $service = new BizEmployeeConfigService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectConfigList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取员工配置详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $configId = intval(end($parts));
        $service = new BizEmployeeConfigService();
        $config = $service->selectConfigById($configId);
        if (!$config) return AjaxResult::error('配置不存在');
        return AjaxResult::success($config);
    }

    // 新增员工配置
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEmployeeConfigService();
        $result = $service->insertConfig($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改员工配置
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEmployeeConfigService();
        $result = $service->updateConfig($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 更新员工是否可排班状态
    public function updateSchedulable(Request $request)
    {
        $userId = $request->input('userId');
        $isSchedulable = $request->input('isSchedulable', '1');
        $service = new BizEmployeeConfigService();
        $result = $service->updateSchedulable($userId, $isSchedulable);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 保存员工休息日期列表
    public function saveRestDates(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $userId = $data['user_id'];
        $restDates = $data['rest_dates'] ?? [];
        $service = new BizEmployeeConfigService();
        $result = $service->updateRestDates($userId, $restDates);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取员工休息日期列表
    public function getRestDates(Request $request)
    {
        $userId = $request->input('userId');
        $service = new BizEmployeeConfigService();
        $restDates = $service->getRestDatesByUserId($userId);
        return AjaxResult::success($restDates);
    }

    // 批量删除员工配置
    public function remove(Request $request)
    {
        $configIds = $request->input('configIds', '');
        if (!is_array($configIds)) {
            $configIds = explode(',', $configIds);
        }
        $configIds = array_map('intval', array_filter($configIds));
        $service = new BizEmployeeConfigService();
        $result = $service->deleteConfigByIds($configIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 模糊搜索员工，用于下拉选择框
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $params = ['login_user' => $request->loginUser];
        $service = new BizEmployeeConfigService();
        $list = $service->searchEmployee($keyword, $params);
        return AjaxResult::success($list);
    }
}
