<?php

namespace app\service;

use app\model\SysAppMenu;
use app\model\SysMenu;
use app\service\SysPermissionService;

class SysAppMenuService
{
    const GROUP_COLORS = [
        'business' => '#FF6B35',
        'attendance' => '#F59E0B',
        'wms' => '#3D6DF7',
        'finance' => '#8B5CF6',
        'admin' => '#52c41a',
        'system' => '#3D6DF7',
    ];

    public function getGroupedAppMenus($userId = null)
    {
        $menuIds = $this->getAuthorizedMenuIds($userId);

        $appMenus = SysAppMenu::where('visible', 1)
            ->whereIn('menu_id', $menuIds)
            ->orderBy('sort_order', 'asc')
            ->get()
            ->keyBy('menu_id');

        if ($appMenus->isEmpty()) return [];

        $sysMenus = SysMenu::whereIn('menu_id', $appMenus->keys())
            ->where('menu_type', 'C')
            ->where('status', '0')
            ->get()
            ->keyBy('menu_id');

        $parentIds = $sysMenus->pluck('parent_id')->unique()->filter()->values()->toArray();
        $parentMenus = SysMenu::whereIn('menu_id', $parentIds)
            ->where('menu_type', 'M')
            ->where('status', '0')
            ->get()
            ->keyBy('menu_id');

        $parentAppMenus = SysAppMenu::whereIn('menu_id', $parentIds)->get()->keyBy('menu_id');

        $grouped = [];
        foreach ($sysMenus as $menuId => $menu) {
            $parentId = $menu->parent_id;
            $parent = $parentMenus->get($parentId);
            if (!$parent) continue;

            $appMenu = $appMenus->get($menuId);
            $parentAppMenu = $parentAppMenus->get($parentId);
            $groupKey = $parent->path;
            $groupBgColor = $parentAppMenu ? $parentAppMenu->bg_color : (self::GROUP_COLORS[$groupKey] ?? '#3D6DF7');

            if (!isset($grouped[$groupKey])) {
                $grouped[$groupKey] = [
                    'groupName' => $parent->menu_name,
                    'groupKey' => $groupKey,
                    'groupSort' => $parent->order_num,
                    'bgColor' => $groupBgColor,
                    'items' => []
                ];
            }

            $grouped[$groupKey]['items'][] = [
                'id' => $menuId,
                'title' => $menu->menu_name,
                'icon' => $appMenu->app_icon ?: 'list',
                'path' => $appMenu->app_path ?: '',
                'iconColor' => $appMenu->icon_color ?: '#fff',
                'bgColor' => $appMenu->bg_color ?: $groupBgColor,
                'sortOrder' => $appMenu->sort_order ?: 0,
            ];
        }

        uasort($grouped, fn($a, $b) => $a['groupSort'] <=> $b['groupSort']);
        return array_values($grouped);
    }

    private function getAuthorizedMenuIds($userId)
    {
        if ($userId === null) return SysMenu::where('status', '0')->pluck('menu_id')->toArray();

        $user = \app\model\SysUser::find($userId);
        if (!$user || $user->isAdmin()) {
            return SysMenu::where('status', '0')->pluck('menu_id')->toArray();
        }

        $permService = new SysPermissionService();
        $userPerms = $permService->getMenuPermission($user);

        return SysMenu::where('status', '0')
            ->where(function ($q) use ($userPerms) {
                $q->where('perms', '')->orWhereNull('perms')->orWhereIn('perms', $userPerms);
            })
            ->pluck('menu_id')->toArray();
    }

    public function selectAppMenuList($params = [])
    {
        $query = SysAppMenu::query();
        if (!empty($params['menu_id'])) $query->where('menu_id', $params['menu_id']);
        if (isset($params['visible']) && $params['visible'] !== '') $query->where('visible', $params['visible']);
        return $query->orderBy('sort_order', 'asc')->get()->map(function ($item) {
            $sysMenu = SysMenu::find($item->menu_id);
            $item->menu_name = $sysMenu ? $sysMenu->menu_name : '';
            $item->parent_id = $sysMenu ? $sysMenu->parent_id : 0;
            $item->menu_type = $sysMenu ? $sysMenu->menu_type : '';
            return $item;
        });
    }

    public function getAppMenuByMenuId($menuId)
    {
        return SysAppMenu::where('menu_id', $menuId)->first();
    }

    public function addAppMenu($data)
    {
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysAppMenu::create($data);
    }

    public function editAppMenu($data)
    {
        $data['update_time'] = date('Y-m-d H:i:s');
        if (isset($data['app_menu_id'])) {
            return SysAppMenu::where('app_menu_id', $data['app_menu_id'])->update(
                collect($data)->only(['menu_id', 'app_path', 'app_icon', 'bg_color', 'icon_color', 'sort_order', 'visible', 'update_by', 'update_time'])->toArray()
            );
        }
        if (isset($data['menu_id'])) {
            return SysAppMenu::where('menu_id', $data['menu_id'])->update(
                collect($data)->only(['app_path', 'app_icon', 'bg_color', 'icon_color', 'sort_order', 'visible', 'update_by', 'update_time'])->toArray()
            );
        }
        return 0;
    }

    public function removeAppMenu($appMenuId)
    {
        return SysAppMenu::where('app_menu_id', $appMenuId)->delete();
    }
}
