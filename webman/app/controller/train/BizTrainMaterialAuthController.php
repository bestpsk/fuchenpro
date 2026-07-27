<?php

namespace app\controller\train;

use support\Request;
use app\service\BizTrainMaterialAuthService;
use app\service\PermissionService;
use app\common\AjaxResult;

/**
 * 培训材料授权管理控制器
 */
class BizTrainMaterialAuthController
{
    // 获取材料的授权配置
    public function getAuth(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:auth')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $materialId = intval(end($parts));
        if (!$materialId) {
            return AjaxResult::error('材料ID不能为空');
        }
        $service = new BizTrainMaterialAuthService();
        $config = $service->getAuthConfig($materialId);
        return AjaxResult::success($config);
    }

    // 保存材料的授权配置
    public function saveAuth(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:auth')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = $request->post();
        $materialId = intval($data['materialId'] ?? 0);
        if (!$materialId) {
            return AjaxResult::error('材料ID不能为空');
        }
        $userIds = $data['userIds'] ?? [];
        $deptIds = $data['deptIds'] ?? [];
        $createBy = $request->loginUser->user->user_name ?? '';

        $service = new BizTrainMaterialAuthService();
        $result = $service->saveAuthConfig($materialId, $userIds, $deptIds, $createBy);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
