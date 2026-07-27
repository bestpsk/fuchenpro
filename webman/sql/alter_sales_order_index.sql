-- 为 biz_sales_order 添加 (customer_id, order_status) 联合索引
-- 理由：客户列表批量查询成交额时使用 whereIn('customer_id', $ids)->whereIn('order_status', ['1','2'])
--       联合索引比两个独立索引更高效，覆盖 GROUP BY customer_id 的聚合查询
-- 影响范围：BizCustomerService::selectCustomerList、BizCustomerService::searchCustomer
-- 执行方式：手动在 MySQL 中执行

ALTER TABLE `biz_sales_order` ADD INDEX `idx_customer_status` (`customer_id`, `order_status`);
