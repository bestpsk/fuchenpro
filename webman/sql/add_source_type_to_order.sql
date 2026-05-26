ALTER TABLE `biz_sales_order`
  ADD COLUMN `source_type` char(1) NOT NULL DEFAULT '0' COMMENT '来源类型（0开单 1操作 2还款 3手动）' AFTER `order_status`,
  ADD COLUMN `operation_batch_id` varchar(32) DEFAULT NULL COMMENT '操作批次ID（来源为操作时关联）' AFTER `source_type`;

UPDATE `biz_sales_order` SET `source_type` = '0' WHERE `order_status` IN ('0', '1', '2');
UPDATE `biz_sales_order` SET `source_type` = '2' WHERE `order_status` = '3';
