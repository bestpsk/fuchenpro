-- =============================================
-- 修复APP菜单路径 - 幂等脚本
-- 确保 sys_menu.client_type、sys_app_menu.app_path、缺失记录、角色权限全部正确
-- 安全重复执行：所有操作均带条件检查
-- =============================================

-- =============================================
-- 一、确保一级目录 client_type = 'all'（Web和APP均可见）
-- =============================================

UPDATE `sys_menu` SET `client_type` = 'all'
WHERE `menu_name` = '业务管理' AND `parent_id` = 0 AND `menu_type` = 'M'
  AND (`client_type` IS NULL OR `client_type` != 'all');

UPDATE `sys_menu` SET `client_type` = 'all'
WHERE `menu_name` = '进销存管理' AND `parent_id` = 0 AND `menu_type` = 'M'
  AND (`client_type` IS NULL OR `client_type` != 'all');

UPDATE `sys_menu` SET `client_type` = 'all'
WHERE `menu_name` = '财务管理' AND `parent_id` = 0 AND `menu_type` = 'M'
  AND (`client_type` IS NULL OR `client_type` != 'all');

UPDATE `sys_menu` SET `client_type` = 'all'
WHERE `menu_name` = '系统管理' AND `parent_id` = 0 AND `menu_type` = 'M'
  AND (`client_type` IS NULL OR `client_type` != 'all');

UPDATE `sys_menu` SET `client_type` = 'all'
WHERE `menu_name` = '考勤管理' AND `parent_id` = 0 AND `menu_type` = 'M'
  AND (`client_type` IS NULL OR `client_type` != 'all');

-- =============================================
-- 二、确保APP专属子菜单的 sys_menu 记录存在
-- 卡项管理、备货管理、客户管理、考勤规则 可能尚未创建
-- =============================================

-- 获取业务管理一级目录ID
SET @business_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0 LIMIT 1) t);

-- 获取考勤管理一级目录ID（可能client_type是app或all）
SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0 LIMIT 1) t);

-- ---------- 卡项管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项管理', @business_menu_id, 7, 'cardItem', NULL, NULL, 'AppCardItem', 1, 0, 'C', '0', '0', 'app', 'business:cardItem:list', 'component', 'admin', NOW()
FROM DUAL WHERE @business_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem' AND client_type = 'app');

SET @card_item_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem' AND client_type = 'app' LIMIT 1) t);

-- 卡项管理按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项新增', @card_item_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:add', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项新增' AND parent_id = @card_item_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项修改', @card_item_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:edit', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项修改' AND parent_id = @card_item_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项删除', @card_item_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:remove', '#', 'admin', NOW()
FROM DUAL WHERE @card_item_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '卡项删除' AND parent_id = @card_item_menu_id);

-- ---------- 备货管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货管理', @business_menu_id, 8, 'stockPrepare', NULL, NULL, 'AppStockPrepare', 1, 0, 'C', '0', '0', 'app', 'business:stockPrepare:list', 'shopping-cart', 'admin', NOW()
FROM DUAL WHERE @business_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货管理' AND path = 'stockPrepare' AND client_type = 'app');

SET @stock_prepare_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '备货管理' AND path = 'stockPrepare' AND client_type = 'app' LIMIT 1) t);

-- 备货管理按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货查询', @stock_prepare_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:query', '#', 'admin', NOW()
FROM DUAL WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货查询' AND parent_id = @stock_prepare_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '备货出库', @stock_prepare_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:stockOut', '#', 'admin', NOW()
FROM DUAL WHERE @stock_prepare_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '备货出库' AND parent_id = @stock_prepare_menu_id);

-- ---------- 客户管理 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户管理', @business_menu_id, 9, 'customer', NULL, NULL, 'AppCustomer', 1, 0, 'C', '0', '0', 'app', 'business:customer:list', 'account', 'admin', NOW()
FROM DUAL WHERE @business_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户管理' AND path = 'customer' AND client_type = 'app');

SET @customer_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '客户管理' AND path = 'customer' AND client_type = 'app' LIMIT 1) t);

-- 客户管理按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户新增', @customer_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:add', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户新增' AND parent_id = @customer_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户修改', @customer_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:edit', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户修改' AND parent_id = @customer_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '客户删除', @customer_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:remove', '#', 'admin', NOW()
FROM DUAL WHERE @customer_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '客户删除' AND parent_id = @customer_menu_id);

-- ---------- 考勤规则 ----------
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '考勤规则', @attendance_menu_id, 4, 'attendanceRule', NULL, NULL, 'AppAttendanceRule', 1, 0, 'C', '0', '0', 'app', 'business:attendance:rule:list', 'setting', 'admin', NOW()
FROM DUAL WHERE @attendance_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '考勤规则' AND path = 'attendanceRule' AND client_type = 'app');

SET @attendance_rule_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤规则' AND path = 'attendanceRule' AND client_type = 'app' LIMIT 1) t);

-- 考勤规则按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则新增', @attendance_rule_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:add', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则新增' AND parent_id = @attendance_rule_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则修改', @attendance_rule_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:edit', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则修改' AND parent_id = @attendance_rule_menu_id);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '规则删除', @attendance_rule_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:remove', '#', 'admin', NOW()
FROM DUAL WHERE @attendance_rule_menu_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '规则删除' AND parent_id = @attendance_rule_menu_id);

-- =============================================
-- 三、更新 sys_app_menu.app_path - 业务管理
-- =============================================

-- 企业管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/enterprise/index'
WHERE m.menu_name = '企业管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/enterprise/index');

-- 门店管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/store/index'
WHERE m.menu_name = '门店管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/store/index');

-- 行程安排
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/schedule/index'
WHERE m.menu_name = '行程安排' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/schedule/index');

-- 销售开单
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/sales/index'
WHERE m.menu_name = '销售开单' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/sales/index');

-- 订单管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/order/index'
WHERE m.menu_name = '订单管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/order/index');

-- 方案管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/plan/index'
WHERE m.menu_name = '方案管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/plan/index');

-- 卡项管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/cardItem/index'
WHERE m.menu_name = '卡项管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/cardItem/index');

-- 备货管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/stockPrepare/index'
WHERE m.menu_name = '备货管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/stockPrepare/index');

-- 客户管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/business/customer/index'
WHERE m.menu_name = '客户管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/business/customer/index');

-- =============================================
-- 四、更新 sys_app_menu.app_path - 进销存管理(WMS)
-- =============================================

-- 供货商管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/supplier/index'
WHERE m.menu_name = '供货商管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/supplier/index');

-- 货品管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/product/index'
WHERE m.menu_name = '货品管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/product/index');

-- 入库管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/stockIn/index'
WHERE m.menu_name = '入库管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/stockIn/index');

-- 出库管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/shipment/index'
WHERE m.menu_name = '出库管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/shipment/index');

-- 库存查看
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/stock/index'
WHERE m.menu_name = '库存查看' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/stock/index');

-- 库存盘点
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/wms/stockCheck/index'
WHERE m.menu_name = '库存盘点' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/wms/stockCheck/index');

-- =============================================
-- 五、更新 sys_app_menu.app_path - 财务管理
-- =============================================

-- 方案审核
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/finance/planAudit/index'
WHERE m.menu_name = '方案审核' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/finance/planAudit/index');

-- 报销管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/finance/reimbursement/index'
WHERE m.menu_name = '报销管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/finance/reimbursement/index');

-- 报销统计
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/finance/reimbursementReport/index'
WHERE m.menu_name = '报销统计' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/finance/reimbursementReport/index');

-- =============================================
-- 六、更新 sys_app_menu.app_path - 考勤管理
-- =============================================

-- 考勤打卡
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/attendance/index'
WHERE m.menu_name = '考勤打卡' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/attendance/index');

-- 考勤记录（打卡记录）
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/attendance/record'
WHERE m.menu_name IN ('考勤记录', '打卡记录') AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/attendance/record');

-- 考勤配置
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/attendance/config'
WHERE m.menu_name = '考勤配置' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/attendance/config');

-- 考勤规则
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/attendance/rule'
WHERE m.menu_name = '考勤规则' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/attendance/rule');

-- =============================================
-- 七、更新 sys_app_menu.app_path - 系统管理（有APP页面的）
-- =============================================

-- 用户管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/user/index'
WHERE m.menu_name = '用户管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/user/index');

-- 角色管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/role/index'
WHERE m.menu_name = '角色管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/role/index');

-- 部门管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/dept/index'
WHERE m.menu_name = '部门管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/dept/index');

-- 岗位管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/post/index'
WHERE m.menu_name = '岗位管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/post/index');

-- 字典管理
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/dict/index'
WHERE m.menu_name = '字典管理' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/dict/index');

-- 通知公告
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_path = '/pages/system/notice/index'
WHERE m.menu_name = '通知公告' AND m.menu_type = 'C'
  AND (sam.app_path IS NULL OR sam.app_path = '' OR sam.app_path != '/pages/system/notice/index');

-- =============================================
-- 八、创建缺失的 sys_app_menu 记录
-- 为 sys_menu 中存在但 sys_app_menu 中缺失的菜单补全扩展配置
-- =============================================

-- ---------- 业务管理子菜单 ----------

-- 企业管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/enterprise/index', 'home-fill', '#FF6B35', '#fff', 1, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '企业管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 门店管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/store/index', 'home', '#FF6B35', '#fff', 2, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '门店管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 行程安排
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/schedule/index', 'calendar', '#FF6B35', '#fff', 3, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '行程安排' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 销售开单
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/sales/index', 'edit-pen', '#FF6B35', '#fff', 4, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '销售开单' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 订单管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/order/index', 'list', '#FF6B35', '#fff', 5, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '订单管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 方案管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/plan/index', 'file-text', '#FF6B35', '#fff', 6, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '方案管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 卡项管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/cardItem/index', 'star', '#FF6B35', '#fff', 7, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '卡项管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 备货管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/stockPrepare/index', 'shopping-cart', '#FF6B35', '#fff', 8, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '备货管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 客户管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/business/customer/index', 'account', '#FF6B35', '#fff', 9, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '客户管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- ---------- 进销存管理(WMS)子菜单 ----------

-- 供货商管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/supplier/index', 'account', '#10B981', '#fff', 1, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '供货商管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 货品管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/product/index', 'list', '#10B981', '#fff', 2, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '货品管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 入库管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/stockIn/index', 'arrow-down', '#10B981', '#fff', 3, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '入库管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 出库管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/shipment/index', 'arrow-up', '#10B981', '#fff', 4, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '出库管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 库存查看
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/stock/index', 'search', '#10B981', '#fff', 5, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '库存查看' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 库存盘点
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/wms/stockCheck/index', 'checkmark-circle', '#10B981', '#fff', 6, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '库存盘点' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- ---------- 财务管理子菜单 ----------

-- 方案审核
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/finance/planAudit/index', 'checkmark', '#10B981', '#fff', 1, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '方案审核' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 报销管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/finance/reimbursement/index', 'edit-pen', '#3B82F6', '#fff', 2, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '报销管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 报销统计
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/finance/reimbursementReport/index', 'level', '#8B5CF6', '#fff', 3, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '报销统计' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- ---------- 考勤管理子菜单 ----------

-- 考勤打卡
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/attendance/index', 'clock', '#F59E0B', '#fff', 1, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '考勤打卡' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 考勤记录（打卡记录）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/attendance/record', 'file-text', '#F59E0B', '#fff', 2, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name IN ('考勤记录', '打卡记录') AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 考勤配置
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/attendance/config', 'grid', '#F59E0B', '#fff', 3, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '考勤配置' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 考勤规则
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/attendance/rule', 'setting', '#F59E0B', '#fff', 4, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '考勤规则' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- ---------- 系统管理子菜单（有APP页面的） ----------

-- 用户管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/user/index', 'account', '#3D6DF7', '#fff', 1, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '用户管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 角色管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/role/index', 'man-add', '#3D6DF7', '#fff', 2, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '角色管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 部门管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/dept/index', 'home', '#3D6DF7', '#fff', 3, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '部门管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 岗位管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/post/index', 'bookmark', '#3D6DF7', '#fff', 4, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '岗位管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 字典管理
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/dict/index', 'file-text', '#3D6DF7', '#fff', 4, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '字典管理' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 通知公告
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '/pages/system/notice/index', 'chat', '#3D6DF7', '#fff', 5, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '通知公告' AND m.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- ---------- 一级目录的 sys_app_menu 记录 ----------

-- 业务管理目录
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#FF6B35', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '业务管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 进销存管理目录
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#3D6DF7', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '进销存管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 财务管理目录
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#8B5CF6', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '财务管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 考勤管理目录
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#F59E0B', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '考勤管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- 系统管理目录
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
SELECT m.menu_id, '', '', '#3D6DF7', '#fff', m.order_num, 1, 'admin'
FROM `sys_menu` m
WHERE m.menu_name = '系统管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_app_menu` sam WHERE sam.menu_id = m.menu_id);

-- =============================================
-- 八-B、修复无效APP图标名（非uView有效图标名，导致显示英文文字）
-- =============================================

-- 门店管理: shop → home
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_icon = 'home'
WHERE m.menu_name = '门店管理' AND m.menu_type = 'C' AND sam.app_icon = 'shop';

-- 卡项管理: component → star
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_icon = 'star'
WHERE m.menu_name = '卡项管理' AND m.menu_type = 'C' AND sam.app_icon = 'component';

-- 方案审核: edit → checkmark
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_icon = 'checkmark'
WHERE m.menu_name = '方案审核' AND m.menu_type = 'C' AND sam.app_icon = 'edit';

-- 报销管理: form → edit-pen
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_icon = 'edit-pen'
WHERE m.menu_name = '报销管理' AND m.menu_type = 'C' AND sam.app_icon = 'form';

-- 报销统计: chart → level
UPDATE `sys_app_menu` sam
INNER JOIN `sys_menu` m ON sam.menu_id = m.menu_id
SET sam.app_icon = 'level'
WHERE m.menu_name = '报销统计' AND m.menu_type = 'C' AND sam.app_icon = 'chart';

-- 修复 app_menu_config 旧版兼容表
UPDATE `app_menu_config` SET `icon` = 'home' WHERE `title` = '门店管理' AND `icon` = 'shop';
UPDATE `app_menu_config` SET `icon` = 'star' WHERE `title` = '卡项管理' AND `icon` = 'component';
UPDATE `app_menu_config` SET `icon` = 'checkmark' WHERE `title` = '方案审核' AND `icon` = 'edit';
UPDATE `app_menu_config` SET `icon` = 'edit-pen' WHERE `title` = '报销管理' AND `icon` = 'form';
UPDATE `app_menu_config` SET `icon` = 'level' WHERE `title` = '报销统计' AND `icon` = 'chart';

-- =============================================
-- 九、为管理员角色(role_id=1)分配所有APP菜单权限
-- 包括一级目录、子菜单及按钮权限
-- =============================================

SET @admin_role_id = 1;

-- ---------- 业务管理目录及子菜单权限 ----------

-- 业务管理目录
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_name = '业务管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

-- 业务管理下所有子菜单
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0 LIMIT 1) t)
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

-- 业务管理下所有按钮权限（二级子菜单的子项）
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
INNER JOIN `sys_menu` pm ON sm.parent_id = pm.menu_id
WHERE pm.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0 LIMIT 1) t)
  AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = sm.menu_id);

-- ---------- 进销存管理目录及子菜单权限 ----------

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_name = '进销存管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '进销存管理' AND parent_id = 0 LIMIT 1) t)
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
INNER JOIN `sys_menu` pm ON sm.parent_id = pm.menu_id
WHERE pm.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '进销存管理' AND parent_id = 0 LIMIT 1) t)
  AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = sm.menu_id);

-- ---------- 财务管理目录及子菜单权限 ----------

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_name = '财务管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '财务管理' AND parent_id = 0 LIMIT 1) t)
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
INNER JOIN `sys_menu` pm ON sm.parent_id = pm.menu_id
WHERE pm.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '财务管理' AND parent_id = 0 LIMIT 1) t)
  AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = sm.menu_id);

-- ---------- 考勤管理目录及子菜单权限 ----------

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_name = '考勤管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0 LIMIT 1) t)
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
INNER JOIN `sys_menu` pm ON sm.parent_id = pm.menu_id
WHERE pm.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0 LIMIT 1) t)
  AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = sm.menu_id);

-- ---------- 系统管理目录及子菜单权限（仅APP相关菜单） ----------

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.menu_name = '系统管理' AND m.parent_id = 0 AND m.menu_type = 'M'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

-- 系统管理下有APP页面的子菜单：用户管理、角色管理、部门管理、岗位管理、字典管理、通知公告
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, m.menu_id FROM `sys_menu` m
WHERE m.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '系统管理' AND parent_id = 0 LIMIT 1) t)
  AND m.menu_name IN ('用户管理', '角色管理', '部门管理', '岗位管理', '字典管理', '通知公告')
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = m.menu_id);

-- 这些系统菜单的按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, sm.menu_id FROM `sys_menu` sm
INNER JOIN `sys_menu` pm ON sm.parent_id = pm.menu_id
WHERE pm.parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '系统管理' AND parent_id = 0 LIMIT 1) t)
  AND pm.menu_name IN ('用户管理', '角色管理', '部门管理', '岗位管理', '字典管理', '通知公告')
  AND sm.menu_type = 'F'
  AND NOT EXISTS (SELECT 1 FROM `sys_role_menu` WHERE role_id = @admin_role_id AND menu_id = sm.menu_id);

-- =============================================
-- 十、同步更新 app_menu_config 旧版兼容表的路径
-- =============================================

UPDATE `app_menu_config` SET `path` = '/pages/business/enterprise/index' WHERE `group_key` = 'business' AND `title` = '企业管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/enterprise/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/store/index' WHERE `group_key` = 'business' AND `title` = '门店管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/store/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/schedule/index' WHERE `group_key` = 'business' AND `title` = '行程安排' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/schedule/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/sales/index' WHERE `group_key` = 'business' AND `title` = '销售开单' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/sales/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/order/index' WHERE `group_key` = 'business' AND `title` = '订单管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/order/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/plan/index' WHERE `group_key` = 'business' AND `title` = '方案管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/plan/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/cardItem/index' WHERE `group_key` = 'business' AND `title` = '卡项管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/cardItem/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/stockPrepare/index' WHERE `group_key` = 'business' AND `title` = '备货管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/stockPrepare/index');
UPDATE `app_menu_config` SET `path` = '/pages/business/customer/index' WHERE `group_key` = 'business' AND `title` = '客户管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/business/customer/index');

UPDATE `app_menu_config` SET `path` = '/pages/wms/supplier/index' WHERE `group_key` = 'wms' AND `title` = '供货商管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/supplier/index');
UPDATE `app_menu_config` SET `path` = '/pages/wms/product/index' WHERE `group_key` = 'wms' AND `title` = '货品管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/product/index');
UPDATE `app_menu_config` SET `path` = '/pages/wms/stockIn/index' WHERE `group_key` = 'wms' AND `title` = '入库管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/stockIn/index');
UPDATE `app_menu_config` SET `path` = '/pages/wms/shipment/index' WHERE `group_key` = 'wms' AND `title` = '出库管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/shipment/index');
UPDATE `app_menu_config` SET `path` = '/pages/wms/stock/index' WHERE `group_key` = 'wms' AND `title` = '库存查看' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/stock/index');
UPDATE `app_menu_config` SET `path` = '/pages/wms/stockCheck/index' WHERE `group_key` = 'wms' AND `title` = '库存盘点' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/wms/stockCheck/index');

UPDATE `app_menu_config` SET `path` = '/pages/finance/planAudit/index' WHERE `group_key` = 'finance' AND `title` = '方案审核' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/finance/planAudit/index');
UPDATE `app_menu_config` SET `path` = '/pages/finance/reimbursement/index' WHERE `group_key` = 'finance' AND `title` = '报销管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/finance/reimbursement/index');
UPDATE `app_menu_config` SET `path` = '/pages/finance/reimbursementReport/index' WHERE `group_key` = 'finance' AND `title` = '报销统计' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/finance/reimbursementReport/index');

UPDATE `app_menu_config` SET `path` = '/pages/attendance/index' WHERE `group_key` = 'attendance' AND `title` = '考勤打卡' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/attendance/index');
UPDATE `app_menu_config` SET `path` = '/pages/attendance/record' WHERE `group_key` = 'attendance' AND `title` IN ('考勤记录', '打卡记录') AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/attendance/record');
UPDATE `app_menu_config` SET `path` = '/pages/attendance/config' WHERE `group_key` = 'attendance' AND `title` = '考勤配置' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/attendance/config');
UPDATE `app_menu_config` SET `path` = '/pages/attendance/rule' WHERE `group_key` = 'attendance' AND `title` = '考勤规则' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/attendance/rule');

UPDATE `app_menu_config` SET `path` = '/pages/system/user/index' WHERE `group_key` = 'system' AND `title` = '用户管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/user/index');
UPDATE `app_menu_config` SET `path` = '/pages/system/role/index' WHERE `group_key` = 'system' AND `title` = '角色管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/role/index');
UPDATE `app_menu_config` SET `path` = '/pages/system/dept/index' WHERE `group_key` = 'system' AND `title` = '部门管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/dept/index');
UPDATE `app_menu_config` SET `path` = '/pages/system/post/index' WHERE `group_key` = 'system' AND `title` = '岗位管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/post/index');
UPDATE `app_menu_config` SET `path` = '/pages/system/dict/index' WHERE `group_key` = 'system' AND `title` = '字典管理' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/dict/index');
UPDATE `app_menu_config` SET `path` = '/pages/system/notice/index' WHERE `group_key` = 'system' AND `title` = '通知公告' AND (`path` IS NULL OR `path` = '' OR `path` != '/pages/system/notice/index');
