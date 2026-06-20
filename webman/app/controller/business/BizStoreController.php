<?php

namespace app\controller\business;

use support\Request;
use app\service\BizStoreService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizStore;

/**
 * 门店管理控制器
 *
 * 负责门店的增删改查和门店搜索功能，门店隶属于企业
 */
class BizStoreController
{
    // 分页查询门店列表，支持按企业、门店名称、状态等条件筛选
    public function list(Request $request)
    {
        $service = new BizStoreService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectStoreList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取门店详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $storeId = intval(end($parts));
        $service = new BizStoreService();
        $store = $service->selectStoreById($storeId);
        if (!$store) return AjaxResult::error('门店不存在');
        return AjaxResult::success($store);
    }

    // 模糊搜索门店，可按企业ID过滤，用于下拉选择框
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $enterpriseId = $request->input('enterpriseId', null);
        $params = ['login_user' => $request->loginUser];
        $service = new BizStoreService();
        $result = $service->selectStoreForSearch($keyword, $enterpriseId, $params);
        return AjaxResult::success($result);
    }

    // 新增门店，自动填充创建人信息
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizStoreService();
        $result = $service->insertStore($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改门店信息，自动填充更新人信息
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizStoreService();
        $result = $service->updateStore($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除门店
    public function remove(Request $request)
    {
        $storeIds = explode(',', $request->input('storeIds', ''));
        $storeIds = array_map('intval', array_filter($storeIds));
        $service = new BizStoreService();
        $result = $service->deleteStoreByIds($storeIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 导出门店数据
    public function export(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $service = new BizStoreService();
        $result = $service->selectStoreList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizStore::class);
        return $excelUtil->exportExcel($list, '门店数据');
    }
}
