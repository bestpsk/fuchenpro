<?php

namespace app\controller;

use support\Request;
use app\service\HomeStatsService;
use app\common\AjaxResult;

class AppHomeController
{
    public function stats(Request $request)
    {
        $result = HomeStatsService::getTodayStats($request->loginUser);
        return AjaxResult::success($result);
    }
}
