<?php

namespace app\service;

use support\Redis;
use app\common\Constants;
use app\service\SysConfigService;

/**
 * 密码服务层，负责密码加密、验证和密码错误锁定策略
 */
class PasswordService
{
    public static function encrypt($password)
    {
        return password_hash($password, PASSWORD_BCRYPT);
    }

    public static function verify($password, $hash)
    {
        return password_verify($password, $hash);
    }

    public static function validate($loginUser, $password)
    {
        $redis = Redis::connection();
        $retryCountKey = Constants::PWD_ERR_CNT_KEY . $loginUser->user_name;
        $retryCount = (int)$redis->get($retryCountKey);

        $pwdErrMaxCount = intval(SysConfigService::getConfigValue('sys.security.pwdErrMaxCount'));
        $pwdErrLockTime = intval(SysConfigService::getConfigValue('sys.security.pwdErrLockTime'));

        if ($retryCount >= $pwdErrMaxCount) {
            $ttl = $redis->ttl($retryCountKey);
            $minutes = max(1, ceil($ttl / 60));
            return "密码错误次数过多，账户锁定{$minutes}分钟";
        }

        if (!self::verify($password, $loginUser->password)) {
            $retryCount++;
            $redis->setex($retryCountKey, $pwdErrLockTime * 60, $retryCount);
            $remaining = $pwdErrMaxCount - $retryCount;
            if ($remaining > 0) {
                return "密码错误，还剩{$remaining}次机会";
            }
            return "密码错误次数过多，账户锁定{$pwdErrLockTime}分钟";
        }

        $redis->del($retryCountKey);
        return true;
    }

    public static function isDefaultPassword($password)
    {
        $initPassword = SysConfigService::selectConfigByKey('sys.security.initPassword');
        return $password === $initPassword;
    }
}
