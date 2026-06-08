<?php

echo "=== 执行卡项管理和备货管理数据库迁移 ===\n\n";

$configFile = __DIR__ . '/config/database.php';
$config = include $configFile;
$mysql = $config['connections']['mysql'];

try {
    $dsn = "mysql:host={$mysql['host']};port={$mysql['port']};dbname={$mysql['database']};charset=utf8mb4";
    $pdo = new PDO($dsn, $mysql['username'], $mysql['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    echo "✓ 数据库连接成功\n\n";

    $sqlFile = __DIR__ . '/sql/biz_card_item.sql';
    if (!file_exists($sqlFile)) {
        echo "✗ SQL文件不存在: $sqlFile\n";
        exit(1);
    }

    echo "读取SQL文件...\n";
    $sql = file_get_contents($sqlFile);

    $statements = [];
    $current = '';
    $lines = explode("\n", $sql);

    foreach ($lines as $line) {
        $trimmed = trim($line);
        if ($trimmed === '' || strpos($trimmed, '--') === 0) {
            continue;
        }
        $current .= $line . "\n";
        if (substr(rtrim($trimmed), -1) === ';') {
            $stmt = trim($current);
            if ($stmt !== '') {
                $statements[] = $stmt;
            }
            $current = '';
        }
    }

    if (trim($current) !== '') {
        $statements[] = trim($current);
    }

    echo "共 " . count($statements) . " 条SQL语句待执行\n\n";

    $success = 0;
    $failed = 0;

    foreach ($statements as $i => $stmt) {
        $preview = substr(preg_replace('/\s+/', ' ', $stmt), 0, 80);
        try {
            $pdo->exec($stmt);
            $success++;
            echo "  ✓ [" . ($i + 1) . "] {$preview}\n";
        } catch (PDOException $e) {
            $failed++;
            $errMsg = $e->getMessage();
            if (strpos($errMsg, 'Duplicate column') !== false || strpos($errMsg, 'Duplicate entry') !== false) {
                echo "  ○ [" . ($i + 1) . "] {$preview} (已存在，跳过)\n";
                $success++;
                $failed--;
            } else {
                echo "  ✗ [" . ($i + 1) . "] {$preview}\n";
                echo "    错误: {$errMsg}\n";
            }
        }
    }

    echo "\n执行完成: 成功 {$success}, 失败 {$failed}\n\n";

    echo "验证表结构...\n";

    $tables = $pdo->query("SHOW TABLES LIKE 'biz_card_item%'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('biz_card_item', $tables) ? "  ✓ biz_card_item 表已创建\n" : "  ✗ biz_card_item 表未创建\n";
    echo in_array('biz_card_item_product', $tables) ? "  ✓ biz_card_item_product 表已创建\n" : "  ✗ biz_card_item_product 表未创建\n";

    $prepareTables = $pdo->query("SHOW TABLES LIKE 'biz_stock_prepare%'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('biz_stock_prepare', $prepareTables) ? "  ✓ biz_stock_prepare 表已创建\n" : "  ✗ biz_stock_prepare 表未创建\n";
    echo in_array('biz_stock_prepare_item', $prepareTables) ? "  ✓ biz_stock_prepare_item 表已创建\n" : "  ✗ biz_stock_prepare_item 表未创建\n";

    $orderItemCols = $pdo->query("SHOW COLUMNS FROM biz_order_item LIKE 'card_item_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('card_item_id', $orderItemCols) ? "  ✓ biz_order_item.card_item_id 字段已添加\n" : "  ✗ biz_order_item.card_item_id 字段未添加\n";

    $packageItemCols = $pdo->query("SHOW COLUMNS FROM biz_package_item LIKE 'card_item_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('card_item_id', $packageItemCols) ? "  ✓ biz_package_item.card_item_id 字段已添加\n" : "  ✗ biz_package_item.card_item_id 字段未添加\n";

    $cipCols = $pdo->query("SHOW COLUMNS FROM biz_card_item_product")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('unit_type', $cipCols) ? "  ✓ biz_card_item_product.unit_type 字段已添加\n" : "  ✗ biz_card_item_product.unit_type 字段未添加\n";
    echo in_array('pack_qty', $cipCols) ? "  ✓ biz_card_item_product.pack_qty 字段已添加\n" : "  ✗ biz_card_item_product.pack_qty 字段未添加\n";

    $menuCount = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE menu_name = '卡项管理'")->fetchColumn();
    echo $menuCount > 0 ? "  ✓ 卡项管理菜单已插入\n" : "  ✗ 卡项管理菜单未插入\n";

    $prepareMenuCount = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE menu_name = '企业备货'")->fetchColumn();
    echo $prepareMenuCount > 0 ? "  ✓ 企业备货菜单已插入\n" : "  ✗ 企业备货菜单未插入\n";

    $dictCount = $pdo->query("SELECT COUNT(*) FROM sys_dict_type WHERE dict_type = 'biz_card_item_category'")->fetchColumn();
    echo $dictCount > 0 ? "  ✓ 卡项类别字典已插入\n" : "  ✗ 卡项类别字典未插入\n";

    echo "\n✓ 迁移完成！\n";

} catch (PDOException $e) {
    echo "✗ 连接失败: " . $e->getMessage() . "\n";
}
