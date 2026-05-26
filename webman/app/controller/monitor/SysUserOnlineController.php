<?php

namespace app\controller\monitor;

use support\Request;
use app\service\SysUserOnlineService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 在线用户监控控制器
 *
 * 负责查询当前在线用户列表和强制下线指定用户功能
 */
class SysUserOnlineController
{
    // 查询当前在线用户列表（从Redis中获取所有活跃登录令牌）
    public function list(Request $request)
    {
        $service = new SysUserOnlineService();
        $list = $service->selectOnlineList($request->all());
        return TableDataInfo::result($list, count($list));
    }

    // 强制下线指定用户（删除其Redis登录令牌）
    public function forceLogout(Request $request)
    {
        $tokenId = $request->input('tokenId', '');
        $service = new SysUserOnlineService();
        $result = $service->forceLogout($tokenId);
        return AjaxResult::toAjax($result ? 1 : 0);
    }
}
