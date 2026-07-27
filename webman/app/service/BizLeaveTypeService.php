<?php

namespace app\service;

use app\model\BizLeaveType;

/**
 * 休假类型服务层
 */
class BizLeaveTypeService
{
    /**
     * 分页查询休假类型列表
     */
    public function selectList($params = [])
    {
        $query = BizLeaveType::query();

        if (!empty($params['type_name'])) {
            $query->where('type_name', 'like', '%' . $params['type_name'] . '%');
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (isset($params['need_approval']) && $params['need_approval'] !== '') {
            $query->where('need_approval', $params['need_approval']);
        }

        $query->orderBy('sort', 'asc')->orderBy('type_id', 'asc');

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    /**
     * 查询全部启用的休假类型（供下拉选择用）
     */
    public function selectAllEnabled()
    {
        return BizLeaveType::where('status', '0')->orderBy('sort', 'asc')->get();
    }

    public function selectById($typeId)
    {
        return BizLeaveType::find($typeId);
    }

    public function insert($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizLeaveType::create($data);
    }

    public function update($data)
    {
        if (empty($data['type_id'])) {
            throw new \Exception('类型ID不能为空');
        }
        $type = BizLeaveType::find($data['type_id']);
        if (!$type) {
            throw new \Exception('休假类型不存在');
        }
        unset($data['type_id']);
        $type->fill($data)->save();
        return true;
    }

    public function deleteByIds($typeIds)
    {
        return BizLeaveType::whereIn('type_id', $typeIds)->delete();
    }
}
