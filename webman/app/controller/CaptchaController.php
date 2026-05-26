<?php

namespace app\controller;

use support\Request;
use app\service\CaptchaService;
use app\common\AjaxResult;

/**
 * 验证码控制器
 *
 * 生成图形验证码，返回Base64编码的验证码图片和唯一标识UUID
 */
class CaptchaController
{
    // 生成验证码图片，返回Base64图片数据和UUID（用于登录时校验）
    public function captchaImage(Request $request)
    {
        $result = CaptchaService::getCaptcha();
        return AjaxResult::success('', $result);
    }
}
