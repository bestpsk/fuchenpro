-- =============================================
-- biz_rest_plan.sql 幂等安全版本
-- 使用 CREATE TABLE IF NOT EXISTS，不删除已有数据
-- 跳过数据迁移（biz_employee_rest_day 表可能已被删除）
-- =============================================

-- 1. 休息日方案表
CREATE TABLE IF NOT EXISTS `biz_rest_plan` (
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
CREATE TABLE IF NOT EXISTS `biz_rest_plan_employee` (
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
CREATE TABLE IF NOT EXISTS `biz_rest_plan_date` (
  `id`         bigint NOT NULL AUTO_INCREMENT,
  `plan_id`    bigint NOT NULL COMMENT '方案ID',
  `rest_date`  date NOT NULL COMMENT '休息日期',
  `reason`     varchar(200) DEFAULT '' COMMENT '事由',
  PRIMARY KEY (`id`),
  KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='休息日方案-日期表';

-- 4. 数据迁移已跳过（biz_employee_rest_day 表可能已被删除，无需迁移）
