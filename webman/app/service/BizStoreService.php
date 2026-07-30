<?php

namespace app\service;

use app\model\BizStore;
use app\model\BizEnterprise;
use app\service\DataScopeService;

/**
 * 门店服务层，处理门店的增删改查和搜索，自动关联企业名称
 */
class BizStoreService
{
    // 按条件分页查询门店列表
    public function selectStoreList($params = [])
    {
        $query = BizStore::query();

        if (!empty($params['store_name'])) {
            $query->where('store_name', 'like', '%' . $params['store_name'] . '%');
        }
        if (!empty($params['enterprise_id'])) {
            $query->where('enterprise_id', $params['enterprise_id']);
        }
        if (!empty($params['manager_name'])) {
            $query->where('manager_name', 'like', '%' . $params['manager_name'] . '%');
        }
        if (!empty($params['phone'])) {
            $query->where('phone', 'like', '%' . $params['phone'] . '%');
        }
        if (!empty($params['keyword'])) {
            $query->where(function ($q) use ($params) {
                $q->where('store_name', 'like', '%' . $params['keyword'] . '%')
                  ->orWhere('enterprise_name', 'like', '%' . $params['keyword'] . '%');
            });
        }
        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('store_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询门店详情

    public function selectStoreById($storeId)
    {
        return BizStore::find($storeId);
    }

    // 新增门店

    public function insertStore($data)
    {
        if (isset($data['server_user_id']) && is_array($data['server_user_id'])) {
            $data['server_user_id'] = !empty($data['server_user_id']) ? implode(',', $data['server_user_id']) : null;
        }
        if (isset($data['server_user_name']) && is_array($data['server_user_name'])) {
            $data['server_user_name'] = !empty($data['server_user_name']) ? implode('、', $data['server_user_name']) : null;
        }
        $data['create_time'] = date('Y-m-d H:i:s');
        if (!empty($data['enterprise_id'])) {
            $enterprise = BizEnterprise::find($data['enterprise_id']);
            if ($enterprise) {
                $data['enterprise_name'] = $enterprise->enterprise_name;
            }
        }
        return BizStore::create($data);
    }

    // 更新门店信息

    public function updateStore($data)
    {
        if (isset($data['server_user_id']) && is_array($data['server_user_id'])) {
            $data['server_user_id'] = !empty($data['server_user_id']) ? implode(',', $data['server_user_id']) : null;
        }
        if (isset($data['server_user_name']) && is_array($data['server_user_name'])) {
            $data['server_user_name'] = !empty($data['server_user_name']) ? implode('、', $data['server_user_name']) : null;
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        if (!empty($data['enterprise_id'])) {
            $enterprise = BizEnterprise::find($data['enterprise_id']);
            if ($enterprise) {
                $data['enterprise_name'] = $enterprise->enterprise_name;
            }
        }
        $store = BizStore::find($data['store_id']);
        if (!$store) {
            throw new \Exception('门店不存在');
        }
        $store->fill($data)->save();
        return true;
    }

    public function selectStoreForSearch($keyword, $enterpriseId = null, $params = [])
    {
        $query = BizStore::query();

        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('store_name', 'like', '%' . $keyword . '%')
                  ->orWhere('enterprise_name', 'like', '%' . $keyword . '%');
            });
        }

        if (!empty($enterpriseId)) {
            $query->where('enterprise_id', $enterpriseId);
        }

        return $query->where('status', '0')
                    ->orderBy('store_name', 'asc')
                    ->limit(50)
                    ->get();
    }

    // 批量删除门店

    public function deleteStoreByIds($storeIds)
    {
        return BizStore::whereIn('store_id', $storeIds)->delete();
    }
}
