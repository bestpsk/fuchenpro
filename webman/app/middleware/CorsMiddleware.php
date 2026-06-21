<?php

namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Request;
use Webman\Http\Response;

/**
 * 跨域资源共享(CORS)中间件
 *
 * 处理浏览器跨域请求，拦截OPTIONS预检请求并返回204，
 * 在响应头中注入跨域允许的Origin、Methods、Headers等配置
 */
class CorsMiddleware implements MiddlewareInterface
{
    public function process(Request $request, callable $handler): Response
    {
        if ($request->method() === 'OPTIONS') {
            $response = response('', 204);
        } else {
            $response = $handler($request);
        }

        $origin = $request->header('origin', '');
        $allowedOrigins = config('cors.allowed_origins', []);
        $headers = [
            'Access-Control-Allow-Methods' => config('cors.methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            'Access-Control-Allow-Headers' => config('cors.headers', 'Content-Type, Authorization, X-Requested-With, token, isToken, repeatSubmit, interval'),
            'Access-Control-Allow-Credentials' => 'true',
            'Access-Control-Max-Age' => (string)config('cors.max_age', 86400),
        ];

        if (!empty($allowedOrigins)) {
            if (in_array($origin, $allowedOrigins, true) && $origin !== '') {
                $headers['Access-Control-Allow-Origin'] = $origin;
            }
        } elseif ($origin !== '') {
            $headers['Access-Control-Allow-Origin'] = $origin;
        }

        $response->withHeaders($headers);

        return $response;
    }
}
