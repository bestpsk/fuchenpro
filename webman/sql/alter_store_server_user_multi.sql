-- 门店服务员工字段改为支持多人（逗号分隔存储）
ALTER TABLE `biz_store` MODIFY COLUMN `server_user_id` VARCHAR(255) DEFAULT NULL COMMENT '服务员工ID(逗号分隔)';
ALTER TABLE `biz_store` MODIFY COLUMN `server_user_name` VARCHAR(500) DEFAULT NULL COMMENT '服务员工姓名(顿号分隔)';
ALTER TABLE `biz_store` DROP INDEX `idx_server_user_id`;
