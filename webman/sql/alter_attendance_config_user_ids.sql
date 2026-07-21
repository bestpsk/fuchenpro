-- 将 user_id (int) 改为 user_ids (varchar)，支持多用户逗号分隔
ALTER TABLE `biz_attendance_config`
  CHANGE COLUMN `user_id` `user_ids` varchar(500) DEFAULT NULL COMMENT '用户ID列表（逗号分隔）';

-- 删除旧索引
ALTER TABLE `biz_attendance_config` DROP INDEX `idx_user_id`;

-- 新索引
ALTER TABLE `biz_attendance_config` ADD INDEX `idx_user_ids` (`user_ids`(100));
