<?php

namespace app\controller\system;

use support\Request;
use app\service\SysDictDataService;
use app\service\SysDictTypeService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 字典数据管理控制器
 *
 * 负责字典数据的增删改查，以及根据字典类型键名查询字典数据列表
 */
class SysDictDataController
{
    // 分页查询字典数据列表
    public function list(Request $request)
    {
        $service = new SysDictDataService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectDictDataList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据字典编码获取字典数据详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $dictCode = intval(end($parts));
        $service = new SysDictDataService();
        $dict = $service->selectDictDataById($dictCode);
        if (!$dict) return AjaxResult::error('字典数据不存在');
        return AjaxResult::success($dict);
    }

    // 根据字典类型键名查询字典数据列表（优先从Redis缓存读取）
    public function dictType(Request $request)
    {
        $parts = explode('/', $request->path());
        $dictType = end($parts);
        $service = new SysDictTypeService();
        $data = $service->selectDictDataByType($dictType);
        if ($data === null) {
            $data = [];
        }
        return AjaxResult::success($data);
    }

    // 新增字典数据
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDictDataService();
        $result = $service->insertDictData($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改字典数据
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDictDataService();
        $result = $service->updateDictData($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除字典数据
    public function remove(Request $request)
    {
        $dictCodes = $request->input('dictCodes', $request->input('dictCode', ''));
        if (!is_array($dictCodes)) {
            $dictCodes = explode(',', $dictCodes);
        }
        $dictCodes = array_map('intval', array_filter($dictCodes));
        if (empty($dictCodes)) {
            return AjaxResult::error('字典编码不能为空');
        }
        $service = new SysDictDataService();
        $result = $service->deleteDictDataByIds($dictCodes);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
