<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizProductService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizProduct;

/**
 * 货品管理控制器
 *
 * 负责仓储货品的增删改查和模糊搜索功能
 */
class BizProductController
{
    // 分页查询货品列表
    public function list(Request $request)
    {
        $service = new BizProductService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectProductList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取货品详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $productId = intval(end($parts));
        $service = new BizProductService();
        $loginUser = $request->loginUser;
        $product = $service->selectProductById($productId, $loginUser);
        if (!$product) return AjaxResult::error('货品不存在');
        return AjaxResult::success($product);
    }

    // 模糊搜索货品，用于下拉选择框
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $service = new BizProductService();
        $list = $service->searchProduct($keyword);
        return AjaxResult::success($list);
    }

    // 新增货品
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:product:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $data['login_user'] = $request->loginUser;
        $service = new BizProductService();
        $result = $service->insertProduct($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改货品信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:product:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $data['login_user'] = $request->loginUser;
            $service = new BizProductService();
            $result = $service->updateProduct($data);
            return AjaxResult::toAjax($result ? 1 : 0);
        } catch (\Throwable $e) {
            \support\Log::error('货品操作失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 批量删除货品
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:product:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $productIds = $request->input('productIds', '');
        if (!is_array($productIds)) {
            $productIds = explode(',', $productIds);
        }
        $productIds = array_map('intval', array_filter($productIds));
        $params['login_user'] = $request->loginUser;
        $service = new BizProductService();
        $result = $service->deleteProductByIds($productIds, $params);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 导出货品数据
    public function export(Request $request)
    {
        $service = new BizProductService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $result = $service->selectProductList($params);
        $list = $result->items();
        // 关联查询supplier_name
        foreach ($list as $item) {
            if (!empty($item->supplier_id)) {
                $supplier = \app\model\BizSupplier::find($item->supplier_id);
                $item->supplier_name = $supplier ? $supplier->supplier_name : '';
            } else {
                $item->supplier_name = '';
            }
        }
        $excelUtil = new ExcelUtil(BizProduct::class);
        return $excelUtil->exportExcel($list, '货品数据');
    }
}
