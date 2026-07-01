<?php

namespace app\controller\system;

use support\Request;
use app\service\SysConfigService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 系统参数配置控制器
 *
 * 负责系统参数的增删改查、按键名查询参数值和参数缓存刷新等功能
 */
class SysConfigController
{
    // 分页查询系统参数配置列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysConfigService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectConfigList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取参数配置详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $configId = intval(end($parts));
        $service = new SysConfigService();
        $config = $service->selectConfigById($configId);
        if (!$config) return AjaxResult::error('参数不存在');
        return AjaxResult::success($config);
    }

    // 根据参数键名查询参数值
    public function getConfigKey(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $configKey = end($parts);
        $service = new SysConfigService();
        return AjaxResult::success('', $service->selectConfigByKey($configKey));
    }

    // 新增参数配置
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysConfigService();
        return AjaxResult::toAjax($service->insertConfig($data) ? 1 : 0);
    }

    // 修改参数配置
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysConfigService();
        return AjaxResult::toAjax($service->updateConfig($data) ? 1 : 0);
    }

    // 批量删除参数配置
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $configIds = explode(',', $request->input('configIds', ''));
        $configIds = array_map('intval', array_filter($configIds));
        $service = new SysConfigService();
        return AjaxResult::toAjax($service->deleteConfigByIds($configIds) ? 1 : 0);
    }

    // 刷新参数缓存（清空Redis中的配置缓存并重新加载）
    public function refreshCache(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:config:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysConfigService();
        $service->resetConfigCache();
        return AjaxResult::success();
    }
}
