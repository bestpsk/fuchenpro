-- --------------------------------------------------------
-- 主机:                           127.0.0.1
-- 服务器版本:                        8.0.12 - MySQL Community Server - GPL
-- 服务器操作系统:                      Win64
-- HeidiSQL 版本:                  11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 导出  表 fuchenpro.app_menu_config 结构
DROP TABLE IF EXISTS `app_menu_config`;
CREATE TABLE IF NOT EXISTS `app_menu_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(50) NOT NULL DEFAULT '' COMMENT '分组名称',
  `group_key` varchar(50) NOT NULL DEFAULT '' COMMENT '分组标识',
  `group_sort` int(11) NOT NULL DEFAULT '0' COMMENT '分组排序',
  `title` varchar(50) NOT NULL COMMENT '菜单标题',
  `icon` varchar(100) NOT NULL DEFAULT '' COMMENT '图标名称',
  `path` varchar(255) NOT NULL DEFAULT '' COMMENT '跳转路径',
  `perms` varchar(100) DEFAULT '' COMMENT '权限标识',
  `icon_color` varchar(20) NOT NULL DEFAULT '#3D6DF7' COMMENT '图标颜色',
  `bg_color` varchar(20) NOT NULL DEFAULT '#E8F0FE' COMMENT '图标背景色',
  `sort_order` int(11) NOT NULL DEFAULT '0' COMMENT '组内排序',
  `visible` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否显示（1显示 0隐藏）',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='App移动端菜单配置表';

-- 正在导出表  fuchenpro.app_menu_config 的数据：~50 rows (大约)
DELETE FROM `app_menu_config`;
/*!40000 ALTER TABLE `app_menu_config` DISABLE KEYS */;
INSERT INTO `app_menu_config` (`id`, `group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `perms`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(2, '常用功能', 'quick', 1, '开单', 'file-text', '/pages/business/sales/index', 'business:sales:list', '#3D6DF7', '#E8F0FE', 2, 1, '0', '', NULL, '', NULL, ''),
	(3, '常用功能', 'quick', 1, '行程', 'calendar', '/pages/business/schedule/index', 'business:schedule:list', '#3D6DF7', '#E8F0FE', 3, 1, '0', '', NULL, '', NULL, ''),
	(4, '常用功能', 'quick', 1, '订单', 'list', '/pages/business/order/index', 'business:order:list', '#3D6DF7', '#E8F0FE', 4, 1, '0', '', NULL, '', NULL, ''),
	(9, '业务管理', 'business', 2, '企业管理', 'home-fill', '/pages/business/enterprise/index', 'business:enterprise:list', '#fff', '#FF6B35', 1, 1, '0', '', NULL, '', NULL, ''),
	(10, '业务管理', 'business', 2, '门店管理', 'home', '/pages/business/store/index', 'business:store:list', '#fff', '#FF6B35', 2, 1, '0', '', NULL, '', NULL, ''),
	(11, '业务管理', 'business', 2, '行程安排', 'calendar', '/pages/business/schedule/index', 'business:schedule:list', '#fff', '#FF6B35', 3, 1, '0', '', NULL, '', NULL, ''),
	(12, '业务管理', 'business', 2, '销售开单', 'edit-pen', '/pages/business/sales/index', 'business:sales:list', '#fff', '#FF6B35', 4, 1, '0', '', NULL, '', NULL, ''),
	(14, '业务管理', 'business', 2, '订单管理', 'list', '/pages/business/order/index', 'business:order:list', '#fff', '#FF6B35', 6, 1, '0', '', NULL, '', NULL, ''),
	(15, '系统管理', 'system', 6, '用户管理', 'account', '', 'system:user:list', '#fff', '#3D6DF7', 1, 1, '0', '', NULL, '', NULL, ''),
	(16, '系统管理', 'system', 6, '角色管理', 'man-add', '', 'system:role:list', '#fff', '#3D6DF7', 2, 1, '0', '', NULL, '', NULL, ''),
	(17, '系统管理', 'system', 6, '菜单管理', 'list', '', 'system:menu:list', '#fff', '#3D6DF7', 3, 1, '0', '', NULL, '', NULL, ''),
	(18, '系统管理', 'system', 6, '部门管理', 'home', '', 'system:dept:list', '#fff', '#3D6DF7', 4, 1, '0', '', NULL, '', NULL, ''),
	(19, '系统管理', 'system', 6, '岗位管理', 'bookmark', '', 'system:post:list', '#fff', '#3D6DF7', 5, 1, '0', '', NULL, '', NULL, ''),
	(20, '系统管理', 'system', 6, '字典管理', 'file-text', '', 'system:dict:list', '#fff', '#3D6DF7', 6, 1, '0', '', NULL, '', NULL, ''),
	(21, '系统管理', 'system', 6, '参数设置', 'setting', '', 'system:config:list', '#fff', '#3D6DF7', 7, 1, '0', '', NULL, '', NULL, ''),
	(22, '系统管理', 'system', 6, '通知公告', 'chat', '', 'system:notice:list', '#fff', '#3D6DF7', 8, 1, '0', '', NULL, '', NULL, ''),
	(23, '快捷操作', 'mine_action', 7, '在线客服', 'chat', '', '', '#666', '#f5f5f5', 1, 0, '0', '', NULL, '', NULL, ''),
	(24, '快捷操作', 'mine_action', 7, '反馈社区', 'edit-pen', '', '', '#666', '#f5f5f5', 2, 0, '0', '', NULL, '', NULL, ''),
	(25, '快捷操作', 'mine_action', 7, '点赞我们', 'thumb-up', '', '', '#666', '#f5f5f5', 3, 0, '0', '', NULL, '', NULL, ''),
	(26, '快捷操作', 'mine_action', 7, '关于我们', 'info-circle', '/pages/mine/about/index', '', '#666', '#f5f5f5', 4, 0, '0', '', NULL, '', NULL, ''),
	(27, '个人菜单', 'mine_menu', 8, '编辑资料', 'edit-pen', '/pages/mine/info/edit', '', '#3c96f3', '#e8f2ff', 1, 0, '0', '', NULL, '', NULL, ''),
	(28, '个人菜单', 'mine_menu', 8, '常见问题', 'question-circle', '/pages/mine/help/index', '', '#3c96f3', '#e8f2ff', 2, 0, '0', '', NULL, '', NULL, ''),
	(29, '个人菜单', 'mine_menu', 8, '关于我们', 'info-circle', '/pages/mine/about/index', '', '#3c96f3', '#e8f2ff', 3, 0, '0', '', NULL, '', NULL, ''),
	(30, '个人菜单', 'mine_menu', 8, '应用设置', 'setting', '/pages/mine/setting/index', '', '#3c96f3', '#e8f2ff', 4, 0, '0', '', NULL, '', NULL, ''),
	(32, '进销存管理', 'wms', 4, '供货商管理', 'account', '/pages/wms/supplier/index', 'wms:supplier:list', '#fff', '#00B42A', 1, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(33, '进销存管理', 'wms', 4, '货品管理', 'grid', '', 'wms:product:list', '#fff', '#00B42A', 2, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(34, '进销存管理', 'wms', 4, '入库管理', 'arrow-down', '', 'wms:stockIn:list', '#fff', '#00B42A', 3, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(35, '进销存管理', 'wms', 4, '出库管理', 'arrow-up', '', 'wms:stockOut:list', '#fff', '#00B42A', 4, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(36, '进销存管理', 'wms', 4, '库存查看', 'list', '', 'wms:inventory:list', '#fff', '#00B42A', 5, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(37, '进销存管理', 'wms', 4, '库存盘点', 'file-text', '', 'wms:stockCheck:list', '#fff', '#00B42A', 6, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(38, '进销存管理', 'wms', 4, '进销存报表', 'chart', '', 'wms:report:list', '#fff', '#00B42A', 7, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(39, '财务管理', 'finance', 5, '方案审核', 'edit-pen', '/pages/business/plan/index', 'finance:planAudit:list', '#fff', '#F53F3F', 1, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(40, '财务管理', 'finance', 5, '报销管理', 'file-text', '', 'finance:reimbursement:list', '#fff', '#F53F3F', 2, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(41, '财务管理', 'finance', 5, '报销统计', 'chart', '', 'finance:reimbursementReport:list', '#fff', '#F53F3F', 3, 0, '0', 'admin', '2026-05-23 14:08:03', '', NULL, ''),
	(42, '考勤管理', 'attendance', 3, '考勤打卡', 'clock', '/pages/attendance/index', '', '#fff', '#F59E0B', 1, 1, '0', '', NULL, '', NULL, ''),
	(43, '考勤管理', 'attendance', 3, '考勤记录', 'file-text', '/pages/attendance/record', '', '#fff', '#F59E0B', 2, 1, '0', '', NULL, '', NULL, ''),
	(44, '考勤管理', 'attendance', 3, '考勤规则', 'setting', '', '', '#fff', '#F59E0B', 3, 1, '0', '', NULL, '', NULL, ''),
	(45, '考勤管理', 'attendance', 3, '考勤配置', 'grid', '', '', '#fff', '#F59E0B', 4, 1, '0', '', NULL, '', NULL, ''),
	(46, '进销存管理', 'wms', 4, '供货商管理', 'account', '/pages/wms/supplier/index', '', '#fff', '#10B981', 1, 1, '0', '', NULL, '', NULL, ''),
	(47, '进销存管理', 'wms', 4, '货品管理', 'list', '', '', '#fff', '#10B981', 2, 1, '0', '', NULL, '', NULL, ''),
	(48, '进销存管理', 'wms', 4, '入库管理', 'arrow-down', '', '', '#fff', '#10B981', 3, 1, '0', '', NULL, '', NULL, ''),
	(49, '进销存管理', 'wms', 4, '出库管理', 'arrow-up', '', '', '#fff', '#10B981', 4, 1, '0', '', NULL, '', NULL, ''),
	(50, '进销存管理', 'wms', 4, '库存查看', 'search', '', '', '#fff', '#10B981', 5, 1, '0', '', NULL, '', NULL, ''),
	(51, '进销存管理', 'wms', 4, '库存盘点', 'checkmark-circle', '', '', '#fff', '#10B981', 6, 1, '0', '', NULL, '', NULL, ''),
	(52, '进销存管理', 'wms', 4, '店企业出货', 'car', '/pages/wms/shipment/index', '', '#fff', '#10B981', 7, 1, '0', '', NULL, '', NULL, ''),
	(53, '进销存管理', 'wms', 4, '进销存报表', 'list-dot', '', '', '#fff', '#10B981', 8, 1, '0', '', NULL, '', NULL, ''),
	(54, '财务管理', 'finance', 5, '方案审核', 'checkmark', '/pages/business/plan/index', '', '#fff', '#8B5CF6', 1, 1, '0', '', NULL, '', NULL, ''),
	(55, '财务管理', 'finance', 5, '报销管理', 'edit-pen', '', '', '#fff', '#8B5CF6', 2, 1, '0', '', NULL, '', NULL, ''),
	(56, '财务管理', 'finance', 5, '报销统计', 'file-text', '', '', '#fff', '#8B5CF6', 3, 1, '0', '', NULL, '', NULL, ''),
	(57, '业务管理', 'business', 2, '方案管理', 'file-text', '/pages/business/plan/index', 'business:plan:list', '#fff', '#FF6B35', 6, 1, '0', '', NULL, '', NULL, '');
/*!40000 ALTER TABLE `app_menu_config` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_attendance_clock 结构
DROP TABLE IF EXISTS `biz_attendance_clock`;
CREATE TABLE IF NOT EXISTS `biz_attendance_clock` (
  `clock_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '打卡ID',
  `record_id` bigint(20) NOT NULL COMMENT '关联考勤记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(30) DEFAULT '' COMMENT '用户姓名',
  `clock_time` datetime NOT NULL COMMENT '打卡时间',
  `clock_type` char(1) NOT NULL DEFAULT '0' COMMENT '打卡类型(0上班 1下班)',
  `work_type` char(1) NOT NULL DEFAULT '0' COMMENT '工作类型(0坐班 1外勤)',
  `latitude` decimal(10,7) DEFAULT NULL COMMENT '打卡纬度',
  `longitude` decimal(10,7) DEFAULT NULL COMMENT '打卡经度',
  `address` varchar(255) DEFAULT '' COMMENT '打卡地址',
  `photo` varchar(500) DEFAULT '' COMMENT '打卡照片',
  `outside_reason` varchar(500) DEFAULT '' COMMENT '外勤事由',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`clock_id`),
  KEY `idx_record_id` (`record_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_clock_time` (`clock_time`),
  KEY `idx_user_date` (`user_id`,`clock_time`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='打卡明细表';

-- 正在导出表  fuchenpro.biz_attendance_clock 的数据：~13 rows (大约)
DELETE FROM `biz_attendance_clock`;
/*!40000 ALTER TABLE `biz_attendance_clock` DISABLE KEYS */;
INSERT INTO `biz_attendance_clock` (`clock_id`, `record_id`, `user_id`, `user_name`, `clock_time`, `clock_type`, `work_type`, `latitude`, `longitude`, `address`, `photo`, `outside_reason`, `remark`, `create_time`) VALUES
	(1, 1, 1, '若依', '2026-04-29 14:51:12', '0', '0', 31.0443840, 121.4664005, '31.044384, 121.466400', '', '', '', '2026-04-29 14:51:12'),
	(2, 1, 1, '若依', '2026-04-29 16:34:08', '1', '0', NULL, NULL, '115151541', '', '', '', '2026-04-29 16:34:08'),
	(3, 1, 1, '若依', '2026-04-29 20:04:21', '1', '0', NULL, NULL, '1212', '/profile/upload/20260429/faa1dab92844899c9730d80d565c99d8.png', '', '', '2026-04-29 20:04:21'),
	(4, 2, 1, '若依', '2026-04-30 01:06:48', '0', '1', NULL, NULL, '', '/profile/upload/20260430/aaa8286dfa49ad4e4064448bf5e8baa5.png', '111', '', '2026-04-30 01:06:48'),
	(5, 2, 1, '若依', '2026-04-30 01:22:31', '1', '0', NULL, NULL, '111', '/profile/upload/20260430/9afe6ed2e06052fb9aaa44882540c5ed.png', '', '', '2026-04-30 01:22:31'),
	(6, 3, 1, 'admin', '2026-05-02 00:31:06', '0', '0', 31.0443368, 121.4664212, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', '', '', '2026-05-02 00:31:06'),
	(7, 3, 1, 'admin', '2026-05-02 00:32:25', '1', '0', 31.0443341, 121.4664045, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', '', '', '2026-05-02 00:32:25'),
	(8, 3, 1, 'admin', '2026-05-02 00:32:29', '1', '0', 31.0443341, 121.4664045, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', '', '', '2026-05-02 00:32:29'),
	(9, 3, 1, 'admin', '2026-05-02 00:52:05', '1', '0', 31.0443232, 121.4663635, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', '', '', '2026-05-02 00:52:05'),
	(10, 3, 1, 'admin', '2026-05-02 01:15:09', '1', '0', 31.0443163, 121.4664135, '永德小区北区', '', '', '', '2026-05-02 01:15:09'),
	(11, 3, 1, 'admin', '2026-05-02 21:44:26', '1', '0', 31.0443450, 121.4662010, '永德小区北区', '/profile/upload/20260502/09b530786537df3e7b79f4335182dc22.jpg', '', '', '2026-05-02 21:44:26'),
	(12, 4, 1, 'admin', '2026-05-05 23:35:24', '0', '0', 31.0442870, 121.4661830, '永德小区北区', '', '', '', '2026-05-05 23:35:24'),
	(13, 4, 1, 'admin', '2026-05-05 23:35:51', '1', '0', 31.0442870, 121.4661830, '永德小区北区', '', '', '', '2026-05-05 23:35:51'),
	(14, 5, 1, '若依', '2026-05-23 19:44:21', '0', '0', 31.2130010, 121.4782990, '中海·恒昌玖里(建设中)', '', '', '', '2026-05-23 19:44:21'),
	(15, 5, 1, '若依', '2026-05-23 19:44:41', '0', '0', 31.2130010, 121.4782990, '中海·恒昌玖里(建设中)', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260523/5e90ca62cd1001e8dbeaa9e7ee4b176a.jpg', '', '', '2026-05-23 19:44:41');
/*!40000 ALTER TABLE `biz_attendance_clock` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_attendance_config 结构
DROP TABLE IF EXISTS `biz_attendance_config`;
CREATE TABLE IF NOT EXISTS `biz_attendance_config` (
  `config_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(100) DEFAULT NULL COMMENT '配置名称',
  `rule_id` int(11) NOT NULL COMMENT '考勤规则ID',
  `user_ids` varchar(500) DEFAULT NULL COMMENT '用户ID列表（逗号分隔）',
  `config_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '配置类型：1=用户级，2=部门级',
  `dept_ids` varchar(500) DEFAULT NULL COMMENT '部门ID列表（逗号分隔）',
  `status` char(1) DEFAULT '0' COMMENT '状态：0=正常，1=停用',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  KEY `idx_rule_id` (`rule_id`),
  KEY `idx_config_type` (`config_type`),
  KEY `idx_dept_ids` (`dept_ids`(100))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考勤配置表';

-- 正在导出表  fuchenpro.biz_attendance_config 的数据：~2 rows (大约)
DELETE FROM `biz_attendance_config`;
/*!40000 ALTER TABLE `biz_attendance_config` DISABLE KEYS */;
INSERT INTO `biz_attendance_config` (`config_id`, `config_name`, `rule_id`, `user_ids`, `config_type`, `dept_ids`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '333', 1, '1', 1, NULL, '0', '33', 'admin', '2026-05-06 14:50:38', 'admin', '2026-05-06 16:37:16'),
	(2, '2121212', 1, '1,2,100', 1, NULL, '0', '1111', 'admin', '2026-05-06 14:51:07', 'admin', '2026-05-06 16:36:56'),
	(3, '部门测试1', 1, NULL, 2, '104,105', '0', '地方', 'admin', '2026-05-26 18:19:33', NULL, NULL);
/*!40000 ALTER TABLE `biz_attendance_config` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_attendance_record 结构
DROP TABLE IF EXISTS `biz_attendance_record`;
CREATE TABLE IF NOT EXISTS `biz_attendance_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(30) DEFAULT '' COMMENT '用户姓名',
  `attendance_date` date NOT NULL COMMENT '考勤日期',
  `clock_in_time` datetime DEFAULT NULL COMMENT '上班打卡时间',
  `clock_out_time` datetime DEFAULT NULL COMMENT '下班打卡时间',
  `clock_in_latitude` decimal(10,7) DEFAULT NULL COMMENT '上班打卡纬度',
  `clock_in_longitude` decimal(10,7) DEFAULT NULL COMMENT '上班打卡经度',
  `clock_in_address` varchar(255) DEFAULT '' COMMENT '上班打卡地址',
  `clock_in_photo` varchar(500) DEFAULT '' COMMENT '上班打卡照片',
  `clock_out_latitude` decimal(10,7) DEFAULT NULL COMMENT '下班打卡纬度',
  `clock_out_longitude` decimal(10,7) DEFAULT NULL COMMENT '下班打卡经度',
  `clock_out_address` varchar(255) DEFAULT '' COMMENT '下班打卡地址',
  `clock_out_photo` varchar(500) DEFAULT '' COMMENT '下班打卡照片',
  `attendance_status` char(1) NOT NULL DEFAULT '0' COMMENT '考勤状态(0正常 1迟到 2早退 3迟到+早退 4缺勤)',
  `clock_count` int(11) NOT NULL DEFAULT '0' COMMENT '打卡次数',
  `first_clock_time` datetime DEFAULT NULL COMMENT '首次打卡时间',
  `last_clock_time` datetime DEFAULT NULL COMMENT '最后打卡时间',
  `clock_type` char(1) NOT NULL DEFAULT '0' COMMENT '打卡类型(0坐班 1外勤)',
  `outside_reason` varchar(500) DEFAULT '' COMMENT '外勤事由',
  `rule_id` bigint(20) DEFAULT NULL COMMENT '关联考勤规则ID',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`attendance_date`),
  KEY `idx_attendance_date` (`attendance_date`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_attendance_status` (`attendance_status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考勤记录表';

-- 正在导出表  fuchenpro.biz_attendance_record 的数据：~4 rows (大约)
DELETE FROM `biz_attendance_record`;
/*!40000 ALTER TABLE `biz_attendance_record` DISABLE KEYS */;
INSERT INTO `biz_attendance_record` (`record_id`, `user_id`, `user_name`, `attendance_date`, `clock_in_time`, `clock_out_time`, `clock_in_latitude`, `clock_in_longitude`, `clock_in_address`, `clock_in_photo`, `clock_out_latitude`, `clock_out_longitude`, `clock_out_address`, `clock_out_photo`, `attendance_status`, `clock_count`, `first_clock_time`, `last_clock_time`, `clock_type`, `outside_reason`, `rule_id`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, '若依', '2026-04-29', '2026-04-29 14:51:12', '2026-04-29 20:04:21', 31.0443840, 121.4664005, '31.044384, 121.466400', '', NULL, NULL, '1212', '/profile/upload/20260429/faa1dab92844899c9730d80d565c99d8.png', '1', 3, '2026-04-29 14:51:12', '2026-04-29 20:04:21', '0', '', 1, '', '若依', '2026-04-29 14:51:12', '若依', '2026-04-29 20:04:21'),
	(2, 1, '若依', '2026-04-30', '2026-04-30 01:06:48', '2026-04-30 01:22:31', NULL, NULL, '', '/profile/upload/20260430/aaa8286dfa49ad4e4064448bf5e8baa5.png', NULL, NULL, '111', '/profile/upload/20260430/9afe6ed2e06052fb9aaa44882540c5ed.png', '2', 2, '2026-04-30 01:06:48', '2026-04-30 01:22:31', '0', '', NULL, '', '若依', '2026-04-30 01:06:48', '', '2026-04-30 01:22:31'),
	(3, 1, 'admin', '2026-05-02', '2026-05-02 00:31:06', '2026-05-02 21:44:26', 31.0443368, 121.4664212, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', 31.0443450, 121.4662010, '永德小区北区', '/profile/upload/20260502/09b530786537df3e7b79f4335182dc22.jpg', '0', 6, '2026-05-02 00:31:06', '2026-05-02 21:44:26', '0', '', NULL, '', 'admin', '2026-05-02 00:31:06', '', '2026-05-02 21:44:26'),
	(4, 1, 'admin', '2026-05-05', '2026-05-05 23:35:24', '2026-05-05 23:35:51', 31.0442870, 121.4661830, '永德小区北区', '', 31.0442870, 121.4661830, '永德小区北区', '', '1', 2, '2026-05-05 23:35:24', '2026-05-05 23:35:51', '0', '', NULL, '', 'admin', '2026-05-05 23:35:24', '', '2026-05-05 23:35:51'),
	(5, 1, '若依', '2026-05-23', NULL, NULL, NULL, NULL, '', '', NULL, NULL, '', '', '0', 0, NULL, NULL, '0', '', NULL, '', '若依', '2026-05-23 19:44:21', '', '2026-05-23 19:44:21');
/*!40000 ALTER TABLE `biz_attendance_record` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_attendance_rule 结构
DROP TABLE IF EXISTS `biz_attendance_rule`;
CREATE TABLE IF NOT EXISTS `biz_attendance_rule` (
  `rule_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_name` varchar(100) NOT NULL COMMENT '规则名称',
  `work_start_time` time NOT NULL COMMENT '上班时间',
  `work_end_time` time NOT NULL COMMENT '下班时间',
  `late_threshold` int(11) NOT NULL DEFAULT '0' COMMENT '迟到容忍分钟数',
  `early_leave_threshold` int(11) NOT NULL DEFAULT '0' COMMENT '早退容忍分钟数',
  `work_latitude` decimal(10,7) DEFAULT NULL COMMENT '考勤点纬度',
  `work_longitude` decimal(10,7) DEFAULT NULL COMMENT '考勤点经度',
  `work_address` varchar(255) DEFAULT '' COMMENT '考勤点地址',
  `allowed_distance` int(11) DEFAULT '500' COMMENT '允许打卡距离(米)',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考勤规则表';

-- 正在导出表  fuchenpro.biz_attendance_rule 的数据：~0 rows (大约)
DELETE FROM `biz_attendance_rule`;
/*!40000 ALTER TABLE `biz_attendance_rule` DISABLE KEYS */;
INSERT INTO `biz_attendance_rule` (`rule_id`, `rule_name`, `work_start_time`, `work_end_time`, `late_threshold`, `early_leave_threshold`, `work_latitude`, `work_longitude`, `work_address`, `allowed_distance`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '标准班', '09:00:00', '18:00:00', 0, 0, 31.2109990, 121.4824490, '上海市黄浦区半淞园路街道恒升大厦', 500, '0', '默认考勤规则', 'admin', '2026-04-29 07:46:25', 'admin', '2026-05-05 23:17:29');
/*!40000 ALTER TABLE `biz_attendance_rule` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_customer 结构
DROP TABLE IF EXISTS `biz_customer`;
CREATE TABLE IF NOT EXISTS `biz_customer` (
  `customer_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '客户ID',
  `enterprise_id` bigint(20) NOT NULL COMMENT '所属企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '所属企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '所属门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '所属门店名称',
  `customer_name` varchar(50) NOT NULL COMMENT '客户姓名',
  `avatar` varchar(500) DEFAULT '' COMMENT '客户头像',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信',
  `gender` char(1) DEFAULT '2' COMMENT '性别(0男1女2未知)',
  `age` int(11) DEFAULT NULL COMMENT '年龄',
  `tag` varchar(100) DEFAULT NULL COMMENT '客户标签(字典biz_customer_tag)',
  `remark` text COMMENT '备注',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常1停用)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`customer_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_store_id` (`store_id`),
  KEY `idx_customer_name` (`customer_name`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户表';

-- 正在导出表  fuchenpro.biz_customer 的数据：~8 rows (大约)
DELETE FROM `biz_customer`;
/*!40000 ALTER TABLE `biz_customer` DISABLE KEYS */;
INSERT INTO `biz_customer` (`customer_id`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `customer_name`, `avatar`, `phone`, `wechat`, `gender`, `age`, `tag`, `remark`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 2, '逆龄奢', 3, '宜川店', '客户1', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/customer_avatar/8523d05a2a9f9e04dfb45ad133366dd3.jpg', NULL, NULL, '1', 55, 'normal,follow', '1111盛世嫡妃', '0', 'admin', '2026-05-09 22:49:56', 'admin', '2026-05-27 22:09:45'),
	(2, 2, NULL, 3, NULL, '测试顾客2', '', NULL, NULL, '0', 55, '寿司', '发多少', '0', 'admin', '2026-05-24 22:37:32', '', '2026-05-24 22:37:32'),
	(3, 2, NULL, 3, NULL, '测试2', '', NULL, NULL, '1', 55, NULL, '111', '0', 'admin', '2026-05-25 23:43:11', '', '2026-05-25 23:43:11'),
	(4, 2, NULL, 3, NULL, '李明', '', NULL, NULL, '0', 55, NULL, '的', '0', 'admin', '2026-05-25 23:47:01', 'admin', '2026-05-26 00:15:02'),
	(5, 2, NULL, 3, NULL, '请问请问', '', NULL, NULL, '1', NULL, NULL, NULL, '0', 'admin', '2026-05-26 00:25:12', '', '2026-05-26 00:25:12'),
	(6, 2, '逆龄奢', 3, '宜川店', '测试客户', 'blob:http://192.168.2.74:8088/cefca53b-da1e-4507-8998-6fded540fdea', '', '', '1', NULL, '', '', '0', 'admin', '2026-05-26 18:22:32', '', '2026-05-26 18:22:32'),
	(7, 4, '企业1', 5, '哈哈', 'aaa', '', '', '', '0', NULL, 'important,new', '', '0', 'admin', '2026-05-27 22:10:34', '', '2026-05-27 22:10:34'),
	(8, 1, NULL, 2, NULL, '客户3', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/customer_avatar/3fbea32dc79ab822fb3ab5588d9b1385.png', NULL, NULL, '1', 55, 'important,normal', '辅导费', '0', 'admin', '2026-05-28 15:19:35', '', '2026-05-28 15:19:36');
/*!40000 ALTER TABLE `biz_customer` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_customer_archive 结构
DROP TABLE IF EXISTS `biz_customer_archive`;
CREATE TABLE IF NOT EXISTS `biz_customer_archive` (
  `archive_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '档案ID',
  `customer_id` bigint(20) NOT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `archive_date` date DEFAULT NULL COMMENT '档案日期',
  `archive_type` varchar(50) DEFAULT NULL COMMENT '档案类型(铺垫/开方案/销售/售后/回访)',
  `source_type` char(1) NOT NULL DEFAULT '3' COMMENT '来源类型(0开单 1操作 2还款 3手动新增)',
  `source_id` bigint(20) DEFAULT NULL COMMENT '来源记录ID',
  `plan_items` text COMMENT '方案项目JSON:[{name,quantity}]',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `satisfaction` tinyint(4) DEFAULT NULL COMMENT '满意度(1-5星)',
  `photos` text COMMENT '照片JSON数组',
  `customer_feedback` varchar(500) DEFAULT NULL COMMENT '顾客反馈',
  `operator_user_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `operator_user_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`archive_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_archive_date` (`archive_date`),
  KEY `idx_source_type` (`source_type`),
  KEY `idx_enterprise_id` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户档案表';

-- 正在导出表  fuchenpro.biz_customer_archive 的数据：~30 rows (大约)
DELETE FROM `biz_customer_archive`;
/*!40000 ALTER TABLE `biz_customer_archive` DISABLE KEYS */;
INSERT INTO `biz_customer_archive` (`archive_id`, `customer_id`, `customer_name`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `archive_date`, `archive_type`, `source_type`, `source_id`, `plan_items`, `amount`, `satisfaction`, `photos`, `customer_feedback`, `operator_user_id`, `operator_user_name`, `remark`, `create_by`, `create_time`) VALUES
	(1, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-09', 'sales', '0', 1, '[{"name":"品项1","quantity":10},{"name":"品项2","quantity":10}]', 7960.00, NULL, NULL, '防守打法神鼎飞丹砂方式搭嘎', 1, 'admin', '套餐: 套餐卡1', 'admin', '2026-05-09 22:50:40'),
	(4, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-09', 'sales', '1', 8, '[{"name":"品项1","quantity":1},{"name":"品项2","quantity":1}]', 796.00, 5, '["20260509\\/74e407483fabcd1997c631eab465649e.png","20260509\\/a4c36981c3f7fe74d9580c9133ab66a7.jpg"]', '1111', 1, 'admin', '', 'admin', '2026-05-09 23:42:39'),
	(5, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-10', 'sales', '1', 10, '[{"name":"品项1","quantity":1},{"name":"品项2","quantity":1}]', 796.00, 5, '["20260510\\/27947a7899f8f74321e7864ad92f79c4.jpg","20260510\\/f92cc968604ae6effe2e6a92d129f838.png"]', '惹我热污染', 1, 'admin', '惹我热污染; 惹我热污染', 'admin', '2026-05-10 20:01:38'),
	(6, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-10', 'sales', '0', 2, '[{"name":"品项3","quantity":1},{"name":"品项4","quantity":1}]', 0.00, NULL, NULL, '额温枪委屈委屈各付各的付个', 1, 'admin', '套餐: 品项套餐2', 'admin', '2026-05-10 22:48:01'),
	(7, 1, '客户1', 2, '逆龄奢', 0, '宜川店', '2026-05-11', 'sales', '0', 3, '[{"name":"你明明","quantity":1}]', 380.00, NULL, NULL, '吉里吉里', 1, 'admin', '套餐: 停机了', 'admin', '2026-05-11 00:04:07'),
	(8, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-12', 'sales', '0', 5, '[{"name":"fsdfs","quantity":1},{"name":"eqwe","quantity":1}]', 777.00, NULL, NULL, '大大是的', 1, 'admin', '套餐: 啊实打实', 'admin', '2026-05-12 00:49:14'),
	(9, 1, '客户1', 2, '逆龄奢', 0, '宜川店', '2026-05-12', 'sales', '2', 1, '[{"name":"啊实打实","quantity":1}]', 100.00, NULL, NULL, NULL, 1, 'admin', '科技局', 'admin', '2026-05-12 17:05:07'),
	(10, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-12', 'sales', '0', 8, '[{"name":"对方水电费","quantity":10},{"name":"辅导费收到","quantity":10}]', 7960.00, NULL, NULL, '发的范德萨', 1, 'admin', '套餐: 测试套餐2', 'admin', '2026-05-12 20:21:56'),
	(11, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-12', 'sales', '2', 2, '[{"name":"啊实打实","quantity":1}]', 100.00, NULL, NULL, NULL, 1, 'admin', '111', 'admin', '2026-05-12 20:28:11'),
	(12, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-12', 'sales', '2', 3, '[{"name":"啊实打实","quantity":1}]', 200.00, NULL, NULL, NULL, 1, 'admin', '200', 'admin', '2026-05-12 20:28:27'),
	(13, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-12', 'sales', '1', 11, '[{"name":"对方水电费","quantity":1}]', 398.00, 5, NULL, '', 1, 'admin', '', 'admin', '2026-05-12 22:24:35'),
	(14, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-13', 'sales', '1', 21, '[{"name":"对方水电费","quantity":1},{"name":"烦都烦死","quantity":1},{"name":"对方水电费","quantity":1},{"name":"辅导费收到","quantity":1}]', 1194.00, 5, '["20260513\\/833964975e5bb834b4b4ef8ac592ae0a.jpg","20260513\\/ff73a9e2885bf0ad91ecac3c9d2070cc.png","[object Object],[object Object]"]', '吉里吉里', 1, 'admin', '7567567; 顺丰到付; 敏敏哦; 敏敏哦', 'admin', '2026-05-13 17:38:40'),
	(15, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-15', 'sales', '1', 23, '[{"name":"对方水电费","quantity":1},{"name":"对方水电费","quantity":1}]', 796.00, 5, '["https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260515\\/f77c765a994061081a8397047872513d.jpg","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260515\\/b9524dc0608eb5cad31dbd4e8e26cefb.png","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260515\\/d5ed87604f84d00fbb5f1525c245d99c.jpg","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260515\\/4ae4bebf7489feae9e6f2e478a3906d0.jpg"]', '几厘米', 1, 'admin', '苟富贵; 管理会计', 'admin', '2026-05-15 16:22:29'),
	(16, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-22', 'sales', '0', 11, '[{"name":"额废物费","quantity":1}]', 680.00, NULL, NULL, '苟富贵', 1, '若依', '套餐: ', 'admin', '2026-05-22 12:42:26'),
	(17, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-22', 'sales', '1', 26, '[{"name":"额废物费","quantity":1},{"name":"对方水电费","quantity":1},{"name":"辅导费收到","quantity":1}]', 1476.00, 5, '["20260522\\/e341db3c857af5fe55597c553f09e7e6.png","20260522\\/4d8d999b42973f22b5fc036182d6d6eb.png","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260522\\/978a506dde8d58eaea9237b0a626e275.png","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260522\\/84edd8ed40240dc8495eac01ecdf935e.png"]', '656456456', 1, '若依', '353; 风范; 65464564', 'admin', '2026-05-22 15:55:04'),
	(18, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-22', 'sales', '2', 4, '[{"name":"测试套餐2","quantity":1}]', 200.00, NULL, NULL, NULL, 1, '若依', 'fdfs ', 'admin', '2026-05-22 15:56:27'),
	(19, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-22', 'sales', '2', 5, '[{"name":"测试套餐2","quantity":1}]', 100.00, NULL, NULL, NULL, 1, '若依', '', 'admin', '2026-05-22 16:26:19'),
	(20, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-25', 'sales', '0', 17, '[{"name":"很反感很反感","quantity":1}]', 1000.00, NULL, NULL, '金龟换酒', 1, '若依', '套餐: 进货价格', 'admin', '2026-05-25 19:58:04'),
	(21, 2, '测试顾客2', 2, '逆龄奢', 3, '宜川店', '2026-05-25', 'sales', '0', 18, '[{"name":"功夫格斗","quantity":1}]', 1000.00, NULL, NULL, '换个', 1, '若依', '套餐: 液态氧', 'admin', '2026-05-25 20:01:19'),
	(22, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-26', 'sales', '0', 19, '[{"name":"我打的","quantity":1}]', 980.00, NULL, NULL, '', 1, '若依', '套餐: ', 'admin', '2026-05-26 20:09:14'),
	(23, 1, '客户1', 2, NULL, 3, NULL, '2026-05-27', 'preparation', '3', NULL, '[{"name":"发的范德萨","quantity":1},{"name":"辅导费","quantity":1}]', 980.00, 5, NULL, '佛挡杀佛是', 100, '测试', '佛挡杀佛', 'admin', '2026-05-27 18:56:25'),
	(24, 1, '客户1', 2, NULL, 3, NULL, '2026-05-27', 'preparation', '3', NULL, '[{"name":"11111","quantity":1}]', 11111.00, 5, NULL, '1111', 1, '若依', '1111', 'admin', '2026-05-27 21:30:30'),
	(25, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-27', 'sales', '0', 20, '[{"name":"达大厦大声道","quantity":1}]', 980.00, NULL, NULL, '梵蒂冈', 1, '若依', '套餐: 阿达', 'admin', '2026-05-27 22:13:13'),
	(26, 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '2026-05-28', 'sales', '0', 21, '[{"name":"防守打法都是","quantity":1}]', 9800.00, NULL, NULL, '德叔', 1, '若依', '套餐: 辅导费', 'admin', '2026-05-28 15:20:16'),
	(27, 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '2026-05-28', 'sales', '0', 22, '[{"name":"hfghfg","quantity":1}]', 888.00, NULL, NULL, '', 1, '若依', '套餐: 225252', 'admin', '2026-05-28 16:44:25'),
	(28, 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '2026-05-28', 'sales', '0', 23, '[{"name":"242424","quantity":1}]', 888.00, NULL, NULL, '', 1, '若依', '套餐: h很反感很符合', 'admin', '2026-05-28 16:46:04'),
	(29, 4, '李明', 2, '逆龄奢', 3, '宜川店', '2026-05-28', 'sales', '0', 24, '[{"name":"鬼地方个","quantity":5}]', 5555.00, NULL, NULL, '鬼地方个', 1, '若依', '套餐: 鬼地方个', 'admin', '2026-05-28 17:30:15'),
	(30, 1, '客户1', 2, '逆龄奢', 3, '宜川店', '2026-05-29', 'sales', '1', 27, '[{"name":"达大厦大声道","quantity":1}]', 980.00, 5, '["https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/dce0e64022794884f849a80c0e667300.jpg","https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/ccb8f124cbdf36dad5af4add6cca1aeb.jpg"]', '模棱两可', 1, '若依', '攻击力', 'admin', '2026-05-29 14:55:15'),
	(31, 1, '客户1', 2, NULL, 3, NULL, '2026-05-29', 'preparation', '3', NULL, '[{"name":"会理解","quantity":"10"},{"name":"会给你了吗","quantity":"20"}]', 980.00, 3, NULL, '公共功能', 1, '若依', '公共功能寂寞', 'admin', '2026-05-29 15:02:59'),
	(32, 1, '客户1', 2, NULL, 3, NULL, '2026-05-29', 'after_sales', '3', NULL, '[{"name":"回来回来","quantity":1}]', 0.00, 5, NULL, '护理记录固体', 1, '若依', '公积金进', 'admin', '2026-05-29 15:03:40');
/*!40000 ALTER TABLE `biz_customer_archive` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_customer_package 结构
DROP TABLE IF EXISTS `biz_customer_package`;
CREATE TABLE IF NOT EXISTS `biz_customer_package` (
  `package_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '套餐ID',
  `package_no` varchar(30) NOT NULL COMMENT '套餐编号',
  `customer_id` bigint(20) NOT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `order_id` bigint(20) DEFAULT NULL COMMENT '来源订单ID',
  `order_no` varchar(30) DEFAULT NULL COMMENT '来源订单编号',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `package_name` varchar(100) DEFAULT NULL COMMENT '套餐名称',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '套餐总金额',
  `paid_amount` decimal(12,2) DEFAULT '0.00' COMMENT '实付金额',
  `owed_amount` decimal(12,2) DEFAULT '0.00' COMMENT '欠款金额',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0有效1已用完2已过期3已退款)',
  `expire_date` date DEFAULT NULL COMMENT '过期日期',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`package_id`),
  UNIQUE KEY `uk_package_no` (`package_no`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户套餐表';

-- 正在导出表  fuchenpro.biz_customer_package 的数据：~14 rows (大约)
DELETE FROM `biz_customer_package`;
/*!40000 ALTER TABLE `biz_customer_package` DISABLE KEYS */;
INSERT INTO `biz_customer_package` (`package_id`, `package_no`, `customer_id`, `customer_name`, `order_id`, `order_no`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `package_name`, `total_amount`, `paid_amount`, `owed_amount`, `status`, `expire_date`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'PK202605090001', 1, '客户1', 1, 'SO202605090001', 2, NULL, 3, NULL, '套餐卡1', 7960.00, 7960.00, 0.00, '1', NULL, '防守打法神鼎飞丹砂方式搭嘎', 'admin', '2026-05-09 22:50:40', '', '2026-05-09 22:50:40'),
	(2, 'PK202605100001', 1, '客户1', 2, 'SO202605100001', 2, NULL, 3, NULL, '品项套餐2', 0.00, 0.00, 0.00, '1', NULL, '额温枪委屈委屈各付各的付个', 'admin', '2026-05-10 22:48:01', '', '2026-05-10 22:48:01'),
	(3, 'PK202605110001', 1, '客户1', 3, 'SO202605110001', 2, NULL, 0, NULL, '停机了', 380.00, 380.00, 0.00, '1', NULL, '吉里吉里', 'admin', '2026-05-11 00:04:07', '', '2026-05-11 00:04:07'),
	(5, 'PK202605120001', 1, '客户1', 5, 'SO202605120001', 2, NULL, 3, NULL, '啊实打实', 777.00, 777.00, 0.00, '1', NULL, '大大是的', 'admin', '2026-05-12 00:49:14', '', '2026-05-12 22:46:28'),
	(7, 'PK202605120002', 1, '客户1', 8, 'SO202605120003', 2, NULL, 3, NULL, '测试套餐2', 7960.00, 7280.00, 680.00, '1', NULL, '发的范德萨', 'admin', '2026-05-12 20:21:56', '', '2026-05-22 16:26:19'),
	(8, 'PK202605220001', 1, '客户1', 11, 'SO202605220001', 2, NULL, 3, NULL, '客户1 2026-05-22 持卡记录', 680.00, 680.00, 0.00, '1', NULL, '苟富贵', 'admin', '2026-05-22 12:42:26', '', '2026-05-22 15:55:04'),
	(9, 'PK202605250001', 1, '客户1', 17, 'SO202605250001', 2, NULL, 3, NULL, '进货价格', 1000.00, 1000.00, 0.00, '1', NULL, '金龟换酒', 'admin', '2026-05-25 19:58:04', '', '2026-05-25 19:58:04'),
	(10, 'PK202605250002', 2, '测试顾客2', 18, 'SO202605250002', 2, NULL, 3, NULL, '液态氧', 1000.00, 1000.00, 0.00, '1', NULL, '换个', 'admin', '2026-05-25 20:01:19', '', '2026-05-25 20:01:19'),
	(11, 'PK202605260001', 1, '客户1', 19, 'SO202605260001', 2, NULL, 3, NULL, '客户1 2026-05-26 持卡记录', 980.00, 980.00, 0.00, '1', NULL, '', 'admin', '2026-05-26 20:09:14', '', '2026-05-26 20:09:14'),
	(12, 'PK202605270001', 1, '客户1', 20, 'SO202605270001', 2, NULL, 3, NULL, '阿达', 980.00, 980.00, 0.00, '1', NULL, '梵蒂冈', 'admin', '2026-05-27 22:13:13', '', '2026-05-29 14:55:15'),
	(13, 'PK202605280001', 8, '客户3', 21, 'SO202605280001', 1, NULL, 2, NULL, '辅导费', 9800.00, 8000.00, 1800.00, '1', NULL, '德叔', 'admin', '2026-05-28 15:20:16', '', '2026-05-28 15:20:16'),
	(14, 'PK202605280002', 8, '客户3', 22, 'SO202605280002', 1, NULL, 2, NULL, '225252', 888.00, 800.00, 88.00, '1', NULL, '', 'admin', '2026-05-28 16:44:25', '', '2026-05-28 16:44:25'),
	(15, 'PK202605280003', 8, '客户3', 23, 'SO202605280003', 1, NULL, 2, NULL, 'h很反感很符合', 888.00, 880.00, 8.00, '1', NULL, '', 'admin', '2026-05-28 16:46:04', '', '2026-05-28 16:46:04'),
	(16, 'PK202605280004', 4, '李明', 24, 'SO202605280004', 2, NULL, 3, NULL, '鬼地方个', 5555.00, 5000.00, 555.00, '1', NULL, '鬼地方个', 'admin', '2026-05-28 17:30:15', '', '2026-05-28 17:30:15');
/*!40000 ALTER TABLE `biz_customer_package` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_employee_config 结构
DROP TABLE IF EXISTS `biz_employee_config`;
CREATE TABLE IF NOT EXISTS `biz_employee_config` (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `user_id` bigint(20) NOT NULL COMMENT '员工ID',
  `user_name` varchar(50) DEFAULT NULL COMMENT '员工姓名',
  `post_id` bigint(20) DEFAULT NULL COMMENT '岗位ID',
  `post_name` varchar(50) DEFAULT NULL COMMENT '岗位名称',
  `dept_id` bigint(20) DEFAULT NULL COMMENT '部门ID',
  `dept_name` varchar(50) DEFAULT NULL COMMENT '部门名称',
  `is_schedulable` char(1) NOT NULL DEFAULT '1' COMMENT '是否可排班(0否 1是)',
  `rest_dates` text COMMENT '休息日期(JSON格式)',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='员工配置表';

-- 正在导出表  fuchenpro.biz_employee_config 的数据：~3 rows (大约)
DELETE FROM `biz_employee_config`;
/*!40000 ALTER TABLE `biz_employee_config` DISABLE KEYS */;
INSERT INTO `biz_employee_config` (`config_id`, `user_id`, `user_name`, `post_id`, `post_name`, `dept_id`, `dept_name`, `is_schedulable`, `rest_dates`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, 'admin', 1, '董事长', 103, '研发部门', '1', '["2026-05-31","2026-05-30"]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-05-11 21:32:16'),
	(2, 2, 'ry', NULL, NULL, 105, '测试部门', '1', '[]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-04-28 22:09:16'),
	(3, 100, '测试', 4, '普通员工', 101, '深圳总公司', '1', '["2026-05-09","2026-05-21","2026-06-03","2026-05-15"]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-05-01 14:22:07');
/*!40000 ALTER TABLE `biz_employee_config` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_enterprise 结构
DROP TABLE IF EXISTS `biz_enterprise`;
CREATE TABLE IF NOT EXISTS `biz_enterprise` (
  `enterprise_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '企业ID',
  `enterprise_name` varchar(100) NOT NULL COMMENT '企业名称',
  `pinyin` varchar(50) DEFAULT NULL COMMENT '拼音首字母',
  `boss_name` varchar(50) NOT NULL COMMENT '老板姓名',
  `phone` varchar(20) NOT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `enterprise_type` char(1) NOT NULL DEFAULT '1' COMMENT '企业类型(1直营 2加盟 3合作)',
  `store_count` int(11) DEFAULT '0' COMMENT '门店数量',
  `annual_performance` decimal(12,2) DEFAULT '0.00' COMMENT '年业绩',
  `enterprise_level` char(1) NOT NULL DEFAULT '3' COMMENT '企业级别(1A级 2B级 3C级)',
  `server_user_id` bigint(20) DEFAULT NULL COMMENT '服务人ID',
  `server_user_name` varchar(50) DEFAULT NULL COMMENT '服务人姓名',
  `cooperation_start_date` date DEFAULT NULL COMMENT '开始合作日期',
  `cooperation_end_date` date DEFAULT NULL COMMENT '结束合作日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`enterprise_id`),
  KEY `idx_enterprise_name` (`enterprise_name`),
  KEY `idx_server_user_id` (`server_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='企业管理表';

-- 正在导出表  fuchenpro.biz_enterprise 的数据：~4 rows (大约)
DELETE FROM `biz_enterprise`;
/*!40000 ALTER TABLE `biz_enterprise` DISABLE KEYS */;
INSERT INTO `biz_enterprise` (`enterprise_id`, `enterprise_name`, `pinyin`, `boss_name`, `phone`, `address`, `enterprise_type`, `store_count`, `annual_performance`, `enterprise_level`, `server_user_id`, `server_user_name`, `cooperation_start_date`, `cooperation_end_date`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '馥田诗', '', '汪志', '15888888888', '陆家浜路1396号', '2', 2, 2000.00, '1', NULL, '吴总', '2026-05-06', '2028-05-05', '0', NULL, 'admin', '2026-04-27 23:38:35', 'admin', '2026-05-16 20:14:41'),
	(2, '逆龄奢', '', '木总', '13588888888', '发顺丰第四范式', '2', 2, 500.00, '2', NULL, '李总', '2026-05-06', '2027-05-06', '0', '防守打法收到', 'admin', '2026-05-02 18:20:18', 'admin', '2026-05-06 19:09:28'),
	(4, '企业1', 'Y1', '汪老板', '15555555555', '法国德国电饭锅电饭锅代发给对方大概给对方', '3', 5, 5000.00, '2', NULL, NULL, NULL, NULL, '0', '41', 'admin', '2026-05-26 14:13:27', '', '2026-05-26 14:13:27'),
	(5, '测试3', '3', '哈哈', '16666666666', '急急急', '1', 0, 0.00, '2', NULL, NULL, NULL, NULL, '0', NULL, 'admin', '2026-05-29 17:09:35', '', '2026-05-29 17:09:35');
/*!40000 ALTER TABLE `biz_enterprise` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_feedback 结构
DROP TABLE IF EXISTS `biz_feedback`;
CREATE TABLE IF NOT EXISTS `biz_feedback` (
  `feedback_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '反馈ID',
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='问题反馈表';

-- 正在导出表  fuchenpro.biz_feedback 的数据：~0 rows (大约)
DELETE FROM `biz_feedback`;
/*!40000 ALTER TABLE `biz_feedback` DISABLE KEYS */;
INSERT INTO `biz_feedback` (`feedback_id`, `title`, `content`, `feedback_type`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '房间号富家大室就发货', '鬼地方个多喝点风蚀高地司法过广东佛山公司', '0', '1', 'admin', '2026-05-30 14:01:47', 'admin', '2026-05-30 14:02:29');
/*!40000 ALTER TABLE `biz_feedback` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_feedback_reply 结构
DROP TABLE IF EXISTS `biz_feedback_reply`;
CREATE TABLE IF NOT EXISTS `biz_feedback_reply` (
  `reply_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '回复ID',
  `feedback_id` bigint(20) NOT NULL COMMENT '反馈ID',
  `content` text NOT NULL COMMENT '回复内容',
  `create_by` varchar(64) DEFAULT '' COMMENT '回复人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
  PRIMARY KEY (`reply_id`),
  KEY `idx_feedback_id` (`feedback_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='反馈回复表';

-- 正在导出表  fuchenpro.biz_feedback_reply 的数据：~0 rows (大约)
DELETE FROM `biz_feedback_reply`;
/*!40000 ALTER TABLE `biz_feedback_reply` DISABLE KEYS */;
INSERT INTO `biz_feedback_reply` (`reply_id`, `feedback_id`, `content`, `create_by`, `create_time`) VALUES
	(1, 1, '法国电饭锅地方', 'admin', '2026-05-30 14:02:29');
/*!40000 ALTER TABLE `biz_feedback_reply` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_inventory 结构
DROP TABLE IF EXISTS `biz_inventory`;
CREATE TABLE IF NOT EXISTS `biz_inventory` (
  `inventory_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '库存ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '当前库存数量',
  `earliest_expiry` date DEFAULT NULL COMMENT '最早批次有效期至',
  `warn_qty` int(11) DEFAULT '0' COMMENT '预警数量',
  `last_stock_in_time` datetime DEFAULT NULL COMMENT '最后入库时间',
  `last_stock_out_time` datetime DEFAULT NULL COMMENT '最后出库时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uk_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存表';

-- 正在导出表  fuchenpro.biz_inventory 的数据：~2 rows (大约)
DELETE FROM `biz_inventory`;
/*!40000 ALTER TABLE `biz_inventory` DISABLE KEYS */;
INSERT INTO `biz_inventory` (`inventory_id`, `product_id`, `quantity`, `earliest_expiry`, `warn_qty`, `last_stock_in_time`, `last_stock_out_time`, `create_time`, `update_time`) VALUES
	(1, 1, 8, NULL, 0, '2026-05-05 16:51:22', '2026-05-05 16:53:55', '2026-04-29 15:10:14', '2026-05-08 21:34:47'),
	(2, 2, 0, NULL, 20, '2026-05-05 18:25:27', '2026-05-05 18:25:39', '2026-05-05 00:11:55', '2026-05-17 19:56:56');
/*!40000 ALTER TABLE `biz_inventory` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_operation_record 结构
DROP TABLE IF EXISTS `biz_operation_record`;
CREATE TABLE IF NOT EXISTS `biz_operation_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `operation_type` char(1) NOT NULL DEFAULT '0' COMMENT '操作类型(0持卡操作1体验操作)',
  `customer_id` bigint(20) NOT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `package_id` bigint(20) DEFAULT NULL COMMENT '套餐ID',
  `package_no` varchar(30) DEFAULT NULL COMMENT '套餐编号',
  `operation_batch_id` varchar(32) DEFAULT NULL COMMENT '操作批次ID',
  `package_item_id` bigint(20) DEFAULT NULL COMMENT '套餐明细ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '品项名称',
  `operation_quantity` int(11) NOT NULL DEFAULT '1' COMMENT '操作次数',
  `consume_amount` decimal(12,2) DEFAULT '0.00' COMMENT '消耗金额',
  `trial_price` decimal(12,2) DEFAULT NULL COMMENT '体验价',
  `customer_feedback` varchar(500) DEFAULT NULL COMMENT '顾客反馈',
  `satisfaction` tinyint(4) DEFAULT NULL COMMENT '满意度(1-5星)',
  `before_photo` varchar(500) DEFAULT NULL COMMENT '操作前对比照',
  `after_photo` varchar(500) DEFAULT NULL COMMENT '操作后对比照',
  `operator_user_id` bigint(20) DEFAULT NULL COMMENT '操作员工ID',
  `operator_user_name` varchar(50) DEFAULT NULL COMMENT '操作员工姓名',
  `operation_date` date DEFAULT NULL COMMENT '操作日期',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_package_id` (`package_id`),
  KEY `idx_operation_date` (`operation_date`),
  KEY `idx_operation_batch_id` (`operation_batch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作记录表';

-- 正在导出表  fuchenpro.biz_operation_record 的数据：~27 rows (大约)
DELETE FROM `biz_operation_record`;
/*!40000 ALTER TABLE `biz_operation_record` DISABLE KEYS */;
INSERT INTO `biz_operation_record` (`record_id`, `operation_type`, `customer_id`, `customer_name`, `package_id`, `package_no`, `operation_batch_id`, `package_item_id`, `product_name`, `operation_quantity`, `consume_amount`, `trial_price`, `customer_feedback`, `satisfaction`, `before_photo`, `after_photo`, `operator_user_id`, `operator_user_name`, `operation_date`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `remark`, `create_by`, `create_time`) VALUES
	(1, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923010001', 1, '品项1', 1, 398.00, NULL, '发给大哥电饭锅鬼地方个', 5, '20260509/923392b9a1b944a52c3d2e0f534f4712.jpg', '20260509/28371766b381169d709fb4274b97eac2.jpg', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '咕嘟咕嘟改单费', 'admin', '2026-05-09 23:01:36'),
	(2, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923010001', 2, '品项2', 1, 398.00, NULL, '发给大哥电饭锅鬼地方个', 5, '20260509/923392b9a1b944a52c3d2e0f534f4712.jpg', '20260509/28371766b381169d709fb4274b97eac2.jpg', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '咕嘟咕嘟改单费', 'admin', '2026-05-09 23:01:36'),
	(3, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923220003', 1, '品项1', 1, 398.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '', 'admin', '2026-05-09 23:22:06'),
	(4, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923220003', 2, '品项2', 1, 398.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '', 'admin', '2026-05-09 23:22:07'),
	(5, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923290005', 1, '品项1', 1, 398.00, NULL, '1111111111111111111111', 5, '20260509/d976b9742a4c856b1a1b52b22254714c.png', '20260509/f3045879c25f4b3e868cdb9804c79c6d.png', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '1111111111111111111111', 'admin', '2026-05-09 23:29:20'),
	(6, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923290005', 2, '品项2', 1, 398.00, NULL, '1111111111111111111111', 5, '20260509/d976b9742a4c856b1a1b52b22254714c.png', '20260509/f3045879c25f4b3e868cdb9804c79c6d.png', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '1111111111111111111111', 'admin', '2026-05-09 23:29:20'),
	(7, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923420007', 1, '品项1', 1, 398.00, NULL, '1111', 5, '20260509/74e407483fabcd1997c631eab465649e.png', '20260509/a4c36981c3f7fe74d9580c9133ab66a7.jpg', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '', 'admin', '2026-05-09 23:42:39'),
	(8, '0', 1, '客户1', 1, 'PK202605090001', 'OB2026050923420007', 2, '品项2', 1, 398.00, NULL, '1111', 5, '20260509/74e407483fabcd1997c631eab465649e.png', '20260509/a4c36981c3f7fe74d9580c9133ab66a7.jpg', 1, 'admin', '2026-05-09', 2, NULL, 3, NULL, '', 'admin', '2026-05-09 23:42:39'),
	(9, '0', 1, '客户1', 1, 'PK202605090001', 'OB202605101201389621', 1, '品项1', 1, 398.00, NULL, '惹我热污染', 5, '20260510/27947a7899f8f74321e7864ad92f79c4.jpg', '20260510/f92cc968604ae6effe2e6a92d129f838.png', 1, 'admin', '2026-05-10', 2, NULL, 3, NULL, '惹我热污染', 'admin', '2026-05-10 20:01:38'),
	(10, '0', 1, '客户1', 1, 'PK202605090001', 'OB202605101201389621', 2, '品项2', 1, 398.00, NULL, '惹我热污染', 5, '20260510/27947a7899f8f74321e7864ad92f79c4.jpg', '20260510/f92cc968604ae6effe2e6a92d129f838.png', 1, 'admin', '2026-05-10', 2, NULL, 3, NULL, '惹我热污染', 'admin', '2026-05-10 20:01:38'),
	(11, '0', 1, '客户1', 7, NULL, 'OB202605122224352399', 12, '对方水电费', 1, 398.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '', 'admin', '2026-05-12 22:24:35'),
	(12, '0', 1, '客户1', 7, NULL, 'OB202605122224358558', 13, '辅导费收到', 1, 398.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '', 'admin', '2026-05-12 22:24:35'),
	(13, '0', 1, '客户1', 5, NULL, 'OB202605122246283835', 8, 'fsdfs', 1, 333.00, NULL, '方式电风扇', 5, '[object Object]', '[object Object]', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '范德萨发生', 'admin', '2026-05-12 22:46:28'),
	(14, '0', 1, '客户1', 5, NULL, 'OB202605122246289021', 9, 'eqwe', 1, 444.00, NULL, '方式电风扇', 5, '[object Object]', '[object Object]', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '范德萨发生', 'admin', '2026-05-12 22:46:28'),
	(15, '0', 1, '客户1', 7, NULL, 'OB202605122330523372', 13, '辅导费收到', 5, 1990.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '', 'admin', '2026-05-12 23:30:52'),
	(16, '0', 1, '客户1', 7, NULL, 'OB202605122330521242', 12, '对方水电费', 4, 1592.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '', 'admin', '2026-05-12 23:30:52'),
	(17, '0', 1, '客户1', 2, NULL, 'OB202605122330526517', 4, '品项4', 1, 0.00, NULL, '', 5, '', '', 1, 'admin', '2026-05-12', 2, NULL, 3, NULL, '', 'admin', '2026-05-12 23:30:52'),
	(18, '0', 1, '客户1', 7, 'PK202605120002', 'OB202605130938409385', 12, '对方水电费', 1, 398.00, NULL, '6756756', 1, '20260513/833964975e5bb834b4b4ef8ac592ae0a.jpg', '20260513/ff73a9e2885bf0ad91ecac3c9d2070cc.png', 1, 'admin', '2026-05-13', 2, NULL, 3, NULL, '7567567', 'admin', '2026-05-13 17:38:40'),
	(19, '1', 1, '客户1', NULL, NULL, 'OB202605131742321317', NULL, '烦都烦死', 1, 0.00, 0.00, '防守打法', 5, '', '', 1, 'admin', '2026-05-13', 2, NULL, 3, NULL, '顺丰到付', 'admin', '2026-05-13 17:42:32'),
	(20, '0', 1, '客户1', 7, NULL, 'OB202605132348411935', 12, '对方水电费', 1, 398.00, NULL, '吉里吉里', 5, '[object Object],[object Object]', '[object Object],[object Object]', 1, 'admin', '2026-05-13', 2, NULL, 3, NULL, '敏敏哦', 'admin', '2026-05-13 23:48:41'),
	(21, '0', 1, '客户1', 7, NULL, 'OB202605132348412357', 13, '辅导费收到', 1, 398.00, NULL, '吉里吉里', 5, '[object Object],[object Object]', '[object Object],[object Object]', 1, 'admin', '2026-05-13', 2, NULL, 3, NULL, '敏敏哦', 'admin', '2026-05-13 23:48:41'),
	(22, '0', 1, '客户1', 7, 'PK202605120002', 'OB202605150822294233', 12, '对方水电费', 1, 398.00, NULL, '咕嘟咕嘟发给', 5, 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260515/f77c765a994061081a8397047872513d.jpg', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260515/b9524dc0608eb5cad31dbd4e8e26cefb.png', 1, 'admin', '2026-05-15', 2, NULL, 3, NULL, '苟富贵', 'admin', '2026-05-15 16:22:29'),
	(23, '0', 1, '客户1', 7, NULL, 'OB202605152020213975', 12, '对方水电费', 1, 398.00, NULL, '几厘米', 5, 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260515/d5ed87604f84d00fbb5f1525c245d99c.jpg', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260515/4ae4bebf7489feae9e6f2e478a3906d0.jpg', 1, 'admin', '2026-05-15', 2, NULL, 3, NULL, '管理会计', 'admin', '2026-05-15 20:20:21'),
	(24, '0', 1, '客户1', 8, 'PK202605220001', 'OB202605220755047919', 14, '额废物费', 1, 680.00, NULL, '5345345', 5, '20260522/e341db3c857af5fe55597c553f09e7e6.png', '', 1, '若依', '2026-05-22', 2, NULL, 3, NULL, '353', 'admin', '2026-05-22 15:55:04'),
	(25, '0', 1, '客户1', 7, 'PK202605120002', 'OB202605221145294283', 12, '对方水电费', 1, 398.00, NULL, '的我的娃', 5, '20260522/4d8d999b42973f22b5fc036182d6d6eb.png', '', 1, '若依', '2026-05-22', 2, NULL, 3, NULL, '风范', 'admin', '2026-05-22 19:45:29'),
	(26, '0', 1, '客户1', 7, 'PK202605120002', 'OB202605221517169947', 13, '辅导费收到', 1, 398.00, NULL, '656456456', 5, 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260522/978a506dde8d58eaea9237b0a626e275.png', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260522/84edd8ed40240dc8495eac01ecdf935e.png', 1, '若依', '2026-05-22', 2, NULL, 3, NULL, '65464564', 'admin', '2026-05-22 23:17:16'),
	(27, '0', 1, '客户1', 12, NULL, 'OB202605291455156027', 18, '达大厦大声道', 1, 980.00, NULL, '模棱两可', 5, 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260529/dce0e64022794884f849a80c0e667300.jpg', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260529/ccb8f124cbdf36dad5af4add6cca1aeb.jpg', 1, '若依', '2026-05-29', 2, NULL, 3, NULL, '攻击力', 'admin', '2026-05-29 14:55:15');
/*!40000 ALTER TABLE `biz_operation_record` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_order_item 结构
DROP TABLE IF EXISTS `biz_order_item`;
CREATE TABLE IF NOT EXISTS `biz_order_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `product_name` varchar(100) NOT NULL COMMENT '品项名称',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '次数',
  `deal_amount` decimal(12,2) DEFAULT '0.00' COMMENT '成交金额',
  `paid_amount` decimal(12,2) DEFAULT '0.00' COMMENT '实付金额',
  `unit_price` decimal(10,2) DEFAULT '0.00' COMMENT '单次价',
  `owed_amount` decimal(10,2) DEFAULT '0.00' COMMENT '欠款金额',
  `payment_method` varchar(50) DEFAULT 'cash' COMMENT '付款方式',
  `is_our_operation` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否我们操作(0否1是)',
  `customer_feedback` varchar(500) DEFAULT NULL COMMENT '顾客反馈',
  `before_photo` varchar(500) DEFAULT NULL COMMENT '操作前对比照',
  `after_photo` varchar(500) DEFAULT NULL COMMENT '操作后对比照',
  `remark` text COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`item_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';

-- 正在导出表  fuchenpro.biz_order_item 的数据：~27 rows (大约)
DELETE FROM `biz_order_item`;
/*!40000 ALTER TABLE `biz_order_item` DISABLE KEYS */;
INSERT INTO `biz_order_item` (`item_id`, `order_id`, `product_name`, `quantity`, `deal_amount`, `paid_amount`, `unit_price`, `owed_amount`, `payment_method`, `is_our_operation`, `customer_feedback`, `before_photo`, `after_photo`, `remark`, `create_time`) VALUES
	(1, 1, '品项1', 10, 3980.00, 3980.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-09 22:50:40'),
	(2, 1, '品项2', 10, 3980.00, 3980.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-09 22:50:40'),
	(3, 2, '品项3', 1, 0.00, 0.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-10 22:48:01'),
	(4, 2, '品项4', 1, 0.00, 0.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-10 22:48:01'),
	(5, 3, '你明明', 1, 380.00, 380.00, 380.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-11 00:04:07'),
	(8, 5, 'fsdfs', 1, 333.00, 33.00, 333.00, 300.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-12 00:49:14'),
	(9, 5, 'eqwe', 1, 444.00, 444.00, 444.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-12 00:49:14'),
	(12, 7, '还款-啊实打实', 1, 100.00, 100.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, '支付方式: cash', '2026-05-12 17:05:07'),
	(13, 8, '对方水电费', 10, 3980.00, 3000.00, 398.00, 980.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-12 20:21:56'),
	(14, 8, '辅导费收到', 10, 3980.00, 3980.00, 398.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-12 20:21:56'),
	(15, 9, '还款-啊实打实', 1, 100.00, 100.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, '支付方式: cash', '2026-05-12 20:28:11'),
	(16, 10, '还款-啊实打实', 1, 200.00, 200.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, '支付方式: cash', '2026-05-12 20:28:27'),
	(17, 11, '额废物费', 1, 680.00, 680.00, 680.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-22 12:42:26'),
	(18, 12, '额废物费', 1, 0.00, 0.00, 680.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-22 15:55:04'),
	(19, 13, '还款-测试套餐2', 1, 200.00, 200.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, '支付方式: cash', '2026-05-22 15:56:27'),
	(20, 14, '还款-测试套餐2', 1, 100.00, 100.00, 0.00, 0.00, 'cash', 1, NULL, NULL, NULL, '支付方式: cash', '2026-05-22 16:26:19'),
	(21, 15, '对方水电费', 1, 0.00, 0.00, 398.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-22 19:45:29'),
	(22, 16, '辅导费收到', 1, 0.00, 0.00, 398.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-22 23:17:16'),
	(23, 17, '很反感很反感', 1, 1000.00, 1000.00, 1000.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-25 19:58:04'),
	(24, 18, '功夫格斗', 1, 1000.00, 1000.00, 1000.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-25 20:01:19'),
	(25, 19, '我打的', 1, 980.00, 980.00, 980.00, 0.00, 'card', 1, NULL, NULL, NULL, NULL, '2026-05-26 20:09:14'),
	(26, 20, '达大厦大声道', 1, 980.00, 980.00, 980.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-27 22:13:13'),
	(27, 21, '防守打法都是', 1, 9800.00, 8000.00, 9800.00, 1800.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-28 15:20:16'),
	(28, 22, 'hfghfg', 1, 888.00, 800.00, 888.00, 88.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-28 16:44:25'),
	(29, 23, '242424', 1, 888.00, 880.00, 888.00, 8.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-28 16:46:04'),
	(30, 24, '鬼地方个', 5, 5555.00, 5000.00, 1111.00, 555.00, 'card', 1, NULL, NULL, NULL, NULL, '2026-05-28 17:30:15'),
	(31, 25, '达大厦大声道', 1, 980.00, 0.00, 980.00, 980.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-05-29 14:55:15');
/*!40000 ALTER TABLE `biz_order_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_package_item 结构
DROP TABLE IF EXISTS `biz_package_item`;
CREATE TABLE IF NOT EXISTS `biz_package_item` (
  `package_item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '套餐明细ID',
  `package_id` bigint(20) NOT NULL COMMENT '套餐ID',
  `product_name` varchar(100) NOT NULL COMMENT '品项名称',
  `unit_price` decimal(12,2) DEFAULT '0.00' COMMENT '单次价格',
  `plan_price` decimal(12,2) DEFAULT '0.00' COMMENT '方案总价',
  `deal_price` decimal(12,2) DEFAULT '0.00' COMMENT '成交金额',
  `paid_amount` decimal(12,2) DEFAULT '0.00' COMMENT '实付金额',
  `owed_amount` decimal(12,2) DEFAULT '0.00' COMMENT '欠款金额',
  `total_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '总次数',
  `used_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '已用次数',
  `remaining_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '剩余次数',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`package_item_id`),
  KEY `idx_package_id` (`package_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='套餐明细表';

-- 正在导出表  fuchenpro.biz_package_item 的数据：~18 rows (大约)
DELETE FROM `biz_package_item`;
/*!40000 ALTER TABLE `biz_package_item` DISABLE KEYS */;
INSERT INTO `biz_package_item` (`package_item_id`, `package_id`, `product_name`, `unit_price`, `plan_price`, `deal_price`, `paid_amount`, `owed_amount`, `total_quantity`, `used_quantity`, `remaining_quantity`, `remark`) VALUES
	(1, 1, '品项1', 398.00, 3980.00, 3980.00, 3980.00, 0.00, 10, 5, 5, NULL),
	(2, 1, '品项2', 398.00, 3980.00, 3980.00, 3980.00, 0.00, 10, 5, 5, NULL),
	(3, 2, '品项3', 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0, 1, NULL),
	(4, 2, '品项4', 0.00, 0.00, 0.00, 0.00, 0.00, 1, 1, 0, NULL),
	(5, 3, '你明明', 380.00, 0.00, 380.00, 380.00, 0.00, 1, 0, 1, NULL),
	(8, 5, 'fsdfs', 333.00, 0.00, 333.00, 33.00, 300.00, 1, 1, 0, NULL),
	(9, 5, 'eqwe', 444.00, 0.00, 444.00, 444.00, 0.00, 1, 1, 0, NULL),
	(12, 7, '对方水电费', 398.00, 0.00, 3980.00, 3000.00, 980.00, 10, 10, 0, NULL),
	(13, 7, '辅导费收到', 398.00, 0.00, 3980.00, 3980.00, 0.00, 10, 8, 2, NULL),
	(14, 8, '额废物费', 680.00, 0.00, 680.00, 680.00, 0.00, 1, 1, 0, NULL),
	(15, 9, '很反感很反感', 1000.00, 1000.00, 1000.00, 1000.00, 0.00, 1, 0, 1, NULL),
	(16, 10, '功夫格斗', 1000.00, 1000.00, 1000.00, 1000.00, 0.00, 1, 0, 1, NULL),
	(17, 11, '我打的', 980.00, 980.00, 980.00, 980.00, 0.00, 1, 0, 1, NULL),
	(18, 12, '达大厦大声道', 980.00, 980.00, 980.00, 980.00, 0.00, 1, 1, 0, NULL),
	(19, 13, '防守打法都是', 9800.00, 9800.00, 9800.00, 8000.00, 1800.00, 1, 0, 1, NULL),
	(20, 14, 'hfghfg', 888.00, 888.00, 888.00, 800.00, 88.00, 1, 0, 1, NULL),
	(21, 15, '242424', 888.00, 888.00, 888.00, 880.00, 8.00, 1, 0, 1, NULL),
	(22, 16, '鬼地方个', 1111.00, 5555.00, 5555.00, 5000.00, 555.00, 5, 0, 5, NULL);
/*!40000 ALTER TABLE `biz_package_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_plan 结构
DROP TABLE IF EXISTS `biz_plan`;
CREATE TABLE IF NOT EXISTS `biz_plan` (
  `plan_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `plan_no` varchar(30) NOT NULL COMMENT '方案编号',
  `enterprise_id` bigint(20) NOT NULL COMMENT '企业ID',
  `plan_name` varchar(100) NOT NULL COMMENT '方案名称',
  `commission_rate` decimal(5,2) DEFAULT '0.00' COMMENT '分成比例(%)',
  `plan_amount` decimal(12,2) DEFAULT '0.00' COMMENT '方案金额(店家付款)',
  `gift_amount` decimal(12,2) DEFAULT '0.00' COMMENT '配赠金额',
  `shipped_amount` decimal(12,2) DEFAULT '0.00' COMMENT '已出金额',
  `remaining_amount` decimal(12,2) DEFAULT '0.00' COMMENT '剩余金额',
  `effective_date` date DEFAULT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `audit_status` char(1) DEFAULT '0' COMMENT '审核状态(0草稿 1待审核 2已审核 3已完成 4已驳回)',
  `audit_by` varchar(64) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审核备注',
  `submit_by` varchar(64) DEFAULT NULL COMMENT '提交审核人',
  `submit_time` datetime DEFAULT NULL COMMENT '提交审核时间',
  `status_change_by` varchar(64) DEFAULT NULL COMMENT '状态变更人',
  `status_change_time` datetime DEFAULT NULL COMMENT '状态变更时间',
  `status` char(1) DEFAULT '0' COMMENT '启用状态(0启用 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`plan_id`),
  UNIQUE KEY `uk_plan_no` (`plan_no`),
  KEY `idx_enterprise_id` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='方案表';

-- 正在导出表  fuchenpro.biz_plan 的数据：~6 rows (大约)
DELETE FROM `biz_plan`;
/*!40000 ALTER TABLE `biz_plan` DISABLE KEYS */;
INSERT INTO `biz_plan` (`plan_id`, `plan_no`, `enterprise_id`, `plan_name`, `commission_rate`, `plan_amount`, `gift_amount`, `shipped_amount`, `remaining_amount`, `effective_date`, `expiry_date`, `audit_status`, `audit_by`, `audit_time`, `audit_remark`, `submit_by`, `submit_time`, `status_change_by`, `status_change_time`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'PL20260507001', 2, '逆龄奢 30%方案', 30.00, 100000.00, 150000.00, 99380.00, 50620.00, '2026-05-07', '2027-05-01', '2', 'admin', '2026-05-07 10:46:07', '', NULL, NULL, NULL, NULL, '0', NULL, 'admin', '2026-05-07 06:47:53', 'admin', '2026-05-07 15:03:48'),
	(2, 'PL20260507002', 2, '逆龄奢 25%方案', 25.00, 100000.00, 100000.00, 10000.00, 90000.00, '2026-05-07', '2028-05-04', '2', 'admin', '2026-05-07 15:18:22', '', 'admin', '2026-05-07 15:18:15', NULL, NULL, '0', '不不不不', 'admin', '2026-05-07 12:36:03', NULL, '2026-05-07 15:19:20'),
	(3, 'PL20260507003', 1, '馥田诗 30%方案', 30.00, 100000.00, 100000.00, 0.00, 100000.00, '2026-05-08', '2027-05-10', '2', 'admin', '2026-05-07 15:23:48', '', 'admin', '2026-05-07 15:23:44', NULL, NULL, '0', '11111', 'admin', '2026-05-07 15:23:38', NULL, '2026-05-07 15:23:48'),
	(4, 'PL20260508001', 1, '馥田诗 0%方案', 30.00, 300000.00, 300000.00, 75580.00, 224420.00, '2026-05-08', '2027-05-08', '2', 'admin', '2026-05-08 21:33:36', '', 'admin', '2026-05-08 21:33:27', 'admin', '2026-05-26 12:32:25', '0', NULL, 'admin', '2026-05-08 21:33:16', NULL, '2026-05-27 19:10:40'),
	(5, 'PL20260518001', 2, '逆龄奢 0%方案', 30.00, 100000.00, 300000.00, 0.00, 300000.00, '2026-05-18', '2028-05-31', '4', '', '2026-05-18 19:57:41', '法国很反感', 'admin', '2026-05-18 19:27:55', NULL, NULL, '0', NULL, 'admin', '2026-05-18 13:33:13', 'admin', '2026-05-18 19:57:41'),
	(6, 'PL20260526001', 4, '企业1 方案', 30.00, 100000.00, 33333.00, 33333.00, 0.00, '0000-00-00', '2016-12-01', '3', 'admin', '2026-05-26 14:19:01', '', 'admin', '2026-05-26 14:18:58', NULL, NULL, '0', NULL, 'admin', '2026-05-26 14:18:42', NULL, '2026-05-26 14:41:10');
/*!40000 ALTER TABLE `biz_plan` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_plan_item 结构
DROP TABLE IF EXISTS `biz_plan_item`;
CREATE TABLE IF NOT EXISTS `biz_plan_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `plan_id` bigint(20) NOT NULL COMMENT '方案ID',
  `product_id` bigint(20) DEFAULT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `supplier_id` bigint(20) DEFAULT NULL COMMENT '供货商ID',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供货商名称',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位整 2副单位拆)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `quantity` int(11) DEFAULT '0' COMMENT '数量(最小单位)',
  `spec` varchar(20) DEFAULT NULL COMMENT '规格',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额',
  `shipped_quantity` int(11) DEFAULT '0' COMMENT '已出数量',
  `remaining_quantity` int(11) DEFAULT '0' COMMENT '剩余数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='方案配赠明细表';

-- 正在导出表  fuchenpro.biz_plan_item 的数据：~7 rows (大约)
DELETE FROM `biz_plan_item`;
/*!40000 ALTER TABLE `biz_plan_item` DISABLE KEYS */;
INSERT INTO `biz_plan_item` (`item_id`, `plan_id`, `product_id`, `product_name`, `supplier_id`, `supplier_name`, `unit_type`, `pack_qty`, `quantity`, `spec`, `sale_price`, `amount`, `shipped_quantity`, `remaining_quantity`, `remark`) VALUES
	(4, 1, 2, '测试1', 1, '南京伊美荟', '2', 10, 100, '支', 680.00, 68000.00, 100, 0, NULL),
	(5, 1, 1, 'GCS-p7', 1, '南京伊美荟', '1', 10, 10, '盒', 2580.00, 25800.00, 1, 9, NULL),
	(6, 2, 2, '测试1', 1, '南京伊美荟', '1', 10, 10, '盒', 6800.00, 68000.00, 1, 9, NULL),
	(7, 2, 1, 'GCS-p7', 1, '南京伊美荟', '2', 10, 20, '支', 258.00, 5160.00, 0, 20, NULL),
	(8, 4, 2, '测试1', 1, '南京伊美荟', '1', 10, 10, '盒', 6800.00, 68000.00, 10, 0, NULL),
	(10, 5, 2, '测试1', 1, '南京伊美荟', '1', 10, 40, '盒', 6800.00, 272000.00, 0, 40, NULL),
	(11, 5, 1, 'GCS-p7', 1, '南京伊美荟', '1', 10, 11, '盒', 2580.00, 28380.00, 0, 11, NULL),
	(12, 6, 2, '测试1', 1, NULL, '1', 10, 100, '盒', 6800.00, 680000.00, 100, 0, NULL);
/*!40000 ALTER TABLE `biz_plan_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_product 结构
DROP TABLE IF EXISTS `biz_product`;
CREATE TABLE IF NOT EXISTS `biz_product` (
  `product_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '货品ID',
  `product_name` varchar(100) NOT NULL COMMENT '品名',
  `product_code` varchar(50) NOT NULL COMMENT '货品编码',
  `supplier_id` bigint(20) DEFAULT NULL COMMENT '供货商ID',
  `spec` char(1) DEFAULT NULL COMMENT '副单位/规格(字典biz_product_spec)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例(1主单位=多少副单位)',
  `category` char(1) NOT NULL DEFAULT '1' COMMENT '类别(1院装-面部 2院装-身体 3仪器-面部 4仪器-身体 5家居-面部 6家居-身体)',
  `unit` char(1) DEFAULT NULL COMMENT '主单位(字典biz_product_unit)',
  `purchase_price` decimal(10,2) DEFAULT '0.00' COMMENT '进货价',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '出货价',
  `sale_price_spec` decimal(10,2) DEFAULT '0.00' COMMENT '出货价(按副单位)',
  `shelf_life_days` int(11) DEFAULT NULL COMMENT '保质期(天)',
  `has_expiry` char(1) DEFAULT '0' COMMENT '是否有有效期(0否 1是)',
  `warn_qty` int(11) DEFAULT '0' COMMENT '库存预警数量',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uk_product_code` (`product_code`),
  KEY `idx_product_name` (`product_name`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='货品表';

-- 正在导出表  fuchenpro.biz_product 的数据：~2 rows (大约)
DELETE FROM `biz_product`;
/*!40000 ALTER TABLE `biz_product` DISABLE KEYS */;
INSERT INTO `biz_product` (`product_id`, `product_name`, `product_code`, `supplier_id`, `spec`, `pack_qty`, `category`, `unit`, `purchase_price`, `sale_price`, `sale_price_spec`, `shelf_life_days`, `has_expiry`, `warn_qty`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'GCS-p7', 'gcs-p7', 1, '1', 10, '3', '5', 2580.00, 2580.00, 258.00, 365, '0', 50, '0', NULL, 'admin', '2026-04-29 15:10:14', 'admin', '2026-05-03 21:51:49'),
	(2, '测试1', 'CS1-20260504', 1, '1', 10, '1', '5', 6800.00, 6800.00, 680.00, NULL, '0', 20, '0', NULL, 'admin', '2026-05-05 00:11:54', 'admin', '2026-05-17 19:56:56');
/*!40000 ALTER TABLE `biz_product` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_repayment_record 结构
DROP TABLE IF EXISTS `biz_repayment_record`;
CREATE TABLE IF NOT EXISTS `biz_repayment_record` (
  `repayment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '还款ID',
  `repayment_no` varchar(50) DEFAULT NULL COMMENT '还款编号',
  `customer_id` bigint(20) DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `package_id` bigint(20) DEFAULT NULL COMMENT '套餐ID（还款来源）',
  `package_no` varchar(50) DEFAULT NULL COMMENT '套餐编号',
  `package_name` varchar(200) DEFAULT NULL COMMENT '套餐名称',
  `order_id` bigint(20) DEFAULT NULL COMMENT '原订单ID',
  `order_no` varchar(50) DEFAULT NULL COMMENT '原订单编号',
  `repayment_order_id` bigint(20) DEFAULT NULL COMMENT '还款订单ID',
  `repayment_order_no` varchar(50) DEFAULT NULL COMMENT '还款订单编号',
  `repayment_amount` decimal(12,2) DEFAULT '0.00' COMMENT '还款金额',
  `repayment_type` char(1) DEFAULT '1' COMMENT '还款类型：1-套餐还款 2-订单还款',
  `payment_method` varchar(50) DEFAULT NULL COMMENT '支付方式',
  `status` char(1) DEFAULT '0' COMMENT '状态：0-待审核 1-已审核 2-已取消',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `creator_user_id` bigint(20) DEFAULT NULL COMMENT '创建用户ID',
  `creator_user_name` varchar(64) DEFAULT NULL COMMENT '创建用户名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `audit_by` varchar(64) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`repayment_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_package_id` (`package_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='还款记录表';

-- 正在导出表  fuchenpro.biz_repayment_record 的数据：~5 rows (大约)
DELETE FROM `biz_repayment_record`;
/*!40000 ALTER TABLE `biz_repayment_record` DISABLE KEYS */;
INSERT INTO `biz_repayment_record` (`repayment_id`, `repayment_no`, `customer_id`, `customer_name`, `package_id`, `package_no`, `package_name`, `order_id`, `order_no`, `repayment_order_id`, `repayment_order_no`, `repayment_amount`, `repayment_type`, `payment_method`, `status`, `remark`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `create_by`, `creator_user_id`, `creator_user_name`, `create_time`, `update_by`, `update_time`, `audit_by`, `audit_time`) VALUES
	(1, 'RP202605120001', 1, '客户1', 5, 'PK202605120001', '啊实打实', 5, 'SO202605120001', 7, 'SO202605120002', 100.00, '1', 'cash', '0', '科技局', 2, '逆龄奢', 0, '宜川店', 'admin', 1, 'admin', '2026-05-12 17:05:07', NULL, NULL, NULL, NULL),
	(2, 'RP202605120002', 1, '客户1', 5, 'PK202605120001', '啊实打实', 5, 'SO202605120001', 9, 'SO202605120004', 100.00, '1', 'cash', '1', '111', 2, '逆龄奢', 3, '宜川店', 'admin', 1, 'admin', '2026-05-12 20:28:11', NULL, NULL, 'admin', '2026-05-12 20:28:11'),
	(3, 'RP202605120003', 1, '客户1', 5, 'PK202605120001', '啊实打实', 5, 'SO202605120001', 10, 'SO202605120005', 200.00, '1', 'cash', '1', '200', 2, '逆龄奢', 3, '宜川店', 'admin', 1, 'admin', '2026-05-12 20:28:27', NULL, NULL, 'admin', '2026-05-12 20:28:27'),
	(4, 'RP202605220001', 1, '客户1', 7, 'PK202605120002', '测试套餐2', 8, 'SO202605120003', 13, 'SO202605220002', 200.00, '1', 'cash', '1', 'fdfs ', 2, '逆龄奢', 3, '宜川店', 'admin', 1, '若依', '2026-05-22 15:56:27', NULL, NULL, '若依', '2026-05-22 15:56:27'),
	(5, 'RP202605220002', 1, '客户1', 7, 'PK202605120002', '测试套餐2', 8, 'SO202605120003', 14, 'SO202605220003', 100.00, '1', 'cash', '1', '', 2, '逆龄奢', 3, '宜川店', 'admin', 1, '若依', '2026-05-22 16:26:19', NULL, NULL, '若依', '2026-05-22 16:26:19');
/*!40000 ALTER TABLE `biz_repayment_record` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_sales_order 结构
DROP TABLE IF EXISTS `biz_sales_order`;
CREATE TABLE IF NOT EXISTS `biz_sales_order` (
  `order_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(30) NOT NULL COMMENT '订单编号',
  `customer_id` bigint(20) NOT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `enterprise_id` bigint(20) NOT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `store_dealer` varchar(100) DEFAULT NULL COMMENT '门店成交人',
  `deal_amount` decimal(12,2) DEFAULT '0.00' COMMENT '成交总金额',
  `paid_amount` decimal(12,2) DEFAULT '0.00' COMMENT '实付金额',
  `owed_amount` decimal(12,2) DEFAULT '0.00' COMMENT '欠款金额',
  `payment_method` varchar(50) DEFAULT 'cash' COMMENT '付款方式',
  `order_status` char(1) NOT NULL DEFAULT '0' COMMENT '订单状态(0待确认1已成交2已取消)',
  `source_type` char(1) NOT NULL DEFAULT '0' COMMENT '来源类型（0开单 1操作 2还款 3手动）',
  `operation_batch_id` varchar(32) DEFAULT NULL COMMENT '操作批次ID（来源为操作时关联）',
  `package_name` varchar(200) DEFAULT '' COMMENT '套餐名称',
  `enterprise_audit_status` char(1) NOT NULL DEFAULT '0' COMMENT '企业审核(0未审核1已审核)',
  `finance_audit_status` char(1) NOT NULL DEFAULT '0' COMMENT '财务审核(0未审核1已审核)',
  `enterprise_audit_by` varchar(64) DEFAULT NULL COMMENT '企业审核人',
  `enterprise_audit_time` datetime DEFAULT NULL COMMENT '企业审核时间',
  `finance_audit_by` varchar(64) DEFAULT NULL COMMENT '财务审核人',
  `finance_audit_time` datetime DEFAULT NULL COMMENT '财务审核时间',
  `creator_user_id` bigint(20) DEFAULT NULL COMMENT '开单员工ID',
  `creator_user_name` varchar(50) DEFAULT NULL COMMENT '开单员工姓名',
  `remark` text COMMENT '备注',
  `customer_feedback` varchar(500) DEFAULT NULL COMMENT '顾客反馈',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_store_id` (`store_id`),
  KEY `idx_order_status` (`order_status`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售订单表';

-- 正在导出表  fuchenpro.biz_sales_order 的数据：~23 rows (大约)
DELETE FROM `biz_sales_order`;
/*!40000 ALTER TABLE `biz_sales_order` DISABLE KEYS */;
INSERT INTO `biz_sales_order` (`order_id`, `order_no`, `customer_id`, `customer_name`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `store_dealer`, `deal_amount`, `paid_amount`, `owed_amount`, `payment_method`, `order_status`, `source_type`, `operation_batch_id`, `package_name`, `enterprise_audit_status`, `finance_audit_status`, `enterprise_audit_by`, `enterprise_audit_time`, `finance_audit_by`, `finance_audit_time`, `creator_user_id`, `creator_user_name`, `remark`, `customer_feedback`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'SO202605090001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 7960.00, 7960.00, 0.00, 'cash', '2', '0', NULL, '套餐卡1', '1', '1', '若依', '2026-05-25 18:39:09', '若依', '2026-05-25 18:39:11', 1, 'admin', '防守打法神鼎飞丹砂方式搭嘎', '', 'admin', '2026-05-09 22:50:40', '', '2026-05-25 18:39:11'),
	(2, 'SO202605100001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 0.00, 0.00, 0.00, 'cash', '1', '0', NULL, '品项套餐2', '1', '1', '若依', '2026-05-25 18:39:14', 'admin', '2026-05-12 00:18:48', 1, 'admin', '额温枪委屈委屈各付各的付个', '', 'admin', '2026-05-10 22:48:01', '', '2026-05-25 18:39:14'),
	(3, 'SO202605110001', 1, '客户1', 2, '逆龄奢', 0, '宜川店', NULL, 380.00, 380.00, 0.00, 'cash', '2', '0', NULL, '停机了', '1', '1', '若依', '2026-05-25 18:39:13', '若依', '2026-05-25 18:39:14', 1, 'admin', '吉里吉里', NULL, 'admin', '2026-05-11 00:04:07', '', '2026-05-25 18:39:14'),
	(5, 'SO202605120001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 777.00, 477.00, 300.00, 'cash', '2', '0', NULL, '啊实打实', '1', '1', '若依', '2026-05-25 18:39:15', '若依', '2026-05-25 18:39:15', 1, 'admin', '大大是的', NULL, 'admin', '2026-05-12 00:49:14', '', '2026-05-25 18:39:15'),
	(7, 'SO202605120002', 1, '客户1', 2, '逆龄奢', 0, '宜川店', NULL, 100.00, 100.00, 0.00, 'cash', '3', '2', NULL, '还款-啊实打实', '1', '1', 'admin', '2026-05-12 17:05:07', 'admin', '2026-05-12 17:05:07', 1, 'admin', '科技局 [还款订单]', '', 'admin', '2026-05-12 17:05:07', '', '2026-05-22 00:28:17'),
	(8, 'SO202605120003', 1, '客户1', 2, '逆龄奢', 3, '宜川店', '张三', 7960.00, 6980.00, 980.00, 'cash', '1', '0', NULL, '测试套餐2', '1', '1', '若依', '2026-05-25 18:39:05', '若依', '2026-05-22 19:21:28', 1, 'admin', '发的范德萨', NULL, 'admin', '2026-05-12 20:21:56', '', '2026-05-25 18:39:05'),
	(9, 'SO202605120004', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 100.00, 100.00, 0.00, 'cash', '3', '2', NULL, '还款-啊实打实', '1', '1', 'admin', '2026-05-12 20:28:11', 'admin', '2026-05-12 20:28:11', 1, 'admin', '111 [还款订单]', '', 'admin', '2026-05-12 20:28:11', '', '2026-05-22 00:28:17'),
	(10, 'SO202605120005', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 200.00, 200.00, 0.00, 'cash', '3', '2', NULL, '还款-啊实打实', '1', '1', 'admin', '2026-05-12 20:28:27', 'admin', '2026-05-12 20:28:27', 1, 'admin', '200 [还款订单]', '', 'admin', '2026-05-12 20:28:27', '', '2026-05-22 00:28:17'),
	(11, 'SO202605220001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', '房东方', 680.00, 680.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '若依', '2026-05-25 18:39:04', '若依', '2026-05-25 18:39:04', 1, '若依', '苟富贵', '', 'admin', '2026-05-22 12:42:26', '', '2026-05-25 18:39:04'),
	(12, 'OP202605220001', 1, '客户1', 2, '', 3, '', NULL, 680.00, 0.00, 0.00, 'cash', '1', '1', 'OB202605220755047919', '额废物费', '1', '1', NULL, NULL, NULL, NULL, 1, '若依', '[操作订单] 持卡操作', NULL, '若依', '2026-05-22 15:55:04', '', '2026-05-22 15:55:04'),
	(13, 'SO202605220002', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 200.00, 200.00, 0.00, 'cash', '2', '2', NULL, '还款-测试套餐2', '1', '1', '若依', '2026-05-22 15:56:27', '若依', '2026-05-22 15:56:27', 1, '若依', 'fdfs  [还款订单]', '', 'admin', '2026-05-22 15:56:27', '', '2026-05-22 15:56:27'),
	(14, 'SO202605220003', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 0.00, 100.00, 0.00, 'cash', '2', '2', NULL, '还款-测试套餐2', '1', '1', '若依', '2026-05-22 16:26:19', '若依', '2026-05-22 16:26:19', 1, '若依', ' [还款订单]', '', 'admin', '2026-05-22 16:26:19', '', '2026-05-22 16:26:19'),
	(15, 'OP202605220002', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 398.00, 0.00, 0.00, 'cash', '1', '1', 'OB202605221145294283', '对方水电费', '1', '1', NULL, NULL, NULL, NULL, 1, '若依', '[操作订单] 持卡操作', NULL, '若依', '2026-05-22 19:45:29', '', '2026-05-22 19:45:29'),
	(16, 'OP202605220003', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 398.00, 0.00, 0.00, 'cash', '1', '1', 'OB202605221517169947', '辅导费收到', '1', '1', NULL, NULL, NULL, NULL, 1, '若依', '[操作订单] 持卡操作', NULL, '若依', '2026-05-22 23:17:16', '', '2026-05-22 23:17:16'),
	(17, 'SO202605250001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', '来来来', 1000.00, 1000.00, 0.00, 'cash', '1', '0', NULL, '进货价格', '1', '0', '若依', '2026-05-25 19:58:31', NULL, NULL, 1, '若依', '金龟换酒', NULL, 'admin', '2026-05-25 19:58:04', '', '2026-05-25 19:58:31'),
	(18, 'SO202605250002', 2, '测试顾客2', 2, '逆龄奢', 3, '宜川店', '和通过', 1000.00, 1000.00, 0.00, 'cash', '1', '0', NULL, '液态氧', '1', '0', '若依', '2026-05-25 20:01:37', NULL, NULL, 1, '若依', '换个', NULL, 'admin', '2026-05-25 20:01:19', '', '2026-05-25 20:01:37'),
	(19, 'SO202605260001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', '', 980.00, 980.00, 0.00, 'card', '1', '0', NULL, '', '1', '0', '若依', '2026-05-27 14:49:24', NULL, NULL, 1, '若依', '', '', 'admin', '2026-05-26 20:09:14', '', '2026-05-27 14:49:24'),
	(20, 'SO202605270001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', '辅导费', 980.00, 980.00, 0.00, 'cash', '4', '0', NULL, '阿达', '0', '0', NULL, NULL, NULL, NULL, 1, '若依', '梵蒂冈', NULL, 'admin', '2026-05-27 22:13:13', '', '2026-05-27 22:15:51'),
	(21, 'SO202605280001', 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '美美', 9800.00, 8000.00, 1800.00, 'cash', '1', '0', NULL, '辅导费', '1', '0', '若依', '2026-05-28 15:22:26', NULL, NULL, 1, '若依', '德叔', NULL, 'admin', '2026-05-28 15:20:16', '', '2026-05-28 15:22:26'),
	(22, 'SO202605280002', 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '25', 888.00, 800.00, 88.00, 'cash', '1', '0', NULL, '225252', '1', '0', '若依', '2026-05-28 16:45:00', NULL, NULL, 1, '若依', '', NULL, 'admin', '2026-05-28 16:44:25', '', '2026-05-28 16:45:00'),
	(23, 'SO202605280003', 8, '客户3', 1, '馥田诗', 2, '肇嘉浜', '', 888.00, 880.00, 8.00, 'cash', '1', '0', NULL, 'h很反感很符合', '1', '0', '若依', '2026-05-28 16:46:25', NULL, NULL, 1, '若依', '', NULL, 'admin', '2026-05-28 16:46:04', '', '2026-05-28 16:46:25'),
	(24, 'SO202605280004', 4, '李明', 2, '逆龄奢', 3, '宜川店', '给对方', 5555.00, 5000.00, 555.00, 'card', '1', '0', NULL, '鬼地方个', '1', '0', '若依', '2026-05-28 17:30:31', NULL, NULL, 1, '若依', '鬼地方个', '', 'admin', '2026-05-28 17:30:15', '', '2026-05-28 17:30:31'),
	(25, 'OP202605290001', 1, '客户1', 2, '逆龄奢', 3, '宜川店', NULL, 980.00, 0.00, 0.00, 'cash', '1', '1', 'OB202605291455156027', '达大厦大声道', '1', '1', NULL, NULL, NULL, NULL, 1, '若依', '[操作订单] 持卡操作', NULL, '若依', '2026-05-29 14:55:15', '', '2026-05-29 14:55:15');
/*!40000 ALTER TABLE `biz_sales_order` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_schedule 结构
DROP TABLE IF EXISTS `biz_schedule`;
CREATE TABLE IF NOT EXISTS `biz_schedule` (
  `schedule_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行程ID',
  `user_id` bigint(20) NOT NULL COMMENT '员工ID',
  `user_name` varchar(50) DEFAULT NULL COMMENT '员工姓名',
  `enterprise_id` bigint(20) NOT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `schedule_date` date NOT NULL COMMENT '行程日期',
  `purpose` char(1) NOT NULL COMMENT '下店目的(1爆卡 2启动销售 3售后服务 4洽谈业务)',
  `remark` text COMMENT '备注',
  `status` char(1) NOT NULL DEFAULT '1' COMMENT '状态(1已预约 2服务中 3已完成 4已取消)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`schedule_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_schedule_date` (`schedule_date`),
  KEY `idx_user_date` (`user_id`,`schedule_date`),
  KEY `idx_enterprise_date` (`enterprise_id`,`schedule_date`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='行程安排表';

-- 正在导出表  fuchenpro.biz_schedule 的数据：~40 rows (大约)
DELETE FROM `biz_schedule`;
/*!40000 ALTER TABLE `biz_schedule` DISABLE KEYS */;
INSERT INTO `biz_schedule` (`schedule_id`, `user_id`, `user_name`, `enterprise_id`, `enterprise_name`, `schedule_date`, `purpose`, `remark`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(43, 1, 'admin', 1, '馥田诗', '2026-04-08', '1', NULL, '1', 'admin', '2026-04-30 19:48:37', '', '2026-04-30 19:48:37'),
	(44, 1, 'admin', 1, '馥田诗', '2026-04-09', '1', NULL, '1', 'admin', '2026-04-30 19:48:37', '', '2026-04-30 19:48:37'),
	(45, 1, 'admin', 1, '馥田诗', '2026-04-10', '1', NULL, '1', 'admin', '2026-04-30 19:48:37', '', '2026-04-30 19:48:37'),
	(46, 1, 'admin', 1, '馥田诗', '2026-04-11', '1', NULL, '1', 'admin', '2026-04-30 19:48:37', '', '2026-04-30 19:48:37'),
	(47, 1, 'admin', 1, '馥田诗', '2026-04-12', '1', NULL, '1', 'admin', '2026-04-30 19:48:37', '', '2026-04-30 19:48:37'),
	(48, 2, 'ry', 1, '馥田诗', '2026-04-12', '2', NULL, '1', 'admin', '2026-04-30 19:48:44', '', '2026-04-30 19:48:44'),
	(49, 2, 'ry', 1, '馥田诗', '2026-04-13', '2', NULL, '1', 'admin', '2026-04-30 19:48:44', '', '2026-04-30 19:48:44'),
	(50, 2, 'ry', 1, '馥田诗', '2026-04-14', '2', NULL, '1', 'admin', '2026-04-30 19:48:44', '', '2026-04-30 19:48:44'),
	(51, 2, 'ry', 1, '馥田诗', '2026-04-15', '2', NULL, '1', 'admin', '2026-04-30 19:48:44', '', '2026-04-30 19:48:44'),
	(52, 2, 'ry', 1, '馥田诗', '2026-04-16', '2', NULL, '1', 'admin', '2026-04-30 19:48:44', '', '2026-04-30 19:48:44'),
	(66, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(67, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(68, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(69, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(70, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(71, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(72, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(73, 1, '若依', 2, '逆龄奢', '0000-00-00', '1', '，，', '1', 'admin', '2026-05-02 23:47:44', '', '2026-05-02 23:47:44'),
	(74, 1, '若依', 2, '逆龄奢', '2026-05-03', '1', '带上电脑', '1', 'admin', '2026-05-03 00:22:31', '', '2026-05-03 00:22:31'),
	(75, 1, '若依', 2, '逆龄奢', '2026-05-04', '1', '带上电脑', '1', 'admin', '2026-05-03 00:22:31', '', '2026-05-03 00:22:31'),
	(76, 1, '若依', 2, '逆龄奢', '2026-05-05', '1', '带上电脑', '1', 'admin', '2026-05-03 00:22:31', '', '2026-05-03 00:22:31'),
	(77, 1, '若依', 2, '逆龄奢', '2026-05-06', '1', '带上电脑', '1', 'admin', '2026-05-03 00:22:31', '', '2026-05-03 00:22:31'),
	(78, 1, '若依', 2, '逆龄奢', '2026-05-08', '1', '', '1', 'admin', '2026-05-03 01:04:32', '', '2026-05-03 01:04:32'),
	(79, 1, '若依', 2, '逆龄奢', '2026-05-09', '1', '', '1', 'admin', '2026-05-03 01:04:32', '', '2026-05-03 01:04:32'),
	(80, 1, '若依', 2, '逆龄奢', '2026-05-10', '1', '', '1', 'admin', '2026-05-03 01:04:32', '', '2026-05-03 01:04:32'),
	(81, 1, '若依', 1, '馥田诗', '2026-05-18', '2', '哈撒撒', '1', 'admin', '2026-05-03 01:05:21', '', '2026-05-03 01:05:21'),
	(82, 1, '若依', 1, '馥田诗', '2026-05-19', '2', '哈撒撒', '1', 'admin', '2026-05-03 01:05:21', '', '2026-05-03 01:05:21'),
	(83, 1, '若依', 1, '馥田诗', '2026-05-20', '2', '哈撒撒', '1', 'admin', '2026-05-03 01:05:21', '', '2026-05-03 01:05:21'),
	(84, 1, '若依', 1, '馥田诗', '2026-05-21', '2', '哈撒撒', '1', 'admin', '2026-05-03 01:05:21', '', '2026-05-03 01:05:21'),
	(90, 2, 'ry', 1, '馥田诗', '2026-05-12', '2', NULL, '2', 'admin', '2026-05-08 21:35:58', '', '2026-05-08 21:35:58'),
	(91, 2, 'ry', 1, '馥田诗', '2026-05-13', '2', NULL, '2', 'admin', '2026-05-08 21:35:58', '', '2026-05-08 21:35:58'),
	(92, 2, 'ry', 1, '馥田诗', '2026-05-14', '2', NULL, '2', 'admin', '2026-05-08 21:35:58', '', '2026-05-08 21:35:58'),
	(93, 2, 'ry', 1, '馥田诗', '2026-05-15', '2', NULL, '2', 'admin', '2026-05-08 21:35:58', '', '2026-05-08 21:35:58'),
	(94, 1, '若依', 1, '馥田诗', '2026-05-29', '2', '', '2', 'admin', '2026-05-08 21:35:58', 'admin', '2026-05-29 14:52:40'),
	(95, 1, '若依', 1, '馥田诗', '2026-05-22', '2', '150', '2', 'admin', '2026-05-16 20:15:26', '', '2026-05-16 20:15:26'),
	(96, 1, '若依', 1, '馥田诗', '2026-05-23', '2', '150', '2', 'admin', '2026-05-16 20:15:26', '', '2026-05-16 20:15:26'),
	(97, 1, '若依', 1, '馥田诗', '2026-05-24', '2', '150', '2', 'admin', '2026-05-16 20:15:26', '', '2026-05-16 20:15:26'),
	(98, 101, '奋斗奋斗', 2, '逆龄奢', '2026-05-11', '1', '大师', '1', 'admin', '2026-05-20 22:56:17', '', '2026-05-20 22:56:17'),
	(99, 101, '奋斗奋斗', 2, '逆龄奢', '2026-05-12', '1', '大师', '1', 'admin', '2026-05-20 22:56:17', '', '2026-05-20 22:56:17'),
	(100, 101, '奋斗奋斗', 2, '逆龄奢', '2026-05-13', '1', '大师', '1', 'admin', '2026-05-20 22:56:17', '', '2026-05-20 22:56:17');
/*!40000 ALTER TABLE `biz_schedule` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_shipment 结构
DROP TABLE IF EXISTS `biz_shipment`;
CREATE TABLE IF NOT EXISTS `biz_shipment` (
  `shipment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shipment_no` varchar(30) NOT NULL COMMENT '出货单号',
  `plan_id` bigint(20) NOT NULL COMMENT '关联方案ID',
  `enterprise_id` bigint(20) NOT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '收货人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额(折扣后)',
  `logistics_company` varchar(50) DEFAULT NULL COMMENT '物流公司',
  `logistics_no` varchar(50) DEFAULT NULL COMMENT '物流单号',
  `shipment_status` char(1) DEFAULT '0' COMMENT '出货状态(0待审核 1已审核 2已发货 3已收货 4已驳回)',
  `shipment_date` date DEFAULT NULL COMMENT '发货日期',
  `receipt_date` date DEFAULT NULL COMMENT '收货日期',
  `audit_by` varchar(64) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`shipment_id`),
  UNIQUE KEY `uk_shipment_no` (`shipment_no`),
  KEY `idx_plan_id` (`plan_id`),
  KEY `idx_enterprise_id` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出货单表';

-- 正在导出表  fuchenpro.biz_shipment 的数据：~6 rows (大约)
DELETE FROM `biz_shipment`;
/*!40000 ALTER TABLE `biz_shipment` DISABLE KEYS */;
INSERT INTO `biz_shipment` (`shipment_id`, `shipment_no`, `plan_id`, `enterprise_id`, `enterprise_name`, `contact_person`, `contact_phone`, `shipping_address`, `total_quantity`, `total_amount`, `logistics_company`, `logistics_no`, `shipment_status`, `shipment_date`, `receipt_date`, `audit_by`, `audit_time`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'SH20260507001', 1, 2, '逆龄奢', '木总', '13588888888', '发顺丰第四范式', 11, 9380.00, '', '', '3', '2026-05-07', '2026-05-07', 'admin', '2026-05-07 10:47:53', NULL, 'admin', '2026-05-07 10:47:13', NULL, '2026-05-07 15:02:08'),
	(2, 'SH20260507002', 1, 2, '逆龄奢', '木总', '13588888888', '发顺丰第四范式', 90, 90000.00, ' 11', '22', '3', '2026-05-07', '2026-05-07', 'admin', '2026-05-07 15:03:37', NULL, 'admin', '2026-05-07 15:03:22', NULL, '2026-05-07 15:03:48'),
	(3, 'SH20260507003', 2, 2, '逆龄奢', '木总', '13588888888', '发顺丰第四范式', 1, 10000.00, '222', '2222', '3', '2026-05-07', '2026-05-07', 'admin', '2026-05-07 15:19:11', NULL, 'admin', '2026-05-07 15:19:00', NULL, '2026-05-07 15:19:20'),
	(4, 'SH20260508001', 4, 1, '馥田诗', '汪志', '15888888888', '陆家浜路1396号', 11, 70580.00, '问问全文', '额电费', '3', '2026-05-08', '2026-05-08', 'admin', '2026-05-08 21:34:23', NULL, 'admin', '2026-05-08 21:34:08', NULL, '2026-05-08 21:34:47'),
	(5, 'SH20260526001', 6, 4, '企业1', '汪老板', '15555555555', '法国德国电饭锅电饭锅代发给对方大概给对方', 100, 33333.00, '41111', '1111', '3', '2026-05-26', '2026-05-26', 'admin', '2026-05-26 14:40:59', NULL, 'admin', '2026-05-26 14:40:38', NULL, '2026-05-26 14:41:10'),
	(6, 'SH20260526002', 4, 1, '馥田诗', '汪志', '15888888888', '陆家浜路1396号', 20, 5000.00, '德邦物流', 'DPK9997878787878', '3', '2026-05-26', '2026-05-27', 'admin', '2026-05-26 17:49:37', NULL, 'admin', '2026-05-26 16:22:12', NULL, '2026-05-27 19:10:40');
/*!40000 ALTER TABLE `biz_shipment` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_shipment_item 结构
DROP TABLE IF EXISTS `biz_shipment_item`;
CREATE TABLE IF NOT EXISTS `biz_shipment_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shipment_id` bigint(20) NOT NULL COMMENT '出货单ID',
  `plan_item_id` bigint(20) DEFAULT NULL COMMENT '关联方案明细ID',
  `product_id` bigint(20) DEFAULT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `supplier_id` bigint(20) DEFAULT NULL COMMENT '供货商ID',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供货商名称',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `quantity` int(11) DEFAULT '0' COMMENT '数量(最小单位)',
  `spec` varchar(20) DEFAULT NULL COMMENT '规格',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `discount_price` decimal(10,2) DEFAULT '0.00' COMMENT '折扣单价',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额(折扣单价×数量)',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_shipment_id` (`shipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出货明细表';

-- 正在导出表  fuchenpro.biz_shipment_item 的数据：~8 rows (大约)
DELETE FROM `biz_shipment_item`;
/*!40000 ALTER TABLE `biz_shipment_item` DISABLE KEYS */;
INSERT INTO `biz_shipment_item` (`item_id`, `shipment_id`, `plan_item_id`, `product_id`, `product_name`, `supplier_id`, `supplier_name`, `unit_type`, `pack_qty`, `quantity`, `spec`, `sale_price`, `discount_price`, `amount`, `remark`) VALUES
	(1, 1, 4, 2, '测试1', 1, '南京伊美荟', '2', 10, 10, '支', 680.00, 680.00, 6800.00, NULL),
	(2, 1, 5, 1, 'GCS-p7', 1, '南京伊美荟', '1', 10, 1, '盒', 2580.00, 2580.00, 2580.00, NULL),
	(3, 2, 4, 2, '测试1', 1, '南京伊美荟', '2', 10, 90, '支', 680.00, 1000.00, 90000.00, NULL),
	(4, 3, 6, 2, '测试1', 1, '南京伊美荟', '1', 10, 1, '盒', 6800.00, 10000.00, 10000.00, NULL),
	(5, 4, 8, 2, '测试1', 1, '南京伊美荟', '1', 10, 10, '盒', 6800.00, 6800.00, 68000.00, NULL),
	(6, 4, NULL, 1, 'GCS-p7', 1, '南京伊美荟', '1', 10, 1, '盒', 2580.00, 2580.00, 2580.00, NULL),
	(7, 5, 12, 2, '测试1', 1, NULL, '1', 10, 100, '盒', 6800.00, 333.33, 33333.00, NULL),
	(8, 6, NULL, 2, '测试1', 1, '南京伊美荟', '1', 10, 20, '盒', 6800.00, 250.00, 5000.00, NULL);
/*!40000 ALTER TABLE `biz_shipment_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_check 结构
DROP TABLE IF EXISTS `biz_stock_check`;
CREATE TABLE IF NOT EXISTS `biz_stock_check` (
  `stock_check_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '盘点单ID',
  `stock_check_no` varchar(30) NOT NULL COMMENT '盘点单号',
  `check_date` date DEFAULT NULL COMMENT '盘点日期',
  `total_quantity` int(11) DEFAULT '0' COMMENT '盘点总数量',
  `total_diff_quantity` int(11) DEFAULT '0' COMMENT '差异数量合计',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stock_check_id`),
  UNIQUE KEY `uk_stock_check_no` (`stock_check_no`),
  KEY `idx_check_date` (`check_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='盘点单主表';

-- 正在导出表  fuchenpro.biz_stock_check 的数据：~0 rows (大约)
DELETE FROM `biz_stock_check`;
/*!40000 ALTER TABLE `biz_stock_check` DISABLE KEYS */;
INSERT INTO `biz_stock_check` (`stock_check_id`, `stock_check_no`, `check_date`, `total_quantity`, `total_diff_quantity`, `operator_id`, `operator_name`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'PD20260505001', '2026-05-05', 19, 10, 1, '', '1', NULL, 'admin', '2026-05-05 23:20:56', '', '2026-05-05 23:21:22');
/*!40000 ALTER TABLE `biz_stock_check` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_check_item 结构
DROP TABLE IF EXISTS `biz_stock_check_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_check_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `stock_check_id` bigint(20) NOT NULL COMMENT '盘点单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `system_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '系统库存数量',
  `actual_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '实际盘点数量',
  `diff_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '差异数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_check_id` (`stock_check_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='盘点单明细表';

-- 正在导出表  fuchenpro.biz_stock_check_item 的数据：~2 rows (大约)
DELETE FROM `biz_stock_check_item`;
/*!40000 ALTER TABLE `biz_stock_check_item` DISABLE KEYS */;
INSERT INTO `biz_stock_check_item` (`item_id`, `stock_check_id`, `product_id`, `product_name`, `spec`, `unit`, `system_quantity`, `actual_quantity`, `diff_quantity`, `remark`) VALUES
	(1, 1, 1, 'GCS-p7', '1', '5', 0, 10, 10, NULL),
	(2, 1, 2, '测试1', '1', '5', 9, 9, 0, NULL);
/*!40000 ALTER TABLE `biz_stock_check_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_in 结构
DROP TABLE IF EXISTS `biz_stock_in`;
CREATE TABLE IF NOT EXISTS `biz_stock_in` (
  `stock_in_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '入库单ID',
  `stock_in_no` varchar(30) NOT NULL COMMENT '入库单号',
  `stock_in_type` char(1) NOT NULL DEFAULT '1' COMMENT '入库类型(1采购入库 2退货入库 3其他入库)',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额',
  `stock_in_date` date DEFAULT NULL COMMENT '入库日期',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stock_in_id`),
  UNIQUE KEY `uk_stock_in_no` (`stock_in_no`),
  KEY `idx_stock_in_date` (`stock_in_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='入库单主表';

-- 正在导出表  fuchenpro.biz_stock_in 的数据：~2 rows (大约)
DELETE FROM `biz_stock_in`;
/*!40000 ALTER TABLE `biz_stock_in` DISABLE KEYS */;
INSERT INTO `biz_stock_in` (`stock_in_id`, `stock_in_no`, `stock_in_type`, `total_quantity`, `total_amount`, `stock_in_date`, `operator_id`, `operator_name`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(13, 'RK20260505001', '1', 11, 7058.00, '2026-05-05', 1, 'admin', '1', '11111', 'admin', '2026-05-05 16:50:59', '', '2026-05-05 16:51:22'),
	(14, 'RK20260505002', '1', 10, 6800.00, '2026-05-05', 1, 'admin', '1', '11111', 'admin', '2026-05-05 17:52:53', '', '2026-05-05 18:25:27');
/*!40000 ALTER TABLE `biz_stock_in` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_in_item 结构
DROP TABLE IF EXISTS `biz_stock_in_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_in_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `stock_in_id` bigint(20) NOT NULL COMMENT '入库单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `supplier_id` bigint(20) DEFAULT NULL COMMENT '供货商ID',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供货商名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `original_quantity` int(11) DEFAULT NULL COMMENT '原始数量(换算前)',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '入库数量',
  `purchase_price` decimal(10,2) DEFAULT '0.00' COMMENT '进货单价',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date DEFAULT NULL COMMENT '有效期至',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_in_id` (`stock_in_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='入库单明细表';

-- 正在导出表  fuchenpro.biz_stock_in_item 的数据：~3 rows (大约)
DELETE FROM `biz_stock_in_item`;
/*!40000 ALTER TABLE `biz_stock_in_item` DISABLE KEYS */;
INSERT INTO `biz_stock_in_item` (`item_id`, `stock_in_id`, `product_id`, `product_name`, `supplier_id`, `supplier_name`, `spec`, `unit`, `pack_qty`, `unit_type`, `original_quantity`, `quantity`, `purchase_price`, `amount`, `remark`, `production_date`, `expiry_date`) VALUES
	(12, 13, 2, '测试1', 1, '南京伊美荟', '1', '5', 10, '1', 1, 10, 680.00, 6800.00, NULL, '2026-05-01', '2028-05-06'),
	(13, 13, 1, 'GCS-p7', 1, '南京伊美荟', '1', '5', 10, '2', 1, 1, 258.00, 258.00, NULL, '2026-05-01', '2028-05-01'),
	(14, 14, 2, '测试1', 1, '南京伊美荟', '1', '5', 10, '1', 1, 10, 680.00, 6800.00, NULL, '2025-04-01', '2027-05-01');
/*!40000 ALTER TABLE `biz_stock_in_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_out 结构
DROP TABLE IF EXISTS `biz_stock_out`;
CREATE TABLE IF NOT EXISTS `biz_stock_out` (
  `stock_out_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '出库单ID',
  `stock_out_no` varchar(30) NOT NULL COMMENT '出库单号',
  `stock_out_type` char(1) NOT NULL DEFAULT '1' COMMENT '出库类型(1销售出库 2调拨出库 3其他出库)',
  `out_target_type` varchar(1) NOT NULL DEFAULT '1' COMMENT '出库对象类型（1-企业出库 2-员工领用）',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '出库企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '出库企业名称',
  `contact_employee_id` int(11) DEFAULT NULL COMMENT '对接员工ID',
  `contact_employee_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对接员工姓名',
  `responsible_id` bigint(20) DEFAULT NULL COMMENT '负责员工ID',
  `responsible_name` varchar(50) DEFAULT NULL COMMENT '负责员工姓名',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额',
  `stock_out_date` date DEFAULT NULL COMMENT '出库日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stock_out_id`),
  UNIQUE KEY `uk_stock_out_no` (`stock_out_no`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_responsible_id` (`responsible_id`),
  KEY `idx_stock_out_date` (`stock_out_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出库单主表';

-- 正在导出表  fuchenpro.biz_stock_out 的数据：~2 rows (大约)
DELETE FROM `biz_stock_out`;
/*!40000 ALTER TABLE `biz_stock_out` DISABLE KEYS */;
INSERT INTO `biz_stock_out` (`stock_out_id`, `stock_out_no`, `stock_out_type`, `out_target_type`, `enterprise_id`, `enterprise_name`, `contact_employee_id`, `contact_employee_name`, `responsible_id`, `responsible_name`, `total_quantity`, `total_amount`, `stock_out_date`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(20, 'CK20260505001', '1', '1', 2, '逆龄奢', 100, '测试', NULL, NULL, 11, 7058.00, '2026-05-05', '1', '222', 'admin', '2026-05-05 16:53:52', '', '2026-05-05 16:53:55'),
	(21, 'CK20260505002', '1', '2', 2, '逆龄奢', NULL, NULL, 100, '测试', 1, 680.00, '2026-05-05', '1', '22222', 'admin', '2026-05-05 17:53:50', '', '2026-05-05 18:25:39');
/*!40000 ALTER TABLE `biz_stock_out` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_out_item 结构
DROP TABLE IF EXISTS `biz_stock_out_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_out_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `stock_out_id` bigint(20) NOT NULL COMMENT '出库单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `original_quantity` int(11) DEFAULT NULL COMMENT '??????(?????',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '出库数量',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '出货单价',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_out_id` (`stock_out_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出库单明细表';

-- 正在导出表  fuchenpro.biz_stock_out_item 的数据：~3 rows (大约)
DELETE FROM `biz_stock_out_item`;
/*!40000 ALTER TABLE `biz_stock_out_item` DISABLE KEYS */;
INSERT INTO `biz_stock_out_item` (`item_id`, `stock_out_id`, `product_id`, `product_name`, `spec`, `unit`, `pack_qty`, `unit_type`, `original_quantity`, `quantity`, `sale_price`, `amount`, `remark`) VALUES
	(18, 20, 2, '测试1', '1', '5', 10, '1', 1, 10, 680.00, 6800.00, NULL),
	(19, 20, 1, 'GCS-p7', '1', '5', 10, '2', 1, 1, 258.00, 258.00, NULL),
	(20, 21, 2, '测试1', '1', '5', 10, '2', 1, 1, 680.00, 680.00, NULL);
/*!40000 ALTER TABLE `biz_stock_out_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_store 结构
DROP TABLE IF EXISTS `biz_store`;
CREATE TABLE IF NOT EXISTS `biz_store` (
  `store_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '门店ID',
  `enterprise_id` bigint(20) NOT NULL COMMENT '所属企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '所属企业名称',
  `store_name` varchar(100) NOT NULL COMMENT '门店名称',
  `manager_name` varchar(50) DEFAULT NULL COMMENT '门店负责人',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `business_hours` varchar(100) DEFAULT NULL COMMENT '营业时间',
  `annual_performance` decimal(12,2) DEFAULT '0.00' COMMENT '年业绩',
  `regular_customers` int(11) DEFAULT '0' COMMENT '常来顾客数',
  `creator_name` varchar(50) DEFAULT NULL COMMENT '创建人',
  `server_user_id` bigint(20) DEFAULT NULL COMMENT '服务员工ID',
  `server_user_name` varchar(50) DEFAULT NULL COMMENT '服务员工姓名',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`store_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_store_name` (`store_name`),
  KEY `idx_server_user_id` (`server_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门店管理表';

-- 正在导出表  fuchenpro.biz_store 的数据：~4 rows (大约)
DELETE FROM `biz_store`;
/*!40000 ALTER TABLE `biz_store` DISABLE KEYS */;
INSERT INTO `biz_store` (`store_id`, `enterprise_id`, `enterprise_name`, `store_name`, `manager_name`, `phone`, `wechat`, `address`, `business_hours`, `annual_performance`, `regular_customers`, `creator_name`, `server_user_id`, `server_user_name`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, '馥田诗', '顺义店', '哈哈哈', '15555555555', 'fdfd', '佛山市对方水电费', '09:00-21:00', 0.00, 0, NULL, 1, '若依', '0', NULL, 'admin', '2026-04-30 18:02:15', '', '2026-04-30 18:02:15'),
	(2, 1, '馥田诗', '肇嘉浜', '发顺丰', '13555555555', 'gfggg', '改单费咕嘟咕嘟', '19:01 - 20:01', 455.00, 111, 'admin', 1, '若依', '0', '111111', 'admin', '2026-04-30 19:05:02', '', '2026-04-30 19:05:02'),
	(3, 2, '逆龄奢', '宜川店', '木总', '1555555555', NULL, '辅导费神鼎飞丹砂', NULL, 0.00, 0, NULL, 1, '若依', '0', NULL, 'admin', '2026-05-02 22:30:37', 'admin', '2026-05-16 20:14:48'),
	(5, 4, '企业1', '哈哈', '133', '1333333333', NULL, '133333', NULL, 0.00, 0, NULL, NULL, NULL, '0', '113333', 'admin', '2026-05-27 21:44:49', '', '2026-05-27 21:44:49');
/*!40000 ALTER TABLE `biz_store` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_supplier 结构
DROP TABLE IF EXISTS `biz_supplier`;
CREATE TABLE IF NOT EXISTS `biz_supplier` (
  `supplier_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '供货商ID',
  `supplier_name` varchar(100) NOT NULL COMMENT '供货商名称',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `cooperation_start_date` date DEFAULT NULL COMMENT '合作起始日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`supplier_id`),
  KEY `idx_supplier_name` (`supplier_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='供货商表';

-- 正在导出表  fuchenpro.biz_supplier 的数据：~0 rows (大约)
DELETE FROM `biz_supplier`;
/*!40000 ALTER TABLE `biz_supplier` DISABLE KEYS */;
INSERT INTO `biz_supplier` (`supplier_id`, `supplier_name`, `contact_person`, `contact_phone`, `address`, `cooperation_start_date`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '南京伊美荟', '田总', '15555555555', '南京市', '2026-04-25', '0', NULL, 'admin', '2026-04-29 11:18:41', 'admin', '2026-05-17 19:57:00');
/*!40000 ALTER TABLE `biz_supplier` ENABLE KEYS */;

-- 导出  表 fuchenpro.fin_reimbursement 结构
DROP TABLE IF EXISTS `fin_reimbursement`;
CREATE TABLE IF NOT EXISTS `fin_reimbursement` (
  `reimbursement_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `reimbursement_no` varchar(32) NOT NULL COMMENT '报销单号',
  `applicant_id` int(11) NOT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人姓名',
  `dept_id` int(11) DEFAULT NULL COMMENT '所属部门ID',
  `dept_name` varchar(100) DEFAULT NULL COMMENT '部门名称',
  `apply_date` date DEFAULT NULL COMMENT '申请日期',
  `category` char(1) DEFAULT '4' COMMENT '分类：1行程买票 2销售费用 3行政支出 4其它',
  `income_amount` decimal(12,2) DEFAULT '0.00' COMMENT '收入金额',
  `expense_amount` decimal(12,2) DEFAULT '0.00' COMMENT '支出金额',
  `expense_type` char(1) DEFAULT '1' COMMENT '支出类型：1员工支出 2公司支出',
  `status` char(1) DEFAULT '0' COMMENT '状态：0待审核 1已审核 2已驳回 3已支付',
  `voucher_images` text COMMENT '凭证图片JSON数组',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `audit_by` varchar(50) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审核备注',
  `pay_by` varchar(50) DEFAULT NULL COMMENT '支付人',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(50) DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`reimbursement_id`),
  UNIQUE KEY `uk_reimbursement_no` (`reimbursement_no`),
  KEY `idx_applicant_id` (`applicant_id`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_status` (`status`),
  KEY `idx_apply_date` (`apply_date`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报销单表';

-- 正在导出表  fuchenpro.fin_reimbursement 的数据：~15 rows (大约)
DELETE FROM `fin_reimbursement`;
/*!40000 ALTER TABLE `fin_reimbursement` DISABLE KEYS */;
INSERT INTO `fin_reimbursement` (`reimbursement_id`, `reimbursement_no`, `applicant_id`, `applicant_name`, `dept_id`, `dept_name`, `apply_date`, `category`, `income_amount`, `expense_amount`, `expense_type`, `status`, `voucher_images`, `remark`, `audit_by`, `audit_time`, `audit_remark`, `pay_by`, `pay_time`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'BX202605180001', 1, '', 103, '', NULL, '1', 0.00, 0.00, '1', '0', NULL, '大叔大婶', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 19:58:07', NULL, NULL),
	(2, 'BX202605180002', 1, '', 103, '', NULL, '1', 0.00, 0.00, '1', '0', NULL, '大叔大婶', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 22:40:01', NULL, NULL),
	(3, 'BX202605180003', 1, '', 103, '', '2026-05-18', '1', 0.00, 598.00, '1', '0', '["blob:http://192.168.2.74:8088/8525e9f0-ea3b-4255-b5af-29c56346fadb"]', '222', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 23:00:38', '', '2026-05-19 13:40:45'),
	(4, 'BX202605180004', 1, '', 103, '', '2026-05-18', '2', 0.00, 980.00, '1', '0', '[]', '电风扇', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 23:42:53', '', '2026-05-19 14:23:15'),
	(5, 'BX202605190001', 1, '', 103, '', '2026-05-18', '4', 66.00, 666.00, '2', '3', '["blob:http://192.168.2.74:8088/7d2c73c1-d312-40c5-9beb-70f17f09119a"]', '6666', '', '2026-05-19 12:15:59', '2120', '', '2026-05-19 12:16:06', '', '2026-05-19 00:00:41', NULL, '2026-05-19 12:16:06'),
	(6, 'BX202605190002', 1, '', 103, '', '2026-05-19', '4', 22.00, 222.00, '1', '0', '["blob:http://192.168.2.74:8088/c620eb48-98ba-405b-8f9a-7767e52712b5"]', '22', NULL, NULL, NULL, NULL, NULL, '', '2026-05-19 12:57:13', '', '2026-05-19 13:40:58'),
	(7, 'BX202605190003', 1, '', 103, '', '2026-05-19', '4', 99.00, 999.00, '1', '0', '[]', '25', NULL, NULL, NULL, NULL, NULL, '', '2026-05-19 14:23:42', NULL, NULL),
	(11, 'BX202605190007', 1, '', 103, '', '2026-05-19', '4', 33.00, 333.00, '1', '0', '["blob:http://192.168.2.74:8088/4c5a4332-2bd5-40c2-98f6-bf47107047fa"]', '333', NULL, NULL, NULL, NULL, NULL, '', '2026-05-19 15:26:08', NULL, NULL),
	(12, 'BX202605190008', 1, '若依', 103, '研发部门', NULL, '1', 0.00, 0.00, '1', '0', NULL, '33', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-19 17:21:05', NULL, NULL),
	(13, 'BX202605190009', 1, '若依', 103, '研发部门', NULL, '2', 0.00, 0.00, '1', '0', NULL, '999', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-19 18:00:08', NULL, NULL),
	(14, 'BX202605200001', 1, '若依', 103, '研发部门', NULL, '1', 0.00, 0.00, '1', '0', NULL, '999', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-20 09:14:00', NULL, NULL),
	(15, 'BX202605200002', 1, '若依', 103, '研发部门', '2026-05-20', '3', 0.00, 0.00, '1', '0', '["blob:http://192.168.2.74:8088/fb0f399f-2e6e-40b0-8dc1-01ab65d12d58"]', '888', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-20 09:28:23', '若依', '2026-05-20 13:13:20'),
	(16, 'BX202605200003', 1, '若依', 103, '研发部门', '2026-05-20', '3', 88.00, 888.00, '1', '0', '["https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260520/10b7e3bed417b223b36c9ffe69e5c851.jpg"]', '515153', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-20 12:23:08', '若依', '2026-05-20 15:37:26');
/*!40000 ALTER TABLE `fin_reimbursement` ENABLE KEYS */;

-- 导出  表 fuchenpro.fin_reimbursement_item 结构
DROP TABLE IF EXISTS `fin_reimbursement_item`;
CREATE TABLE IF NOT EXISTS `fin_reimbursement_item` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `reimbursement_id` int(11) NOT NULL COMMENT '报销单ID',
  `item_name` varchar(100) DEFAULT NULL COMMENT '项目名称',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `description` varchar(200) DEFAULT NULL COMMENT '说明',
  PRIMARY KEY (`item_id`),
  KEY `idx_reimbursement_id` (`reimbursement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报销明细表';

-- 正在导出表  fuchenpro.fin_reimbursement_item 的数据：~0 rows (大约)
DELETE FROM `fin_reimbursement_item`;
/*!40000 ALTER TABLE `fin_reimbursement_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `fin_reimbursement_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.gen_table 结构
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE IF NOT EXISTS `gen_table` (
  `table_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int(1) DEFAULT '1' COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='代码生成业务表';

-- 正在导出表  fuchenpro.gen_table 的数据：~0 rows (大约)
DELETE FROM `gen_table`;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;

-- 导出  表 fuchenpro.gen_table_column 结构
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE IF NOT EXISTS `gen_table_column` (
  `column_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint(20) DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) DEFAULT '' COMMENT '字典类型',
  `sort` int(11) DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='代码生成业务表字段';

-- 正在导出表  fuchenpro.gen_table_column 的数据：~0 rows (大约)
DELETE FROM `gen_table_column`;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;

-- 导出  表 fuchenpro.hr_salary_tier 结构
DROP TABLE IF EXISTS `hr_salary_tier`;
CREATE TABLE IF NOT EXISTS `hr_salary_tier` (
  `tier_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '阶梯ID',
  `salary_id` bigint(20) NOT NULL COMMENT '薪资配置ID',
  `tier_level` int(11) DEFAULT '1' COMMENT '阶梯级别',
  `min_amount` decimal(12,2) DEFAULT '0.00' COMMENT '最小金额',
  `max_amount` decimal(12,2) DEFAULT NULL COMMENT '最大金额（NULL表示无上限）',
  `commission_rate` decimal(5,4) DEFAULT '0.0000' COMMENT '提成比例',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`tier_id`),
  KEY `idx_salary_id` (`salary_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='薪资阶梯配置表';

-- 正在导出表  fuchenpro.hr_salary_tier 的数据：~0 rows (大约)
DELETE FROM `hr_salary_tier`;
/*!40000 ALTER TABLE `hr_salary_tier` DISABLE KEYS */;
/*!40000 ALTER TABLE `hr_salary_tier` ENABLE KEYS */;

-- 导出  表 fuchenpro.hr_salary_type 结构
DROP TABLE IF EXISTS `hr_salary_type`;
CREATE TABLE IF NOT EXISTS `hr_salary_type` (
  `type_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '类型ID',
  `type_code` varchar(50) NOT NULL COMMENT '类型编码',
  `type_name` varchar(100) NOT NULL COMMENT '类型名称',
  `calc_formula` varchar(500) DEFAULT '' COMMENT '计算公式说明',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uk_type_code` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8 COMMENT='薪资架构类型表';

-- 正在导出表  fuchenpro.hr_salary_type 的数据：~6 rows (大约)
DELETE FROM `hr_salary_type`;
/*!40000 ALTER TABLE `hr_salary_type` DISABLE KEYS */;
INSERT INTO `hr_salary_type` (`type_id`, `type_code`, `type_name`, `calc_formula`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(100, 'BASE_SALARY', '底薪', '固定金额', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '每月固定发放'),
	(101, 'SALES_COMMISSION', '销售业绩提成', '销售业绩 × 提成比例', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '按销售业绩计算'),
	(102, 'PAYMENT_COMMISSION', '回款业绩提成', '回款金额 × 提成比例', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '按回款金额计算'),
	(103, 'PROFIT_COMMISSION', '利润提成', '(回款金额 - 成本) × 提成比例', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '按利润计算'),
	(104, 'TIERED_SALES', '阶梯销售提成', '按销售业绩阶梯计算提成', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '阶梯式销售提成'),
	(105, 'TIERED_PAYMENT', '阶梯回款提成', '按回款业绩阶梯计算提成', '0', 'admin', '2026-04-28 00:31:07', '', NULL, '阶梯式回款提成');
/*!40000 ALTER TABLE `hr_salary_type` ENABLE KEYS */;

-- 导出  表 fuchenpro.hr_user_salary 结构
DROP TABLE IF EXISTS `hr_user_salary`;
CREATE TABLE IF NOT EXISTS `hr_user_salary` (
  `salary_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '薪资配置ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `type_id` bigint(20) NOT NULL COMMENT '薪资类型ID',
  `base_amount` decimal(12,2) DEFAULT '0.00' COMMENT '基础金额/底薪',
  `commission_rate` decimal(5,4) DEFAULT '0.0000' COMMENT '提成比例（如0.05表示5%）',
  `tier_config` text COMMENT '阶梯配置（JSON格式）',
  `effective_date` date DEFAULT NULL COMMENT '生效日期',
  `expire_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`salary_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type_id` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='用户薪资配置表';

-- 正在导出表  fuchenpro.hr_user_salary 的数据：~0 rows (大约)
DELETE FROM `hr_user_salary`;
/*!40000 ALTER TABLE `hr_user_salary` DISABLE KEYS */;
INSERT INTO `hr_user_salary` (`salary_id`, `user_id`, `type_id`, `base_amount`, `commission_rate`, `tier_config`, `effective_date`, `expire_date`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(4, 2, 100, 5000.00, 0.0000, NULL, '2026-04-28', '2027-04-27', '0', 'admin', '2026-04-28 12:34:41', '', NULL, '');
/*!40000 ALTER TABLE `hr_user_salary` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_blob_triggers 结构
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_blob_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Blob类型的触发器表';

-- 正在导出表  fuchenpro.qrtz_blob_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_blob_triggers`;
/*!40000 ALTER TABLE `qrtz_blob_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_blob_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_calendars 结构
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE IF NOT EXISTS `qrtz_calendars` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`,`calendar_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日历信息表';

-- 正在导出表  fuchenpro.qrtz_calendars 的数据：~0 rows (大约)
DELETE FROM `qrtz_calendars`;
/*!40000 ALTER TABLE `qrtz_calendars` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_calendars` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_cron_triggers 结构
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_cron_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cron类型的触发器表';

-- 正在导出表  fuchenpro.qrtz_cron_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_cron_triggers`;
/*!40000 ALTER TABLE `qrtz_cron_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_cron_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_fired_triggers 结构
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_fired_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint(13) NOT NULL COMMENT '触发的时间',
  `sched_time` bigint(13) NOT NULL COMMENT '定时器制定的时间',
  `priority` int(11) NOT NULL COMMENT '优先级',
  `state` varchar(16) NOT NULL COMMENT '状态',
  `job_name` varchar(200) DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`,`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='已触发的触发器表';

-- 正在导出表  fuchenpro.qrtz_fired_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_fired_triggers`;
/*!40000 ALTER TABLE `qrtz_fired_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_fired_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_job_details 结构
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE IF NOT EXISTS `qrtz_job_details` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) NOT NULL COMMENT '任务组名',
  `description` varchar(250) DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`,`job_name`,`job_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务详细信息表';

-- 正在导出表  fuchenpro.qrtz_job_details 的数据：~0 rows (大约)
DELETE FROM `qrtz_job_details`;
/*!40000 ALTER TABLE `qrtz_job_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_job_details` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_locks 结构
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE IF NOT EXISTS `qrtz_locks` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`,`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储的悲观锁信息表';

-- 正在导出表  fuchenpro.qrtz_locks 的数据：~0 rows (大约)
DELETE FROM `qrtz_locks`;
/*!40000 ALTER TABLE `qrtz_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_locks` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_paused_trigger_grps 结构
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE IF NOT EXISTS `qrtz_paused_trigger_grps` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`,`trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='暂停的触发器表';

-- 正在导出表  fuchenpro.qrtz_paused_trigger_grps 的数据：~0 rows (大约)
DELETE FROM `qrtz_paused_trigger_grps`;
/*!40000 ALTER TABLE `qrtz_paused_trigger_grps` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_paused_trigger_grps` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_scheduler_state 结构
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE IF NOT EXISTS `qrtz_scheduler_state` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint(13) NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint(13) NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`,`instance_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='调度器状态表';

-- 正在导出表  fuchenpro.qrtz_scheduler_state 的数据：~0 rows (大约)
DELETE FROM `qrtz_scheduler_state`;
/*!40000 ALTER TABLE `qrtz_scheduler_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_scheduler_state` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_simple_triggers 结构
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_simple_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint(7) NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint(12) NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint(10) NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='简单触发器的信息表';

-- 正在导出表  fuchenpro.qrtz_simple_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_simple_triggers`;
/*!40000 ALTER TABLE `qrtz_simple_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_simple_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_simprop_triggers 结构
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_simprop_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int(11) DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int(11) DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint(20) DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint(20) DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='同步机制的行锁表';

-- 正在导出表  fuchenpro.qrtz_simprop_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_simprop_triggers`;
/*!40000 ALTER TABLE `qrtz_simprop_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_simprop_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.qrtz_triggers 结构
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE IF NOT EXISTS `qrtz_triggers` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint(13) DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint(13) DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int(11) DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) NOT NULL COMMENT '触发器的类型',
  `start_time` bigint(13) NOT NULL COMMENT '开始时间',
  `end_time` bigint(13) DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint(2) DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
  KEY `sched_name` (`sched_name`,`job_name`,`job_group`),
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='触发器详细信息表';

-- 正在导出表  fuchenpro.qrtz_triggers 的数据：~0 rows (大约)
DELETE FROM `qrtz_triggers`;
/*!40000 ALTER TABLE `qrtz_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrtz_triggers` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_app_menu 结构
DROP TABLE IF EXISTS `sys_app_menu`;
CREATE TABLE IF NOT EXISTS `sys_app_menu` (
  `app_menu_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'App菜单ID',
  `menu_id` bigint(20) NOT NULL COMMENT '关联sys_menu的menu_id',
  `app_path` varchar(200) DEFAULT '' COMMENT 'App页面路径',
  `app_icon` varchar(100) DEFAULT '' COMMENT 'App图标名称(uView图标)',
  `bg_color` varchar(20) DEFAULT '#3D6DF7' COMMENT '图标背景色',
  `icon_color` varchar(20) DEFAULT '#fff' COMMENT '图标颜色',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `visible` tinyint(4) DEFAULT '1' COMMENT '是否显示(1显示 0隐藏)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`app_menu_id`),
  UNIQUE KEY `uk_menu_id` (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='App菜单扩展配置表';

-- 正在导出表  fuchenpro.sys_app_menu 的数据：~35 rows (大约)
DELETE FROM `sys_app_menu`;
/*!40000 ALTER TABLE `sys_app_menu` DISABLE KEYS */;
INSERT INTO `sys_app_menu` (`app_menu_id`, `menu_id`, `app_path`, `app_icon`, `bg_color`, `icon_color`, `sort_order`, `visible`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 2000, '', '', '#FF6B35', '#fff', 1, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(2, 2012, '', '', '#F59E0B', '#fff', 2, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(3, 2021, '', '', '#3D6DF7', '#fff', 3, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(4, 3000, '', '', '#8B5CF6', '#fff', 4, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(5, 3023, '', '', '#52c41a', '#fff', 5, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(6, 1, '', '', '#3D6DF7', '#fff', 6, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(7, 2001, '/pages/business/enterprise/index', 'home-fill', '#FF6B35', '#fff', 1, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(8, 2059, '/pages/business/store/index', 'home', '#FF6B35', '#fff', 2, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(9, 2007, '/pages/business/schedule/index', 'calendar', '#FF6B35', '#fff', 3, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(10, 2065, '/pages/business/sales/index', 'edit-pen', '#FF6B35', '#fff', 4, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(11, 2072, '/pages/business/order/index', 'list', '#FF6B35', '#fff', 5, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(12, 2076, '/pages/business/plan/index', 'file-text', '#FF6B35', '#fff', 6, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(13, 2013, '/pages/attendance/record', 'file-text', '#F59E0B', '#fff', 1, 1, 'admin', '2026-05-30 15:33:05', '', '2026-05-30 15:33:05'),
	(14, 2014, '', 'setting', '#F59E0B', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(15, 2080, '', 'grid', '#F59E0B', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(16, 2022, '/pages/wms/supplier/index', 'account', '#3D6DF7', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(17, 2028, '', 'list', '#3D6DF7', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(18, 2034, '', 'arrow-down', '#3D6DF7', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(19, 2041, '', 'arrow-up', '#3D6DF7', '#fff', 4, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(20, 2048, '', 'search', '#3D6DF7', '#fff', 5, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(21, 2050, '', 'checkmark-circle', '#3D6DF7', '#fff', 6, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(22, 2088, '/pages/wms/shipment/index', 'car', '#3D6DF7', '#fff', 7, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(23, 2057, '', 'list-dot', '#3D6DF7', '#fff', 8, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(24, 3001, '/pages/business/plan/index', 'checkmark', '#8B5CF6', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(25, 3002, '', 'edit-pen', '#8B5CF6', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(26, 3003, '', 'file-text', '#8B5CF6', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(27, 100, '', 'account', '#52c41a', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(28, 3024, '/pages/admin/feedback/index', 'edit-pen', '#52c41a', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(29, 103, '', 'home', '#52c41a', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(30, 104, '', 'bookmark', '#52c41a', '#fff', 4, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(31, 107, '', 'chat', '#52c41a', '#fff', 5, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(32, 101, '', 'man-add', '#3D6DF7', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(33, 102, '', 'list', '#3D6DF7', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(34, 105, '', 'file-text', '#3D6DF7', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(35, 106, '', 'setting', '#3D6DF7', '#fff', 4, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06');
/*!40000 ALTER TABLE `sys_app_menu` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_banner 结构
DROP TABLE IF EXISTS `sys_banner`;
CREATE TABLE IF NOT EXISTS `sys_banner` (
  `banner_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) DEFAULT '' COMMENT '标题',
  `image` varchar(500) NOT NULL COMMENT '图片地址',
  `link_url` varchar(500) DEFAULT '' COMMENT '跳转链接',
  `sort_order` int(11) NOT NULL DEFAULT '0' COMMENT '排序号(越小越前)',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='轮播图表';

-- 正在导出表  fuchenpro.sys_banner 的数据：~3 rows (大约)
DELETE FROM `sys_banner`;
/*!40000 ALTER TABLE `sys_banner` DISABLE KEYS */;
INSERT INTO `sys_banner` (`banner_id`, `title`, `image`, `link_url`, `sort_order`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '欢迎使用', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260525/2013839df589d2c49ea8077114163d65.png', '', 1, '0', '默认轮播图1', 'admin', '2026-05-25 12:12:44', 'admin', '2026-05-25 17:19:37'),
	(2, '高效协作', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260525/dc2a7b15f1d8a42546db4ff9df042789.png', '', 2, '0', '默认轮播图2', 'admin', '2026-05-25 12:12:44', 'admin', '2026-05-25 12:40:25'),
	(3, '智能管理', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260525/40723ad7d6817b01ad81d7fb36e3b196.png', '', 3, '0', '默认轮播图3', 'admin', '2026-05-25 12:12:44', 'admin', '2026-05-25 12:40:43');
/*!40000 ALTER TABLE `sys_banner` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_config 结构
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE IF NOT EXISTS `sys_config` (
  `config_id` int(5) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COMMENT='参数配置表';

-- 正在导出表  fuchenpro.sys_config 的数据：~9 rows (大约)
DELETE FROM `sys_config`;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` (`config_id`, `config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),
	(2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '初始化密码 123456'),
	(3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '深色主题theme-dark，浅色主题theme-light'),
	(4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '是否开启验证码功能（true开启，false关闭）'),
	(5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '是否开启注册用户功能（true开启，false关闭）'),
	(6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）'),
	(7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框'),
	(8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框'),
	(9, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', 'admin', '2026-04-25 01:10:54', '', NULL, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_dept 结构
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE IF NOT EXISTS `sys_dept` (
  `dept_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint(20) DEFAULT '0' COMMENT '父部门id',
  `ancestors` varchar(50) DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) DEFAULT '' COMMENT '部门名称',
  `order_num` int(4) DEFAULT '0' COMMENT '显示顺序',
  `leader` varchar(20) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `status` char(1) DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8 COMMENT='部门表';

-- 正在导出表  fuchenpro.sys_dept 的数据：~10 rows (大约)
DELETE FROM `sys_dept`;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` (`dept_id`, `parent_id`, `ancestors`, `dept_name`, `order_num`, `leader`, `phone`, `email`, `status`, `del_flag`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(100, 0, '0', '馥辰国际', 0, '汪志', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', 'admin', '2026-04-25 21:47:28'),
	(101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', '', NULL),
	(102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', '', NULL),
	(103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', '', NULL),
	(104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL),
	(105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL),
	(106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL),
	(107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL),
	(108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL),
	(109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_dict_data 结构
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE IF NOT EXISTS `sys_dict_data` (
  `dict_code` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int(4) DEFAULT '0' COMMENT '字典排序',
  `dict_label` varchar(100) DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8 COMMENT='字典数据表';

-- 正在导出表  fuchenpro.sys_dict_data 的数据：~119 rows (大约)
DELETE FROM `sys_dict_data`;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '性别男'),
	(2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '性别女'),
	(3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '性别未知'),
	(4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '显示菜单'),
	(5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '隐藏菜单'),
	(6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '正常状态'),
	(7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '停用状态'),
	(8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '正常状态'),
	(9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '停用状态'),
	(10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '默认分组'),
	(11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '系统分组'),
	(12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '系统默认是'),
	(13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '系统默认否'),
	(14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '通知'),
	(15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '公告'),
	(16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '正常状态'),
	(17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '关闭状态'),
	(18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '其他操作'),
	(19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '新增操作'),
	(20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '修改操作'),
	(21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '删除操作'),
	(22, 4, '其它', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-04-25 01:10:53', 'admin', '2026-04-27 23:37:05', '授权操作'),
	(23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '导出操作'),
	(24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '导入操作'),
	(25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '强退操作'),
	(26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '生成操作'),
	(27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '清空操作'),
	(28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '正常状态'),
	(29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-04-25 01:10:53', '', NULL, '停用状态'),
	(100, 1, '专业店', '1', 'biz_enterprise_type', '', 'primary', 'N', '0', 'admin', '2026-04-27 18:23:54', 'admin', '2026-05-06 16:51:58', NULL),
	(101, 2, '综合店', '2', 'biz_enterprise_type', '', 'success', 'N', '0', 'admin', '2026-04-27 18:23:54', 'admin', '2026-04-27 23:36:29', NULL),
	(102, 3, '前庭后院', '3', 'biz_enterprise_type', '', 'danger', 'N', '0', 'admin', '2026-04-27 18:23:54', 'admin', '2026-05-06 16:54:33', NULL),
	(103, 1, 'A级', '1', 'biz_enterprise_level', '', 'danger', 'N', '0', 'admin', '2026-04-27 18:23:54', '', NULL, NULL),
	(104, 2, 'B级', '2', 'biz_enterprise_level', '', 'warning', 'N', '0', 'admin', '2026-04-27 18:23:54', '', NULL, NULL),
	(105, 3, 'C级', '3', 'biz_enterprise_level', '', 'info', 'Y', '0', 'admin', '2026-04-27 18:23:54', '', NULL, NULL),
	(106, 1, '爆卡', '1', 'biz_schedule_purpose', '', 'danger', 'N', '0', 'admin', '2026-04-28 15:36:55', '', NULL, NULL),
	(107, 2, '销售', '2', 'biz_schedule_purpose', '', 'success', 'N', '0', 'admin', '2026-04-28 15:36:55', 'admin', '2026-05-02 22:48:47', NULL),
	(108, 3, '售后', '3', 'biz_schedule_purpose', '', 'warning', 'N', '0', 'admin', '2026-04-28 15:36:55', 'admin', '2026-05-02 22:48:51', NULL),
	(109, 4, '业务', '4', 'biz_schedule_purpose', '', 'primary', 'N', '0', 'admin', '2026-04-28 15:36:55', 'admin', '2026-05-02 22:49:02', NULL),
	(111, 2, '服务中', '2', 'biz_schedule_status', '', 'warning', 'N', '0', 'admin', '2026-04-28 16:25:35', '', NULL, NULL),
	(112, 3, '已完成', '3', 'biz_schedule_status', '', 'success', 'N', '0', 'admin', '2026-04-28 16:25:35', '', NULL, NULL),
	(113, 4, '已取消', '4', 'biz_schedule_status', '', 'danger', 'N', '0', 'admin', '2026-04-28 16:25:35', '', NULL, NULL),
	(114, 1, '已预约', '1', 'biz_schedule_status', '', 'primary', 'Y', '0', 'admin', '2026-04-28 17:36:58', '', NULL, NULL),
	(134, 1, '正常', '0', 'biz_attendance_status', '', 'success', 'N', '0', 'admin', '2026-04-29 07:46:25', '', NULL, NULL),
	(135, 2, '迟到', '1', 'biz_attendance_status', '', 'warning', 'N', '0', 'admin', '2026-04-29 07:46:25', '', NULL, NULL),
	(136, 3, '早退', '2', 'biz_attendance_status', '', 'warning', 'N', '0', 'admin', '2026-04-29 07:46:25', '', NULL, NULL),
	(137, 4, '迟到+早退', '3', 'biz_attendance_status', '', 'danger', 'N', '0', 'admin', '2026-04-29 07:46:25', '', NULL, NULL),
	(138, 5, '缺勤', '4', 'biz_attendance_status', '', 'danger', 'N', '0', 'admin', '2026-04-29 07:46:25', '', NULL, NULL),
	(139, 1, '院装-面部', '1', 'biz_product_category', '', 'primary', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(140, 2, '院装-身体', '2', 'biz_product_category', '', 'success', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(141, 3, '仪器-面部', '3', 'biz_product_category', '', 'warning', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(142, 4, '仪器-身体', '4', 'biz_product_category', '', 'danger', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(143, 5, '家居-面部', '5', 'biz_product_category', '', 'info', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(144, 6, '家居-身体', '6', 'biz_product_category', '', 'default', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(145, 1, '采购入库', '1', 'biz_stock_in_type', '', 'primary', 'Y', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(146, 2, '退货入库', '2', 'biz_stock_in_type', '', 'warning', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(147, 3, '其他入库', '3', 'biz_stock_in_type', '', 'info', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(148, 1, '销售出库', '1', 'biz_stock_out_type', '', 'primary', 'Y', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(149, 2, '调拨出库', '2', 'biz_stock_out_type', '', 'warning', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(150, 3, '其他出库', '3', 'biz_stock_out_type', '', 'info', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(151, 1, '待确认', '0', 'biz_doc_status', '', 'warning', 'Y', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(152, 2, '已确认', '1', 'biz_doc_status', '', 'success', 'N', '0', 'admin', '2026-04-29 07:51:27', '', NULL, NULL),
	(153, 1, '箱', '1', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(154, 2, '件', '2', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(155, 3, '套', '3', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(156, 4, '罐', '4', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(157, 5, '盒', '5', 'biz_product_unit', '', '', 'Y', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(158, 6, '袋', '6', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(159, 7, '包', '7', 'biz_product_unit', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(160, 1, '支', '1', 'biz_product_spec', '', '', 'Y', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(161, 2, '瓶', '2', 'biz_product_spec', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(162, 3, '件', '3', 'biz_product_spec', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(163, 4, '套', '4', 'biz_product_spec', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(164, 5, '片', '5', 'biz_product_spec', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(165, 6, '个', '6', 'biz_product_spec', '', '', 'N', '0', 'admin', '2026-04-29 14:08:25', '', NULL, NULL),
	(166, 1, 'VIP', 'vip', 'biz_customer_tag', NULL, NULL, 'N', '0', 'admin', '2026-04-30 23:50:25', '', NULL, NULL),
	(167, 2, '普通', 'normal', 'biz_customer_tag', NULL, NULL, 'N', '0', 'admin', '2026-04-30 23:50:25', '', NULL, NULL),
	(168, 3, '重点客户', 'important', 'biz_customer_tag', NULL, NULL, 'N', '0', 'admin', '2026-04-30 23:50:25', '', NULL, NULL),
	(169, 4, '新客户', 'new', 'biz_customer_tag', NULL, NULL, 'N', '0', 'admin', '2026-04-30 23:50:25', '', NULL, NULL),
	(170, 5, '待跟进', 'follow', 'biz_customer_tag', NULL, NULL, 'N', '0', 'admin', '2026-04-30 23:50:25', '', NULL, NULL),
	(181, 1, '未成交', '0', 'biz_package_status', NULL, NULL, 'N', '0', 'admin', '2026-05-03 08:56:46', '', NULL, NULL),
	(182, 2, '已成交', '1', 'biz_package_status', NULL, NULL, 'N', '0', 'admin', '2026-05-03 08:56:46', '', NULL, NULL),
	(183, 3, '已用完', '2', 'biz_package_status', NULL, NULL, 'N', '0', 'admin', '2026-05-03 08:56:46', '', NULL, NULL),
	(184, 4, '足浴养生', '4', 'biz_enterprise_type', NULL, 'success', 'N', '0', 'admin', '2026-05-06 16:53:09', 'admin', '2026-05-06 16:53:22', NULL),
	(185, 5, '产后修复', '5', 'biz_enterprise_type', NULL, 'danger', 'N', '0', 'admin', '2026-05-06 16:54:14', 'admin', '2026-05-06 16:54:24', NULL),
	(186, 1, '铺垫', 'preparation', 'biz_archive_type', NULL, NULL, 'N', '0', 'admin', '2026-05-08 15:43:54', '', NULL, NULL),
	(187, 2, '开方案', 'plan', 'biz_archive_type', NULL, NULL, 'N', '0', 'admin', '2026-05-08 15:43:54', '', NULL, NULL),
	(188, 3, '销售', 'sales', 'biz_archive_type', NULL, NULL, 'N', '0', 'admin', '2026-05-08 15:43:54', '', NULL, NULL),
	(189, 4, '售后', 'after_sales', 'biz_archive_type', NULL, NULL, 'N', '0', 'admin', '2026-05-08 15:43:54', '', NULL, NULL),
	(190, 5, '回访', 'follow_up', 'biz_archive_type', NULL, NULL, 'N', '0', 'admin', '2026-05-08 15:43:54', '', NULL, NULL),
	(191, 1, '员工支出', '1', 'fin_reimbursement_expense_type', '', 'primary', 'Y', '0', 'admin', '2026-05-18 18:01:58', '', NULL, '个人先垫付，公司后报销'),
	(192, 2, '公司支出', '2', 'fin_reimbursement_expense_type', '', 'success', 'N', '0', 'admin', '2026-05-18 18:01:58', '', NULL, '公司直接支付'),
	(193, 0, '待审核', '0', 'fin_reimbursement_status', '', 'warning', 'Y', '0', 'admin', '2026-05-18 18:01:58', '', NULL, NULL),
	(194, 1, '已审核', '1', 'fin_reimbursement_status', '', 'success', 'N', '0', 'admin', '2026-05-18 18:01:58', '', NULL, NULL),
	(195, 2, '已驳回', '2', 'fin_reimbursement_status', '', 'danger', 'N', '0', 'admin', '2026-05-18 18:01:58', '', NULL, NULL),
	(196, 3, '已支付', '3', 'fin_reimbursement_status', '', 'info', 'N', '0', 'admin', '2026-05-18 18:01:58', '', NULL, NULL),
	(197, 1, '行程买票', '1', 'fin_reimbursement_category', '', 'primary', 'N', '0', 'admin', '2026-05-18 18:03:48', '', NULL, NULL),
	(198, 2, '销售费用', '2', 'fin_reimbursement_category', '', 'success', 'N', '0', 'admin', '2026-05-18 18:03:48', '', NULL, NULL),
	(199, 3, '行政支出', '3', 'fin_reimbursement_category', '', 'warning', 'N', '0', 'admin', '2026-05-18 18:03:48', '', NULL, NULL),
	(200, 4, '其它', '4', 'fin_reimbursement_category', '', 'info', 'Y', '0', 'admin', '2026-05-18 18:03:48', '', NULL, NULL),
	(207, 1, '开单', '0', 'biz_source_type', '', 'primary', 'Y', '0', 'admin', '2026-05-21 23:28:34', '', NULL, '销售开单'),
	(208, 2, '操作', '1', 'biz_source_type', '', 'success', 'N', '0', 'admin', '2026-05-21 23:28:34', '', NULL, '项目操作'),
	(209, 3, '还款', '2', 'biz_source_type', '', 'warning', 'N', '0', 'admin', '2026-05-21 23:28:34', '', NULL, '客户还款'),
	(210, 4, '手动', '3', 'biz_source_type', '', 'info', 'N', '0', 'admin', '2026-05-21 23:28:34', '', NULL, '手动建档'),
	(211, 1, '待确认', '0', 'biz_order_status', NULL, NULL, 'N', '0', 'admin', '2026-05-22 14:22:22', '', NULL, NULL),
	(212, 2, '企业已审', '1', 'biz_order_status', NULL, NULL, 'N', '0', 'admin', '2026-05-22 14:22:22', '', NULL, NULL),
	(213, 3, '财务已审', '2', 'biz_order_status', NULL, NULL, 'N', '0', 'admin', '2026-05-22 14:22:22', '', NULL, NULL),
	(214, 5, '已取消', '4', 'biz_order_status', NULL, NULL, 'N', '0', 'admin', '2026-05-22 14:22:22', '', NULL, NULL),
	(215, 1, '现金', 'cash', 'biz_payment_method', '', 'primary', 'Y', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '现金支付'),
	(216, 2, '划卡', 'card', 'biz_payment_method', '', 'success', 'N', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '刷卡支付'),
	(217, 3, '置换', 'exchange', 'biz_payment_method', '', 'warning', 'N', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '置换支付'),
	(218, 4, '赠送', 'gift', 'biz_payment_method', '', 'danger', 'N', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '赠送（成交0实付0）'),
	(219, 1, '工作问题', '0', 'biz_feedback_type', '', 'danger', 'Y', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(220, 2, '优化建议', '1', 'biz_feedback_type', '', 'warning', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(221, 3, '其他', '2', 'biz_feedback_type', '', 'info', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(222, 1, '待处理', '0', 'biz_feedback_status', '', 'info', 'Y', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(223, 2, '处理中', '1', 'biz_feedback_status', '', 'warning', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(224, 3, '已处理', '2', 'biz_feedback_status', '', 'success', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(225, 4, '已关闭', '3', 'biz_feedback_status', '', 'info', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL);
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_dict_type 结构
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE IF NOT EXISTS `sys_dict_type` (
  `dict_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8 COMMENT='字典类型表';

-- 正在导出表  fuchenpro.sys_dict_type 的数据：~32 rows (大约)
DELETE FROM `sys_dict_type`;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` (`dict_id`, `dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-04-25 01:10:51', '', NULL, '用户性别列表'),
	(2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-04-25 01:10:51', '', NULL, '菜单状态列表'),
	(3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '系统开关列表'),
	(4, '任务状态', 'sys_job_status', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '任务状态列表'),
	(5, '任务分组', 'sys_job_group', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '任务分组列表'),
	(6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '系统是否列表'),
	(7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '通知类型列表'),
	(8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '通知状态列表'),
	(9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '操作类型列表'),
	(10, '系统状态', 'sys_common_status', '0', 'admin', '2026-04-25 01:10:52', '', NULL, '登录状态列表'),
	(100, '企业类型', 'biz_enterprise_type', '0', 'admin', '2026-04-27 18:23:54', '', NULL, '企业类型列表'),
	(101, '企业级别', 'biz_enterprise_level', '0', 'admin', '2026-04-27 18:23:54', '', NULL, '企业级别列表'),
	(102, '下店目的', 'biz_schedule_purpose', '0', 'admin', '2026-04-28 15:36:55', '', NULL, '下店目的列表'),
	(103, '行程状态', 'biz_schedule_status', '0', 'admin', '2026-04-28 16:25:34', '', NULL, '行程状态列表'),
	(110, '考勤状态', 'biz_attendance_status', '0', 'admin', '2026-04-29 07:46:25', '', NULL, '考勤状态列表'),
	(111, '货品类别', 'biz_product_category', '0', 'admin', '2026-04-29 07:51:27', '', NULL, '货品类别列表'),
	(112, '入库类型', 'biz_stock_in_type', '0', 'admin', '2026-04-29 07:51:27', '', NULL, '入库类型列表'),
	(113, '出库类型', 'biz_stock_out_type', '0', 'admin', '2026-04-29 07:51:27', '', NULL, '出库类型列表'),
	(114, '单据确认状态', 'biz_doc_status', '0', 'admin', '2026-04-29 07:51:27', '', NULL, '单据确认状态列表'),
	(115, '货品规格', 'biz_product_spec', '0', 'admin', '2026-04-29 12:41:01', '', NULL, '货品规格列表'),
	(117, '货品单位', 'biz_product_unit', '0', 'admin', '2026-04-29 14:08:25', '', NULL, '货品单位列表'),
	(119, '客户标签', 'biz_customer_tag', '0', 'admin', '2026-04-30 23:50:25', '', NULL, '客户标签列表'),
	(120, '订单状态', 'biz_order_status', '0', 'admin', '2026-04-30 23:50:25', '', NULL, '销售订单状态'),
	(121, '套餐状态', 'biz_package_status', '0', 'admin', '2026-04-30 23:50:25', '', NULL, '客户套餐状态'),
	(122, '档案类型', 'biz_archive_type', '0', 'admin', '2026-05-08 15:43:54', '', NULL, '客户档案类型'),
	(123, '报销分类', 'fin_reimbursement_category', '0', 'admin', '2026-05-18 18:03:48', '', NULL, '报销单分类'),
	(124, '支出类型', 'fin_reimbursement_expense_type', '0', 'admin', '2026-05-18 18:03:48', '', NULL, '报销支出类型'),
	(125, '报销状态', 'fin_reimbursement_status', '0', 'admin', '2026-05-18 18:03:48', '', NULL, '报销单状态'),
	(126, '订单来源类型', 'biz_source_type', '0', 'admin', '2026-05-21 23:28:34', '', NULL, '订单来源类型字典（开单/操作/还款/手动）'),
	(127, '付款方式', 'biz_payment_method', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '销售开单付款方式'),
	(128, '反馈类型', 'biz_feedback_type', '0', 'admin', '2026-05-30 13:09:54', '', NULL, '反馈类型列表'),
	(129, '反馈状态', 'biz_feedback_status', '0', 'admin', '2026-05-30 13:09:54', '', NULL, '反馈处理状态列表');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_job 结构
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE IF NOT EXISTS `sys_job` (
  `job_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`,`job_name`,`job_group`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='定时任务调度表';

-- 正在导出表  fuchenpro.sys_job 的数据：~3 rows (大约)
DELETE FROM `sys_job`;
/*!40000 ALTER TABLE `sys_job` DISABLE KEYS */;
INSERT INTO `sys_job` (`job_id`, `job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-04-25 01:10:54', '', NULL, ''),
	(2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-04-25 01:10:54', '', NULL, ''),
	(3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-04-25 01:10:54', '', NULL, '');
/*!40000 ALTER TABLE `sys_job` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_job_log 结构
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE IF NOT EXISTS `sys_job_log` (
  `job_log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) DEFAULT NULL COMMENT '日志信息',
  `status` char(1) DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) DEFAULT '' COMMENT '异常信息',
  `start_time` datetime DEFAULT NULL COMMENT '执行开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '执行结束时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='定时任务调度日志表';

-- 正在导出表  fuchenpro.sys_job_log 的数据：~0 rows (大约)
DELETE FROM `sys_job_log`;
/*!40000 ALTER TABLE `sys_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job_log` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_logininfor 结构
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE IF NOT EXISTS `sys_logininfor` (
  `info_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) DEFAULT '' COMMENT '操作系统',
  `status` char(1) DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) DEFAULT '' COMMENT '提示消息',
  `login_time` datetime DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB AUTO_INCREMENT=326 DEFAULT CHARSET=utf8 COMMENT='系统访问记录';

-- 正在导出表  fuchenpro.sys_logininfor 的数据：~226 rows (大约)
DELETE FROM `sys_logininfor`;
/*!40000 ALTER TABLE `sys_logininfor` DISABLE KEYS */;
INSERT INTO `sys_logininfor` (`info_id`, `user_name`, `ipaddr`, `login_location`, `browser`, `os`, `status`, `msg`, `login_time`) VALUES
	(100, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 10:42:00'),
	(101, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 10:43:45'),
	(102, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 10:51:33'),
	(103, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:30:39'),
	(104, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:32:28'),
	(105, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:32:50'),
	(106, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:33:15'),
	(107, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:35:32'),
	(108, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:41:28'),
	(109, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:46:13'),
	(110, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:47:22'),
	(111, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:48:49'),
	(112, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:54:38'),
	(113, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 13:16:18'),
	(114, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:17:14'),
	(115, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:18:05'),
	(116, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:42:52'),
	(117, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:49:45'),
	(118, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:50:47'),
	(119, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 14:01:31'),
	(120, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 15:10:03'),
	(121, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 16:18:12'),
	(122, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 17:04:45'),
	(123, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 17:05:26'),
	(124, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 18:26:48'),
	(125, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 19:52:14'),
	(126, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 21:05:27'),
	(127, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 21:44:33'),
	(128, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 00:03:37'),
	(129, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 00:46:28'),
	(130, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 12:02:01'),
	(131, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:04:56'),
	(132, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:06:14'),
	(133, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:16:22'),
	(134, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:34:09'),
	(135, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 19:55:31'),
	(136, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 20:05:25'),
	(137, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 20:06:54'),
	(138, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 21:25:38'),
	(139, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 21:39:43'),
	(140, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 22:33:22'),
	(141, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:03:31'),
	(142, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:38:15'),
	(143, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:39:31'),
	(144, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 23:53:55'),
	(145, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 00:04:37'),
	(146, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 00:35:57'),
	(147, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 08:19:15'),
	(148, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 13:07:46'),
	(149, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 13:24:02'),
	(150, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 16:20:20'),
	(151, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 18:22:47'),
	(152, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 19:19:57'),
	(153, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 20:19:54'),
	(154, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 22:04:27'),
	(155, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 23:37:28'),
	(156, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-28 12:33:16'),
	(157, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-28 17:47:29'),
	(158, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-28 22:48:24'),
	(159, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 07:46:46'),
	(160, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 07:47:54'),
	(161, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 12:45:12'),
	(162, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 12:55:27'),
	(163, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 13:00:07'),
	(164, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-04-29 14:18:01'),
	(165, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-04-29 16:40:58'),
	(166, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 18:00:22'),
	(167, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 18:10:50'),
	(168, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 23:48:36'),
	(169, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-30 01:06:19'),
	(170, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 13:55:10'),
	(171, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-30 14:04:36'),
	(172, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 14:07:48'),
	(173, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 19:26:13'),
	(174, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 10:51:21'),
	(175, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 16:12:17'),
	(176, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 22:25:35'),
	(177, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 00:09:54'),
	(178, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-02 00:10:11'),
	(179, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-02 00:10:50'),
	(180, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 12:17:32'),
	(181, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 18:17:46'),
	(182, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 21:43:54'),
	(183, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-02 21:46:33'),
	(184, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 07:58:15'),
	(185, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 07:58:50'),
	(186, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 07:59:37'),
	(187, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 14:22:17'),
	(188, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 15:11:53'),
	(189, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 16:32:39'),
	(190, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 21:38:14'),
	(191, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 03:17:28'),
	(192, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 08:17:51'),
	(193, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 18:37:53'),
	(194, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 23:45:42'),
	(195, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 11:07:36'),
	(196, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-05 12:07:48'),
	(197, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 16:09:10'),
	(198, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 22:46:02'),
	(199, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 23:25:56'),
	(200, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-05 23:35:07'),
	(201, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-06 14:04:38'),
	(202, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-06 19:08:20'),
	(203, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 06:43:53'),
	(204, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 12:33:50'),
	(205, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 18:15:12'),
	(206, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 23:24:34'),
	(207, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 08:22:07'),
	(208, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 15:20:28'),
	(209, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 20:22:45'),
	(210, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-08 21:41:21'),
	(211, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:03:39'),
	(212, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:19:38'),
	(213, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:33:13'),
	(214, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 11:41:18'),
	(215, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-09 16:22:11'),
	(216, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 17:19:42'),
	(217, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 21:12:26'),
	(218, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 22:27:41'),
	(219, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-09 22:41:17'),
	(220, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 10:58:12'),
	(221, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 11:07:34'),
	(222, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 17:03:50'),
	(223, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 17:12:52'),
	(224, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 20:25:57'),
	(225, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 22:12:25'),
	(226, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 22:30:09'),
	(227, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-11 21:31:23'),
	(228, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-11 21:47:14'),
	(229, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-11 21:48:07'),
	(230, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 00:50:38'),
	(231, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 15:12:04'),
	(232, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 15:13:57'),
	(233, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-12 20:20:23'),
	(234, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 20:29:59'),
	(235, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 21:30:44'),
	(236, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-12 22:54:41'),
	(237, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-12 23:59:14'),
	(238, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 16:36:11'),
	(239, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-13 16:42:03'),
	(240, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 22:41:22'),
	(241, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-13 22:45:37'),
	(242, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 22:58:30'),
	(243, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 16:35:12'),
	(244, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-14 16:36:46'),
	(245, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 17:36:03'),
	(246, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 20:14:40'),
	(247, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-14 23:59:20'),
	(248, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 14:15:13'),
	(249, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-15 14:15:21'),
	(250, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 17:03:24'),
	(251, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-15 19:44:39'),
	(252, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 20:50:47'),
	(253, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 19:26:41'),
	(254, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 19:45:39'),
	(255, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 20:12:38'),
	(256, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-16 20:40:38'),
	(257, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-17 19:56:29'),
	(258, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 08:38:14'),
	(259, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 18:03:17'),
	(260, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 19:33:17'),
	(261, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 12:15:37'),
	(262, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:11:08'),
	(263, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:28:11'),
	(264, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:51:03'),
	(265, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 21:43:05'),
	(266, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 22:04:37'),
	(267, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 08:46:23'),
	(268, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 12:21:04'),
	(269, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 13:12:10'),
	(270, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-20 14:47:10'),
	(271, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 14:49:07'),
	(272, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 18:25:09'),
	(273, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 19:50:55'),
	(274, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 20:20:12'),
	(275, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-20 20:25:21'),
	(276, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 21:56:51'),
	(277, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 14:16:27'),
	(278, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 19:38:25'),
	(279, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 20:14:24'),
	(280, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-22 12:41:17'),
	(281, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-22 19:02:36'),
	(282, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-22 19:03:16'),
	(283, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 00:27:34'),
	(284, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 00:27:55'),
	(285, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 13:42:32'),
	(286, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 14:19:50'),
	(287, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 14:41:30'),
	(288, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 15:18:16'),
	(289, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 16:51:10'),
	(290, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 19:11:17'),
	(291, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 19:21:09'),
	(292, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-24 20:16:53'),
	(293, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-24 20:18:56'),
	(294, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-25 11:54:59'),
	(295, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 12:13:26'),
	(296, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-25 17:18:44'),
	(297, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 18:02:51'),
	(298, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 23:06:39'),
	(299, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 00:17:28'),
	(300, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-26 12:22:37'),
	(301, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 14:26:23'),
	(302, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-26 17:49:09'),
	(303, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 19:26:28'),
	(304, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 14:33:17'),
	(305, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-27 14:49:09'),
	(306, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 15:17:45'),
	(307, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-27 21:30:05'),
	(308, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 21:35:24'),
	(309, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-28 13:13:39'),
	(310, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-28 16:47:13'),
	(311, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-28 19:47:38'),
	(312, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 12:32:00'),
	(313, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 13:53:56'),
	(314, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-29 15:22:02'),
	(315, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 17:47:39'),
	(316, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 19:37:07'),
	(317, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-29 22:15:41'),
	(318, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 22:54:05'),
	(319, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:48:54'),
	(320, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:51:15'),
	(321, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:56:08'),
	(322, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 13:05:34'),
	(323, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 13:10:24'),
	(324, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-30 13:10:44'),
	(325, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 14:02:49');
/*!40000 ALTER TABLE `sys_logininfor` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_menu 结构
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE IF NOT EXISTS `sys_menu` (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int(4) DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) DEFAULT '' COMMENT '路由名称',
  `is_frame` int(1) DEFAULT '1' COMMENT '是否为外链（0是 1否）',
  `is_cache` int(1) DEFAULT '0' COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3030 DEFAULT CHARSET=utf8 COMMENT='菜单权限表';

-- 正在导出表  fuchenpro.sys_menu 的数据：~216 rows (大约)
DELETE FROM `sys_menu`;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '系统管理', 0, 4, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-04-25 01:10:46', 'admin', '2026-04-28 21:49:00', '系统管理目录'),
	(2, '系统监控', 0, 7, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-04-25 01:10:46', '', NULL, '系统监控目录'),
	(3, '系统工具', 0, 8, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-04-25 01:10:46', '', NULL, '系统工具目录'),
	(4, '公司官网', 0, 9, 'https://baidu.com', NULL, '', '', 0, 0, 'M', '0', '0', '', 'guide', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-08 09:30:04', '若依官网地址'),
	(100, '用户管理', 3023, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:04:30', '用户管理菜单'),
	(101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-04-25 01:10:46', '', NULL, '角色管理菜单'),
	(102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-04-25 01:10:46', '', NULL, '菜单管理菜单'),
	(103, '部门管理', 3023, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:05:36', '部门管理菜单'),
	(104, '岗位管理', 3023, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:05:48', '岗位管理菜单'),
	(105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-04-25 01:10:46', '', NULL, '字典管理菜单'),
	(106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-04-25 01:10:46', '', NULL, '参数设置菜单'),
	(107, '通知公告', 3023, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:08:38', '通知公告菜单'),
	(108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-04-25 01:10:46', '', NULL, '日志管理菜单'),
	(109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-04-25 01:10:46', '', NULL, '在线用户菜单'),
	(110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-04-25 01:10:46', '', NULL, '定时任务菜单'),
	(111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-04-25 01:10:46', '', NULL, '数据监控菜单'),
	(112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-04-25 01:10:46', '', NULL, '服务监控菜单'),
	(113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-04-25 01:10:46', '', NULL, '缓存监控菜单'),
	(114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-04-25 01:10:47', '', NULL, '缓存列表菜单'),
	(115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-04-25 01:10:47', '', NULL, '表单构建菜单'),
	(116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-04-25 01:10:47', '', NULL, '代码生成菜单'),
	(117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-04-25 01:10:47', '', NULL, '系统接口菜单'),
	(500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-04-25 01:10:47', '', NULL, '操作日志菜单'),
	(501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-04-25 01:10:47', '', NULL, '登录日志菜单'),
	(1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(2000, '业务管理', 0, 1, 'business', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'peoples', 'admin', '2026-04-27 18:23:54', 'admin', '2026-04-28 21:48:20', ''),
	(2001, '企业管理', 2000, 1, 'enterprise', 'business/enterprise/index', NULL, 'Enterprise', 1, 0, 'C', '0', '0', 'business:enterprise:list', 'chart', 'admin', '2026-04-27 18:23:54', 'admin', '2026-04-27 23:27:44', ''),
	(2002, '企业查询', 2001, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:enterprise:query', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2003, '企业新增', 2001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:enterprise:add', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2004, '企业修改', 2001, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:enterprise:edit', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2005, '企业删除', 2001, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:enterprise:remove', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2006, '企业导出', 2001, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:enterprise:export', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2007, '行程安排', 2000, 2, 'schedule', 'business/schedule/index', NULL, 'Schedule', 1, 0, 'C', '0', '0', 'business:schedule:list', 'date', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2008, '行程查询', 2007, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:schedule:query', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2009, '行程新增', 2007, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:schedule:add', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2010, '行程修改', 2007, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:schedule:edit', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2011, '行程删除', 2007, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:schedule:remove', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2012, '考勤管理', 0, 2, 'attendance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'time', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2013, '考勤记录', 2012, 1, 'record', 'business/attendance/record', NULL, 'AttendanceRecord', 1, 0, 'C', '0', '0', 'business:attendance:record:list', 'log', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2014, '考勤规则', 2012, 2, 'rule', 'business/attendance/rule', NULL, 'AttendanceRule', 1, 0, 'C', '0', '0', 'business:attendance:rule:list', 'edit', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2015, '记录查询', 2013, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:record:query', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2016, '记录详情', 2013, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:record:detail', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2017, '规则查询', 2014, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:rule:query', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2018, '规则新增', 2014, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:rule:add', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2019, '规则修改', 2014, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:rule:edit', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2020, '规则删除', 2014, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:rule:remove', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2021, '进销存管理', 0, 3, 'wms', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'shopping', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2022, '供货商管理', 2021, 1, 'supplier', 'wms/supplier/index', NULL, 'WmsSupplier', 1, 0, 'C', '0', '0', 'wms:supplier:list', 'peoples', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2023, '供货商查询', 2022, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:supplier:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2024, '供货商新增', 2022, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:supplier:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2025, '供货商修改', 2022, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:supplier:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2026, '供货商删除', 2022, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:supplier:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2027, '供货商导出', 2022, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:supplier:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2028, '货品管理', 2021, 2, 'product', 'wms/product/index', NULL, 'WmsProduct', 1, 0, 'C', '0', '0', 'wms:product:list', 'component', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2029, '货品查询', 2028, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:product:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2030, '货品新增', 2028, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:product:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2031, '货品修改', 2028, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:product:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2032, '货品删除', 2028, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:product:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2033, '货品导出', 2028, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:product:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2034, '入库管理', 2021, 3, 'stockIn', 'wms/stockIn/index', NULL, 'WmsStockIn', 1, 0, 'C', '0', '0', 'wms:stockIn:list', 'monitor', 'admin', '2026-04-29 07:51:27', 'admin', '2026-04-30 16:52:46', ''),
	(2035, '入库查询', 2034, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2036, '入康新增', 2034, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2037, '入库修改', 2034, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2038, '入库删除', 2034, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2039, '入库确认', 2034, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:confirm', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2040, '入库导出', 2034, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockIn:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2041, '出库管理', 2021, 4, 'stockOut', 'wms/stockOut/index', NULL, 'WmsStockOut', 1, 0, 'C', '0', '0', 'wms:stockOut:list', 'upload', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2042, '出库查询', 2041, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2043, '出库新增', 2041, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2044, '出库修改', 2041, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2045, '出库删除', 2041, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2046, '出库确认', 2041, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:confirm', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2047, '出库导出', 2041, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockOut:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2048, '库存查看', 2021, 5, 'inventory', 'wms/inventory/index', NULL, 'WmsInventory', 1, 0, 'C', '0', '0', 'wms:inventory:list', 'list', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2049, '库存导出', 2048, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:inventory:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2050, '库存盘点', 2021, 6, 'stockCheck', 'wms/stockCheck/index', NULL, 'WmsStockCheck', 1, 0, 'C', '0', '0', 'wms:stockCheck:list', 'clipboard', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2051, '盘点查询', 2050, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:query', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2052, '盘點新增', 2050, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:add', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2053, '盘点修改', 2050, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:edit', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2054, '盘点删除', 2050, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:remove', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2055, '盘点确认', 2050, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:confirm', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2056, '盘点导出', 2050, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:stockCheck:export', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2057, '进销存报表', 2021, 7, 'report', 'wms/report/index', NULL, 'WmsReport', 1, 0, 'C', '0', '0', 'wms:report:list', 'chart', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2058, '报表导出', 2057, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:report:export', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2059, '门店管理', 2000, 2, 'store', 'business/store/index', NULL, 'Store', 1, 0, 'C', '0', '0', 'business:store:list', 'shopping', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2060, '门店查询', 2059, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:store:query', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2061, '门店新增', 2059, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:store:add', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2062, '门店修改', 2059, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:store:edit', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2063, '门店删除', 2059, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:store:remove', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2064, '门店导出', 2059, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:store:export', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2065, '销售开单', 2000, 3, 'sales', 'business/sales/index', NULL, 'Sales', 1, 0, 'C', '0', '0', 'business:sales:list', 'shopping', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2066, '销售开单查询', 2065, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:query', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2067, '销售开单新增', 2065, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:add', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2068, '销售开单修改', 2065, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:edit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2069, '销售开单删除', 2065, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:remove', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2070, '企业审核', 2065, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:enterpriseAudit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2071, '财务审核', 2065, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:sales:financeAudit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2072, '订单管理', 2000, 4, 'order', 'business/order/index', NULL, 'Order', 1, 0, 'C', '0', '0', 'business:order:list', 'list', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2073, '订单查询', 2072, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:order:query', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2074, '企业审核', 2072, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:order:enterpriseAudit', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2075, '财务审核', 2072, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:order:financeAudit', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2076, '方案管理', 2000, 5, 'plan', 'business/planList/index', NULL, 'Plan', 1, 0, 'C', '0', '0', 'business:plan:list', 'list', 'admin', '2026-05-03 19:40:18', '', '2026-05-07 15:00:21', ''),
	(2077, '方案查询', 2076, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:query', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2078, '方案新增', 2076, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:add', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2079, '方案审核', 2076, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:audit', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2080, '考勤配置', 2012, 3, 'config', 'business/attendance/config', NULL, 'AttendanceConfig', 1, 0, 'C', '0', '0', 'business:attendance:config:list', 'form', 'admin', '2026-05-06 00:00:32', 'admin', '2026-05-06 17:24:35', '考勤配置菜单'),
	(2081, '配置查询', 2080, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:query', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2082, '配置新增', 2080, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:add', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2083, '配置修改', 2080, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:edit', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2084, '配置删除', 2080, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:config:remove', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2085, '方案修改', 2076, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:edit', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2086, '方案删除', 2076, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:remove', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2087, '提交审核', 2076, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:plan:submitAudit', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2088, '店企业出货', 2021, 6, 'enterpriseShipment', 'wms/enterpriseShipment/index', NULL, 'EnterpriseShipment', 1, 0, 'C', '0', '0', 'wms:enterpriseShipment:list', 'shopping', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2089, '查看', 2088, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:enterpriseShipment:query', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2090, '审核', 2088, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:enterpriseShipment:audit', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2091, '填写物流', 2088, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:enterpriseShipment:logistics', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2092, '确认发货', 2088, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:enterpriseShipment:ship', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2093, '确认收货', 2088, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'wms:enterpriseShipment:confirmReceipt', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2094, '方案审核操作', 3001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:planAudit:audit', '#', 'admin', '2026-05-18 18:01:58', NULL, NULL, ''),
	(2095, '报销新增', 3002, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:add', '#', 'admin', '2026-05-18 18:01:58', NULL, NULL, ''),
	(2096, '报销编辑', 3002, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:edit', '#', 'admin', '2026-05-18 18:01:58', NULL, NULL, ''),
	(2097, '报销删除', 3002, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:remove', '#', 'admin', '2026-05-18 18:01:58', NULL, NULL, ''),
	(2098, '报销审核', 3002, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:audit', '#', 'admin', '2026-05-18 18:01:58', NULL, NULL, ''),
	(2099, '报销支付', 3002, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:pay', '#', 'admin', '2026-05-18 18:01:59', NULL, NULL, ''),
	(2100, '报销导出', 3002, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:export', '#', 'admin', '2026-05-18 18:01:59', NULL, NULL, ''),
	(3000, '财务管理', 0, 5, 'finance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'money', 'admin', '2026-05-18 18:03:48', NULL, NULL, '财务管理目录'),
	(3001, '方案审核', 3000, 1, 'planAudit', 'finance/planAudit/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:planAudit:list', 'edit', 'admin', '2026-05-18 18:03:48', NULL, NULL, '方案审核菜单'),
	(3002, '报销管理', 3000, 2, 'reimbursement', 'finance/reimbursement/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursement:list', 'form', 'admin', '2026-05-18 18:03:48', NULL, NULL, '报销管理菜单'),
	(3003, '报销统计', 3000, 3, 'reimbursementReport', 'finance/reimbursementReport/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursementReport:list', 'chart', 'admin', '2026-05-18 18:03:48', NULL, NULL, '报销统计菜单'),
	(3004, '方案审核查询', 3001, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:planAudit:query', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3005, '方案审核操作', 3001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:planAudit:audit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3006, '报销查询', 3002, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:query', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3007, '报销新增', 3002, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:add', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3008, '报销编辑', 3002, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:edit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3009, '报销删除', 3002, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:remove', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3010, '报销审核', 3002, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:audit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3011, '报销支付', 3002, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:pay', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3012, '报销导出', 3002, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:export', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3013, 'App菜单配置', 1, 9, 'appMenu', 'system/appMenu/index', NULL, 'AppMenu', 1, 0, 'C', '0', '0', 'system:appMenu:list', 'phone', 'admin', '2026-05-20 22:41:43', '', NULL, 'App移动端菜单配置菜单'),
	(3014, 'App菜单查询', 3013, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:query', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3015, 'App菜单新增', 3013, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:add', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3016, 'App菜单修改', 3013, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:edit', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3017, 'App菜单删除', 3013, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:appMenu:remove', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3018, '轮播图管理', 1, 8, 'banner', 'system/banner/index', NULL, 'Banner', 1, 0, 'C', '0', '0', 'system:banner:list', 'swagger', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3019, '轮播图查询', 3018, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:query', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3020, '轮播图新增', 3018, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:add', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3021, '轮播图修改', 3018, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:edit', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3022, '轮播图删除', 3018, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'system:banner:remove', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3023, '行政管理', 0, 5, 'admin', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'clipboard', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3024, '问题反馈', 3023, 1, 'feedback', 'admin/feedback/index', NULL, 'AdminFeedback', 1, 0, 'C', '0', '0', 'admin:feedback:list', 'message', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3025, '反馈查询', 3024, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:query', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3026, '反馈新增', 3024, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:add', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3027, '反馈修改', 3024, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:edit', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3028, '反馈删除', 3024, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:remove', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3029, '反馈处理', 3024, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'admin:feedback:handle', '#', 'admin', '2026-05-30 13:09:54', '', NULL, '');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_notice 结构
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE IF NOT EXISTS `sys_notice` (
  `notice_id` int(4) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) NOT NULL COMMENT '公告标题',
  `notice_type` char(1) NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob COMMENT '公告内容',
  `status` char(1) DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='通知公告表';

-- 正在导出表  fuchenpro.sys_notice 的数据：~5 rows (大约)
DELETE FROM `sys_notice`;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
INSERT INTO `sys_notice` (`notice_id`, `notice_title`, `notice_type`, `notice_content`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', _binary 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-04-25 01:10:54', '', NULL, '管理员'),
	(2, '维护通知：2018-07-01 若依系统凌晨维护', '1', _binary 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-04-25 01:10:54', '', NULL, '管理员'),
	(3, '若依开源框架介绍', '1', _binary 0x3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE9A1B9E79BAEE4BB8BE7BB8D3C2F7370616E3E3C2F703E3C703E3C666F6E7420636F6C6F723D2223333333333333223E52756F5969E5BC80E6BA90E9A1B9E79BAEE698AFE4B8BAE4BC81E4B89AE794A8E688B7E5AE9AE588B6E79A84E5908EE58FB0E8849AE6898BE69EB6E6A186E69EB6EFBC8CE4B8BAE4BC81E4B89AE68993E980A0E79A84E4B880E7AB99E5BC8FE8A7A3E586B3E696B9E6A188EFBC8CE9998DE4BD8EE4BC81E4B89AE5BC80E58F91E68890E69CACEFBC8CE68F90E58D87E5BC80E58F91E69588E78E87E38082E4B8BBE8A681E58C85E68BACE794A8E688B7E7AEA1E79086E38081E8A792E889B2E7AEA1E79086E38081E983A8E997A8E7AEA1E79086E38081E88F9CE58D95E7AEA1E79086E38081E58F82E695B0E7AEA1E79086E38081E5AD97E585B8E7AEA1E79086E380813C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B297E4BD8DE7AEA1E790863C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E5AE9AE697B6E4BBBBE58AA13C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE380813C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE69C8DE58AA1E79B91E68EA7E38081E799BBE5BD95E697A5E5BF97E38081E6938DE4BD9CE697A5E5BF97E38081E4BBA3E7A081E7949FE68890E7AD89E58A9FE883BDE38082E585B6E4B8ADEFBC8CE8BF98E694AFE68C81E5A49AE695B0E68DAEE6BA90E38081E695B0E68DAEE69D83E99990E38081E59BBDE99985E58C96E380815265646973E7BC93E5AD98E38081446F636B6572E983A8E7BDB2E38081E6BB91E58AA8E9AA8CE8AF81E7A081E38081E7ACACE4B889E696B9E8AEA4E8AF81E799BBE5BD95E38081E58886E5B883E5BC8FE4BA8BE58AA1E380813C2F7370616E3E3C666F6E7420636F6C6F723D2223333333333333223EE58886E5B883E5BC8FE69687E4BBB6E5AD98E582A83C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E58886E5BA93E58886E8A1A8E5A484E79086E7AD89E68A80E69CAFE789B9E782B9E380823C2F7370616E3E3C2F703E3C703E3C696D67207372633D2268747470733A2F2F666F727564612E67697465652E636F6D2F696D616765732F313737333933313834383334323433393033322F61346432323331335F313831353039352E706E6722207374796C653D2277696474683A20363470783B223E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE5AE98E7BD91E58F8AE6BC94E7A4BA3C2F7370616E3E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE5AE98E7BD91E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F72756F79692E7669703C2F613E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E3C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE69687E6A1A3E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F646F632E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F646F632E72756F79692E7669703C2F613E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E4B88DE58886E7A6BBE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F64656D6F2E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F64656D6F2E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E58886E7A6BBE78988E69CACE38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F7675652E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F7675652E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E5BEAEE69C8DE58AA1E78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F636C6F75642E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F636C6F75642E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E7A7BBE58AA8E7ABAFE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F68352E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F68352E72756F79692E7669703C2F613E3C2F703E3C703E3C6272207374796C653D22636F6C6F723A207267622834382C2034392C203531293B20666F6E742D66616D696C793A202671756F743B48656C766574696361204E6575652671756F743B2C2048656C7665746963612C20417269616C2C2073616E732D73657269663B20666F6E742D73697A653A20313270783B223E3C2F703E, '0', 'admin', '2026-04-25 01:10:54', '', NULL, '管理员'),
	(11, '今晚开会', '1', _binary 0x3C703EE4BB8AE6999AE8A681E5BC80E4BC9AE4BA86EFBC81EFBC81EFBC81EFBC813C696D67207372633D222F6465762D61706932303236303532342F62633263386465363631356464363662333566376464656434636531333534382E6A7067223E3C2F703E, '0', 'admin', '2026-05-24 20:19:42', '', NULL, NULL),
	(12, '赛诺第一季度业绩爆红', '1', _binary 0x3C703EE6849FE8B0A2E5A4A7E5AEB6E4B880E5ADA3E5BAA6E4BBA5E69DA5E585B1E5908CE79A84E58AAAE58A9BEFBC8C36E69C8831E697A531393A3030E68891E4BBACE8819AE9A490E78B82E6ACA2EFBC8CE4B88DE98689E4B88DE5BD92EFBC813C696D67207372633D2268747470733A2F2F6D79647265616D2D313330323638323831332E636F732E61702D7368616E676861692E6D7971636C6F75642E636F6D2F75706C6F61642F32303236303532392F66343136626161373134376161343731346535336534646236343932633261312E6A7067223E3C2F703E, '0', 'admin', '2026-05-29 15:40:52', 'admin', '2026-05-29 22:42:24', NULL);
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_notice_read 结构
DROP TABLE IF EXISTS `sys_notice_read`;
CREATE TABLE IF NOT EXISTS `sys_notice_read` (
  `read_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '已读主键',
  `notice_id` int(4) NOT NULL COMMENT '公告id',
  `user_id` bigint(20) NOT NULL COMMENT '用户id',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`),
  UNIQUE KEY `uk_user_notice` (`user_id`,`notice_id`) COMMENT '同一用户同一公告只记录一次'
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='公告已读记录表';

-- 正在导出表  fuchenpro.sys_notice_read 的数据：~5 rows (大约)
DELETE FROM `sys_notice_read`;
/*!40000 ALTER TABLE `sys_notice_read` DISABLE KEYS */;
INSERT INTO `sys_notice_read` (`read_id`, `notice_id`, `user_id`, `read_time`) VALUES
	(1, 1, 1, '2026-05-24 20:18:33'),
	(2, 2, 1, '2026-05-24 20:18:38'),
	(3, 3, 1, '2026-05-24 20:18:44'),
	(4, 11, 1, '2026-05-24 20:19:57'),
	(5, 12, 1, '2026-05-29 15:41:14');
/*!40000 ALTER TABLE `sys_notice_read` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_oper_log 结构
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE IF NOT EXISTS `sys_oper_log` (
  `oper_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) DEFAULT '' COMMENT '模块标题',
  `business_type` int(2) DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` int(1) DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) DEFAULT '' COMMENT '返回参数',
  `status` int(1) DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint(20) DEFAULT '0' COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`),
  KEY `idx_sys_oper_log_bt` (`business_type`),
  KEY `idx_sys_oper_log_s` (`status`),
  KEY `idx_sys_oper_log_ot` (`oper_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='操作日志记录';

-- 正在导出表  fuchenpro.sys_oper_log 的数据：~0 rows (大约)
DELETE FROM `sys_oper_log`;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_post 结构
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE IF NOT EXISTS `sys_post` (
  `post_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) NOT NULL COMMENT '岗位名称',
  `post_sort` int(4) NOT NULL COMMENT '显示顺序',
  `status` char(1) NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='岗位信息表';

-- 正在导出表  fuchenpro.sys_post 的数据：~4 rows (大约)
DELETE FROM `sys_post`;
/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;
INSERT INTO `sys_post` (`post_id`, `post_code`, `post_name`, `post_sort`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 'ceo', '董事长', 1, '0', 'admin', '2026-04-25 01:10:45', '', NULL, ''),
	(2, 'se', '项目经理', 2, '0', 'admin', '2026-04-25 01:10:45', '', NULL, ''),
	(3, 'hr', '人力资源', 3, '0', 'admin', '2026-04-25 01:10:45', '', NULL, ''),
	(4, 'user', '普通员工', 4, '0', 'admin', '2026-04-25 01:10:45', '', NULL, '');
/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_role 结构
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE IF NOT EXISTS `sys_role` (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) NOT NULL COMMENT '角色权限字符串',
  `role_sort` int(4) NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) DEFAULT '1' COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) DEFAULT '1' COMMENT '部门树选择项是否关联显示',
  `status` char(1) NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='角色信息表';

-- 正在导出表  fuchenpro.sys_role 的数据：~2 rows (大约)
DELETE FROM `sys_role`;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `role_sort`, `data_scope`, `menu_check_strictly`, `dept_check_strictly`, `status`, `del_flag`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL, '超级管理员'),
	(2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-04-25 01:10:45', 'admin', '2026-05-08 00:29:26', '普通角色');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_role_dept 结构
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE IF NOT EXISTS `sys_role_dept` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和部门关联表';

-- 正在导出表  fuchenpro.sys_role_dept 的数据：~3 rows (大约)
DELETE FROM `sys_role_dept`;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
INSERT INTO `sys_role_dept` (`role_id`, `dept_id`) VALUES
	(2, 100),
	(2, 101),
	(2, 105);
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_role_menu 结构
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE IF NOT EXISTS `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和菜单关联表';

-- 正在导出表  fuchenpro.sys_role_menu 的数据：~270 rows (大约)
DELETE FROM `sys_role_menu`;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
	(1, 2000),
	(1, 2001),
	(1, 2002),
	(1, 2003),
	(1, 2004),
	(1, 2005),
	(1, 2006),
	(1, 2007),
	(1, 2008),
	(1, 2009),
	(1, 2010),
	(1, 2011),
	(1, 2012),
	(1, 2013),
	(1, 2014),
	(1, 2015),
	(1, 2016),
	(1, 2017),
	(1, 2018),
	(1, 2019),
	(1, 2020),
	(1, 2021),
	(1, 2022),
	(1, 2023),
	(1, 2024),
	(1, 2025),
	(1, 2026),
	(1, 2027),
	(1, 2028),
	(1, 2029),
	(1, 2030),
	(1, 2031),
	(1, 2032),
	(1, 2033),
	(1, 2034),
	(1, 2035),
	(1, 2036),
	(1, 2037),
	(1, 2038),
	(1, 2039),
	(1, 2040),
	(1, 2041),
	(1, 2042),
	(1, 2043),
	(1, 2044),
	(1, 2045),
	(1, 2046),
	(1, 2047),
	(1, 2048),
	(1, 2049),
	(1, 2050),
	(1, 2051),
	(1, 2052),
	(1, 2053),
	(1, 2054),
	(1, 2055),
	(1, 2056),
	(1, 2057),
	(1, 2058),
	(1, 2059),
	(1, 2060),
	(1, 2061),
	(1, 2062),
	(1, 2063),
	(1, 2064),
	(1, 2065),
	(1, 2066),
	(1, 2067),
	(1, 2068),
	(1, 2069),
	(1, 2070),
	(1, 2071),
	(1, 2072),
	(1, 2073),
	(1, 2074),
	(1, 2075),
	(1, 2076),
	(1, 2077),
	(1, 2078),
	(1, 2079),
	(1, 2080),
	(1, 2081),
	(1, 2082),
	(1, 2083),
	(1, 2084),
	(1, 2088),
	(1, 2089),
	(1, 2090),
	(1, 2091),
	(1, 2092),
	(1, 2093),
	(1, 3018),
	(1, 3019),
	(1, 3020),
	(1, 3021),
	(1, 3022),
	(1, 3023),
	(1, 3024),
	(1, 3025),
	(1, 3026),
	(1, 3027),
	(1, 3028),
	(1, 3029),
	(2, 1),
	(2, 2),
	(2, 3),
	(2, 4),
	(2, 100),
	(2, 101),
	(2, 102),
	(2, 103),
	(2, 104),
	(2, 105),
	(2, 106),
	(2, 107),
	(2, 108),
	(2, 109),
	(2, 110),
	(2, 111),
	(2, 112),
	(2, 113),
	(2, 114),
	(2, 115),
	(2, 116),
	(2, 117),
	(2, 500),
	(2, 501),
	(2, 1000),
	(2, 1001),
	(2, 1002),
	(2, 1003),
	(2, 1004),
	(2, 1005),
	(2, 1006),
	(2, 1007),
	(2, 1008),
	(2, 1009),
	(2, 1010),
	(2, 1011),
	(2, 1012),
	(2, 1013),
	(2, 1014),
	(2, 1015),
	(2, 1016),
	(2, 1017),
	(2, 1018),
	(2, 1019),
	(2, 1020),
	(2, 1021),
	(2, 1022),
	(2, 1023),
	(2, 1024),
	(2, 1025),
	(2, 1026),
	(2, 1027),
	(2, 1028),
	(2, 1029),
	(2, 1030),
	(2, 1031),
	(2, 1032),
	(2, 1033),
	(2, 1034),
	(2, 1035),
	(2, 1036),
	(2, 1037),
	(2, 1038),
	(2, 1039),
	(2, 1040),
	(2, 1041),
	(2, 1042),
	(2, 1043),
	(2, 1044),
	(2, 1045),
	(2, 1046),
	(2, 1047),
	(2, 1048),
	(2, 1049),
	(2, 1050),
	(2, 1051),
	(2, 1052),
	(2, 1053),
	(2, 1054),
	(2, 1055),
	(2, 1056),
	(2, 1057),
	(2, 1058),
	(2, 1059),
	(2, 1060),
	(2, 2000),
	(2, 2001),
	(2, 2002),
	(2, 2003),
	(2, 2004),
	(2, 2005),
	(2, 2006),
	(2, 2007),
	(2, 2008),
	(2, 2009),
	(2, 2010),
	(2, 2011),
	(2, 2012),
	(2, 2013),
	(2, 2014),
	(2, 2015),
	(2, 2016),
	(2, 2017),
	(2, 2018),
	(2, 2019),
	(2, 2020),
	(2, 2021),
	(2, 2022),
	(2, 2023),
	(2, 2024),
	(2, 2025),
	(2, 2026),
	(2, 2027),
	(2, 2028),
	(2, 2029),
	(2, 2030),
	(2, 2031),
	(2, 2032),
	(2, 2033),
	(2, 2034),
	(2, 2035),
	(2, 2036),
	(2, 2037),
	(2, 2038),
	(2, 2039),
	(2, 2040),
	(2, 2041),
	(2, 2042),
	(2, 2043),
	(2, 2044),
	(2, 2045),
	(2, 2046),
	(2, 2047),
	(2, 2048),
	(2, 2049),
	(2, 2050),
	(2, 2051),
	(2, 2052),
	(2, 2053),
	(2, 2054),
	(2, 2055),
	(2, 2056),
	(2, 2057),
	(2, 2058),
	(2, 2059),
	(2, 2060),
	(2, 2061),
	(2, 2062),
	(2, 2063),
	(2, 2064),
	(2, 2065),
	(2, 2066),
	(2, 2067),
	(2, 2068),
	(2, 2069),
	(2, 2070),
	(2, 2071),
	(2, 2072),
	(2, 2073),
	(2, 2074),
	(2, 2075),
	(2, 2076),
	(2, 2077),
	(2, 2078),
	(2, 2079),
	(2, 2080),
	(2, 2081),
	(2, 2082),
	(2, 2083),
	(2, 2084),
	(2, 2085),
	(2, 2086),
	(2, 2087),
	(2, 2088),
	(2, 2089),
	(2, 2090),
	(2, 2091),
	(2, 2092),
	(2, 2093);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user 结构
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE IF NOT EXISTS `sys_user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint(20) DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) DEFAULT '' COMMENT '手机号码',
  `sex` char(1) DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) DEFAULT '' COMMENT '密码',
  `status` char(1) DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8 COMMENT='用户信息表';

-- 正在导出表  fuchenpro.sys_user 的数据：~4 rows (大约)
DELETE FROM `sys_user`;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` (`user_id`, `dept_id`, `user_name`, `nick_name`, `user_type`, `email`, `phonenumber`, `sex`, `avatar`, `password`, `status`, `del_flag`, `login_ip`, `login_date`, `pwd_update_date`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/avatar/a66467cde77a863b9a21bff37f912c67.png', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-05-30 14:02:48', '2026-04-25 01:10:45', 'admin', '2026-04-25 01:10:45', '', NULL, '管理员'),
	(2, 106, 'ry', '若人头', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-04-25 01:10:45', '2026-04-25 01:10:45', 'admin', '2026-04-25 01:10:45', 'admin', '2026-04-28 22:24:11', '测试员'),
	(100, 101, '测试', '测试', '00', '', '15877778888', '0', '', '$2y$10$XouudTyFvzABxDZVRaQhZ.Jh9TSE9Qil2RA2N9mzv6hPqcyo.O4Uy', '0', '0', '', NULL, NULL, 'admin', '2026-04-25 21:08:28', '', NULL, '111'),
	(101, NULL, '辅导费', '奋斗奋斗', '00', '', '', '0', '', '$2y$10$GiUlf1m6QaMIwgfxTHuDfeEoedCiiS0O1HBb3bcR.rW0DKPuua8gK', '0', '2', '', NULL, NULL, 'admin', '2026-05-20 19:52:31', '', NULL, NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user_detail 结构
DROP TABLE IF EXISTS `sys_user_detail`;
CREATE TABLE IF NOT EXISTS `sys_user_detail` (
  `detail_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '详情ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `wechat` varchar(50) DEFAULT '' COMMENT '微信号',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `id_card` varchar(18) DEFAULT '' COMMENT '身份证号',
  `address` varchar(200) DEFAULT '' COMMENT '住址',
  `welcome_slogan` varchar(50) DEFAULT NULL COMMENT '首页问候语',
  `hire_date` date DEFAULT NULL COMMENT '入职日期',
  `employment_status` char(1) DEFAULT '0' COMMENT '在职状态（0在职 1离职）',
  `resign_date` date DEFAULT NULL COMMENT '离职日期',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`detail_id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='员工详情表';

-- 正在导出表  fuchenpro.sys_user_detail 的数据：~2 rows (大约)
DELETE FROM `sys_user_detail`;
/*!40000 ALTER TABLE `sys_user_detail` DISABLE KEYS */;
INSERT INTO `sys_user_detail` (`detail_id`, `user_id`, `wechat`, `birthday`, `id_card`, `address`, `welcome_slogan`, `hire_date`, `employment_status`, `resign_date`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 2, '', NULL, '', '', NULL, NULL, '0', NULL, 'admin', '2026-04-28 16:00:14', 'admin', '2026-04-28 22:24:11', ''),
	(2, 1, '', NULL, '', '', '永远相信美好的事情即将发生！', NULL, '0', NULL, '', '2026-05-24 22:33:34', '', NULL, NULL);
/*!40000 ALTER TABLE `sys_user_detail` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user_post 结构
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE IF NOT EXISTS `sys_user_post` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户与岗位关联表';

-- 正在导出表  fuchenpro.sys_user_post 的数据：~3 rows (大约)
DELETE FROM `sys_user_post`;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
INSERT INTO `sys_user_post` (`user_id`, `post_id`) VALUES
	(1, 1),
	(2, 2),
	(100, 4);
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user_role 结构
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户和角色关联表';

-- 正在导出表  fuchenpro.sys_user_role 的数据：~3 rows (大约)
DELETE FROM `sys_user_role`;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES
	(1, 1),
	(2, 1),
	(100, 2);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
