-- =============================================
-- 为sys_menu添加client_type字段，支持App专属菜单
-- 解决：App端考勤等功能菜单无法通过动态菜单系统展示的问题
-- =============================================

-- 1. 为sys_menu添加client_type字段
ALTER TABLE `sys_menu` ADD COLUMN `client_type` varchar(10) NOT NULL DEFAULT 'all'
COMMENT '客户端类型(all-全端 web-仅Web app-仅App)' AFTER `status`;

-- 2. 插入考勤管理一级目录（App专属）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('考勤管理', 0, 3, 'attendance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'app', '', 'date', 'admin', NOW());

-- 3. 插入考勤子菜单（App专属）
SET @attendance_parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendance' AND parent_id = 0 AND client_type = 'app') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('考勤打卡', @attendance_parent_id, 1, 'attendanceClock', NULL, NULL, NULL, 1, 0, 'C', '0', '0', 'app', 'business:attendance:clock', 'clock', 'admin', NOW());

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('打卡记录', @attendance_parent_id, 2, 'attendanceRecord', NULL, NULL, NULL, 1, 0, 'C', '0', '0', 'app', 'business:attendance:record', 'list', 'admin', NOW());

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('考勤配置', @attendance_parent_id, 3, 'attendanceConfig', NULL, NULL, NULL, 1, 0, 'C', '0', '0', 'app', 'business:attendance:config', 'setting', 'admin', NOW());

-- 4. 为考勤菜单创建sys_app_menu扩展配置
SET @attendance_parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendance' AND parent_id = 0 AND client_type = 'app') t);
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@attendance_parent_id, '', '', '#F59E0B', '#fff', 3, 1, 'admin');

SET @attendance_clock_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendanceClock' AND client_type = 'app') t);
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@attendance_clock_id, '/pages/attendance/index', 'clock', '#F59E0B', '#fff', 1, 1, 'admin');

SET @attendance_record_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendanceRecord' AND client_type = 'app') t);
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@attendance_record_id, '/pages/attendance/record', 'file-text', '#F59E0B', '#fff', 2, 1, 'admin');

SET @attendance_config_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendanceConfig' AND client_type = 'app') t);
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@attendance_config_id, '/pages/attendance/config', 'grid', '#F59E0B', '#fff', 3, 1, 'admin');

-- 5. 为管理员角色分配考勤菜单权限
SET @admin_role_id = 1;
SET @attendance_parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE path = 'attendance' AND parent_id = 0 AND client_type = 'app') t);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @attendance_parent_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @attendance_parent_id;
