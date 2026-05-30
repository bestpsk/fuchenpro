-- =============================================
-- 行政管理 - 问题反馈模块
-- =============================================

-- 1. 反馈表
CREATE TABLE `biz_feedback` (
  `feedback_id` bigint NOT NULL AUTO_INCREMENT COMMENT '反馈ID',
  `title` varchar(200) NOT NULL COMMENT '反馈标题',
  `content` text NOT NULL COMMENT '反馈内容',
  `feedback_type` char(1) DEFAULT '0' COMMENT '反馈类型(0功能异常 1优化建议 2其他)',
  `status` char(1) DEFAULT '0' COMMENT '处理状态(0待处理 1处理中 2已处理 3已关闭)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`feedback_id`),
  KEY `idx_create_by` (`create_by`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='问题反馈表';

-- 2. 反馈回复表
CREATE TABLE `biz_feedback_reply` (
  `reply_id` bigint NOT NULL AUTO_INCREMENT COMMENT '回复ID',
  `feedback_id` bigint NOT NULL COMMENT '反馈ID',
  `content` text NOT NULL COMMENT '回复内容',
  `create_by` varchar(64) DEFAULT '' COMMENT '回复人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
  PRIMARY KEY (`reply_id`),
  KEY `idx_feedback_id` (`feedback_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='反馈回复表';

-- 3. 字典类型
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('反馈类型', 'biz_feedback_type', '0', 'admin', NOW(), '反馈类型列表');

INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('反馈状态', 'biz_feedback_status', '0', 'admin', NOW(), '反馈处理状态列表');

-- 4. 字典数据
INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '工作问题', '0', 'biz_feedback_type', '', 'danger', 'Y', '0', 'admin', NOW()),
(2, '优化建议', '1', 'biz_feedback_type', '', 'warning', 'N', '0', 'admin', NOW()),
(3, '其他', '2', 'biz_feedback_type', '', 'info', 'N', '0', 'admin', NOW());

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '待处理', '0', 'biz_feedback_status', '', 'info', 'Y', '0', 'admin', NOW()),
(2, '处理中', '1', 'biz_feedback_status', '', 'warning', 'N', '0', 'admin', NOW()),
(3, '已处理', '2', 'biz_feedback_status', '', 'success', 'N', '0', 'admin', NOW()),
(4, '已关闭', '3', 'biz_feedback_status', '', 'info', 'N', '0', 'admin', NOW());

-- 5. 一级目录：行政管理
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('行政管理', 0, 5, 'admin', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'clipboard', 'admin', NOW());

-- 6. 二级菜单：问题反馈
SET @admin_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '行政管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('问题反馈', @admin_menu_id, 1, 'feedback', 'admin/feedback/index', NULL, 'AdminFeedback', 1, 0, 'C', '0', '0', 'admin:feedback:list', 'message', 'admin', NOW());

-- 7. 按钮权限
SET @feedback_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '问题反馈' AND path = 'feedback') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('反馈查询', @feedback_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:query', '#', 'admin', NOW()),
('反馈新增', @feedback_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:add', '#', 'admin', NOW()),
('反馈修改', @feedback_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:edit', '#', 'admin', NOW()),
('反馈删除', @feedback_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:remove', '#', 'admin', NOW()),
('反馈处理', @feedback_menu_id, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:handle', '#', 'admin', NOW());

-- 8. 为管理员角色分配菜单权限
SET @admin_role_id = 1;
SET @admin_dir_menu = (SELECT menu_id FROM sys_menu WHERE menu_name = '行政管理' AND parent_id = 0);
SET @feedback_menu = (SELECT menu_id FROM sys_menu WHERE menu_name = '问题反馈' AND path = 'feedback');
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @admin_dir_menu);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @feedback_menu);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @feedback_menu;
