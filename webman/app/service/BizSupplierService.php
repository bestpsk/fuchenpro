<?php

namespace app\service;

use app\model\BizSupplier;
use app\model\SysUser;
use app\service\DataScopeService;

/**
 * 供应商服务层，处理供应商的增删改查和搜索
 */
class BizSupplierService
{
    // 按条件分页查询供应商列表
    public function selectSupplierList($params = [])
    {
        $query = BizSupplier::query();
        if (!empty($params['supplier_name'])) {
            $query->where('supplier_name', 'like', '%' . $params['supplier_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['contact_person'])) {
            $query->where('contact_person', 'like', '%' . $params['contact_person'] . '%');
        }
        // 数据权限过滤：非管理员只能查看其可见用户创建的供应商
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                ->pluck('user_name')->toArray();
            $query->whereIn('create_by', $visibleUserNames);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('supplier_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询供应商详情

    public function selectSupplierById($supplierId, $loginUser = null)
    {
        $supplier = BizSupplier::find($supplierId);
        if (!$supplier) {
            return null;
        }
        // 数据权限校验：非管理员只能查看其可见用户创建的供应商
        if (!empty($loginUser) && !$loginUser->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
            $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                ->pluck('user_name')->toArray();
            if (!in_array($supplier->create_by, $visibleUserNames)) {
                return null;
            }
        }
        return $supplier;
    }

    // 搜索供应商，返回简化列表供下拉选择

    public function searchSupplier($keyword = '')
    {
        $query = BizSupplier::query()->where('status', '0');
        if (!empty($keyword)) {
            $query->where('supplier_name', 'like', '%' . $keyword . '%');
        }
        return $query->orderBy('supplier_id', 'desc')->limit(50)->get();
    }

    // 新增供应商

    public function insertSupplier($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizSupplier::create($data);
    }

    // 更新供应商信息

    public function updateSupplier($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return BizSupplier::where('supplier_id', $data['supplier_id'])->update($data);
    }

    // 批量删除供应商

    public function deleteSupplierByIds($supplierIds, $params = [])
    {
        return BizSupplier::whereIn('supplier_id', $supplierIds)->delete();
    }
}
