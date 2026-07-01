-- 性能优化索引补充
-- biz_sales_order 业绩统计常用查询
ALTER TABLE biz_sales_order ADD INDEX idx_creator_user_id (creator_user_id);
ALTER TABLE biz_sales_order ADD INDEX idx_create_time (create_time);

-- biz_operation_record 操作记录统计
ALTER TABLE biz_operation_record ADD INDEX idx_operator_user_id (operator_user_id);

-- biz_stock_in / biz_stock_out 仓库过滤
ALTER TABLE biz_stock_in ADD INDEX idx_warehouse_id (warehouse_id);
ALTER TABLE biz_stock_out ADD INDEX idx_warehouse_id (warehouse_id);

-- biz_stock_in_item FIFO 批次查询组合索引
ALTER TABLE biz_stock_in_item ADD INDEX idx_wh_product_expiry (warehouse_id, product_id, expiry_date);
