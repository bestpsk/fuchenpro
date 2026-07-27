<?php

namespace app\service;

use app\model\BizTrainMaterial;

/**
 * 培训学习材料服务层，处理材料的增删改查
 */
class BizTrainMaterialService
{
    // 分页查询材料列表
    // $userId 非null时按授权过滤（非管理员），null时不过滤
    public function selectMaterialList($params = [], $userId = null)
    {
        $query = BizTrainMaterial::query()->where('del_flag', '0');

        // 授权过滤：非管理员只能看到被授权的材料
        if ($userId !== null) {
            $authService = new \app\service\BizTrainMaterialAuthService();
            $materialIds = $authService->getAuthorizedMaterialIds($userId);
            if ($materialIds !== null) {
                $query->whereIn('material_id', $materialIds);
            }
        }

        if (!empty($params['keyword'])) {
            $keyword = $params['keyword'];
            $query->where(function ($q) use ($keyword) {
                $q->where('title', 'like', '%' . $keyword . '%');
            });
        }
        if (!empty($params['title'])) {
            $query->where('title', 'like', '%' . $params['title'] . '%');
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('category', $params['category']);
        }
        if (isset($params['file_type']) && $params['file_type'] !== '') {
            $query->where('file_type', $params['file_type']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('sort', 'asc')->orderBy('material_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询材料
    public function selectMaterialById($materialId)
    {
        return BizTrainMaterial::where('del_flag', '0')->find($materialId);
    }

    // 新增材料
    public function insertMaterial($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizTrainMaterial::create($data);
    }

    // 修改材料
    public function updateMaterial($data)
    {
        if (empty($data['material_id'])) {
            throw new \Exception('材料ID不能为空');
        }
        $material = BizTrainMaterial::find($data['material_id']);
        if (!$material) {
            throw new \Exception('材料不存在');
        }
        unset($data['material_id']);
        $material->fill($data)->save();
        return true;
    }

    // 软删除材料
    public function deleteMaterialByIds($materialIds)
    {
        return BizTrainMaterial::whereIn('material_id', $materialIds)
            ->where('del_flag', '0')
            ->update(['del_flag' => '2', 'update_time' => date('Y-m-d H:i:s')]);
    }
}
