<?php

namespace app\controller\wms;

use support\Request;
use app\service\BizStockTransferService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\ExcelUtil;
use app\common\TableDataInfo;
use app\model\BizStockTransfer;

/**
 * 调拨管理控制器
 *
 * 负责调拨单的增删改查、确认调拨和取消确认等功能，
 * 确认调拨时自动扣减源仓库库存并增加目标仓库库存，已确认的调拨单不可修改或删除
 */
class BizStockTransferController
{
    // 分页查询调拨单列表
    public function list(Request $request)
    {
        $service = new BizStockTransferService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectTransferList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取调拨单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $transferId = intval(end($parts));
        $service = new BizStockTransferService();
        $params['login_user'] = $request->loginUser;
        $transfer = $service->selectTransferById($transferId, $params);
        if (!$transfer) return AjaxResult::error('调拨单不存在');
        return AjaxResult::success($transfer);
    }

    // 新增调拨单，含调拨明细项，自动填充操作人信息
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:transfer:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $loginUser = $request->loginUser->user;
            $realName = trim($loginUser->nick_name ?? '');
            $userName = trim($loginUser->user_name ?? '');
            $data['create_by'] = $realName ?: $userName;
            $data['operator_id'] = $request->loginUser->userId ?? 0;
            $data['operator_name'] = $realName ?: $userName;
            if (isset($data['items'])) {
                $data['items'] = convert_to_snake_case($data['items']);
            }
            $service = new BizStockTransferService();
            $result = $service->addTransfer($data);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success();
        } catch (\Throwable $e) {
            \support\Log::error('新增调拨单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 修改调拨单及明细项，已确认的调拨单不可修改
    public function update(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:transfer:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $data = convert_to_snake_case($request->post());
            $data['update_by'] = $request->loginUser->user->user_name ?? '';
            $data['login_user'] = $request->loginUser;
            if (isset($data['items'])) {
                $data['items'] = convert_to_snake_case($data['items']);
            }
            $service = new BizStockTransferService();
            $result = $service->updateTransfer($data);
            if (!$result) return AjaxResult::error('修改失败，调拨单不存在或已确认');
            return AjaxResult::success();
        } catch (\Throwable $e) {
            \support\Log::error('修改调拨单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 批量删除调拨单，已确认的调拨单不可删除
    public function delete(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:transfer:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $transferIds = $request->input('transferIds', '');
            if (!is_array($transferIds)) {
                $transferIds = explode(',', $transferIds);
            }
            $transferIds = array_map('intval', array_filter($transferIds));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockTransferService();
            $result = $service->deleteTransferByIds($transferIds, $params);
            if (!$result) return AjaxResult::error('删除失败，已确认的调拨单不可删除');
            return AjaxResult::success();
        } catch (\Throwable $e) {
            \support\Log::error('删除调拨单失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 确认调拨，将源仓库库存扣减并增加目标仓库库存
    public function confirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:transfer:confirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $parts = explode('/', $request->path());
            $id = intval(end($parts));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockTransferService();
            $result = $service->confirmTransfer($id, $params);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success($result['msg']);
        } catch (\Throwable $e) {
            \support\Log::error('确认调拨失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 取消确认调拨，回退库存
    public function cancelConfirm(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'wms:transfer:confirm')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        try {
            $parts = explode('/', $request->path());
            $id = intval(end($parts));
            $params['login_user'] = $request->loginUser;
            $service = new BizStockTransferService();
            $result = $service->cancelConfirmTransfer($id, $params);
            if (!$result['success']) return AjaxResult::error($result['msg']);
            return AjaxResult::success($result['msg']);
        } catch (\Throwable $e) {
            \support\Log::error('取消确认调拨失败: ' . $e->getMessage());
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 导出调拨数据
    public function export(Request $request)
    {
        $service = new BizStockTransferService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $result = $service->selectTransferList($params);
        $list = $result->items();
        $excelUtil = new ExcelUtil(BizStockTransfer::class);
        return $excelUtil->exportExcel($list, '调拨数据');
    }
}
