-- =============================================
-- 新增APP财务模块菜单 - 方案审核/报销管理/报销统计
-- 同时写入 sys_menu + sys_app_menu（新版）和 app_menu_config（旧版兼容）
-- 所有INSERT均带重复检查，防止重复执行导致数据冲突
-- =============================================

-- =============================================
-- 一、sys_menu 菜单记录（含 client_type 和按钮权限）
-- =============================================

-- 获取财务管理一级目录ID
SET @finance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '财务管理' AND parent_id = 0) t);

-- ---------- 1. 方案审核 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '方案审核', @finance_menu_id, 1, 'planAudit', NULL, NULL, 'AppPlanAudit', 1, 0, 'C', '0', '0', 'app', 'finance:planAudit:list', 'edit', 'admin', NOW()
FROM DUAL WHERE @finance_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '方案审核' AND path = 'planAudit' AND client_type = 'app');

SET @plan_audit_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '方案审核' AND path = 'planAudit' AND client_type = 'app') t);

-- 方案审核按钮：审核
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '方案审核操作', @plan_audit_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:planAudit:audit', '#', 'admin', NOW()
FROM DUAL WHERE @plan_audit_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '方案审核操作' AND parent_id = @plan_audit_menu_id);

-- ---------- 2. 报销管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销管理', @finance_menu_id, 2, 'reimbursement', NULL, NULL, 'AppReimbursement', 1, 0, 'C', '0', '0', 'app', 'finance:reimbursement:list', 'form', 'admin', NOW()
FROM DUAL WHERE @finance_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销管理' AND path = 'reimbursement' AND client_type = 'app');

SET @reimbursement_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '报销管理' AND path = 'reimbursement' AND client_type = 'app') t);

-- 报销管理按钮：新增
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销新增', @reimbursement_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:add', '#', 'admin', NOW()
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销新增' AND parent_id = @reimbursement_menu_id);

-- 报销管理按钮：编辑
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销编辑', @reimbursement_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:edit', '#', 'admin', NOW()
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销编辑' AND parent_id = @reimbursement_menu_id);

-- 报销管理按钮：删除
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销删除', @reimbursement_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:remove', '#', 'admin', NOW()
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销删除' AND parent_id = @reimbursement_menu_id);

-- 报销管理按钮：审核
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销审核', @reimbursement_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:audit', '#', 'admin', NOW()
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销审核' AND parent_id = @reimbursement_menu_id);

-- 报销管理按钮：支付
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销支付', @reimbursement_menu_id, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:pay', '#', 'admin', NOW()
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销支付' AND parent_id = @reimbursement_menu_id);

-- ---------- 3. 报销统计 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '报销统计', @finance_menu_id, 3, 'reimbursementReport', NULL, NULL, 'AppReimbursementReport', 1, 0, 'C', '0', '0', 'app', 'finance:reimbursement:report', 'chart', 'admin', NOW()
FROM DUAL WHERE @finance_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '报销统计' AND path = 'reimbursementReport' AND client_type = 'app');

SET @reimbursement_report_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '报销统计' AND path = 'reimbursementReport' AND client_type = 'app') t);

-- =============================================
-- 二、sys_app_menu 扩展配置（APP路径、图标、颜色）
-- =============================================

-- 方案审核 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @plan_audit_menu_id, '/pages/finance/planAudit/index', 'edit', '#10B981', '#fff', 1, 1, 'admin'
FROM DUAL WHERE @plan_audit_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @plan_audit_menu_id);

-- 报销管理 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @reimbursement_menu_id, '/pages/finance/reimbursement/index', 'form', '#3B82F6', '#fff', 2, 1, 'admin'
FROM DUAL WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @reimbursement_menu_id);

-- 报销统计 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @reimbursement_report_menu_id, '/pages/finance/reimbursementReport/index', 'chart', '#8B5CF6', '#fff', 3, 1, 'admin'
FROM DUAL WHERE @reimbursement_report_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @reimbursement_report_menu_id);

-- =============================================
-- 三、app_menu_config 旧版兼容记录
-- =============================================

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '财务管理', 'finance', 5, '方案审核', 'edit', '/pages/finance/planAudit/index', '#fff', '#10B981', 1, 1, '0', 'finance:planAudit:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '方案审核' AND path = '/pages/finance/planAudit/index');

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '财务管理', 'finance', 5, '报销管理', 'form', '/pages/finance/reimbursement/index', '#fff', '#3B82F6', 2, 1, '0', 'finance:reimbursement:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '报销管理' AND path = '/pages/finance/reimbursement/index');

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '财务管理', 'finance', 5, '报销统计', 'chart', '/pages/finance/reimbursementReport/index', '#fff', '#8B5CF6', 3, 1, '0', 'finance:reimbursement:report'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '报销统计' AND path = '/pages/finance/reimbursementReport/index');

-- =============================================
-- 四、为管理员角色分配菜单权限
-- =============================================

SET @admin_role_id = 1;

-- 方案审核及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @plan_audit_menu_id FROM DUAL
WHERE @plan_audit_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @plan_audit_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @plan_audit_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);

-- 报销管理及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @reimbursement_menu_id FROM DUAL
WHERE @reimbursement_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @reimbursement_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @reimbursement_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);

-- 报销统计及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @reimbursement_report_menu_id FROM DUAL
WHERE @reimbursement_report_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @reimbursement_report_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @reimbursement_report_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);
