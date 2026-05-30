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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.qrtz_calendars 结构
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE IF NOT EXISTS `qrtz_calendars` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`,`calendar_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日历信息表';

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.qrtz_locks 结构
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE IF NOT EXISTS `qrtz_locks` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`,`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储的悲观锁信息表';

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.qrtz_paused_trigger_grps 结构
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE IF NOT EXISTS `qrtz_paused_trigger_grps` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`,`trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='暂停的触发器表';

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.qrtz_scheduler_state 结构
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE IF NOT EXISTS `qrtz_scheduler_state` (
  `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint(13) NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint(13) NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`,`instance_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='调度器状态表';

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.sys_role_dept 结构
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE IF NOT EXISTS `sys_role_dept` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和部门关联表';

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.sys_role_menu 结构
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE IF NOT EXISTS `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色和菜单关联表';

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

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

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.sys_user_post 结构
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE IF NOT EXISTS `sys_user_post` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户与岗位关联表';

-- 数据导出被取消选择。

-- 导出  表 fuchenpro.sys_user_role 结构
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户和角色关联表';

-- 数据导出被取消选择。

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
