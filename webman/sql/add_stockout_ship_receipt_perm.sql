-- =================================================================
-- 进销存权限标识完整性修复
-- 补充数据库 sys_menu 缺失的权限标识
-- 执行前请确认菜单ID：出库管理=2041, 仓库管理=3067, 盘点新增=2052
-- =================================================================

-- 1. 出库管理补充发货权限标识
-- parent_id=2041 为出库管理菜单ID
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms_scope`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('出库发货', 2041, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:ship', '#', 'admin', NOW(), '', NULL, ''),
('出库收货', 2041, 8, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:receipt', '#', 'admin', NOW(), '', NULL, '');

-- 2. 仓库管理补充用户授权权限标识
-- parent_id=3067 为仓库管理菜单ID
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms_scope`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
('仓库授权', 3067, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:warehouse:assign', '#', 'admin', NOW(), '', NULL, '');

-- 3. 修正盘点新增菜单名繁体字
UPDATE `sys_menu` SET `menu_name` = '盘点新增' WHERE `menu_id` = 2052 AND `menu_name` = '盘點新增';
