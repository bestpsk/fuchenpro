<?php

namespace app\controller\business;

use support\Request;
use app\service\BizAttendanceConfigService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 考勤配置控制器
 *
 * 负责考勤配置的增删改查，以及获取当前登录用户的考勤规则
 */
class BizAttendanceConfigController
{
    protected $configService;

    public function __construct()
    {
        $this->configService = new BizAttendanceConfigService();
    }

    // 分页查询考勤配置列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:config:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $params = convert_to_snake_case($request->get());
            $params['login_user'] = $request->loginUser;
            $result = $this->configService->selectConfigList($params);
            return TableDataInfo::result($result->items(), $result->total());
        } catch (\Throwable $e) {
            return AjaxResult::error('查询考勤配置列表失败');
        }
    }

    // 根据ID获取考勤配置详情
    public function info(Request $request, $configId)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:config:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $config = $this->configService->selectConfigById($configId);
        if (!$config) {
            return AjaxResult::error('配置不存在');
        }
        return AjaxResult::success($config);
    }

    // 新增考勤配置
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:config:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['create_by'] = $request->loginUser->user->user_name ?? '';
            $result = $this->configService->insertConfig($data);
            if ($result) {
                return AjaxResult::success($result, '新增成功');
            }
            return AjaxResult::error('新增失败');
        } catch (\Throwable $e) {
            return AjaxResult::error('新增考勤配置失败：' . $e->getMessage());
        }
    }

    // 修改考勤配置
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:config:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $result = $this->configService->updateConfig($data);
            if ($result) {
                return AjaxResult::success(null, '修改成功');
            }
            return AjaxResult::error('修改失败');
        } catch (\Throwable $e) {
            return AjaxResult::error('修改考勤配置失败：' . $e->getMessage());
        }
    }

    // 批量删除考勤配置
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:attendance:config:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $configIds = $request->input('configIds', '');
            if (!is_array($configIds)) {
                $configIds = explode(',', $configIds);
            }
            $configIds = array_map('intval', array_filter($configIds));
            if (empty($configIds)) {
                return AjaxResult::error('请选择要删除的配置');
            }
            $result = $this->configService->deleteConfigByIds($configIds);
            if ($result) {
                return AjaxResult::success(null, '删除成功');
            }
            return AjaxResult::error('删除失败');
        } catch (\Throwable $e) {
            return AjaxResult::error('删除考勤配置失败：' . $e->getMessage());
        }
    }

    // 获取当前登录用户的考勤规则（根据用户关联的配置计算）
    public function getUserRule(Request $request)
    {
        $userId = $request->loginUser->userId;
        $clockType = $request->input('clock_type', '0');
        $rule = $this->configService->getUserRuleByClockType($userId, $clockType);
        return AjaxResult::success($rule);
    }
}
