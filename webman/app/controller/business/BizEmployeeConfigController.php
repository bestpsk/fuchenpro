<?php

namespace app\controller\business;

use support\Request;
use app\service\BizEmployeeConfigService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 员工配置控制器
 *
 * 负责员工排班配置的增删改查、是否可排班状态管理、员工搜索等功能
 * 休息日管理已迁移至 BizRestPlanController（biz_rest_plan_* 表）
 */
class BizEmployeeConfigController
{
    // 分页查询员工配置列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizEmployeeConfigService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectConfigList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取员工配置详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
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
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEmployeeConfigService();
        $result = $service->insertConfig($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改员工配置
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizEmployeeConfigService();
        $result = $service->updateConfig($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 更新员工是否可排班状态
    public function updateSchedulable(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->post('userId');
        $isSchedulable = $request->post('isSchedulable', '1');
        // 兼容 boolean/int/string 入参，统一转换为字符串 '0'/'1'
        if (is_bool($isSchedulable)) {
            $isSchedulable = $isSchedulable ? '1' : '0';
        } else {
            $isSchedulable = (string)$isSchedulable;
            if ($isSchedulable !== '0' && $isSchedulable !== '1') {
                $isSchedulable = '1';
            }
        }
        $service = new BizEmployeeConfigService();
        $result = $service->updateSchedulable($userId, $isSchedulable);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除员工配置
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
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
        if (PermissionService::lacksPermi($request->loginUser, 'business:employeeConfig:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $keyword = $request->input('keyword', '');
        $params = ['login_user' => $request->loginUser];
        $service = new BizEmployeeConfigService();
        $list = $service->searchEmployee($keyword, $params);
        return AjaxResult::success($list);
    }
}
