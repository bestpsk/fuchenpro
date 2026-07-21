-- 考勤配置菜单和按钮权限
SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0) t);

-- 考勤配置菜单
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('考勤配置', @attendance_menu_id, 3, 'config', 'business/attendance/config', NULL, 'AttendanceConfig', 1, 0, 'C', '0', '0', 'business:attendance:config:list', 'tool', 'admin', NOW());

-- 考勤配置按钮权限
SET @config_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤配置' AND path = 'config') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('配置查询', @config_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:query', '#', 'admin', NOW()),
('配置新增', @config_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:add', '#', 'admin', NOW()),
('配置修改', @config_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:edit', '#', 'admin', NOW()),
('配置删除', @config_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:remove', '#', 'admin', NOW());

-- 为管理员角色分配考勤配置菜单权限
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(@admin_role_id, @config_menu_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @config_menu_id;
