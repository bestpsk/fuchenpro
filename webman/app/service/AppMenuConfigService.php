<?php

namespace app\service;

use app\model\AppMenuConfig;

class AppMenuConfigService
{
    public function list($params = [])
    {
        $query = AppMenuConfig::where('status', '0');

        if (!empty($params['group_key'])) {
            $query->where('group_key', $params['group_key']);
        }
        if (!empty($params['title'])) {
            $query->where('title', 'like', '%' . $params['title'] . '%');
        }
        if (isset($params['visible']) && $params['visible'] !== '') {
            $query->where('visible', $params['visible']);
        }

        return $query->orderBy('group_sort', 'asc')
            ->orderBy('sort_order', 'asc')
            ->get();
    }

    public function getGroupedMenus($userId = null)
    {
        $query = AppMenuConfig::where('status', '0')
            ->where('visible', 1);

        if ($userId !== null) {
            $user = \app\model\SysUser::find($userId);
            if ($user && !$user->isAdmin()) {
                $permService = new SysPermissionService();
                $userPerms = $permService->getMenuPermission($user);
                $query->where(function ($q) use ($userPerms) {
                    $q->where('perms', '')
                      ->orWhereNull('perms')
                      ->orWhereIn('perms', $userPerms);
                });
            }
        }

        $menus = $query->orderBy('group_sort', 'asc')
            ->orderBy('sort_order', 'asc')
            ->get();

        $grouped = [];
        foreach ($menus as $menu) {
            $key = $menu['group_key'];
            if (!isset($grouped[$key])) {
                $grouped[$key] = [
                    'group_name' => $menu['group_name'],
                    'group_key' => $menu['group_key'],
                    'group_sort' => $menu['group_sort'],
                    'items' => []
                ];
            }
            $grouped[$key]['items'][] = [
                'id' => $menu['id'],
                'title' => $menu['title'],
                'icon' => $menu['icon'],
                'path' => $menu['path'],
                'icon_color' => $menu['icon_color'],
                'bg_color' => $menu['bg_color'],
                'sort_order' => $menu['sort_order'],
            ];
        }

        return array_values(array_filter($grouped, fn($g) => count($g['items']) > 0));
    }

    public function getInfo($id)
    {
        return AppMenuConfig::find($id);
    }

    public function add($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return AppMenuConfig::create($data);
    }

    public function edit($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        return AppMenuConfig::where('id', $data['id'])->update($data);
    }

    public function remove($id)
    {
        return AppMenuConfig::where('id', $id)->delete();
    }

    public function updateSort($data)
    {
        if (!empty($data['menus'])) {
            foreach ($data['menus'] as $menu) {
                $menu = convert_to_snake_case($menu);
                if (isset($menu['id']) && isset($menu['sort_order'])) {
                    AppMenuConfig::where('id', $menu['id'])->update(['sort_order' => $menu['sort_order']]);
                }
            }
        } elseif (!empty($data['ids']) && !empty($data['sort_orders'])) {
            $ids = explode(',', $data['ids']);
            $sortOrders = explode(',', $data['sort_orders']);
            foreach ($ids as $index => $id) {
                if (isset($sortOrders[$index])) {
                    AppMenuConfig::where('id', intval($id))->update(['sort_order' => intval($sortOrders[$index])]);
                }
            }
        }
        return true;
    }

    public function changeStatus($id, $visible)
    {
        return AppMenuConfig::where('id', $id)->update([
            'visible' => $visible,
            'update_time' => date('Y-m-d H:i:s')
        ]);
    }
}
