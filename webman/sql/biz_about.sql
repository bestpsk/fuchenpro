-- =============================================
-- 企业小报模块
-- 在"行政管理"菜单下新增"企业小报"管理，App端可查看
-- 执行前请确保 biz_admin.sql 已执行（行政管理菜单已存在）
-- =============================================

-- 1. 企业小报表
CREATE TABLE IF NOT EXISTS `biz_about` (
  `about_id` bigint NOT NULL AUTO_INCREMENT COMMENT '介绍ID',
  `about_title` varchar(200) NOT NULL COMMENT '标题',
  `cover_url` varchar(500) DEFAULT '' COMMENT '封面图URL',
  `about_content` longtext COMMENT '富文本内容',
  `status` char(1) DEFAULT '0' COMMENT '状态(0正常 1关闭)',
  `sort` int DEFAULT 0 COMMENT '排序',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`about_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业小报表';

-- 2. 菜单：在"行政管理"下新增"企业小报"
SET @admin_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '行政管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('企业小报', @admin_menu_id, 2, 'about', 'admin/about/index', NULL, 'AdminAbout', 1, 0, 'C', '0', '0', 'admin:about:list', 'build', 'admin', NOW());
SET @about_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '企业小报' AND path = 'about') t);

-- 3. 按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('介绍查询', @about_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:about:query', '#', 'admin', NOW()),
('介绍新增', @about_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:about:add', '#', 'admin', NOW()),
('介绍修改', @about_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:about:edit', '#', 'admin', NOW()),
('介绍删除', @about_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:about:remove', '#', 'admin', NOW());

-- 4. 为管理员角色分配权限
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @about_menu_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @about_menu_id;

-- 5. 已有表补充封面图字段（如果表已存在则执行此ALTER语句）
-- ALTER TABLE `biz_about` ADD COLUMN `cover_url` varchar(500) DEFAULT '' COMMENT '封面图URL' AFTER `about_title`;
