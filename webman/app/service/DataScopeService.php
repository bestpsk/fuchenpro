<?php

namespace app\service;

use app\model\SysUser;
use app\model\SysDept;
use app\model\SysRoleDept;
use app\model\BizEnterprise;

/**
 * 数据权限服务层，根据用户角色的数据权限范围自动为查询添加过滤条件
 */
class DataScopeService
{
    // 将数据权限条件应用到查询构建器
    public static function applyDataScope($query, $loginUser, $deptAlias = 'd', $userAlias = 'u')
    {
        if ($loginUser->isAdmin()) {
            return $query;
        }

        $roles = $loginUser->user ? $loginUser->user->roles : [];
        if (empty($roles)) {
            return $query->whereRaw('1 = 0');
        }

        $conditions = [];
        foreach ($roles as $role) {
            $dataScope = self::getRoleDataScope($role);
            $roleId = self::getRoleId($role);

            switch ($dataScope) {
                case '1':
                    return $query;
                case '2':
                    $deptIds = SysRoleDept::where('role_id', $roleId)
                        ->pluck('dept_id')
                        ->toArray();
                    $conditions[] = [$deptAlias . '.dept_id', 'in', $deptIds];
                    break;
                case '3':
                    $conditions[] = [$deptAlias . '.dept_id', '=', $loginUser->deptId];
                    break;
                case '4':
                    $dept = SysDept::find($loginUser->deptId);
                    if ($dept) {
                        $conditions[] = function ($q) use ($deptAlias, $dept, $loginUser) {
                            $q->where($deptAlias . '.dept_id', $loginUser->deptId)
                              ->orWhere($deptAlias . '.dept_id', 'in', function ($subQ) use ($dept) {
                                  $subQ->select('dept_id')->from('sys_dept')
                                       ->whereRaw("find_in_set(?, ancestors)", [$dept->dept_id]);
                              });
                        };
                    }
                    break;
                case '5':
                    $conditions[] = [$userAlias . '.user_id', '=', $loginUser->userId];
                    break;
            }
        }

        if (!empty($conditions)) {
            $query->where(function ($q) use ($conditions) {
                foreach ($conditions as $condition) {
                    if (is_callable($condition)) {
                        $condition($q);
                    } elseif ($condition[1] === 'in') {
                        $q->orWhereIn($condition[0], $condition[2]);
                    } else {
                        $q->orWhere($condition[0], $condition[1], $condition[2]);
                    }
                }
            });
        }

        return $query;
    }

    /**
     * 统一应用数据权限过滤
     * @param mixed $query 查询构建器
     * @param mixed $loginUser 登录用户
     * @param string $userField 过滤字段名（如 creator_user_id, operator_user_id, enterprise_id）
     * @param string $scopeType 过滤模式：'user'=按用户ID直接过滤, 'enterprise'=通过enterprise_id间接过滤, 'username'=按用户名过滤
     * @return mixed
     */
    public static function applyUserScope($query, $loginUser, $userField, $scopeType = 'user')
    {
        if (empty($loginUser) || $loginUser->isAdmin()) {
            return $query;
        }

        $visibleUserIds = self::getVisibleUserIds($loginUser);

        switch ($scopeType) {
            case 'enterprise':
                $enterpriseIds = BizEnterprise::where(function($q) use ($visibleUserIds) {
                    foreach ($visibleUserIds as $uid) {
                        $q->orWhereRaw('FIND_IN_SET(?, server_user_id)', [$uid]);
                    }
                })->pluck('enterprise_id')->toArray();
                return $query->whereIn($userField, $enterpriseIds);

            case 'username':
                $visibleUserNames = SysUser::whereIn('user_id', $visibleUserIds)
                    ->pluck('user_name')->toArray();
                return $query->whereIn($userField, $visibleUserNames);

            case 'user':
            default:
                return $query->whereIn($userField, $visibleUserIds);
        }
    }

    /**
     * 获取当前用户可见的所有用户ID列表（用于统计报表等场景）
     * 多角色时取并集（OR策略）
     */
    public static function getVisibleUserIds($loginUser)
    {
        $userId = $loginUser->userId;

        if ($loginUser->isAdmin()) {
            $allUserIds = SysUser::where('del_flag', '0')->where('status', '0')->pluck('user_id')->toArray();
            return !empty($allUserIds) ? $allUserIds : [$userId];
        }

        $roles = $loginUser->user ? $loginUser->user->roles : [];
        if (empty($roles)) {
            return [$userId];
        }

        $allUserIds = [];

        foreach ($roles as $role) {
            $dataScope = self::getRoleDataScope($role);
            $roleId = self::getRoleId($role);

            switch ($dataScope) {
                case '1':
                    $allUserIds = SysUser::where('del_flag', '0')->where('status', '0')->pluck('user_id')->toArray();
                    break 2;
                case '2':
                    $deptIds = SysRoleDept::where('role_id', $roleId)->pluck('dept_id')->toArray();
                    if (!empty($deptIds)) {
                        $userIds = SysUser::whereIn('dept_id', $deptIds)->where('del_flag', '0')->pluck('user_id')->toArray();
                        $allUserIds = array_merge($allUserIds, $userIds);
                    }
                    break;
                case '3':
                    $userIds = SysUser::where('dept_id', $loginUser->deptId)->where('del_flag', '0')->pluck('user_id')->toArray();
                    $allUserIds = array_merge($allUserIds, $userIds);
                    break;
                case '4':
                    $deptIds = SysDept::where('dept_id', $loginUser->deptId)
                        ->orWhereRaw("FIND_IN_SET(?, ancestors)", [$loginUser->deptId])
                        ->pluck('dept_id')->toArray();
                    $userIds = SysUser::whereIn('dept_id', $deptIds)->where('del_flag', '0')->pluck('user_id')->toArray();
                    $allUserIds = array_merge($allUserIds, $userIds);
                    break;
                case '5':
                default:
                    $allUserIds[] = $userId;
                    break;
            }
        }

        $allUserIds = array_unique($allUserIds);
        return !empty($allUserIds) ? $allUserIds : [$userId];
    }

    // 从角色数据中获取data_scope（兼容数组和对象）
    private static function getRoleDataScope($role)
    {
        if (is_array($role)) {
            return $role['data_scope'] ?? '5';
        }
        return $role->data_scope ?? '5';
    }

    // 从角色数据中获取role_id（兼容数组和对象）
    private static function getRoleId($role)
    {
        if (is_array($role)) {
            return $role['role_id'] ?? 0;
        }
        return $role->role_id ?? 0;
    }
}
