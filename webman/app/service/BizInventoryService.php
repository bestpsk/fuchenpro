<?php

namespace app\service;

use app\model\BizInventory;
use app\model\BizProduct;
use app\model\BizWarehouse;
use app\service\DataScopeService;

/**
 * 库存服务层，处理库存查询和库存预警，库存数据由入库/出库确认时自动更新
 */
class BizInventoryService
{
    // 按条件分页查询库存列表，关联产品信息
    public function selectInventoryList($params = [])
    {
        $query = BizInventory::query()->with('product');
        if (!empty($params['product_name'])) {
            $query->whereHas('product', function ($q) use ($params) {
                $q->where('product_name', 'like', '%' . $params['product_name'] . '%');
            });
        }
        if (!empty($params['product_code'])) {
            $query->whereHas('product', function ($q) use ($params) {
                $q->where('product_code', 'like', '%' . $params['product_code'] . '%');
            });
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->whereHas('product', function ($q) use ($params) {
                $q->where('category', $params['category']);
            });
        }
        if (isset($params['is_warn']) && $params['is_warn'] === '1') {
            $query->whereColumn('quantity', '<=', 'warn_qty');
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->whereHas('product', function ($q) use ($visibleUserIds) {
        //         $q->whereHas('stockInItems', function ($sq) use ($visibleUserIds) {
        //             $sq->whereHas('stockIn', function ($sq2) use ($visibleUserIds) {
        //                 $sq2->whereIn('operator_id', $visibleUserIds);
        //             });
        //         });
        //     });
        // }
        // 仓库权限过滤：非管理员只能查看授权仓库的数据
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('warehouse_id', $authorizedWhIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('inventory_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        // Flatten product and warehouse fields to top level
        foreach ($result->items() as $item) {
            $product = $item->product;
            $item->product_code = $product ? $product->product_code : '';
            $item->product_name = $product ? $product->product_name : '';
            $item->category = $product ? $product->category : '';
            $item->purchase_price = $product ? $product->purchase_price : '';
            $item->sale_price = $product ? $product->sale_price : '';
            $item->unit = $product ? $product->unit : '';
            $item->spec = $product ? $product->spec : '';
            $item->pack_qty = $product ? $product->pack_qty : 1;

            $warehouse = BizWarehouse::find($item->warehouse_id);
            $item->warehouse_name = $warehouse ? $warehouse->warehouse_name : '';

            // Hide the nested product relation to avoid data duplication
            $item->setHidden(['product']);
        }

        return $result;
    }

    public function selectWarnList($params = [])
    {
        $params['is_warn'] = '1';
        return $this->selectInventoryList($params);
    }

    public function selectInventoryByProductId($productId, $warehouseId = null)
    {
        $query = BizInventory::where('product_id', $productId)->with('product');
        if ($warehouseId !== null) {
            $query->where('warehouse_id', $warehouseId);
        }
        return $query->first();
    }
}
