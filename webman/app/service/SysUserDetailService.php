<?php

namespace app\service;

use app\model\SysUserDetail;

/**
 * 用户详情服务层，处理用户扩展详情的查询、新增和更新
 */
class SysUserDetailService
{
    // 根据用户ID查询用户详情
    public function selectDetailByUserId($userId)
    {
        return SysUserDetail::where('user_id', $userId)->first();
    }

    // 新增用户详情

    public function insertDetail($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysUserDetail::create($data);
    }

    // 更新用户详情信息

    public function updateDetail($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        $detail = null;
        if (isset($data['detail_id'])) {
            $detail = SysUserDetail::find($data['detail_id']);
        } elseif (isset($data['user_id'])) {
            $detail = SysUserDetail::where('user_id', $data['user_id'])->first();
        }
        if ($detail) {
            $detail->fill($data)->save();
            return true;
        }
        // 不存在则新增
        if (isset($data['user_id'])) {
            return $this->insertDetail($data);
        }
        return false;
    }

    public function deleteDetailByUserId($userId)
    {
        return SysUserDetail::where('user_id', $userId)->delete();
    }

    public function setWelcomeSlogan($userId, $welcomeSlogan)
    {
        $detail = SysUserDetail::where('user_id', $userId)->first();
        if ($detail) {
            return SysUserDetail::where('user_id', $userId)->update([
                'welcome_slogan' => $welcomeSlogan,
                'update_time' => date('Y-m-d H:i:s'),
            ]);
        }
        return SysUserDetail::create([
            'user_id' => $userId,
            'welcome_slogan' => $welcomeSlogan,
            'create_time' => date('Y-m-d H:i:s'),
        ]);
    }
}
