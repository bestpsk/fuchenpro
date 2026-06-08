<?php
/**
 * 执行备货数据修复SQL脚本
 */
try {
    $pdo = new PDO(
        'mysql:host=127.0.0.1;port=3306;dbname=fuchenpro;charset=utf8mb4',
        'fuchenpro',
        '123456',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "===== 1. 检查需要修正的记录 =====\n";
    $result = $pdo->query("
        SELECT spi.item_id, spi.prepare_id, spi.product_id, spi.product_name,
            spi.unit_type, spi.pack_qty, spi.sale_price,
            p.sale_price as product_sale_price, p.sale_price_spec as product_sale_price_spec,
            spi.quantity, spi.amount,
            spi.shipped_quantity, spi.shipped_amount,
            spi.remaining_quantity, spi.remaining_amount,
            CASE 
                WHEN spi.sale_price = p.sale_price AND spi.unit_type = '2' THEN 'NEED_FIX'
                ELSE 'OK'
            END as status
        FROM biz_stock_prepare_item spi
        JOIN biz_product p ON spi.product_id = p.product_id
    ");
    $rows = $result->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $row) {
        echo "  item_id={$row['item_id']} product={$row['product_name']} unit_type={$row['unit_type']} sale_price={$row['sale_price']} qty={$row['quantity']} status={$row['status']}\n";
    }

    echo "\n===== 2. 修正数据 =====\n";
    $stmt = $pdo->exec("
        UPDATE biz_stock_prepare_item spi
        JOIN biz_product p ON spi.product_id = p.product_id
        SET 
            spi.quantity = spi.quantity * spi.pack_qty,
            spi.sale_price = p.sale_price_spec,
            spi.amount = spi.quantity * spi.pack_qty * p.sale_price_spec,
            spi.shipped_quantity = spi.shipped_quantity * spi.pack_qty,
            spi.shipped_amount = spi.shipped_quantity * spi.pack_qty * p.sale_price_spec,
            spi.remaining_quantity = spi.remaining_quantity * spi.pack_qty,
            spi.remaining_amount = spi.remaining_quantity * spi.pack_qty * p.sale_price_spec
        WHERE spi.unit_type = '2' AND spi.sale_price = p.sale_price
    ");
    echo "  影响 {$stmt} 行\n";

    echo "\n===== 3. 重算备货主表汇总 =====\n";
    $pdo->exec("
        UPDATE biz_stock_prepare sp
        SET 
            sp.total_quantity = (SELECT COALESCE(SUM(spi.quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
            sp.total_amount = (SELECT COALESCE(SUM(spi.amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
            sp.shipped_quantity = (SELECT COALESCE(SUM(spi.shipped_quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
            sp.shipped_amount = (SELECT COALESCE(SUM(spi.shipped_amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
            sp.remaining_quantity = (SELECT COALESCE(SUM(spi.remaining_quantity), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id),
            sp.remaining_amount = (SELECT COALESCE(SUM(spi.remaining_amount), 0) FROM biz_stock_prepare_item spi WHERE spi.prepare_id = sp.prepare_id)
    ");
    echo "  主表汇总已重算\n";

    echo "\n===== 4. 验证修正结果 =====\n";
    $result = $pdo->query("
        SELECT spi.item_id, spi.prepare_id, spi.product_id, spi.product_name,
            spi.unit_type, spi.pack_qty, spi.sale_price,
            p.sale_price as product_sale_price, p.sale_price_spec as product_sale_price_spec,
            spi.quantity, spi.amount,
            spi.shipped_quantity, spi.shipped_amount,
            spi.remaining_quantity, spi.remaining_amount
        FROM biz_stock_prepare_item spi
        JOIN biz_product p ON spi.product_id = p.product_id
    ");
    $rows = $result->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $row) {
        $ok = ($row['sale_price'] == $row['product_sale_price_spec']) ? 'OK' : 'MISMATCH';
        echo "  item_id={$row['item_id']} product={$row['product_name']} unit_type={$row['unit_type']} sale_price={$row['sale_price']} qty={$row['quantity']} remaining={$row['remaining_quantity']} status={$ok}\n";
    }

    echo "\n===== 5. 验证备货主表 =====\n";
    $result = $pdo->query("SELECT * FROM biz_stock_prepare");
    $rows = $result->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $row) {
        echo "  prepare_id={$row['prepare_id']} total_qty={$row['total_quantity']} total_amt={$row['total_amount']} shipped_qty={$row['shipped_quantity']} remaining_qty={$row['remaining_quantity']}\n";
    }

    echo "\n===== 完成 =====\n";
} catch (PDOException $e) {
    echo "错误: " . $e->getMessage() . "\n";
    exit(1);
}
