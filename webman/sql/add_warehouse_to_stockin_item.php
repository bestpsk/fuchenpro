<?php
// 给 biz_stock_in_item 添加 warehouse_id 列
require __DIR__ . '/../vendor/autoload.php';

$config = require __DIR__ . '/../config/database.php';
$connections = $config['connections'] ?? $config;
$dbConfig = $connections['mysql'] ?? ($connections['default'] ?? []);

try {
    $dsn = "mysql:host={$dbConfig['host']};port=" . ($dbConfig['port'] ?? 3306) . ";dbname={$dbConfig['database']};charset=utf8mb4";
    $pdo = new PDO($dsn, $dbConfig['username'], $dbConfig['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    // 检查列是否已存在
    $stmt = $pdo->query("SHOW COLUMNS FROM biz_stock_in_item LIKE 'warehouse_id'");
    if ($stmt->rowCount() > 0) {
        echo "warehouse_id 列已存在，跳过添加\n";
    } else {
        $pdo->exec("ALTER TABLE `biz_stock_in_item` ADD COLUMN `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER `stock_in_id`");
        echo "已添加 warehouse_id 列到 biz_stock_in_item 表\n";
    }

    // 回填历史数据
    $result = $pdo->exec("UPDATE biz_stock_in_item sii INNER JOIN biz_stock_in si ON sii.stock_in_id = si.stock_in_id SET sii.warehouse_id = si.warehouse_id WHERE sii.warehouse_id IS NULL");
    echo "已回填 {$result} 条历史数据的 warehouse_id\n";

    echo "迁移完成！\n";
} catch (Exception $e) {
    echo "迁移失败: " . $e->getMessage() . "\n";
}
