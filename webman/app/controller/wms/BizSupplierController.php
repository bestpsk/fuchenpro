<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizSupplierService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizSupplier;

/**
 * 供应商管理控制器
 *
 * 负责供应商的增删改查和模糊搜索功能
 */
class BizSupplierController
{
    // 分页查询供应商列表
    public function list(Request $request)
    {
        $service = new BizSupplierService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectSupplierList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取供应商详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $supplierId = intval(end($parts));
        $service = new BizSupplierService();
        $loginUser = $request->loginUser;
        $supplier = $service->selectSupplierById($supplierId, $loginUser);
        if (!$supplier) return AjaxResult::error('供货商不存在');
        return AjaxResult::success($supplier);
    }

    // 模糊搜索供应商，用于下拉选择框
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $service = new BizSupplierService();
        $list = $service->searchSupplier($keyword);
        return AjaxResult::success($list);
    }

    // 新增供应商
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:supplier:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $data['login_user'] = $request->loginUser;
        $service = new BizSupplierService();
        $result = $service->insertSupplier($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改供应商信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:supplier:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $data['login_user'] = $request->loginUser;
            $service = new BizSupplierService();
            $result = $service->updateSupplier($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Exception $e) {
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 批量删除供应商
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:supplier:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $supplierIds = $request->input('supplierIds', '');
        if (!is_array($supplierIds)) {
            $supplierIds = explode(',', $supplierIds);
        }
        $supplierIds = array_map('intval', array_filter($supplierIds));
        $params['login_user'] = $request->loginUser;
        $service = new BizSupplierService();
        $result = $service->deleteSupplierByIds($supplierIds, $params);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 导出供货商数据
    public function export(Request $request)
    {
        $service = new BizSupplierService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $result = $service->selectSupplierList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizSupplier::class);
        return $excelUtil->exportExcel($list, '供货商数据');
    }
}
