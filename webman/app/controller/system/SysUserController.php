<?php

namespace app\controller\system;

use support\Request;
use app\service\SysUserService;
use app\service\PermissionService;
use app\service\CosService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\SysUser;

/**
 * 系统用户管理控制器
 *
 * 负责用户的增删改查、导入导出、重置密码、状态变更、
 * 个人信息修改、头像上传、角色授权和部门树查询等功能
 */
class SysUserController
{
    // 分页查询用户列表，支持按部门、用户名、手机号、状态等条件筛选
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['login_user'] = $request->loginUser;
        $service = new SysUserService();
        $result = $service->selectUserList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 导出用户数据为Excel文件
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = $request->all();
        $params['login_user'] = $request->loginUser;
        $params['pageSize'] = 10000;
        $service = new SysUserService();
        $result = $service->selectUserList($params);
        $list = $result->items();

        $excelUtil = new ExcelUtil(SysUser::class);
        return $excelUtil->exportExcel($list, '用户数据');
    }

    // 从Excel文件导入用户数据，支持更新已存在用户
    public function importData(Request $request)
    {
        $file = $request->file('file');
        $updateSupport = $request->post('updateSupport', 'false') === 'true' || $request->post('updateSupport', false) === true;

        if (!$file || !$file->isValid()) {
            return AjaxResult::error('上传文件无效');
        }

        $excelUtil = new ExcelUtil(SysUser::class);
        $userList = $excelUtil->importExcel($file);

        $operName = $request->loginUser->user->user_name ?? '';
        $service = new SysUserService();

        try {
            $message = $service->importUser($userList, $updateSupport, $operName);
            return AjaxResult::success($message);
        } catch (\Exception $e) {
            return AjaxResult::error('操作失败，请稍后重试');
        }
    }

    // 下载用户导入模板
    public function importTemplate(Request $request)
    {
        $excelUtil = new ExcelUtil(SysUser::class);
        return $excelUtil->importTemplateExcel('用户数据');
    }

    // 获取用户详情，含角色列表和岗位列表；无ID时返回新增用户所需的角色岗位选项
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->input('user_id', 0);
        if (!$userId) {
            $parts = explode('/', $request->path());
            $userId = end($parts);
        }

        $roleService = new \app\service\SysRoleService();
        $roles = $roleService->selectAllRoles();
        $postService = new \app\service\SysPostService();
        $posts = $postService->selectPostAll();

        if (empty($userId) || $userId === 'system' || $userId === 'user' || !is_numeric($userId)) {
            return AjaxResult::success('', [
                'roles' => $roles,
                'posts' => $posts,
            ]);
        }

        $service = new SysUserService();
        $user = $service->selectUserById($userId);
        if (!$user) {
            return AjaxResult::error('用户不存在');
        }

        $userRoles = $user->roles->pluck('role_id')->toArray();
        $userPosts = $user->posts->pluck('post_id')->toArray();

        $userData = $user->toArray();
        unset($userData['password']);

        return AjaxResult::success('', [
            'data' => $userData,
            'roles' => $roles,
            'posts' => $posts,
            'roleIds' => $userRoles,
            'postIds' => $userPosts,
        ]);
    }

    // 新增用户，校验用户名、手机号、邮箱唯一性
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $service = new SysUserService();

        if ($service->checkUserNameUnique($data['user_name'] ?? '')) {
            return AjaxResult::error('新增用户\'' . ($data['user_name'] ?? '') . '\'失败，登录账号已存在');
        }
        if (!empty($data['phonenumber']) && $service->checkPhoneUnique($data['phonenumber'])) {
            return AjaxResult::error('新增用户\'' . ($data['user_name'] ?? '') . '\'失败，手机号码已存在');
        }
        if (!empty($data['email']) && $service->checkEmailUnique($data['email'])) {
            return AjaxResult::error('新增用户\'' . ($data['user_name'] ?? '') . '\'失败，邮箱已存在');
        }

        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $result = $service->insertUser($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改用户信息，校验用户名、手机号、邮箱唯一性
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $service = new SysUserService();

        if ($service->checkUserNameUnique($data['user_name'] ?? '', $data['user_id'] ?? null)) {
            return AjaxResult::error('修改用户\'' . ($data['user_name'] ?? '') . '\'失败，登录账号已存在');
        }
        if (!empty($data['phonenumber']) && $service->checkPhoneUnique($data['phonenumber'], $data['user_id'] ?? null)) {
            return AjaxResult::error('修改用户\'' . ($data['user_name'] ?? '') . '\'失败，手机号码已存在');
        }
        if (!empty($data['email']) && $service->checkEmailUnique($data['email'], $data['user_id'] ?? null)) {
            return AjaxResult::error('修改用户\'' . ($data['user_name'] ?? '') . '\'失败，邮箱已存在');
        }

        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $result = $service->updateUser($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 批量删除用户，不允许删除超级管理员(ID=1)
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userIds = $request->input('userId', '');
        if (!is_array($userIds)) {
            $userIds = explode(',', $userIds);
        }
        $userIds = array_map('intval', array_filter($userIds));
        if (in_array(1, $userIds)) {
            return AjaxResult::error('不允许删除超级管理员');
        }
        $service = new SysUserService();
        $result = $service->deleteUserByIds($userIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 重置指定用户密码
    public function resetPwd(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:resetPwd')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->post('userId');
        $password = $request->post('password');
        if (empty($userId) || empty($password)) {
            return AjaxResult::error('参数错误');
        }
        if (intval($userId) === 1) {
            return AjaxResult::error('不允许修改超级管理员密码');
        }
        $service = new SysUserService();
        $result = $service->resetPwd($userId, $password);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 变更用户状态（启用/停用）
    public function changeStatus(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->post('userId');
        $status = $request->post('status');
        if (intval($userId) === 1) {
            return AjaxResult::error('不允许修改超级管理员状态');
        }
        $service = new SysUserService();
        $result = $service->changeStatus($userId, $status);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 获取当前登录用户的个人信息，含角色组和岗位组
    public function profile(Request $request)
    {
        $loginUser = $request->loginUser;
        $service = new SysUserService();
        $user = $service->selectUserById($loginUser->userId);
        if (!$user) {
            return AjaxResult::error('用户不存在');
        }
        $userData = $user->toArray();
        unset($userData['password']);
        $roleGroup = $user->roles->pluck('role_name')->implode(',');
        $postGroup = $user->posts->pluck('post_name')->implode(',');
        return AjaxResult::success('', [
            'data' => $userData,
            'roleGroup' => $roleGroup,
            'postGroup' => $postGroup,
        ]);
    }

    // 修改当前登录用户的个人信息，校验手机号和邮箱唯一性
    public function updateProfile(Request $request)
    {
        $loginUser = $request->loginUser;
        $data = convert_to_snake_case($request->post());
        $service = new SysUserService();

        if (!empty($data['phonenumber']) && $service->checkPhoneUnique($data['phonenumber'], $loginUser->userId)) {
            return AjaxResult::error('修改用户失败，手机号码已存在');
        }
        if (!empty($data['email']) && $service->checkEmailUnique($data['email'], $loginUser->userId)) {
            return AjaxResult::error('修改用户失败，邮箱已存在');
        }

        $result = $service->updateUserProfile($loginUser->userId, $data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改当前登录用户密码，需验证旧密码
    public function updatePwd(Request $request)
    {
        $loginUser = $request->loginUser;
        $oldPassword = $request->post('oldPassword', '');
        $newPassword = $request->post('newPassword', '');

        if (empty($oldPassword) || empty($newPassword)) {
            return AjaxResult::error('参数错误');
        }

        $user = \app\model\SysUser::find($loginUser->userId);
        if (!\app\service\PasswordService::verify($oldPassword, $user->password)) {
            return AjaxResult::error('修改密码失败，旧密码错误');
        }

        $service = new SysUserService();
        $result = $service->resetPwd($loginUser->userId, $newPassword);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 上传当前登录用户头像，支持COS云存储和本地存储
    public function avatar(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $loginUser = $request->loginUser;
        $file = $request->file('avatarfile');
        if (!$file || !$file->isValid()) {
            return AjaxResult::error('上传图片异常，请联系管理员');
        }

        $ext = $file->getUploadExtension() ?: 'png';
        $allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        if (!in_array(strtolower($ext), $allowedExts, true)) {
            return AjaxResult::error('不支持的图片格式');
        }
        $filename = md5(uniqid()) . '.' . $ext;

        $cosService = new CosService();
        if ($cosService->isEnabled()) {
            $cosPath = 'avatar/' . $filename;
            $avatarUrl = $cosService->uploadFile($file, $cosPath);
            if ($avatarUrl) {
                SysUser::where('user_id', $loginUser->userId)->update(['avatar' => $avatarUrl]);
                return AjaxResult::success('', ['imgUrl' => $avatarUrl]);
            }
            return AjaxResult::error('COS上传失败');
        }

        $uploadDir = public_path() . '/profile/avatar/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        $file->move($uploadDir . $filename);

        $avatarUrl = '/profile/avatar/' . $filename;
        SysUser::where('user_id', $loginUser->userId)->update(['avatar' => $avatarUrl]);

        return AjaxResult::success('', ['imgUrl' => $avatarUrl]);
    }

    // 获取用户角色授权页面数据（用户信息+所有角色列表）
    public function authRole(Request $request)
    {
        $parts = explode('/', $request->path());
        $userId = intval($parts[array_search('authRole', $parts) + 1] ?? 0);
        if (!$userId) {
            return AjaxResult::error('参数错误');
        }

        $userService = new SysUserService();
        $user = $userService->selectUserById($userId);
        if (!$user) {
            return AjaxResult::error('用户不存在');
        }

        $roleService = new \app\service\SysRoleService();
        $roles = $roleService->selectAllRoles();
        // 标记用户已分配的角色
        $userRoleIds = \app\model\SysUserRole::where('user_id', $userId)->pluck('role_id')->toArray();
        $rolesArray = $roles->toArray();
        foreach ($rolesArray as &$role) {
            $role['flag'] = in_array($role['role_id'], $userRoleIds);
        }
        unset($role);

        $userData = $user->toArray();
        unset($userData['password']);

        return AjaxResult::success('', [
            'user' => $userData,
            'roles' => $rolesArray,
        ]);
    }

    // 保存用户角色授权关系
    public function insertAuthRole(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'system:user:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $userId = $request->input('userId');
        $roleIds = $request->input('roleIds', []);
        if (is_string($roleIds)) {
            $roleIds = explode(',', $roleIds);
        }
        if (!$userId) {
            return AjaxResult::error('参数错误');
        }

        // 直接处理角色关联，避免 updateUser 清空岗位
        \app\model\SysUserRole::where('user_id', $userId)->delete();
        if (!empty($roleIds)) {
            $data = [];
            foreach ($roleIds as $roleId) {
                if ($roleId) {
                    $data[] = ['user_id' => $userId, 'role_id' => $roleId];
                }
            }
            if (!empty($data)) {
                \app\model\SysUserRole::insert($data);
            }
        }
        return AjaxResult::success();
    }

    // 获取部门树下拉选择数据
    public function deptTree(Request $request)
    {
        $deptService = new \app\service\SysDeptService();
        $depts = $deptService->selectDeptList([]);
        return AjaxResult::success($deptService->buildDeptTreeSelect($depts, 0));
    }
}
