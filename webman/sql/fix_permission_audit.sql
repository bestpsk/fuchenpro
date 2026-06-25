-- =============================================
-- 权限配置审计修复脚本
-- 修复内容：删除冗余/孤立/未使用权限，新增缺失权限
-- =============================================

-- =============================================
-- 1. 删除冗余重复的按钮权限（ID 2094-2100，与 3004-3012 重复）
-- =============================================

-- 先删除 sys_role_menu 中的引用
DELETE FROM `sys_role_menu` WHERE `menu_id` IN (2094, 2095, 2096, 2097, 2098, 2099, 2100);

-- 再删除 sys_menu 中的冗余记录
DELETE FROM `sys_menu` WHERE `menu_id` IN (2094, 2095, 2096, 2097, 2098, 2099, 2100);

-- =============================================
-- 2. 删除 sys_role_menu 中的孤立引用（menu_id 不存在于 sys_menu）
-- =============================================

DELETE FROM `sys_role_menu` WHERE `menu_id` IN (3039, 3047, 3048, 3049, 3050, 3052, 3053, 3054, 3056, 3057);

-- =============================================
-- 3. 删除未使用的 business:sales:* 按钮权限（ID 2066-2071）
-- =============================================

-- 先删除 sys_role_menu 中的引用
DELETE FROM `sys_role_menu` WHERE `menu_id` IN (2066, 2067, 2068, 2069, 2070, 2071);

-- 再删除 sys_menu 中的记录
DELETE FROM `sys_menu` WHERE `menu_id` IN (2066, 2067, 2068, 2069, 2070, 2071);

-- =============================================
-- 4. 新增缺失的按钮权限
-- =============================================

-- 销售开单 (parent_id=2065) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('销售开单新增', 2065, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:salesOrder:add', '#', 'admin', NOW(), NULL, NULL, ''),
('操作记录新增', 2065, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:operation:add', '#', 'admin', NOW(), NULL, NULL, ''),
('还款新增', 2065, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:repayment:add', '#', 'admin', NOW(), NULL, NULL, ''),
('还款审核', 2065, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:repayment:audit', '#', 'admin', NOW(), NULL, NULL, ''),
('还款取消', 2065, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:repayment:cancel', '#', 'admin', NOW(), NULL, NULL, ''),
('归档新增', 2065, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:archive:add', '#', 'admin', NOW(), NULL, NULL, ''),
('归档删除', 2065, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:archive:remove', '#', 'admin', NOW(), NULL, NULL, '');

-- 订单管理 (parent_id=2072) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('订单取消', 2072, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:cancel', '#', 'admin', NOW(), NULL, NULL, ''),
('订单导出', 2072, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:export', '#', 'admin', NOW(), NULL, NULL, '');

-- 方案管理 (parent_id=2076) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('方案导出', 2076, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:export', '#', 'admin', NOW(), NULL, NULL, '');

-- 企业备货 (parent_id=3044) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('备货导出', 3044, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:export', '#', 'admin', NOW(), NULL, NULL, '');

-- 卡项管理 (parent_id=3034) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('卡项导出', 3034, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:export', '#', 'admin', NOW(), NULL, NULL, '');

-- 出库管理 (parent_id=2041) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('发货确认', 2041, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:ship', '#', 'admin', NOW(), NULL, NULL, ''),
('回单确认', 2041, 8, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:receipt', '#', 'admin', NOW(), NULL, NULL, '');

-- 数据库备份 (parent_id=3083) 下的按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('备份新增', 3083, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:backup:add', '#', 'admin', NOW(), NULL, NULL, ''),
('备份删除', 3083, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:backup:remove', '#', 'admin', NOW(), NULL, NULL, '');

-- =============================================
-- 5. 为 role_id=1 (admin) 添加新增权限的引用
-- =============================================

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT 1, `menu_id` FROM `sys_menu`
WHERE `perms` IN (
    'business:salesOrder:add',
    'business:operation:add',
    'business:repayment:add',
    'business:repayment:audit',
    'business:repayment:cancel',
    'business:archive:add',
    'business:archive:remove',
    'business:order:cancel',
    'business:order:export',
    'business:plan:export',
    'business:stockPrepare:export',
    'business:cardItem:export',
    'wms:stockOut:ship',
    'wms:stockOut:receipt',
    'system:backup:add',
    'system:backup:remove'
)
AND `menu_id` NOT IN (SELECT `menu_id` FROM `sys_role_menu` WHERE `role_id` = 1);
