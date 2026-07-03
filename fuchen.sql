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


-- 导出 fuchenpro 的数据库结构
DROP DATABASE IF EXISTS `fuchenpro`;
CREATE DATABASE IF NOT EXISTS `fuchenpro` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `fuchenpro`;

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
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='App移动端菜单配置表';

-- 正在导出表  fuchenpro.app_menu_config 的数据：~45 rows (大约)
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
	(15, '系统管理', 'system', 6, '用户管理', 'account', '/pages/system/user/index', 'system:user:list', '#fff', '#3D6DF7', 1, 1, '0', '', NULL, '', NULL, ''),
	(16, '系统管理', 'system', 6, '角色管理', 'man-add', '/pages/system/role/index', 'system:role:list', '#fff', '#3D6DF7', 2, 1, '0', '', NULL, '', NULL, ''),
	(17, '系统管理', 'system', 6, '菜单管理', 'list', '', 'system:menu:list', '#fff', '#3D6DF7', 3, 1, '0', '', NULL, '', NULL, ''),
	(18, '系统管理', 'system', 6, '部门管理', 'home', '/pages/system/dept/index', 'system:dept:list', '#fff', '#3D6DF7', 4, 1, '0', '', NULL, '', NULL, ''),
	(19, '系统管理', 'system', 6, '岗位管理', 'bookmark', '/pages/system/post/index', 'system:post:list', '#fff', '#3D6DF7', 5, 1, '0', '', NULL, '', NULL, ''),
	(20, '系统管理', 'system', 6, '字典管理', 'file-text', '/pages/system/dict/index', 'system:dict:list', '#fff', '#3D6DF7', 6, 1, '0', '', NULL, '', NULL, ''),
	(21, '系统管理', 'system', 6, '参数设置', 'setting', '', 'system:config:list', '#fff', '#3D6DF7', 7, 1, '0', '', NULL, '', NULL, ''),
	(22, '系统管理', 'system', 6, '通知公告', 'chat', '/pages/system/notice/index', 'system:notice:list', '#fff', '#3D6DF7', 8, 1, '0', '', NULL, '', NULL, ''),
	(23, '快捷操作', 'mine_action', 7, '在线客服', 'chat', '', '', '#666', '#f5f5f5', 1, 0, '0', '', NULL, '', NULL, ''),
	(24, '快捷操作', 'mine_action', 7, '反馈社区', 'edit-pen', '', '', '#666', '#f5f5f5', 2, 0, '0', '', NULL, '', NULL, ''),
	(25, '快捷操作', 'mine_action', 7, '点赞我们', 'thumb-up', '', '', '#666', '#f5f5f5', 3, 0, '0', '', NULL, '', NULL, ''),
	(26, '快捷操作', 'mine_action', 7, '关于我们', 'info-circle', '/pages/mine/about/index', '', '#666', '#f5f5f5', 4, 0, '0', '', NULL, '', NULL, ''),
	(27, '个人菜单', 'mine_menu', 8, '编辑资料', 'edit-pen', '/pages/mine/info/edit', '', '#3c96f3', '#e8f2ff', 1, 0, '0', '', NULL, '', NULL, ''),
	(28, '个人菜单', 'mine_menu', 8, '常见问题', 'question-circle', '/pages/mine/help/index', '', '#3c96f3', '#e8f2ff', 2, 0, '0', '', NULL, '', NULL, ''),
	(29, '个人菜单', 'mine_menu', 8, '关于我们', 'info-circle', '/pages/mine/about/index', '', '#3c96f3', '#e8f2ff', 3, 0, '0', '', NULL, '', NULL, ''),
	(30, '个人菜单', 'mine_menu', 8, '应用设置', 'setting', '/pages/mine/setting/index', '', '#3c96f3', '#e8f2ff', 4, 0, '0', '', NULL, '', NULL, ''),
	(42, '考勤管理', 'attendance', 3, '考勤打卡', 'clock', '/pages/attendance/index', '', '#fff', '#F59E0B', 1, 1, '0', '', NULL, '', NULL, ''),
	(43, '考勤管理', 'attendance', 3, '考勤记录', 'file-text', '/pages/attendance/record', '', '#fff', '#F59E0B', 2, 1, '0', '', NULL, '', NULL, ''),
	(44, '考勤管理', 'attendance', 3, '考勤规则', 'setting', '/pages/attendance/rule', '', '#fff', '#F59E0B', 3, 1, '0', '', NULL, '', NULL, ''),
	(45, '考勤管理', 'attendance', 3, '考勤配置', 'grid', '/pages/attendance/config', '', '#fff', '#F59E0B', 4, 1, '0', '', NULL, '', NULL, ''),
	(46, '进销存管理', 'wms', 4, '供货商管理', 'account', '/pages/wms/supplier/index', '', '#fff', '#10B981', 1, 1, '0', '', NULL, '', NULL, ''),
	(47, '进销存管理', 'wms', 4, '货品管理', 'list', '/pages/wms/product/index', '', '#fff', '#10B981', 2, 1, '0', '', NULL, '', NULL, ''),
	(48, '进销存管理', 'wms', 4, '入库管理', 'arrow-down', '/pages/wms/stockIn/index', '', '#fff', '#10B981', 3, 1, '0', '', NULL, '', NULL, ''),
	(49, '进销存管理', 'wms', 4, '出库管理', 'arrow-up', '/pages/wms/shipment/index', '', '#fff', '#10B981', 4, 1, '0', '', NULL, '', NULL, ''),
	(50, '进销存管理', 'wms', 4, '库存查看', 'search', '/pages/wms/stock/index', '', '#fff', '#10B981', 5, 1, '0', '', NULL, '', NULL, ''),
	(51, '进销存管理', 'wms', 4, '库存盘点', 'checkmark-circle', '/pages/wms/stockCheck/index', '', '#fff', '#10B981', 6, 1, '0', '', NULL, '', NULL, ''),
	(52, '进销存管理', 'wms', 4, '店企业出货', 'car', '/pages/wms/shipment/index', '', '#fff', '#10B981', 7, 1, '0', '', NULL, '', NULL, ''),
	(53, '进销存管理', 'wms', 4, '进销存报表', 'list-dot', '', '', '#fff', '#10B981', 8, 1, '0', '', NULL, '', NULL, ''),
	(54, '财务管理', 'finance', 5, '方案审核', 'checkmark', '/pages/finance/planAudit/index', '', '#fff', '#8B5CF6', 1, 1, '0', '', NULL, '', NULL, ''),
	(55, '财务管理', 'finance', 5, '报销管理', 'edit-pen', '/pages/finance/reimbursement/index', '', '#fff', '#8B5CF6', 2, 1, '0', '', NULL, '', NULL, ''),
	(56, '财务管理', 'finance', 5, '报销统计', 'file-text', '/pages/finance/reimbursementReport/index', '', '#fff', '#8B5CF6', 3, 1, '0', '', NULL, '', NULL, ''),
	(57, '业务管理', 'business', 2, '方案管理', 'file-text', '/pages/business/plan/index', 'business:plan:list', '#fff', '#FF6B35', 6, 1, '0', '', NULL, '', NULL, ''),
	(58, '业务管理', 'business', 2, '卡项管理', 'star', '/pages/business/cardItem/index', 'business:cardItem:list', '#fff', '#FF6B35', 7, 1, '0', '', NULL, '', NULL, ''),
	(59, '业务管理', 'business', 2, '备货管理', 'shopping-cart', '/pages/business/stockPrepare/index', 'business:stockPrepare:list', '#fff', '#FF6B35', 8, 1, '0', '', NULL, '', NULL, ''),
	(60, '业务管理', 'business', 2, '客户管理', 'account', '/pages/business/customer/index', 'business:customer:list', '#fff', '#FF6B35', 9, 1, '0', '', NULL, '', NULL, ''),
	(61, '进销存管理', 'wms', 4, '仓库管理', 'home', '/pages/wms/warehouse/index', '', '#fff', '#10B981', 7, 1, '0', 'admin', '2026-06-20 19:59:16', '', NULL, ''),
	(62, '进销存管理', 'wms', 4, '调拨管理', 'swap', '/pages/wms/stockTransfer/index', '', '#fff', '#10B981', 9, 1, '0', 'admin', '2026-06-20 19:59:16', '', NULL, '');
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
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='打卡明细表';

-- 正在导出表  fuchenpro.biz_attendance_clock 的数据：~22 rows (大约)
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
	(15, 5, 1, '若依', '2026-05-23 19:44:41', '0', '0', 31.2130010, 121.4782990, '中海·恒昌玖里(建设中)', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260523/5e90ca62cd1001e8dbeaa9e7ee4b176a.jpg', '', '', '2026-05-23 19:44:41'),
	(16, 6, 1, '若依', '2026-06-19 23:35:21', '0', '0', NULL, NULL, '东方闪电', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260619/81962052c5dca9e44e9f1c0025f6f613.jpg', '', '', '2026-06-19 23:35:21'),
	(17, 6, 1, '若依', '2026-06-19 23:35:43', '1', '0', NULL, NULL, '好', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260619/dd6a80150b80be05cc9ab64e31728160.jpg', '', '', '2026-06-19 23:35:43'),
	(18, 6, 1, '若依', '2026-06-19 23:45:01', '1', '0', NULL, NULL, '111', '', '', '', '2026-06-19 23:45:01'),
	(19, 7, 1, '若依', '2026-06-26 02:09:44', '0', '0', NULL, NULL, '定位失败', '', '', '', '2026-06-26 02:09:44'),
	(20, 7, 1, '若依', '2026-06-26 02:39:47', '1', '0', NULL, NULL, '77', '', '', '', '2026-06-26 02:39:47'),
	(21, 7, 1, '若依', '2026-06-26 17:17:54', '1', '0', 31.2129690, 121.4783340, '顺昌路504弄小区', '', '', '', '2026-06-26 17:17:54'),
	(22, 7, 1, '若依', '2026-06-26 22:22:33', '1', '1', 31.2129310, 121.4782640, '顺昌路504弄小区', '/profile/upload/20260626/d57aa17f2831c2980714aca0fd2fa3d5.jpg', '估计快了', '', '2026-06-26 22:22:33'),
	(23, 8, 1, '超级管理员', '2026-06-30 00:41:28', '0', '1', 31.0443360, 121.4661780, '永德小区北区', '/profile/upload/20260630/024c058f6b4b61698acbfb0306ec1854.jpg', '111', '', '2026-06-30 00:41:28');
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

-- 正在导出表  fuchenpro.biz_attendance_config 的数据：~3 rows (大约)
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考勤记录表';

-- 正在导出表  fuchenpro.biz_attendance_record 的数据：~7 rows (大约)
DELETE FROM `biz_attendance_record`;
/*!40000 ALTER TABLE `biz_attendance_record` DISABLE KEYS */;
INSERT INTO `biz_attendance_record` (`record_id`, `user_id`, `user_name`, `attendance_date`, `clock_in_time`, `clock_out_time`, `clock_in_latitude`, `clock_in_longitude`, `clock_in_address`, `clock_in_photo`, `clock_out_latitude`, `clock_out_longitude`, `clock_out_address`, `clock_out_photo`, `attendance_status`, `clock_count`, `first_clock_time`, `last_clock_time`, `clock_type`, `outside_reason`, `rule_id`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, '若依', '2026-04-29', '2026-04-29 14:51:12', '2026-04-29 20:04:21', 31.0443840, 121.4664005, '31.044384, 121.466400', '', NULL, NULL, '1212', '/profile/upload/20260429/faa1dab92844899c9730d80d565c99d8.png', '1', 3, '2026-04-29 14:51:12', '2026-04-29 20:04:21', '0', '', 1, '', '若依', '2026-04-29 14:51:12', '若依', '2026-04-29 20:04:21'),
	(2, 1, '若依', '2026-04-30', '2026-04-30 01:06:48', '2026-04-30 01:22:31', NULL, NULL, '', '/profile/upload/20260430/aaa8286dfa49ad4e4064448bf5e8baa5.png', NULL, NULL, '111', '/profile/upload/20260430/9afe6ed2e06052fb9aaa44882540c5ed.png', '2', 2, '2026-04-30 01:06:48', '2026-04-30 01:22:31', '0', '', NULL, '', '若依', '2026-04-30 01:06:48', '', '2026-04-30 01:22:31'),
	(3, 1, 'admin', '2026-05-02', '2026-05-02 00:31:06', '2026-05-02 21:44:26', 31.0443368, 121.4664212, '上海市闵行区吴泾镇闵行区吴泾第一幼儿园(永德园)永德小区北区', '', 31.0443450, 121.4662010, '永德小区北区', '/profile/upload/20260502/09b530786537df3e7b79f4335182dc22.jpg', '0', 6, '2026-05-02 00:31:06', '2026-05-02 21:44:26', '0', '', NULL, '', 'admin', '2026-05-02 00:31:06', '', '2026-05-02 21:44:26'),
	(4, 1, 'admin', '2026-05-05', '2026-05-05 23:35:24', '2026-05-05 23:35:51', 31.0442870, 121.4661830, '永德小区北区', '', 31.0442870, 121.4661830, '永德小区北区', '', '1', 2, '2026-05-05 23:35:24', '2026-05-05 23:35:51', '0', '', NULL, '', 'admin', '2026-05-05 23:35:24', '', '2026-05-05 23:35:51'),
	(5, 1, '若依', '2026-05-23', NULL, NULL, NULL, NULL, '', '', NULL, NULL, '', '', '0', 0, NULL, NULL, '0', '', NULL, '', '若依', '2026-05-23 19:44:21', '', '2026-05-23 19:44:21'),
	(6, 1, '若依', '2026-06-19', '2026-06-19 23:35:21', '2026-06-19 23:45:01', NULL, NULL, '东方闪电', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260619/81962052c5dca9e44e9f1c0025f6f613.jpg', NULL, NULL, '111', '', '1', 3, '2026-06-19 23:35:21', '2026-06-19 23:45:01', '0', '', NULL, '', '若依', '2026-06-19 23:35:21', '', '2026-06-19 23:45:01'),
	(7, 1, '若依', '2026-06-26', '2026-06-26 02:09:44', '2026-06-26 22:22:33', NULL, NULL, '定位失败', '', 31.2129310, 121.4782640, '顺昌路504弄小区', '/profile/upload/20260626/d57aa17f2831c2980714aca0fd2fa3d5.jpg', '0', 4, '2026-06-26 02:09:44', '2026-06-26 22:22:33', '0', '', NULL, '', '若依', '2026-06-26 02:09:44', '', '2026-06-26 22:22:33'),
	(8, 1, '超级管理员', '2026-06-30', '2026-06-30 00:41:28', '2026-06-30 00:41:28', 31.0443360, 121.4661780, '永德小区北区', '/profile/upload/20260630/024c058f6b4b61698acbfb0306ec1854.jpg', 31.0443360, 121.4661780, '永德小区北区', '/profile/upload/20260630/024c058f6b4b61698acbfb0306ec1854.jpg', '0', 1, '2026-06-30 00:41:28', '2026-06-30 00:41:28', '0', '', NULL, '', '超级管理员', '2026-06-30 00:41:28', '', '2026-06-30 00:41:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考勤规则表';

-- 正在导出表  fuchenpro.biz_attendance_rule 的数据：~2 rows (大约)
DELETE FROM `biz_attendance_rule`;
/*!40000 ALTER TABLE `biz_attendance_rule` DISABLE KEYS */;
INSERT INTO `biz_attendance_rule` (`rule_id`, `rule_name`, `work_start_time`, `work_end_time`, `late_threshold`, `early_leave_threshold`, `work_latitude`, `work_longitude`, `work_address`, `allowed_distance`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '标准班', '10:00:00', '18:00:00', 0, 0, 31.2109990, 121.4824490, '上海市黄浦区半淞园路街道恒升大厦', 500, '0', '默认考勤规则', 'admin', '2026-04-29 07:46:25', 'admin', '2026-06-28 00:34:43'),
	(2, '红红', '10:00:00', '18:00:00', 1, 0, 31.2109990, 121.4824490, '上海市黄浦区半淞园路街道恒升大厦', 500, '0', '', 'admin', '2026-06-28 00:22:52', 'admin', '2026-06-28 00:42:43');
/*!40000 ALTER TABLE `biz_attendance_rule` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_card_item 结构
DROP TABLE IF EXISTS `biz_card_item`;
CREATE TABLE IF NOT EXISTS `biz_card_item` (
  `card_item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '卡项ID',
  `card_item_name` varchar(100) NOT NULL COMMENT '卡项名称',
  `card_item_code` varchar(50) DEFAULT NULL COMMENT '卡项编码',
  `category` char(1) NOT NULL DEFAULT '1' COMMENT '类别(1面部 2身体 3仪器 4其他)',
  `default_quantity` int(11) NOT NULL DEFAULT '1' COMMENT '默认次数',
  `suggested_price` decimal(12,2) DEFAULT '0.00' COMMENT '建议成交价',
  `default_unit_price` decimal(12,2) DEFAULT '0.00' COMMENT '默认单次价',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`card_item_id`),
  UNIQUE KEY `uk_card_item_code` (`card_item_code`),
  KEY `idx_card_item_name` (`card_item_name`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='卡项目录表';

-- 正在导出表  fuchenpro.biz_card_item 的数据：~0 rows (大约)
DELETE FROM `biz_card_item`;
/*!40000 ALTER TABLE `biz_card_item` DISABLE KEYS */;
INSERT INTO `biz_card_item` (`card_item_id`, `card_item_name`, `card_item_code`, `category`, `default_quantity`, `suggested_price`, `default_unit_price`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '卡项1', 'KX1-20260601', '2', 10, 15180.00, 1518.00, '0', NULL, 'admin', '2026-06-01 19:09:02', 'admin', '2026-07-02 23:35:48');
/*!40000 ALTER TABLE `biz_card_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_card_item_product 结构
DROP TABLE IF EXISTS `biz_card_item_product`;
CREATE TABLE IF NOT EXISTS `biz_card_item_product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `card_item_id` bigint(20) NOT NULL COMMENT '卡项ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `unit_type` char(1) NOT NULL DEFAULT '1' COMMENT '单位类型(1主单位-整 2副单位-拆)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例(1主单位=多少副单位)',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '消耗数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_card_item_id` (`card_item_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='卡项关联货品表';

-- 正在导出表  fuchenpro.biz_card_item_product 的数据：~2 rows (大约)
DELETE FROM `biz_card_item_product`;
/*!40000 ALTER TABLE `biz_card_item_product` DISABLE KEYS */;
INSERT INTO `biz_card_item_product` (`id`, `card_item_id`, `product_id`, `unit_type`, `pack_qty`, `quantity`, `remark`) VALUES
	(8, 1, 1, '1', 10, 1, NULL),
	(9, 1, 2, '1', 10, 1, NULL),
	(10, 1, 3, '1', 10, 1, NULL);
/*!40000 ALTER TABLE `biz_card_item_product` ENABLE KEYS */;

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户表';

-- 正在导出表  fuchenpro.biz_customer 的数据：~4 rows (大约)
DELETE FROM `biz_customer`;
/*!40000 ALTER TABLE `biz_customer` DISABLE KEYS */;
INSERT INTO `biz_customer` (`customer_id`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `customer_name`, `avatar`, `phone`, `wechat`, `gender`, `age`, `tag`, `remark`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 7, '终测1', 8, '终测门店2', '客户1', 'https://synolife-1443627946.cos.ap-shanghai.myqcloud.com/customer_avatar/ad25eceeac53e52b75f3a4ef031c90c3.jpg', '', '', '1', 55, 'normal', '俄文', '0', 'admin', '2026-06-20 18:35:09', 'admin', '2026-06-26 02:41:45'),
	(2, 7, NULL, 8, NULL, '111', '/profile/customer_avatar/b9f32df95027f927b827580f8471d45f.jpg', NULL, NULL, '1', NULL, NULL, NULL, '0', 'admin', '2026-06-26 07:40:01', '', '2026-06-26 07:40:01'),
	(3, 7, NULL, 7, NULL, '新客户1', '/profile/customer_avatar/e116fa4f7a1390880c81eccfa7759ec6.jpg', NULL, NULL, '1', 55, 'vip', '111', '0', 'admin', '2026-06-27 23:34:57', '', '2026-06-27 23:34:57'),
	(4, 4, '企业1', 5, '哈哈', 'LIly', '/profile/customer_avatar/3f599c581cd3687edbebec330ef2fff6.jpg', '', '', '1', 55, 'normal,important', '', '0', 'pengpeng', '2026-06-28 21:46:28', 'pengpeng', '2026-06-28 21:54:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户档案表';

-- 正在导出表  fuchenpro.biz_customer_archive 的数据：~7 rows (大约)
DELETE FROM `biz_customer_archive`;
/*!40000 ALTER TABLE `biz_customer_archive` DISABLE KEYS */;
INSERT INTO `biz_customer_archive` (`archive_id`, `customer_id`, `customer_name`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `archive_date`, `archive_type`, `source_type`, `source_id`, `plan_items`, `amount`, `satisfaction`, `photos`, `customer_feedback`, `operator_user_id`, `operator_user_name`, `remark`, `create_by`, `create_time`) VALUES
	(1, 1, '客户1', 7, '终测1', 8, '终测门店2', '2026-06-20', 'sales', '0', 1, '[{"name":"卡项1","quantity":10}]', 9380.00, NULL, NULL, '11', 1, '若依', '套餐: 套餐1', 'admin', '2026-06-20 19:13:56'),
	(2, 1, '客户1', 7, '终测1', 8, '终测门店2', '2026-06-20', 'sales', '1', 1, '[{"name":"卡项1","quantity":1}]', 938.00, 4, '["\\/profile\\/upload\\/20260620\\/0996e45411a292d11f0d65c75d4b9ac7.jpg"]', '防守打法水电费第三方', 1, '若依', '放大发的', 'admin', '2026-06-20 19:16:59'),
	(3, 2, '111', 7, '终测1', 8, '终测门店2', '2026-06-26', 'sales', '0', 3, '[{"name":"卡项1","quantity":10}]', 9380.00, NULL, NULL, '', 1, '若依', '套餐: 11', 'admin', '2026-06-26 22:08:49'),
	(4, 1, '客户1', 7, '终测1', 8, '终测门店2', '2026-06-26', 'sales', '1', 2, '[{"name":"卡项1","quantity":1}]', 938.00, 5, NULL, '', 1, '若依', '', 'admin', '2026-06-27 06:13:24'),
	(5, 4, 'LIly', 4, '企业1', 5, '哈哈', '2026-06-28', 'sales', '0', 5, '[{"name":"卡项1","quantity":10}]', 9380.00, NULL, NULL, '', 103, '鹏鹏', '套餐: 发发发', 'pengpeng', '2026-06-28 22:57:02'),
	(6, 4, 'LIly', 4, '企业1', 5, '哈哈', '2026-06-28', 'sales', '0', 6, '[{"name":"卡项1","quantity":10}]', 9380.00, NULL, NULL, '', 1, '超级管理员', '套餐: 111', 'admin', '2026-06-28 23:14:18'),
	(7, 4, 'LIly', 4, '企业1', 5, '哈哈', '2026-06-28', 'sales', '0', 7, '[{"name":"卡项1","quantity":10}]', 9380.00, NULL, NULL, '', 105, '测试', '套餐: 22', 'ceshi', '2026-06-28 23:16:10'),
	(8, 3, '新客户1', 7, '终测1', 7, '终测门店1', '2026-07-03', 'sales', '0', 2, '[{"name":"卡项1","quantity":10}]', 15180.00, NULL, NULL, '', 1, '超级管理员', '套餐: ', 'admin', '2026-07-03 00:00:41'),
	(9, 3, '新客户1', 7, '终测1', 7, '终测门店1', '2026-07-03', 'sales', '0', 4, '[{"name":"卡项1","quantity":10}]', 15180.00, NULL, NULL, '', 1, '超级管理员', '套餐: ', 'admin', '2026-07-03 00:09:15');
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户套餐表';

-- 正在导出表  fuchenpro.biz_customer_package 的数据：~5 rows (大约)
DELETE FROM `biz_customer_package`;
/*!40000 ALTER TABLE `biz_customer_package` DISABLE KEYS */;
INSERT INTO `biz_customer_package` (`package_id`, `package_no`, `customer_id`, `customer_name`, `order_id`, `order_no`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `package_name`, `total_amount`, `paid_amount`, `owed_amount`, `status`, `expire_date`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'PK202606200001', 1, '客户1', 1, 'SO202606200001', 7, '终测1', 8, '终测门店2', '套餐1', 9380.00, 9380.00, 0.00, '1', NULL, '11', 'admin', '2026-06-20 19:13:56', '', '2026-06-20 19:13:56'),
	(2, 'PK202606260003', 2, '111', 3, 'SO202606260003', 7, '终测1', 8, '终测门店2', '11', 9380.00, 9380.00, 0.00, '1', NULL, '', 'admin', '2026-06-26 22:08:49', '', '2026-06-26 22:08:49'),
	(3, 'PK202606280001', 4, 'LIly', 5, 'SO202606280001', 4, '企业1', 5, '哈哈', '发发发', 9380.00, 9380.00, 0.00, '1', NULL, '', 'pengpeng', '2026-06-28 22:57:02', '', '2026-06-28 22:57:02'),
	(4, 'PK202606280002', 4, 'LIly', 6, 'SO202606280002', 4, '企业1', 5, '哈哈', '111', 9380.00, 9380.00, 0.00, '1', NULL, '', 'admin', '2026-06-28 23:14:18', '', '2026-06-28 23:14:18'),
	(5, 'PK202606280003', 4, 'LIly', 7, 'SO202606280003', 4, '企业1', 5, '哈哈', '22', 9380.00, 9380.00, 0.00, '1', NULL, '', 'ceshi', '2026-06-28 23:16:10', '', '2026-06-28 23:16:10'),
	(6, 'PK202607020001', 3, '新客户1', 1, 'SO202607020001', 7, '终测1', 7, '终测门店1', '新客户1 2026-07-02 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-02 23:36:10', '', '2026-07-02 23:36:10'),
	(7, 'PK202607030001', 3, '新客户1', 2, 'SO202607030001', 7, '终测1', 7, '终测门店1', '新客户1 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:00:41', '', '2026-07-03 00:00:41'),
	(8, 'PK202607030002', 3, '新客户1', 3, 'SO202607030002', 7, '终测1', 7, '终测门店1', '新客户1 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:07:05', '', '2026-07-03 00:07:05'),
	(9, 'PK202607030003', 3, '新客户1', 4, 'SO202607030003', 7, '终测1', 7, '终测门店1', '新客户1 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:09:15', '', '2026-07-03 00:09:15'),
	(10, 'PK202607030004', 2, '111', 5, 'SO202607030004', 7, '终测1', 8, '终测门店2', '111 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:09:22', '', '2026-07-03 00:09:22'),
	(11, 'PK202607030005', 2, '111', 6, 'SO202607030005', 7, '终测1', 8, '终测门店2', '111 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:10:41', '', '2026-07-03 00:10:41'),
	(12, 'PK202607030006', 3, '新客户1', 7, 'SO202607030006', 7, '终测1', 7, '终测门店1', '新客户1 2026-07-03 持卡记录', 15180.00, 15180.00, 0.00, '1', NULL, '', 'admin', '2026-07-03 00:10:47', '', '2026-07-03 00:10:47');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='员工配置表';

-- 正在导出表  fuchenpro.biz_employee_config 的数据：~5 rows (大约)
DELETE FROM `biz_employee_config`;
/*!40000 ALTER TABLE `biz_employee_config` DISABLE KEYS */;
INSERT INTO `biz_employee_config` (`config_id`, `user_id`, `user_name`, `post_id`, `post_name`, `dept_id`, `dept_name`, `is_schedulable`, `rest_dates`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, 'admin', 1, '董事长', 103, '研发部门', '1', '["2026-05-31","2026-05-30"]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-05-11 21:32:16'),
	(2, 2, 'ry', NULL, NULL, 105, '测试部门', '1', '["2026-06-08","2026-06-09"]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-06-08 22:54:08'),
	(3, 100, '测试', 4, '普通员工', 101, '深圳总公司', '1', '["2026-05-09","2026-05-21","2026-06-03","2026-05-15"]', '0', NULL, 'admin', '2026-04-28 17:48:51', '', '2026-05-01 14:22:07'),
	(4, 102, 'ceshi1', 2, '项目经理', 103, '研发部门', '1', '["2026-07-01"]', '0', NULL, '', '2026-06-03 00:32:03', '', '2026-06-27 23:06:55'),
	(5, 103, '鹏鹏', 2, '项目经理', 101, '赛诺·森品牌', '1', '["2026-06-20","2026-06-23","2026-06-24"]', '0', NULL, '', '2026-06-08 22:53:57', '', '2026-06-20 18:18:03');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='企业管理表';

-- 正在导出表  fuchenpro.biz_enterprise 的数据：~7 rows (大约)
DELETE FROM `biz_enterprise`;
/*!40000 ALTER TABLE `biz_enterprise` DISABLE KEYS */;
INSERT INTO `biz_enterprise` (`enterprise_id`, `enterprise_name`, `pinyin`, `boss_name`, `phone`, `address`, `enterprise_type`, `store_count`, `annual_performance`, `enterprise_level`, `server_user_id`, `server_user_name`, `cooperation_start_date`, `cooperation_end_date`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '馥田诗', '', '汪志', '15888888888', '陆家浜路1396号', '2', 2, 2000.00, '1', NULL, '吴总', '2026-05-06', '2028-05-05', '0', NULL, 'admin', '2026-04-27 23:38:35', 'admin', '2026-05-16 20:14:41'),
	(2, '逆龄奢', '', '木总', '13588888888', '发顺丰第四范式', '2', 2, 500.00, '2', NULL, '李总', '2026-05-06', '2027-05-06', '0', '防守打法收到', 'admin', '2026-05-02 18:20:18', 'admin', '2026-05-06 19:09:28'),
	(4, '企业1', 'Y1', '汪老板', '15555555555', '法国德国电饭锅电饭锅代发给对方大概给对方', '3', 5, 5000.00, '2', NULL, NULL, NULL, NULL, '0', '41', 'admin', '2026-05-26 14:13:27', '', '2026-05-26 14:13:27'),
	(5, '测试3', '3', '哈哈', '16666666666', '急急急', '1', 0, 0.00, '2', NULL, NULL, NULL, NULL, '0', NULL, 'admin', '2026-05-29 17:09:35', 'admin', '2026-06-08 22:44:42'),
	(6, '测试4', '4', '测试', '15555555555', NULL, '1', 0, 0.00, '2', 2, '若人头', '2026-06-09', '2028-06-01', '0', '地方', 'admin', '2026-06-09 14:11:29', '', '2026-06-09 14:11:29'),
	(7, '终测1', '1', '11', '15555555555', '烦都烦死', '1', 5, 500.00, '1', NULL, NULL, NULL, NULL, '0', NULL, 'admin', '2026-06-19 16:04:08', 'admin', '2026-06-20 18:16:54'),
	(8, '终测2', '2', '老板', '15666666666', NULL, '1', 0, 0.00, '3', 1, '若依、若人头', NULL, NULL, '0', NULL, 'admin', '2026-06-21 11:19:25', 'admin', '2026-06-27 23:02:13'),
	(9, '啊啊啊', 'AAA', '啊啊', '13333333333', NULL, '1', 3, 0.00, '3', NULL, NULL, NULL, NULL, '0', NULL, 'admin', '2026-07-01 09:19:28', 'admin', '2026-07-01 23:43:51');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='问题反馈表';

-- 正在导出表  fuchenpro.biz_feedback 的数据：~2 rows (大约)
DELETE FROM `biz_feedback`;
/*!40000 ALTER TABLE `biz_feedback` DISABLE KEYS */;
INSERT INTO `biz_feedback` (`feedback_id`, `title`, `content`, `feedback_type`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '房间号富家大室就发货', '鬼地方个多喝点风蚀高地司法过广东佛山公司', '0', '1', 'admin', '2026-05-30 14:01:47', 'admin', '2026-05-30 14:02:29'),
	(2, '测试', '防守打法施工分公司答复是打发谁', '0', '0', 'admin', '2026-06-21 14:11:56', '', '2026-06-21 14:11:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='反馈回复表';

-- 正在导出表  fuchenpro.biz_feedback_reply 的数据：~3 rows (大约)
DELETE FROM `biz_feedback_reply`;
/*!40000 ALTER TABLE `biz_feedback_reply` DISABLE KEYS */;
INSERT INTO `biz_feedback_reply` (`reply_id`, `feedback_id`, `content`, `create_by`, `create_time`) VALUES
	(1, 1, '法国电饭锅地方', 'admin', '2026-05-30 14:02:29'),
	(2, 2, '放松放松东方闪电', 'admin', '2026-06-21 14:12:12'),
	(3, 2, '服务费第三方', 'admin', '2026-06-21 14:12:17');
/*!40000 ALTER TABLE `biz_feedback_reply` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_inventory 结构
DROP TABLE IF EXISTS `biz_inventory`;
CREATE TABLE IF NOT EXISTS `biz_inventory` (
  `inventory_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '库存ID',
  `warehouse_id` bigint(20) NOT NULL DEFAULT '1' COMMENT '仓库ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '当前库存数量',
  `earliest_expiry` date DEFAULT NULL COMMENT '最早批次有效期至',
  `warn_qty` int(11) DEFAULT '0' COMMENT '预警数量',
  `last_stock_in_time` datetime DEFAULT NULL COMMENT '最后入库时间',
  `last_stock_out_time` datetime DEFAULT NULL COMMENT '最后出库时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uk_product_warehouse` (`product_id`,`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存表';

-- 正在导出表  fuchenpro.biz_inventory 的数据：~4 rows (大约)
DELETE FROM `biz_inventory`;
/*!40000 ALTER TABLE `biz_inventory` DISABLE KEYS */;
INSERT INTO `biz_inventory` (`inventory_id`, `warehouse_id`, `product_id`, `quantity`, `earliest_expiry`, `warn_qty`, `last_stock_in_time`, `last_stock_out_time`, `create_time`, `update_time`) VALUES
	(1, 2, 3, 100, '2026-07-04', 0, '2026-07-02 23:00:21', NULL, '2026-07-02 23:00:21', '2026-07-02 23:00:21'),
	(2, 2, 2, 100, '2026-07-04', 20, '2026-07-02 23:00:21', NULL, '2026-07-02 23:00:21', '2026-07-02 23:00:21'),
	(3, 2, 1, 100, '2026-07-04', 50, '2026-07-02 23:00:21', NULL, '2026-07-02 23:00:21', '2026-07-02 23:00:21'),
	(4, 1, 2, 90, '2026-07-04', 20, '2026-07-03 00:31:30', '2026-07-03 00:31:37', '2026-07-03 00:31:30', '2026-07-03 00:31:37'),
	(5, 1, 3, 90, '2026-07-04', 0, '2026-07-03 00:31:30', '2026-07-03 00:31:37', '2026-07-03 00:31:30', '2026-07-03 00:31:37'),
	(6, 1, 1, 90, '2026-07-04', 50, '2026-07-03 00:31:30', '2026-07-03 00:31:37', '2026-07-03 00:31:30', '2026-07-03 00:31:37');
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
  KEY `idx_operation_batch_id` (`operation_batch_id`),
  KEY `idx_operator_user_id` (`operator_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作记录表';

-- 正在导出表  fuchenpro.biz_operation_record 的数据：~2 rows (大约)
DELETE FROM `biz_operation_record`;
/*!40000 ALTER TABLE `biz_operation_record` DISABLE KEYS */;
INSERT INTO `biz_operation_record` (`record_id`, `operation_type`, `customer_id`, `customer_name`, `package_id`, `package_no`, `operation_batch_id`, `package_item_id`, `product_name`, `operation_quantity`, `consume_amount`, `trial_price`, `customer_feedback`, `satisfaction`, `before_photo`, `after_photo`, `operator_user_id`, `operator_user_name`, `operation_date`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `remark`, `create_by`, `create_time`) VALUES
	(1, '0', 1, '客户1', 1, NULL, 'OB202606201916597727', 1, '卡项1', 1, 938.00, NULL, '防守打法水电费第三方', 4, '/profile/upload/20260620/0996e45411a292d11f0d65c75d4b9ac7.jpg', '', 1, '若依', '2026-06-20', 7, NULL, 8, NULL, '放大发的', 'admin', '2026-06-20 19:16:59'),
	(2, '0', 1, '客户1', 1, NULL, 'OB202606270613247312', 1, '卡项1', 1, 938.00, NULL, '', 5, '', '', 1, '若依', '2026-06-26', 7, NULL, 8, NULL, '', 'admin', '2026-06-27 06:13:24');
/*!40000 ALTER TABLE `biz_operation_record` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_order_item 结构
DROP TABLE IF EXISTS `biz_order_item`;
CREATE TABLE IF NOT EXISTS `biz_order_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `card_item_id` bigint(20) DEFAULT NULL COMMENT '卡项ID',
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
  KEY `idx_order_id` (`order_id`),
  KEY `idx_card_item_id` (`card_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';

-- 正在导出表  fuchenpro.biz_order_item 的数据：~7 rows (大约)
DELETE FROM `biz_order_item`;
/*!40000 ALTER TABLE `biz_order_item` DISABLE KEYS */;
INSERT INTO `biz_order_item` (`item_id`, `order_id`, `card_item_id`, `product_name`, `quantity`, `deal_amount`, `paid_amount`, `unit_price`, `owed_amount`, `payment_method`, `is_our_operation`, `customer_feedback`, `before_photo`, `after_photo`, `remark`, `create_time`) VALUES
	(1, 1, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-02 23:36:10'),
	(2, 2, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'card', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:00:41'),
	(3, 3, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:07:05'),
	(4, 4, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:09:15'),
	(5, 5, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:09:22'),
	(6, 6, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:10:41'),
	(7, 7, 1, '卡项1', 10, 15180.00, 15180.00, 1518.00, 0.00, 'cash', 1, NULL, NULL, NULL, NULL, '2026-07-03 00:10:47');
/*!40000 ALTER TABLE `biz_order_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_package_item 结构
DROP TABLE IF EXISTS `biz_package_item`;
CREATE TABLE IF NOT EXISTS `biz_package_item` (
  `package_item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '套餐明细ID',
  `package_id` bigint(20) NOT NULL COMMENT '套餐ID',
  `card_item_id` bigint(20) DEFAULT NULL COMMENT '卡项ID',
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
  KEY `idx_package_id` (`package_id`),
  KEY `idx_card_item_id` (`card_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='套餐明细表';

-- 正在导出表  fuchenpro.biz_package_item 的数据：~5 rows (大约)
DELETE FROM `biz_package_item`;
/*!40000 ALTER TABLE `biz_package_item` DISABLE KEYS */;
INSERT INTO `biz_package_item` (`package_item_id`, `package_id`, `card_item_id`, `product_name`, `unit_price`, `plan_price`, `deal_price`, `paid_amount`, `owed_amount`, `total_quantity`, `used_quantity`, `remaining_quantity`, `remark`) VALUES
	(1, 1, 1, '卡项1', 938.00, 9380.00, 9380.00, 9380.00, 0.00, 10, 2, 8, NULL),
	(2, 2, 1, '卡项1', 938.00, 9380.00, 9380.00, 9380.00, 0.00, 10, 0, 10, NULL),
	(3, 3, 1, '卡项1', 938.00, 9380.00, 9380.00, 9380.00, 0.00, 10, 0, 10, NULL),
	(4, 4, 1, '卡项1', 938.00, 9380.00, 9380.00, 9380.00, 0.00, 10, 0, 10, NULL),
	(5, 5, 1, '卡项1', 938.00, 9380.00, 9380.00, 9380.00, 0.00, 10, 0, 10, NULL),
	(6, 6, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(7, 7, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(8, 8, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(9, 9, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(10, 10, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(11, 11, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL),
	(12, 12, 1, '卡项1', 1518.00, 15180.00, 15180.00, 15180.00, 0.00, 10, 0, 10, NULL);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='方案表';

-- 正在导出表  fuchenpro.biz_plan 的数据：~0 rows (大约)
DELETE FROM `biz_plan`;
/*!40000 ALTER TABLE `biz_plan` DISABLE KEYS */;
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
  `prepared_quantity` int(11) NOT NULL DEFAULT '0',
  `remaining_quantity` int(11) DEFAULT '0' COMMENT '剩余数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='方案配赠明细表';

-- 正在导出表  fuchenpro.biz_plan_item 的数据：~0 rows (大约)
DELETE FROM `biz_plan_item`;
/*!40000 ALTER TABLE `biz_plan_item` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='货品表';

-- 正在导出表  fuchenpro.biz_product 的数据：~2 rows (大约)
DELETE FROM `biz_product`;
/*!40000 ALTER TABLE `biz_product` DISABLE KEYS */;
INSERT INTO `biz_product` (`product_id`, `product_name`, `product_code`, `supplier_id`, `spec`, `pack_qty`, `category`, `unit`, `purchase_price`, `sale_price`, `sale_price_spec`, `shelf_life_days`, `has_expiry`, `warn_qty`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'GCS-p7', 'gcs-p7', 1, '1', 10, '3', '5', 2580.00, 2580.00, 258.00, 365, '0', 50, '0', NULL, 'admin', '2026-04-29 15:10:14', 'admin', '2026-06-26 02:26:54'),
	(2, '测试1', 'CS1-20260504', 1, '1', 10, '1', '5', 6800.00, 6800.00, 680.00, NULL, '0', 20, '0', NULL, 'admin', '2026-05-05 00:11:54', 'admin', '2026-06-26 22:29:23'),
	(3, '身体套盒', 'STTH-20260629', 1, '1', 10, '1', '5', 5800.00, 5800.00, 580.00, NULL, '0', 0, '0', NULL, 'pengpeng', '2026-06-30 00:01:09', '', '2026-06-30 00:01:09');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='还款记录表';

-- 正在导出表  fuchenpro.biz_repayment_record 的数据：~0 rows (大约)
DELETE FROM `biz_repayment_record`;
/*!40000 ALTER TABLE `biz_repayment_record` DISABLE KEYS */;
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
  KEY `idx_order_status` (`order_status`),
  KEY `idx_creator_user_id` (`creator_user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售订单表';

-- 正在导出表  fuchenpro.biz_sales_order 的数据：~7 rows (大约)
DELETE FROM `biz_sales_order`;
/*!40000 ALTER TABLE `biz_sales_order` DISABLE KEYS */;
INSERT INTO `biz_sales_order` (`order_id`, `order_no`, `customer_id`, `customer_name`, `enterprise_id`, `enterprise_name`, `store_id`, `store_name`, `store_dealer`, `deal_amount`, `paid_amount`, `owed_amount`, `payment_method`, `order_status`, `source_type`, `operation_batch_id`, `package_name`, `enterprise_audit_status`, `finance_audit_status`, `enterprise_audit_by`, `enterprise_audit_time`, `finance_audit_by`, `finance_audit_time`, `creator_user_id`, `creator_user_name`, `remark`, `customer_feedback`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'SO202607020001', 3, '新客户1', 7, '终测1', 7, '终测门店1', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-02 23:36:23', '超级管理员', '2026-07-02 23:36:36', 1, '超级管理员', '', '', 'admin', '2026-07-02 23:36:10', '', '2026-07-02 23:36:36'),
	(2, 'SO202607030001', 3, '新客户1', 7, '终测1', 7, '终测门店1', '', 15180.00, 15180.00, 0.00, 'card', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:01:59', '超级管理员', '2026-07-03 00:02:50', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:00:41', '', '2026-07-03 00:02:50'),
	(3, 'SO202607030002', 3, '新客户1', 7, '终测1', 7, '终测门店1', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:07:11', '超级管理员', '2026-07-03 00:07:12', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:07:05', '', '2026-07-03 00:07:12'),
	(4, 'SO202607030003', 3, '新客户1', 7, '终测1', 7, '终测门店1', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:09:40', '超级管理员', '2026-07-03 00:09:53', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:09:15', '', '2026-07-03 00:09:53'),
	(5, 'SO202607030004', 2, '111', 7, '终测1', 8, '终测门店2', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:09:38', '超级管理员', '2026-07-03 00:09:52', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:09:22', '', '2026-07-03 00:09:52'),
	(6, 'SO202607030005', 2, '111', 7, '终测1', 8, '终测门店2', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:10:54', '超级管理员', '2026-07-03 00:10:56', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:10:41', '', '2026-07-03 00:10:56'),
	(7, 'SO202607030006', 3, '新客户1', 7, '终测1', 7, '终测门店1', '', 15180.00, 15180.00, 0.00, 'cash', '2', '0', NULL, '', '1', '1', '超级管理员', '2026-07-03 00:10:52', '超级管理员', '2026-07-03 00:10:55', 1, '超级管理员', '', '', 'admin', '2026-07-03 00:10:47', '', '2026-07-03 00:10:55');
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
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='行程安排表';

-- 正在导出表  fuchenpro.biz_schedule 的数据：~11 rows (大约)
DELETE FROM `biz_schedule`;
/*!40000 ALTER TABLE `biz_schedule` DISABLE KEYS */;
INSERT INTO `biz_schedule` (`schedule_id`, `user_id`, `user_name`, `enterprise_id`, `enterprise_name`, `schedule_date`, `purpose`, `remark`, `status`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(35, 103, '鹏鹏', 7, '终测1', '2026-06-27', '2', '', '1', 'admin', '2026-06-26 23:02:28', 'pengpeng', '2026-06-28 21:56:09'),
	(37, 103, '鹏鹏', 7, '终测1', '2026-06-28', '2', '', '1', 'admin', '2026-06-26 23:12:18', 'pengpeng', '2026-06-28 21:56:09'),
	(43, 103, '鹏鹏', 7, '终测1', '2026-06-29', '2', '', '1', 'admin', '2026-06-27 23:44:30', 'pengpeng', '2026-06-28 21:56:09'),
	(44, 103, '鹏鹏', 7, '终测1', '2026-06-30', '2', '', '1', 'admin', '2026-06-27 23:44:30', 'pengpeng', '2026-06-28 21:56:09'),
	(51, 100, '测试', 7, '终测1', '2026-06-27', '1', '', '1', 'admin', '2026-06-27 23:46:12', '', '2026-06-27 23:46:12'),
	(52, 100, '测试', 7, '终测1', '2026-06-28', '1', '', '1', 'admin', '2026-06-27 23:46:12', '', '2026-06-27 23:46:12'),
	(53, 100, '测试', 7, '终测1', '2026-06-29', '1', '', '1', 'admin', '2026-06-27 23:46:12', '', '2026-06-27 23:46:12'),
	(54, 100, '测试', 7, '终测1', '2026-06-30', '1', '', '1', 'admin', '2026-06-27 23:46:12', '', '2026-06-27 23:46:12'),
	(55, 102, 'ceshi1', 7, '终测1', '2026-06-29', '1', '', '1', 'admin', '2026-06-27 23:55:17', '', '2026-06-27 23:55:17'),
	(56, 102, 'ceshi1', 7, '终测1', '2026-06-30', '1', '', '1', 'admin', '2026-06-27 23:55:17', '', '2026-06-27 23:55:17'),
	(57, 103, '鹏鹏', 7, '终测1', '2026-07-01', '2', '', '1', 'pengpeng', '2026-06-28 21:56:09', '', '2026-06-28 21:56:09');
/*!40000 ALTER TABLE `biz_schedule` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_check 结构
DROP TABLE IF EXISTS `biz_stock_check`;
CREATE TABLE IF NOT EXISTS `biz_stock_check` (
  `stock_check_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '盘点单ID',
  `stock_check_no` varchar(30) NOT NULL COMMENT '盘点单号',
  `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='盘点单主表';

-- 正在导出表  fuchenpro.biz_stock_check 的数据：~4 rows (大约)
DELETE FROM `biz_stock_check`;
/*!40000 ALTER TABLE `biz_stock_check` DISABLE KEYS */;
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
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `original_quantity` int(11) DEFAULT NULL COMMENT '原始数量(换算前)',
  `system_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '系统库存数量',
  `actual_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '实际盘点数量',
  `diff_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '差异数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date DEFAULT NULL COMMENT '到期日期',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_check_id` (`stock_check_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='盘点单明细表';

-- 正在导出表  fuchenpro.biz_stock_check_item 的数据：~12 rows (大约)
DELETE FROM `biz_stock_check_item`;
/*!40000 ALTER TABLE `biz_stock_check_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_stock_check_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_in 结构
DROP TABLE IF EXISTS `biz_stock_in`;
CREATE TABLE IF NOT EXISTS `biz_stock_in` (
  `stock_in_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '入库单ID',
  `stock_in_no` varchar(30) NOT NULL COMMENT '入库单号',
  `stock_in_type` char(1) NOT NULL DEFAULT '1' COMMENT '入库类型(1采购入库 2退货入库 3其他入库)',
  `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID',
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
  KEY `idx_status` (`status`),
  KEY `idx_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='入库单主表';

-- 正在导出表  fuchenpro.biz_stock_in 的数据：~5 rows (大约)
DELETE FROM `biz_stock_in`;
/*!40000 ALTER TABLE `biz_stock_in` DISABLE KEYS */;
INSERT INTO `biz_stock_in` (`stock_in_id`, `stock_in_no`, `stock_in_type`, `warehouse_id`, `total_quantity`, `total_amount`, `stock_in_date`, `operator_id`, `operator_name`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'RK20260702001', '1', 2, 300, 151800.00, '2026-07-02', 1, '超级管理员', '1', NULL, '超级管理员', '2026-07-02 23:00:18', '', '2026-07-02 23:00:21'),
	(2, 'RK20260703001', '1', 1, 300, 151800.00, '2026-07-02', 1, '超级管理员', '1', NULL, '超级管理员', '2026-07-03 00:31:21', '', '2026-07-03 00:31:30');
/*!40000 ALTER TABLE `biz_stock_in` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_in_item 结构
DROP TABLE IF EXISTS `biz_stock_in_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_in_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `stock_in_id` bigint(20) NOT NULL COMMENT '入库单ID',
  `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID',
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
  `shipped_quantity` decimal(10,2) DEFAULT '0.00' COMMENT '已出库数量',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_in_id` (`stock_in_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_wh_product_expiry` (`warehouse_id`,`product_id`,`expiry_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='入库单明细表';

-- 正在导出表  fuchenpro.biz_stock_in_item 的数据：~5 rows (大约)
DELETE FROM `biz_stock_in_item`;
/*!40000 ALTER TABLE `biz_stock_in_item` DISABLE KEYS */;
INSERT INTO `biz_stock_in_item` (`item_id`, `stock_in_id`, `warehouse_id`, `product_id`, `product_name`, `supplier_id`, `supplier_name`, `spec`, `unit`, `pack_qty`, `unit_type`, `original_quantity`, `quantity`, `purchase_price`, `amount`, `remark`, `production_date`, `expiry_date`, `shipped_quantity`) VALUES
	(1, 1, 2, 3, '身体套盒', 1, '供货商1', '1', '5', 10, '1', 10, 100, 580.00, 58000.00, NULL, '2026-07-01', '2026-07-04', 0.00),
	(2, 1, 2, 2, '测试1', 1, '供货商1', '1', '5', 10, '1', 10, 100, 680.00, 68000.00, NULL, '2026-07-01', '2026-07-04', 0.00),
	(3, 1, 2, 1, 'GCS-p7', 1, '供货商1', '1', '5', 10, '1', 10, 100, 258.00, 25800.00, NULL, '2026-07-01', '2026-07-04', 0.00),
	(4, 2, 1, 2, '测试1', 1, '供货商1', '1', '5', 10, '1', 10, 100, 680.00, 68000.00, NULL, '2026-07-01', '2026-07-04', 10.00),
	(5, 2, 1, 3, '身体套盒', 1, '供货商1', '1', '5', 10, '1', 10, 100, 580.00, 58000.00, NULL, '2026-07-01', '2026-07-04', 10.00),
	(6, 2, 1, 1, 'GCS-p7', 1, '供货商1', '1', '5', 10, '1', 10, 100, 258.00, 25800.00, NULL, '2026-07-01', '2026-07-04', 10.00);
/*!40000 ALTER TABLE `biz_stock_in_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_out 结构
DROP TABLE IF EXISTS `biz_stock_out`;
CREATE TABLE IF NOT EXISTS `biz_stock_out` (
  `stock_out_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '出库单ID',
  `stock_out_no` varchar(30) NOT NULL COMMENT '出库单号',
  `stock_out_type` char(1) NOT NULL DEFAULT '1' COMMENT '出库类型(1销售出库 2调拨出库 3其他出库)',
  `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID',
  `out_target_type` varchar(1) NOT NULL DEFAULT '1' COMMENT '出库对象类型（1-企业出库 2-员工领用）',
  `prepare_id` bigint(20) DEFAULT NULL COMMENT '来源备货ID',
  `plan_id` bigint(20) DEFAULT NULL COMMENT '关联方案ID',
  `enterprise_id` bigint(20) DEFAULT NULL COMMENT '出库企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '出库企业名称',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '收货人',
  `contact_phone` varchar(50) DEFAULT NULL COMMENT '收货电话',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `logistics_company` varchar(100) DEFAULT NULL COMMENT '物流公司',
  `logistics_no` varchar(100) DEFAULT NULL COMMENT '物流单号',
  `shipment_date` datetime DEFAULT NULL COMMENT '发货日期',
  `receipt_date` datetime DEFAULT NULL COMMENT '收货日期',
  `shipment_images` text COMMENT '发货图片(JSON数组)',
  `audit_by` varchar(50) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `contact_employee_id` int(11) DEFAULT NULL COMMENT '对接员工ID',
  `contact_employee_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对接员工姓名',
  `responsible_id` bigint(20) DEFAULT NULL COMMENT '负责员工ID',
  `responsible_name` varchar(50) DEFAULT NULL COMMENT '负责员工姓名',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额',
  `stock_out_date` date DEFAULT NULL COMMENT '出库日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认)',
  `ship_type` tinyint(4) DEFAULT '0' COMMENT '发货方式(0无需发货/1自提/2物流)',
  `ship_status` tinyint(4) DEFAULT '0' COMMENT '发货状态(0待发货/1已发货/2已收货)',
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
  KEY `idx_status` (`status`),
  KEY `idx_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出库单主表';

-- 正在导出表  fuchenpro.biz_stock_out 的数据：~7 rows (大约)
DELETE FROM `biz_stock_out`;
/*!40000 ALTER TABLE `biz_stock_out` DISABLE KEYS */;
INSERT INTO `biz_stock_out` (`stock_out_id`, `stock_out_no`, `stock_out_type`, `warehouse_id`, `out_target_type`, `prepare_id`, `plan_id`, `enterprise_id`, `enterprise_name`, `contact_person`, `contact_phone`, `shipping_address`, `logistics_company`, `logistics_no`, `shipment_date`, `receipt_date`, `shipment_images`, `audit_by`, `audit_time`, `contact_employee_id`, `contact_employee_name`, `responsible_id`, `responsible_name`, `total_quantity`, `total_amount`, `stock_out_date`, `status`, `ship_type`, `ship_status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'CK20260702001', '1', 1, '1', 1, NULL, 7, '终测1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '超级管理员', 30, 15180.00, '2026-07-02', '0', 2, 0, NULL, 'admin', '2026-07-02 23:58:53', '', '2026-07-02 23:58:53'),
	(2, 'CK20260703001', '1', 1, '1', 7, NULL, 7, '终测1', NULL, NULL, NULL, 'shunfeng', '111', '2026-07-03 00:31:44', '2026-07-03 00:31:47', NULL, NULL, NULL, NULL, '-', 1, '超级管理员', 30, 15180.00, '2026-07-03', '3', 2, 2, NULL, 'admin', '2026-07-03 00:29:48', 'admin', '2026-07-03 00:31:47'),
	(3, 'CK20260703002', '1', 2, '1', 6, NULL, 7, '终测1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 103, '鹏鹏', 30, 15180.00, '2026-07-03', '0', 2, 0, NULL, 'admin', '2026-07-03 01:12:24', '', '2026-07-03 01:12:24');
/*!40000 ALTER TABLE `biz_stock_out` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_out_item 结构
DROP TABLE IF EXISTS `biz_stock_out_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_out_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `stock_out_id` bigint(20) NOT NULL COMMENT '出库单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `plan_item_id` bigint(20) DEFAULT NULL COMMENT '关联方案明细ID',
  `supplier_id` bigint(20) DEFAULT NULL COMMENT '供货商ID',
  `supplier_name` varchar(100) DEFAULT NULL COMMENT '供货商名称',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `spec` varchar(100) DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `original_quantity` int(11) DEFAULT NULL COMMENT '原始数量(换算前)',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '出库数量',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '出货单价',
  `discount_price` decimal(10,2) DEFAULT NULL COMMENT '折扣单价',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_stock_out_id` (`stock_out_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出库单明细表';

-- 正在导出表  fuchenpro.biz_stock_out_item 的数据：~9 rows (大约)
DELETE FROM `biz_stock_out_item`;
/*!40000 ALTER TABLE `biz_stock_out_item` DISABLE KEYS */;
INSERT INTO `biz_stock_out_item` (`item_id`, `stock_out_id`, `product_id`, `plan_item_id`, `supplier_id`, `supplier_name`, `product_name`, `spec`, `unit`, `pack_qty`, `unit_type`, `original_quantity`, `quantity`, `sale_price`, `discount_price`, `amount`, `remark`) VALUES
	(1, 1, 1, NULL, NULL, NULL, 'GCS-p7', '1', '5', 10, '1', 1, 10, 258.00, NULL, 2580.00, NULL),
	(2, 1, 2, NULL, NULL, NULL, '测试1', '1', '5', 10, '1', 1, 10, 680.00, NULL, 6800.00, NULL),
	(3, 1, 3, NULL, NULL, NULL, '身体套盒', '1', '5', 10, '1', 1, 10, 580.00, NULL, 5800.00, NULL),
	(7, 2, 1, NULL, NULL, NULL, 'GCS-p7', '1', '5', 10, '1', 1, 10, 258.00, NULL, 2580.00, NULL),
	(8, 2, 2, NULL, NULL, NULL, '测试1', '1', '5', 10, '1', 1, 10, 680.00, NULL, 6800.00, NULL),
	(9, 2, 3, NULL, NULL, NULL, '身体套盒', '1', '5', 10, '1', 1, 10, 580.00, NULL, 5800.00, NULL),
	(10, 3, 1, NULL, NULL, NULL, 'GCS-p7', '1', '5', 10, '1', 1, 10, 258.00, NULL, 2580.00, NULL),
	(11, 3, 2, NULL, NULL, NULL, '测试1', '1', '5', 10, '1', 1, 10, 680.00, NULL, 6800.00, NULL),
	(12, 3, 3, NULL, NULL, NULL, '身体套盒', '1', '5', 10, '1', 1, 10, 580.00, NULL, 5800.00, NULL);
/*!40000 ALTER TABLE `biz_stock_out_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_prepare 结构
DROP TABLE IF EXISTS `biz_stock_prepare`;
CREATE TABLE IF NOT EXISTS `biz_stock_prepare` (
  `prepare_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '备货ID',
  `prepare_no` varchar(30) NOT NULL COMMENT '备货编号(SP+日期+4位序号)',
  `plan_id` bigint(20) unsigned DEFAULT NULL,
  `plan_no` varchar(30) DEFAULT NULL COMMENT '关联方案编号',
  `order_id` bigint(20) DEFAULT NULL COMMENT '来源订单ID',
  `order_no` varchar(30) DEFAULT NULL COMMENT '来源订单编号',
  `customer_id` bigint(20) DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `enterprise_id` bigint(20) NOT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量(最小单位)',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '总金额',
  `shipped_quantity` int(11) DEFAULT '0' COMMENT '已出库数量',
  `shipped_amount` decimal(12,2) DEFAULT '0.00' COMMENT '已出库金额',
  `remaining_quantity` int(11) DEFAULT '0' COMMENT '剩余待出数量',
  `remaining_amount` decimal(12,2) DEFAULT '0.00' COMMENT '剩余待出金额',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待备货 1部分出库 2已出完 3已取消)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `creator_user_id` bigint(20) DEFAULT NULL COMMENT '创建人用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`prepare_id`),
  UNIQUE KEY `uk_prepare_no` (`prepare_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_store_id` (`store_id`),
  KEY `idx_status` (`status`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货表';

-- 正在导出表  fuchenpro.biz_stock_prepare 的数据：~15 rows (大约)
DELETE FROM `biz_stock_prepare`;
/*!40000 ALTER TABLE `biz_stock_prepare` DISABLE KEYS */;
INSERT INTO `biz_stock_prepare` (`prepare_id`, `prepare_no`, `plan_id`, `plan_no`, `order_id`, `order_no`, `customer_id`, `customer_name`, `enterprise_id`, `enterprise_name`, `warehouse_id`, `store_id`, `store_name`, `total_quantity`, `total_amount`, `shipped_quantity`, `shipped_amount`, `remaining_quantity`, `remaining_amount`, `status`, `remark`, `create_by`, `creator_user_id`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'SP202607020002', NULL, NULL, 1, 'SO202607020001', 3, '新客户1', 7, '终测1', NULL, 7, '终测门店1', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-02 23:36:46', '', '2026-07-02 23:36:46'),
	(2, 'SP202607030001', NULL, NULL, 3, 'SO202607030002', 3, '新客户1', 7, '终测1', NULL, 7, '终测门店1', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-03 00:07:39', '', '2026-07-03 00:07:39'),
	(3, 'SP202607030002', NULL, NULL, 2, 'SO202607030001', 3, '新客户1', 7, '终测1', NULL, 7, '终测门店1', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-03 00:07:40', '', '2026-07-03 00:07:40'),
	(4, 'SP202607030003', NULL, NULL, 5, 'SO202607030004', 2, '111', 7, '终测1', NULL, 8, '终测门店2', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-03 00:10:10', '', '2026-07-03 00:10:10'),
	(5, 'SP202607030004', NULL, NULL, 4, 'SO202607030003', 3, '新客户1', 7, '终测1', NULL, 7, '终测门店1', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-03 00:10:10', '', '2026-07-03 00:10:10'),
	(6, 'SP202607030005', NULL, NULL, 6, 'SO202607030005', 2, '111', 7, '终测1', NULL, 8, '终测门店2', 30, 15180.00, 0, 0.00, 30, 15180.00, '0', NULL, 'admin', NULL, '2026-07-03 00:11:09', '', '2026-07-03 00:11:09'),
	(7, 'SP202607030006', NULL, NULL, 7, 'SO202607030006', 3, '新客户1', 7, '终测1', NULL, 7, '终测门店1', 30, 15180.00, 30, 15180.00, 0, 0.00, '2', NULL, 'admin', NULL, '2026-07-03 00:11:09', '', '2026-07-03 00:31:44');
/*!40000 ALTER TABLE `biz_stock_prepare` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_prepare_item 结构
DROP TABLE IF EXISTS `biz_stock_prepare_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_prepare_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `prepare_id` bigint(20) NOT NULL COMMENT '备货ID',
  `plan_item_id` bigint(20) unsigned DEFAULT NULL,
  `card_item_id` bigint(20) DEFAULT NULL COMMENT '卡项ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) NOT NULL COMMENT '货品名称',
  `unit` varchar(20) DEFAULT NULL COMMENT '主单位',
  `spec` varchar(100) DEFAULT NULL COMMENT '副单位/规格',
  `unit_type` char(1) NOT NULL DEFAULT '1' COMMENT '单位类型(1主单位-整 2副单位-拆)',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '出货价',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '数量(最小单位)',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `shipped_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '已出库数量',
  `shipped_amount` decimal(12,2) DEFAULT '0.00' COMMENT '已出库金额',
  `remaining_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '剩余待出数量',
  `remaining_amount` decimal(12,2) DEFAULT '0.00' COMMENT '剩余待出金额',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_prepare_id` (`prepare_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_plan_item_id` (`plan_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货明细表';

-- 正在导出表  fuchenpro.biz_stock_prepare_item 的数据：~14 rows (大约)
DELETE FROM `biz_stock_prepare_item`;
/*!40000 ALTER TABLE `biz_stock_prepare_item` DISABLE KEYS */;
INSERT INTO `biz_stock_prepare_item` (`item_id`, `prepare_id`, `plan_item_id`, `card_item_id`, `product_id`, `product_name`, `unit`, `spec`, `unit_type`, `pack_qty`, `sale_price`, `quantity`, `amount`, `shipped_quantity`, `shipped_amount`, `remaining_quantity`, `remaining_amount`, `remark`) VALUES
	(1, 1, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 10, 2580.00, 0, 0.00, NULL),
	(2, 1, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 10, 6800.00, 0, 0.00, NULL),
	(3, 1, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 10, 5800.00, 0, 0.00, NULL),
	(4, 2, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 0, 0.00, 10, 2580.00, NULL),
	(5, 2, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 0, 0.00, 10, 6800.00, NULL),
	(6, 2, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 0, 0.00, 10, 5800.00, NULL),
	(7, 3, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 0, 0.00, 10, 2580.00, NULL),
	(8, 3, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 0, 0.00, 10, 6800.00, NULL),
	(9, 3, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 0, 0.00, 10, 5800.00, NULL),
	(10, 4, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 0, 0.00, 10, 2580.00, NULL),
	(11, 4, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 0, 0.00, 10, 6800.00, NULL),
	(12, 4, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 0, 0.00, 10, 5800.00, NULL),
	(13, 5, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 0, 0.00, 10, 2580.00, NULL),
	(14, 5, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 0, 0.00, 10, 6800.00, NULL),
	(15, 5, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 0, 0.00, 10, 5800.00, NULL),
	(16, 6, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 10, 2580.00, 0, 0.00, NULL),
	(17, 6, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 10, 6800.00, 0, 0.00, NULL),
	(18, 6, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 10, 5800.00, 0, 0.00, NULL),
	(19, 7, NULL, NULL, 1, 'GCS-p7', '5', '1', '1', 10, 258.00, 10, 2580.00, 10, 2580.00, 0, 0.00, NULL),
	(20, 7, NULL, NULL, 2, '测试1', '5', '1', '1', 10, 680.00, 10, 6800.00, 10, 6800.00, 0, 0.00, NULL),
	(21, 7, NULL, NULL, 3, '身体套盒', '5', '1', '1', 10, 580.00, 10, 5800.00, 10, 5800.00, 0, 0.00, NULL);
/*!40000 ALTER TABLE `biz_stock_prepare_item` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_prepare_order 结构
DROP TABLE IF EXISTS `biz_stock_prepare_order`;
CREATE TABLE IF NOT EXISTS `biz_stock_prepare_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `prepare_id` bigint(20) NOT NULL COMMENT '备货ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `order_no` varchar(30) DEFAULT NULL COMMENT '订单编号',
  `customer_id` bigint(20) DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  PRIMARY KEY (`id`),
  KEY `idx_prepare_id` (`prepare_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存-订单关联表';

-- 正在导出表  fuchenpro.biz_stock_prepare_order 的数据：~2 rows (大约)
DELETE FROM `biz_stock_prepare_order`;
/*!40000 ALTER TABLE `biz_stock_prepare_order` DISABLE KEYS */;
INSERT INTO `biz_stock_prepare_order` (`id`, `prepare_id`, `order_id`, `order_no`, `customer_id`, `customer_name`, `store_id`, `store_name`) VALUES
	(1, 1, 1, 'SO202607020001', 3, '新客户1', 7, '终测门店1'),
	(2, 2, 3, 'SO202607030002', 3, '新客户1', 7, '终测门店1'),
	(3, 3, 2, 'SO202607030001', 3, '新客户1', 7, '终测门店1'),
	(4, 4, 5, 'SO202607030004', 2, '111', 8, '终测门店2'),
	(5, 5, 4, 'SO202607030003', 3, '新客户1', 7, '终测门店1'),
	(6, 6, 6, 'SO202607030005', 2, '111', 8, '终测门店2'),
	(7, 7, 7, 'SO202607030006', 3, '新客户1', 7, '终测门店1');
/*!40000 ALTER TABLE `biz_stock_prepare_order` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_transfer 结构
DROP TABLE IF EXISTS `biz_stock_transfer`;
CREATE TABLE IF NOT EXISTS `biz_stock_transfer` (
  `transfer_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '调拨ID',
  `transfer_no` varchar(30) NOT NULL COMMENT '调拨单号',
  `from_warehouse_id` bigint(20) NOT NULL COMMENT '源仓库ID',
  `from_warehouse_name` varchar(100) DEFAULT NULL COMMENT '源仓库名称',
  `to_warehouse_id` bigint(20) NOT NULL COMMENT '目标仓库ID',
  `to_warehouse_name` varchar(100) DEFAULT NULL COMMENT '目标仓库名称',
  `total_quantity` int(11) DEFAULT '0' COMMENT '总数量',
  `transfer_date` date DEFAULT NULL COMMENT '调拨日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认 2已取消)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`transfer_id`),
  UNIQUE KEY `uk_transfer_no` (`transfer_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='调拨单主表';

-- 正在导出表  fuchenpro.biz_stock_transfer 的数据：~3 rows (大约)
DELETE FROM `biz_stock_transfer`;
/*!40000 ALTER TABLE `biz_stock_transfer` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_stock_transfer` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_stock_transfer_item 结构
DROP TABLE IF EXISTS `biz_stock_transfer_item`;
CREATE TABLE IF NOT EXISTS `biz_stock_transfer_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `transfer_id` bigint(20) NOT NULL COMMENT '调拨单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `spec` char(1) DEFAULT NULL COMMENT '规格',
  `unit` char(1) DEFAULT NULL COMMENT '单位',
  `pack_qty` int(11) DEFAULT '1' COMMENT '换算比例',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `original_quantity` int(11) DEFAULT '0' COMMENT '原始数量',
  `quantity` int(11) DEFAULT '0' COMMENT '调拨数量(最小单位)',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='调拨单明细表';

-- 正在导出表  fuchenpro.biz_stock_transfer_item 的数据：~4 rows (大约)
DELETE FROM `biz_stock_transfer_item`;
/*!40000 ALTER TABLE `biz_stock_transfer_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_stock_transfer_item` ENABLE KEYS */;

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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门店管理表';

-- 正在导出表  fuchenpro.biz_store 的数据：~11 rows (大约)
DELETE FROM `biz_store`;
/*!40000 ALTER TABLE `biz_store` DISABLE KEYS */;
INSERT INTO `biz_store` (`store_id`, `enterprise_id`, `enterprise_name`, `store_name`, `manager_name`, `phone`, `wechat`, `address`, `business_hours`, `annual_performance`, `regular_customers`, `creator_name`, `server_user_id`, `server_user_name`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 1, '馥田诗', '顺义店', '哈哈哈', '15555555555', 'fdfd', '佛山市对方水电费', '09:00-21:00', 0.00, 0, NULL, 1, '若依', '0', NULL, 'admin', '2026-04-30 18:02:15', '', '2026-04-30 18:02:15'),
	(2, 1, '馥田诗', '肇嘉浜', '发顺丰', '13555555555', 'gfggg', '改单费咕嘟咕嘟', '19:01 - 20:01', 455.00, 111, 'admin', 1, '若依', '0', '111111', 'admin', '2026-04-30 19:05:02', '', '2026-04-30 19:05:02'),
	(3, 2, '逆龄奢', '宜川店', '木总', '1555555555', NULL, '辅导费神鼎飞丹砂', NULL, 0.00, 0, NULL, 1, '若依', '0', NULL, 'admin', '2026-05-02 22:30:37', 'admin', '2026-05-16 20:14:48'),
	(5, 4, '企业1', '哈哈', '133', '1333333333', NULL, '133333', NULL, 0.00, 0, NULL, NULL, NULL, '0', '113333', 'admin', '2026-05-27 21:44:49', '', '2026-05-27 21:44:49'),
	(6, 5, '测试3', '测试门店3', 'dd', '15222222222', 'ddd', 'dddddddd', '2026-6-26 - 2027-6-26', 555.00, 55, NULL, NULL, '滴滴滴', '0', '顶顶顶顶', 'admin', '2026-06-01 22:30:22', 'admin', '2026-06-19 14:12:27'),
	(7, 7, '终测1', '终测门店1', NULL, NULL, NULL, NULL, NULL, 0.00, 0, NULL, 100, '测试、ceshi1', '0', NULL, 'admin', '2026-06-19 16:04:49', 'admin', '2026-06-27 23:03:46'),
	(8, 7, '终测1', '终测门店2', '11', '1522222222', '11', '11', '9 - 21', 500.00, 200, NULL, NULL, '1212', '0', NULL, 'admin', '2026-06-19 20:57:09', 'admin', '2026-06-20 14:33:45'),
	(9, 8, '终测2', '终测2门店1', NULL, NULL, NULL, NULL, NULL, 0.00, 0, '若依', 2, '若人头、测试', '0', NULL, 'admin', '2026-06-21 11:20:16', 'admin', '2026-06-27 23:03:38'),
	(10, 8, '终测2', 'mend2', NULL, NULL, NULL, NULL, NULL, 0.00, 0, '若依', 1, '若依、若人头', '0', NULL, 'admin', '2026-06-21 11:23:56', 'admin', '2026-06-26 23:57:26'),
	(11, 8, '终测2', '测试1', NULL, NULL, NULL, NULL, NULL, 0.00, 0, '若依', 100, '测试、ceshi1', '0', NULL, 'admin', '2026-06-21 12:00:46', 'admin', '2026-06-27 23:03:00'),
	(12, 8, '终测2', '门顶上', '呃呃呃', NULL, '11', NULL, NULL, 0.00, 0, '若依', 103, '鹏鹏、ceshi1', '0', NULL, 'admin', '2026-06-21 12:24:40', 'admin', '2026-06-27 23:04:05'),
	(13, 4, '企业1', '1111', NULL, NULL, NULL, NULL, NULL, 0.00, 0, '超级管理员', NULL, NULL, '0', NULL, 'admin', '2026-07-01 09:19:41', '', '2026-07-01 09:19:41');
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
	(1, '供货商1', '111', NULL, NULL, NULL, '0', NULL, 'admin', '2026-06-26 02:26:44', 'admin', '2026-06-27 06:01:24');
/*!40000 ALTER TABLE `biz_supplier` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_warehouse 结构
DROP TABLE IF EXISTS `biz_warehouse`;
CREATE TABLE IF NOT EXISTS `biz_warehouse` (
  `warehouse_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `warehouse_name` varchar(100) NOT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(30) NOT NULL COMMENT '仓库编码',
  `address` varchar(255) DEFAULT NULL COMMENT '仓库地址',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(50) DEFAULT NULL COMMENT '联系电话',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`warehouse_id`),
  UNIQUE KEY `uk_warehouse_code` (`warehouse_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库表';

-- 正在导出表  fuchenpro.biz_warehouse 的数据：~2 rows (大约)
DELETE FROM `biz_warehouse`;
/*!40000 ALTER TABLE `biz_warehouse` DISABLE KEYS */;
INSERT INTO `biz_warehouse` (`warehouse_id`, `warehouse_name`, `warehouse_code`, `address`, `contact_person`, `contact_phone`, `status`, `remark`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, '上海仓库', 'WH001', '上海市闵行区', 'who', '15111111111', '0', NULL, 'admin', '2026-06-20 20:02:33', '', '2026-06-20 20:02:33'),
	(2, '深圳仓库', 'WH002', '深圳市', 'whoi', '15222222222', '0', NULL, 'admin', '2026-06-20 20:03:13', '', '2026-06-20 20:03:13');
/*!40000 ALTER TABLE `biz_warehouse` ENABLE KEYS */;

-- 导出  表 fuchenpro.biz_warehouse_user 结构
DROP TABLE IF EXISTS `biz_warehouse_user`;
CREATE TABLE IF NOT EXISTS `biz_warehouse_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint(20) NOT NULL COMMENT '仓库ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_user` (`warehouse_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库用户权限表';

-- 正在导出表  fuchenpro.biz_warehouse_user 的数据：~0 rows (大约)
DELETE FROM `biz_warehouse_user`;
/*!40000 ALTER TABLE `biz_warehouse_user` DISABLE KEYS */;
INSERT INTO `biz_warehouse_user` (`id`, `warehouse_id`, `user_id`, `create_time`) VALUES
	(2, 2, 103, '2026-06-29 23:31:50');
/*!40000 ALTER TABLE `biz_warehouse_user` ENABLE KEYS */;

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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报销单表';

-- 正在导出表  fuchenpro.fin_reimbursement 的数据：~15 rows (大约)
DELETE FROM `fin_reimbursement`;
/*!40000 ALTER TABLE `fin_reimbursement` DISABLE KEYS */;
INSERT INTO `fin_reimbursement` (`reimbursement_id`, `reimbursement_no`, `applicant_id`, `applicant_name`, `dept_id`, `dept_name`, `apply_date`, `category`, `income_amount`, `expense_amount`, `expense_type`, `status`, `voucher_images`, `remark`, `audit_by`, `audit_time`, `audit_remark`, `pay_by`, `pay_time`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES
	(1, 'BX202605180001', 1, '', 103, '', NULL, '1', 0.00, 0.00, '1', '0', NULL, '大叔大婶', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 19:58:07', NULL, NULL),
	(2, 'BX202605180002', 1, '', 103, '', NULL, '1', 0.00, 0.00, '1', '0', NULL, '大叔大婶', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 22:40:01', NULL, NULL),
	(3, 'BX202605180003', 1, '', 103, '', '2026-05-18', '1', 0.00, 598.00, '1', '0', '["blob:http://192.168.2.74:8088/8525e9f0-ea3b-4255-b5af-29c56346fadb"]', '222', NULL, NULL, NULL, NULL, NULL, '', '2026-05-18 23:00:38', '', '2026-05-19 13:40:45'),
	(4, 'BX202605180004', 1, '', 103, '', '2026-05-18', '2', 0.00, 980.00, '1', '1', '[]', '电风扇', '若依', '2026-06-26 07:19:23', '', NULL, NULL, '', '2026-05-18 23:42:53', '', '2026-06-26 07:19:23'),
	(5, 'BX202605190001', 1, '', 103, '', '2026-05-18', '4', 66.00, 666.00, '2', '3', '["blob:http://192.168.2.74:8088/7d2c73c1-d312-40c5-9beb-70f17f09119a"]', '6666', '', '2026-05-19 12:15:59', '2120', '', '2026-05-19 12:16:06', '', '2026-05-19 00:00:41', NULL, '2026-05-19 12:16:06'),
	(6, 'BX202605190002', 1, '', 103, '', '2026-05-19', '4', 22.00, 222.00, '1', '1', '["blob:http://192.168.2.74:8088/c620eb48-98ba-405b-8f9a-7767e52712b5"]', '22', '若依', '2026-06-26 07:19:27', '', NULL, NULL, '', '2026-05-19 12:57:13', '', '2026-06-26 07:19:27'),
	(7, 'BX202605190003', 1, '', 103, '', '2026-05-19', '4', 99.00, 999.00, '1', '1', '[]', '25', '若依', '2026-06-26 07:19:29', '', NULL, NULL, '', '2026-05-19 14:23:42', NULL, '2026-06-26 07:19:29'),
	(11, 'BX202605190007', 1, '', 103, '', '2026-05-19', '4', 33.00, 333.00, '1', '0', '["blob:http://192.168.2.74:8088/4c5a4332-2bd5-40c2-98f6-bf47107047fa"]', '333', NULL, NULL, NULL, NULL, NULL, '', '2026-05-19 15:26:08', NULL, NULL),
	(12, 'BX202605190008', 1, '若依', 103, '研发部门', NULL, '1', 0.00, 0.00, '1', '0', NULL, '33', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-19 17:21:05', NULL, NULL),
	(13, 'BX202605190009', 1, '若依', 103, '研发部门', NULL, '2', 0.00, 0.00, '1', '0', NULL, '999', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-19 18:00:08', NULL, NULL),
	(14, 'BX202605200001', 1, '若依', 103, '研发部门', NULL, '1', 0.00, 0.00, '1', '0', NULL, '999', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-20 09:14:00', NULL, NULL),
	(15, 'BX202605200002', 1, '若依', 103, '研发部门', '2026-05-20', '3', 0.00, 0.00, '1', '0', '["blob:http://192.168.2.74:8088/fb0f399f-2e6e-40b0-8dc1-01ab65d12d58"]', '888', NULL, NULL, NULL, NULL, NULL, '若依', '2026-05-20 09:28:23', '若依', '2026-05-20 13:13:20'),
	(16, 'BX202605200003', 1, '若依', 103, '研发部门', '2026-05-20', '3', 88.00, 888.00, '1', '1', '["https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260520/10b7e3bed417b223b36c9ffe69e5c851.jpg"]', '515153', '若依', '2026-06-06 00:07:10', '', NULL, NULL, '若依', '2026-05-20 12:23:08', '若依', '2026-06-06 00:07:10'),
	(17, 'BX202606260001', 1, '若依', 103, '事业1部', '2026-06-25', '4', 0.00, 555.00, '1', '1', '', '', '若依', '2026-06-26 07:23:48', '', NULL, NULL, '若依', '2026-06-26 07:23:44', NULL, '2026-06-26 07:23:48'),
	(18, 'BX202606300001', 103, '鹏鹏', 101, '赛诺·森品牌', '2026-06-30', '1', 0.00, 80.00, '1', '3', '["/profile/upload/20260630/4abccbb7d7d5c007f096ed0bb7141ae4.jpg"]', '111', '鹏鹏', '2026-06-30 18:03:52', '', '鹏鹏', '2026-06-30 18:03:56', '鹏鹏', '2026-06-30 18:03:47', NULL, '2026-06-30 18:03:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='App菜单扩展配置表';

-- 正在导出表  fuchenpro.sys_app_menu 的数据：~40 rows (大约)
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
	(14, 2014, '/pages/attendance/rule', 'setting', '#F59E0B', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(15, 2080, '/pages/attendance/config', 'grid', '#F59E0B', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(16, 2022, '/pages/wms/supplier/index', 'account', '#3D6DF7', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(17, 2028, '/pages/wms/product/index', 'list', '#3D6DF7', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(18, 2034, '/pages/wms/stockIn/index', 'arrow-down', '#3D6DF7', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(19, 2041, '/pages/wms/shipment/index', 'arrow-up', '#3D6DF7', '#fff', 4, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(20, 2048, '/pages/wms/stock/index', 'search', '#3D6DF7', '#fff', 5, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(21, 2050, '/pages/wms/stockCheck/index', 'checkmark-circle', '#3D6DF7', '#fff', 6, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(23, 2057, '/pages/wms/report/index', 'list-dot', '#3D6DF7', '#fff', 8, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-06 13:09:09'),
	(24, 3001, '/pages/finance/planAudit/index', 'checkmark', '#8B5CF6', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(25, 3002, '/pages/finance/reimbursement/index', 'edit-pen', '#8B5CF6', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(26, 3003, '/pages/finance/reimbursementReport/index', 'file-text', '#8B5CF6', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(27, 100, '/pages/system/user/index', 'account', '#52c41a', '#fff', 1, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(28, 3024, '/pages/admin/feedback/index', 'edit-pen', '#52c41a', '#fff', 2, 1, 'admin', '2026-05-30 15:33:06', '', '2026-05-30 15:33:06'),
	(29, 103, '/pages/system/dept/index', 'setting', '#3D6DF7', '#fff', 3, 1, 'admin', '2026-05-30 15:33:06', 'admin', '2026-06-08 16:45:45'),
	(30, 104, '/pages/system/post/index', 'bookmark', '#3D6DF7', '#fff', 4, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-08 15:40:53'),
	(31, 107, '/pages/system/notice/index', 'chat', '#52c41a', '#fff', 5, 1, 'admin', '2026-05-30 15:33:06', '', '2026-06-05 23:18:58'),
	(32, 101, '', 'man-add', '#3D6DF7', '#fff', 1, 0, 'admin', '2026-05-30 15:33:06', '', '2026-06-06 13:09:09'),
	(33, 102, '', 'list', '#3D6DF7', '#fff', 2, 0, 'admin', '2026-05-30 15:33:06', '', '2026-06-06 13:09:09'),
	(34, 105, '', 'file-text', '#3D6DF7', '#fff', 3, 0, 'admin', '2026-05-30 15:33:06', '', '2026-06-06 13:09:09'),
	(35, 106, '', 'setting', '#3D6DF7', '#fff', 4, 0, 'admin', '2026-05-30 15:33:06', '', '2026-06-06 13:09:09'),
	(37, 3031, '/pages/attendance/index', 'clock', '#F59E0B', '#fff', 1, 1, 'admin', '2026-05-31 21:55:36', '', '2026-05-31 21:55:36'),
	(40, 3034, '/pages/business/cardItem/index', 'star', '#FF6B35', '#fff', 7, 1, 'admin', '2026-06-05 23:18:59', '', '2026-06-06 00:23:45'),
	(44, 3058, '/pages/business/customer/index', 'account', '#FF6B35', '#fff', 9, 1, 'admin', '2026-06-05 23:18:59', '', '2026-06-05 23:18:59'),
	(46, 3044, '/pages/business/stockPrepare/index', 'shopping-cart', '#FF6B35', '#fff', 8, 1, 'admin', '2026-06-06 13:09:09', '', '2026-06-06 13:09:09'),
	(47, 3067, '/pages/wms/warehouse/index', 'home', '#3D6DF7', '#fff', 7, 1, 'admin', '2026-06-20 19:59:16', '', NULL),
	(48, 3072, '/pages/wms/stockTransfer/index', 'swap', '#3D6DF7', '#fff', 9, 1, 'admin', '2026-06-20 19:59:16', '', NULL);
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
	(1, '欢迎使用', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260525/2013839df589d2c49ea8077114163d65.png', '', 1, '0', '默认轮播图1', 'admin', '2026-05-25 12:12:44', 'pengpeng', '2026-07-01 09:01:11'),
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
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8 COMMENT='参数配置表';

-- 正在导出表  fuchenpro.sys_config 的数据：~35 rows (大约)
DELETE FROM `sys_config`;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` (`config_id`, `config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),
	(2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '初始化密码 123456'),
	(3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-04-25 01:10:53', '', NULL, '深色主题theme-dark，浅色主题theme-light'),
	(4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '是否开启验证码功能（true开启，false关闭）'),
	(5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '是否开启注册用户功能（true开启，false关闭）'),
	(6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）'),
	(7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框'),
	(8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-04-25 01:10:53', 'admin', '2026-06-27 22:52:53', '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框'),
	(9, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', 'admin', '2026-04-25 01:10:54', 'admin', '2026-06-27 22:52:53', '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）'),
	(101, '登录过期时间', 'sys.login.expireTime', '1440', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', 'Token有效期（分钟），影响Web端和APP端'),
	(102, '启用腾讯云COS', 'sys.cos.enabled', 'true', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '是否启用腾讯云对象存储'),
	(103, '腾讯云SecretId', 'sys.cos.secretId', '', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '腾讯云COS SecretId'),
	(104, '腾讯云SecretKey', 'sys.cos.secretKey', '', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '腾讯云COS SecretKey'),
	(105, 'COS存储桶名称', 'sys.cos.bucket', 'mydream-1302682813', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '腾讯云COS存储桶名称'),
	(106, 'COS地域', 'sys.cos.region', 'ap-shanghai', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '腾讯云COS地域'),
	(107, 'COS自定义域名', 'sys.cos.domain', '', 'Y', 'admin', '2026-06-08 13:31:42', 'admin', '2026-06-27 22:52:53', '腾讯云COS自定义域名'),
	(108, '允许修改套餐次数', 'biz.sales.packageQuantityEditable', 'false', 'Y', 'admin', '2026-06-08 13:31:42', 'pengpeng', '2026-06-28 22:56:23', '销售开单中是否允许修改套餐次数，影响Web端和APP端'),
	(109, '允许修改套餐成交金额', 'biz.sales.packageDealAmountEditable', 'false', 'Y', 'admin', '2026-06-08 13:31:42', 'pengpeng', '2026-06-28 22:56:23', '销售开单中是否允许修改套餐成交金额，影响Web端和APP端'),
	(110, '允许修改套餐实付金额', 'biz.sales.packagePaidAmountEditable', 'true', 'Y', 'admin', '2026-06-08 13:31:42', 'pengpeng', '2026-06-28 22:56:23', '销售开单中是否允许修改套餐实付金额，影响Web端和APP端'),
	(111, '允许手动输入打卡地址', 'biz.attendance.allowManualAddress', 'false', 'Y', '', '2026-06-20 00:14:57', 'pengpeng', '2026-06-28 22:56:24', '控制APP端考勤打卡是否允许手动输入地址，关闭后定位失败时无法手动输入'),
	(112, '高德Web服务Key', 'sys.amap.webServiceKey', 'd184e115457658cbcf3f92ed8e3a1772', 'Y', 'admin', '2026-06-21 12:46:55', 'admin', '2026-06-27 22:52:53', '高德地图Web服务API Key，用于逆地理编码和IP定位'),
	(113, '高德JS API Key', 'sys.amap.jsKey', 'fa588d6bc9fbc9dce1f0c379e40f9faa', 'Y', 'admin', '2026-06-21 12:46:55', 'admin', '2026-06-26 02:43:04', '高德地图JS API Key，用于前端地图组件加载'),
	(114, '高德安全密钥', 'sys.amap.securityJsCode', '19ef226bdd6e4a6276d45ed1e5cb9a475', 'Y', 'admin', '2026-06-21 12:46:55', 'admin', '2026-06-27 22:52:53', '高德地图JS API安全密钥'),
	(115, '验证码有效期', 'sys.security.captchaExpire', '2', 'Y', 'admin', '2026-06-21 13:20:16', 'admin', '2026-06-26 02:43:03', '验证码有效期（分钟）'),
	(116, '密码最大错误次数', 'sys.security.pwdErrMaxCount', '5', 'Y', 'admin', '2026-06-21 13:20:16', 'admin', '2026-06-26 02:43:03', '密码错误超过此次数后锁定账户'),
	(117, '密码锁定时间', 'sys.security.pwdErrLockTime', '10', 'Y', 'admin', '2026-06-21 13:20:16', 'admin', '2026-06-26 02:43:03', '密码错误锁定时间（分钟）'),
	(118, '用户初始密码', 'sys.security.initPassword', '123456', 'Y', 'admin', '2026-06-21 13:20:16', 'admin', '2026-06-26 02:43:03', '新建用户和重置密码时的默认密码'),
	(119, '令牌续期阈值', 'sys.login.tokenRefreshThreshold', '20', 'Y', 'admin', '2026-06-21 13:20:16', 'admin', '2026-06-26 02:43:03', '令牌剩余有效期低于此值时自动续期（分钟）'),
	(125, '数据库备份启用', 'sys.backup.enabled', 'true', 'Y', '', '2026-06-21 23:58:36', '', NULL, NULL),
	(126, '数据库备份时间', 'sys.backup.time', '02:00', 'Y', '', '2026-06-21 23:58:36', 'pengpeng', '2026-07-01 09:01:25', NULL),
	(127, '备份保留天数', 'sys.backup.retainDays', '30', 'Y', '', '2026-06-21 23:58:36', '', NULL, NULL),
	(128, '数据库备份启用', 'sys.backup.enabled', 'true', 'Y', '', '2026-06-22 00:14:45', '', NULL, NULL),
	(129, '数据库备份时间', 'sys.backup.time', '02:00', 'Y', '', '2026-06-22 00:14:45', '', NULL, NULL),
	(130, '备份保留天数', 'sys.backup.retainDays', '30', 'Y', '', '2026-06-22 00:14:45', '', NULL, NULL),
	(131, 'mysqldump路径', 'sys.backup.mysqldumpPath', 'mysqldump', 'Y', '', '2026-06-22 00:14:45', '', NULL, NULL);
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_db_backup 结构
DROP TABLE IF EXISTS `sys_db_backup`;
CREATE TABLE IF NOT EXISTS `sys_db_backup` (
  `backup_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '备份ID',
  `file_name` varchar(200) NOT NULL DEFAULT '' COMMENT '备份文件名',
  `file_size` bigint(20) NOT NULL DEFAULT '0' COMMENT '文件大小(字节)',
  `cos_path` varchar(500) DEFAULT '' COMMENT 'COS存储路径',
  `cos_url` varchar(500) DEFAULT '' COMMENT 'COS访问URL',
  `backup_type` varchar(20) NOT NULL DEFAULT 'auto' COMMENT '备份类型(auto自动/manual手动)',
  `status` varchar(20) NOT NULL DEFAULT 'success' COMMENT '状态(success成功/failed失败)',
  `duration` decimal(10,2) DEFAULT '0.00' COMMENT '耗时(秒)',
  `error_message` text COMMENT '错误信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`backup_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据库备份记录表';

-- 正在导出表  fuchenpro.sys_db_backup 的数据：~6 rows (大约)
DELETE FROM `sys_db_backup`;
/*!40000 ALTER TABLE `sys_db_backup` DISABLE KEYS */;
INSERT INTO `sys_db_backup` (`backup_id`, `file_name`, `file_size`, `cos_path`, `cos_url`, `backup_type`, `status`, `duration`, `error_message`, `create_time`) VALUES
	(5, 'fuchenpro_20260622_003632.sql', 277009, '', '', 'manual', 'success', 0.76, '', '2026-06-22 00:36:33'),
	(6, 'fuchenpro_20260622_004149.sql', 278179, '', '', 'manual', 'success', 0.78, '', '2026-06-22 00:41:49'),
	(7, 'fuchenpro_20260626_020033.sql', 0, '', '', 'auto', 'failed', 0.10, 'mysqldump执行失败', '2026-06-26 02:00:34'),
	(8, 'fuchenpro_20260627_020047.sql', 0, '', '', 'auto', 'failed', 0.18, 'mysqldump执行失败', '2026-06-27 02:00:47'),
	(9, 'fuchenpro_20260627_020047.sql', 0, '', '', 'auto', 'failed', 0.20, 'mysqldump执行失败', '2026-06-27 02:00:47'),
	(10, 'fuchenpro_20260629_020013.sql', 413834, '', '', 'auto', 'success', 0.79, '', '2026-06-29 02:00:13'),
	(11, 'fuchenpro_20260630_020054.sql', 442389, '', '', 'auto', 'success', 1.10, '', '2026-06-30 02:00:55'),
	(12, 'fuchenpro_20260701_020055.sql', 445885, '', '', 'auto', 'success', 0.85, '', '2026-07-01 02:00:56');
/*!40000 ALTER TABLE `sys_db_backup` ENABLE KEYS */;

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
	(100, 0, '0', '赛诺美生', 0, '汪志', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', 'admin', '2026-06-26 02:33:34'),
	(101, 100, '0,100', '赛诺·森品牌', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', 'admin', '2026-06-04 22:41:14'),
	(102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2026-04-25 01:10:44', '', NULL),
	(103, 101, '0,100,101', '事业1部', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:44', 'admin', '2026-06-04 22:40:15'),
	(104, 101, '0,100,101', '事业2部', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', 'admin', '2026-06-04 22:40:24'),
	(105, 101, '0,100,101', '事业3部', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', 'admin', '2026-06-04 22:40:34'),
	(106, 101, '0,100,101', '事业5部', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-25 01:10:45', 'admin', '2026-06-04 22:40:42'),
	(107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2026-04-25 01:10:45', '', NULL),
	(108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2026-04-25 01:10:45', '', NULL),
	(109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2026-04-25 01:10:45', '', NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8 COMMENT='字典数据表';

-- 正在导出表  fuchenpro.sys_dict_data 的数据：~139 rows (大约)
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
	(216, 2, '耗卡', 'card', 'biz_payment_method', '', 'success', 'N', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '耗卡支付'),
	(218, 3, '赠送', 'gift', 'biz_payment_method', '', 'danger', 'N', '0', 'admin', '2026-05-26 18:51:09', '', NULL, '赠送（成交0实付0）'),
	(219, 1, '工作问题', '0', 'biz_feedback_type', '', 'danger', 'Y', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(220, 2, '优化建议', '1', 'biz_feedback_type', '', 'warning', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(221, 3, '其他', '2', 'biz_feedback_type', '', 'info', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(222, 1, '待处理', '0', 'biz_feedback_status', '', 'info', 'Y', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(223, 2, '处理中', '1', 'biz_feedback_status', '', 'warning', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(224, 3, '已处理', '2', 'biz_feedback_status', '', 'success', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(225, 4, '已关闭', '3', 'biz_feedback_status', '', 'info', 'N', '0', 'admin', '2026-05-30 13:09:54', '', NULL, NULL),
	(234, 1, '待备货', '0', 'biz_stock_prepare_status', '', 'primary', 'Y', '0', 'admin', '2026-06-01 19:05:41', '', NULL, NULL),
	(235, 2, '部分出库', '1', 'biz_stock_prepare_status', '', 'warning', 'N', '0', 'admin', '2026-06-01 19:05:41', '', NULL, NULL),
	(236, 3, '已出完', '2', 'biz_stock_prepare_status', '', 'success', 'N', '0', 'admin', '2026-06-01 19:05:41', '', NULL, NULL),
	(237, 4, '已取消', '3', 'biz_stock_prepare_status', '', 'info', 'N', '0', 'admin', '2026-06-01 19:05:41', '', NULL, NULL),
	(238, 1, '面部', '1', 'biz_card_item_category', '', 'primary', 'Y', '0', 'admin', '2026-06-01 19:06:44', '', NULL, NULL),
	(239, 2, '身体', '2', 'biz_card_item_category', '', 'success', 'N', '0', 'admin', '2026-06-01 19:06:44', '', NULL, NULL),
	(240, 3, '仪器', '3', 'biz_card_item_category', '', 'warning', 'N', '0', 'admin', '2026-06-01 19:06:44', '', NULL, NULL),
	(241, 4, '其他', '4', 'biz_card_item_category', '', 'info', 'N', '0', 'admin', '2026-06-01 19:06:44', '', NULL, NULL),
	(242, 1, '顺丰速运', 'shunfeng', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(243, 2, '中通快递', 'zhongtong', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(244, 3, '圆通速递', 'yuantong', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(245, 4, '申通快递', 'shentong', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(246, 5, '韵达快递', 'yunda', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(247, 6, '百世快递', 'baishi', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(248, 7, '极兔速递', 'jitu', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(249, 8, '邮政EMS', 'ems', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(250, 9, '德邦快递', 'debang', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(251, 10, '京东物流', 'jd', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:07', '', NULL, NULL),
	(252, 11, '天天快递', 'tiantian', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:08', '', NULL, NULL),
	(253, 12, '宅急送', 'zhaijisong', 'logistics_company', '', 'primary', 'N', '0', 'admin', '2026-06-19 22:16:08', '', NULL, NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8 COMMENT='字典类型表';

-- 正在导出表  fuchenpro.sys_dict_type 的数据：~35 rows (大约)
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
	(129, '反馈状态', 'biz_feedback_status', '0', 'admin', '2026-05-30 13:09:54', '', NULL, '反馈处理状态列表'),
	(130, '卡项类别', 'biz_card_item_category', '0', 'admin', '2026-06-01 08:51:00', '', NULL, '卡项类别列表'),
	(132, '备货状态', 'biz_stock_prepare_status', '0', 'admin', '2026-06-01 19:05:41', '', NULL, '备货状态列表'),
	(133, '物流公司', 'logistics_company', '0', 'admin', '2026-06-19 22:16:07', '', NULL, '物流公司列表');
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
  `login_source` varchar(20) DEFAULT 'web' COMMENT '登录来源（web端/app端）',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB AUTO_INCREMENT=428 DEFAULT CHARSET=utf8 COMMENT='系统访问记录';

-- 正在导出表  fuchenpro.sys_logininfor 的数据：~310 rows (大约)
DELETE FROM `sys_logininfor`;
/*!40000 ALTER TABLE `sys_logininfor` DISABLE KEYS */;
INSERT INTO `sys_logininfor` (`info_id`, `user_name`, `ipaddr`, `login_location`, `browser`, `os`, `status`, `msg`, `login_time`, `login_source`) VALUES
	(100, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 10:42:00', 'web'),
	(101, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 10:43:45', 'web'),
	(102, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 10:51:33', 'web'),
	(103, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:30:39', 'web'),
	(104, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:32:28', 'web'),
	(105, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:32:50', 'web'),
	(106, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:33:15', 'web'),
	(107, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:35:32', 'web'),
	(108, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:41:28', 'web'),
	(109, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:46:13', 'web'),
	(110, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:47:22', 'web'),
	(111, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 12:48:49', 'web'),
	(112, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 12:54:38', 'web'),
	(113, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-04-25 13:16:18', 'web'),
	(114, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:17:14', 'web'),
	(115, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:18:05', 'web'),
	(116, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:42:52', 'web'),
	(117, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:49:45', 'web'),
	(118, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 13:50:47', 'web'),
	(119, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 14:01:31', 'web'),
	(120, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 15:10:03', 'web'),
	(121, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 16:18:12', 'web'),
	(122, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 17:04:45', 'web'),
	(123, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 17:05:26', 'web'),
	(124, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 18:26:48', 'web'),
	(125, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 19:52:14', 'web'),
	(126, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 21:05:27', 'web'),
	(127, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-25 21:44:33', 'web'),
	(128, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 00:03:37', 'web'),
	(129, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 00:46:28', 'web'),
	(130, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 12:02:01', 'web'),
	(131, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:04:56', 'web'),
	(132, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:06:14', 'web'),
	(133, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:16:22', 'web'),
	(134, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 12:34:09', 'web'),
	(135, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 19:55:31', 'web'),
	(136, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 20:05:25', 'web'),
	(137, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 20:06:54', 'web'),
	(138, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 21:25:38', 'web'),
	(139, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 21:39:43', 'web'),
	(140, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 22:33:22', 'web'),
	(141, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:03:31', 'web'),
	(142, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:38:15', 'web'),
	(143, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-26 23:39:31', 'web'),
	(144, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-26 23:53:55', 'web'),
	(145, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 00:04:37', 'web'),
	(146, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 00:35:57', 'web'),
	(147, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 08:19:15', 'web'),
	(148, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-27 13:07:46', 'web'),
	(149, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 13:24:02', 'web'),
	(150, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 16:20:20', 'web'),
	(151, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 18:22:47', 'web'),
	(152, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 19:19:57', 'web'),
	(153, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 20:19:54', 'web'),
	(154, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 22:04:27', 'web'),
	(155, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-27 23:37:28', 'web'),
	(156, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-28 12:33:16', 'web'),
	(157, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-28 17:47:29', 'web'),
	(158, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-28 22:48:24', 'web'),
	(159, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 07:46:46', 'web'),
	(160, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 07:47:54', 'web'),
	(161, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 12:45:12', 'web'),
	(162, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 12:55:27', 'web'),
	(163, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 13:00:07', 'web'),
	(164, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-04-29 14:18:01', 'web'),
	(165, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-04-29 16:40:58', 'web'),
	(166, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-29 18:00:22', 'web'),
	(167, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 18:10:50', 'web'),
	(168, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-29 23:48:36', 'web'),
	(169, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-30 01:06:19', 'web'),
	(170, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 13:55:10', 'web'),
	(171, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-04-30 14:04:36', 'web'),
	(172, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 14:07:48', 'web'),
	(173, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-04-30 19:26:13', 'web'),
	(174, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 10:51:21', 'web'),
	(175, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 16:12:17', 'web'),
	(176, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-01 22:25:35', 'web'),
	(177, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 00:09:54', 'web'),
	(178, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-02 00:10:11', 'web'),
	(179, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-02 00:10:50', 'web'),
	(180, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 12:17:32', 'web'),
	(181, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 18:17:46', 'web'),
	(182, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-02 21:43:54', 'web'),
	(183, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-02 21:46:33', 'web'),
	(184, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 07:58:15', 'web'),
	(185, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 07:58:50', 'web'),
	(186, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 07:59:37', 'web'),
	(187, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 14:22:17', 'web'),
	(188, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-03 15:11:53', 'web'),
	(189, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 16:32:39', 'web'),
	(190, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-03 21:38:14', 'web'),
	(191, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 03:17:28', 'web'),
	(192, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 08:17:51', 'web'),
	(193, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 18:37:53', 'web'),
	(194, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-04 23:45:42', 'web'),
	(195, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 11:07:36', 'web'),
	(196, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-05 12:07:48', 'web'),
	(197, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 16:09:10', 'web'),
	(198, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 22:46:02', 'web'),
	(199, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-05 23:25:56', 'web'),
	(200, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-05 23:35:07', 'web'),
	(201, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-06 14:04:38', 'web'),
	(202, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-06 19:08:20', 'web'),
	(203, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 06:43:53', 'web'),
	(204, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 12:33:50', 'web'),
	(205, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 18:15:12', 'web'),
	(206, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-07 23:24:34', 'web'),
	(207, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 08:22:07', 'web'),
	(208, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 15:20:28', 'web'),
	(209, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-08 20:22:45', 'web'),
	(210, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-08 21:41:21', 'web'),
	(211, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:03:39', 'web'),
	(212, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:19:38', 'web'),
	(213, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-08 22:33:13', 'web'),
	(214, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 11:41:18', 'web'),
	(215, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-09 16:22:11', 'web'),
	(216, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 17:19:42', 'web'),
	(217, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 21:12:26', 'web'),
	(218, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-09 22:27:41', 'web'),
	(219, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-09 22:41:17', 'web'),
	(220, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 10:58:12', 'web'),
	(221, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 11:07:34', 'web'),
	(222, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 17:03:50', 'web'),
	(223, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 17:12:52', 'web'),
	(224, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 20:25:57', 'web'),
	(225, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-10 22:12:25', 'web'),
	(226, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-10 22:30:09', 'web'),
	(227, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-11 21:31:23', 'web'),
	(228, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-11 21:47:14', 'web'),
	(229, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-11 21:48:07', 'web'),
	(230, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 00:50:38', 'web'),
	(231, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 15:12:04', 'web'),
	(232, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 15:13:57', 'web'),
	(233, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-12 20:20:23', 'web'),
	(234, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 20:29:59', 'web'),
	(235, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-12 21:30:44', 'web'),
	(236, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-12 22:54:41', 'web'),
	(237, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-12 23:59:14', 'web'),
	(238, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 16:36:11', 'web'),
	(239, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-13 16:42:03', 'web'),
	(240, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 22:41:22', 'web'),
	(241, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-13 22:45:37', 'web'),
	(242, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-13 22:58:30', 'web'),
	(243, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 16:35:12', 'web'),
	(244, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-14 16:36:46', 'web'),
	(245, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 17:36:03', 'web'),
	(246, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-14 20:14:40', 'web'),
	(247, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-14 23:59:20', 'web'),
	(248, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 14:15:13', 'web'),
	(249, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-15 14:15:21', 'web'),
	(250, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 17:03:24', 'web'),
	(251, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-15 19:44:39', 'web'),
	(252, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-15 20:50:47', 'web'),
	(253, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 19:26:41', 'web'),
	(254, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 19:45:39', 'web'),
	(255, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-16 20:12:38', 'web'),
	(256, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-16 20:40:38', 'web'),
	(257, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-17 19:56:29', 'web'),
	(258, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 08:38:14', 'web'),
	(259, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 18:03:17', 'web'),
	(260, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-18 19:33:17', 'web'),
	(261, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 12:15:37', 'web'),
	(262, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:11:08', 'web'),
	(263, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:28:11', 'web'),
	(264, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 16:51:03', 'web'),
	(265, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 21:43:05', 'web'),
	(266, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-19 22:04:37', 'web'),
	(267, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 08:46:23', 'web'),
	(268, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 12:21:04', 'web'),
	(269, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 13:12:10', 'web'),
	(270, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-20 14:47:10', 'web'),
	(271, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 14:49:07', 'web'),
	(272, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 18:25:09', 'web'),
	(273, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 19:50:55', 'web'),
	(274, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 20:20:12', 'web'),
	(275, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-05-20 20:25:21', 'web'),
	(276, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-20 21:56:51', 'web'),
	(277, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 14:16:27', 'web'),
	(278, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 19:38:25', 'web'),
	(279, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-21 20:14:24', 'web'),
	(280, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-22 12:41:17', 'web'),
	(281, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-22 19:02:36', 'web'),
	(282, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-22 19:03:16', 'web'),
	(283, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 00:27:34', 'web'),
	(284, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 00:27:55', 'web'),
	(285, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 13:42:32', 'web'),
	(286, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 14:19:50', 'web'),
	(287, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 14:41:30', 'web'),
	(288, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 15:18:16', 'web'),
	(289, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 16:51:10', 'web'),
	(290, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-23 19:11:17', 'web'),
	(291, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-23 19:21:09', 'web'),
	(292, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-24 20:16:53', 'web'),
	(293, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-24 20:18:56', 'web'),
	(294, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-25 11:54:59', 'web'),
	(295, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 12:13:26', 'web'),
	(296, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-25 17:18:44', 'web'),
	(297, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 18:02:51', 'web'),
	(298, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-25 23:06:39', 'web'),
	(299, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 00:17:28', 'web'),
	(300, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-26 12:22:37', 'web'),
	(301, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 14:26:23', 'web'),
	(302, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-26 17:49:09', 'web'),
	(303, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-26 19:26:28', 'web'),
	(304, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 14:33:17', 'web'),
	(305, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-27 14:49:09', 'web'),
	(306, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 15:17:45', 'web'),
	(307, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-27 21:30:05', 'web'),
	(308, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-27 21:35:24', 'web'),
	(309, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-28 13:13:39', 'web'),
	(310, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-28 16:47:13', 'web'),
	(311, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-28 19:47:38', 'web'),
	(312, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 12:32:00', 'web'),
	(313, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 13:53:56', 'web'),
	(314, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-29 15:22:02', 'web'),
	(315, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 17:47:39', 'web'),
	(316, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 19:37:07', 'web'),
	(317, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-29 22:15:41', 'web'),
	(318, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 22:54:05', 'web'),
	(319, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:48:54', 'web'),
	(320, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:51:15', 'web'),
	(321, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-29 23:56:08', 'web'),
	(322, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 13:05:34', 'web'),
	(323, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 13:10:24', 'web'),
	(324, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-30 13:10:44', 'web'),
	(325, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 14:02:49', 'web'),
	(326, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-30 18:36:54', 'web'),
	(327, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-05-30 18:49:30', 'web'),
	(328, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-05-31 22:04:40', 'web'),
	(329, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-01 08:51:15', 'web'),
	(330, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-01 15:21:55', 'web'),
	(331, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-01 17:44:52', 'web'),
	(332, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-01 19:01:50', 'web'),
	(333, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-01 22:37:01', 'web'),
	(334, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-02 12:02:02', 'web'),
	(335, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-02 20:54:11', 'web'),
	(336, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-03 07:04:25', 'web'),
	(337, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-03 13:36:46', 'web'),
	(338, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-03 15:17:16', 'web'),
	(339, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-03 15:18:37', 'web'),
	(340, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-04 19:58:21', 'web'),
	(341, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-05 15:06:05', 'web'),
	(342, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-05 15:06:23', 'web'),
	(343, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-05 22:16:00', 'web'),
	(344, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-05 22:39:22', 'web'),
	(345, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-06 00:20:16', 'web'),
	(346, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-06 12:25:24', 'web'),
	(347, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-06 12:27:18', 'web'),
	(348, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-06 12:33:35', 'web'),
	(349, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-06 18:53:24', 'web'),
	(350, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-06 23:59:49', 'web'),
	(351, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-08 00:32:28', 'web'),
	(352, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-08 06:09:43', 'web'),
	(353, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-08 10:32:49', 'web'),
	(354, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-08 13:32:42', 'web'),
	(355, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-08 14:36:05', 'web'),
	(356, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-08 16:32:10', 'web'),
	(357, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-08 22:41:54', 'web'),
	(358, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-09 13:09:34', 'web'),
	(359, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-09 13:31:59', 'web'),
	(360, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-10 00:41:11', 'web'),
	(361, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-18 19:16:27', 'app'),
	(362, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-19 20:56:34', 'app'),
	(363, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-19 21:01:45', 'web'),
	(364, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-19 22:16:40', 'web'),
	(365, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-19 22:18:42', 'web'),
	(366, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-19 22:31:18', 'web'),
	(367, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-19 23:27:29', 'app'),
	(368, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-20 12:27:39', 'app'),
	(369, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-20 14:35:51', 'web'),
	(370, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-20 18:16:25', 'app'),
	(371, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-21 08:20:18', 'app'),
	(372, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-21 08:54:50', 'web'),
	(373, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-21 14:13:49', 'app'),
	(374, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-21 14:19:28', 'web'),
	(375, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-21 22:53:52', 'web'),
	(376, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-22 01:04:26', 'web'),
	(377, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-22 01:49:26', 'app'),
	(378, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 01:43:15', 'app'),
	(379, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-26 01:43:36', 'web'),
	(380, 'peng1', '127.0.0.1', '内网IP', 'Chrome', 'Android', '1', '用户不存在', '2026-06-26 02:46:52', 'app'),
	(381, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 02:51:16', 'app'),
	(382, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 02:51:41', 'app'),
	(383, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 11:10:28', 'app'),
	(384, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 12:45:39', 'app'),
	(385, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 13:10:44', 'app'),
	(386, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-06-26 14:03:43', 'web'),
	(387, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 15:23:17', 'app'),
	(388, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-26 17:17:43', 'app'),
	(389, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-26 17:21:30', 'web'),
	(390, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-26 22:29:07', 'web'),
	(391, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-27 06:14:41', 'app'),
	(392, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-27 16:43:35', 'app'),
	(393, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-27 19:25:36', 'web'),
	(394, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-27 22:50:40', 'web'),
	(395, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-27 22:55:01', 'app'),
	(396, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-28 00:43:58', 'app'),
	(397, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-28 20:22:37', 'app'),
	(398, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-28 20:23:12', 'web'),
	(399, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-28 21:05:29', 'web'),
	(400, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-28 21:27:02', 'web'),
	(401, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-28 22:59:09', 'app'),
	(402, 'ceshi', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-28 23:06:28', 'app'),
	(403, 'ceshi', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-28 23:09:25', 'app'),
	(404, 'ceshi', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-06-28 23:10:46', 'app'),
	(405, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-28 23:11:54', 'app'),
	(406, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-06-28 23:13:53', 'web'),
	(407, 'ceshi', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-06-28 23:15:43', 'web'),
	(408, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '1', '密码错误，还剩4次机会', '2026-06-28 23:58:31', 'web'),
	(409, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-28 23:58:43', 'web'),
	(410, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-29 23:29:44', 'web'),
	(411, 'admin', '127.0.0.1', '内网IP', 'Edge', 'Windows 10', '0', '登录成功', '2026-06-29 23:30:29', 'web'),
	(412, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-29 23:59:17', 'web'),
	(413, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-30 00:35:49', 'app'),
	(414, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-06-30 17:20:00', 'web'),
	(415, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Android', '0', '登录成功', '2026-06-30 18:21:49', 'app'),
	(416, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 00:34:18', 'web'),
	(417, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Windows 10', '0', '登录成功', '2026-07-01 08:51:04', 'web'),
	(418, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 08:57:21', 'web'),
	(419, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 09:05:17', 'web'),
	(420, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 14:53:27', 'web'),
	(421, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 16:35:28', 'app'),
	(422, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-01 16:59:36', 'web'),
	(423, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-02 17:54:09', 'web'),
	(424, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-02 18:59:19', 'web'),
	(425, 'admin', '127.0.0.1', '内网IP', 'Unknown', 'Windows 10', '0', '登录成功', '2026-07-03 00:55:01', 'web'),
	(426, 'pengpeng', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-03 01:11:36', 'web'),
	(427, 'admin', '127.0.0.1', '内网IP', 'Chrome', 'Windows 10', '0', '登录成功', '2026-07-03 14:07:19', 'web');
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
  `client_type` varchar(10) NOT NULL DEFAULT 'all' COMMENT '客户端类型(all-全端 web-仅Web app-仅App)',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3091 DEFAULT CHARSET=utf8 COMMENT='菜单权限表';

-- 正在导出表  fuchenpro.sys_menu 的数据：~244 rows (大约)
DELETE FROM `sys_menu`;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '系统管理', 0, 5, 'system', NULL, '', '', 1, 0, 'M', '0', '0', 'all', '', 'system', 'admin', '2026-04-25 01:10:46', 'admin', '2026-04-28 21:49:00', '系统管理目录'),
	(2, '系统监控', 0, 7, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', 'all', '', 'monitor', 'admin', '2026-04-25 01:10:46', '', NULL, '系统监控目录'),
	(3, '系统工具', 0, 8, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', 'all', '', 'tool', 'admin', '2026-04-25 01:10:46', '', NULL, '系统工具目录'),
	(4, '公司官网', 0, 9, 'https://baidu.com', NULL, '', '', 0, 0, 'M', '0', '0', 'all', '', 'guide', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-08 09:30:04', '若依官网地址'),
	(100, '用户管理', 3023, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:user:list', 'user', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:04:30', '用户管理菜单'),
	(101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:role:list', 'peoples', 'admin', '2026-04-25 01:10:46', '', NULL, '角色管理菜单'),
	(102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:menu:list', 'tree-table', 'admin', '2026-04-25 01:10:46', '', NULL, '菜单管理菜单'),
	(103, '部门管理', 3023, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:dept:list', 'tree', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:05:36', '部门管理菜单'),
	(104, '岗位管理', 3023, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:post:list', 'post', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:05:48', '岗位管理菜单'),
	(105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:dict:list', 'dict', 'admin', '2026-04-25 01:10:46', '', NULL, '字典管理菜单'),
	(106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:config:list', 'edit', 'admin', '2026-04-25 01:10:46', '', NULL, '参数设置菜单'),
	(107, '通知公告', 3023, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'all', 'system:notice:list', 'message', 'admin', '2026-04-25 01:10:46', 'admin', '2026-05-30 14:08:38', '通知公告菜单'),
	(108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', 'all', '', 'log', 'admin', '2026-04-25 01:10:46', '', NULL, '日志管理菜单'),
	(109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:online:list', 'online', 'admin', '2026-04-25 01:10:46', '', NULL, '在线用户菜单'),
	(110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:job:list', 'job', 'admin', '2026-04-25 01:10:46', '', NULL, '定时任务菜单'),
	(111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:druid:list', 'druid', 'admin', '2026-04-25 01:10:46', '', NULL, '数据监控菜单'),
	(112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:server:list', 'server', 'admin', '2026-04-25 01:10:46', '', NULL, '服务监控菜单'),
	(113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:cache:list', 'redis', 'admin', '2026-04-25 01:10:46', '', NULL, '缓存监控菜单'),
	(114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:cache:list', 'redis-list', 'admin', '2026-04-25 01:10:47', '', NULL, '缓存列表菜单'),
	(115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'all', 'tool:build:list', 'build', 'admin', '2026-04-25 01:10:47', '', NULL, '表单构建菜单'),
	(116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'all', 'tool:gen:list', 'code', 'admin', '2026-04-25 01:10:47', '', NULL, '代码生成菜单'),
	(117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'all', 'tool:swagger:list', 'swagger', 'admin', '2026-04-25 01:10:47', '', NULL, '系统接口菜单'),
	(500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:operlog:list', 'form', 'admin', '2026-04-25 01:10:47', '', NULL, '操作日志菜单'),
	(501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'all', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-04-25 01:10:47', '', NULL, '登录日志菜单'),
	(1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:export', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:import', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:user:resetPwd', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:role:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:role:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:role:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:role:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:role:export', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:menu:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:menu:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:menu:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:menu:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dept:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dept:add', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dept:edit', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dept:remove', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:post:query', '#', 'admin', '2026-04-25 01:10:47', '', NULL, ''),
	(1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:post:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:post:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:post:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:post:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dict:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dict:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dict:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dict:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:dict:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:config:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:config:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:config:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:config:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:config:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:notice:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:notice:add', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:notice:edit', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'system:notice:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:operlog:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:operlog:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:operlog:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:logininfor:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:logininfor:remove', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:logininfor:export', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:logininfor:unlock', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:online:query', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:online:batchLogout', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:online:forceLogout', '#', 'admin', '2026-04-25 01:10:48', '', NULL, ''),
	(1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:query', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:add', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:edit', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:remove', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:changeStatus', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'monitor:job:export', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:query', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:edit', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:remove', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:import', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:preview', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'all', 'tool:gen:code', '#', 'admin', '2026-04-25 01:10:49', '', NULL, ''),
	(2000, '业务管理', 0, 1, 'business', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'peoples', 'admin', '2026-04-27 18:23:54', 'admin', '2026-04-28 21:48:20', ''),
	(2001, '企业管理', 2000, 1, 'enterprise', 'business/enterprise/index', NULL, 'Enterprise', 1, 0, 'C', '0', '0', 'all', 'business:enterprise:list', 'chart', 'admin', '2026-04-27 18:23:54', 'admin', '2026-04-27 23:27:44', ''),
	(2002, '企业查询', 2001, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:enterprise:query', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2003, '企业新增', 2001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:enterprise:add', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2004, '企业修改', 2001, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:enterprise:edit', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2005, '企业删除', 2001, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:enterprise:remove', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2006, '企业导出', 2001, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:enterprise:export', '#', 'admin', '2026-04-27 18:23:54', '', NULL, ''),
	(2007, '行程安排', 2000, 2, 'schedule', 'business/schedule/index', NULL, 'Schedule', 1, 0, 'C', '0', '0', 'all', 'business:schedule:list', 'date', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2008, '行程查询', 2007, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:schedule:query', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2009, '行程新增', 2007, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:schedule:add', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2010, '行程修改', 2007, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:schedule:edit', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2011, '行程删除', 2007, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:schedule:remove', '#', 'admin', '2026-04-28 15:36:55', '', NULL, ''),
	(2012, '考勤管理', 0, 2, 'attendance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'time', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2013, '考勤记录', 2012, 1, 'record', 'business/attendance/record', NULL, 'AttendanceRecord', 1, 0, 'C', '0', '0', 'all', 'business:attendance:record:list', 'log', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2014, '考勤规则', 2012, 2, 'rule', 'business/attendance/rule', NULL, 'AttendanceRule', 1, 0, 'C', '0', '0', 'all', 'business:attendance:rule:list', 'edit', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2015, '记录查询', 2013, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:record:query', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2016, '记录详情', 2013, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:record:detail', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2017, '规则查询', 2014, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:query', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2018, '规则新增', 2014, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:add', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2019, '规则修改', 2014, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:edit', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2020, '规则删除', 2014, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:rule:remove', '#', 'admin', '2026-04-29 07:46:25', '', NULL, ''),
	(2021, '进销存管理', 0, 3, 'wms', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'shopping', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2022, '供货商管理', 2021, 1, 'supplier', 'wms/supplier/index', NULL, 'WmsSupplier', 1, 0, 'C', '0', '0', 'all', 'wms:supplier:list', 'peoples', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2023, '供货商查询', 2022, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:supplier:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2024, '供货商新增', 2022, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:supplier:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2025, '供货商修改', 2022, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:supplier:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2026, '供货商删除', 2022, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:supplier:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2027, '供货商导出', 2022, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:supplier:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2028, '货品管理', 2021, 2, 'product', 'wms/product/index', NULL, 'WmsProduct', 1, 0, 'C', '0', '0', 'all', 'wms:product:list', 'component', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2029, '货品查询', 2028, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:product:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2030, '货品新增', 2028, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:product:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2031, '货品修改', 2028, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:product:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2032, '货品删除', 2028, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:product:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2033, '货品导出', 2028, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:product:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2034, '入库管理', 2021, 3, 'stockIn', 'wms/stockIn/index', NULL, 'WmsStockIn', 1, 0, 'C', '0', '0', 'all', 'wms:stockIn:list', 'monitor', 'admin', '2026-04-29 07:51:27', 'admin', '2026-04-30 16:52:46', ''),
	(2035, '入库查询', 2034, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2036, '入康新增', 2034, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2037, '入库修改', 2034, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2038, '入库删除', 2034, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2039, '入库确认', 2034, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:confirm', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2040, '入库导出', 2034, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockIn:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2041, '出库管理', 2021, 4, 'stockOut', 'wms/stockOut/index', NULL, 'WmsStockOut', 1, 0, 'C', '0', '0', 'all', 'wms:stockOut:list', 'upload', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2042, '出库查询', 2041, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:query', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2043, '出库新增', 2041, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:add', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2044, '出库修改', 2041, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:edit', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2045, '出库删除', 2041, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:remove', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2046, '出库确认', 2041, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:confirm', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2047, '出库导出', 2041, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockOut:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2048, '库存查看', 2021, 5, 'inventory', 'wms/inventory/index', NULL, 'WmsInventory', 1, 0, 'C', '0', '0', 'all', 'wms:inventory:list', 'list', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2049, '库存导出', 2048, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:inventory:export', '#', 'admin', '2026-04-29 07:51:27', '', NULL, ''),
	(2050, '库存盘点', 2021, 6, 'stockCheck', 'wms/stockCheck/index', NULL, 'WmsStockCheck', 1, 0, 'C', '0', '0', 'all', 'wms:stockCheck:list', 'clipboard', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2051, '盘点查询', 2050, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:query', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2052, '盘點新增', 2050, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:add', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2053, '盘点修改', 2050, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:edit', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2054, '盘点删除', 2050, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:remove', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2055, '盘点确认', 2050, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:confirm', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2056, '盘点导出', 2050, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:stockCheck:export', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2057, '进销存报表', 2021, 7, 'report', 'wms/report/index', NULL, 'WmsReport', 1, 0, 'C', '0', '0', 'all', 'wms:report:list', 'chart', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2058, '报表导出', 2057, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'wms:report:export', '#', 'admin', '2026-04-29 07:51:28', '', NULL, ''),
	(2059, '门店管理', 2000, 2, 'store', 'business/store/index', NULL, 'Store', 1, 0, 'C', '0', '0', 'all', 'business:store:list', 'shopping', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2060, '门店查询', 2059, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:store:query', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2061, '门店新增', 2059, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:store:add', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2062, '门店修改', 2059, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:store:edit', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2063, '门店删除', 2059, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:store:remove', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2064, '门店导出', 2059, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:store:export', '#', 'admin', '2026-04-30 17:58:01', '', NULL, ''),
	(2065, '销售开单', 2000, 3, 'sales', 'business/sales/index', NULL, 'Sales', 1, 0, 'C', '0', '0', 'all', 'business:sales:list', 'shopping', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2066, '销售开单查询', 2065, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:query', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2067, '销售开单新增', 2065, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:add', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2068, '销售开单修改', 2065, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:edit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2069, '销售开单删除', 2065, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:remove', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2070, '企业审核', 2065, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:enterpriseAudit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2071, '财务审核', 2065, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:financeAudit', '#', 'admin', '2026-04-30 23:50:25', '', NULL, ''),
	(2072, '订单管理', 2000, 4, 'order', 'business/order/index', NULL, 'Order', 1, 0, 'C', '0', '0', 'all', 'business:order:list', 'list', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2073, '订单查询', 2072, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:query', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2074, '企业审核', 2072, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:enterpriseAudit', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2075, '财务审核', 2072, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:financeAudit', '#', 'admin', '2026-05-02 23:19:33', '', NULL, ''),
	(2076, '方案管理', 2000, 5, 'plan', 'business/planList/index', NULL, 'Plan', 1, 0, 'C', '0', '0', 'all', 'business:plan:list', 'list', 'admin', '2026-05-03 19:40:18', '', '2026-05-07 15:00:21', ''),
	(2077, '方案查询', 2076, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:query', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2078, '方案新增', 2076, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:add', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2079, '方案审核', 2076, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:audit', '#', 'admin', '2026-05-03 19:40:18', '', NULL, ''),
	(2080, '考勤配置', 2012, 3, 'config', 'business/attendance/config', NULL, 'AttendanceConfig', 1, 0, 'C', '0', '0', 'all', 'business:attendance:config:list', 'form', 'admin', '2026-05-06 00:00:32', 'admin', '2026-05-06 17:24:35', '考勤配置菜单'),
	(2081, '配置查询', 2080, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:config:query', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2082, '配置新增', 2080, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:config:add', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2083, '配置修改', 2080, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:config:edit', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2084, '配置删除', 2080, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:attendance:config:remove', '#', 'admin', '2026-05-06 00:00:32', '', NULL, ''),
	(2085, '方案修改', 2076, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:edit', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2086, '方案删除', 2076, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:remove', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2087, '提交审核', 2076, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:plan:submitAudit', '#', 'admin', '2026-05-06 23:01:44', '', NULL, ''),
	(2088, '操作提交', 2065, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:operation', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(2089, '还款', 2065, 8, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:repayment', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(2090, '还款审核', 2065, 9, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:repaymentAudit', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(2091, '档案新增', 2065, 10, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:archiveAdd', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(2092, '档案删除', 2065, 11, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:archiveRemove', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(2093, '订单取消', 2065, 12, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:cancel', '#', 'admin', '2026-06-28 22:32:10', '', NULL, ''),
	(3000, '财务管理', 0, 3, 'finance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'money', 'admin', '2026-05-18 18:03:48', NULL, NULL, '财务管理目录'),
	(3001, '方案审核', 3000, 1, 'planAudit', 'finance/planAudit/index', NULL, NULL, 1, 0, 'C', '0', '0', 'all', 'finance:planAudit:list', 'edit', 'admin', '2026-05-18 18:03:48', NULL, NULL, '方案审核菜单'),
	(3002, '报销管理', 3000, 2, 'reimbursement', 'finance/reimbursement/index', NULL, NULL, 1, 0, 'C', '0', '0', 'all', 'finance:reimbursement:list', 'form', 'admin', '2026-05-18 18:03:48', NULL, NULL, '报销管理菜单'),
	(3003, '报销统计', 3000, 3, 'reimbursementReport', 'finance/reimbursementReport/index', NULL, NULL, 1, 0, 'C', '0', '0', 'all', 'finance:reimbursementReport:list', 'chart', 'admin', '2026-05-18 18:03:48', NULL, NULL, '报销统计菜单'),
	(3004, '方案审核查询', 3001, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:planAudit:query', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3005, '方案审核操作', 3001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:planAudit:audit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3006, '报销查询', 3002, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:query', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3007, '报销新增', 3002, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:add', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3008, '报销编辑', 3002, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:edit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3009, '报销删除', 3002, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:remove', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3010, '报销审核', 3002, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:audit', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3011, '报销支付', 3002, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:pay', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3012, '报销导出', 3002, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'finance:reimbursement:export', '#', 'admin', '2026-05-18 18:03:48', NULL, NULL, ''),
	(3013, 'App菜单配置', 1, 9, 'appMenu', 'system/appMenu/index', NULL, 'AppMenu', 1, 0, 'C', '0', '0', 'all', 'system:appMenu:list', 'phone', 'admin', '2026-05-20 22:41:43', '', NULL, 'App移动端菜单配置菜单'),
	(3014, 'App菜单查询', 3013, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:appMenu:query', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3015, 'App菜单新增', 3013, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:appMenu:add', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3016, 'App菜单修改', 3013, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:appMenu:edit', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3017, 'App菜单删除', 3013, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:appMenu:remove', '#', 'admin', '2026-05-20 22:41:43', '', NULL, ''),
	(3018, '轮播图管理', 1, 8, 'banner', 'system/banner/index', NULL, 'Banner', 1, 0, 'C', '0', '0', 'all', 'system:banner:list', 'swagger', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3019, '轮播图查询', 3018, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:banner:query', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3020, '轮播图新增', 3018, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:banner:add', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3021, '轮播图修改', 3018, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:banner:edit', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3022, '轮播图删除', 3018, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:banner:remove', '#', 'admin', '2026-05-25 12:12:44', '', NULL, ''),
	(3023, '行政管理', 0, 4, 'admin', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'clipboard', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3024, '问题反馈', 3023, 1, 'feedback', 'admin/feedback/index', NULL, 'AdminFeedback', 1, 0, 'C', '0', '0', 'all', 'admin:feedback:list', 'message', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3025, '反馈查询', 3024, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'admin:feedback:query', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3026, '反馈新增', 3024, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'admin:feedback:add', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3027, '反馈修改', 3024, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'admin:feedback:edit', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3028, '反馈删除', 3024, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'admin:feedback:remove', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3029, '反馈处理', 3024, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'admin:feedback:handle', '#', 'admin', '2026-05-30 13:09:54', '', NULL, ''),
	(3031, '考勤打卡', 2012, 1, 'attendanceClock', NULL, NULL, NULL, 1, 0, 'C', '0', '0', 'app', 'business:attendance:clock', 'clock', 'admin', '2026-05-31 21:55:35', 'admin', '2026-06-01 17:49:00', ''),
	(3034, '卡项管理', 3000, 4, 'cardItem', 'business/cardItem/index', NULL, 'CardItem', 1, 0, 'C', '0', '0', 'all', 'business:cardItem:list', 'component', 'admin', '2026-06-01 08:51:00', 'admin', '2026-06-01 17:53:01', ''),
	(3035, '卡项查询', 3034, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:query', '#', 'admin', '2026-06-01 08:51:00', '', NULL, ''),
	(3036, '卡项新增', 3034, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:add', '#', 'admin', '2026-06-01 08:51:00', '', NULL, ''),
	(3037, '卡项修改', 3034, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:edit', '#', 'admin', '2026-06-01 08:51:00', '', NULL, ''),
	(3038, '卡项删除', 3034, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:cardItem:remove', '#', 'admin', '2026-06-01 08:51:00', '', NULL, ''),
	(3044, '企业备货', 2000, 5, 'stockPrepare', 'business/stockPrepare/index', NULL, 'StockPrepare', 1, 0, 'C', '0', '0', 'all', 'business:stockPrepare:list', 'component', 'admin', '2026-06-01 19:05:41', 'admin', '2026-06-06 12:34:10', ''),
	(3045, '备货查询', 3044, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:query', '#', 'admin', '2026-06-01 19:05:41', '', NULL, ''),
	(3046, '备货出库', 3044, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:stockPrepare:createStockOut', '#', 'admin', '2026-06-01 19:05:41', '', NULL, ''),
	(3058, '客户管理', 2000, 9, 'customer', NULL, NULL, 'AppCustomer', 1, 0, 'C', '0', '0', 'app', 'business:customer:list', 'account', 'admin', '2026-06-05 23:18:57', '', NULL, ''),
	(3059, '客户新增', 3058, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:add', '#', 'admin', '2026-06-05 23:18:57', '', NULL, ''),
	(3060, '客户修改', 3058, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:edit', '#', 'admin', '2026-06-05 23:18:58', '', NULL, ''),
	(3061, '客户删除', 3058, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:customer:remove', '#', 'admin', '2026-06-05 23:18:58', '', NULL, ''),
	(3066, '系统配置', 1, 9, 'sysConfig', 'system/sysConfig/index', NULL, 'SysConfig', 1, 0, 'C', '0', '0', 'all', 'system:sysConfig:list', 'edit', 'admin', '2026-06-08 13:31:42', '', NULL, ''),
	(3067, '仓库管理', 2021, 8, 'warehouse', 'wms/warehouse/index', NULL, 'WmsWarehouse', 1, 0, 'C', '0', '0', 'all', 'wms:warehouse:list', 'build', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3068, '仓库查询', 3067, 1, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:warehouse:query', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3069, '仓库新增', 3067, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:warehouse:add', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3070, '仓库修改', 3067, 3, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:warehouse:edit', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3071, '仓库删除', 3067, 4, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:warehouse:remove', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3072, '调拨管理', 2021, 9, 'stockTransfer', 'wms/stockTransfer/index', NULL, 'WmsStockTransfer', 1, 0, 'C', '0', '0', 'all', 'wms:transfer:list', 'switch', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3073, '调拨查询', 3072, 1, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:transfer:query', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3074, '调拨新增', 3072, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:transfer:add', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3075, '调拨修改', 3072, 3, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:transfer:edit', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3076, '调拨删除', 3072, 4, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:transfer:remove', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3077, '调拨确认', 3072, 5, '', '', NULL, '', 1, 0, 'F', '0', '0', 'all', 'wms:transfer:confirm', '#', 'admin', '2026-06-19 13:14:30', '', NULL, ''),
	(3080, '数据统计', 0, 3, 'statistics', NULL, NULL, NULL, 1, 0, 'M', '0', '0', 'all', '', 'chart', 'admin', '2026-06-21 23:19:49', '', NULL, '数据统计目录'),
	(3081, '业绩统计', 3080, 1, 'performance', 'statistics/performance/index', NULL, 'PerformanceStats', 1, 0, 'C', '0', '0', 'all', 'statistics:performance:list', 'peoples', 'admin', '2026-06-21 23:19:49', '', NULL, '业绩统计菜单'),
	(3082, '企业业绩', 3080, 2, 'enterprise', 'statistics/enterprise/index', NULL, 'EnterpriseStats', 1, 0, 'C', '0', '0', 'all', 'statistics:enterprise:list', 'build', 'admin', '2026-06-21 23:19:49', '', NULL, '企业业绩菜单'),
	(3083, '数据库备份', 1, 10, 'dbBackup', 'system/backup/index', NULL, 'DbBackup', 1, 0, 'C', '0', '0', 'all', 'system:backup:list', 'upload', 'admin', '2026-06-21 23:58:36', '', NULL, '数据库备份菜单'),
	(3084, '员工配置列表', 2007, 10, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:employeeConfig:list', '#', 'admin', '2026-06-27 01:03:16', '', NULL, '员工配置查询（行程安排页内嵌功能）'),
	(3085, '员工配置修改', 2007, 11, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:employeeConfig:edit', '#', 'admin', '2026-06-27 01:03:16', '', NULL, '员工配置修改（可排班/休息日期）'),
	(3086, '还款取消', 2065, 13, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:repaymentCancel', '#', 'admin', '2026-06-28 23:47:17', '', NULL, ''),
	(3087, '操作记录删除', 2065, 14, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:sales:operationRemove', '#', 'admin', '2026-06-28 23:47:17', '', NULL, ''),
	(3088, '订单取消', 2072, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:cancel', '#', 'admin', '2026-06-28 23:47:17', '', NULL, ''),
	(3089, '订单导出', 2072, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'business:order:export', '#', 'admin', '2026-06-28 23:47:17', '', NULL, ''),
	(3090, '备份下载', 3083, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'all', 'system:backup:download', '#', 'admin', '2026-07-01 11:13:16', NULL, NULL, '');
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

-- 正在导出表  fuchenpro.sys_notice 的数据：~3 rows (大约)
DELETE FROM `sys_notice`;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
INSERT INTO `sys_notice` (`notice_id`, `notice_title`, `notice_type`, `notice_content`, `status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(2, '维护通知：2018-07-01 若依系统凌晨维护', '1', _binary 0x3C703EE7BBB4E68AA4E58685E5AEB931313C2F703E, '0', 'admin', '2026-04-25 01:10:54', 'admin', '2026-06-26 22:59:49', '管理员'),
	(11, '今晚开会', '1', _binary 0x3C703E3C696D67207372633D222F70726F66696C652F75706C6F61642F32303236303632362F38643239376264363762613532646434343961353431323563396334346636652E6A70672220616C743D2222207374796C653D226D61782D77696474683A20313030253B206865696768743A206175746F3B2077696474683A20313030253B223EE4BB8AE6999AE8A681E5BC80E4BC9AE4BA86EFBC81EFBC81EFBC81EFBC813231313C696D67207372633D222F70726F66696C652F75706C6F61642F32303236303632362F31663866646539316263616662393736636535663232366137646239393261322E706E67223E3C2F703E, '0', 'admin', '2026-05-24 20:19:42', 'admin', '2026-06-26 22:53:02', NULL),
	(12, '赛诺第一季度业绩爆红', '1', _binary 0x3C703EE6849FE8B0A2E5A4A7E5AEB6E4B880E5ADA3E5BAA6E4BBA5E69DA5E585B1E5908CE79A84E58AAAE58A9BEFBC8C36E69C8831E697A531393A3030E68891E4BBACE8819AE9A490E78B82E6ACA2EFBC8CE4B88DE98689E4B88DE5BD92EFBC81313C696D67207372633D2268747470733A2F2F6D79647265616D2D313330323638323831332E636F732E61702D7368616E676861692E6D7971636C6F75642E636F6D2F75706C6F61642F32303236303532392F66343136626161373134376161343731346535336534646236343932633261312E6A7067223E3C2F703E, '0', 'admin', '2026-05-29 15:40:52', 'admin', '2026-06-26 22:38:36', NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='公告已读记录表';

-- 正在导出表  fuchenpro.sys_notice_read 的数据：~6 rows (大约)
DELETE FROM `sys_notice_read`;
/*!40000 ALTER TABLE `sys_notice_read` DISABLE KEYS */;
INSERT INTO `sys_notice_read` (`read_id`, `notice_id`, `user_id`, `read_time`) VALUES
	(2, 2, 1, '2026-05-24 20:18:38'),
	(4, 11, 1, '2026-05-24 20:19:57'),
	(5, 12, 1, '2026-05-29 15:41:14'),
	(6, 11, 103, '2026-06-28 23:45:25'),
	(7, 2, 103, '2026-06-28 23:45:45'),
	(8, 12, 103, '2026-06-28 23:49:48');
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
) ENGINE=InnoDB AUTO_INCREMENT=613 DEFAULT CHARSET=utf8 COMMENT='操作日志记录';

-- 正在导出表  fuchenpro.sys_oper_log 的数据：~454 rows (大约)
DELETE FROM `sys_oper_log`;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
INSERT INTO `sys_oper_log` (`oper_id`, `title`, `business_type`, `method`, `request_method`, `operator_type`, `oper_name`, `dept_name`, `oper_url`, `oper_ip`, `oper_location`, `oper_param`, `json_result`, `status`, `error_msg`, `oper_time`, `cost_time`) VALUES
	(100, '系统操作', 1, '/business/store', 'POST', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","storeName":"测试1","annualPerformance":0,"regularCustomers":0,"creatorName":"若依","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:00:46', 64),
	(101, '门店管理', 1, '/business/store', 'POST', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","storeName":"门顶上","annualPerformance":0,"regularCustomers":0,"creatorName":"若依","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:24:40', 90),
	(102, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":101,"configName":"登录过期时间","configKey":"sys.login.expireTime","configValue":"1440","configType":"Y","remark":"Token有效期（分钟），影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 53),
	(103, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":102,"configName":"启用腾讯云COS","configKey":"sys.cos.enabled","configValue":"true","configType":"Y","remark":"是否启用腾讯云对象存储"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 10),
	(104, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":103,"configName":"腾讯云SecretId","configKey":"sys.cos.secretId","configValue":"","configType":"Y","remark":"腾讯云COS SecretId"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 14),
	(105, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":104,"configName":"腾讯云SecretKey","configKey":"sys.cos.secretKey","configValue":"","configType":"Y","remark":"腾讯云COS SecretKey"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 12),
	(106, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":105,"configName":"COS存储桶名称","configKey":"sys.cos.bucket","configValue":"mydream-1302682813","configType":"Y","remark":"腾讯云COS存储桶名称"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 12),
	(107, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":106,"configName":"COS地域","configKey":"sys.cos.region","configValue":"ap-shanghai","configType":"Y","remark":"腾讯云COS地域"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 11),
	(108, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":107,"configName":"COS自定义域名","configKey":"sys.cos.domain","configValue":"","configType":"Y","remark":"腾讯云COS自定义域名"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 16),
	(109, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":112,"configName":"高德Web服务Key","configKey":"sys.amap.webServiceKey","configValue":"d184e115457658cbcf3f92ed8e3a1772","configType":"Y","remark":"高德地图Web服务API Key，用于逆地理编码和IP定位"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 12),
	(110, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":113,"configName":"高德JS API Key","configKey":"sys.amap.jsKey","configValue":"fa588d6bc9fbc9dce1f0c379e40f9faa","configType":"Y","remark":"高德地图JS API Key，用于前端地图组件加载"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 3),
	(111, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":114,"configName":"高德安全密钥","configKey":"sys.amap.securityJsCode","configValue":"19ef226bdd6e4a6276d45ed1e5cb9a475","configType":"Y","remark":"高德地图JS API安全密钥"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 16),
	(112, '参数管理', 3, '/system/config/refreshCache', 'DELETE', 1, 'admin', '', '//localhost:8787/system/config/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 12:47:56', 11),
	(113, '销售管理', 1, '/business/sales/cancel', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/cancel', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":500,"msg":"取消失败，仅待确认订单可取消"}', 1, '取消失败，仅待确认订单可取消', '2026-06-21 14:11:25', 1),
	(114, '反馈管理', 1, '/admin/feedback', 'POST', 1, 'admin', '', '//localhost:8787/admin/feedback', '127.0.0.1', '内网IP', '{"title":"测试","feedbackType":"0","content":"防守打法施工分公司答复是打发谁"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 14:11:56', 26),
	(115, '反馈管理', 1, '/admin/feedback/reply', 'POST', 1, 'admin', '', '//localhost:8787/admin/feedback/reply', '127.0.0.1', '内网IP', '{"feedbackId":"2","content":"放松放松东方闪电"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 14:12:12', 23),
	(116, '反馈管理', 1, '/admin/feedback/reply', 'POST', 1, 'admin', '', '//localhost:8787/admin/feedback/reply', '127.0.0.1', '内网IP', '{"feedbackId":"2","content":"服务费第三方"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-21 14:12:17', 22),
	(117, '系统操作', 1, '/statistics/performance/exportStore', 'POST', 1, 'admin', '', '//localhost:8787/statistics/performance/exportStore', '127.0.0.1', '内网IP', '{"startDate":"2026-01-01","endDate":"2026-09-27"}', '', 0, '', '2026-06-21 23:22:14', 149),
	(118, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-21 23:59:02', 1283),
	(119, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:19:59', 1),
	(120, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:20:03', 1),
	(121, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:20:08', 1),
	(122, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:20:35', 1),
	(123, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-22 00:21:19', 889),
	(124, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:21:23', 1),
	(125, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-22 00:28:33', 876),
	(126, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:28:40', 1),
	(127, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:28:42', 1),
	(128, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"3"}', '', 0, '', '2026-06-22 00:29:09', 2),
	(129, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"2"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:29:12', 1),
	(130, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"1"}', '{"code":500,"msg":"备份文件不可下载"}', 1, '备份文件不可下载', '2026-06-22 00:29:15', 1),
	(131, '系统操作', 3, '/system/backup', 'DELETE', 1, 'admin', '', '//localhost:8787/system/backup?backupIds=1', '127.0.0.1', '内网IP', '{"backupIds":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 00:34:24', 23),
	(132, '系统操作', 3, '/system/backup', 'DELETE', 1, 'admin', '', '//localhost:8787/system/backup?backupIds=2', '127.0.0.1', '内网IP', '{"backupIds":"2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 00:34:28', 15),
	(133, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"3"}', '', 0, '', '2026-06-22 00:34:29', 2),
	(134, '系统操作', 3, '/system/backup', 'DELETE', 1, 'admin', '', '//localhost:8787/system/backup?backupIds=3', '127.0.0.1', '内网IP', '{"backupIds":"3"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 00:34:34', 17),
	(135, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-22 00:34:41', 904),
	(136, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"4"}', '', 0, '', '2026-06-22 00:35:12', 26),
	(137, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"4"}', '', 0, '', '2026-06-22 00:35:19', 1),
	(138, '系统操作', 3, '/system/backup', 'DELETE', 1, 'admin', '', '//localhost:8787/system/backup?backupIds=4', '127.0.0.1', '内网IP', '{"backupIds":"4"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 00:36:30', 120),
	(139, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-22 00:36:33', 782),
	(140, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '', 0, '', '2026-06-22 00:36:39', 2),
	(141, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '', 0, '', '2026-06-22 00:36:48', 1),
	(142, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '', 0, '', '2026-06-22 00:36:56', 1),
	(143, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:41:43', 8),
	(144, '系统操作', 1, '/system/backup/execute', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/execute', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"备份成功"}', 0, '', '2026-06-22 00:41:49', 795),
	(145, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:41:52', 1),
	(146, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:42:05', 1),
	(147, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:42:06', 1),
	(148, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:42:13', 1),
	(149, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:42:21', 1),
	(150, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:42:30', 1),
	(151, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 00:43:58', 1),
	(152, '系统操作', 1, '/system/backup/download', 'POST', 1, 'admin', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"5"}', '', 0, '', '2026-06-22 00:44:09', 2),
	(153, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'admin', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 01:52:55', 3),
	(154, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"温馨提醒：2018-07-01111 若依新版本发布啦","noticeType":"2","status":"0","noticeContent":"新版本内容","noticeId":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-22 01:53:13', 77),
	(155, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":2,"noticeTitle":"维护通知：2018-07-01 若依系统凌晨维护","noticeType":"1","noticeContent":"<p>维护内容111<\\/p>","status":"0","createBy":"admin","createTime":"2026-04-25 01:10:54","updateBy":"","updateTime":null,"remark":"管理员","createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 01:54:39', 7),
	(156, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":2,"noticeTitle":"维护通知：2018-07-01 若依系统凌晨维护","noticeType":"1","noticeContent":"<p>维护内容111<\\/p>","status":"0","createBy":"admin","createTime":"2026-04-25 01:10:54","updateBy":"","updateTime":null,"remark":"管理员","createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-22 01:55:35', 1),
	(157, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"serverUserName":[],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 01:46:53', 77),
	(158, '部门管理', 2, '/system/dept', 'PUT', 1, 'admin', '', '//localhost:8787/system/dept', '127.0.0.1', '内网IP', '{"deptId":100,"parentId":0,"deptName":"赛诺美生","orderNum":0,"leader":"汪志","phone":"15888888888","email":"ry@qq.com","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:33:34', 112),
	(159, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":12,"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-29 15:40:52","updateBy":"admin","updateTime":"2026-06-08 00:34:14","remark":null,"createNickName":"若依"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:38:07', 16),
	(160, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"今晚开会","noticeType":"1","status":"0","noticeContent":"<p>今晚要开会了！！！！<img src=\\"https:\\/\\/synolife-1443627946.cos.ap-shanghai.myqcloud.com\\/upload\\/20260626\\/8f23e80be7f5fce0fa88f6e852bdea1a.jpg\\" alt=\\"图片\\" style=\\"max-width: 100%; height: auto; width: 100%;\\"><br><\\/p>","noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:39:05', 96),
	(161, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":null,"longitude":null,"address":"77","photo":""}', '{"code":200,"msg":"打卡成功","data":{"recordId":7,"userId":1,"userName":"若依","attendanceDate":"2026-06-26","clockInTime":"2026-06-26 02:09:44","clockOutTime":"2026-06-26 02:39:47","clockInLatitude":null,"clockInLongitude":null,"clockInAddress":"定位失败","clockInPhoto":"","clockOutLatitude":null,"clockOutLongitude":null,"clockOutAddress":"77","clockOutPhoto":"","attendanceStatus":"2","clockCount":2,"firstClockTime":"2026-06-26 02:09:44","lastClockTime":"2026-06-26 02:39:47","clockType":"0","outsideReason":"","ruleId":null,"remark":"","createBy":"若依","createTime":"2026-06-26 02:09:44","updateBy":"","updateTime":"2026-06-26 02:39:47"}}', 0, '', '2026-06-26 02:39:47', 33),
	(162, '客户管理', 2, '/business/customer', 'PUT', 1, 'admin', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerId":1,"customerName":"客户1","phone":"","wechat":"","gender":"1","age":55,"tag":"normal","remark":"俄文","enterpriseId":7,"enterpriseName":"终测1","storeId":8,"storeName":"终测门店2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:41:45', 104),
	(163, '客户管理', 1, '/business/customer/avatar', 'POST', 1, 'admin', '', '//localhost:8787/business/customer/avatar', '127.0.0.1', '内网IP', '{"customer_id":"1"}', '{"code":200,"msg":"","imgUrl":"https:\\/\\/synolife-1443627946.cos.ap-shanghai.myqcloud.com\\/customer_avatar\\/ad25eceeac53e52b75f3a4ef031c90c3.jpg"}', 0, '', '2026-06-26 02:41:45', 336),
	(164, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":101,"configName":"登录过期时间","configKey":"sys.login.expireTime","configValue":"1440","configType":"Y","remark":"Token有效期（分钟），影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 67),
	(165, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":119,"configName":"令牌续期阈值","configKey":"sys.login.tokenRefreshThreshold","configValue":"20","configType":"Y","remark":"令牌剩余有效期低于此值时自动续期（分钟）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(166, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":102,"configName":"启用腾讯云COS","configKey":"sys.cos.enabled","configValue":"true","configType":"Y","remark":"是否启用腾讯云对象存储"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 7),
	(167, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":103,"configName":"腾讯云SecretId","configKey":"sys.cos.secretId","configValue":"","configType":"Y","remark":"腾讯云COS SecretId"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 14),
	(168, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":104,"configName":"腾讯云SecretKey","configKey":"sys.cos.secretKey","configValue":"","configType":"Y","remark":"腾讯云COS SecretKey"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 14),
	(169, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":105,"configName":"COS存储桶名称","configKey":"sys.cos.bucket","configValue":"mydream-1302682813","configType":"Y","remark":"腾讯云COS存储桶名称"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 14),
	(170, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":106,"configName":"COS地域","configKey":"sys.cos.region","configValue":"ap-shanghai","configType":"Y","remark":"腾讯云COS地域"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 14),
	(171, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":107,"configName":"COS自定义域名","configKey":"sys.cos.domain","configValue":"","configType":"Y","remark":"腾讯云COS自定义域名"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(172, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":4,"configName":"账号自助-验证码开关","configKey":"sys.account.captchaEnabled","configValue":"true","configType":"Y","remark":"是否开启验证码功能（true开启，false关闭）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(173, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":115,"configName":"验证码有效期","configKey":"sys.security.captchaExpire","configValue":"2","configType":"Y","remark":"验证码有效期（分钟）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 16),
	(174, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":116,"configName":"密码最大错误次数","configKey":"sys.security.pwdErrMaxCount","configValue":"5","configType":"Y","remark":"密码错误超过此次数后锁定账户"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 16),
	(175, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":117,"configName":"密码锁定时间","configKey":"sys.security.pwdErrLockTime","configValue":"10","configType":"Y","remark":"密码错误锁定时间（分钟）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 7),
	(176, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":9,"configName":"用户管理-密码字符范围","configKey":"sys.account.chrtype","configValue":"0","configType":"Y","remark":"默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 14),
	(177, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":7,"configName":"用户管理-初始密码修改策略","configKey":"sys.account.initPasswordModify","configValue":"1","configType":"Y","remark":"0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(178, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":8,"configName":"用户管理-账号密码更新周期","configKey":"sys.account.passwordValidateDays","configValue":"0","configType":"Y","remark":"密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(179, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":118,"configName":"用户初始密码","configKey":"sys.security.initPassword","configValue":"123456","configType":"Y","remark":"新建用户和重置密码时的默认密码"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 13),
	(180, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":6,"configName":"用户登录-黑名单列表","configKey":"sys.login.blackIPList","configValue":"","configType":"Y","remark":"设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:03', 15),
	(181, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":112,"configName":"高德Web服务Key","configKey":"sys.amap.webServiceKey","configValue":"d184e115457658cbcf3f92ed8e3a1772","configType":"Y","remark":"高德地图Web服务API Key，用于逆地理编码和IP定位"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:04', 15),
	(182, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":113,"configName":"高德JS API Key","configKey":"sys.amap.jsKey","configValue":"fa588d6bc9fbc9dce1f0c379e40f9faa","configType":"Y","remark":"高德地图JS API Key，用于前端地图组件加载"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:04', 15),
	(183, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":114,"configName":"高德安全密钥","configKey":"sys.amap.securityJsCode","configValue":"19ef226bdd6e4a6276d45ed1e5cb9a475","configType":"Y","remark":"高德地图JS API安全密钥"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:04', 14),
	(184, '参数管理', 3, '/system/config/refreshCache', 'DELETE', 1, 'admin', '', '//localhost:8787/system/config/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:43:04', 7),
	(185, '用户管理', 2, '/system/user', 'PUT', 1, 'admin', '', '//localhost:8787/system/user', '127.0.0.1', '内网IP', '{"userId":103,"deptId":101,"userName":"pengpeng","nickName":"鹏鹏","userType":"00","email":"","phonenumber":"","sex":"0","avatar":"","status":"0","delFlag":"0","loginIp":"127.0.0.1","loginDate":"2026-06-03 15:17:16","pwdUpdateDate":null,"createBy":"admin","createTime":"2026-06-03 15:16:56","updateBy":"","updateTime":null,"remark":null,"postIds":[2],"roleIds":[100]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:47:23', 65),
	(186, '用户详情', 1, '/system/user/detail', 'POST', 1, 'admin', '', '//localhost:8787/system/user/detail', '127.0.0.1', '内网IP', '{"detailId":null,"userId":103,"wechat":"","birthday":null,"idCard":"","address":"","hireDate":null,"employmentStatus":"0","resignDate":null,"remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:47:23', 9),
	(187, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"测试角色","roleKey":"1","roleSort":3,"dataScope":"1","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"","updateTime":null,"remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,2012,2002,2003,2008,2009,2015,2016,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,3045,3059]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 02:48:55', 94),
	(188, '报销管理', 1, '/finance/reimbursement/audit', 'POST', 1, 'admin', '', '//localhost:8787/finance/reimbursement/audit', '127.0.0.1', '内网IP', '{"reimbursementId":4,"passed":true,"auditRemark":""}', '{"code":200,"msg":"审核成功"}', 0, '', '2026-06-26 07:19:23', 22),
	(189, '报销管理', 1, '/finance/reimbursement/audit', 'POST', 1, 'admin', '', '//localhost:8787/finance/reimbursement/audit', '127.0.0.1', '内网IP', '{"reimbursementId":6,"passed":true,"auditRemark":""}', '{"code":200,"msg":"审核成功"}', 0, '', '2026-06-26 07:19:27', 16),
	(190, '报销管理', 1, '/finance/reimbursement/audit', 'POST', 1, 'admin', '', '//localhost:8787/finance/reimbursement/audit', '127.0.0.1', '内网IP', '{"reimbursementId":7,"passed":true,"auditRemark":""}', '{"code":200,"msg":"审核成功"}', 0, '', '2026-06-26 07:19:29', 21),
	(191, '报销管理', 1, '/finance/reimbursement', 'POST', 1, 'admin', '', '//localhost:8787/finance/reimbursement', '127.0.0.1', '内网IP', '{"applyDate":"2026-06-25","category":"4","expenseAmount":555,"incomeAmount":0,"expenseType":"1","voucherImages":"","remark":""}', '{"code":200,"msg":"新增成功","data":{"applyDate":"2026-06-25","category":"4","expenseAmount":"555.00","incomeAmount":"0.00","expenseType":"1","voucherImages":"","remark":"","applicantId":1,"applicantName":"若依","deptId":103,"deptName":"事业1部","createBy":"若依","reimbursementNo":"BX202606260001","status":"0","createTime":"2026-06-26 07:23:44","reimbursementId":17}}', 0, '', '2026-06-26 07:23:44', 110),
	(192, '报销管理', 1, '/finance/reimbursement/audit', 'POST', 1, 'admin', '', '//localhost:8787/finance/reimbursement/audit', '127.0.0.1', '内网IP', '{"reimbursementId":17,"passed":true,"auditRemark":""}', '{"code":200,"msg":"审核成功"}', 0, '', '2026-06-26 07:23:48', 19),
	(193, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":12,"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！1<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-29 15:40:52","updateBy":"admin","updateTime":"2026-06-26 02:38:07","remark":null,"createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 07:35:28', 7),
	(194, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 07:35:47', 2),
	(195, '供货商管理', 2, '/wms/supplier', 'PUT', 1, 'admin', '', '//localhost:8787/wms/supplier', '127.0.0.1', '内网IP', '{"supplierId":1,"supplierName":"供货商1","contactPerson":null,"contactPhone":null,"address":null,"cooperationStartDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-26 02:26:44","updateBy":"","updateTime":"2026-06-26 02:26:44"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 07:37:10', 1),
	(196, '货品管理', 2, '/wms/product', 'PUT', 1, 'admin', '', '//localhost:8787/wms/product', '127.0.0.1', '内网IP', '{"productId":2,"productName":"测试1","productCode":"CS1-20260504","supplierId":1,"spec":"1","packQty":10,"category":"1","unit":"5","purchasePrice":6800,"salePrice":6800,"salePriceSpec":680,"shelfLifeDays":null,"hasExpiry":"0","warnQty":20,"status":"0","remark":null,"createBy":"admin","createTime":"2026-05-05 00:11:54","updateBy":"admin","updateTime":"2026-06-26 02:26:50"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 07:38:03', 1),
	(197, '客户管理', 1, '/business/customer', 'POST', 1, 'admin', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerName":"111","enterpriseId":7,"storeId":8,"status":"0","gender":"1"}', '{"code":200,"msg":"","customerId":2}', 0, '', '2026-06-26 07:40:01', 113),
	(198, '客户管理', 1, '/business/customer/avatar', 'POST', 1, 'admin', '', '//localhost:8787/business/customer/avatar', '127.0.0.1', '内网IP', '{"customer_id":"2"}', '{"code":200,"msg":"","imgUrl":"\\/profile\\/customer_avatar\\/b9f32df95027f927b827580f8471d45f.jpg"}', 0, '', '2026-06-26 07:40:01', 11),
	(199, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","pinyin":"2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"serverUserName":null,"cooperationStartDate":null,"cooperationEndDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 11:19:25","updateBy":"admin","updateTime":"2026-06-26 02:08:57"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 09:53:46', 100),
	(200, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","pinyin":"2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":"0.00","enterpriseLevel":"3","serverUserId":[1,2],"serverUserName":"","cooperationStartDate":null,"cooperationEndDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 11:19:25","updateBy":"admin","updateTime":"2026-06-26 09:53:45"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 09:53:52', 32),
	(201, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":12,"enterpriseId":8,"enterpriseName":"终测2","storeName":"门顶上","managerName":null,"phone":null,"wechat":null,"address":null,"annualPerformance":0,"regularCustomers":0,"creatorName":"若依","serverUserId":[2,100],"serverUserName":"若人头、测试","status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 12:24:40","updateBy":"","updateTime":"2026-06-21 12:24:40"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 09:54:01', 30),
	(202, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"serverUserName":[],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 11:26:02', 113),
	(203, '卡项管理', 2, '/business/cardItem', 'PUT', 1, 'admin', '', '//localhost:8787/business/cardItem', '127.0.0.1', '内网IP', '{"cardItemId":1,"cardItemName":"卡项1","cardItemCode":"KX1-20260601","category":"2","defaultQuantity":10,"suggestedPrice":"9380.00","defaultUnitPrice":"938.00","status":"0","remark":null,"products":[{"productId":1,"unitType":"2","packQty":10,"quantity":10},{"productId":2,"unitType":"2","packQty":10,"quantity":10}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 11:27:40', 108),
	(204, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","status":"0","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 11:27:59', 83),
	(205, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":12,"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-29 15:40:52","updateBy":"admin","updateTime":"2026-06-26 11:27:59","remark":null,"createNickName":"若依"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 11:59:51', 111),
	(206, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":11,"noticeTitle":"今晚开会","noticeType":"1","noticeContent":"<p>今晚要开会了！！！！<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-24 20:19:42","updateBy":"admin","updateTime":"2026-06-26 02:39:05","remark":null,"createNickName":"若依"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 12:00:10', 77),
	(207, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","status":"0","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！1<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 12:00:23', 11),
	(208, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'admin', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 12:00:26', 1),
	(209, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'admin', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 12:00:26', 1),
	(210, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"没有可新增的排班数据"}', 1, '没有可新增的排班数据', '2026-06-26 12:04:22', 0),
	(211, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"没有可新增的排班数据"}', 1, '没有可新增的排班数据', '2026-06-26 13:09:54', 0),
	(212, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"今晚开会","noticeType":"1","status":"0","noticeContent":"<p>今晚要开会了！！！！<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 13:21:31', 91),
	(213, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.212969,"longitude":121.478334,"address":"顺昌路504弄小区","photo":""}', '{"code":200,"msg":"打卡成功","data":{"recordId":7,"userId":1,"userName":"若依","attendanceDate":"2026-06-26","clockInTime":"2026-06-26 02:09:44","clockOutTime":"2026-06-26 17:17:54","clockInLatitude":null,"clockInLongitude":null,"clockInAddress":"定位失败","clockInPhoto":"","clockOutLatitude":"31.2129690","clockOutLongitude":"121.4783340","clockOutAddress":"顺昌路504弄小区","clockOutPhoto":"","attendanceStatus":"2","clockCount":3,"firstClockTime":"2026-06-26 02:09:44","lastClockTime":"2026-06-26 17:17:54","clockType":"0","outsideReason":"","ruleId":null,"remark":"","createBy":"若依","createTime":"2026-06-26 02:09:44","updateBy":"","updateTime":"2026-06-26 17:17:54"}}', 0, '', '2026-06-26 17:17:54', 43),
	(214, '通知公告', 3, '/system/notice', 'DELETE', 1, 'admin', '', '//localhost:8787/system/notice?noticeId=3', '127.0.0.1', '内网IP', '{"noticeId":"3"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-26 17:18:41', 1),
	(215, '通知公告', 3, '/system/notice', 'DELETE', 1, 'admin', '', '//localhost:8787/system/notice?noticeId=3', '127.0.0.1', '内网IP', '{"noticeId":"3"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-26 17:18:43', 1),
	(216, '通知公告', 3, '/system/notice', 'DELETE', 1, 'admin', '', '//localhost:8787/system/notice?noticeId=2', '127.0.0.1', '内网IP', '{"noticeId":"2"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-26 17:18:45', 1),
	(217, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"今晚开会","noticeType":"1","status":"0","noticeContent":"<p>今晚要开会了！！！！2<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:18:57', 52),
	(218, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'admin', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"3"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:19:01', 1),
	(219, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=12%2C13%2C9%2C10', '127.0.0.1', '内网IP', '{"scheduleIds":"12,13,9,10"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:22:04', 85),
	(220, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-21","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-22","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-23","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-24","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-25","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-26","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:22:04', 17),
	(221, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=19%2C18%2C17%2C16%2C15%2C14', '127.0.0.1', '内网IP', '{"scheduleIds":"19,18,17,16,15,14"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:22:13', 54),
	(222, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-23","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-24","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-25","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-26","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 17:22:13', 22),
	(223, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=23%2C22%2C21%2C20', '127.0.0.1', '内网IP', '{"scheduleIds":"23,22,21,20"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 20:02:37', 32),
	(224, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-23","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-24","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-25","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-26","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 20:02:37', 20),
	(225, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:09', 9),
	(226, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:10', 1),
	(227, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:10', 1),
	(228, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:14', 1),
	(229, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:14', 1),
	(230, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:19', 1),
	(231, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:20', 1),
	(232, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:20', 1),
	(233, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateTolerance":0,"earlyLeaveTolerance":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '', 0, '', '2026-06-26 21:30:29', 1),
	(234, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"serverUserName":[],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:08:21', 56),
	(235, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":12,"enterpriseId":8,"storeName":"门顶上","managerName":"11","phone":null,"wechat":"11","address":null,"businessHours":null,"annualPerformance":0,"regularCustomers":0,"serverUserId":[],"serverUserName":[],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:08:34', 43),
	(236, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":"2","customerName":"111","storeId":"8","storeName":"终测门店2","enterpriseId":7,"enterpriseName":"终测1","orderStatus":"0","packageName":"11","storeDealer":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":9380,"paidAmount":9380,"paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:08:49', 36),
	(237, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":3}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:08:58', 31),
	(238, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":3}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:09:27', 96),
	(239, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"1","outsideReason":"估计快了","latitude":31.212931,"longitude":121.478264,"address":"顺昌路504弄小区","photo":"\\/profile\\/upload\\/20260626\\/d57aa17f2831c2980714aca0fd2fa3d5.jpg"}', '{"code":200,"msg":"打卡成功","data":{"recordId":7,"userId":1,"userName":"若依","attendanceDate":"2026-06-26","clockInTime":"2026-06-26 02:09:44","clockOutTime":"2026-06-26 22:22:33","clockInLatitude":null,"clockInLongitude":null,"clockInAddress":"定位失败","clockInPhoto":"","clockOutLatitude":"31.2129310","clockOutLongitude":"121.4782640","clockOutAddress":"顺昌路504弄小区","clockOutPhoto":"\\/profile\\/upload\\/20260626\\/d57aa17f2831c2980714aca0fd2fa3d5.jpg","attendanceStatus":"0","clockCount":4,"firstClockTime":"2026-06-26 02:09:44","lastClockTime":"2026-06-26 22:22:33","clockType":"0","outsideReason":"","ruleId":null,"remark":"","createBy":"若依","createTime":"2026-06-26 02:09:44","updateBy":"","updateTime":"2026-06-26 22:22:33"}}', 0, '', '2026-06-26 22:22:33', 66),
	(240, '货品管理', 2, '/wms/product', 'PUT', 1, 'admin', '', '//localhost:8787/wms/product', '127.0.0.1', '内网IP', '{"productId":2,"productName":"测试1","productCode":"CS1-20260504","supplierId":1,"spec":"1","packQty":10,"category":"1","unit":"5","purchasePrice":6800,"salePrice":6800,"salePriceSpec":680,"shelfLifeDays":null,"hasExpiry":"0","warnQty":20,"status":"0","remark":null,"createBy":"admin","createTime":"2026-05-05 00:11:54","updateBy":"admin","updateTime":"2026-06-26 02:26:50"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:29:23', 57),
	(241, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":12,"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！1<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-29 15:40:52","updateBy":"admin","updateTime":"2026-06-26 12:00:23","remark":null,"createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 22:29:51', 1),
	(242, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":12,"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！1<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-05-29 15:40:52","updateBy":"admin","updateTime":"2026-06-26 12:00:23","remark":null,"createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 22:31:46', 1),
	(243, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:31:59', 4),
	(244, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:31:59', 4),
	(245, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":26,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:31:59', 8),
	(246, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":27,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:31:59', 6),
	(247, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:32:06', 12),
	(248, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:32:06', 5),
	(249, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:32:06', 7),
	(250, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":26,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:32:06', 7),
	(251, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":27,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:32:06', 6),
	(252, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"赛诺第一季度业绩爆红","noticeType":"1","status":"0","noticeContent":"<p>感谢大家一季度以来共同的努力，6月1日19:00我们聚餐狂欢，不醉不归！1<img src=\\"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260529\\/f416baa7147aa4714e53e4db6492c2a1.jpg\\"><\\/p>","noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:38:36', 7),
	(253, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeTitle":"今晚开会","noticeType":"1","status":"0","noticeContent":"<p><img src=\\"\\/profile\\/upload\\/20260626\\/8d297bd67ba52dd449a54125c9c44f6e.jpg\\" alt=\\"\\" style=\\"max-width: 100%; height: auto; width: 100%;\\"><br>今晚要开会了！！！！2<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:38:49', 50),
	(254, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":3,"noticeTitle":"若依开源框架介绍","noticeType":"1","noticeContent":"<p><span style=\\"color: rgb(230, 0, 0);\\">项目介绍<\\/span><\\/p><p><span style=\\"color: rgb(51, 51, 51);\\">岗位管理、定时任务、服务监控、登录日志、操作日志、代码生成等功能。其中，还支持多数据源、数据权限、国际化、Redis缓存、Docker部署、滑动验证码、第三方认证登录、分布式事务、、分库分表处理等技术特点。<\\/span><\\/p><p><br style=\\"color: rgb(48, 49, 51); font-family: &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif; font-size: 12px;\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-04-25 01:10:54","updateBy":"","updateTime":null,"remark":"管理员","createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 22:39:11', 2),
	(255, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":3,"noticeTitle":"若依开源框架介绍","noticeType":"1","noticeContent":"<p><span style=\\"color: rgb(230, 0, 0);\\">项目介绍<\\/span><\\/p><p><span style=\\"color: rgb(51, 51, 51);\\">岗位管理、定时任务、服务监控、登录日志、操作日志、代码生成等功能。其中，还支持多数据源、数据权限、国际化、Redis缓存、Docker部署、滑动验证码、第三方认证登录、分布式事务、、分库分表处理等技术特点。<\\/span><\\/p><p><br style=\\"color: rgb(48, 49, 51); font-family: &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif; font-size: 12px;\\"><\\/p>","status":"0","createBy":"admin","createTime":"2026-04-25 01:10:54","updateBy":"","updateTime":null,"remark":"管理员","createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 22:39:12', 1),
	(256, '通知公告', 3, '/system/notice', 'DELETE', 1, 'admin', '', '//localhost:8787/system/notice?noticeIds=3', '127.0.0.1', '内网IP', '{"noticeIds":"3"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:39:19', 17),
	(257, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":1,"noticeTitle":"温馨提醒：2018-07-01111 若依新版本发布啦","noticeType":"2","noticeContent":"<p>新版本内容1111<\\/p>","status":"0","createBy":"admin","createTime":"2026-04-25 01:10:54","updateBy":"admin","updateTime":"2026-06-22 01:53:13","remark":"管理员","createNickName":"若依"}', '{"code":"42S22","msg":"Server internal error"}', 1, 'Server internal error', '2026-06-26 22:39:24', 1),
	(258, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:47:43', 82),
	(259, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:47:43', 8),
	(260, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":26,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:47:44', 7),
	(261, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":27,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:47:44', 9),
	(262, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:48:16', 43),
	(263, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:48:16', 8),
	(264, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":26,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:48:16', 8),
	(265, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":27,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:48:16', 8),
	(266, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":28,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:48:16', 9),
	(267, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":28,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:09', 148),
	(268, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":27,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:09', 4),
	(269, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":26,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:09', 9),
	(270, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:09', 9),
	(271, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:09', 9),
	(272, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=28%2C27%2C26', '127.0.0.1', '内网IP', '{"scheduleIds":"28,27,26"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:17', 23),
	(273, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:17', 6),
	(274, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:17', 8),
	(275, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:18', 6),
	(276, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=29%2C25', '127.0.0.1', '内网IP', '{"scheduleIds":"29,25"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:39', 11),
	(277, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-26","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:39', 7),
	(278, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:39', 6),
	(279, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=31', '127.0.0.1', '内网IP', '{"scheduleIds":"31"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:52', 2),
	(280, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:52', 9),
	(281, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:52', 8),
	(282, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:49:52', 9),
	(283, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=32', '127.0.0.1', '内网IP', '{"scheduleIds":"32"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:50:10', 30),
	(284, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"3","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:50:10', 7),
	(285, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:50:10', 9),
	(286, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:50:10', 10),
	(287, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":11,"noticeTitle":"今晚开会","noticeType":"1","noticeContent":"<p><img src=\\"\\/profile\\/upload\\/20260626\\/8d297bd67ba52dd449a54125c9c44f6e.jpg\\" alt=\\"\\" style=\\"max-width: 100%; height: auto; width: 100%;\\">今晚要开会了！！！！2<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:51:23', 25),
	(288, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":11,"noticeTitle":"今晚开会","noticeType":"1","noticeContent":"<p><img src=\\"\\/profile\\/upload\\/20260626\\/8d297bd67ba52dd449a54125c9c44f6e.jpg\\" alt=\\"\\" style=\\"max-width: 100%; height: auto; width: 100%;\\">今晚要开会了！！！！211<img src=\\"\\/profile\\/upload\\/20260626\\/1f8fde91bcafb976ce5f226a7db992a2.png\\"><\\/p>","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:53:02', 105),
	(289, '通知公告', 3, '/system/notice', 'DELETE', 1, 'admin', '', '//localhost:8787/system/notice?noticeIds=1', '127.0.0.1', '内网IP', '{"noticeIds":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:53:06', 14),
	(290, '通知公告', 2, '/system/notice', 'PUT', 1, 'admin', '', '//localhost:8787/system/notice', '127.0.0.1', '内网IP', '{"noticeId":2,"noticeTitle":"维护通知：2018-07-01 若依系统凌晨维护","noticeType":"1","noticeContent":"<p>维护内容11<\\/p>","status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 22:59:49', 110),
	(291, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=33', '127.0.0.1', '内网IP', '{"scheduleIds":"33"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:01:02', 53),
	(292, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"3","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:01:02', 5),
	(293, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:01:03', 5),
	(294, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:01:03', 6),
	(295, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=34', '127.0.0.1', '内网IP', '{"scheduleIds":"34"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:02:28', 100),
	(296, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"3","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:02:28', 9),
	(297, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:02:28', 7),
	(298, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"3","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:02:28', 7),
	(299, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:11:50', 81),
	(300, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-26 23:11:50', 1),
	(301, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:11:51', 10),
	(302, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":25,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-26 23:11:51', 1),
	(303, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-25","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:02', 33),
	(304, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:02', 9),
	(305, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":35,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:02', 6),
	(306, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"2","status":"1"},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"2","status":"1"}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:19', 92),
	(307, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:19', 6),
	(308, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":36,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:19', 6),
	(309, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:19', 7),
	(310, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":35,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:19', 6),
	(311, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":24,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:22', 4),
	(312, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":36,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:22', 6),
	(313, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":30,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:23', 6),
	(314, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":35,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:23', 7),
	(315, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":37,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:23', 5),
	(316, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":38,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:12:23', 7),
	(317, '供货商管理', 2, '/wms/supplier', 'PUT', 1, 'admin', '', '//localhost:8787/wms/supplier', '127.0.0.1', '内网IP', '{"supplierName":"供货商1","contactPerson":"111","contactPhone":null,"address":null,"cooperationStartDate":null,"status":"0","remark":null,"supplierId":1}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:43:47', 103),
	(318, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","pinyin":"2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":"0.00","enterpriseLevel":"3","serverUserId":[1,2],"serverUserName":"","cooperationStartDate":null,"cooperationEndDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 11:19:25","updateBy":"admin","updateTime":"2026-06-26 22:08:20"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:57:17', 71),
	(319, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":10,"enterpriseId":8,"enterpriseName":"终测2","storeName":"mend2","managerName":null,"phone":null,"wechat":null,"address":null,"annualPerformance":0,"regularCustomers":0,"creatorName":"若依","serverUserId":[1,2],"serverUserName":"若依、若人头","status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 11:23:56","updateBy":"","updateTime":"2026-06-21 11:23:56"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-26 23:57:26', 7),
	(320, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'admin', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 01:17:41', 1),
	(321, '供货商管理', 2, '/wms/supplier', 'PUT', 1, 'admin', '', '//localhost:8787/wms/supplier', '127.0.0.1', '内网IP', '{"supplierName":"供货商1","contactPerson":"111","contactPhone":null,"address":null,"cooperationStartDate":null,"status":"0","remark":null,"supplierId":1}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 05:54:21', 39),
	(322, '供货商管理', 2, '/wms/supplier', 'PUT', 1, 'admin', '', '//localhost:8787/wms/supplier', '127.0.0.1', '内网IP', '{"supplierName":"供货商1","contactPerson":"111","contactPhone":null,"address":null,"cooperationStartDate":null,"status":"0","remark":null,"supplierId":1}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 05:59:20', 28),
	(323, '供货商管理', 2, '/wms/supplier', 'PUT', 1, 'admin', '', '//localhost:8787/wms/supplier', '127.0.0.1', '内网IP', '{"supplierId":1,"supplierName":"供货商1","contactPerson":"111","contactPhone":null,"address":null,"cooperationStartDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-26 02:26:44","updateBy":"admin","updateTime":"2026-06-27 05:59:20"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 06:01:24', 87),
	(324, '操作记录', 1, '/business/operation', 'POST', 1, 'admin', '', '//localhost:8787/business/operation', '127.0.0.1', '内网IP', '{"customerId":"1","customerName":"客户1","packageId":1,"packageItemId":1,"productName":"卡项1","operationType":"0","operationQuantity":1,"consumeAmount":"938.00","unitPrice":"938.00","operationDate":"2026-06-26","operatorUserId":null,"operatorUserName":"若依","satisfaction":5,"customerFeedback":"","beforePhoto":"","afterPhoto":"","remark":"","enterpriseId":"7","storeId":"8"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 06:13:24', 55),
	(325, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":101,"configName":"登录过期时间","configKey":"sys.login.expireTime","configValue":"1440","configType":"Y","remark":"Token有效期（分钟），影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 18),
	(326, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":102,"configName":"启用腾讯云COS","configKey":"sys.cos.enabled","configValue":"true","configType":"Y","remark":"是否启用腾讯云对象存储"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 20),
	(327, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":103,"configName":"腾讯云SecretId","configKey":"sys.cos.secretId","configValue":"","configType":"Y","remark":"腾讯云COS SecretId"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 4),
	(328, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":104,"configName":"腾讯云SecretKey","configKey":"sys.cos.secretKey","configValue":"","configType":"Y","remark":"腾讯云COS SecretKey"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 9),
	(329, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":105,"configName":"COS存储桶名称","configKey":"sys.cos.bucket","configValue":"mydream-1302682813","configType":"Y","remark":"腾讯云COS存储桶名称"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 20),
	(330, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":106,"configName":"COS地域","configKey":"sys.cos.region","configValue":"ap-shanghai","configType":"Y","remark":"腾讯云COS地域"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 9),
	(331, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":107,"configName":"COS自定义域名","configKey":"sys.cos.domain","configValue":"","configType":"Y","remark":"腾讯云COS自定义域名"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 5),
	(332, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":4,"configName":"账号自助-验证码开关","configKey":"sys.account.captchaEnabled","configValue":"true","configType":"Y","remark":"是否开启验证码功能（true开启，false关闭）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 19),
	(333, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":5,"configName":"账号自助-是否开启用户注册功能","configKey":"sys.account.registerUser","configValue":"false","configType":"Y","remark":"是否开启注册用户功能（true开启，false关闭）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 16),
	(334, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":9,"configName":"用户管理-密码字符范围","configKey":"sys.account.chrtype","configValue":"0","configType":"Y","remark":"默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 14),
	(335, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":7,"configName":"用户管理-初始密码修改策略","configKey":"sys.account.initPasswordModify","configValue":"1","configType":"Y","remark":"0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 15),
	(336, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":8,"configName":"用户管理-账号密码更新周期","configKey":"sys.account.passwordValidateDays","configValue":"0","configType":"Y","remark":"密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 18),
	(337, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":2,"configName":"用户管理-账号初始密码","configKey":"sys.user.initPassword","configValue":"123456","configType":"Y","remark":"初始化密码 123456"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 14),
	(338, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":6,"configName":"用户登录-黑名单列表","configKey":"sys.login.blackIPList","configValue":"","configType":"Y","remark":"设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 15),
	(339, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":112,"configName":"高德Web服务Key","configKey":"sys.amap.webServiceKey","configValue":"d184e115457658cbcf3f92ed8e3a1772","configType":"Y","remark":"高德地图Web服务API Key，用于逆地理编码和IP定位"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 15),
	(340, '参数管理', 2, '/system/config', 'PUT', 1, 'admin', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":114,"configName":"高德安全密钥","configKey":"sys.amap.securityJsCode","configValue":"19ef226bdd6e4a6276d45ed1e5cb9a475","configType":"Y","remark":"高德地图JS API安全密钥"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 14),
	(341, '参数管理', 3, '/system/config/refreshCache', 'DELETE', 1, 'admin', '', '//localhost:8787/system/config/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 22:52:53', 6),
	(342, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":8,"enterpriseName":"终测2","bossName":"老板","phone":"15666666666","address":null,"enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[1,2],"serverUserName":["若依","若人头"],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:02:13', 74),
	(343, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":12,"enterpriseId":8,"storeName":"门顶上","managerName":"呃呃呃","phone":null,"wechat":"11","address":null,"businessHours":null,"annualPerformance":0,"regularCustomers":0,"serverUserId":[],"serverUserName":[],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:02:33', 78),
	(344, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":12,"enterpriseId":8,"storeName":"门顶上","managerName":"呃呃呃","phone":null,"wechat":"11","address":null,"businessHours":null,"annualPerformance":0,"regularCustomers":0,"serverUserId":[100,2],"serverUserName":["测试","若人头"],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:02:41', 15),
	(345, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":11,"enterpriseId":8,"storeName":"测试1","managerName":null,"phone":null,"wechat":null,"address":null,"businessHours":null,"annualPerformance":0,"regularCustomers":0,"serverUserId":[100,102],"serverUserName":["测试","ceshi1"],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:03:00', 83),
	(346, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":9,"enterpriseId":8,"enterpriseName":"终测2","storeName":"终测2门店1","managerName":null,"phone":null,"wechat":null,"address":null,"annualPerformance":"0.00","regularCustomers":0,"creatorName":"若依","serverUserId":[2,100],"serverUserName":"若人头、测试","status":"0","remark":null,"createBy":"admin","createTime":"2026-06-21 11:20:16","updateBy":"","updateTime":"2026-06-21 11:20:16"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:03:38', 35),
	(347, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":7,"enterpriseId":7,"enterpriseName":"终测1","storeName":"终测门店1","managerName":null,"phone":null,"wechat":null,"address":null,"annualPerformance":"0.00","regularCustomers":0,"creatorName":null,"serverUserId":[100,102],"serverUserName":"测试、ceshi1","status":"0","remark":null,"createBy":"admin","createTime":"2026-06-19 16:04:49","updateBy":"","updateTime":"2026-06-19 16:04:49"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:03:46', 50),
	(348, '门店管理', 2, '/business/store', 'PUT', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"storeId":12,"enterpriseId":8,"storeName":"门顶上","managerName":"呃呃呃","phone":null,"wechat":"11","address":null,"businessHours":null,"annualPerformance":0,"regularCustomers":0,"serverUserId":[103,102],"serverUserName":["鹏鹏","ceshi1"],"status":"0","remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:04:05', 17),
	(349, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=24%2C36%2C30%2C38', '127.0.0.1', '内网IP', '{"scheduleIds":"24,36,30,38"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:05:38', 50),
	(350, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:05:38', 9),
	(351, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":35,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:05:38', 9),
	(352, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":37,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:05:38', 11),
	(353, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:05:59', 73),
	(354, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"1","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"1","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:06:25', 57),
	(355, '员工配置', 1, '/business/employeeConfig/saveRestDates', 'POST', 1, 'admin', '', '//localhost:8787/business/employeeConfig/saveRestDates', '127.0.0.1', '内网IP', '{"userId":102,"restDates":["2026-07-01"]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:06:55', 81),
	(356, '客户管理', 1, '/business/customer', 'POST', 1, 'admin', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerName":"新客户1","enterpriseId":7,"storeId":7,"status":"0","gender":"1","age":55,"tag":"vip","remark":"111"}', '{"code":200,"msg":"","customerId":3}', 0, '', '2026-06-27 23:34:57', 110),
	(357, '客户管理', 1, '/business/customer/avatar', 'POST', 1, 'admin', '', '//localhost:8787/business/customer/avatar', '127.0.0.1', '内网IP', '{"customer_id":"3"}', '{"code":200,"msg":"","imgUrl":"\\/profile\\/customer_avatar\\/e116fa4f7a1390880c81eccfa7759ec6.jpg"}', 0, '', '2026-06-27 23:34:57', 12),
	(358, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=40%2C39', '127.0.0.1', '内网IP', '{"scheduleIds":"40,39"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:44:29', 29),
	(359, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"2","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"2","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:44:30', 8),
	(360, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":45,"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","purpose":"1","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:45:35', 91),
	(361, '排班管理', 2, '/business/schedule', 'PUT', 1, 'admin', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":46,"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","purpose":"1","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:45:35', 7),
	(362, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=41%2C42%2C45%2C46', '127.0.0.1', '内网IP', '{"scheduleIds":"41,42,45,46"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:46:12', 56),
	(363, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"1","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"1","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"1","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"1","status":"1","remark":""},{"userId":100,"userName":"测试","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-27","purpose":"1","status":"1","remark":""},{"userId":100,"userName":"测试","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-28","purpose":"1","status":"1","remark":""},{"userId":100,"userName":"测试","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"1","status":"1","remark":""},{"userId":100,"userName":"测试","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"1","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:46:12', 22),
	(364, '排班管理', 3, '/business/schedule', 'DELETE', 1, 'admin', '', '//localhost:8787/business/schedule?scheduleIds=47%2C48%2C49%2C50', '127.0.0.1', '内网IP', '{"scheduleIds":"47,48,49,50"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:55:17', 48),
	(365, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-29","purpose":"1","status":"1","remark":""},{"userId":102,"userName":"ceshi1","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-06-30","purpose":"1","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-27 23:55:17', 20),
	(366, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"09:00:00","workEndTime":"18:00:00","lateThreshold":0,"earlyLeaveThreshold":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.482449","workLatitude":"31.210999","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 00:15:05', 77),
	(367, '考勤管理', 1, '/business/attendance/rule', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleName":"红红","lateThreshold":0,"earlyLeaveThreshold":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.482449","workLatitude":"31.210999","allowedDistance":500,"status":"0","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 00:22:52', 93),
	(368, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":1,"ruleName":"标准班","workStartTime":"10:00:00","workEndTime":"18:00:00","lateThreshold":0,"earlyLeaveThreshold":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":"默认考勤规则"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 00:34:43', 82),
	(369, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":2,"ruleName":"红红","workStartTime":"10:00:00","workEndTime":"18:00:00","lateThreshold":1,"earlyLeaveThreshold":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.482449","workLatitude":"31.210999","allowedDistance":500,"status":"0","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 00:38:19', 111),
	(370, '考勤管理', 2, '/business/attendance/rule', 'PUT', 1, 'admin', '', '//localhost:8787/business/attendance/rule', '127.0.0.1', '内网IP', '{"ruleId":2,"ruleName":"红红","workStartTime":"10:00:00","workEndTime":"18:00:00","lateThreshold":1,"earlyLeaveThreshold":0,"workAddress":"上海市黄浦区半淞园路街道恒升大厦","workLongitude":"121.4824490","workLatitude":"31.2109990","allowedDistance":500,"status":"0","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 00:42:43', 6),
	(371, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-28 20:26:21', 5),
	(372, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-28 20:26:22', 3),
	(373, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100"}', '{"code":500,"msg":"操作失败"}', 1, '操作失败', '2026-06-28 20:27:04', 38),
	(374, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=100&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:31:08', 0),
	(375, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"测试角色","roleKey":"1","roleSort":3,"dataScope":"1","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-26 02:48:55","remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,3080,2012,1035,2002,2003,2008,2009,2015,2016,2017,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,3045,3059,3081,3082]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:32:33', 143),
	(376, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=100&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:58:55', 2),
	(377, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=100&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:59:05', 0),
	(378, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100,2', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100,2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:59:29', 77),
	(379, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 20:59:35', 34),
	(380, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=100&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:01:55', 0),
	(381, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"测试角色","roleKey":"1","roleSort":3,"dataScope":"1","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-28 20:32:33","remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,3080,2012,1035,2002,2003,2008,2009,2010,2011,2015,2016,2017,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,3045,3059,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:28:09', 106),
	(382, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=100', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"100"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:29:31', 64),
	(383, '用户管理', 2, '/system/user/profile/updatePwd', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/user/profile/updatePwd', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:44:07', 226),
	(384, '角色管理', 2, '/system/role/dataScope', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/dataScope', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"测试角色","roleKey":"1","roleSort":3,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-28 21:28:09","remark":null,"deptIds":[]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:45:01', 75),
	(385, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"市场老师","roleKey":"1","roleSort":3,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-28 21:45:01","remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,3080,2012,1035,2002,2003,2008,2009,2010,2011,2015,2016,2017,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,3045,3059,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:45:13', 52),
	(386, '客户管理', 1, '/business/customer', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerName":"LIly","phone":"","wechat":"","gender":"1","age":55,"tag":"","remark":"","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈"}', '{"code":200,"msg":"","customerId":4}', 0, '', '2026-06-28 21:46:28', 35),
	(387, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"市场老师","roleKey":"1","roleSort":3,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-28 21:45:13","remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,3080,2012,1035,2002,2003,2008,2009,2010,2011,2015,2016,2017,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,2078,3045,3059,3060,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:47:28', 117),
	(388, '客户管理', 2, '/business/customer', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerId":4,"customerName":"LIly","phone":"","wechat":"","gender":"1","age":55,"tag":"normal,important","remark":"","avatar":"","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:47:38', 7),
	(389, '客户管理', 2, '/business/customer', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/customer', '127.0.0.1', '内网IP', '{"customerId":4,"customerName":"LIly","phone":"","wechat":"","gender":"1","age":55,"tag":"normal,important","remark":"","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:54:58', 85),
	(390, '客户管理', 1, '/business/customer/avatar', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/customer/avatar', '127.0.0.1', '内网IP', '{"customer_id":"4"}', '{"code":200,"msg":"","imgUrl":"\\/profile\\/customer_avatar\\/3f599c581cd3687edbebec330ef2fff6.jpg"}', 0, '', '2026-06-28 21:54:58', 22),
	(391, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-01","purpose":"2","status":"1","remark":""}]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:56:09', 21),
	(392, '排班管理', 2, '/business/schedule', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":35,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:56:09', 9),
	(393, '排班管理', 2, '/business/schedule', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":37,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:56:09', 9),
	(394, '排班管理', 2, '/business/schedule', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":43,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:56:09', 9),
	(395, '排班管理', 2, '/business/schedule', 'PUT', 1, 'pengpeng', '', '//localhost:8787/business/schedule', '127.0.0.1', '内网IP', '{"scheduleId":44,"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","purpose":"2","status":"1","remark":""}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:56:09', 10),
	(396, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":100,"roleName":"市场老师","roleKey":"1","roleSort":3,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-06-03 07:08:47","updateBy":"admin","updateTime":"2026-06-28 21:47:28","remark":null,"menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,3031,2013,3080,2012,1035,2002,2003,2008,2009,2010,2011,2015,2016,2017,2060,2061,2066,2067,2068,2069,2070,2073,2074,2077,2078,3045,3059,3060,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 21:57:21', 105),
	(397, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":2,"roleName":"普通角色","roleKey":"common","roleSort":2,"dataScope":"2","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-04-25 01:10:45","updateBy":"admin","updateTime":"2026-05-08 00:29:26","remark":"普通角色","menuIds":[2001,2059,2007,2065,2072,2076,3044,2012,3031,2013,2014,2080,3080,3000,3001,3002,3003,3034,2021,2022,2028,2034,2041,2048,2050,2057,3067,3072,3023,100,3024,103,104,107,1,101,102,105,106,3018,108,500,501,3013,3066,3083,2,109,110,111,112,113,114,3,115,116,117,4,2000,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,2002,2003,2004,2005,2006,2008,2009,2010,2011,2015,2016,2017,2018,2019,2020,2023,2024,2025,2026,2027,2029,2030,2031,2032,2033,2035,2036,2037,2038,2039,2040,2042,2043,2044,2045,2046,2047,2049,2051,2052,2053,2054,2055,2056,2058,2060,2061,2062,2063,2064,2066,2067,2068,2069,2070,2071,2073,2074,2075,2077,2078,2079,2081,2082,2083,2084,2085,2086,2087,3004,3005,3006,3007,3008,3009,3010,3011,3012,3014,3015,3016,3017,3019,3020,3021,3022,3025,3026,3027,3028,3029,3035,3036,3037,3038,3045,3046,3059,3060,3061,3068,3069,3070,3071,3073,3074,3075,3076,3077,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:06:02', 90),
	(398, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=2&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"2","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:06:13', 0),
	(399, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=2&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"2","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:06:24', 0),
	(400, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=2&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"2","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:06:44', 0),
	(401, '角色管理', 2, '/system/role/dataScope', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/dataScope', '127.0.0.1', '内网IP', '{"roleId":2,"roleName":"普通角色","roleKey":"common","roleSort":2,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-04-25 01:10:45","updateBy":"admin","updateTime":"2026-06-28 22:06:02","remark":"普通角色","deptIds":[]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:06:59', 59),
	(402, '角色管理', 2, '/system/role/authUser/cancel', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/cancel', '127.0.0.1', '内网IP', '{"userId":103,"roleId":"100"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:07:09', 29),
	(403, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=2&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"2","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:07:18', 0),
	(404, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll?roleId=100&userIds=103', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:07:34', 0),
	(405, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=103&roleIds=2', '127.0.0.1', '内网IP', '{"userId":"103","roleIds":"2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:08:26', 94),
	(406, '角色管理', 2, '/system/role/authUser/selectAll', 'PUT', 1, 'admin', '', '//localhost:8787/system/role/authUser/selectAll', '127.0.0.1', '内网IP', '{"roleId":"100","userIds":"103"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:49:44', 87),
	(407, '参数管理', 2, '/system/config', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":108,"configName":"允许修改套餐次数","configKey":"biz.sales.packageQuantityEditable","configValue":"false","configType":"Y","remark":"销售开单中是否允许修改套餐次数，影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:56:23', 93),
	(408, '参数管理', 2, '/system/config', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":109,"configName":"允许修改套餐成交金额","configKey":"biz.sales.packageDealAmountEditable","configValue":"false","configType":"Y","remark":"销售开单中是否允许修改套餐成交金额，影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:56:23', 3),
	(409, '参数管理', 2, '/system/config', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":110,"configName":"允许修改套餐实付金额","configKey":"biz.sales.packagePaidAmountEditable","configValue":"true","configType":"Y","remark":"销售开单中是否允许修改套餐实付金额，影响Web端和APP端"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:56:24', 6),
	(410, '参数管理', 2, '/system/config', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":111,"configName":"允许手动输入打卡地址","configKey":"biz.attendance.allowManualAddress","configValue":"false","configType":"Y","remark":"控制APP端考勤打卡是否允许手动输入地址，关闭后定位失败时无法手动输入"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:56:24', 3),
	(411, '参数管理', 3, '/system/config/refreshCache', 'DELETE', 1, 'pengpeng', '', '//localhost:8787/system/config/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:56:24', 9),
	(412, '销售管理', 1, '/business/sales', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":4,"customerName":"LIly","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈","orderStatus":"0","packageName":"发发发","storeDealer":"飞飞","customerFeedback":"111","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"9380.00","paidAmount":"9380.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:57:02', 74),
	(413, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":5}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 22:57:08', 19),
	(414, '用户管理', 1, '/system/user', 'POST', 1, 'admin', '', '//localhost:8787/system/user', '127.0.0.1', '内网IP', '{"deptId":103,"userName":"测试","nickName":"ceshi","sex":"0","status":"0","postIds":[2],"roleIds":[2]}', '{"code":500,"msg":"新增用户\'测试\'失败，登录账号已存在"}', 1, '新增用户\'测试\'失败，登录账号已存在', '2026-06-28 23:00:59', 1),
	(415, '用户管理', 1, '/system/user', 'POST', 1, 'admin', '', '//localhost:8787/system/user', '127.0.0.1', '内网IP', '{"deptId":103,"userName":"测试2","nickName":"ceshi2","sex":"0","status":"0","postIds":[2],"roleIds":[2]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:01:09', 139),
	(416, '用户管理', 1, '/system/user', 'POST', 1, 'admin', '', '//localhost:8787/system/user', '127.0.0.1', '内网IP', '{"deptId":104,"userName":"ceshi","nickName":"测试","status":"0","postIds":[2],"roleIds":[2]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:02:22', 145),
	(417, '用户管理', 2, '/system/user/authRole', 'PUT', 1, 'admin', '', '//localhost:8787/system/user/authRole?userId=105&roleIds=2', '127.0.0.1', '内网IP', '{"userId":"105","roleIds":"2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:08:11', 29),
	(418, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":2,"roleName":"普通角色","roleKey":"common","roleSort":2,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-04-25 01:10:45","updateBy":"admin","updateTime":"2026-06-28 22:06:59","remark":"普通角色","menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,2012,3031,2013,2014,2080,3080,3000,3001,3002,3003,3034,2021,2022,2028,2034,2041,2048,2050,2057,3067,3072,3023,100,3024,103,104,107,1,101,102,105,106,3018,108,500,501,3013,3066,3083,2,109,110,111,112,113,114,3,115,116,117,4,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,2002,2003,2004,2005,2006,2008,2009,2010,2011,2015,2016,2017,2018,2019,2020,2023,2024,2025,2026,2027,2029,2030,2031,2032,2033,2035,2036,2037,2038,2039,2040,2042,2043,2044,2045,2046,2047,2049,2051,2052,2053,2054,2055,2056,2058,2060,2061,2062,2063,2064,2066,2067,2068,2069,2070,2071,2073,2074,2075,2077,2078,2079,2081,2082,2083,2084,2085,2086,2087,2088,2089,2090,2091,2092,2093,3004,3005,3006,3007,3008,3009,3010,3011,3012,3014,3015,3016,3017,3019,3020,3021,3022,3025,3026,3027,3028,3029,3035,3036,3037,3038,3045,3046,3059,3060,3061,3068,3069,3070,3071,3073,3074,3075,3076,3077,3081,3082,3084,3085]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:09:04', 51),
	(419, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":4,"customerName":"LIly","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈","orderStatus":"0","packageName":"111","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"9380.00","paidAmount":"9380.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:14:18', 60),
	(420, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":6}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:14:25', 14),
	(421, '销售管理', 1, '/business/sales', 'POST', 1, 'ceshi', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":4,"customerName":"LIly","enterpriseId":4,"enterpriseName":"企业1","storeId":5,"storeName":"哈哈","orderStatus":"0","packageName":"22","storeDealer":"11","customerFeedback":"11","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"9380.00","paidAmount":"9380.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:16:10', 79),
	(422, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'ceshi', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":7}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:16:22', 36),
	(423, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:45:25', 68),
	(424, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:45:45', 63),
	(425, '系统操作', 1, '/common/upload', 'POST', 1, 'pengpeng', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260628\\/4608b88268846fecc5fd86e12681d749.jpg","url":"\\/profile\\/upload\\/20260628\\/4608b88268846fecc5fd86e12681d749.jpg","newFileName":"4608b88268846fecc5fd86e12681d749.jpg","originalFilename":"1782661580298.jpg"}', 0, '', '2026-06-28 23:46:26', 12),
	(426, '系统操作', 1, '/common/upload', 'POST', 1, 'pengpeng', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260628\\/b67d2b097400b9fae014cae72c465881.jpg","url":"\\/profile\\/upload\\/20260628\\/b67d2b097400b9fae014cae72c465881.jpg","newFileName":"b67d2b097400b9fae014cae72c465881.jpg","originalFilename":"1782661580298.jpg"}', 0, '', '2026-06-28 23:46:40', 10),
	(427, '系统操作', 1, '/common/upload', 'POST', 1, 'pengpeng', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260628\\/3796c9d4e9e1b86d9035f8b77e5098b4.jpg","url":"\\/profile\\/upload\\/20260628\\/3796c9d4e9e1b86d9035f8b77e5098b4.jpg","newFileName":"3796c9d4e9e1b86d9035f8b77e5098b4.jpg","originalFilename":"1782661580298.jpg"}', 0, '', '2026-06-28 23:46:56', 9),
	(428, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":2,"roleName":"普通角色","roleKey":"common","roleSort":2,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-04-25 01:10:45","updateBy":"admin","updateTime":"2026-06-28 23:09:04","remark":"普通角色","menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,2012,3031,2013,2014,2080,3080,3000,3001,3002,3003,3034,2021,2022,2028,2034,2041,2048,2050,2057,3067,3072,3023,100,3024,103,104,107,1,101,102,105,106,3018,108,500,501,3013,3066,3083,2,109,110,111,112,113,114,3,115,116,117,4,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,2002,2003,2004,2005,2006,2008,2009,2010,2011,2015,2016,2017,2018,2019,2020,2023,2024,2025,2026,2027,2029,2030,2031,2032,2033,2035,2036,2037,2038,2039,2040,2042,2043,2044,2045,2046,2047,2049,2051,2052,2053,2054,2055,2056,2058,2060,2061,2062,2063,2064,2066,2067,2068,2069,2070,2071,2073,2074,2075,2077,2078,2079,2081,2082,2083,2084,2085,2086,2087,2088,2089,2090,2091,2092,2093,3004,3005,3006,3007,3008,3009,3010,3011,3012,3014,3015,3016,3017,3019,3020,3021,3022,3025,3026,3027,3028,3029,3035,3036,3037,3038,3045,3046,3059,3060,3061,3068,3069,3070,3071,3073,3074,3075,3076,3077,3081,3082,3084,3085,3086,3087,3088,3089]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:48:13', 123),
	(429, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"11"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:49:46', 1),
	(430, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"2"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:49:47', 1),
	(431, '通知公告', 1, '/system/notice/markRead', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/notice/markRead', '127.0.0.1', '内网IP', '{"noticeId":"12"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-28 23:49:48', 13),
	(432, '角色管理', 2, '/system/role', 'PUT', 1, 'admin', '', '//localhost:8787/system/role', '127.0.0.1', '内网IP', '{"roleId":2,"roleName":"普通角色","roleKey":"common","roleSort":2,"dataScope":"5","menuCheckStrictly":1,"deptCheckStrictly":1,"status":"0","delFlag":"0","createBy":"admin","createTime":"2026-04-25 01:10:45","updateBy":"admin","updateTime":"2026-06-28 23:48:12","remark":"普通角色","menuIds":[2000,2001,2059,2007,2065,2072,2076,3044,3058,2012,3031,2013,2014,2080,3080,3000,3001,3002,3003,3034,2021,2022,2028,2034,2041,2048,2050,2057,3067,3072,3023,100,3024,103,104,107,1,101,102,105,106,3018,108,500,501,3013,3066,3083,2,109,110,111,112,113,114,3,115,116,117,4,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,2002,2003,2004,2005,2006,2008,2009,2010,2011,2015,2016,2017,2018,2019,2020,2023,2024,2025,2026,2027,2029,2030,2031,2032,2033,2035,2036,2037,2038,2039,2040,2042,2043,2044,2045,2046,2047,2049,2051,2052,2053,2054,2055,2056,2058,2060,2061,2062,2063,2064,2066,2067,2068,2069,2070,2071,2073,2074,2075,2077,2078,2079,2081,2082,2083,2084,2085,2086,2087,2088,2089,2090,2091,2092,2093,3004,3005,3006,3007,3008,3009,3010,3011,3012,3014,3015,3016,3017,3019,3020,3021,3022,3025,3026,3027,3028,3029,3035,3036,3037,3038,3045,3046,3059,3060,3061,3068,3069,3070,3071,3073,3074,3075,3076,3077,3081,3082,3084,3085,3086,3087,3088,3089]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-29 23:31:22', 134),
	(433, '仓库管理', 1, '/wms/warehouse/assignUsers', 'POST', 1, 'admin', '', '//localhost:8787/wms/warehouse/assignUsers', '127.0.0.1', '内网IP', '{"warehouseId":1,"userIds":[103],"action":"add"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-29 23:31:38', 6),
	(434, '仓库管理', 1, '/wms/warehouse/assignUsers', 'POST', 1, 'admin', '', '//localhost:8787/wms/warehouse/assignUsers', '127.0.0.1', '内网IP', '{"warehouseId":1,"userIds":[103],"action":"remove"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-29 23:31:44', 34),
	(435, '仓库管理', 1, '/wms/warehouse/assignUsers', 'POST', 1, 'admin', '', '//localhost:8787/wms/warehouse/assignUsers', '127.0.0.1', '内网IP', '{"warehouseId":2,"userIds":[103],"action":"add"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-29 23:31:50', 28),
	(436, '备货管理', 1, '/business/stockPrepare/createStockOut', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createStockOut', '127.0.0.1', '内网IP', '{"prepareId":1,"items":[{"itemId":1,"unitType":"2","originalQuantity":1},{"itemId":2,"unitType":"2","originalQuantity":1}],"warehouseId":2}', '{"code":200,"msg":"操作成功","data":{"stockOutNo":"CK20260629001","stockOutType":"1","outTargetType":"1","prepareId":1,"planId":null,"warehouseId":2,"enterpriseId":7,"enterpriseName":"终测1","responsibleId":1,"responsibleName":"超级管理员","totalQuantity":2,"totalAmount":"938.00","stockOutDate":"2026-06-29","status":"0","shipType":"2","remark":null,"createBy":"admin","createTime":"2026-06-29 23:36:03","stockOutId":2}}', 0, '', '2026-06-29 23:36:03', 37),
	(437, '进销存报表', 1, '/wms/report/exportTurnover', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/report/exportTurnover', '127.0.0.1', '内网IP', '{"warehouseId":"2"}', '', 0, '', '2026-06-29 23:58:05', 138),
	(438, '货品管理', 1, '/wms/product', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/product', '127.0.0.1', '内网IP', '{"productName":"身体套盒","productCode":"STTH-20260629","supplierId":1,"category":"1","unit":"5","spec":"1","packQty":10,"purchasePrice":5800,"salePrice":5800,"salePriceSpec":580,"warnQty":0,"status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:01:09', 74),
	(439, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-06-29","warehouseId":2,"items":[{"productId":3,"productName":"身体套盒","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"purchasePrice":5800,"_mainPrice":5800,"amount":5800,"productionDate":"2026-06-01","expiryDate":"2027-06-01"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:03:18', 57),
	(440, '出库管理', 2, '/wms/stockOut/confirm/2', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockOut/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"货品【GCS-p7】库存不足，当前库存：0，出库数量：1"}', 1, '货品【GCS-p7】库存不足，当前库存：0，出库数量：1', '2026-06-30 00:04:06', 7),
	(441, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-06-29","warehouseId":2,"items":[{"productId":1,"productName":"GCS-p7","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"2","originalQuantity":1,"quantity":1,"purchasePrice":258,"_mainPrice":2580,"amount":258,"productionDate":"2026-06-01","expiryDate":"2026-07-01"},{"productId":2,"productName":"测试1","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"2","originalQuantity":1,"quantity":1,"purchasePrice":680,"_mainPrice":6800,"amount":680,"productionDate":"2026-06-01","expiryDate":"2026-07-01"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:16:26', 56),
	(442, '入库管理', 2, '/wms/stockIn/confirm/3', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockIn/confirm/3', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-06-30 00:16:39', 76),
	(443, '入库管理', 2, '/wms/stockIn/confirm/2', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockIn/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-06-30 00:16:40', 18),
	(444, '出库管理', 2, '/wms/stockOut/confirm/2', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockOut/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"出库确认成功"}', 0, '', '2026-06-30 00:17:13', 41),
	(445, '出库管理', 2, '/wms/stockOut/ship/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/ship/2', '127.0.0.1', '内网IP', '{"ship_type":"2","logistics_company":"shunfeng","logistics_no":"1111111"}', '{"code":200,"msg":"发货成功"}', 0, '', '2026-06-30 00:17:39', 14),
	(446, '出库管理', 2, '/wms/stockOut/confirmReceipt/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirmReceipt/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"确认收货成功"}', 0, '', '2026-06-30 00:17:42', 15),
	(447, '库存盘点', 1, '/wms/stockCheck', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck', '127.0.0.1', '内网IP', '{"checkDate":"2026-06-29","warehouseId":2,"items":[{"productId":1,"productName":"GCS-p7","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":0,"actualQuantity":1,"diffQuantity":1,"_prevUnitType":"2","_rawSystemQty":0,"_rawActualQty":1},{"productId":2,"productName":"测试1","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":0,"actualQuantity":1,"diffQuantity":1,"_prevUnitType":"2","_rawSystemQty":0,"_rawActualQty":1},{"productId":3,"productName":"身体套盒","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":10,"actualQuantity":10,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":10,"_rawActualQty":10}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:18:26', 40),
	(448, '库存盘点', 2, '/wms/stockCheck/confirm/1', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck/confirm/1', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"盘点确认成功"}', 0, '', '2026-06-30 00:18:50', 55),
	(449, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044324,"longitude":121.4662,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:11', 11),
	(450, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044324,"longitude":121.4662,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:13', 9),
	(451, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044324,"longitude":121.4662,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:17', 6),
	(452, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:25', 4),
	(453, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:25', 2),
	(454, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:29', 2),
	(455, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:29', 3),
	(456, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:32', 7),
	(457, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044323,"longitude":121.466199,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18597米"}', 1, '不在考勤范围内，距离考勤点18597米', '2026-06-30 00:36:36', 5),
	(458, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044312,"longitude":121.466224,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18598米"}', 1, '不在考勤范围内，距离考勤点18598米', '2026-06-30 00:36:41', 2),
	(459, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044312,"longitude":121.466224,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18598米"}', 1, '不在考勤范围内，距离考勤点18598米', '2026-06-30 00:36:46', 2),
	(460, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044312,"longitude":121.466224,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18598米"}', 1, '不在考勤范围内，距离考勤点18598米', '2026-06-30 00:37:34', 2),
	(461, '库存盘点', 1, '/wms/stockCheck', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockCheck', '127.0.0.1', '内网IP', '{"checkDate":"2026-06-29","warehouseId":2,"items":[{"productId":1,"productName":"GCS-p7","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":1,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":1,"productionDate":"2026-06-01","expiryDate":"2026-07-01"},{"productId":2,"productName":"测试1","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":1,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":1,"productionDate":"2026-06-01","expiryDate":"2026-07-01"},{"productId":3,"productName":"身体套盒","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":10,"actualQuantity":10,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":10,"_rawActualQty":10}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:38:16', 40),
	(462, '库存盘点', 2, '/wms/stockCheck/confirm/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockCheck/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"盘点确认成功"}', 0, '', '2026-06-30 00:38:23', 19),
	(463, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044312,"longitude":121.466224,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18598米"}', 1, '不在考勤范围内，距离考勤点18598米', '2026-06-30 00:39:03', 3),
	(464, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044336,"longitude":121.466178,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18596米"}', 1, '不在考勤范围内，距离考勤点18596米', '2026-06-30 00:41:14', 2),
	(465, '系统操作', 1, '/common/upload', 'POST', 1, 'admin', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260630\\/024c058f6b4b61698acbfb0306ec1854.jpg","url":"\\/profile\\/upload\\/20260630\\/024c058f6b4b61698acbfb0306ec1854.jpg","newFileName":"024c058f6b4b61698acbfb0306ec1854.jpg","originalFilename":"1782751280488.jpg"}', 0, '', '2026-06-30 00:41:27', 14),
	(466, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"1","outsideReason":"111","latitude":31.044336,"longitude":121.466178,"address":"永德小区北区","photo":"\\/profile\\/upload\\/20260630\\/024c058f6b4b61698acbfb0306ec1854.jpg"}', '{"code":200,"msg":"打卡成功","data":{"recordId":8,"userId":1,"userName":"超级管理员","attendanceDate":"2026-06-30","clockInTime":"2026-06-30 00:41:28","clockOutTime":"2026-06-30 00:41:28","clockInLatitude":"31.0443360","clockInLongitude":"121.4661780","clockInAddress":"永德小区北区","clockInPhoto":"\\/profile\\/upload\\/20260630\\/024c058f6b4b61698acbfb0306ec1854.jpg","clockOutLatitude":"31.0443360","clockOutLongitude":"121.4661780","clockOutAddress":"永德小区北区","clockOutPhoto":"\\/profile\\/upload\\/20260630\\/024c058f6b4b61698acbfb0306ec1854.jpg","attendanceStatus":"0","clockCount":1,"firstClockTime":"2026-06-30 00:41:28","lastClockTime":"2026-06-30 00:41:28","clockType":"0","outsideReason":"","ruleId":null,"remark":"","createBy":"超级管理员","createTime":"2026-06-30 00:41:28","updateBy":"","updateTime":"2026-06-30 00:41:28"}}', 0, '', '2026-06-30 00:41:28', 27),
	(467, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:08', 2),
	(468, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:10', 2),
	(469, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:14', 2),
	(470, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:16', 4),
	(471, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:17', 3),
	(472, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:25', 2),
	(473, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:34', 2),
	(474, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:35', 2),
	(475, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:36', 2),
	(476, '考勤管理', 1, '/business/attendance/clock', 'POST', 1, 'admin', '', '//localhost:8787/business/attendance/clock', '127.0.0.1', '内网IP', '{"clockType":"0","outsideReason":"","latitude":31.044236,"longitude":121.466295,"address":"永德小区北区","photo":""}', '{"code":500,"msg":"不在考勤范围内，距离考勤点18606米"}', 1, '不在考勤范围内，距离考勤点18606米', '2026-06-30 00:44:44', 2),
	(477, '库存盘点', 1, '/wms/stockCheck', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck', '127.0.0.1', '内网IP', '{"checkDate":"2026-06-29","warehouseId":2,"items":[{"productId":1,"productName":"GCS-p7","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":1,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":1,"productionDate":"2026-06-01","expiryDate":"2026-07-01"},{"productId":2,"productName":"测试1","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":1,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":1,"productionDate":"2026-06-01","expiryDate":"2026-07-01"},{"productId":3,"productName":"身体套盒","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":10,"actualQuantity":10,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":10,"_rawActualQty":10,"productionDate":"2026-06-01","expiryDate":"2026-07-01"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:57:35', 43),
	(478, '库存盘点', 2, '/wms/stockCheck/confirm/3', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck/confirm/3', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"盘点确认成功"}', 0, '', '2026-06-30 00:57:38', 15),
	(479, '库存盘点', 1, '/wms/stockCheck', 'POST', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck', '127.0.0.1', '内网IP', '{"checkDate":"2026-06-29","warehouseId":2,"items":[{"productId":1,"productName":"GCS-p7","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":2,"diffQuantity":1,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":2,"expiryDate":"2026-07-01"},{"productId":2,"productName":"测试1","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":1,"actualQuantity":2,"diffQuantity":1,"_prevUnitType":"2","_rawSystemQty":1,"_rawActualQty":2},{"productId":3,"productName":"身体套盒","spec":"1","unit":"5","unitType":"2","packQty":10,"systemQuantity":10,"actualQuantity":10,"diffQuantity":0,"_prevUnitType":"2","_rawSystemQty":10,"_rawActualQty":10}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 00:58:46', 15),
	(480, '库存盘点', 2, '/wms/stockCheck/confirm/4', 'PUT', 1, 'pengpeng', '', '//localhost:8787/wms/stockCheck/confirm/4', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"盘点确认成功"}', 0, '', '2026-06-30 00:58:57', 31),
	(481, '系统操作', 1, '/common/upload', 'POST', 1, 'pengpeng', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260630\\/4abccbb7d7d5c007f096ed0bb7141ae4.jpg","url":"\\/profile\\/upload\\/20260630\\/4abccbb7d7d5c007f096ed0bb7141ae4.jpg","newFileName":"4abccbb7d7d5c007f096ed0bb7141ae4.jpg","originalFilename":"潮色.jpg"}', 0, '', '2026-06-30 18:03:43', 9),
	(482, '报销管理', 1, '/finance/reimbursement', 'POST', 1, 'pengpeng', '', '//localhost:8787/finance/reimbursement', '127.0.0.1', '内网IP', '{"applyDate":"2026-06-30","category":"1","expenseAmount":80,"incomeAmount":0,"expenseType":"1","voucherImages":"[\\"\\/profile\\/upload\\/20260630\\/4abccbb7d7d5c007f096ed0bb7141ae4.jpg\\"]","remark":"111"}', '{"code":200,"msg":"新增成功","data":{"applyDate":"2026-06-30","category":"1","expenseAmount":"80.00","incomeAmount":"0.00","expenseType":"1","voucherImages":"[\\"\\/profile\\/upload\\/20260630\\/4abccbb7d7d5c007f096ed0bb7141ae4.jpg\\"]","remark":"111","applicantId":103,"applicantName":"鹏鹏","deptId":101,"deptName":"赛诺·森品牌","createBy":"鹏鹏","reimbursementNo":"BX202606300001","status":"0","createTime":"2026-06-30 18:03:47","reimbursementId":18}}', 0, '', '2026-06-30 18:03:47', 69),
	(483, '报销管理', 1, '/finance/reimbursement/audit', 'POST', 1, 'pengpeng', '', '//localhost:8787/finance/reimbursement/audit', '127.0.0.1', '内网IP', '{"reimbursementId":18,"passed":true,"auditRemark":""}', '{"code":200,"msg":"审核成功"}', 0, '', '2026-06-30 18:03:52', 11),
	(484, '报销管理', 1, '/finance/reimbursement/pay', 'POST', 1, 'pengpeng', '', '//localhost:8787/finance/reimbursement/pay', '127.0.0.1', '内网IP', '{"reimbursementId":18}', '{"code":200,"msg":"支付成功"}', 0, '', '2026-06-30 18:03:56', 13),
	(485, '调拨管理', 1, '/wms/stockTransfer', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockTransfer', '127.0.0.1', '内网IP', '{"fromWarehouseId":1,"fromWarehouseName":"上海仓库","toWarehouseId":2,"toWarehouseName":"深圳仓库","transferDate":"2026-06-30","items":[{"productId":2,"productName":"测试1","spec":"1","unit":"5","packQty":10,"unitType":"2","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-06-30 18:22:52', 104),
	(486, '调拨管理', 2, '/wms/stockTransfer/confirm/7', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockTransfer/confirm/7', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"调拨确认成功"}', 0, '', '2026-06-30 18:23:00', 40),
	(487, '系统操作', 1, '/system/backup/download', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"12"}', '{"code":403,"msg":"仅超级管理员可下载备份文件"}', 1, '仅超级管理员可下载备份文件', '2026-07-01 09:00:08', 0),
	(488, '系统操作', 1, '/system/backup/download', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"12"}', '{"code":403,"msg":"仅超级管理员可下载备份文件"}', 1, '仅超级管理员可下载备份文件', '2026-07-01 09:00:20', 0),
	(489, '系统操作', 1, '/system/backup/download', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"12"}', '{"code":403,"msg":"仅超级管理员可下载备份文件"}', 1, '仅超级管理员可下载备份文件', '2026-07-01 09:00:24', 0),
	(490, '系统操作', 1, '/system/backup/download', 'POST', 1, 'pengpeng', '', '//localhost:8787/system/backup/download', '127.0.0.1', '内网IP', '{"backupId":"12"}', '{"code":403,"msg":"仅超级管理员可下载备份文件"}', 1, '仅超级管理员可下载备份文件', '2026-07-01 09:00:46', 0),
	(491, '轮播图管理', 2, '/system/banner', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/banner', '127.0.0.1', '内网IP', '{"bannerId":1,"title":"欢迎使用","image":"https:\\/\\/mydream-1302682813.cos.ap-shanghai.myqcloud.com\\/upload\\/20260525\\/2013839df589d2c49ea8077114163d65.png","linkUrl":"","sortOrder":1,"status":"0","remark":"默认轮播图1","createBy":"admin","createTime":"2026-05-25 12:12:44","updateBy":"admin","updateTime":"2026-05-25 17:19:37"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 09:01:11', 75),
	(492, '参数管理', 2, '/system/config', 'PUT', 1, 'pengpeng', '', '//localhost:8787/system/config', '127.0.0.1', '内网IP', '{"configId":126,"configName":"数据库备份时间","configKey":"sys.backup.time","configValue":"02:00","configType":"Y","createBy":"","createTime":"2026-06-21 23:58:36","updateBy":"","updateTime":null,"remark":null}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 09:01:25', 75),
	(493, '字典管理', 3, '/system/dict/type/refreshCache', 'DELETE', 1, 'pengpeng', '', '//localhost:8787/system/dict/type/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":403,"msg":"没有操作权限"}', 1, '没有操作权限', '2026-07-01 09:01:30', 0),
	(494, '字典管理', 3, '/system/dict/type/refreshCache', 'DELETE', 1, 'pengpeng', '', '//localhost:8787/system/dict/type/refreshCache', '127.0.0.1', '内网IP', '[]', '{"code":403,"msg":"没有操作权限"}', 1, '没有操作权限', '2026-07-01 09:01:37', 0),
	(495, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-01","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-02","purpose":"2","status":"1","remark":""}]', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-07-01 09:19:11', 10),
	(496, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-01","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-02","purpose":"2","status":"1","remark":""}]', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-07-01 09:19:13', 2),
	(497, '企业管理', 1, '/business/enterprise', 'POST', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseName":"啊啊啊","bossName":"啊啊","phone":"13333333333","enterpriseType":"1","storeCount":0,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 09:19:28', 67),
	(498, '门店管理', 1, '/business/store', 'POST', 1, 'admin', '', '//localhost:8787/business/store', '127.0.0.1', '内网IP', '{"enterpriseId":4,"enterpriseName":"企业1","storeName":"1111","annualPerformance":0,"regularCustomers":0,"creatorName":"超级管理员","serverUserId":[],"status":"0"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 09:19:41', 89),
	(499, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-09","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-08","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-01","purpose":"2","status":"1","remark":""}]', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-07-01 09:20:03', 3),
	(500, '排班管理', 1, '/business/schedule/batch', 'POST', 1, 'admin', '', '//localhost:8787/business/schedule/batch', '127.0.0.1', '内网IP', '[{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-09","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-08","purpose":"2","status":"1","remark":""},{"userId":103,"userName":"鹏鹏","enterpriseId":7,"enterpriseName":"终测1","scheduleDate":"2026-07-01","purpose":"2","status":"1","remark":""}]', '{"code":500,"msg":"Server internal error"}', 1, 'Server internal error', '2026-07-01 09:20:05', 2),
	(501, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":9}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:57:25', 4),
	(502, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":9}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:57:26', 4),
	(503, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 16:57:38', 122),
	(504, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":10}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:57:55', 3),
	(505, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":9}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:57:59', 4),
	(506, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":8}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:58:01', 3),
	(507, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":7}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:58:03', 9),
	(508, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":6}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:58:05', 4),
	(509, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":5}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:58:06', 10),
	(510, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":2}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 16:58:08', 4),
	(511, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 16:58:11', 60),
	(512, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":"","spec":"","unitType":"1","salePrice":0,"quantity":2}]}', '{"code":500,"msg":"货品ID不能为空"}', 1, '货品ID不能为空', '2026-07-01 17:01:10', 0),
	(513, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":2}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 17:01:14', 3),
	(514, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":2}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 17:02:05', 2),
	(515, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:04:09', 58),
	(516, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:04:33', 130),
	(517, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:04:51', 87),
	(518, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":3}]}', '{"code":500,"msg":"操作失败，请稍后重试"}', 1, '操作失败，请稍后重试', '2026-07-01 17:05:58', 2),
	(519, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:06:02', 28),
	(520, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:56:26', 166),
	(521, '方案管理', 1, '/business/plan', 'POST', 1, 'admin', '', '//localhost:8787/business/plan', '127.0.0.1', '内网IP', '{"enterpriseId":4,"enterpriseName":"企业1","planName":"企业1-30%","commissionRate":30,"planAmount":10000,"giftAmount":33333.33,"remainingAmount":33333.33,"effectiveDate":"2026-07-01","expiryDate":"2026-07-31","items":[]}', '{"code":200,"msg":"操作成功","data":{"enterpriseId":4,"planName":"企业1-30%","commissionRate":30,"planAmount":10000,"giftAmount":33333.33,"remainingAmount":33333.33,"effectiveDate":"2026-07-01","expiryDate":"2026-07-31","createBy":"admin","planNo":"PL20260701001","shippedAmount":0,"auditStatus":"0","createTime":"2026-07-01 17:59:14","planId":2}}', 0, '', '2026-07-01 17:59:14', 26),
	(522, '方案管理', 2, '/business/plan/submitAudit/2', 'PUT', 1, 'admin', '', '//localhost:8787/business/plan/submitAudit/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":null,"data":"提交审核成功"}', 0, '', '2026-07-01 17:59:22', 10),
	(523, '方案管理', 2, '/business/plan/audit', 'PUT', 1, 'admin', '', '//localhost:8787/business/plan/audit', '127.0.0.1', '内网IP', '{"planId":2,"passed":true}', '{"code":200,"msg":null,"data":"审核成功"}', 0, '', '2026-07-01 17:59:24', 10),
	(524, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 17:59:40', 87),
	(525, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=3', '127.0.0.1', '内网IP', '{"stockOutIds":"3"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:35', 63),
	(526, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=4', '127.0.0.1', '内网IP', '{"stockOutIds":"4"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:37', 10),
	(527, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=5', '127.0.0.1', '内网IP', '{"stockOutIds":"5"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:39', 8),
	(528, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=6', '127.0.0.1', '内网IP', '{"stockOutIds":"6"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:41', 16),
	(529, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=7', '127.0.0.1', '内网IP', '{"stockOutIds":"7"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:44', 13),
	(530, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=8', '127.0.0.1', '内网IP', '{"stockOutIds":"8"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:46', 11),
	(531, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=9', '127.0.0.1', '内网IP', '{"stockOutIds":"9"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:21:48', 11),
	(532, '出库管理', 3, '/wms/stockOut', 'DELETE', 1, 'admin', '', '//localhost:8787/wms/stockOut?stockOutIds=10', '127.0.0.1', '内网IP', '{"stockOutIds":"10"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:22:02', 16),
	(533, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:23:25', 110),
	(534, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-07-01","warehouseId":1,"items":[{"productId":3,"productName":"身体套盒","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"purchasePrice":5800,"_mainPrice":5800,"amount":5800,"expiryDate":"2026-07-02"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:24:10', 50),
	(535, '入库管理', 2, '/wms/stockIn/confirm/4', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockIn/confirm/4', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-07-01 18:24:15', 10),
	(536, '出库管理', 2, '/wms/stockOut/confirm/11', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/11', '127.0.0.1', '内网IP', '{"warehouseId":1}', '{"code":200,"msg":"出库确认成功"}', 0, '', '2026-07-01 18:24:27', 36),
	(537, '系统操作', 1, '/common/upload', 'POST', 1, 'admin', '', '//localhost:8787/common/upload', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"","fileName":"20260701\\/427b7d11dc75fe074b29ef9f5b8487e0.jpg","url":"\\/profile\\/upload\\/20260701\\/427b7d11dc75fe074b29ef9f5b8487e0.jpg","newFileName":"427b7d11dc75fe074b29ef9f5b8487e0.jpg","originalFilename":"潮色.jpg"}', 0, '', '2026-07-01 18:24:37', 11),
	(538, '出库管理', 2, '/wms/stockOut/ship/11', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/ship/11', '127.0.0.1', '内网IP', '{"ship_type":"2","logistics_company":"shunfeng","logistics_no":"1111","shipment_images":"[\\"\\/profile\\/upload\\/20260701\\/427b7d11dc75fe074b29ef9f5b8487e0.jpg\\"]"}', '{"code":200,"msg":"发货成功"}', 0, '', '2026-07-01 18:24:39', 12),
	(539, '出库管理', 2, '/wms/stockOut/confirmReceipt/11', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirmReceipt/11', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"确认收货成功"}', 0, '', '2026-07-01 18:24:42', 18),
	(540, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:56:19', 52),
	(541, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:57:34', 83),
	(542, '出库管理', 2, '/wms/stockOut', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut', '127.0.0.1', '内网IP', '{"stockOutId":13,"stockOutNo":"CK20260701011","stockOutType":"1","outTargetType":"1","enterpriseId":4,"enterpriseName":"企业1","warehouseId":2,"warehouseName":"","contactEmployeeId":null,"contactEmployeeName":"-","contactPerson":null,"contactPhone":null,"shippingAddress":null,"responsibleId":1,"responsibleName":"超级管理员","totalQuantity":10,"totalAmount":"5800.00","stockOutDate":"2026-07-01","status":"0","shipType":"2","shipStatus":0,"logisticsCompany":null,"logisticsNo":null,"shipmentDate":null,"receiptDate":null,"shipmentImages":null,"planId":2,"planName":"企业1-30%","prepareId":12,"remark":null,"createBy":"admin","createTime":"2026-07-01 18:57:34","updateBy":"","updateTime":"2026-07-01 18:57:34","items":[{"itemId":15,"productId":3,"productName":"身体套盒","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"salePrice":5800,"_mainPrice":5800,"amount":5800,"remark":null}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 18:58:53', 44),
	(543, '出库管理', 2, '/wms/stockOut/confirm/13', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/13', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"出库确认成功"}', 0, '', '2026-07-01 18:58:57', 23),
	(544, '出库管理', 2, '/wms/stockOut/ship/13', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/ship/13', '127.0.0.1', '内网IP', '{"ship_type":"2","logistics_company":"shunfeng","logistics_no":"····"}', '{"code":200,"msg":"发货成功"}', 0, '', '2026-07-01 18:59:04', 22),
	(545, '出库管理', 2, '/wms/stockOut/confirmReceipt/13', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirmReceipt/13', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"确认收货成功"}', 0, '', '2026-07-01 18:59:11', 37),
	(546, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-07-01","warehouseId":1,"items":[{"productId":3,"productName":"身体套盒","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"purchasePrice":5800,"_mainPrice":5800,"amount":5800,"expiryDate":"2026-07-02"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 19:00:08', 29),
	(547, '入库管理', 2, '/wms/stockIn/confirm/5', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockIn/confirm/5', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-07-01 19:00:11', 20),
	(548, '出库管理', 2, '/wms/stockOut', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut', '127.0.0.1', '内网IP', '{"stockOutId":12,"stockOutNo":"CK20260701010","stockOutType":"1","outTargetType":"1","enterpriseId":4,"enterpriseName":"企业1","warehouseId":1,"warehouseName":"","contactEmployeeId":null,"contactEmployeeName":"-","contactPerson":null,"contactPhone":null,"shippingAddress":null,"responsibleId":1,"responsibleName":"超级管理员","totalQuantity":10,"totalAmount":"5800.00","stockOutDate":"2026-07-01","status":"0","shipType":"2","shipStatus":0,"logisticsCompany":null,"logisticsNo":null,"shipmentDate":null,"receiptDate":null,"shipmentImages":null,"planId":2,"planName":"企业1-30%","prepareId":11,"remark":null,"createBy":"admin","createTime":"2026-07-01 18:56:19","updateBy":"","updateTime":"2026-07-01 18:56:19","items":[{"itemId":14,"productId":3,"productName":"身体套盒","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"salePrice":5800,"_mainPrice":5800,"amount":5800,"remark":null}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 19:00:20', 36),
	(549, '出库管理', 2, '/wms/stockOut/confirm/12', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/12', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"出库确认成功"}', 0, '', '2026-07-01 19:00:25', 12),
	(550, '出库管理', 2, '/wms/stockOut/ship/12', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/ship/12', '127.0.0.1', '内网IP', '{"ship_type":"2","logistics_company":"shunfeng","logistics_no":"11111","remark":"11"}', '{"code":200,"msg":"发货成功"}', 0, '', '2026-07-01 19:00:31', 20),
	(551, '出库管理', 2, '/wms/stockOut/confirmReceipt/12', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirmReceipt/12', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"确认收货成功"}', 0, '', '2026-07-01 19:00:33', 21),
	(552, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":2}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 19:01:22', 17),
	(553, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":2}]}', '{"code":500,"msg":"备货总金额超过方案配赠金额剩余额度"}', 1, '备货总金额超过方案配赠金额剩余额度', '2026-07-01 19:01:35', 3),
	(554, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":500,"msg":"备货总金额超过方案配赠金额剩余额度"}', 1, '备货总金额超过方案配赠金额剩余额度', '2026-07-01 19:01:39', 3),
	(555, '企业管理', 2, '/business/enterprise', 'PUT', 1, 'admin', '', '//localhost:8787/business/enterprise', '127.0.0.1', '内网IP', '{"enterpriseId":9,"enterpriseName":"啊啊啊","pinyin":"AAA","bossName":"啊啊","phone":"13333333333","address":null,"enterpriseType":"1","storeCount":3,"annualPerformance":0,"enterpriseLevel":"3","serverUserId":[],"serverUserName":null,"cooperationStartDate":null,"cooperationEndDate":null,"status":"0","remark":null,"createBy":"admin","createTime":"2026-07-01 09:19:28","updateBy":"","updateTime":"2026-07-01 09:19:28"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-01 23:43:51', 71),
	(556, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":500,"msg":"备货总金额超过方案配赠金额剩余额度"}', 1, '备货总金额超过方案配赠金额剩余额度', '2026-07-02 00:41:17', 2),
	(557, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"支","unitType":"2","salePrice":580,"quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 00:43:05', 44),
	(558, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":2,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":500,"msg":"备货总金额超过方案配赠金额剩余额度"}', 1, '备货总金额超过方案配赠金额剩余额度', '2026-07-02 00:43:19', 3),
	(559, '备货管理', 1, '/business/stockPrepare/createFromPlan', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromPlan', '127.0.0.1', '内网IP', '{"planId":1,"items":[{"productId":3,"productName":"身体套盒","spec":"盒","unitType":"1","salePrice":"5800.00","quantity":1}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 00:43:43', 54),
	(560, '备货管理', 1, '/business/stockPrepare/createStockOut', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createStockOut', '127.0.0.1', '内网IP', '{"prepareId":15,"items":[{"itemId":16,"unitType":"1","originalQuantity":1}],"warehouseId":2}', '{"code":200,"msg":"操作成功","data":{"stockOutNo":"CK20260702001","stockOutType":"1","outTargetType":"1","prepareId":15,"planId":1,"warehouseId":2,"enterpriseId":7,"enterpriseName":"终测1","responsibleId":1,"responsibleName":"超级管理员","totalQuantity":10,"totalAmount":"5800.00","stockOutDate":"2026-07-02","status":"0","shipType":"2","remark":null,"createBy":"admin","createTime":"2026-07-02 00:45:51","stockOutId":15}}', 0, '', '2026-07-02 00:45:51', 87),
	(561, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-07-02","warehouseId":2,"items":[{"productId":3,"productName":"身体套盒","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":5800,"_mainPrice":5800,"amount":58000,"productionDate":"2026-07-01","expiryDate":"2026-07-04"},{"productId":2,"productName":"测试1","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":6800,"_mainPrice":6800,"amount":68000,"productionDate":"2026-07-01","expiryDate":"2026-07-04"},{"productId":1,"productName":"GCS-p7","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":2580,"_mainPrice":2580,"amount":25800,"productionDate":"2026-07-01","expiryDate":"2026-07-04"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 23:00:18', 69),
	(562, '入库管理', 2, '/wms/stockIn/confirm/1', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockIn/confirm/1', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-07-02 23:00:21', 23),
	(563, '卡项管理', 2, '/business/cardItem', 'PUT', 1, 'admin', '', '//localhost:8787/business/cardItem', '127.0.0.1', '内网IP', '{"cardItemId":1,"cardItemName":"卡项1","cardItemCode":"KX1-20260601","category":"2","defaultQuantity":10,"suggestedPrice":15180,"defaultUnitPrice":1518,"status":"0","remark":null,"createBy":"admin","createTime":"2026-06-01 19:09:02","updateBy":"admin","updateTime":"2026-06-26 11:27:40","products":[{"product_id":1,"unit_type":"1","pack_qty":10,"quantity":1,"remark":null},{"product_id":2,"unit_type":"1","pack_qty":10,"quantity":1,"remark":null},{"product_id":3,"unit_type":"1","pack_qty":10,"quantity":1,"remark":null}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 23:35:48', 40),
	(564, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 23:36:10', 37),
	(565, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":1}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 23:36:23', 45),
	(566, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":1}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-02 23:36:36', 12),
	(567, '备货管理', 1, '/business/stockPrepare/createFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createFromOrder', '127.0.0.1', '内网IP', '{"orderId":1}', '{"code":200,"msg":"操作成功","data":{"prepareNo":"SP202607020002","orderId":1,"orderNo":"SO202607020001","customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","totalQuantity":30,"totalAmount":"15180.00","shippedQuantity":0,"shippedAmount":0,"remainingQuantity":30,"remainingAmount":"15180.00","status":"0","remark":null,"createBy":"admin","createTime":"2026-07-02 23:36:46","prepareId":1}}', 0, '', '2026-07-02 23:36:46', 37),
	(568, '备货管理', 1, '/business/stockPrepare/createStockOut', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createStockOut', '127.0.0.1', '内网IP', '{"prepareId":1,"items":[{"itemId":1,"unitType":"1","originalQuantity":1},{"itemId":2,"unitType":"1","originalQuantity":1},{"itemId":3,"unitType":"1","originalQuantity":1}],"warehouseId":1}', '{"code":200,"msg":"操作成功","data":{"stockOutNo":"CK20260702001","stockOutType":"1","outTargetType":"1","prepareId":1,"planId":null,"warehouseId":1,"enterpriseId":7,"enterpriseName":"终测1","responsibleId":1,"responsibleName":"超级管理员","totalQuantity":30,"totalAmount":"15180.00","stockOutDate":"2026-07-02","status":"0","shipType":"2","remark":null,"createBy":"admin","createTime":"2026-07-02 23:58:53","stockOutId":1}}', 0, '', '2026-07-02 23:58:53', 37),
	(569, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"card"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:00:41', 102),
	(570, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:00:48', 9),
	(571, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":500,"msg":"订单已审核，不可重复审核"}', 1, '订单已审核，不可重复审核', '2026-07-03 00:00:50', 2),
	(572, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":500,"msg":"订单已审核，不可重复审核"}', 1, '订单已审核，不可重复审核', '2026-07-03 00:00:52', 1),
	(573, '销售管理', 1, '/business/sales/cancel', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/cancel', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":200,"msg":"取消成功"}', 0, '', '2026-07-03 00:01:02', 19),
	(574, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"close"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:19', 14),
	(575, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:31', 87),
	(576, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"close"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:35', 17),
	(577, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:39', 18),
	(578, '销售管理', 1, '/business/sales/cancel', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/cancel', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":200,"msg":"取消成功"}', 0, '', '2026-07-03 00:01:42', 14),
	(579, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"close"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:54', 31),
	(580, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":2,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:01:59', 20),
	(581, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":2}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:02:50', 64),
	(582, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:07:05', 47),
	(583, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":3,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:07:11', 18),
	(584, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":3}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:07:12', 20),
	(585, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[3,2]}', '{"code":200,"msg":"操作成功","successCount":2,"failedCount":0,"skippedCount":0,"details":[{"orderId":3,"orderNo":"SO202607030002","status":"success","prepareNo":"SP202607030001"},{"orderId":2,"orderNo":"SO202607030001","status":"success","prepareNo":"SP202607030002"}]}', 0, '', '2026-07-03 00:07:40', 95),
	(586, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[3,2]}', '{"code":200,"msg":"操作成功","successCount":0,"failedCount":0,"skippedCount":2,"details":[{"orderId":3,"orderNo":"SO202607030002","status":"skipped","msg":"已备货"},{"orderId":2,"orderNo":"SO202607030001","status":"skipped","msg":"已备货"}]}', 0, '', '2026-07-03 00:07:44', 8),
	(587, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[3,2]}', '{"code":200,"msg":"操作成功","successCount":0,"failedCount":0,"skippedCount":2,"details":[{"orderId":3,"orderNo":"SO202607030002","status":"skipped","msg":"已备货"},{"orderId":2,"orderNo":"SO202607030001","status":"skipped","msg":"已备货"}]}', 0, '', '2026-07-03 00:07:47', 5),
	(588, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:15', 27),
	(589, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":2,"customerName":"111","enterpriseId":7,"enterpriseName":"终测1","storeId":8,"storeName":"终测门店2","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:22', 17),
	(590, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":5,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:38', 28),
	(591, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":4,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:40', 7),
	(592, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":5}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:52', 42),
	(593, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":4}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:09:53', 16),
	(594, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[5,4]}', '{"code":200,"msg":"操作成功","successCount":2,"failedCount":0,"skippedCount":0,"details":[{"orderId":5,"orderNo":"SO202607030004","status":"success","prepareNo":"SP202607030003"},{"orderId":4,"orderNo":"SO202607030003","status":"success","prepareNo":"SP202607030004"}]}', 0, '', '2026-07-03 00:10:10', 31),
	(595, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[5,4]}', '{"code":200,"msg":"操作成功","successCount":0,"failedCount":0,"skippedCount":2,"details":[{"orderId":5,"orderNo":"SO202607030004","status":"skipped","msg":"已备货"},{"orderId":4,"orderNo":"SO202607030003","status":"skipped","msg":"已备货"}]}', 0, '', '2026-07-03 00:10:16', 7),
	(596, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":2,"customerName":"111","enterpriseId":7,"enterpriseName":"终测1","storeId":8,"storeName":"终测门店2","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:41', 97),
	(597, '销售管理', 1, '/business/sales', 'POST', 1, 'admin', '', '//localhost:8787/business/sales', '127.0.0.1', '内网IP', '{"customerId":3,"customerName":"新客户1","enterpriseId":7,"enterpriseName":"终测1","storeId":7,"storeName":"终测门店1","orderStatus":"0","packageName":"","storeDealer":"","customerFeedback":"","remark":"","items":[{"cardItemId":1,"productName":"卡项1","quantity":10,"dealAmount":"15180.00","paidAmount":"15180.00","paymentMethod":"cash"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:47', 23),
	(598, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":7,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:52', 19),
	(599, '销售管理', 1, '/business/sales/enterpriseAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/enterpriseAudit', '127.0.0.1', '内网IP', '{"orderId":6,"action":"open"}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:54', 21),
	(600, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":7}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:55', 14),
	(601, '销售管理', 1, '/business/sales/financeAudit', 'POST', 1, 'admin', '', '//localhost:8787/business/sales/financeAudit', '127.0.0.1', '内网IP', '{"orderId":6}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:10:56', 16),
	(602, '备货管理', 1, '/business/stockPrepare/batchCreateFromOrder', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/batchCreateFromOrder', '127.0.0.1', '内网IP', '{"orderIds":[6,7]}', '{"code":200,"msg":"操作成功","successCount":2,"failedCount":0,"skippedCount":0,"details":[{"orderId":6,"orderNo":"SO202607030005","status":"success","prepareNo":"SP202607030005"},{"orderId":7,"orderNo":"SO202607030006","status":"success","prepareNo":"SP202607030006"}]}', 0, '', '2026-07-03 00:11:09', 35),
	(603, '备货管理', 1, '/business/stockPrepare/createStockOut', 'POST', 1, 'admin', '', '//localhost:8787/business/stockPrepare/createStockOut', '127.0.0.1', '内网IP', '{"prepareId":7,"items":[{"itemId":19,"unitType":"1","originalQuantity":1},{"itemId":20,"unitType":"1","originalQuantity":1},{"itemId":21,"unitType":"1","originalQuantity":1}],"warehouseId":1}', '{"code":200,"msg":"操作成功","data":{"stockOutNo":"CK20260703001","stockOutType":"1","outTargetType":"1","prepareId":7,"planId":null,"warehouseId":1,"enterpriseId":7,"enterpriseName":"终测1","responsibleId":1,"responsibleName":"超级管理员","totalQuantity":30,"totalAmount":"15180.00","stockOutDate":"2026-07-03","status":"0","shipType":"2","remark":null,"createBy":"admin","createTime":"2026-07-03 00:29:48","stockOutId":2}}', 0, '', '2026-07-03 00:29:48', 100),
	(604, '出库管理', 2, '/wms/stockOut/confirm/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"货品【GCS-p7】库存不足，当前库存：0，出库数量：10"}', 1, '货品【GCS-p7】库存不足，当前库存：0，出库数量：10', '2026-07-03 00:30:22', 9),
	(605, '出库管理', 2, '/wms/stockOut', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut', '127.0.0.1', '内网IP', '{"stockOutId":2,"stockOutNo":"CK20260703001","stockOutType":"1","outTargetType":"1","enterpriseId":7,"enterpriseName":"终测1","warehouseId":1,"warehouseName":"上海仓库","contactEmployeeId":null,"contactEmployeeName":"-","contactPerson":null,"contactPhone":null,"shippingAddress":null,"responsibleId":1,"responsibleName":"超级管理员","totalQuantity":30,"totalAmount":"15180.00","stockOutDate":"2026-07-03","status":"0","shipType":"2","shipStatus":0,"logisticsCompany":null,"logisticsNo":null,"shipmentDate":null,"receiptDate":null,"shipmentImages":null,"planId":null,"planName":null,"prepareId":7,"remark":null,"createBy":"admin","createTime":"2026-07-03 00:29:48","updateBy":"","updateTime":"2026-07-03 00:29:48","items":[{"itemId":4,"productId":1,"productName":"GCS-p7","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"salePrice":2580,"_mainPrice":2580,"amount":2580,"remark":null},{"itemId":5,"productId":2,"productName":"测试1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"salePrice":6800,"_mainPrice":6800,"amount":6800,"remark":null},{"itemId":6,"productId":3,"productName":"身体套盒","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":1,"quantity":1,"salePrice":5800,"_mainPrice":5800,"amount":5800,"remark":null}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:30:44', 69),
	(606, '出库管理', 2, '/wms/stockOut/confirm/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":500,"msg":"货品【GCS-p7】库存不足，当前库存：0，出库数量：10"}', 1, '货品【GCS-p7】库存不足，当前库存：0，出库数量：10', '2026-07-03 00:30:46', 5),
	(607, '入库管理', 1, '/wms/stockIn', 'POST', 1, 'admin', '', '//localhost:8787/wms/stockIn', '127.0.0.1', '内网IP', '{"stockInType":"1","stockInDate":"2026-07-02","warehouseId":1,"items":[{"productId":2,"productName":"测试1","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":6800,"_mainPrice":6800,"amount":68000,"productionDate":"2026-07-01","expiryDate":"2026-07-04"},{"productId":3,"productName":"身体套盒","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":5800,"_mainPrice":5800,"amount":58000,"productionDate":"2026-07-01","expiryDate":"2026-07-04"},{"productId":1,"productName":"GCS-p7","supplierId":1,"supplierName":"供货商1","spec":"1","unit":"5","packQty":10,"unitType":"1","originalQuantity":10,"quantity":10,"purchasePrice":2580,"_mainPrice":2580,"amount":25800,"productionDate":"2026-07-01","expiryDate":"2026-07-04"}]}', '{"code":200,"msg":"操作成功"}', 0, '', '2026-07-03 00:31:21', 49),
	(608, '入库管理', 2, '/wms/stockIn/confirm/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockIn/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"入库确认成功"}', 0, '', '2026-07-03 00:31:30', 39),
	(609, '出库管理', 2, '/wms/stockOut/confirm/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirm/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"出库确认成功"}', 0, '', '2026-07-03 00:31:37', 30),
	(610, '出库管理', 2, '/wms/stockOut/ship/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/ship/2', '127.0.0.1', '内网IP', '{"ship_type":"2","logistics_company":"shunfeng","logistics_no":"111"}', '{"code":200,"msg":"发货成功"}', 0, '', '2026-07-03 00:31:44', 15),
	(611, '出库管理', 2, '/wms/stockOut/confirmReceipt/2', 'PUT', 1, 'admin', '', '//localhost:8787/wms/stockOut/confirmReceipt/2', '127.0.0.1', '内网IP', '[]', '{"code":200,"msg":"确认收货成功"}', 0, '', '2026-07-03 00:31:47', 6),
	(612, '备货管理', 1, '/business/stockPrepare/createStockOut', 'POST', 1, 'pengpeng', '', '//localhost:8787/business/stockPrepare/createStockOut', '127.0.0.1', '内网IP', '{"prepareId":6,"items":[{"itemId":16,"unitType":"1","originalQuantity":1},{"itemId":17,"unitType":"1","originalQuantity":1},{"itemId":18,"unitType":"1","originalQuantity":1}],"warehouseId":2}', '{"code":200,"msg":"操作成功","data":{"stockOutNo":"CK20260703002","stockOutType":"1","outTargetType":"1","prepareId":6,"planId":null,"warehouseId":2,"enterpriseId":7,"enterpriseName":"终测1","responsibleId":103,"responsibleName":"鹏鹏","totalQuantity":30,"totalAmount":"15180.00","stockOutDate":"2026-07-03","status":"0","shipType":"2","remark":null,"createBy":"admin","createTime":"2026-07-03 01:12:24","stockOutId":3}}', 0, '', '2026-07-03 01:12:24', 64);
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
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COMMENT='角色信息表';

-- 正在导出表  fuchenpro.sys_role 的数据：~3 rows (大约)
DELETE FROM `sys_role`;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `role_sort`, `data_scope`, `menu_check_strictly`, `dept_check_strictly`, `status`, `del_flag`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-04-25 01:10:45', '', NULL, '超级管理员'),
	(2, '普通角色', 'common', 2, '5', 1, 1, '0', '0', 'admin', '2026-04-25 01:10:45', 'admin', '2026-06-29 23:31:22', '普通角色'),
	(100, '市场老师', '1', 3, '5', 1, 1, '0', '0', 'admin', '2026-06-03 07:08:47', 'admin', '2026-06-28 21:57:21', NULL);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_role_dept 结构
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE IF NOT EXISTS `sys_role_dept` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和部门关联表';

-- 正在导出表  fuchenpro.sys_role_dept 的数据：~0 rows (大约)
DELETE FROM `sys_role_dept`;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_role_menu 结构
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE IF NOT EXISTS `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和菜单关联表';

-- 正在导出表  fuchenpro.sys_role_menu 的数据：~462 rows (大约)
DELETE FROM `sys_role_menu`;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
	(1, 1),
	(1, 101),
	(1, 103),
	(1, 104),
	(1, 105),
	(1, 1007),
	(1, 1008),
	(1, 1009),
	(1, 1010),
	(1, 1011),
	(1, 1016),
	(1, 1017),
	(1, 1018),
	(1, 1019),
	(1, 1020),
	(1, 1021),
	(1, 1022),
	(1, 1023),
	(1, 1024),
	(1, 1025),
	(1, 1026),
	(1, 1027),
	(1, 1028),
	(1, 1029),
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
	(1, 2085),
	(1, 2086),
	(1, 2087),
	(1, 2088),
	(1, 2089),
	(1, 2090),
	(1, 2091),
	(1, 2092),
	(1, 2093),
	(1, 3000),
	(1, 3001),
	(1, 3002),
	(1, 3003),
	(1, 3004),
	(1, 3005),
	(1, 3006),
	(1, 3007),
	(1, 3008),
	(1, 3009),
	(1, 3010),
	(1, 3011),
	(1, 3012),
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
	(1, 3031),
	(1, 3034),
	(1, 3035),
	(1, 3036),
	(1, 3037),
	(1, 3038),
	(1, 3044),
	(1, 3045),
	(1, 3046),
	(1, 3058),
	(1, 3059),
	(1, 3060),
	(1, 3061),
	(1, 3067),
	(1, 3068),
	(1, 3069),
	(1, 3070),
	(1, 3071),
	(1, 3072),
	(1, 3073),
	(1, 3074),
	(1, 3075),
	(1, 3076),
	(1, 3077),
	(1, 3080),
	(1, 3081),
	(1, 3082),
	(1, 3083),
	(1, 3084),
	(1, 3085),
	(1, 3086),
	(1, 3087),
	(1, 3088),
	(1, 3089),
	(1, 3090),
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
	(2, 2093),
	(2, 3000),
	(2, 3001),
	(2, 3002),
	(2, 3003),
	(2, 3004),
	(2, 3005),
	(2, 3006),
	(2, 3007),
	(2, 3008),
	(2, 3009),
	(2, 3010),
	(2, 3011),
	(2, 3012),
	(2, 3013),
	(2, 3014),
	(2, 3015),
	(2, 3016),
	(2, 3017),
	(2, 3018),
	(2, 3019),
	(2, 3020),
	(2, 3021),
	(2, 3022),
	(2, 3023),
	(2, 3024),
	(2, 3025),
	(2, 3026),
	(2, 3027),
	(2, 3028),
	(2, 3029),
	(2, 3031),
	(2, 3034),
	(2, 3035),
	(2, 3036),
	(2, 3037),
	(2, 3038),
	(2, 3044),
	(2, 3045),
	(2, 3046),
	(2, 3058),
	(2, 3059),
	(2, 3060),
	(2, 3061),
	(2, 3066),
	(2, 3067),
	(2, 3068),
	(2, 3069),
	(2, 3070),
	(2, 3071),
	(2, 3072),
	(2, 3073),
	(2, 3074),
	(2, 3075),
	(2, 3076),
	(2, 3077),
	(2, 3080),
	(2, 3081),
	(2, 3082),
	(2, 3083),
	(2, 3084),
	(2, 3085),
	(2, 3086),
	(2, 3087),
	(2, 3088),
	(2, 3089),
	(2, 3090),
	(100, 1035),
	(100, 2000),
	(100, 2001),
	(100, 2002),
	(100, 2003),
	(100, 2007),
	(100, 2008),
	(100, 2009),
	(100, 2010),
	(100, 2011),
	(100, 2012),
	(100, 2013),
	(100, 2015),
	(100, 2016),
	(100, 2017),
	(100, 2059),
	(100, 2060),
	(100, 2061),
	(100, 2065),
	(100, 2066),
	(100, 2067),
	(100, 2068),
	(100, 2069),
	(100, 2070),
	(100, 2072),
	(100, 2073),
	(100, 2074),
	(100, 2076),
	(100, 2077),
	(100, 2078),
	(100, 3031),
	(100, 3044),
	(100, 3045),
	(100, 3058),
	(100, 3059),
	(100, 3060),
	(100, 3080),
	(100, 3081),
	(100, 3082),
	(100, 3084),
	(100, 3085);
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
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8 COMMENT='用户信息表';

-- 正在导出表  fuchenpro.sys_user 的数据：~8 rows (大约)
DELETE FROM `sys_user`;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` (`user_id`, `dept_id`, `user_name`, `nick_name`, `user_type`, `email`, `phonenumber`, `sex`, `avatar`, `password`, `status`, `del_flag`, `login_ip`, `login_date`, `pwd_update_date`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 103, 'admin', '超级管理员', '00', 'ry@163.com', '15888888888', '1', 'https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/avatar/a66467cde77a863b9a21bff37f912c67.png', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-07-03 14:07:19', '2026-04-25 01:10:45', 'admin', '2026-04-25 01:10:45', '', NULL, '管理员'),
	(2, 106, 'ry', '若人头', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-04-25 01:10:45', '2026-04-25 01:10:45', 'admin', '2026-04-25 01:10:45', 'admin', '2026-04-28 22:24:11', '测试员'),
	(100, 101, '测试', '测试', '00', '', '15877778888', '0', '', '$2y$10$XouudTyFvzABxDZVRaQhZ.Jh9TSE9Qil2RA2N9mzv6hPqcyo.O4Uy', '0', '0', '', NULL, NULL, 'admin', '2026-04-25 21:08:28', 'admin', '2026-06-20 12:28:59', '111'),
	(101, NULL, '辅导费', '奋斗奋斗', '00', '', '', '0', '', '$2y$10$GiUlf1m6QaMIwgfxTHuDfeEoedCiiS0O1HBb3bcR.rW0DKPuua8gK', '0', '2', '', NULL, NULL, 'admin', '2026-05-20 19:52:31', '', NULL, NULL),
	(102, 103, '测试1', 'ceshi1', '00', '', '', '0', '', '$2y$10$wEWrRMhpcXRoi2k4wwXk4e5k/uAafpDT9XeVWUlymXgneSA66TvbS', '0', '0', '', NULL, NULL, 'admin', '2026-06-02 20:57:05', 'admin', '2026-06-03 00:31:47', NULL),
	(103, 101, 'pengpeng', '鹏鹏', '00', '', '', '0', '', '$2y$10$GesZnLrx.4nAp9MLcyqaYe7aDC0WeeMpbHXX5OlM253JrmgCESl1O', '0', '0', '127.0.0.1', '2026-07-03 01:11:36', '2026-06-28 21:44:07', 'admin', '2026-06-03 15:16:56', 'admin', '2026-06-28 21:44:07', NULL),
	(104, 103, '测试2', 'ceshi2', '00', '', '', '0', '', '$2y$10$yd7mU9koqjvPDFDBKjdRTuZx9FBfYV9azugwGnMg/Tt.WUO9xA3Ue', '0', '0', '', NULL, NULL, 'admin', '2026-06-28 23:01:09', '', NULL, NULL),
	(105, 104, 'ceshi', '测试', '00', '', '', '0', '', '$2y$10$OgLsq63yNo3Ikyt9IU0lIOn8ZD2kP4Brsp166K5lBTS4DDtyhaxTW', '0', '0', '127.0.0.1', '2026-06-28 23:15:43', NULL, 'admin', '2026-06-28 23:02:22', '', NULL, NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='员工详情表';

-- 正在导出表  fuchenpro.sys_user_detail 的数据：~4 rows (大约)
DELETE FROM `sys_user_detail`;
/*!40000 ALTER TABLE `sys_user_detail` DISABLE KEYS */;
INSERT INTO `sys_user_detail` (`detail_id`, `user_id`, `wechat`, `birthday`, `id_card`, `address`, `welcome_slogan`, `hire_date`, `employment_status`, `resign_date`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
	(1, 2, '', NULL, '', '', NULL, NULL, '0', NULL, 'admin', '2026-04-28 16:00:14', 'admin', '2026-04-28 22:24:11', ''),
	(2, 1, '', NULL, '', '', '永远相信美好的事情即将发生！', NULL, '0', NULL, '', '2026-05-24 22:33:34', '', NULL, NULL),
	(3, 102, '', NULL, '', '', NULL, NULL, '0', NULL, 'admin', '2026-06-03 00:31:47', '', NULL, ''),
	(4, 103, '', NULL, '', '', NULL, NULL, '0', NULL, 'admin', '2026-06-26 02:47:23', '', NULL, '');
/*!40000 ALTER TABLE `sys_user_detail` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user_post 结构
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE IF NOT EXISTS `sys_user_post` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户与岗位关联表';

-- 正在导出表  fuchenpro.sys_user_post 的数据：~7 rows (大约)
DELETE FROM `sys_user_post`;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
INSERT INTO `sys_user_post` (`user_id`, `post_id`) VALUES
	(1, 1),
	(2, 2),
	(100, 4),
	(102, 2),
	(103, 2),
	(104, 2),
	(105, 2);
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;

-- 导出  表 fuchenpro.sys_user_role 结构
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户和角色关联表';

-- 正在导出表  fuchenpro.sys_user_role 的数据：~10 rows (大约)
DELETE FROM `sys_user_role`;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES
	(1, 1),
	(2, 1),
	(100, 1),
	(100, 2),
	(100, 100),
	(102, 2),
	(103, 2),
	(103, 100),
	(104, 2),
	(105, 2);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
