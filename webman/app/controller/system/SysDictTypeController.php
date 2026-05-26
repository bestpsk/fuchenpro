<?php

namespace app\controller\system;

use support\Request;
use app\service\SysDictTypeService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 字典类型管理控制器
 *
 * 负责字典类型的增删改查、字典缓存刷新和下拉选择等功能
 */
class SysDictTypeController
{
    // 分页查询字典类型列表
    public function list(Request $request)
    {
        $service = new SysDictTypeService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectDictTypeList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取字典类型详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $dictId = intval(end($parts));
        $service = new SysDictTypeService();
        $dict = $service->selectDictTypeById($dictId);
        if (!$dict) return AjaxResult::error('字典类型不存在');
        return AjaxResult::success($dict);
    }

    // 新增字典类型
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDictTypeService();
        $result = $service->insertDictType($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改字典类型
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysDictTypeService();
        $result = $service->updateDictType($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除字典类型
    public function remove(Request $request)
    {
        $dictIds = explode(',', $request->input('dictIds', ''));
        $dictIds = array_map('intval', array_filter($dictIds));
        $service = new SysDictTypeService();
        $result = $service->deleteDictTypeByIds($dictIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 刷新字典缓存（清空Redis中的字典缓存并重新加载）
    public function refreshCache(Request $request)
    {
        $service = new SysDictTypeService();
        $service->resetDictCache();
        return AjaxResult::success();
    }

    // 获取字典类型下拉选择列表
    public function optionselect(Request $request)
    {
        $service = new SysDictTypeService();
        return AjaxResult::success($service->optionselect());
    }
}
