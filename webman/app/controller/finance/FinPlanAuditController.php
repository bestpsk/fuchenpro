<?php

namespace app\controller\finance;

use support\Request;
use app\service\BizPlanService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 方案审核控制器，提供财务视角的方案审核功能
 */
class FinPlanAuditController
{
    protected $service;

    public function __construct()
    {
        $this->service = new BizPlanService();
    }

    // 查询待审核方案列表（待审核和已驳回优先显示）
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'finance:planAudit:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        // 启用审核状态优先级排序（待审核→已驳回→已审核→已完成→草稿）
        $params['audit_priority_sort'] = true;

        $result = $this->service->selectPlanList($params);

        return TableDataInfo::result($result->items(), $result->total());
    }

    // 查询方案详情
    public function info(Request $request, $id)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'finance:planAudit:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $result = $this->service->selectPlanById($id);
        if (!$result) return AjaxResult::error('数据不存在');
        return AjaxResult::success('', $result);
    }

    // 审核方案
    public function audit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'finance:planAudit:audit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $loginUser = $request->loginUser;
        $user = $loginUser->user;

        $data['audit_by'] = $user ? ($user->nick_name ?: $user->user_name) : '';

        $result = $this->service->audit($data);
        if ($result === false) {
            return AjaxResult::error('审核失败');
        }
        return AjaxResult::success('审核成功');
    }
}
