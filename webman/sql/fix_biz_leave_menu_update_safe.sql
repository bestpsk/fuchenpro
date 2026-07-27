-- =============================================
-- biz_leave_menu_update.sql 幂等安全版本
-- 菜单重构部分（UPDATE/DELETE）本身幂等，保持不变
-- 跳过 ALTER TABLE biz_employee_rest_day（表已废弃不存在）
-- 安全执行：可重复执行不报错
-- =============================================

-- ===================== 1. 菜单重构（UPDATE/DELETE 本身幂等）=====================

-- 1.1 休假管理菜单改为指向合并后的页面（从目录M改为页面C）
UPDATE sys_menu SET
  component = 'business/leave/main',
  menu_type = 'C',
  route_name = 'LeaveMain',
  perms = 'business:leave:type:list'
WHERE menu_name = '休假管理' AND path = 'leave';

-- 1.2 删除休假类型、休息日配置、假期日历三个子菜单的按钮权限（先删子按钮再删菜单）
DELETE FROM sys_menu WHERE parent_id IN (
  SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假类型' AND path = 'type') t
);
DELETE FROM sys_menu WHERE parent_id IN (
  SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休息日配置' AND path = 'restDay') t
);
DELETE FROM sys_menu WHERE parent_id IN (
  SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '假期日历' AND path = 'holiday') t
);

-- 1.3 删除休假类型、休息日配置、假期日历三个子菜单
DELETE FROM sys_menu WHERE menu_name IN ('休假类型', '休息日配置', '假期日历')
  AND parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假管理' AND path = 'leave') t);

-- 1.4 删除角色与这三个菜单的关联
DELETE FROM sys_role_menu WHERE menu_id IN (
  SELECT menu_id FROM (
    SELECT menu_id FROM sys_menu WHERE menu_name IN ('休假类型', '休息日配置', '假期日历')
  ) t
);

-- 1.5 请假管理移到考勤管理下（parent_id 改为考勤管理顶级菜单，order_num=3）
UPDATE sys_menu SET
  parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0) t),
  order_num = 3
WHERE menu_name = '请假管理' AND path = 'index';

-- ===================== 2. 跳过 ALTER TABLE biz_employee_rest_day =====================
-- 原脚本的 ALTER TABLE biz_employee_rest_day ADD COLUMN config_name 已跳过
-- 原因：biz_employee_rest_day 表已废弃（被 biz_rest_plan 系列表替代）
-- 该表已被 drop_employee_rest_day_table.sql 删除，ALTER 会报错
