<?php
/**
 * 检查数据库中 file_url/avatar 字段的实际值
 */

$envFile = __DIR__ . '/../.env';
$env = [];
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos($line, '=') === false || strpos($line, '#') === 0) continue;
        list($k, $v) = explode('=', $line, 2);
        $env[trim($k)] = trim($v);
    }
}

$dsn = sprintf(
    'mysql:host=%s;port=%s;dbname=%s;charset=%s',
    $env['DB_HOST'] ?? '127.0.0.1',
    $env['DB_PORT'] ?? '3306',
    $env['DB_DATABASE'] ?? 'fuchenpro',
    $env['DB_CHARSET'] ?? 'utf8mb4'
);

$pdo = new PDO($dsn, $env['DB_USERNAME'] ?? 'root', $env['DB_PASSWORD'] ?? '');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$queries = [
    'biz_train_material.file_url' => 'SELECT material_id, file_url FROM biz_train_material WHERE file_url IS NOT NULL AND file_url != "" LIMIT 5',
    'sys_user.avatar' => 'SELECT user_id, avatar FROM sys_user WHERE avatar IS NOT NULL AND avatar != "" LIMIT 5',
    'biz_customer.avatar' => 'SELECT customer_id, avatar FROM biz_customer WHERE avatar IS NOT NULL AND avatar != "" LIMIT 5',
];

foreach ($queries as $name => $sql) {
    echo "\n========== {$name} ==========\n";
    $stmt = $pdo->query($sql);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $values = array_values($row);
        $id = array_shift($values);
        $url = array_shift($values);
        echo "ID={$id}: {$url}\n";
    }
}
