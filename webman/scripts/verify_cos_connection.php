<?php
/**
 * 验证 COS 连接和密钥是否有效
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Qcloud\Cos\Client;

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

$stmt = $pdo->query("SELECT config_key, config_value FROM sys_config WHERE config_key LIKE 'sys.cos.%'");
$configs = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);

$enabled = ($configs['sys.cos.enabled'] ?? '') === 'true';
$secretId = $configs['sys.cos.secretId'] ?? '';
$secretKey = $configs['sys.cos.secretKey'] ?? '';
$bucket = $configs['sys.cos.bucket'] ?? '';
$region = $configs['sys.cos.region'] ?: 'ap-shanghai';

echo "========== COS 配置 ==========\n";
echo "enabled: " . ($enabled ? 'true' : 'false') . "\n";
echo "secretId: " . (empty($secretId) ? '空' : substr($secretId, 0, 8) . '****') . "\n";
echo "secretKey: " . (empty($secretKey) ? '空' : '已填写') . "\n";
echo "bucket: {$bucket}\n";
echo "region: {$region}\n\n";

if (!$enabled || empty($secretId) || empty($secretKey) || empty($bucket)) {
    echo "配置不完整，无法验证\n";
    exit(1);
}

$cosClient = new Client([
    'region' => $region,
    'schema' => 'https',
    'credentials' => [
        'secretId'  => $secretId,
        'secretKey' => $secretKey,
    ],
]);

echo "正在验证 COS 连接...\n";

try {
    $result = $cosClient->headBucket([
        'Bucket' => $bucket,
    ]);
    echo "✓ COS 连接成功，bucket 可访问\n";

    // 列出前5个对象
    $result = $cosClient->listObjects([
        'Bucket' => $bucket,
        'MaxKeys' => 5,
    ]);

    $objects = $result['Contents'] ?? [];
    echo "✓ 列出 bucket 对象成功，前5个对象：\n";
    foreach ($objects as $obj) {
        echo "  - " . $obj['Key'] . "\n";
    }
    if (empty($objects)) {
        echo "  (bucket 为空或没有列出权限)\n";
    }
} catch (\Throwable $e) {
    echo "✗ COS 连接失败: " . $e->getMessage() . "\n";
    exit(1);
}
