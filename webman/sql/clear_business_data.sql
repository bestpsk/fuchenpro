-- ===========================================
-- 清理订单和进销存数据脚本
-- 用于软件测试，保留基础配置数据
-- 执行前请备份数据库！
-- ===========================================

-- 1. 清理明细表数据
DELETE FROM `biz_order_item`;
DELETE FROM `biz_stock_in_item`;
DELETE FROM `biz_stock_out_item`;
DELETE FROM `biz_stock_prepare_item`;
DELETE FROM `biz_stock_prepare_order`;
DELETE FROM `biz_stock_check_item`;
DELETE FROM `biz_stock_transfer_item`;
DELETE FROM `biz_plan_item`;
DELETE FROM `biz_package_item`;
DELETE FROM `biz_operation_record`;

-- 2. 清理主表数据
DELETE FROM `biz_sales_order`;
DELETE FROM `biz_repayment_record`;
DELETE FROM `biz_stock_in`;
DELETE FROM `biz_stock_out`;
DELETE FROM `biz_stock_prepare`;
DELETE FROM `biz_stock_check`;
DELETE FROM `biz_stock_transfer`;
DELETE FROM `biz_plan`;
DELETE FROM `biz_customer_package`;
DELETE FROM `biz_customer_archive`;

-- 3. 清理库存记录
DELETE FROM `biz_inventory`;

-- 4. 重置自增ID
ALTER TABLE `biz_order_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_sales_order` AUTO_INCREMENT = 1;
ALTER TABLE `biz_repayment_record` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_in_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_in` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_out_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_out` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_prepare_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_prepare_order` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_prepare` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_check_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_check` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_transfer_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_stock_transfer` AUTO_INCREMENT = 1;
ALTER TABLE `biz_plan_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_plan` AUTO_INCREMENT = 1;
ALTER TABLE `biz_inventory` AUTO_INCREMENT = 1;
ALTER TABLE `biz_package_item` AUTO_INCREMENT = 1;
ALTER TABLE `biz_customer_package` AUTO_INCREMENT = 1;
ALTER TABLE `biz_customer_archive` AUTO_INCREMENT = 1;
ALTER TABLE `biz_operation_record` AUTO_INCREMENT = 1;

-- 5. 验证清理结果
SELECT 'biz_sales_order' AS table_name, COUNT(*) AS count FROM biz_sales_order
UNION ALL SELECT 'biz_order_item', COUNT(*) FROM biz_order_item
UNION ALL SELECT 'biz_repayment_record', COUNT(*) FROM biz_repayment_record
UNION ALL SELECT 'biz_stock_in', COUNT(*) FROM biz_stock_in
UNION ALL SELECT 'biz_stock_in_item', COUNT(*) FROM biz_stock_in_item
UNION ALL SELECT 'biz_stock_out', COUNT(*) FROM biz_stock_out
UNION ALL SELECT 'biz_stock_out_item', COUNT(*) FROM biz_stock_out_item
UNION ALL SELECT 'biz_stock_prepare', COUNT(*) FROM biz_stock_prepare
UNION ALL SELECT 'biz_stock_prepare_item', COUNT(*) FROM biz_stock_prepare_item
UNION ALL SELECT 'biz_stock_prepare_order', COUNT(*) FROM biz_stock_prepare_order
UNION ALL SELECT 'biz_stock_check', COUNT(*) FROM biz_stock_check
UNION ALL SELECT 'biz_stock_check_item', COUNT(*) FROM biz_stock_check_item
UNION ALL SELECT 'biz_stock_transfer', COUNT(*) FROM biz_stock_transfer
UNION ALL SELECT 'biz_stock_transfer_item', COUNT(*) FROM biz_stock_transfer_item
UNION ALL SELECT 'biz_inventory', COUNT(*) FROM biz_inventory
UNION ALL SELECT 'biz_plan', COUNT(*) FROM biz_plan
UNION ALL SELECT 'biz_plan_item', COUNT(*) FROM biz_plan_item;

-- 6. 验证基础数据保留
SELECT 'biz_product' AS table_name, COUNT(*) AS count FROM biz_product
UNION ALL SELECT 'biz_warehouse', COUNT(*) FROM biz_warehouse
UNION ALL SELECT 'biz_supplier', COUNT(*) FROM biz_supplier
UNION ALL SELECT 'biz_enterprise', COUNT(*) FROM biz_enterprise
UNION ALL SELECT 'biz_store', COUNT(*) FROM biz_store
UNION ALL SELECT 'biz_customer', COUNT(*) FROM biz_customer
UNION ALL SELECT 'biz_card_item', COUNT(*) FROM biz_card_item;

-- 完成
SELECT '数据清理完成，基础数据已保留' AS message;