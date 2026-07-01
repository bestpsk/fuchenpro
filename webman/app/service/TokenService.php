<?php

namespace app\service;

use support\Redis;
use app\common\Constants;
use app\common\LoginUser;
use app\service\SysConfigService;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * JWT令牌服务层，负责令牌的创建、解析、验证、刷新和销毁，以及在线用户权限缓存刷新
 */
class TokenService
{
    protected $secret;
    protected $expire;

    public function __construct()
    {
        $this->secret = getenv('JWT_SECRET') ?: '';
        $this->expire = intval(SysConfigService::getConfigValue('sys.login.expireTime'));
    }

    // 创建JWT令牌，存入Redis并返回

    public function createToken(LoginUser $loginUser)
    {
        $token = $this->fastUUID();
        $loginUser->token = $token;
        $this->setUserAgent($loginUser);
        $this->refreshToken($loginUser);

        $claims = [
            Constants::LOGIN_USER_KEY => $token,
            Constants::JWT_USERNAME => $loginUser->user ? $loginUser->user->user_name : '',
            'iat' => time(),
            'exp' => time() + $this->expire * 60,
        ];

        $jwt = JWT::encode($claims, $this->secret, Constants::JWT_ALGO);
        return $jwt;
    }

    public function getLoginUser($request)
    {
        $token = $this->getToken($request);
        if (!$token) {
            return null;
        }
        try {
            $decoded = JWT::decode($token, new Key($this->secret, Constants::JWT_ALGO));
            $uuid = $decoded->{Constants::LOGIN_USER_KEY} ?? null;
            if (!$uuid) {
                return null;
            }
            $userKey = Constants::LOGIN_TOKEN_KEY . $uuid;
            $redis = Redis::connection();
            $data = $redis->get($userKey);
            if (!$data) {
                return null;
            }
            $loginUserArr = json_decode($data, true);
            return LoginUser::fromArray($loginUserArr);
        } catch (\Exception $e) {
            return null;
        }
    }

    // 验证JWT令牌，从Redis检查是否有效

    public function verifyToken(LoginUser $loginUser)
    {
        $expireTime = $loginUser->expireTime;
        $currentTime = intval(microtime(true) * 1000);
        $refreshThreshold = intval(SysConfigService::getConfigValue('sys.login.tokenRefreshThreshold')) * 60 * 1000;
        if ($expireTime - $currentTime <= $refreshThreshold) {
            $this->refreshToken($loginUser);
        }
    }

    // 刷新JWT令牌

    public function refreshToken(LoginUser $loginUser)
    {
        $loginUser->loginTime = intval(microtime(true) * 1000);
        $loginUser->expireTime = $loginUser->loginTime + $this->expire * 60 * 1000;
        $userKey = Constants::LOGIN_TOKEN_KEY . $loginUser->token;
        $redis = Redis::connection();
        $redis->setex($userKey, $this->expire * 60, json_encode($loginUser->toArray()));
    }

    // 移除JWT令牌（登出）

    public function removeToken($uuid)
    {
        $userKey = Constants::LOGIN_TOKEN_KEY . $uuid;
        $redis = Redis::connection();
        $redis->del($userKey);
    }

    public function getToken($request)
    {
        $authHeader = $request->header('authorization', '');
        if ($authHeader && str_starts_with($authHeader, Constants::TOKEN_PREFIX)) {
            return substr($authHeader, strlen(Constants::TOKEN_PREFIX));
        }
        return null;
    }

    public function getUuidFromToken($request)
    {
        $token = $this->getToken($request);
        if (!$token) {
            return null;
        }
        try {
            $decoded = JWT::decode($token, new Key($this->secret, Constants::JWT_ALGO));
            return $decoded->{Constants::LOGIN_USER_KEY} ?? null;
        } catch (\Exception $e) {
            return null;
        }
    }

    public function setUserAgent(LoginUser $loginUser)
    {
        $loginUser->ipaddr = request()->getRealIp();
        $loginUser->loginLocation = IpService::getLocation($loginUser->ipaddr);
        $ua = request()->header('user-agent', '');
        $loginUser->browser = UserAgentService::getBrowser($ua);
        $loginUser->os = UserAgentService::getOS($ua);
    }

    public function refreshPermissionByRoleId($roleId)
    {
        $redis = Redis::connection();
        $keys = $redis->keys(Constants::LOGIN_TOKEN_KEY . '*');
        $permissionService = new SysPermissionService();
        foreach ($keys as $key) {
            $data = $redis->get($key);
            if (!$data) continue;
            $loginUserArr = json_decode($data, true);
            $loginUser = LoginUser::fromArray($loginUserArr);
            if ($loginUser->isAdmin()) continue;
            $hasRole = false;
            if ($loginUser->user && $loginUser->user->roles) {
                foreach ($loginUser->user->roles as $role) {
                    $roleData = is_array($role) ? $role : $role->toArray();
                    if (isset($roleData['role_id']) && $roleData['role_id'] == $roleId) {
                        $hasRole = true;
                        break;
                    }
                }
            }
            if ($hasRole) {
                // 重新加载用户角色信息（含最新的data_scope）
                $freshUser = \app\model\SysUser::with(['dept', 'roles'])->find($loginUser->userId);
                if ($freshUser) {
                    $loginUser->user = $freshUser;
                }
                $loginUser->permissions = $permissionService->getMenuPermission($loginUser->user);
                $this->refreshToken($loginUser);
            }
        }
    }

    private function fastUUID()
    {
        return sprintf(
            '%04x%04x%04x%04x%04x%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}
