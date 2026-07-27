-- =============================================
-- 休息日方案架构重构
-- 新建3张表 + 数据迁移
-- =============================================

-- 1. 休息日方案表
DROP TABLE IF EXISTS `biz_rest_plan`;
CREATE TABLE `biz_rest_plan` (
  `plan_id`        bigint NOT NULL AUTO_INCREMENT COMMENT '方案ID',
  `plan_name`      varchar(100) NOT NULL COMMENT '方案名称',
  `config_type`    char(1) NOT NULL DEFAULT '0' COMMENT '配置类型(0按周 1按日期)',
  `monday`         char(1) DEFAULT '0' COMMENT '周一(0上班 1休息)',
  `tuesday`        char(1) DEFAULT '0',
  `wednesday`      char(1) DEFAULT '0',
  `thursday`       char(1) DEFAULT '0',
  `friday`         char(1) DEFAULT '0',
  `saturday`       char(1) DEFAULT '1',
  `sunday`         char(1) DEFAULT '1',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `status`         char(1) NOT NULL DEFAULT '0' COMMENT '状态(0有效 1停用)',
  `create_by`      varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time`    datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`      varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time`    datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休息日方案表';

-- 2. 方案-员工关联表
DROP TABLE IF EXISTS `biz_rest_plan_employee`;
CREATE TABLE `biz_rest_plan_employee` (
  `id`         bigint NOT NULL AUTO_INCREMENT,
  `plan_id`    bigint NOT NULL COMMENT '方案ID',
  `user_id`    bigint NOT NULL COMMENT '员工ID',
  `user_name`  varchar(50) DEFAULT '' COMMENT '员工姓名',
  `dept_id`    bigint DEFAULT NULL COMMENT '部门ID',
  `dept_name`  varchar(50) DEFAULT '' COMMENT '部门名称',
  PRIMARY KEY (`id`),
  KEY `idx_plan_id` (`plan_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休息日方案-员工关联表';

-- 3. 方案-日期表（按日期模式用）
DROP TABLE IF EXISTS `biz_rest_plan_date`;
CREATE TABLE `biz_rest_plan_date` (
  `id`         bigint NOT NULL AUTO_INCREMENT,
  `plan_id`    bigint NOT NULL COMMENT '方案ID',
  `rest_date`  date NOT NULL COMMENT '休息日期',
  `reason`     varchar(200) DEFAULT '' COMMENT '事由',
  PRIMARY KEY (`id`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休息日方案-日期表';

-- 4. 数据迁移：将 biz_employee_rest_day 按 config_name 分组迁移到方案表
-- 仅迁移有 config_name 的记录
INSERT INTO `biz_rest_plan` (`plan_name`, `config_type`, `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`, `effective_date`, `status`, `create_by`, `create_time`)
SELECT DISTINCT
  COALESCE(NULLIF(config_name, ''), CONCAT('休息日配置-', user_id)) AS plan_name,
  '0' AS config_type,
  monday, tuesday, wednesday, thursday, friday, saturday, sunday,
  effective_date, status, create_by, create_time
FROM `biz_employee_rest_day`
GROUP BY COALESCE(NULLIF(config_name, ''), CONCAT('休息日配置-', user_id)), monday, tuesday, wednesday, thursday, friday, saturday, sunday, effective_date, status, create_by, create_time;

-- 5. 迁移员工关联（JOIN sys_user/sys_dept 自动回填姓名和部门，避免空值）
INSERT INTO `biz_rest_plan_employee` (`plan_id`, `user_id`, `user_name`, `dept_id`, `dept_name`)
SELECT p.plan_id, r.user_id,
  COALESCE(NULLIF(u.nick_name, ''), u.user_name) AS user_name,
  u.dept_id,
  d.dept_name
FROM `biz_employee_rest_day` r
JOIN `biz_rest_plan` p ON p.plan_name = COALESCE(NULLIF(r.config_name, ''), CONCAT('休息日配置-', r.user_id))
  AND p.monday = r.monday AND p.tuesday = r.tuesday AND p.wednesday = r.wednesday
  AND p.thursday = r.thursday AND p.friday = r.friday AND p.saturday = r.saturday AND p.sunday = r.sunday
  AND p.effective_date = r.effective_date
LEFT JOIN `sys_user` u ON u.user_id = r.user_id
LEFT JOIN `sys_dept` d ON d.dept_id = u.dept_id;
