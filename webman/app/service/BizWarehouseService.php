<?php

namespace app\service;

use app\model\BizWarehouse;
use app\model\BizWarehouseUser;
use app\model\BizInventory;
use support\Db;

/**
 * 仓库服务层，处理仓库的增删改查、用户授权及仓库编码自动生成
 */
class BizWarehouseService
{
    // 获取用户授权的仓库ID列表（管理员返回null表示不限制）
    public static function getAuthorizedWarehouseIds($loginUser)
    {
        if (empty($loginUser) || $loginUser->isAdmin()) {
            return null;
        }
        return BizWarehouseUser::where('user_id', $loginUser->userId)
            ->pluck('warehouse_id')->toArray();
    }

    // 按条件分页查询仓库列表
    public function selectWarehouseList($params = [])
    {
        $query = BizWarehouse::query();
        if (!empty($params['warehouse_name'])) {
            $query->where('warehouse_name', 'like', '%' . $params['warehouse_name'] . '%');
        }
        if (!empty($params['warehouse_code'])) {
            $query->where('warehouse_code', 'like', '%' . $params['warehouse_code'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        $authorizedWhIds = self::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('warehouse_id', $authorizedWhIds);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('warehouse_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询仓库详情
    public function selectWarehouseById($warehouseId)
    {
        return BizWarehouse::find($warehouseId);
    }

    // 新增仓库，自动生成仓库编码（WH + 3位序号）
    public function addWarehouse($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $data['warehouse_code'] = $this->generateWarehouseCode();
        return BizWarehouse::create($data);
    }

    // 更新仓库信息
    public function updateWarehouse($warehouseId, $data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return BizWarehouse::where('warehouse_id', $warehouseId)->update($data);
    }

    // 批量删除仓库，删除前检查是否有关联库存
    public function deleteWarehouse($warehouseIds)
    {
        // 检查是否有关联库存记录
        $inventoryCount = BizInventory::whereIn('warehouse_id', $warehouseIds)->count();
        if ($inventoryCount > 0) {
            return false;
        }
        Db::transaction(function () use ($warehouseIds) {
            BizWarehouseUser::whereIn('warehouse_id', $warehouseIds)->delete();
            BizWarehouse::whereIn('warehouse_id', $warehouseIds)->delete();
        });
        return true;
    }

    // 获取当前用户授权的仓库列表（管理员返回全部，普通用户按 biz_warehouse_user 过滤）
    public function getUserWarehouses($loginUser)
    {
        if ($loginUser->isAdmin()) {
            return BizWarehouse::where('status', '0')->orderBy('warehouse_id', 'desc')->get();
        }
        $warehouseIds = BizWarehouseUser::where('user_id', $loginUser->userId)
            ->pluck('warehouse_id')->toArray();
        return BizWarehouse::whereIn('warehouse_id', $warehouseIds)
            ->where('status', '0')
            ->orderBy('warehouse_id', 'desc')
            ->get();
    }

    // 分配用户到仓库（支持 add/remove/replace 三种操作）
    public function assignUsers($warehouseId, $userIds, $action = 'replace')
    {
        if ($action === 'add') {
            foreach ($userIds as $userId) {
                BizWarehouseUser::firstOrCreate([
                    'warehouse_id' => $warehouseId,
                    'user_id' => $userId,
                ]);
            }
            return true;
        }
        if ($action === 'remove') {
            BizWarehouseUser::where('warehouse_id', $warehouseId)
                ->whereIn('user_id', $userIds)
                ->delete();
            return true;
        }
        // 默认全量替换
        Db::transaction(function () use ($warehouseId, $userIds) {
            BizWarehouseUser::where('warehouse_id', $warehouseId)->delete();
            if (!empty($userIds)) {
                $insertData = [];
                foreach ($userIds as $userId) {
                    $insertData[] = [
                        'warehouse_id' => $warehouseId,
                        'user_id' => $userId
                    ];
                }
                BizWarehouseUser::insert($insertData);
            }
        });
        return true;
    }

    // 获取仓库下的用户列表
    public function getWarehouseUsers($warehouseId)
    {
        $warehouse = BizWarehouse::with('users')->find($warehouseId);
        if (!$warehouse) {
            return [];
        }
        return $warehouse->users;
    }

    // 生成仓库编码：WH + 3位序号
    private function generateWarehouseCode()
    {
        $lastWarehouse = BizWarehouse::orderBy('warehouse_id', 'desc')->first();
        $nextId = $lastWarehouse ? $lastWarehouse->warehouse_id + 1 : 1;
        return 'WH' . str_pad($nextId, 3, '0', STR_PAD_LEFT);
    }
}
