<?php

namespace app\controller\finance;

use support\Request;
use app\service\BizPlanService;
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
        $params = $request->all();

        $result = $this->service->selectPlanList($params);

        $items = $result->items();
        usort($items, function ($a, $b) {
            $priority = ['1' => 0, '4' => 1, '2' => 2, '3' => 3, '0' => 4];
            $aPriority = $priority[$a->audit_status] ?? 5;
            $bPriority = $priority[$b->audit_status] ?? 5;
            return $aPriority - $bPriority;
        });

        return TableDataInfo::result($items, $result->total());
    }

    // 查询方案详情
    public function info(Request $request, $id)
    {
        $result = $this->service->selectPlanById($id);
        return AjaxResult::success('', $result);
    }

    // 审核方案
    public function audit(Request $request)
    {
        $data = $request->post();
        $loginUser = $request->loginUser;
        $user = $loginUser->user;

        $data['audit_by'] = $user ? ($user->nick_name ?: $user->user_name) : '';

        $result = $this->service->auditPlan($data);
        if ($result === false) {
            return AjaxResult::error('审核失败');
        }
        return AjaxResult::success('审核成功');
    }
}
