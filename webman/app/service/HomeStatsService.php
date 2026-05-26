<?php

namespace app\service;

use app\model\BizSalesOrder;
use app\model\BizOperationRecord;
use app\model\SysUser;
use app\model\SysDept;
use app\model\SysRoleDept;

class HomeStatsService
{
    public static function getTodayStats($loginUser)
    {
        $today = date('Y-m-d');
        $monthStart = date('Y-m-01');

        $userIds = self::getVisibleUserIds($loginUser);

        \support\Log::info('HomeStats调试', [
            'userId' => $loginUser->userId,
            'isAdmin' => $loginUser->isAdmin(),
            'visibleUserIds' => $userIds,
            'today' => $today,
            'monthStart' => $monthStart,
        ]);

        $todayDealCustomers = BizSalesOrder::whereIn('order_status', ['1', '3'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->distinct()->count('customer_id');

        $monthDealCustomers = BizSalesOrder::whereIn('order_status', ['1', '3'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->distinct()->count('customer_id');

        $todayDealAmount = BizSalesOrder::whereIn('order_status', ['1', '3'])
            ->whereIn('creator_user_id', $userIds)
            ->whereDate('create_time', $today)
            ->sum('deal_amount');

        $monthDealAmount = BizSalesOrder::whereIn('order_status', ['1', '3'])
            ->whereIn('creator_user_id', $userIds)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->sum('deal_amount');

        $todayOperationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->whereDate('operation_date', $today)
            ->distinct()->count('customer_id');

        $monthOperationCustomers = BizOperationRecord::whereIn('operator_user_id', $userIds)
            ->where('operation_date', '>=', $monthStart)
            ->distinct()->count('customer_id');

        \support\Log::info('HomeStats结果', [
            'todayDealCustomers' => $todayDealCustomers,
            'monthDealCustomers' => $monthDealCustomers,
            'todayDealAmount' => $todayDealAmount,
            'monthDealAmount' => $monthDealAmount,
            'todayOperationCustomers' => $todayOperationCustomers,
            'monthOperationCustomers' => $monthOperationCustomers,
        ]);

        return [
            'dealCustomerCount' => ['today' => $todayDealCustomers, 'month' => $monthDealCustomers],
            'dealAmount' => ['today' => $todayDealAmount, 'month' => $monthDealAmount],
            'operationCustomerCount' => ['today' => $todayOperationCustomers, 'month' => $monthOperationCustomers],
        ];
    }

    private static function getVisibleUserIds($loginUser)
    {
        $userId = $loginUser->userId;

        if ($loginUser->isAdmin()) {
            $allUserIds = SysUser::where('del_flag', '0')->where('status', '0')->pluck('user_id')->toArray();
            return !empty($allUserIds) ? $allUserIds : [$userId];
        }

        $dataScope = self::getUserDataScope($loginUser);

        switch ($dataScope) {
            case '1':
                $allUserIds = SysUser::where('del_flag', '0')->where('status', '0')->pluck('user_id')->toArray();
                return !empty($allUserIds) ? $allUserIds : [$userId];

            case '2':
                $deptIds = self::getCustomDeptIds($loginUser);
                if (empty($deptIds)) return [$userId];
                $userIds = SysUser::whereIn('dept_id', $deptIds)->where('del_flag', '0')->pluck('user_id')->toArray();
                return !empty($userIds) ? $userIds : [$userId];

            case '3':
                $userIds = SysUser::where('dept_id', $loginUser->deptId)->where('del_flag', '0')->pluck('user_id')->toArray();
                return !empty($userIds) ? $userIds : [$userId];

            case '4':
                $deptIds = SysDept::where('dept_id', $loginUser->deptId)
                    ->orWhereRaw("FIND_IN_SET(?, ancestors)", [$loginUser->deptId])
                    ->pluck('dept_id')->toArray();
                $userIds = SysUser::whereIn('dept_id', $deptIds)->where('del_flag', '0')->pluck('user_id')->toArray();
                return !empty($userIds) ? $userIds : [$userId];

            case '5':
            default:
                return [$userId];
        }
    }

    private static function getUserDataScope($loginUser)
    {
        $roles = $loginUser->user->roles ?? [];
        $minScope = '5';
        foreach ($roles as $role) {
            $dataScope = is_array($role) ? ($role['data_scope'] ?? '5') : ($role->data_scope ?? '5');
            if ($dataScope < $minScope) {
                $minScope = $dataScope;
            }
        }
        return $minScope;
    }

    private static function getCustomDeptIds($loginUser)
    {
        $roles = $loginUser->user->roles ?? [];
        $roleIds = [];
        foreach ($roles as $role) {
            $roleId = is_array($role) ? ($role['role_id'] ?? null) : ($role->role_id ?? null);
            if ($roleId !== null) {
                $roleIds[] = $roleId;
            }
        }
        if (empty($roleIds)) return [];
        return SysRoleDept::whereIn('role_id', $roleIds)->pluck('dept_id')->toArray();
    }
}
