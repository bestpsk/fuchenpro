<?php

namespace app\controller\business;

use support\Request;
use app\service\BizCustomerArchiveService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 客户档案控制器
 *
 * 负责客户档案的查询、新增和删除，档案记录客户的服务历史信息，
 * 可由操作记录、销售订单、还款记录等自动生成或手动创建
 */
class BizCustomerArchiveController
{
    // 分页查询客户档案列表，支持按客户、日期范围等条件筛选
    public function list(Request $request)
    {
        $service = new BizCustomerArchiveService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectArchiveList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 手动新增客户档案，来源类型标记为手动创建(3)
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());

        if (empty($data['customer_id'])) {
            return AjaxResult::error('客户ID不能为空');
        }

        $data['source_type'] = '3';
        $data['source_id'] = null;
        $data['create_by'] = $request->loginUser->user->user_name ?? '';

        $service = new BizCustomerArchiveService();
        try {
            $result = $service->insertArchive($data);
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            return AjaxResult::error('新增档案失败，请稍后重试');
        }
    }

    // 批量删除客户档案
    public function remove(Request $request)
    {
        $archiveIds = $request->input('archiveIds', '');
        if (!is_array($archiveIds)) {
            $archiveIds = explode(',', $archiveIds);
        }
        $archiveIds = array_map('intval', array_filter($archiveIds));
        $service = new BizCustomerArchiveService();
        $result = $service->deleteArchiveByIds($archiveIds);
        if ($result) {
            return AjaxResult::success('删除成功');
        }
        return AjaxResult::error('删除失败');
    }
}
