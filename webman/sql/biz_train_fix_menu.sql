-- =============================================
-- 培训模块菜单修复脚本
-- 修复：删除错误的顶级菜单"学习培训"，改为在"培训管理"下新增"在线学习"
-- 执行前请确保 biz_train.sql 已执行
-- =============================================

-- 1. 删除之前创建的"学习培训"顶级菜单及其子菜单（如果存在）
DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE menu_name IN ('学习培训', '在线学习', '材料预览')
);
DELETE FROM sys_app_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE menu_name IN ('学习培训', '在线学习', '材料预览')
);
DELETE FROM sys_menu WHERE menu_name IN ('学习培训', '在线学习', '材料预览');

-- 2. 获取"培训管理"菜单ID
SET @train_root_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '培训管理' AND parent_id = 0) t);

-- 3. 新增"在线学习"子菜单（放在培训管理下）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('在线学习', @train_root_id, 3, 'online', 'train/online/index', NULL, 'TrainOnline', 1, 0, 'C', '0', '0', 'train:study:list', 'education', 'admin', NOW());
SET @online_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '在线学习' AND path = 'online') t);

-- 4. 新增"材料预览"隐藏路由（用于详情页）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('材料预览', @train_root_id, 4, 'preview', 'train/preview/index', NULL, 'TrainPreview', 1, 0, 'C', '1', '0', 'train:study:preview', 'view', 'admin', NOW());

-- 5. App端菜单配置（更新现有"学习材料"入口指向在线学习）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@online_id, '/pages/train/index', 'book-fill', '#10B981', '#fff', 3, 1, 'admin')
ON DUPLICATE KEY UPDATE app_path = '/pages/train/index', app_icon = 'book-fill', bg_color = '#10B981';

-- 6. 为管理员角色分配新菜单
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(@admin_role_id, @online_id)
ON DUPLICATE KEY UPDATE role_id = role_id;