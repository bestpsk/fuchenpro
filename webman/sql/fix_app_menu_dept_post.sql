-- =============================================
-- 补全APP菜单配置：岗位管理、部门管理
-- 日期: 2026-06-08
-- 幂等脚本：可重复执行
-- 背景：fix_menu_config_cleanup.sql 之前将 menu_id=103(部门管理)、104(岗位管理)
--       的 visible 设为 0、app_path 设为空，导致这两个菜单在APP工作台不显示
-- =============================================

-- =============================================
-- 一、补全 sys_app_menu - 部门管理(103)
-- =============================================

UPDATE `sys_app_menu`
SET
    `app_path`   = '/pages/system/dept/index',
    `app_icon`   = 'tree',
    `bg_color`   = '#3D6DF7',
    `icon_color` = '#fff',
    `sort_order` = 3,
    `visible`    = 1
WHERE `menu_id` = 103
  AND (`app_path` IS NULL OR `app_path` = '' OR `app_path` != '/pages/system/dept/index' OR `visible` != 1);

-- =============================================
-- 二、补全 sys_app_menu - 岗位管理(104)
-- =============================================

UPDATE `sys_app_menu`
SET
    `app_path`   = '/pages/system/post/index',
    `app_icon`   = 'bookmark',
    `bg_color`   = '#3D6DF7',
    `icon_color` = '#fff',
    `sort_order` = 4,
    `visible`    = 1
WHERE `menu_id` = 104
  AND (`app_path` IS NULL OR `app_path` = '' OR `app_path` != '/pages/system/post/index' OR `visible` != 1);

-- =============================================
-- 三、补全 app_menu_config 旧版兼容表 - 岗位管理
-- 部门管理在 app_menu_config 中已有正确路径，无需处理
-- =============================================

UPDATE `app_menu_config`
SET `path` = '/pages/system/post/index'
WHERE `title` = '岗位管理' AND `group_key` = 'system'
  AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/post/index');

-- =============================================
-- 四、为管理员角色(role_id=1)分配部门管理、岗位管理及其按钮权限
-- =============================================

SET @admin_role_id = 1;

-- 4.1 部门管理菜单
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_id = 103
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = 103);

-- 4.2 岗位管理菜单
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_id = 104
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = 104);

-- 4.3 部门管理的按钮权限（type='F'）
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
WHERE sm.parent_id = 103 AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` srm WHERE srm.role_id = @admin_role_id AND srm.menu_id = sm.menu_id);

-- 4.4 岗位管理的按钮权限（type='F'）
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
WHERE sm.parent_id = 104 AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` srm WHERE srm.role_id = @admin_role_id AND srm.menu_id = sm.menu_id);

-- =============================================
-- 五、验证
-- =============================================

SELECT am.app_menu_id, m.menu_id, m.menu_name, am.app_path, am.app_icon, am.bg_color, am.sort_order, am.visible
FROM `sys_app_menu` am
INNER JOIN `sys_menu` m ON am.menu_id = m.menu_id
WHERE m.menu_id IN (103, 104)
ORDER BY m.menu_id;
