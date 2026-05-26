<?php

namespace app\controller\business;

use support\Request;
use app\service\BizOperationRecordService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 操作记录控制器
 *
 * 负责客户操作记录的增删查功能，包括按条件分页查询操作记录列表、
 * 新增操作记录（自动扣减套餐次数并写入客户档案）、
 * 批量删除操作记录、获取操作记录详情（含批次内所有项目）
 */
class BizOperationRecordController
{
    // 分页查询操作记录列表，支持按客户、企业、门店、套餐、日期范围等条件筛选
    public function list(Request $request)
    {
        $service = new BizOperationRecordService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectRecordList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 新增操作记录，自动填充操作人信息，套餐消费类型时扣减套餐次数并写入客户档案
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        if (empty($data['operator_user_id'])) {
            $data['operator_user_id'] = $request->loginUser->user->user_id ?? 0;
        }
        if (empty($data['operator_user_name'])) {
            $data['operator_user_name'] = $request->loginUser->user->nick_name ?? $request->loginUser->user->user_name ?? '';
        }
        $service = new BizOperationRecordService();
        $result = $service->insertRecord($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除操作记录（按ID逗号分隔）
    public function remove(Request $request)
    {
        $recordIds = $request->input('recordIds', '');
        if (!is_array($recordIds)) {
            $recordIds = explode(',', $recordIds);
        }
        $recordIds = array_map('intval', array_filter($recordIds));
        $service = new BizOperationRecordService();
        $result = $service->deleteRecordByIds($recordIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取操作记录详情，包含同一批次的所有操作项目及关联的企业/门店名称
    public function getInfo($id)
    {
        $service = new BizOperationRecordService();
        $result = $service->getRecordDetailById(intval($id));
        if (!$result) {
            return AjaxResult::error('操作记录不存在');
        }
        return AjaxResult::success($result);
    }
}
