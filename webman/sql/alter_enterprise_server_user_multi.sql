-- 企业服务人字段改为支持多人（逗号分隔存储）
ALTER TABLE `biz_enterprise` MODIFY COLUMN `server_user_id` VARCHAR(255) DEFAULT NULL COMMENT '服务人ID(逗号分隔)';
ALTER TABLE `biz_enterprise` MODIFY COLUMN `server_user_name` VARCHAR(500) DEFAULT NULL COMMENT '服务人姓名(顿号分隔)';
ALTER TABLE `biz_enterprise` DROP INDEX `idx_server_user_id`;
