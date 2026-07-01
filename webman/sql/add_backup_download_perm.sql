-- =============================================
-- 新增数据库备份下载权限
-- 父菜单：数据库备份 (menu_id=3083)
-- =============================================

-- 1. 新增"备份下载"按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT '备份下载', 3083, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:backup:download', '#', 'admin', NOW(), NULL, NULL, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `perms` = 'system:backup:download');

-- 2. 为已拥有备份列表权限的角色分配下载权限（含 admin role_id=1）
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT r.`role_id`, m.`menu_id`
FROM `sys_role_menu` r
JOIN `sys_menu` m ON m.`perms` = 'system:backup:download'
JOIN `sys_menu` src ON src.`menu_id` = r.`menu_id` AND src.`perms` = 'system:backup:list'
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` rm
    WHERE rm.`role_id` = r.`role_id` AND rm.`menu_id` = m.`menu_id`
);

-- 3. 确保 admin(role_id=1) 拥有该权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT 1, `menu_id` FROM `sys_menu`
WHERE `perms` = 'system:backup:download'
AND `menu_id` NOT IN (SELECT `menu_id` FROM `sys_role_menu` WHERE `role_id` = 1);
