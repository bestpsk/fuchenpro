-- =============================================
-- App菜单扩展配置表 - 关联sys_menu
-- =============================================

CREATE TABLE `sys_app_menu` (
  `app_menu_id` int NOT NULL AUTO_INCREMENT COMMENT 'App菜单ID',
  `menu_id` bigint NOT NULL COMMENT '关联sys_menu的menu_id',
  `app_path` varchar(200) DEFAULT '' COMMENT 'App页面路径',
  `app_icon` varchar(100) DEFAULT '' COMMENT 'App图标名称(uView图标)',
  `bg_color` varchar(20) DEFAULT '#3D6DF7' COMMENT '图标背景色',
  `icon_color` varchar(20) DEFAULT '#fff' COMMENT '图标颜色',
  `sort_order` int DEFAULT 0 COMMENT '排序',
  `visible` tinyint DEFAULT 1 COMMENT '是否显示(1显示 0隐藏)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`app_menu_id`),
  UNIQUE KEY `uk_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='App菜单扩展配置表';

-- 数据迁移：从 app_menu_config 迁移到 sys_app_menu（通过菜单名称匹配 sys_menu.menu_id）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, a.path, a.icon, a.bg_color, a.icon_color, a.sort_order, a.visible, 'admin'
FROM `app_menu_config` a
INNER JOIN `sys_menu` m ON m.menu_name = a.title AND m.menu_type = 'C'
WHERE a.group_key != 'quick' AND a.group_key != 'mine_action' AND a.group_key != 'mine_menu';

-- 为一级目录也创建 App 扩展记录（存储分组主题色）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#FF6B35', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'business'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#F59E0B', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'attendance'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#3D6DF7', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'wms'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#8B5CF6', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'finance'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#52c41a', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'admin'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#3D6DF7', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_type = 'M' AND m.parent_id = 0 AND m.path = 'system'
AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 菜单权限：App菜单管理
SET @system_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '系统管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('App菜单配置', @system_menu_id, 10, 'appMenu', 'system/appMenu/index', NULL, 'SystemAppMenu', 1, 0, 'C', '0', '0', 'system:appMenu:list', 'phone', 'admin', NOW());

SET @appmenu_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = 'App菜单配置' AND path = 'appMenu') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('App菜单查询', @appmenu_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:query', '#', 'admin', NOW()),
('App菜单新增', @appmenu_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:add', '#', 'admin', NOW()),
('App菜单修改', @appmenu_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:edit', '#', 'admin', NOW()),
('App菜单删除', @appmenu_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:remove', '#', 'admin', NOW());

SET @admin_role_id = 1;
SET @appmenu_menu = (SELECT menu_id FROM sys_menu WHERE menu_name = 'App菜单配置' AND path = 'appMenu');
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @appmenu_menu);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @appmenu_menu;
