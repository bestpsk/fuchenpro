<?php

namespace app\controller;

use support\Request;
use app\service\TokenService;
use app\service\CaptchaService;
use app\service\SysUserService;
use app\service\SysPermissionService;
use app\service\SysLogininforService;
use app\service\SysMenuService;
use app\service\PasswordService;
use app\service\IpService;
use app\service\UserAgentService;
use app\common\AjaxResult;
use app\common\Constants;
use app\common\LoginUser;
use app\common\Helpers;
use app\model\SysUser;

/**
 * 系统登录认证控制器
 *
 * 负责用户登录验证（含验证码校验、IP黑名单检查、密码错误锁定）、
 * 令牌生成与销毁、获取当前登录用户信息及路由菜单、锁屏解锁等功能
 */
class SysLoginController
{
    // 用户登录：校验验证码、IP黑名单、用户状态和密码，生成JWT令牌并记录登录日志
    public function login(Request $request)
    {
        $username = $request->post('username', '');
        $password = $request->post('password', '');
        $code = $request->post('code', '');
        $uuid = $request->post('uuid', '');
        $loginSource = $request->header('x-login-source', 'web') === 'app' ? 'app' : 'web';

        $captchaEnabled = \app\service\SysConfigService::selectCaptchaEnabled();
        if ($captchaEnabled) {
            if (empty($code) || empty($uuid)) {
                return AjaxResult::error('验证码不能为空');
            }
            if (!CaptchaService::validateCaptcha($code, $uuid)) {
                return AjaxResult::error('验证码错误或已过期');
            }
        }

        if (empty($username) || empty($password)) {
            return AjaxResult::error('用户名/密码不能为空');
        }

        $blackIPList = \app\service\SysConfigService::selectConfigByKey('sys.login.blackIPList');
        if (!empty($blackIPList)) {
            $ip = $request->getRealIp();
            $blackList = array_map('trim', explode(';', $blackIPList));
            foreach ($blackList as $pattern) {
                if (fnmatch($pattern, $ip)) {
                    return AjaxResult::error('很遗憾，访问已被禁止');
                }
            }
        }

        $userService = new SysUserService();
        $user = $userService->selectUserByUserName($username);

        if (!$user) {
            $this->recordLogininfor($username, false, '用户不存在', $loginSource);
            return AjaxResult::error('用户不存在');
        }

        if ($user->status === '1') {
            $this->recordLogininfor($username, false, '用户已被停用', $loginSource);
            return AjaxResult::error('用户已被停用，请联系管理员');
        }

        $pwdResult = PasswordService::validate($user, $password);
        if ($pwdResult !== true) {
            $this->recordLogininfor($username, false, $pwdResult, $loginSource);
            return AjaxResult::error($pwdResult);
        }

        $loginUser = new LoginUser();
        $loginUser->userId = $user->user_id;
        $loginUser->deptId = $user->dept_id;
        $loginUser->user = $user;

        $permissionService = new SysPermissionService();
        $loginUser->permissions = $permissionService->getMenuPermission($user);

        $tokenService = new TokenService();
        $token = $tokenService->createToken($loginUser);

        SysUser::where('user_id', $user->user_id)->update([
            'login_ip' => $request->getRealIp(),
            'login_date' => date('Y-m-d H:i:s'),
        ]);

        $this->recordLogininfor($username, true, '登录成功', $loginSource);

        return AjaxResult::success('操作成功', ['token' => $token]);
    }

    // 用户登出：从Redis中删除登录令牌
    public function logout(Request $request)
    {
        $tokenService = new TokenService();
        $uuid = $tokenService->getUuidFromToken($request);
        if ($uuid) {
            $tokenService->removeToken($uuid);
        }
        return AjaxResult::success('退出成功');
    }

    // 获取当前登录用户信息，包括用户数据、角色列表、权限列表和密码策略状态
    public function getInfo(Request $request)
    {
        $loginUser = $request->loginUser;
        if (!$loginUser) {
            return AjaxResult::error('未登录', Constants::UNAUTHORIZED);
        }

        $userService = new SysUserService();
        $user = $userService->selectUserById($loginUser->userId);
        if (!$user) {
            return AjaxResult::error('用户不存在');
        }

        $permissionService = new SysPermissionService();
        $roles = $permissionService->getRolePermission($user);
        $permissions = $loginUser->permissions;

        $pwdChrtype = (int)\app\service\SysConfigService::selectConfigByKey('sys.account.chrtype');
        $isDefaultModifyPwd = (int)\app\service\SysConfigService::selectConfigByKey('sys.account.initPasswordModify');
        $passwordValidateDays = (int)\app\service\SysConfigService::selectConfigByKey('sys.account.passwordValidateDays');

        $isDefaultModifyPwdFlag = false;
        if ($isDefaultModifyPwd === 1) {
            $initPwd = \app\service\SysConfigService::getConfigValue('sys.security.initPassword');
            if (PasswordService::verify($initPwd, $user->password)) {
                $isDefaultModifyPwdFlag = true;
            }
        }

        $isPasswordExpired = false;
        if ($passwordValidateDays > 0 && $user->pwd_update_date) {
            $daysDiff = (time() - strtotime($user->pwd_update_date)) / 86400;
            if ($daysDiff > $passwordValidateDays) {
                $isPasswordExpired = true;
            }
        }

        $userData = $user->toArray();
        unset($userData['password']);
        $userData = Helpers::userToCamelCase($userData);

        // 添加部门名称
        if (!empty($userData['deptId'])) {
            $dept = \app\model\SysDept::find($userData['deptId']);
            $userData['deptName'] = $dept ? $dept->dept_name : '';
        } else {
            $userData['deptName'] = '';
        }

        return AjaxResult::success('', [
            'user' => $userData,
            'roles' => array_values($roles),
            'permissions' => array_values($permissions),
            'pwdChrtype' => $pwdChrtype,
            'isDefaultModifyPwd' => $isDefaultModifyPwdFlag,
            'isPasswordExpired' => $isPasswordExpired,
        ]);
    }

    // 获取当前登录用户的路由菜单树，用于前端动态路由渲染
    public function getRouters(Request $request)
    {
        $loginUser = $request->loginUser;
        if (!$loginUser) {
            return AjaxResult::error('未登录', Constants::UNAUTHORIZED);
        }

        $menuService = new SysMenuService();
        $menus = $menuService->selectMenuTreeByUserId($loginUser->userId);
        $routers = $menuService->buildMenus($menus);

        return json(['code' => 200, 'msg' => '', 'data' => $routers]);
    }

    // 锁屏解锁：验证当前登录用户密码是否正确
    public function unlockscreen(Request $request)
    {
        $password = $request->post('password', '');
        $loginUser = $request->loginUser;
        if (!$loginUser) {
            return AjaxResult::error('未登录', Constants::UNAUTHORIZED);
        }

        $user = SysUser::find($loginUser->userId);
        if (!$user || !PasswordService::verify($password, $user->password)) {
            return AjaxResult::error('密码错误');
        }

        return AjaxResult::success();
    }

    // 记录登录日志（用户名、IP地址、浏览器、操作系统、登录结果）
    private function recordLogininfor($username, $success, $msg, $source = 'web')
    {
        try {
            $request = request();
            $ip = $request->getRealIp();
            $ua = $request->header('user-agent', '');

            $logininforService = new SysLogininforService();
            $logininforService->insertLogininfor([
                'user_name' => $username,
                'ipaddr' => $ip,
                'login_location' => IpService::getLocation($ip),
                'browser' => UserAgentService::getBrowser($ua),
                'os' => UserAgentService::getOS($ua),
                'status' => $success ? '0' : '1',
                'msg' => $msg,
                'login_source' => $source,
                'login_time' => date('Y-m-d H:i:s'),
            ]);
        } catch (\Exception $e) {
        }
    }
}
