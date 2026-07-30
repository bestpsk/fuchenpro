<?php

namespace app\service;

use app\model\BizTrainStudyLog;
use app\model\BizTrainMaterial;
use app\model\SysUser;
use app\model\SysDept;
use support\Db;

/**
 * 培训学习统计服务层
 * 按 user_id + material_id 聚合查询学习时长和次数
 */
class BizTrainStatsService
{
    // 分页查询统计列表
    // $loginUser 非null时按数据权限过滤
    public function selectStatsList($params = [], $loginUser = null)
    {
        $query = Db::table('biz_train_study_log as l')
            ->join('sys_user as u', 'l.user_id', '=', 'u.user_id')
            ->leftJoin('sys_dept as d', 'u.dept_id', '=', 'd.dept_id')
            ->join('biz_train_material as m', 'l.material_id', '=', 'm.material_id')
            ->where('m.del_flag', '0')
            ->where('u.del_flag', '0')
            ->select(
                'l.user_id',
                'u.nick_name as user_name',
                'u.user_name as account',
                'd.dept_name',
                'l.material_id',
                'm.title as material_title',
                Db::raw('SUM(l.valid_duration) as total_duration'),
                Db::raw('COUNT(*) as study_count'),
                Db::raw('MAX(l.start_time) as last_study_time')
            )
            ->groupBy('l.user_id', 'l.material_id', 'u.nick_name', 'u.user_name', 'd.dept_name', 'm.title');

        // 数据权限过滤：非管理员只能看到权限范围内的用户统计数据
        if ($loginUser !== null) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
            $query->whereIn('l.user_id', $visibleUserIds);
        }

        // 筛选条件（日期范围、材料ID、用户ID、用户姓名、材料标题）
        $this->applyStatsFilters($query, $params);

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);

        // 先获取分页数据（clone 避免影响总数查询）
        $items = (clone $query)->orderByRaw('total_duration DESC')
            ->offset(($pageNum - 1) * $pageSize)
            ->limit($pageSize)
            ->get();

        // 计算分组后的总数（用子查询避免 get()->count() 性能问题）
        $total = $items->count() < $pageSize ? ($pageNum - 1) * $pageSize + $items->count() : $this->countGroupedRows($query);

        return ['items' => $items, 'total' => $total];
    }

    // 计算分组查询的总行数（用于分页）
    private function countGroupedRows($query)
    {
        $sql = $query->toSql();
        $bindings = $query->getBindings();
        $countSql = "SELECT COUNT(*) as cnt FROM ({$sql}) AS grouped_rows";
        $result = Db::select($countSql, $bindings);
        return $result[0]->cnt ?? 0;
    }

    // 应用统计查询的公共筛选条件（日期范围、材料ID、用户ID、用户姓名、材料标题）
    // 查询需使用别名：l=biz_train_study_log, u=sys_user, m=biz_train_material
    private function applyStatsFilters($query, $params)
    {
        if (!empty($params['start_date']) && !empty($params['end_date'])) {
            $query->whereBetween('l.start_time', [$params['start_date'] . ' 00:00:00', $params['end_date'] . ' 23:59:59']);
        } elseif (!empty($params['start_date'])) {
            $query->where('l.start_time', '>=', $params['start_date'] . ' 00:00:00');
        } elseif (!empty($params['end_date'])) {
            $query->where('l.start_time', '<=', $params['end_date'] . ' 23:59:59');
        }

        if (!empty($params['material_id'])) {
            $query->where('l.material_id', $params['material_id']);
        }

        if (!empty($params['user_id'])) {
            $query->where('l.user_id', $params['user_id']);
        }

        if (!empty($params['user_name'])) {
            $query->where(function ($q) use ($params) {
                $q->where('u.nick_name', 'like', '%' . $params['user_name'] . '%')
                  ->orWhere('u.user_name', 'like', '%' . $params['user_name'] . '%');
            });
        }

        if (!empty($params['material_title'])) {
            $query->where('m.title', 'like', '%' . $params['material_title'] . '%');
        }
    }

    // 汇总数据
    // $loginUser 非null时按数据权限过滤
    public function getStatsSummary($params = [], $loginUser = null)
    {
        $query = Db::table('biz_train_study_log as l')
            ->join('sys_user as u', 'l.user_id', '=', 'u.user_id')
            ->join('biz_train_material as m', 'l.material_id', '=', 'm.material_id')
            ->where('m.del_flag', '0')
            ->where('u.del_flag', '0');

        // 数据权限过滤
        if ($loginUser !== null) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
            $query->whereIn('l.user_id', $visibleUserIds);
        }

        // 筛选条件（日期范围、材料ID、用户ID、用户姓名、材料标题）
        $this->applyStatsFilters($query, $params);

        $result = $query->selectRaw(
            'SUM(l.valid_duration) as total_duration, COUNT(*) as total_count, COUNT(DISTINCT l.user_id) as user_count, COUNT(DISTINCT l.material_id) as material_count'
        )->first();

        return $result;
    }

    // 导出Excel数据
    public function exportStats($params = [], $loginUser = null)
    {
        $params['page_size'] = 10000;
        $result = $this->selectStatsList($params, $loginUser);
        return $result['items'];
    }
}
