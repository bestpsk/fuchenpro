-- ============================================================
-- 权限配置一致性修复脚本
-- 任务来源：参考.txt 第20行 - 检查权限配置冗余和缺少问题
-- 执行前请备份 sys_menu, sys_role_menu, app_menu_config 表
-- ============================================================

-- 1. 删除 sys_menu 旧组财务按钮权限（2094-2100，已被 3004-3012 替代）
-- 旧组缺少 query 权限，新组 3004-3012 更完整（含 query）
DELETE FROM sys_menu WHERE menu_id IN (2094, 2095, 2096, 2097, 2098, 2099, 2100);
-- 同步清理 sys_role_menu 中对应的关联
DELETE FROM sys_role_menu WHERE menu_id IN (2094, 2095, 2096, 2097, 2098, 2099, 2100);

-- 2. 删除 app_menu_config 旧组隐藏死数据（visible=0，已被新组 visible=1 替代）
-- getGroupedMenus 查询条件为 visible=1，旧组 visible=0 永远不会被返回，属于死数据
-- 进销存旧组：32-38
DELETE FROM app_menu_config WHERE id IN (32, 33, 34, 35, 36, 37, 38);
-- 财务旧组：39-41
DELETE FROM app_menu_config WHERE id IN (39, 40, 41);

-- 3. 清理 sys_role_menu 中 role_id=1 的孤儿关联（menu_id 不存在于 sys_menu）
-- 这些关联指向已被删除的 menu_id，属于无效数据
DELETE FROM sys_role_menu 
WHERE role_id = 1 
  AND menu_id IN (3039, 3047, 3048, 3049, 3050, 3052, 3053, 3054, 3056, 3057);

-- 4. 恢复 business:employeeConfig 权限记录（被 cleanup_employee_config_menu.sql 误删）
-- AppV3 schedule/index.vue 第276、282行仍在引用这两个权限
-- 父菜单：2007（行程安排），menu_type=F（按钮）
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `remark`) VALUES
(3084, '员工配置列表', 2007, 10, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:employeeConfig:list', '#', 'admin', NOW(), '员工配置查询（行程安排页内嵌功能）'),
(3085, '员工配置修改', 2007, 11, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:employeeConfig:edit', '#', 'admin', NOW(), '员工配置修改（可排班/休息日期）');

-- 5. 为超级管理员角色（role_id=1）分配恢复的权限
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(1, 3084),
(1, 3085);

-- ============================================================
-- 验证查询（执行后可运行以下查询确认结果）
-- ============================================================
-- SELECT COUNT(*) AS old_finance_menu_count FROM sys_menu WHERE menu_id IN (2094,2095,2096,2097,2098,2099,2100);  -- 预期: 0
-- SELECT COUNT(*) AS new_finance_menu_count FROM sys_menu WHERE menu_id BETWEEN 3004 AND 3012;  -- 预期: 9
-- SELECT COUNT(*) AS old_app_menu_count FROM app_menu_config WHERE id IN (32,33,34,35,36,37,38,39,40,41);  -- 预期: 0
-- SELECT COUNT(*) AS orphan_role_menu_count FROM sys_role_menu WHERE role_id = 1 AND menu_id IN (3039,3047,3048,3049,3050,3052,3053,3054,3056,3057);  -- 预期: 0
-- SELECT menu_id, menu_name, perms FROM sys_menu WHERE perms LIKE 'business:employeeConfig%';  -- 预期: 2条 (list, edit)
