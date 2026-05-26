<?php

namespace app\common;

use app\model\SysUser;

/**
 * 登录用户信息模型
 *
 * 用于在请求上下文中传递已认证用户的信息，包括用户ID、部门ID、
 * 登录凭证、登录时间、过期时间、IP地址、浏览器和操作系统信息、权限列表等。
 * 实例会被序列化存储在Redis中，并通过JWT令牌关联
 */
class LoginUser
{
    public $userId = 0;            // 用户ID
    public $deptId = 0;            // 部门ID
    public $token = '';            // 登录凭证UUID（用于Redis缓存键）
    public $loginTime = 0;         // 登录时间（毫秒时间戳）
    public $expireTime = 0;        // 过期时间（毫秒时间戳）
    public $ipaddr = '';           // 登录IP地址
    public $loginLocation = '';    // 登录地理位置
    public $browser = '';          // 浏览器类型
    public $os = '';               // 操作系统类型
    public $permissions = [];      // 用户权限标识列表
    public $user = null;           // 关联的用户模型实例

    public function __construct(array $data = [])
    {
        foreach ($data as $key => $value) {
            if (property_exists($this, $key)) {
                $this->$key = $value;
            }
        }
    }

    // 判断当前用户是否为超级管理员（userId=1或用户模型标记为管理员）
    public function isAdmin()
    {
        return $this->userId == 1 || ($this->user && method_exists($this->user, 'isAdmin') && $this->user->isAdmin());
    }

    // 将登录用户信息序列化为数组，用于Redis存储
    public function toArray()
    {
        return [
            'userId' => $this->userId,
            'deptId' => $this->deptId,
            'token' => $this->token,
            'loginTime' => $this->loginTime,
            'expireTime' => $this->expireTime,
            'ipaddr' => $this->ipaddr,
            'loginLocation' => $this->loginLocation,
            'browser' => $this->browser,
            'os' => $this->os,
            'permissions' => is_array($this->permissions) ? array_values($this->permissions) : [],
            'user' => $this->user ? $this->user->toArray() : null,
        ];
    }

    // 从数组反序列化为LoginUser实例，自动将用户数据还原为SysUser模型
    public static function fromArray(array $data)
    {
        $loginUser = new self();
        foreach ($data as $key => $value) {
            if (property_exists($loginUser, $key)) {
                $loginUser->$key = $value;
            }
        }

        if (is_array($loginUser->user) && !empty($loginUser->user)) {
            $userModel = new SysUser();
            $userModel->setRawAttributes($loginUser->user, true);
            $userModel->exists = !empty($loginUser->user['user_id']);
            $loginUser->user = $userModel;
        }

        return $loginUser;
    }
}
