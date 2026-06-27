<?php

namespace app\controller\business;

use support\Request;
use app\service\BizCustomerService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\service\CosService;
use app\model\BizCustomer;

/**
 * 客户管理控制器
 *
 * 负责客户的增删改查、客户搜索（含成交状态和套餐耗尽判断）、
 * 按企业/门店/标签等条件筛选客户列表
 */
class BizCustomerController
{
    // 分页查询客户列表，支持按企业、门店、姓名、电话、标签、状态等条件筛选
    public function list(Request $request)
    {
        $service = new BizCustomerService();
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $result = $service->selectCustomerList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取客户详情
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $customerId = intval(end($parts));
        $service = new BizCustomerService();
        $customer = $service->selectCustomerById($customerId);
        if (!$customer) return AjaxResult::error('客户不存在');
        return AjaxResult::success($customer);
    }

    // 搜索客户，返回含成交状态、消费金额、套餐耗尽情况和平均满意度的客户列表
    public function search(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $enterpriseId = $request->input('enterpriseId');
        $storeId = $request->input('storeId');
        $hasDeal = $request->input('hasDeal');
        $satisfaction = $request->input('satisfaction');
        $service = new BizCustomerService();
        $loginUser = $request->loginUser;
        $result = $service->searchCustomer($keyword, $enterpriseId, $storeId, $hasDeal, $satisfaction, $loginUser);
        return AjaxResult::success($result);
    }

    // 新增客户，自动填充创建人信息
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:customer:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizCustomerService();
        $result = $service->insertCustomer($data);
        if ($result) {
            return AjaxResult::success('', ['customerId' => $result->customer_id]);
        }
        return AjaxResult::error('新增客户失败');
    }

    // 修改客户信息，自动填充更新人信息
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:customer:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizCustomerService();
        $result = $service->updateCustomer($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除客户（按ID逗号分隔）
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'business:customer:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $customerIds = $request->input('customerIds', '');
        if (!is_array($customerIds)) {
            $customerIds = explode(',', $customerIds);
        }
        $customerIds = array_map('intval', array_filter($customerIds));
        $service = new BizCustomerService();
        $result = $service->deleteCustomerByIds($customerIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    public function avatar(Request $request)
    {
        $customerId = $request->post('customer_id');
        if (!$customerId) {
            return AjaxResult::error('缺少客户ID');
        }
        $file = $request->file('avatarfile');
        if (!$file || !$file->isValid()) {
            return AjaxResult::error('上传图片异常，请联系管理员');
        }

        $ext = $file->getUploadExtension() ?: 'png';
        $filename = md5(uniqid()) . '.' . $ext;

        $cosService = new CosService();
        if ($cosService->isEnabled()) {
            $cosPath = 'customer_avatar/' . $filename;
            $avatarUrl = $cosService->uploadFile($file, $cosPath);
            if ($avatarUrl) {
                BizCustomer::where('customer_id', $customerId)->update(['avatar' => $avatarUrl]);
                return AjaxResult::success('', ['imgUrl' => $avatarUrl]);
            }
            return AjaxResult::error('COS上传失败');
        }

        $uploadDir = public_path() . '/profile/customer_avatar/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        $file->move($uploadDir . $filename);

        $avatarUrl = '/profile/customer_avatar/' . $filename;
        BizCustomer::where('customer_id', $customerId)->update(['avatar' => $avatarUrl]);

        return AjaxResult::success('', ['imgUrl' => $avatarUrl]);
    }
}
