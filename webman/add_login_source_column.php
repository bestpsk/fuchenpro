<?php
/**
 * 为 sys_logininfor 表添加 login_source 字段
 */
$host = getenv('DB_HOST') ?: '127.0.0.1';
$port = getenv('DB_PORT') ?: '3306';
$dbname = getenv('DB_DATABASE') ?: 'fuchenpro';
$user = getenv('DB_USERNAME') ?: 'fuchenpro';
$pass = getenv('DB_PASSWORD') ?: '123456';

try {
    $pdo = new PDO("mysql:host={$host};port={$port};dbname={$dbname}", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 检查字段是否已存在
    $stmt = $pdo->query("SHOW COLUMNS FROM sys_logininfor LIKE 'login_source'");
    if ($stmt->rowCount() > 0) {
        echo "login_source 字段已存在，跳过\n";
        exit(0);
    }

    $pdo->exec("ALTER TABLE sys_logininfor ADD COLUMN login_source varchar(20) DEFAULT 'web' COMMENT '登录来源（web端/app端）' AFTER login_time");
    echo "login_source 字段添加成功\n";
} catch (Exception $e) {
    echo "错误: " . $e->getMessage() . "\n";
    exit(1);
}
