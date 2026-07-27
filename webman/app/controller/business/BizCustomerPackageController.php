<?php

namespace app\controller\business;

use support\Request;
use app\service\BizCustomerPackageService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 客户套餐控制器
 *
 * 负责客户已购套餐的查询，包括套餐列表、套餐详情、
 * 按客户ID查询其名下所有套餐（含使用状态筛选）
 */
class BizCustomerPackageController
{
    // 分页查询客户套餐列表，支持按客户、状态等条件筛选
    public function list(Request $request)
    {
        $service = new BizCustomerPackageService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectPackageList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据套餐ID获取套餐详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:package:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $packageId = intval(end($parts));
        $service = new BizCustomerPackageService();
        $package = $service->selectPackageById($packageId);
        if (!$package) return AjaxResult::error('套餐不存在');
        return AjaxResult::success($package);
    }

    // 根据客户ID查询其名下所有套餐，可按状态筛选（0=未使用 1=使用中 2=已用完）
    public function getByCustomer(Request $request)
    {
        $customerId = $request->input('customerId');
        $allParams = $request->all();
        $status = (isset($allParams['status']) && $allParams['status'] !== '') ? $allParams['status'] : null;
        $params = ['login_user' => $request->loginUser];
        $service = new BizCustomerPackageService();
        $result = $service->selectPackagesByCustomer($customerId, $status, $params);
        return AjaxResult::success($result);
    }
}
