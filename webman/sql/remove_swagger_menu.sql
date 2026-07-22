-- 移除系统接口(Swagger)菜单
-- 原因：后端(webman)无Swagger UI支持，访问会404
-- 路径：系统工具 > 系统接口
-- 注意：此SQL需手动执行

-- 删除系统接口菜单（含按钮权限）
DELETE FROM sys_menu WHERE perms = 'tool:swagger:list';
DELETE FROM sys_menu WHERE path = 'swagger' AND component = 'tool/swagger/index';
