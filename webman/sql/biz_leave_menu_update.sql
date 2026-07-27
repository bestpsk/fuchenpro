-- =============================================
-- 休假管理菜单重构 + 休息日表结构变更
-- 执行前确保已执行 biz_leave.sql
-- =============================================

-- ===================== 1. 菜单重构 =====================

-- 1.1 休假管理菜单改为指向合并后的页面（从目录M改为页面C）
UPDATE sys_menu SET
  component = 'business/leave/main',
  menu_type = 'C',
  route_name = 'LeaveMain',
  perms = 'business:leave:type:list'
WHERE menu_name = '休假管理' AND path = 'leave';

-- 1.2 删除休假类型、休息日配置、假期日历三个子菜单的按钮权限（先删子按钮再删菜单）
-- 注意：需要先查出来再删，避免子查询嵌套问题
-- 删除休假类型的按钮权限
DELETE FROM sys_menu WHERE parent_id IN (
  SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假类型' AND path = 'type') t
);
-- 删除休息日配置的按钮权限
DELETE FROM sys_menu WHERE parent_id IN (
  SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休息日配置' AND path = 'restDay') t
);
-- 删除假期日历的按钮权限
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

-- ===================== 2. 休息日表结构变更 =====================

-- 2.1 给 biz_employee_rest_day 添加配置名称字段
ALTER TABLE `biz_employee_rest_day` ADD COLUMN `config_name` varchar(100) DEFAULT '' COMMENT '配置名称' AFTER `dept_id`;
