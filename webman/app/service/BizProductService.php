<?php

namespace app\service;

use app\model\BizProduct;
use app\model\BizInventory;
use support\Db;
use app\model\SysUser;
use app\service\DataScopeService;

/**
 * 货品服务层，处理货品的增删改查和搜索，新增货品时自动创建库存记录
 */
class BizProductService
{
    // 按条件分页查询产品列表
    public function selectProductList($params = [])
    {
        $query = BizProduct::with('supplier');
        if (!empty($params['product_name'])) {
            $query->where('product_name', 'like', '%' . $params['product_name'] . '%');
        }
        if (!empty($params['product_code'])) {
            $query->where('product_code', 'like', '%' . $params['product_code'] . '%');
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('category', $params['category']);
        }
        if (!empty($params['supplier_id'])) {
            $query->where('supplier_id', $params['supplier_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        // 数据权限过滤：非管理员只能查看其可见用户创建的产品
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                ->pluck('user_name')->toArray();
            $query->whereIn('create_by', $visibleUserNames);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('product_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
        
        foreach ($result as $product) {
            $product->supplier_name = $product->supplier ? $product->supplier->supplier_name : null;
            $inventory = BizInventory::where('product_id', $product->product_id)->first();
            $product->inventory_qty = $inventory ? $inventory->quantity : 0;
        }
        
        return $result;
    }

    // 根据ID查询产品详情

    public function selectProductById($productId, $loginUser = null)
    {
        $product = BizProduct::find($productId);
        if (!$product) {
            return null;
        }
        // 数据权限校验：非管理员只能查看其可见用户创建的产品
        if (!empty($loginUser) && !$loginUser->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
            $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                ->pluck('user_name')->toArray();
            if (!in_array($product->create_by, $visibleUserNames)) {
                return null;
            }
        }
        return $product;
    }

    // 搜索产品，返回简化列表供下拉选择

    public function searchProduct($keyword = '')
    {
        $query = BizProduct::query()->where('status', '0');
        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('product_name', 'like', '%' . $keyword . '%')
                  ->orWhere('product_code', 'like', '%' . $keyword . '%');
            });
        }
        $products = $query->with('supplier')->orderBy('product_id', 'desc')->limit(50)->get();
        foreach ($products as $product) {
            $inventory = BizInventory::where('product_id', $product->product_id)->first();
            $product->inventory_qty = $inventory ? $inventory->quantity : 0;
            $product->supplier_name = $product->supplier ? $product->supplier->supplier_name : null;
        }
        return $products;
    }

    // 新增产品

    public function insertProduct($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $product = Db::transaction(function () use ($data) {
            $product = BizProduct::create($data);
            BizInventory::create([
                'product_id' => $product->product_id,
                'quantity' => 0,
                'warn_qty' => $data['warn_qty'] ?? 0,
                'create_time' => date('Y-m-d H:i:s'),
            ]);
            return $product;
        });
        return $product;
    }

    // 更新产品信息

    public function updateProduct($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        // 按 fillable 过滤，移除 login_user 等非数据库字段，避免触发 SQL 错误
        $fillable = (new BizProduct())->getFillable();
        $filteredData = array_intersect_key($data, array_flip($fillable));
        Db::transaction(function () use ($data, $filteredData) {
            BizProduct::where('product_id', $data['product_id'])->update($filteredData);
            if (isset($filteredData['warn_qty'])) {
                BizInventory::where('product_id', $data['product_id'])->update([
                    'warn_qty' => $filteredData['warn_qty'],
                    'update_time' => date('Y-m-d H:i:s'),
                ]);
            }
        });
        return true;
    }

    // 批量删除产品

    public function deleteProductByIds($productIds, $params = [])
    {
        return Db::transaction(function () use ($productIds) {
            BizInventory::whereIn('product_id', $productIds)->delete();
            return BizProduct::whereIn('product_id', $productIds)->delete();
        });
    }
}
