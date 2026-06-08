-- =============================================
-- 新增APP业务菜单 - 卡项管理/备货管理/考勤规则/客户管理
-- 同时写入 sys_menu + sys_app_menu（新版）和 app_menu_config（旧版兼容）
-- 所有INSERT均带重复检查，防止重复执行导致数据冲突
-- =============================================

-- =============================================
-- 一、sys_menu 菜单记录（含 client_type 和按钮权限）
-- =============================================

-- 获取业务管理一级目录ID
SET @business_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0) t);

-- 获取考勤管理一级目录ID
SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0 AND client_type = 'app') t);

-- ---------- 1. 卡项管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项管理', @business_menu_id, 7, 'cardItem', NULL, NULL, 'AppCardItem', 1, 0, 'C', '0', '0', 'app', 'business:cardItem:list', 'component', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem' AND client_type = 'app');

SET @card_item_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem' AND client_type = 'app') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项新增', @card_item_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:add', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项新增' AND parent_id = @card_item_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项修改', @card_item_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:edit', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项修改' AND parent_id = @card_item_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项删除', @card_item_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:remove', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项删除' AND parent_id = @card_item_menu_id);

-- ---------- 2. 备货管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货管理', @business_menu_id, 8, 'stockPrepare', NULL, NULL, 'AppStockPrepare', 1, 0, 'C', '0', '0', 'app', 'business:stockPrepare:list', 'shopping-cart', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货管理' AND path = 'stockPrepare' AND client_type = 'app');

SET @stock_prepare_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '备货管理' AND path = 'stockPrepare' AND client_type = 'app') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货查询', @stock_prepare_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:query', '#', 'admin', NOW()
FROM DUAL WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货查询' AND parent_id = @stock_prepare_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货出库', @stock_prepare_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:stockOut', '#', 'admin', NOW()
FROM DUAL WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货出库' AND parent_id = @stock_prepare_menu_id);

-- ---------- 3. 考勤规则 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '考勤规则', @attendance_menu_id, 4, 'attendanceRule', NULL, NULL, 'AppAttendanceRule', 1, 0, 'C', '0', '0', 'app', 'business:attendance:rule:list', 'setting', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '考勤规则' AND path = 'attendanceRule' AND client_type = 'app');

SET @attendance_rule_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤规则' AND path = 'attendanceRule' AND client_type = 'app') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则新增', @attendance_rule_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:add', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则新增' AND parent_id = @attendance_rule_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则修改', @attendance_rule_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:edit', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则修改' AND parent_id = @attendance_rule_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则删除', @attendance_rule_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:remove', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则删除' AND parent_id = @attendance_rule_menu_id);

-- ---------- 4. 客户管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户管理', @business_menu_id, 9, 'customer', NULL, NULL, 'AppCustomer', 1, 0, 'C', '0', '0', 'app', 'business:customer:list', 'account', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户管理' AND path = 'customer' AND client_type = 'app');

SET @customer_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '客户管理' AND path = 'customer' AND client_type = 'app') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户新增', @customer_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:add', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户新增' AND parent_id = @customer_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户修改', @customer_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:edit', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户修改' AND parent_id = @customer_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户删除', @customer_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:remove', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户删除' AND parent_id = @customer_menu_id);

-- =============================================
-- 二、sys_app_menu 扩展配置（APP路径、图标、颜色）
-- =============================================

-- 卡项管理 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @card_item_menu_id, '/pages/business/cardItem/index', 'star', '#FF6B35', '#fff', 7, 1, 'admin'
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @card_item_menu_id);

-- 备货管理 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @stock_prepare_menu_id, '/pages/business/stockPrepare/index', 'shopping-cart', '#FF6B35', '#fff', 8, 1, 'admin'
FROM DUAL WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @stock_prepare_menu_id);

-- 考勤规则 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @attendance_rule_menu_id, '/pages/attendance/rule', 'setting', '#F59E0B', '#fff', 4, 1, 'admin'
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @attendance_rule_menu_id);

-- 客户管理 APP扩展
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT @customer_menu_id, '/pages/business/customer/index', 'account', '#FF6B35', '#fff', 9, 1, 'admin'
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = @customer_menu_id);

-- =============================================
-- 三、app_menu_config 旧版兼容记录
-- =============================================

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '业务管理', 'business', 2, '卡项管理', 'star', '/pages/business/cardItem/index', '#fff', '#FF6B35', 7, 1, '0', 'business:cardItem:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '卡项管理' AND path = '/pages/business/cardItem/index');

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '业务管理', 'business', 2, '备货管理', 'shopping-cart', '/pages/business/stockPrepare/index', '#fff', '#FF6B35', 8, 1, '0', 'business:stockPrepare:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '备货管理' AND path = '/pages/business/stockPrepare/index');

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '业务管理', 'business', 2, '客户管理', 'account', '/pages/business/customer/index', '#fff', '#FF6B35', 9, 1, '0', 'business:customer:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '客户管理' AND path = '/pages/business/customer/index');

-- 考勤规则放在考勤管理分组下
INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `perms`)
SELECT '考勤管理', 'attendance', 3, '考勤规则', 'setting', '/pages/attendance/rule', '#fff', '#F59E0B', 5, 1, '0', 'business:attendance:rule:list'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM app_menu_config WHERE title = '考勤规则' AND path = '/pages/attendance/rule');

-- =============================================
-- 四、为管理员角色分配菜单权限
-- =============================================

SET @admin_role_id = 1;

-- 卡项管理及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @card_item_menu_id FROM DUAL
WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @card_item_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @card_item_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);

-- 备货管理及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @stock_prepare_menu_id FROM DUAL
WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @stock_prepare_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @stock_prepare_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);

-- 考勤规则及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @attendance_rule_menu_id FROM DUAL
WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @attendance_rule_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @attendance_rule_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);

-- 客户管理及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @customer_menu_id FROM DUAL
WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @customer_menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE parent_id = @customer_menu_id AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = sys_menu.menu_id);
