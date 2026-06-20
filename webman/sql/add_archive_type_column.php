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

    // 检查 archive_type 列是否存在
    $stmt = $pdo->query("SHOW COLUMNS FROM biz_customer_archive LIKE 'archive_type'");
    if ($stmt->rowCount() == 0) {
        $pdo->exec("ALTER TABLE biz_customer_archive ADD COLUMN archive_type varchar(50) DEFAULT NULL COMMENT '档案类型(铺垫/开方案/销售/售后/回访)' AFTER archive_date");
        echo "成功添加 archive_type 字段\n";
    } else {
        echo "archive_type 字段已存在，跳过\n";
    }
} catch (PDOException $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
