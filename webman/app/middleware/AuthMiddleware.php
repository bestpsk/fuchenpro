<?php

namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Request;
use Webman\Http\Response;
use app\service\TokenService;
use app\common\AjaxResult;
use app\common\Constants;

/**
 * JWT Token认证中间件
 *
 * 校验请求携带的JWT令牌，验证登录状态和令牌有效期。
 * 白名单路径（登录、注册、验证码、登出）和公共接口（/common/）跳过认证，
 * 认证通过后将LoginUser实例注入到请求对象中供后续使用
 */
class AuthMiddleware implements MiddlewareInterface
{
    // 不需要认证的白名单路径
    protected $whitelist = [
        '/login',
        '/register',
        '/captchaImage',
        '/logout',
    ];

    // 处理请求：白名单和公共接口直接放行，其他请求校验JWT令牌并自动续期
    public function process(Request $request, callable $handler): Response
    {
        $path = $request->path();

        if (in_array($path, $this->whitelist)) {
            return $handler($request);
        }

        if (str_starts_with($path, '/common/')) {
            return $handler($request);
        }

        $tokenService = new TokenService();
        $loginUser = $tokenService->getLoginUser($request);

        if (!$loginUser) {
            return json(['code' => 401, 'msg' => '未登录或登录已过期']);
        }

        $tokenService->verifyToken($loginUser);

        $request->loginUser = $loginUser;

        return $handler($request);
    }
}
