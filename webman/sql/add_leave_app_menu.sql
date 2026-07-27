-- =============================================
-- App 端考勤管理菜单入口补全（请假管理 + 我的休息日）
-- 前置条件：已执行 biz_leave.sql 和 biz_leave_menu_update.sql
-- 执行后需更新 AppV3 menu.js 的 CACHE_VERSION 并重启后端
-- =============================================

-- 1. 创建"我的休息日"App 专用菜单（sys_menu 中原本无此记录）
-- 使用 client_type='app' 标识为 App 专用菜单，不影响 Web 端
SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0) t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `client_type`, `create_by`, `create_time`)
SELECT '我的休息日', @attendance_menu_id, 10, 'myRest', NULL, NULL, 'AppMyRest', 1, 0, 'C', '0', '0', 'business:leave:restPlan:myPlan', 'calendar', 'app', 'admin', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '我的休息日' AND path = 'myRest');

-- 2. 为管理员角色分配"我的休息日"菜单权限
SET @admin_role_id = 1;
SET @my_rest_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '我的休息日' AND path = 'myRest') t);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @my_rest_menu_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @my_rest_menu_id);

-- 3. 在 sys_app_menu 中添加"请假管理"App 菜单配置
-- 通过 menu_name 匹配 sys_menu.menu_id，避免硬编码
SET @leave_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '请假管理' AND path = 'index') t);

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @leave_menu_id, '/pages/business/leave/list/index', 'edit-pen', '#F59E0B', '#fff', 4, 1, 'admin'
FROM DUAL
WHERE @leave_menu_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @leave_menu_id);

-- 4. 在 sys_app_menu 中添加"我的休息日"App 菜单配置
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @my_rest_menu_id, '/pages/business/leave/myRest', 'calendar', '#F59E0B', '#fff', 5, 1, 'admin'
FROM DUAL
WHERE @my_rest_menu_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @my_rest_menu_id);
