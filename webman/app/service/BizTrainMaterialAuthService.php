<?php

namespace app\service;

use app\model\BizTrainMaterialAuth;
use app\model\BizTrainMaterial;
use app\model\SysUser;
use app\model\SysDept;
use support\Db;

/**
 * 培训材料授权服务层
 * 默认无授权记录=全员可见，有授权记录=仅授权用户/部门可见
 */
class BizTrainMaterialAuthService
{
    // 获取材料的授权配置
    public function getAuthConfig($materialId)
    {
        $auths = BizTrainMaterialAuth::where('material_id', $materialId)->get();

        if ($auths->isEmpty()) {
            return [
                'material_id' => $materialId,
                'auth_type' => 'all',
                'user_ids' => [],
                'dept_ids' => [],
                'user_names' => [],
                'dept_names' => [],
            ];
        }

        $userIds = $auths->where('target_type', '1')->pluck('target_id')->toArray();
        $deptIds = $auths->where('target_type', '2')->pluck('target_id')->toArray();

        $userNames = SysUser::whereIn('user_id', $userIds)->pluck('nick_name', 'user_id')->toArray();
        $deptNames = SysDept::whereIn('dept_id', $deptIds)->pluck('dept_name', 'dept_id')->toArray();

        return [
            'material_id' => $materialId,
            'auth_type' => 'custom',
            'user_ids' => array_map('strval', $userIds),
            'dept_ids' => array_map('strval', $deptIds),
            'user_names' => $userNames,
            'dept_names' => $deptNames,
        ];
    }

    // 保存材料的授权配置
    public function saveAuthConfig($materialId, $userIds, $deptIds, $createBy = '')
    {
        BizTrainMaterialAuth::where('material_id', $materialId)->delete();

        $userIds = array_filter(array_map('intval', $userIds ?? []));
        $deptIds = array_filter(array_map('intval', $deptIds ?? []));

        if (empty($userIds) && empty($deptIds)) {
            return true; // 全员可见，不插入记录
        }

        $now = date('Y-m-d H:i:s');
        $rows = [];
        foreach ($userIds as $uid) {
            $rows[] = [
                'material_id' => $materialId,
                'target_type' => '1',
                'target_id' => $uid,
                'create_by' => $createBy,
                'create_time' => $now,
            ];
        }
        foreach ($deptIds as $did) {
            $rows[] = [
                'material_id' => $materialId,
                'target_type' => '2',
                'target_id' => $did,
                'create_by' => $createBy,
                'create_time' => $now,
            ];
        }

        return BizTrainMaterialAuth::insert($rows);
    }

    // 获取用户可见的材料ID列表
    // 返回 null 表示全部可见（无任何授权记录时）
    public function getAuthorizedMaterialIds($userId)
    {
        // 有授权记录的材料ID集合
        $restrictedMaterialIds = BizTrainMaterialAuth::distinct()
            ->pluck('material_id')
            ->toArray();

        if (empty($restrictedMaterialIds)) {
            return null; // 无任何授权记录，全员可见
        }

        // 用户所在部门（含子部门）
        $user = SysUser::find($userId);
        $deptIds = [];
        if ($user && $user->dept_id) {
            $deptIds[] = $user->dept_id;
            // 含子部门
            $childDepts = SysDept::whereRaw('FIND_IN_SET(?, ancestors)', [$user->dept_id])->pluck('dept_id')->toArray();
            $deptIds = array_merge($deptIds, $childDepts);
        }

        // 用户被直接授权的材料
        $userAuthMaterialIds = BizTrainMaterialAuth::where('target_type', '1')
            ->where('target_id', $userId)
            ->pluck('material_id')
            ->toArray();

        // 用户所在部门被授权的材料
        $deptAuthMaterialIds = [];
        if (!empty($deptIds)) {
            $deptAuthMaterialIds = BizTrainMaterialAuth::where('target_type', '2')
                ->whereIn('target_id', $deptIds)
                ->pluck('material_id')
                ->toArray();
        }

        $authorizedIds = array_unique(array_merge($userAuthMaterialIds, $deptAuthMaterialIds));

        // 无限制的材料 + 被授权的材料
        $allMaterialIds = BizTrainMaterial::where('del_flag', '0')
            ->where('status', '0')
            ->whereNotIn('material_id', $restrictedMaterialIds)
            ->orWhereIn('material_id', $authorizedIds)
            ->pluck('material_id')
            ->toArray();

        return $allMaterialIds;
    }

    // 检查用户是否能访问指定材料
    public function checkMaterialAccess($materialId, $userId)
    {
        $authCount = BizTrainMaterialAuth::where('material_id', $materialId)->count();
        if ($authCount === 0) {
            return true; // 无授权记录，全员可见
        }

        // 检查用户是否被直接授权
        $userAuth = BizTrainMaterialAuth::where('material_id', $materialId)
            ->where('target_type', '1')
            ->where('target_id', $userId)
            ->exists();
        if ($userAuth) {
            return true;
        }

        // 检查用户所在部门是否被授权
        $user = SysUser::find($userId);
        if ($user && $user->dept_id) {
            $deptIds = [$user->dept_id];
            $childDepts = SysDept::whereRaw('FIND_IN_SET(?, ancestors)', [$user->dept_id])->pluck('dept_id')->toArray();
            $deptIds = array_merge($deptIds, $childDepts);

            $deptAuth = BizTrainMaterialAuth::where('material_id', $materialId)
                ->where('target_type', '2')
                ->whereIn('target_id', $deptIds)
                ->exists();
            if ($deptAuth) {
                return true;
            }
        }

        return false;
    }
}
