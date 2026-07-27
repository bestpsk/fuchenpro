<?php

namespace app\service;

use app\model\BizEmployeeConfig;
use app\service\DataScopeService;
use support\Db;

/**
 * 员工配置服务层，处理员工排班配置的增删改查、排班可用状态和员工搜索
 * 休息日管理已迁移至 BizRestPlanService（biz_rest_plan_* 表）
 */
class BizEmployeeConfigService
{
    // 按条件分页查询员工排班配置列表
    public function selectConfigList($params = [])
    {
        $query = Db::table('sys_user as su')
            ->leftJoin('biz_employee_config as ec', 'su.user_id', '=', 'ec.user_id')
            ->leftJoin('sys_user_post as up', 'su.user_id', '=', 'up.user_id')
            ->leftJoin('sys_post as p', 'up.post_id', '=', 'p.post_id')
            ->leftJoin('sys_dept as d', 'su.dept_id', '=', 'd.dept_id')
            ->where('su.del_flag', '0')
            ->where('su.status', '0')
            ->select(
                'su.user_id', 'su.user_name', 'su.nick_name', 'su.phonenumber',
                'ec.config_id', 'ec.is_schedulable', 'ec.status as config_status',
                'p.post_id', 'p.post_name',
                'd.dept_id', 'd.dept_name'
            );

        if (!empty($params['user_name'])) {
            $query->where('su.nick_name', 'like', '%' . $params['user_name'] . '%');
        }
        if (!empty($params['dept_name'])) {
            $query->where('d.dept_name', 'like', '%' . $params['dept_name'] . '%');
        }
        if (!empty($params['dept_id'])) {
            $query->where('su.dept_id', $params['dept_id']);
        }
        if (isset($params['is_schedulable'])) {
            $query->where('ec.is_schedulable', $params['is_schedulable']);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('su.user_id', $visibleUserIds);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('su.user_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        foreach ($result->items() as $item) {
            // 仅当 is_schedulable 字段为 NULL 或空字符串时才兜底为 '1'，不能使用 empty() 因为 empty('0') 为 true
            if ($item->is_schedulable === null || $item->is_schedulable === '') {
                $item->is_schedulable = '1';
            }
            $item->user_name = $item->nick_name ?: $item->user_name;
        }

        return $result;
    }

    // 根据ID查询员工排班配置详情

    public function selectConfigById($configId)
    {
        return BizEmployeeConfig::find($configId);
    }

    public function selectConfigByUserId($userId)
    {
        return BizEmployeeConfig::where('user_id', $userId)->first();
    }

    // 新增员工排班配置

    public function insertConfig($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizEmployeeConfig::create($data);
    }

    // 更新员工排班配置信息

    public function updateConfig($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return BizEmployeeConfig::where('config_id', $data['config_id'])->update($data);
    }

    public function updateSchedulable($userId, $isSchedulable)
    {
        $config = BizEmployeeConfig::where('user_id', $userId)->first();
        if ($config) {
            return BizEmployeeConfig::where('user_id', $userId)->update([
                'is_schedulable' => $isSchedulable,
                'update_time' => date('Y-m-d H:i:s')
            ]);
        }

        $user = Db::table('sys_user')->where('user_id', $userId)->first();
        if (!$user) return false;

        $postInfo = Db::table('sys_user_post as up')
            ->join('sys_post as p', 'up.post_id', '=', 'p.post_id')
            ->where('up.user_id', $userId)->first();

        $deptInfo = Db::table('sys_dept')->where('dept_id', $user->dept_id)->first();

        return BizEmployeeConfig::create([
            'user_id' => $userId,
            'user_name' => $user->nick_name ?: $user->user_name,
            'post_id' => $postInfo ? $postInfo->post_id : null,
            'post_name' => $postInfo ? $postInfo->post_name : null,
            'dept_id' => $user->dept_id,
            'dept_name' => $deptInfo ? $deptInfo->dept_name : null,
            'is_schedulable' => $isSchedulable,
            'status' => '0',
            'create_time' => date('Y-m-d H:i:s'),
        ]) ? true : false;
    }

    // 批量删除员工排班配置

    public function deleteConfigByIds($configIds)
    {
        return BizEmployeeConfig::whereIn('config_id', $configIds)->delete();
    }

    public function searchEmployee($keyword = '', $params = [])
    {
        $query = Db::table('sys_user as su')
            ->leftJoin('sys_user_post as up', 'su.user_id', '=', 'up.user_id')
            ->leftJoin('sys_post as p', 'up.post_id', '=', 'p.post_id')
            ->leftJoin('sys_dept as d', 'su.dept_id', '=', 'd.dept_id')
            ->where('su.del_flag', '0')
            ->where('su.status', '0')
            ->select('su.user_id', 'su.nick_name as user_name', 'd.dept_name', 'p.post_name');

        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('su.nick_name', 'like', '%' . $keyword . '%')
                  ->orWhere('su.user_name', 'like', '%' . $keyword . '%')
                  ->orWhere('d.dept_name', 'like', '%' . $keyword . '%');
            });
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('su.user_id', $visibleUserIds);
        }

        return $query->orderBy('su.user_id', 'desc')->limit(50)->get();
    }
}
