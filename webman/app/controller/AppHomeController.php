<?php

namespace app\controller;

use support\Request;
use app\service\HomeStatsService;
use app\service\EnterpriseStatsService;
use app\common\AjaxResult;

class AppHomeController
{
    public function stats(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');
        $result = HomeStatsService::getTodayStats($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }

    public function enterpriseStats(Request $request)
    {
        $startDate = $request->input('startDate');
        $endDate = $request->input('endDate');

        if (!$startDate || !$endDate) {
            return AjaxResult::error('请选择日期范围');
        }

        $result = EnterpriseStatsService::getEnterpriseStats($request->loginUser, $startDate, $endDate);
        return AjaxResult::success($result);
    }
}
