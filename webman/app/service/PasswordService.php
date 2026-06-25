<?php

namespace app\service;

use support\Redis;
use app\common\Constants;

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

        $maxRetryCount = (int)SysConfigService::selectConfigByKey('sys.account.maxRetryCount') ?: Constants::PWD_ERR_MAX_COUNT;
        $lockTime = (int)SysConfigService::selectConfigByKey('sys.account.lockTime') ?: Constants::PWD_ERR_LOCK_TIME;

        if ($retryCount >= $maxRetryCount) {
            $ttl = $redis->ttl($retryCountKey);
            $minutes = max(1, ceil($ttl / 60));
            return "密码错误次数过多，账户锁定{$minutes}分钟";
        }

        if (!self::verify($password, $loginUser->password)) {
            $retryCount++;
            $redis->setex($retryCountKey, $lockTime * 60, $retryCount);
            $remaining = $maxRetryCount - $retryCount;
            if ($remaining > 0) {
                return "密码错误，还剩{$remaining}次机会";
            }
            return "密码错误次数过多，账户锁定{$lockTime}分钟";
        }

        $redis->del($retryCountKey);
        return true;
    }

    public static function isDefaultPassword($password)
    {
        $initPassword = SysConfigService::selectConfigByKey('sys.user.initPassword');
        return $password === $initPassword;
    }
}
