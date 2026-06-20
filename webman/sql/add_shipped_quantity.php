<?php
require __DIR__ . '/../vendor/autoload.php';
$config = require dirname(__DIR__) . '/config/database.php';

$host = $config['connections']['mysql']['host'] ?? '127.0.0.1';
$port = $config['connections']['mysql']['port'] ?? 3306;
$dbname = $config['connections']['mysql']['database'] ?? '';
$username = $config['connections']['mysql']['username'] ?? 'root';
$password = $config['connections']['mysql']['password'] ?? '';

try {
    $pdo = new PDO("mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 检查字段是否已存在
    $stmt = $pdo->query("SHOW COLUMNS FROM biz_stock_in_item LIKE 'shipped_quantity'");
    if ($stmt->rowCount() == 0) {
        $pdo->exec("ALTER TABLE biz_stock_in_item ADD COLUMN shipped_quantity decimal(10,2) DEFAULT 0 COMMENT '已出库数量'");
        echo "成功添加 shipped_quantity 字段到 biz_stock_in_item 表\n";
    } else {
        echo "shipped_quantity 字段已存在，跳过\n";
    }
} catch (PDOException $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
