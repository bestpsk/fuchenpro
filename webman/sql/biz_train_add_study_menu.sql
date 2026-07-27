-- =============================================
-- 培训模块菜单扩展：学习培训菜单
-- 与"培训管理"(材料管理)并列的顶级菜单，专供员工在线学习查看
-- 执行前请确保 biz_train.sql 已执行
-- =============================================

-- 1. 新增"学习培训"顶级菜单（与"培训管理"平级，order_num=8）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('学习培训', 0, 8, 'trainStudy', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'train:study:list', 'reading', 'admin', NOW());
SET @study_root_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习培训' AND parent_id = 0) t);

-- 2. 子菜单：在线学习（材料列表，仅查看，无增删改）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('在线学习', @study_root_id, 1, 'online', 'trainStudy/online/index', NULL, 'TrainStudyOnline', 1, 0, 'C', '0', '0', 'train:study:list', 'education', 'admin', NOW());
SET @study_online_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '在线学习' AND path = 'online') t);

-- 3. 子菜单：材料预览（隐藏路由页，接收 materialId 参数全屏预览）
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('材料预览', @study_root_id, 2, 'preview', 'trainStudy/preview/index', NULL, 'TrainStudyPreview', 1, 0, 'C', '1', '0', 'train:study:preview', 'view', 'admin', NOW());

-- 4. 在线学习按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('材料查询', @study_online_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:study:query', '#', 'admin', NOW());

-- =============================================
-- 5. App端扩展：学习培训 app 菜单（与"学习材料"管理分开）
-- =============================================
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@study_root_id, '', '', '#3D6DF7', '#fff', 8, 1, 'admin');

INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@study_online_id, '/pages/train/index', 'book-fill', '#3D6DF7', '#fff', 1, 1, 'admin');

-- =============================================
-- 6. 为管理员角色分配学习培训菜单权限
-- =============================================
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(@admin_role_id, @study_root_id),
(@admin_role_id, @study_online_id);
-- 分配按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @study_online_id;
