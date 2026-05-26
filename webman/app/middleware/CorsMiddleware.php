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
    // 处理跨域请求：OPTIONS预检返回204，其他请求注入CORS响应头
    public function process(Request $request, callable $handler): Response
    {
        if ($request->method() === 'OPTIONS') {
            $response = response('', 204);
        } else {
            $response = $handler($request);
        }

        $response->withHeaders([
            'Access-Control-Allow-Origin' => $request->header('origin', '*'),
            'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With, token, isToken, repeatSubmit, interval',
            'Access-Control-Allow-Credentials' => 'true',
            'Access-Control-Max-Age' => '86400',
        ]);

        return $response;
    }
}
