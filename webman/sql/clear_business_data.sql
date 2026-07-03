-- =====================================================
-- 清理业务交易数据，保留基础档案和系统配置
-- 执行前请确认已备份数据库
-- =====================================================

-- 1. 销售订单
TRUNCATE TABLE `biz_order_item`;
TRUNCATE TABLE `biz_sales_order`;

-- 1.1 客户档案（与销售订单关联，需同步清理避免 source_id 撞车）
TRUNCATE TABLE `biz_customer_archive`;

-- 2. 入库管理
TRUNCATE TABLE `biz_stock_in_item`;
TRUNCATE TABLE `biz_stock_in`;

-- 3. 出库管理
TRUNCATE TABLE `biz_stock_out_item`;
TRUNCATE TABLE `biz_stock_out`;

-- 4. 库存盘点
TRUNCATE TABLE `biz_stock_check_item`;
TRUNCATE TABLE `biz_stock_check`;

-- 5. 库存调拨
TRUNCATE TABLE `biz_stock_transfer_item`;
TRUNCATE TABLE `biz_stock_transfer`;

-- 6. 订单备货
TRUNCATE TABLE `biz_stock_prepare_item`;
TRUNCATE TABLE `biz_stock_prepare_order`;
TRUNCATE TABLE `biz_stock_prepare`;

-- 7. 库存数据
TRUNCATE TABLE `biz_inventory`;

-- 8. 还款记录
TRUNCATE TABLE `biz_repayment_record`;

-- 9. 客户套餐购买记录
TRUNCATE TABLE `biz_customer_package`;

-- 10. 操作日志
TRUNCATE TABLE `biz_operation_record`;

-- 11. 考勤打卡记录
TRUNCATE TABLE `biz_attendance_clock`;
TRUNCATE TABLE `biz_attendance_record`;

-- 12. 日程安排
TRUNCATE TABLE `biz_schedule`;

-- 13. 问题反馈
TRUNCATE TABLE `biz_feedback_reply`;
TRUNCATE TABLE `biz_feedback`;

-- 14. 财务报销
TRUNCATE TABLE `fin_reimbursement_item`;
TRUNCATE TABLE `fin_reimbursement`;

-- =====================================================
-- 验证清理结果
-- =====================================================
SELECT 'biz_sales_order' AS table_name, COUNT(*) AS count FROM biz_sales_order
UNION ALL SELECT 'biz_stock_in', COUNT(*) FROM biz_stock_in
UNION ALL SELECT 'biz_stock_out', COUNT(*) FROM biz_stock_out
UNION ALL SELECT 'biz_inventory', COUNT(*) FROM biz_inventory
UNION ALL SELECT 'biz_customer_package', COUNT(*) FROM biz_customer_package
UNION ALL SELECT 'biz_customer_archive', COUNT(*) FROM biz_customer_archive;