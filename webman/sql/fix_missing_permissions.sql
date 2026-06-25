-- 补充缺失的权限标识
-- 执行前请确认相关菜单已存在

-- 1. 备货从方案创建权限（business:stockPrepare:createFromPlan）
-- 父菜单：备货管理（perms = 'business:stockPrepare'）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `remark`) VALUES
('备货创建', (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE perms = 'business:stockPrepare' LIMIT 1) t), 6, '', NULL, 1, 0, 'F', '0', '0', 'business:stockPrepare:createFromPlan', '#', 'admin', NOW(), '从方案创建备货');


