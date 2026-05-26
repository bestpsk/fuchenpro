INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
(2100, 'App菜单配置', 1, 9, 'appMenu', 'system/appMenu/index', NULL, 'AppMenu', 1, 0, 'C', '0', '0', 'system:appMenu:list', 'phone', 'admin', NOW(), '', NULL, 'App移动端菜单配置菜单'),
(2101, 'App菜单查询', 2100, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:query', '#', 'admin', NOW(), '', NULL, ''),
(2102, 'App菜单新增', 2100, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:add', '#', 'admin', NOW(), '', NULL, ''),
(2103, 'App菜单修改', 2100, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:edit', '#', 'admin', NOW(), '', NULL, ''),
(2104, 'App菜单删除', 2100, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:remove', '#', 'admin', NOW(), '', NULL, '');
