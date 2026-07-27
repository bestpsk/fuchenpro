-- 考勤管理权限补充脚本
-- 补充考勤记录导出权限（其他权限已存在于 biz_attendance.sql 中）
-- 执行前请确认已执行 biz_attendance.sql

-- 1. 添加考勤记录导出按钮权限
SET @record_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤记录' AND path = 'record') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '记录导出', @record_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:record:export', '#', 'admin', NOW()
FROM DUAL
WHERE @record_menu_id IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'business:attendance:record:export');

-- 2. 为管理员角色分配导出权限
SET @admin_role_id = (SELECT role_id FROM sys_role WHERE role_key = 'admin' LIMIT 1);
SET @export_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE perms = 'business:attendance:record:export') t);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @export_menu_id
FROM DUAL
WHERE @admin_role_id IS NOT NULL
AND @export_menu_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM sys_role_menu
    WHERE role_id = @admin_role_id AND menu_id = @export_menu_id
);
