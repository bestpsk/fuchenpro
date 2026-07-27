<?php
/**
 * 统计数据库中本地 URL 数量
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

$tables = [
    'biz_train_material' => 'file_url',
    'sys_user' => 'avatar',
    'biz_customer' => 'avatar',
];

echo "========== 数据库中本地 URL 统计 ==========\n";
foreach ($tables as $table => $field) {
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$table} WHERE {$field} IS NOT NULL AND {$field} != '' AND {$field} NOT LIKE 'http://%' AND {$field} NOT LIKE 'https://%'");
    $localCount = $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$table} WHERE {$field} IS NOT NULL AND {$field} != ''");
    $totalCount = $stmt->fetchColumn();

    echo "{$table}.{$field}: 本地URL={$localCount}, 总数={$totalCount}\n";
}
