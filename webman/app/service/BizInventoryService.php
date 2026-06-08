<?php

namespace app\service;

use app\model\BizInventory;
use app\model\BizProduct;
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
        // 数据权限过滤：非管理员只能查看其可见用户操作入库的产品库存
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereHas('product', function ($q) use ($visibleUserIds) {
                $q->whereHas('stockInItems', function ($sq) use ($visibleUserIds) {
                    $sq->whereHas('stockIn', function ($sq2) use ($visibleUserIds) {
                        $sq2->whereIn('operator_id', $visibleUserIds);
                    });
                });
            });
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('inventory_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    public function selectWarnList($params = [])
    {
        $params['is_warn'] = '1';
        return $this->selectInventoryList($params);
    }

    public function selectInventoryByProductId($productId, $params = [])
    {
        $inventory = BizInventory::where('product_id', $productId)->with('product')->first();
        return $inventory;
    }
}
