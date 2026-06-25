-- 清理员工配置菜单（如果 fix_missing_permissions.sql 已执行）
-- 删除员工配置相关菜单（包括子权限）
DELETE FROM sys_menu WHERE perms LIKE 'business:employeeConfig%';

-- 同时清理角色菜单关联
DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE perms LIKE 'business:employeeConfig%'
);