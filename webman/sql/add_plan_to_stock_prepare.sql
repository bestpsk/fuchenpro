-- 方案分批次备货：biz_stock_prepare 增加方案关联字段
ALTER TABLE `biz_stock_prepare` ADD COLUMN `plan_id` int DEFAULT NULL COMMENT '关联方案ID' AFTER `order_no`;
ALTER TABLE `biz_stock_prepare` ADD COLUMN `plan_no` varchar(30) DEFAULT NULL COMMENT '关联方案编号' AFTER `plan_id`;
ALTER TABLE `biz_stock_prepare` ADD COLUMN `creator_user_id` bigint DEFAULT NULL COMMENT '创建人用户ID' AFTER `create_by`;

-- 方案分批次备货：biz_stock_prepare_item 增加方案明细关联字段
ALTER TABLE `biz_stock_prepare_item` ADD COLUMN `plan_item_id` int DEFAULT NULL COMMENT '关联方案明细ID' AFTER `card_item_id`;
