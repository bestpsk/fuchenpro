<?php

namespace app\controller\system;

use support\Request;
use app\service\HrUserSalaryService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 薪资管理控制器
 *
 * 负责用户薪资的增删改查，支持按用户查询薪资列表和薪资类型列表查询
 */
class HrUserSalaryController
{
    // 查询薪资类型列表
    public function typeList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new HrUserSalaryService();
        $params = convert_to_snake_case($request->get());
        $list = $service->selectSalaryTypeList($params);
        return AjaxResult::success($list);
    }

    // 根据用户ID查询其薪资记录列表
    public function listByUser(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $userId = intval(end($parts));
        $service = new HrUserSalaryService();
        $list = $service->selectUserSalaryList($userId);
        return AjaxResult::success($list);
    }

    // 根据ID获取薪资记录详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $salaryId = intval(end($parts));
        $service = new HrUserSalaryService();
        $salary = $service->selectUserSalaryById($salaryId);
        return AjaxResult::success($salary);
    }

    // 新增用户薪资记录
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new HrUserSalaryService();
        $result = $service->insertUserSalary($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改用户薪资记录
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new HrUserSalaryService();
        $result = $service->updateUserSalary($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除用户薪资记录
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:userSalary:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $salaryIds = explode(',', end($parts));
        $salaryIds = array_map('intval', array_filter($salaryIds));
        $service = new HrUserSalaryService();
        $result = $service->deleteUserSalaryByIds($salaryIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
