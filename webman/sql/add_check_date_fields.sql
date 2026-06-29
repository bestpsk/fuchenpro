-- 给盘点明细表添加生产日期和到期日期字段
ALTER TABLE `biz_stock_check_item` ADD COLUMN `production_date` date DEFAULT NULL COMMENT '生产日期' AFTER `remark`;
ALTER TABLE `biz_stock_check_item` ADD COLUMN `expiry_date` date DEFAULT NULL COMMENT '到期日期' AFTER `production_date`;
