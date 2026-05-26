<?php

namespace app\controller;

use support\Request;

/**
 * 首页控制器
 *
 * 提供系统首页展示、视图渲染和JSON响应等基础入口接口
 */
class IndexController
{
    // 系统首页，嵌入webman欢迎页面
    public function index(Request $request)
    {
        return <<<EOF
<style>
  * {
    padding: 0;
    margin: 0;
  }
  iframe {
    border: none;
    overflow: scroll;
  }
</style>
<iframe
  src="https://www.workerman.net/wellcome"
  width="100%"
  height="100%"
  allow="clipboard-write"
  sandbox="allow-scripts allow-same-origin allow-popups allow-downloads"
></iframe>
EOF;
    }

    // 渲染视图模板示例
    public function view(Request $request)
    {
        return view('index/view', ['name' => 'webman']);
    }

    // 返回JSON格式响应示例
    public function json(Request $request)
    {
        return json(['code' => 0, 'msg' => 'ok']);
    }

}
