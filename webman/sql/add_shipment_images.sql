-- 出库管理发货增加图片字段
ALTER TABLE `biz_stock_out` ADD COLUMN `shipment_images` text DEFAULT NULL COMMENT '发货图片(JSON数组)' AFTER `receipt_date`;
