-- 将 dept_id (int) 改为 dept_ids (varchar)，支持多部门逗号分隔
ALTER TABLE `biz_attendance_config` 
  CHANGE COLUMN `dept_id` `dept_ids` varchar(500) DEFAULT NULL COMMENT '部门ID列表（逗号分隔）';

-- 删除旧索引
ALTER TABLE `biz_attendance_config` DROP INDEX `idx_dept_id`;

-- 新索引
ALTER TABLE `biz_attendance_config` ADD INDEX `idx_dept_ids` (`dept_ids`(100));
