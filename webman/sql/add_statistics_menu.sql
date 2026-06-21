-- 数据统计菜单 SQL
-- 一级菜单：数据统计
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
(3080, '数据统计', 0, 3, 'statistics', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'chart', 'admin', NOW(), '', NULL, '数据统计目录');

-- 二级菜单：业绩统计
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
(3081, '业绩统计', 3080, 1, 'performance', 'statistics/performance/index', NULL, 'PerformanceStats', 1, 0, 'C', '0', '0', 'all', 'statistics:performance:list', 'peoples', 'admin', NOW(), '', NULL, '业绩统计菜单');

-- 二级菜单：企业业绩
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
(3082, '企业业绩', 3080, 2, 'enterprise', 'statistics/enterprise/index', NULL, 'EnterpriseStats', 1, 0, 'C', '0', '0', 'all', 'statistics:enterprise:list', 'build', 'admin', NOW(), '', NULL, '企业业绩菜单');

-- 为管理员角色(role_id=1)分配新菜单权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(1, 3080),
(1, 3081),
(1, 3082);
