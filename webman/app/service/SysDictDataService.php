<?php

namespace app\service;

use app\model\SysDictData;

/**
 * 字典数据服务层，处理字典数据的增删改查和缓存管理
 */
class SysDictDataService
{
    // 按条件分页查询字典数据列表
    public function selectDictDataList($params = [])
    {
        $query = SysDictData::query();

        if (!empty($params['dict_type'])) {
            $query->where('dict_type', $params['dict_type']);
        }
        if (!empty($params['dict_label'])) {
            $query->where('dict_label', 'like', '%' . $params['dict_label'] . '%');
        }
        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('dict_sort', 'asc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询字典数据详情

    public function selectDictDataById($dictCode)
    {
        return SysDictData::find($dictCode);
    }

    // 新增字典数据

    public function insertDictData($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $result = SysDictData::create($data);
        SysDictTypeService::resetDictCache();
        return $result;
    }

    // 更新字典数据信息

    public function updateDictData($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        $result = SysDictData::where('dict_code', $data['dict_code'])->update($data);
        SysDictTypeService::resetDictCache();
        return $result;
    }

    // 批量删除字典数据

    public function deleteDictDataByIds($dictCodes)
    {
        $result = SysDictData::whereIn('dict_code', $dictCodes)->delete();
        SysDictTypeService::resetDictCache();
        return $result;
    }
}
