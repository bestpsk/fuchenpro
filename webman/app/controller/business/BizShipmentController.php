<?php

namespace app\controller\business;

use support\Request;
use app\service\BizShipmentService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 出货管理控制器
 *
 * 负责出货单的增删改查、审核、发货和确认收货等全流程管理，
 * 已审核的出货单不可删除
 */
class BizShipmentController
{
    protected $shipmentService;

    public function __construct()
    {
        $this->shipmentService = new BizShipmentService();
    }

    // 分页查询出货单列表
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = $this->shipmentService->selectShipmentList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取出货单详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $shipmentId = intval(end($parts));
        $shipment = $this->shipmentService->selectShipmentById($shipmentId);
        if (!$shipment) return AjaxResult::error('出货单不存在');
        return AjaxResult::success($shipment);
    }

    // 新增出货单，含出货明细项
    public function add(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->shipmentService->insertShipment($data);
        if (isset($result['error'])) {
            return AjaxResult::error($result['error']);
        }
        return AjaxResult::success($result, '新增成功');
    }

    // 修改出货单信息
    public function edit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->shipmentService->updateShipment($data);
        if (!$result) {
            return AjaxResult::error('修改失败');
        }
        return AjaxResult::success(null, '修改成功');
    }

    // 批量删除出货单，已审核的不可删除
    public function remove(Request $request)
    {
        $shipmentIds = $request->input('shipmentIds', '');
        if (!is_array($shipmentIds)) {
            $shipmentIds = explode(',', $shipmentIds);
        }
        $shipmentIds = array_map('intval', array_filter($shipmentIds));
        $result = $this->shipmentService->deleteShipmentByIds($shipmentIds);
        if (!$result) {
            return AjaxResult::error('删除失败，已审核的出货单不可删除');
        }
        return AjaxResult::success(null, '删除成功');
    }

    // 审核出货单（通过或驳回）
    public function audit(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $data['audit_by'] = $request->loginUser->user->user_name ?? '';
        $result = $this->shipmentService->audit($data);
        if (!$result) {
            return AjaxResult::error('审核失败');
        }
        return AjaxResult::success(null, '审核成功');
    }

    // 出货单发货操作
    public function ship(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $result = $this->shipmentService->ship($data);
        if (!$result) {
            return AjaxResult::error('发货失败');
        }
        return AjaxResult::success(null, '发货成功');
    }

    // 确认收货
    public function confirmReceipt(Request $request)
    {
        $parts = explode('/', $request->path());
        $shipmentId = intval(end($parts));
        $result = $this->shipmentService->confirmReceipt($shipmentId);
        if (!$result) {
            return AjaxResult::error('确认收货失败');
        }
        return AjaxResult::success(null, '确认收货成功');
    }
}
