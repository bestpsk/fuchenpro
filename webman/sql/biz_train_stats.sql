-- =============================================
-- 培训学习统计 + 材料授权管理 数据库脚本
-- 执行顺序：1.建表 -> 2.Web菜单 -> 3.App菜单扩展 -> 4.角色分配
-- =============================================

-- 1. 创建培训材料授权表
DROP TABLE IF EXISTS `biz_train_material_auth`;
CREATE TABLE `biz_train_material_auth` (
  `auth_id` bigint NOT NULL AUTO_INCREMENT COMMENT '授权ID',
  `material_id` bigint NOT NULL COMMENT '材料ID',
  `target_type` char(1) NOT NULL COMMENT '授权对象类型(1=用户 2=部门)',
  `target_id` bigint NOT NULL COMMENT '用户ID或部门ID',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`auth_id`),
  UNIQUE KEY `uk_material_target` (`material_id`, `target_type`, `target_id`),
  KEY `idx_material_id` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训材料授权表';

-- =============================================
-- 2. Web菜单数据
-- =============================================
-- 获取培训管理顶级目录ID
SET @train_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '培训管理' AND parent_id = 0) t);

-- 2.1 学习统计菜单
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('学习统计', @train_menu_id, 3, 'stats', 'train/stats/index', NULL, 'TrainStats', 1, 0, 'C', '0', '0', 'train:stats:list', 'chart', 'admin', NOW());
SET @stats_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习统计' AND path = 'stats') t);

-- 2.2 学习统计按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('统计查询', @stats_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:stats:query', '#', 'admin', NOW()),
('统计导出', @stats_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:stats:export', '#', 'admin', NOW());

-- 2.3 学习材料增加授权管理按钮权限
SET @material_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习材料' AND path = 'material') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('材料授权', @material_menu_id, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:auth', '#', 'admin', NOW());

-- =============================================
-- 3. App移动端菜单扩展
-- =============================================
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@stats_menu_id, '/pages/train/stats', 'bar-chart', '#10B981', '#fff', 3, 1, 'admin');

-- =============================================
-- 4. 为管理员角色分配权限
-- =============================================
SET @admin_role_id = 1;
-- 分配学习统计菜单及按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(@admin_role_id, @stats_menu_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @stats_menu_id;
-- 分配材料授权按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE perms = 'train:material:auth' AND parent_id = @material_menu_id;
