-- =============================================
-- 补录历史缺失的开单档案
-- 为已有订单但缺少开单档案(source_type='0')的记录补录档案
-- 日期: 2026-06-19
-- =============================================

INSERT INTO biz_customer_archive (customer_id, customer_name, enterprise_id, enterprise_name, store_id, store_name, archive_date, archive_type, source_type, source_id, plan_items, amount, operator_user_id, operator_user_name, remark, create_by, create_time)
SELECT
    so.customer_id,
    so.customer_name,
    so.enterprise_id,
    so.enterprise_name,
    so.store_id,
    so.store_name,
    DATE(so.create_time),
    'sales',
    '0',
    so.order_id,
    (
        SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('name', oi.product_name, 'quantity', oi.quantity) SEPARATOR ','), ']')
        FROM biz_order_item oi WHERE oi.order_id = so.order_id
    ),
    so.deal_amount,
    so.creator_user_id,
    so.creator_user_name,
    CONCAT('套餐: ', IFNULL(so.package_name, '')),
    so.create_by,
    so.create_time
FROM biz_sales_order so
LEFT JOIN biz_customer_archive ca ON ca.source_type = '0' AND ca.source_id = so.order_id
WHERE ca.archive_id IS NULL
  AND so.source_type = '0'
  AND so.customer_id IS NOT NULL;

SELECT '补录完成' AS status;
