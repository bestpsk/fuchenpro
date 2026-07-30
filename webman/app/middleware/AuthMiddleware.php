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
    // 不需要认证的白名单路径（精确匹配）
    protected $whitelist = [
        '/login',
        '/register',
        '/captchaImage',
        '/logout',
        '/train/studyLog/end',  // 学习结束接口，会话ID本身即为凭证，支持 sendBeacon 无 Token 调用
    ];

    // 不需要认证的路径前缀（动态路径参数场景，如会话ID即凭证的文件流接口）
    protected $whitelistPrefix = [
        '/train/studyLog/file/',  // DRM文件流接口，会话ID本身即为临时凭证
    ];

    // /profile/upload/ 路径下允许匿名访问的图片扩展名（<img>标签无法携带Authorization头）
    // 非图片文件（如.pdf/.doc/.sql等）需认证后访问，防止敏感文档未授权泄露
    protected $publicImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'ico'];

    // 处理请求：白名单和公共接口直接放行，其他请求校验JWT令牌并自动续期
    public function process(Request $request, callable $handler): Response
    {
        $path = $request->path();

        if (in_array($path, $this->whitelist)) {
            return $handler($request);
        }

        // 前缀匹配白名单（用于动态路径参数的免认证接口）
        foreach ($this->whitelistPrefix as $prefix) {
            if (strpos($path, $prefix) === 0) {
                return $handler($request);
            }
        }

        // /profile/upload/ 路径仅允许图片文件匿名访问，非图片文件需认证
        if (strpos($path, '/profile/upload/') === 0) {
            $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
            if (in_array($extension, $this->publicImageExtensions)) {
                return $handler($request);
            }
        }

        // 安全加固：/common/ 路径不再免登录，上传/下载接口均需认证
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
