<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysJobService;
use app\service\PermissionService;
use app\model\SysJob;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;

/**
 * 定时任务管理控制器
 *
 * 负责定时任务的增删改查、状态变更和立即执行等功能
 */
class SysJobController
{
    // 分页查询定时任务列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new SysJobService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectJobList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取定时任务详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $jobId = intval(end($parts));
        $service = new SysJobService();
        $job = $service->selectJobById($jobId);
        if (!$job) return AjaxResult::error('任务不存在');
        return AjaxResult::success($job);
    }

    // 新增定时任务
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysJobService();
        try {
            return AjaxResult::toAjax($service->insertJob($data) ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 修改定时任务
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new SysJobService();
        try {
            return AjaxResult::toAjax($service->updateJob($data) ? 1 : 0);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // 批量删除定时任务
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $jobIds = explode(',', $request->input('jobIds', ''));
        $jobIds = array_map('intval', array_filter($jobIds));
        $service = new SysJobService();
        return AjaxResult::toAjax($service->deleteJobByIds($jobIds) ? 1 : 0);
    }

    // 变更定时任务状态（启动/暂停）
    public function changeStatus(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:changeStatus')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $jobId = $request->post('jobId');
        $status = $request->post('status');
        $service = new SysJobService();
        return AjaxResult::toAjax($service->changeStatus($jobId, $status) ? 1 : 0);
    }

    // 立即执行一次定时任务
    public function run(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:run')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $jobId = $request->post('jobId');
        $service = new SysJobService();
        $job = $service->selectJobById($jobId);
        if (!$job) return AjaxResult::error('任务不存在');
        $service->run($job);
        return AjaxResult::success();
    }

    // 导出定时任务为Excel
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:job:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['page_size'] = 10000;
        $service = new SysJobService();
        $result = $service->selectJobList($params);
        $list = $result->items();

        $excelUtil = new ExcelUtil(SysJob::class);
        return $excelUtil->exportExcel($list, '定时任务');
    }
}
