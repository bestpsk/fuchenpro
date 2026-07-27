-- =============================================
-- biz_leave.sql 幂等安全版本
-- 使用 CREATE TABLE IF NOT EXISTS + INSERT IGNORE
-- 安全执行：不删表、不报错、不修改已有数据
-- 跳过已废弃的 biz_employee_rest_day 表（被 biz_rest_plan 替代）
-- =============================================

-- ===================== 1. 创建业务表（不删除已有数据）=====================

-- 1.1 休假类型配置表
CREATE TABLE IF NOT EXISTS `biz_leave_type` (
  `type_id`        bigint NOT NULL AUTO_INCREMENT COMMENT '类型ID',
  `type_name`      varchar(50) NOT NULL COMMENT '类型名称',
  `type_code`      varchar(50) NOT NULL COMMENT '类型代码',
  `need_approval`  tinyint(1) DEFAULT 0 COMMENT '是否需审批(0否 1是)',
  `is_public`      tinyint(1) DEFAULT 0 COMMENT '是否公共假期(0否 1是,影响全员)',
  `color`          varchar(20) DEFAULT '#3D6DF7' COMMENT '显示颜色',
  `sort`           int DEFAULT 0 COMMENT '排序',
  `status`         char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `create_by`      varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time`    datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`      varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time`    datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uk_type_code` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休假类型配置表';

-- 1.2 biz_employee_rest_day 已废弃（被 biz_rest_plan 系列表替代），跳过创建

-- 1.3 休假记录/请假单表
CREATE TABLE IF NOT EXISTS `biz_leave` (
  `leave_id`         bigint NOT NULL AUTO_INCREMENT COMMENT '休假ID',
  `leave_no`         varchar(32) NOT NULL COMMENT '休假单号(LV+YYYYMMDD+4位序号)',
  `user_id`          bigint NOT NULL COMMENT '员工ID',
  `user_name`        varchar(50) DEFAULT '' COMMENT '员工姓名',
  `dept_id`          bigint DEFAULT NULL COMMENT '部门ID',
  `leave_type_id`    bigint NOT NULL COMMENT '休假类型ID',
  `start_date`       date NOT NULL COMMENT '开始日期',
  `end_date`         date NOT NULL COMMENT '结束日期',
  `start_time_type`  char(1) DEFAULT '0' COMMENT '开始时段(0全天 1上午 2下午)',
  `end_time_type`    char(1) DEFAULT '0' COMMENT '结束时段(0全天 1上午 2下午)',
  `leave_days`       decimal(5,1) DEFAULT 1.0 COMMENT '休假天数(支持0.5天)',
  `reason`           text COMMENT '事由',
  `status`           char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待审核 1已通过 2已拒绝 3已撤销)',
  `approver_id`      bigint DEFAULT NULL COMMENT '审核人ID',
  `approver_name`    varchar(50) DEFAULT '' COMMENT '审核人姓名',
  `approve_time`     datetime DEFAULT NULL COMMENT '审核时间',
  `approve_remark`   text COMMENT '审核备注',
  `create_by`        varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time`      datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`        varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time`      datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`leave_id`),
  UNIQUE KEY `uk_leave_no` (`leave_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_leave_type` (`leave_type_id`),
  KEY `idx_date_range` (`start_date`, `end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休假记录/请假单表';

-- 1.4 公共假期日历表
CREATE TABLE IF NOT EXISTS `biz_holiday` (
  `holiday_id`     bigint NOT NULL AUTO_INCREMENT COMMENT '假期ID',
  `holiday_name`   varchar(100) NOT NULL COMMENT '假期名称(如:国庆节)',
  `start_date`     date NOT NULL COMMENT '开始日期',
  `end_date`       date NOT NULL COMMENT '结束日期',
  `leave_type_id`  bigint NOT NULL COMMENT '关联休假类型ID(法定假日/公司假期)',
  `year`           int NOT NULL COMMENT '年份',
  `status`         char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `create_by`      varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time`    datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`      varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time`    datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`holiday_id`),
  KEY `idx_year` (`year`),
  KEY `idx_date` (`start_date`, `end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公共假期日历表';

-- ===================== 2. 插入字典数据（忽略重复）=====================

-- 2.1 休假单状态字典
INSERT IGNORE INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('休假单状态', 'biz_leave_status', '0', 'admin', NOW(), '休假单状态列表');

INSERT IGNORE INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '待审核', '0', 'biz_leave_status', '', 'info', 'N', '0', 'admin', NOW()),
(2, '已通过', '1', 'biz_leave_status', '', 'success', 'N', '0', 'admin', NOW()),
(3, '已拒绝', '2', 'biz_leave_status', '', 'danger', 'N', '0', 'admin', NOW()),
(4, '已撤销', '3', 'biz_leave_status', '', 'warning', 'N', '0', 'admin', NOW());

-- 2.2 休假时段字典
INSERT IGNORE INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('休假时段', 'biz_leave_time_type', '0', 'admin', NOW(), '休假时段列表');

INSERT IGNORE INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '全天', '0', 'biz_leave_time_type', '', 'primary', 'Y', '0', 'admin', NOW()),
(2, '上午', '1', 'biz_leave_time_type', '', 'info', 'N', '0', 'admin', NOW()),
(3, '下午', '2', 'biz_leave_time_type', '', 'info', 'N', '0', 'admin', NOW());

-- 2.3 考勤状态扩展(追加 5/6/7) - 按 dict_value 去重
INSERT IGNORE INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(6, '公共假期', '5', 'biz_attendance_status', '', 'primary', 'N', '0', 'admin', NOW()),
(7, '休息日', '6', 'biz_attendance_status', '', 'info', 'N', '0', 'admin', NOW()),
(8, '请假休假', '7', 'biz_attendance_status', '', 'success', 'N', '0', 'admin', NOW());

-- ===================== 3. 菜单变更 =====================

SET @attendance_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤管理' AND parent_id = 0) t);

-- 3.1 将行程安排移至考勤管理下（幂等 UPDATE）
UPDATE `sys_menu` SET `parent_id` = @attendance_menu_id, `order_num` = 4
WHERE `menu_name` = '行程安排' AND `path` = 'schedule';

-- 3.2 新增"考勤统计"菜单（通过 route_name 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '考勤统计', @attendance_menu_id, 2, 'stats', 'business/attendance/stats', NULL, 'AttendanceStats', 1, 0, 'C', '0', '0', 'business:attendance:stats:list', 'chart', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE route_name = 'AttendanceStats');

SET @stats_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '考勤统计' AND path = 'stats') t);
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('统计查询', @stats_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:stats:query', '#', 'admin', NOW()),
('统计导出', @stats_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:attendance:stats:export', '#', 'admin', NOW());

-- 3.3 新增"休假管理"二级目录（通过 path + parent_id 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '休假管理', @attendance_menu_id, 5, 'leave', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'calendar', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '休假管理' AND path = 'leave' AND parent_id = @attendance_menu_id);

SET @leave_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假管理' AND path = 'leave' AND parent_id = @attendance_menu_id) t);

-- 3.4 休假类型菜单（通过 route_name 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '休假类型', @leave_menu_id, 1, 'type', 'business/leave/type', NULL, 'LeaveType', 1, 0, 'C', '0', '0', 'business:leave:type:list', 'tree-table', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE route_name = 'LeaveType');

SET @leave_type_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假类型' AND path = 'type' AND parent_id = @leave_menu_id) t);
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('类型查询', @leave_type_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:type:query', '#', 'admin', NOW()),
('类型新增', @leave_type_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:type:add', '#', 'admin', NOW()),
('类型修改', @leave_type_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:type:edit', '#', 'admin', NOW()),
('类型删除', @leave_type_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:type:remove', '#', 'admin', NOW());

-- 3.5 休息日配置菜单（通过 route_name 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '休息日配置', @leave_menu_id, 2, 'restDay', 'business/leave/restDay', NULL, 'LeaveRestDay', 1, 0, 'C', '0', '0', 'business:leave:rest:list', 'time-range', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE route_name = 'LeaveRestDay');

SET @rest_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休息日配置' AND path = 'restDay' AND parent_id = @leave_menu_id) t);
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('休息日查询', @rest_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:rest:query', '#', 'admin', NOW()),
('休息日配置', @rest_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:rest:add', '#', 'admin', NOW()),
('休息日修改', @rest_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:rest:edit', '#', 'admin', NOW()),
('休息日删除', @rest_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:rest:remove', '#', 'admin', NOW());

-- 3.6 请假管理菜单（通过 route_name 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '请假管理', @leave_menu_id, 3, 'index', 'business/leave/index', NULL, 'LeaveIndex', 1, 0, 'C', '0', '0', 'business:leave:list', 'edit', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE route_name = 'LeaveIndex');

SET @leave_index_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '请假管理' AND path = 'index' AND parent_id = @leave_menu_id) t);
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('请假查询', @leave_index_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:query', '#', 'admin', NOW()),
('请假新增', @leave_index_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:add', '#', 'admin', NOW()),
('请假审核', @leave_index_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:approve', '#', 'admin', NOW()),
('请假删除', @leave_index_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:remove', '#', 'admin', NOW());

-- 3.7 假期日历菜单（通过 route_name 去重）
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '假期日历', @leave_menu_id, 4, 'holiday', 'business/leave/holiday', NULL, 'LeaveHoliday', 1, 0, 'C', '0', '0', 'business:leave:holiday:list', 'date', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE route_name = 'LeaveHoliday');

SET @holiday_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '假期日历' AND path = 'holiday' AND parent_id = @leave_menu_id) t);
INSERT IGNORE INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('假期查询', @holiday_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:holiday:query', '#', 'admin', NOW()),
('假期新增', @holiday_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:holiday:add', '#', 'admin', NOW()),
('假期修改', @holiday_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:holiday:edit', '#', 'admin', NOW()),
('假期删除', @holiday_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:leave:holiday:remove', '#', 'admin', NOW());

-- ===================== 4. 为管理员角色分配权限（忽略重复）=====================

SET @admin_role_id = 1;
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu
WHERE menu_name IN ('考勤统计', '休假管理', '休假类型', '休息日配置', '请假管理', '假期日历')
   OR parent_id IN (
       SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name IN ('考勤统计', '休假类型', '休息日配置', '请假管理', '假期日历')) t
   )
   OR parent_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '休假管理' AND path = 'leave') t);

-- ===================== 5. 插入默认休假类型（按 type_code 去重）=====================

INSERT IGNORE INTO `biz_leave_type` (`type_name`, `type_code`, `need_approval`, `is_public`, `color`, `sort`, `status`, `create_by`) VALUES
('休息日',     'rest_day',           0, 0, '#909399', 1, '0', 'admin'),
('请假',       'personal_leave',     1, 0, '#FF9900', 2, '0', 'admin'),
('年假',       'annual_leave',       1, 0, '#00B42A', 3, '0', 'admin'),
('法定假日',   'statutory_holiday',  0, 1, '#F53F3F', 4, '0', 'admin'),
('公司假期',   'company_holiday',    0, 1, '#722ED1', 5, '0', 'admin');
