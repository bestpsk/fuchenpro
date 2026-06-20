<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizInventoryService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizInventory;

/**
 * 库存管理控制器
 *
 * 负责库存查询和库存预警功能，库存数据由入库/出库确认时自动更新
 */
class BizInventoryController
{
    // 分页查询库存列表，支持按货品名称、分类等条件筛选
    public function list(Request $request)
    {
        $service = new BizInventoryService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectInventoryList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 分页查询库存预警列表（低于安全库存量的货品）
    public function warn(Request $request)
    {
        $service = new BizInventoryService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectWarnList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据货品ID获取库存详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $productId = intval(end($parts));
        $warehouseId = $request->input('warehouse_id');
        $service = new BizInventoryService();
        $inventory = $service->selectInventoryByProductId($productId, $warehouseId);
        if (!$inventory) return AjaxResult::error('库存记录不存在');

        // Flatten product fields to top level for frontend consumption
        $product = $inventory->product;
        $inventory->product_code = $product ? $product->product_code : '';
        $inventory->product_name = $product ? $product->product_name : '';
        $inventory->category = $product ? $product->category : '';
        $inventory->purchase_price = $product ? $product->purchase_price : '';
        $inventory->sale_price = $product ? $product->sale_price : '';
        $inventory->unit = $product ? $product->unit : '';
        $inventory->spec = $product ? $product->spec : '';
        $inventory->pack_qty = $product ? $product->pack_qty : 1;

        $warehouse = \app\model\BizWarehouse::find($inventory->warehouse_id);
        $inventory->warehouse_name = $warehouse ? $warehouse->warehouse_name : '';

        // Hide the nested product relation to avoid data duplication
        $inventory->setHidden(['product']);

        return AjaxResult::success($inventory);
    }

    // 导出库存数据
    public function export(Request $request)
    {
        $service = new BizInventoryService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $result = $service->selectInventoryList($params);
        $list = $result->items();
        // 关联查询product和warehouse
        foreach ($list as $item) {
            $product = \app\model\BizProduct::find($item->product_id);
            $item->product_code = $product ? $product->product_code : '';
            $item->product_name = $product ? $product->product_name : '';
            $item->category = $product ? $product->category : '';
            $item->purchase_price = $product ? $product->purchase_price : '';
            $item->sale_price = $product ? $product->sale_price : '';

            $warehouse = \app\model\BizWarehouse::find($item->warehouse_id);
            $item->warehouse_name = $warehouse ? $warehouse->warehouse_name : '';
        }
        $excelUtil = new ExcelUtil(BizInventory::class);
        return $excelUtil->exportExcel($list, '库存数据');
    }
}
