-- 移除 biz_store 表的 creator_name 冗余字段
-- 理由：该字段从未在任何 Service 中赋值或使用，create_by 字段已记录创建者用户名
-- 影响范围：BizStore Model 的 fillable 和 excelConfig
-- 执行方式：手动在 MySQL 中执行

ALTER TABLE `biz_store` DROP COLUMN `creator_name`;
