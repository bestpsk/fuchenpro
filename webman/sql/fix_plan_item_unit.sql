-- =====================================================
-- 修复 biz_plan_item 数量单位不统一
-- 把主单位(unit_type='1')的记录转为副单位（最小单位）
-- 执行前请备份 biz_plan_item 表
-- =====================================================

-- 查看待迁移的记录
SELECT item_id, plan_id, product_name, unit_type, pack_qty,
       quantity AS old_quantity,
       quantity * pack_qty AS new_quantity,
       shipped_quantity,
       remaining_quantity AS old_remaining,
       (quantity * pack_qty - shipped_quantity) AS new_remaining,
       sale_price AS old_price,
       (sale_price / pack_qty) AS new_price
FROM biz_plan_item
WHERE unit_type = '1' AND pack_qty > 1;

-- 执行迁移：主单位数量 → 副单位数量
UPDATE biz_plan_item
SET quantity = quantity * pack_qty,
    remaining_quantity = quantity * pack_qty - shipped_quantity,
    sale_price = sale_price / pack_qty
WHERE unit_type = '1' AND pack_qty > 1;

-- 验证迁移结果
SELECT item_id, plan_id, product_name, unit_type, pack_qty,
       quantity, shipped_quantity, remaining_quantity, sale_price
FROM biz_plan_item
WHERE unit_type = '1' AND pack_qty > 1;
