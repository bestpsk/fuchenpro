-- =============================================
-- 轮播图管理模块数据库脚本
-- 执行顺序：1.建表 -> 2.菜单 -> 3.按钮权限 -> 4.角色权限 -> 5.默认数据
-- =============================================

-- 1. 创建轮播图表
DROP TABLE IF EXISTS `sys_banner`;
CREATE TABLE `sys_banner` (
  `banner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) DEFAULT '' COMMENT '标题',
  `image` varchar(500) NOT NULL COMMENT '图片地址',
  `link_url` varchar(500) DEFAULT '' COMMENT '跳转链接',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号(越小越前)',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮播图表';

-- 2. 插入菜单（放在系统管理下）
SET @system_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '系统管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('轮播图管理', @system_menu_id, 8, 'banner', 'system/banner/index', NULL, 'Banner', 1, 0, 'C', '0', '0', 'system:banner:list', 'swagger', 'admin', NOW());

-- 3. 插入按钮权限
SET @banner_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '轮播图管理' AND path = 'banner') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('轮播图查询', @banner_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:query', '#', 'admin', NOW()),
('轮播图新增', @banner_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:add', '#', 'admin', NOW()),
('轮播图修改', @banner_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:edit', '#', 'admin', NOW()),
('轮播图删除', @banner_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:remove', '#', 'admin', NOW());

-- 4. 为管理员角色分配轮播图菜单权限
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE menu_name IN ('轮播图管理', '轮播图查询', '轮播图新增', '轮播图修改', '轮播图删除') AND (parent_id = @banner_menu_id OR menu_id = @banner_menu_id);

-- 5. 插入默认轮播图数据
INSERT INTO `sys_banner` (`title`, `image`, `link_url`, `sort_order`, `status`, `remark`, `create_by`) VALUES
('欢迎使用', '/profile/upload/banner/banner01.jpg', '', 1, '0', '默认轮播图1', 'admin'),
('高效协作', '/profile/upload/banner/banner02.jpg', '', 2, '0', '默认轮播图2', 'admin'),
('智能管理', '/profile/upload/banner/banner03.jpg', '', 3, '0', '默认轮播图3', 'admin');
