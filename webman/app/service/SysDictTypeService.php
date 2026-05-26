<?php

namespace app\service;

use app\model\SysDictType;
use app\model\SysDictData;
use support\Redis;
use app\common\Constants;

/**
 * 字典类型服务层，处理字典类型的增删改查和缓存管理
 */
class SysDictTypeService
{
    // 按条件分页查询字典类型列表
    public function selectDictTypeList($params = [])
    {
        $query = SysDictType::query();

        if (!empty($params['dict_name'])) {
            $query->where('dict_name', 'like', '%' . $params['dict_name'] . '%');
        }
        if (!empty($params['dict_type'])) {
            $query->where('dict_type', 'like', '%' . $params['dict_type'] . '%');
        }
        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('dict_id', 'asc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询字典类型详情

    public function selectDictTypeById($dictId)
    {
        return SysDictType::find($dictId);
    }

    // 新增字典类型

    public function insertDictType($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        $result = SysDictType::create($data);
        self::resetDictCache();
        return $result;
    }

    // 更新字典类型信息

    public function updateDictType($data)
    {
        $oldType = SysDictType::find($data['dict_id']);
        if ($oldType && $oldType->dict_type !== $data['dict_type']) {
            SysDictData::where('dict_type', $oldType->dict_type)->update(['dict_type' => $data['dict_type']]);
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        $result = SysDictType::where('dict_id', $data['dict_id'])->update($data);
        self::resetDictCache();
        return $result;
    }

    // 批量删除字典类型

    public function deleteDictTypeByIds($dictIds)
    {
        foreach ($dictIds as $dictId) {
            $dictType = SysDictType::find($dictId);
            if ($dictType) {
                SysDictData::where('dict_type', $dictType->dict_type)->delete();
            }
        }
        $result = SysDictType::whereIn('dict_id', $dictIds)->delete();
        self::resetDictCache();
        return $result;
    }

    public static function selectDictDataByType($dictType)
    {
        try {
            $redis = Redis::connection();
            $cacheKey = Constants::SYS_DICT_KEY . $dictType;
            $cached = $redis->get($cacheKey);
            if ($cached) {
                return json_decode($cached, true);
            }

            $data = SysDictData::where('dict_type', $dictType)->where('status', '0')->orderBy('dict_sort', 'asc')->get()->toArray();
            $redis->set($cacheKey, json_encode($data));
            return $data;
        } catch (\Exception $e) {
            $data = SysDictData::where('dict_type', $dictType)->where('status', '0')->orderBy('dict_sort', 'asc')->get()->toArray();
            return $data;
        }
    }

    public function optionselect()
    {
        return SysDictType::where('status', '0')->orderBy('dict_id', 'asc')->get();
    }

    public static function resetDictCache()
    {
        try {
            $redis = Redis::connection();
            $keys = $redis->keys(Constants::SYS_DICT_KEY . '*');
            foreach ($keys as $key) {
                $redis->del($key);
            }
        } catch (\Exception $e) {
        }
    }

    public static function getDictLabel(string $dictType, string $dictValue, string $separator = ','): string
    {
        $dictData = self::selectDictDataByType($dictType);
        if (empty($dictData)) {
            return '';
        }

        $labels = [];
        $values = explode($separator, $dictValue);

        foreach ($dictData as $item) {
            if (in_array($item['dict_value'], $values)) {
                $labels[] = $item['dict_label'];
            }
        }

        return implode($separator, $labels);
    }

    public static function getDictValue(string $dictType, string $dictLabel, string $separator = ','): string
    {
        $dictData = self::selectDictDataByType($dictType);
        if (empty($dictData)) {
            return '';
        }

        $values = [];
        $labels = explode($separator, $dictLabel);

        foreach ($dictData as $item) {
            if (in_array($item['dict_label'], $labels)) {
                $values[] = $item['dict_value'];
            }
        }

        return implode($separator, $values);
    }
}
