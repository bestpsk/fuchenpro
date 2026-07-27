-- =============================================
-- 培训管理模块数据库脚本
-- 执行顺序：1.建表 -> 2.字典类型 -> 3.字典数据 -> 4.Web菜单 -> 5.App菜单扩展 -> 6.角色分配
-- 说明：record/score/review_plan 三张表本次建表预留，MVP仅实现 material 与 study_log 功能
-- =============================================

-- 1. 创建培训学习材料表
DROP TABLE IF EXISTS `biz_train_material`;
CREATE TABLE `biz_train_material` (
  `material_id` bigint NOT NULL AUTO_INCREMENT COMMENT '材料ID',
  `title` varchar(200) NOT NULL COMMENT '材料标题',
  `category` char(2) DEFAULT '1' COMMENT '材料分类(1产品知识 2销售话术 3专业理论 4考核资料)',
  `file_type` char(2) NOT NULL COMMENT '文件类型(1图片 2PDF 3PPT 4Word 5文本)',
  `file_url` varchar(500) NOT NULL COMMENT '原始文件存储路径(fileName)',
  `file_size` bigint DEFAULT 0 COMMENT '文件大小(字节)',
  `cover_url` varchar(500) DEFAULT NULL COMMENT '封面图URL',
  `description` text DEFAULT NULL COMMENT '材料简介',
  `study_duration` int DEFAULT 0 COMMENT '建议学习时长(秒)',
  `sort` int DEFAULT 0 COMMENT '排序',
  `status` char(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志(0存在 2删除)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`material_id`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训学习材料表';

-- 2. 创建学习日志表
DROP TABLE IF EXISTS `biz_train_study_log`;
CREATE TABLE `biz_train_study_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint NOT NULL COMMENT '学习用户ID',
  `material_id` bigint NOT NULL COMMENT '材料ID',
  `session_id` varchar(64) NOT NULL COMMENT '学习会话ID(防伪造)',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `valid_duration` int DEFAULT 0 COMMENT '有效学习时长(秒,后端校验)',
  `pause_count` int DEFAULT 0 COMMENT '暂停次数',
  `switch_count` int DEFAULT 0 COMMENT '切屏次数',
  `status` char(1) DEFAULT '0' COMMENT '状态(0进行中 1已结束 2异常中断)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `uk_session` (`session_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_material_id` (`material_id`),
  KEY `idx_user_material` (`user_id`, `material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训学习日志表';

-- 3. 录音记录表（预留，本次建表不实现功能）
DROP TABLE IF EXISTS `biz_train_record`;
CREATE TABLE `biz_train_record` (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '录音ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `material_id` bigint NOT NULL COMMENT '材料ID',
  `mode` char(1) DEFAULT '1' COMMENT '模式(1逐句跟读 2全文背诵 3关键词填空)',
  `file_url` varchar(500) DEFAULT NULL COMMENT '录音文件路径',
  `duration` int DEFAULT 0 COMMENT '录音时长(秒)',
  `status` char(1) DEFAULT '0' COMMENT '状态(0待评分 1已评分)',
  `score` int DEFAULT NULL COMMENT '评分(0-100)',
  `score_remark` varchar(500) DEFAULT NULL COMMENT '评分备注',
  `score_by` varchar(64) DEFAULT NULL COMMENT '评分人',
  `score_time` datetime DEFAULT NULL COMMENT '评分时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_material_id` (`material_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='背诵录音记录表';

-- 4. 评分表（预留，本次建表不实现功能）
DROP TABLE IF EXISTS `biz_train_score`;
CREATE TABLE `biz_train_score` (
  `score_id` bigint NOT NULL AUTO_INCREMENT COMMENT '评分ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `material_id` bigint NOT NULL COMMENT '材料ID',
  `record_id` bigint DEFAULT NULL COMMENT '关联录音ID',
  `score_type` char(1) DEFAULT '1' COMMENT '评分类型(1背诵 2考核)',
  `score` int NOT NULL COMMENT '得分(0-100)',
  `score_remark` varchar(500) DEFAULT NULL COMMENT '评分备注',
  `score_by` varchar(64) NOT NULL COMMENT '评分人',
  `score_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评分时间',
  PRIMARY KEY (`score_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_material_id` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训评分表';

-- 5. 复习计划表（预留，本次建表不实现功能）
DROP TABLE IF EXISTS `biz_train_review_plan`;
CREATE TABLE `biz_train_review_plan` (
  `plan_id` bigint NOT NULL AUTO_INCREMENT COMMENT '复习计划ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `material_id` bigint NOT NULL COMMENT '材料ID',
  `next_review_date` date NOT NULL COMMENT '下次复习日期',
  `review_count` int DEFAULT 0 COMMENT '已复习次数',
  `ease_factor` decimal(3,2) DEFAULT 2.50 COMMENT '难度系数(Anki SM-2)',
  `interval_days` int DEFAULT 1 COMMENT '复习间隔(天)',
  `status` char(1) DEFAULT '0' COMMENT '状态(0待复习 1已完成 2已过期)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`plan_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_next_review_date` (`next_review_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='间隔重复复习计划表';

-- =============================================
-- 6. 字典类型
-- =============================================
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('材料分类', 'biz_train_material_category', '0', 'admin', NOW(), '培训材料分类列表');
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('材料文件类型', 'biz_train_material_file_type', '0', 'admin', NOW(), '培训材料文件类型列表');
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('学习状态', 'biz_train_study_status', '0', 'admin', NOW(), '培训学习会话状态');

-- =============================================
-- 7. 字典数据
-- =============================================
INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '产品知识', '1', 'biz_train_material_category', '', 'primary', 'Y', '0', 'admin', NOW()),
(2, '销售话术', '2', 'biz_train_material_category', '', 'success', 'N', '0', 'admin', NOW()),
(3, '专业理论', '3', 'biz_train_material_category', '', 'warning', 'N', '0', 'admin', NOW()),
(4, '考核资料', '4', 'biz_train_material_category', '', 'danger', 'N', '0', 'admin', NOW());

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '图片', '1', 'biz_train_material_file_type', '', 'primary', 'N', '0', 'admin', NOW()),
(2, 'PDF', '2', 'biz_train_material_file_type', '', 'success', 'N', '0', 'admin', NOW()),
(3, 'PPT', '3', 'biz_train_material_file_type', '', 'warning', 'N', '0', 'admin', NOW()),
(4, 'Word', '4', 'biz_train_material_file_type', '', 'info', 'N', '0', 'admin', NOW()),
(5, '文本', '5', 'biz_train_material_file_type', '', '', 'N', '0', 'admin', NOW());

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '进行中', '0', 'biz_train_study_status', '', 'primary', 'N', '0', 'admin', NOW()),
(2, '已结束', '1', 'biz_train_study_status', '', 'success', 'N', '0', 'admin', NOW()),
(3, '异常中断', '2', 'biz_train_study_status', '', 'danger', 'N', '0', 'admin', NOW());

-- =============================================
-- 8. Web菜单数据（顶级目录 + 子菜单 + 按钮权限）
-- =============================================
-- 8.1 顶级目录：培训管理
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('培训管理', 0, 7, 'train', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'train:list', 'education', 'admin', NOW());
SET @train_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '培训管理' AND parent_id = 0) t);

-- 8.2 学习材料菜单
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('学习材料', @train_menu_id, 1, 'material', 'train/material/index', NULL, 'TrainMaterial', 1, 0, 'C', '0', '0', 'train:material:list', 'documentation', 'admin', NOW());
SET @material_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习材料' AND path = 'material') t);

-- 8.3 学习材料按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('材料查询', @material_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:query', '#', 'admin', NOW()),
('材料新增', @material_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:add', '#', 'admin', NOW()),
('材料修改', @material_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:edit', '#', 'admin', NOW()),
('材料删除', @material_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:remove', '#', 'admin', NOW()),
('材料导出', @material_menu_id, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:material:export', '#', 'admin', NOW());

-- 8.4 学习记录菜单
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('学习记录', @train_menu_id, 2, 'studyLog', 'train/studyLog/index', NULL, 'TrainStudyLog', 1, 0, 'C', '0', '0', 'train:studyLog:list', 'log', 'admin', NOW());
SET @studylog_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习记录' AND path = 'studyLog') t);

-- 8.5 学习记录按钮权限
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('记录查询', @studylog_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:studyLog:query', '#', 'admin', NOW());

-- =============================================
-- 9. App移动端菜单扩展配置（sys_app_menu）
-- =============================================
-- 9.1 顶级目录：培训管理（存储分组主题色）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@train_menu_id, '', '', '#10B981', '#fff', 7, 1, 'admin');

-- 9.2 学习材料（App端跳转到学习列表页）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@material_menu_id, '/pages/train/index', 'book', '#10B981', '#fff', 1, 1, 'admin');

-- 9.3 学习记录（App端跳转到我的学习记录页）
INSERT INTO `sys_app_menu` (`menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`)
VALUES (@studylog_menu_id, '/pages/train/record', 'file-text', '#10B981', '#fff', 2, 1, 'admin');

-- =============================================
-- 10. 为管理员角色分配培训管理菜单权限
-- =============================================
SET @admin_role_id = 1;
-- 分配顶级目录及子菜单
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(@admin_role_id, @train_menu_id),
(@admin_role_id, @material_menu_id),
(@admin_role_id, @studylog_menu_id);
-- 分配按钮权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id IN (@material_menu_id, @studylog_menu_id);
