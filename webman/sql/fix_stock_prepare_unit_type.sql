-- ============================================================
-- 修复备货明细数据 - 统一为最小单位存储
-- 修复日期: 2026-06-06
-- 核心原则：biz_stock_prepare_item.quantity 始终存储最小单位（副单位）数量
--           biz_stock_prepare_item.sale_price 始终存储副单位出货价（sale_price_spec）
-- 注意：MySQL UPDATE SET 从左到右求值，金额计算必须在数量更新之前
-- ============================================================

-- 1. 检查当前数据状态
SELECT
    spi.item_id, spi.prepare_id, spi.product_id, spi.product_name,
    spi.unit_type, spi.pack_qty, spi.sale_price,
    p.sale_price as product_main_price, p.sale_price_spec as product_sub_price,
    spi.quantity, spi.amount,
    spi.shipped_quantity, spi.shipped_amount,
    spi.remaining_quantity, spi.remaining_amount,
    CASE
        WHEN spi.unit_type = '1' AND spi.sale_price = p.sale_price THEN 'NEED_FIX_TYPE1'
        WHEN spi.unit_type = '2' AND spi.sale_price = p.sale_price THEN 'NEED_FIX_TYPE2'
        ELSE 'OK'
    END as status
FROM biz_stock_prepare_item spi
JOIN biz_product p ON spi.product_id = p.product_id;

-- 2. 修正 unit_type='1' 且 sale_price 是主单位出货价的记录
-- 说明 quantity 是按主单位存储的，需要转为最小单位
-- 注意：金额计算放在数量更新之前，避免MySQL左到右求值导致重复乘pack_qty
UPDATE biz_stock_prepare_item spi
JOIN biz_product p ON spi.product_id = p.product_id
SET
    spi.amount = spi.quantity * spi.pack_qty * p.sale_price_spec,
    spi.shipped_amount = spi.shipped_quantity * spi.pack_qty * p.sale_price_spec,
    spi.remaining_amount = spi.remaining_quantity * spi.pack_qty * p.sale_price_spec,
    spi.quantity = spi.quantity * spi.pack_qty,
    spi.shipped_quantity = spi.shipped_quantity * spi.pack_qty,
    spi.remaining_quantity = spi.remaining_quantity * spi.pack_qty,
    spi.sale_price = p.sale_price_spec
WHERE spi.unit_type = '1' AND spi.sale_price = p.sale_price;

-- 3. 修正 unit_type='2' 但 sale_price 是主单位出货价的记录
-- 说明旧代码强制设了unit_type='2'但实际quantity是按主单位存的
UPDATE biz_stock_prepare_item spi
JOIN biz_product p ON spi.product_id = p.product_id
SET
    spi.amount = spi.quantity * spi.pack_qty * p.sale_price_spec,
    spi.shipped_amount = spi.shipped_quantity * spi.pack_qty * p.sale_price_spec,
    spi.remaining_amount = spi.remaining_quantity * spi.pack_qty * p.sale_price_spec,
    spi.quantity = spi.quantity * spi.pack_qty,
    spi.shipped_quantity = spi.shipped_quantity * spi.pack_qty,
    spi.remaining_quantity = spi.remaining_quantity * spi.pack_qty,
    spi.sale_price = p.sale_price_spec
WHERE spi.unit_type = '2' AND spi.sale_price = p.sale_price;

-- 4. 重算备货主表汇总数据
UPDATE biz_stock_prepare sp
SET
    sp.total_quantity = (SELECT COALESCE(SUM(spi.quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
    sp.total_amount = (SELECT COALESCE(SUM(spi.amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
    sp.shipped_quantity = (SELECT COALESCE(SUM(spi.shipped_quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
    sp.shipped_amount = (SELECT COALESCE(SUM(spi.shipped_amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
    sp.remaining_quantity = (SELECT COALESCE(SUM(spi.remaining_quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
    sp.remaining_amount = (SELECT COALESCE(SUM(spi.remaining_amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id);

-- 5. 验证修正结果
SELECT
    spi.item_id, spi.prepare_id, spi.product_id, spi.product_name,
    spi.unit_type, spi.pack_qty, spi.sale_price,
    p.sale_price as product_main_price, p.sale_price_spec as product_sub_price,
    spi.quantity, spi.amount,
    spi.shipped_quantity, spi.shipped_amount,
    spi.remaining_quantity, spi.remaining_amount,
    CASE
        WHEN spi.sale_price = p.sale_price_spec THEN 'OK'
        ELSE 'STILL_WRONG'
    END as verify_status
FROM biz_stock_prepare_item spi
JOIN biz_product p ON spi.product_id = p.product_id;
