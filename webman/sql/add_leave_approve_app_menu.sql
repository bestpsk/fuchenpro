-- =============================================
-- App 端"请假审核"菜单入口补全
-- 前置条件：已执行 biz_leave.sql / fix_biz_leave_safe.sql（business:leave:approve 权限已存在）
-- 执行后需更新 AppV3 menu.js 的 CACHE_VERSION 并重启后端
-- =============================================

-- 1. 创建"请假审核"App 专用菜单（sys_menu 中原本无此记录）
-- 使用 client_type='app' 标识为 App 专用菜单，不影响 Web 端
SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0) t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `client_type`, `create_by`, `create_time`)
SELECT '请假审核', @attendance_menu_id, 11, 'approve', NULL, NULL, 'AppLeaveApprove', 1, 0, 'C', '0', '0', 'business:leave:approve', 'checkmark-circle', 'app', 'admin', NOW()
FROM DUAL
WHERE @attendance_menu_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '请假审核' AND path = 'approve' AND client_type = 'app');

-- 2. 为管理员角色分配"请假审核"菜单权限
SET @admin_role_id = 1;
SET @approve_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '请假审核' AND path = 'approve' AND client_type = 'app') t);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @approve_menu_id
FROM DUAL
WHERE @approve_menu_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @approve_menu_id);

-- 3. 在 sys_app_menu 中添加"请假审核"App 菜单配置
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @approve_menu_id, '/pages/business/leave/approve/index', 'checkmark-circle', '#3D6DF7', '#fff', 6, 1, 'admin'
FROM DUAL
WHERE @approve_menu_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @approve_menu_id);
