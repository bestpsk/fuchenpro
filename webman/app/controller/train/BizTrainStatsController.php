<?php

namespace app\controller\train;

use support\Request;
use app\service\BizTrainStatsService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;

/**
 * 培训学习统计控制器
 */
class BizTrainStatsController
{
    // 分页查询统计列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:stats:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizTrainStatsService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectStatsList($params, $request->loginUser);
        return TableDataInfo::result($result['items'], $result['total']);
    }

    // 汇总数据
    public function summary(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:stats:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizTrainStatsService();
        $params = convert_to_snake_case($request->all());
        $result = $service->getStatsSummary($params, $request->loginUser);
        return AjaxResult::success($result);
    }

    // 导出Excel
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:stats:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizTrainStatsService();
        $params = convert_to_snake_case($request->all());
        $items = $service->exportStats($params, $request->loginUser);

        $excelUtil = new ExcelUtil();
        $excelUtil->setFields([
            'user_name'       => ['name' => '用户姓名', 'sort' => 1],
            'dept_name'       => ['name' => '所属部门', 'sort' => 2],
            'material_title'  => ['name' => '材料标题', 'sort' => 3],
            'total_duration'  => ['name' => '累计学习时长(秒)', 'cellType' => 'numeric', 'sort' => 4],
            'study_count'     => ['name' => '学习次数', 'cellType' => 'numeric', 'sort' => 5],
            'last_study_time' => ['name' => '最后学习时间', 'sort' => 6],
        ]);
        return $excelUtil->exportExcel($items, '学习统计_' . date('Ymd'));
    }
}
