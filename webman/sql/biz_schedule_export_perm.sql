-- =============================================
-- 行程安排导出权限补充 + purpose 字段注释修正
-- 说明：PC 端导出按钮使用 v-hasPermi="['business:schedule:export']"，
--       但数据库缺少该权限菜单，导致导出按钮对所有用户不可见。
--       本脚本新增导出权限并分配给管理员角色，同时修正 purpose 字段注释。
-- 执行方式：手动执行
-- =============================================

-- 1. 新增行程导出按钮权限（挂在"行程安排"菜单下）
SET @schedule_menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '行程安排' AND path = 'schedule');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '行程导出', @schedule_menu_id, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:schedule:export', '#', 'admin', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'business:schedule:export' AND parent_id = @schedule_menu_id);

-- 2. 为管理员角色（role_id=1）分配导出权限
SET @export_menu_id = (SELECT menu_id FROM sys_menu WHERE perms = 'business:schedule:export');
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, @export_menu_id);

-- 3. 修正 biz_schedule 表 purpose 字段注释（原注释标签已过时）
ALTER TABLE `biz_schedule` MODIFY COLUMN `purpose` char(1) NOT NULL COMMENT '下店目的(1爆卡 2销售 3售后 4业务)';
