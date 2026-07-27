<?php
/**
 * COS 状态检查脚本
 * 输出当前 COS 配置、启用状态以及本地文件统计
 */

require_once __DIR__ . '/../vendor/autoload.php';

use app\service\CosService;

echo "========== COS 配置检查 ==========\n";

// 1. 从数据库读取配置
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
$username = $env['DB_USERNAME'] ?? 'root';
$password = $env['DB_PASSWORD'] ?? '';

$configs = [];
try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->query("SELECT config_key, config_value FROM sys_config WHERE config_key LIKE 'sys.cos.%'");
    $configs = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
} catch (PDOException $e) {
    echo "数据库连接失败: " . $e->getMessage() . "\n";
    exit(1);
}

foreach ($configs as $key => $value) {
    // SecretKey 隐藏显示
    if (strpos($key, 'secretKey') !== false && strlen($value) > 8) {
        $value = substr($value, 0, 4) . '****' . substr($value, -4);
    }
    echo "{$key}: {$value}\n";
}

if (empty($configs)) {
    echo "警告：数据库中未找到任何 sys.cos.* 配置\n";
}

// 2. 检查 CosService 启用状态
echo "\n========== CosService 启用状态 ==========\n";
try {
    $cosService = new CosService();
    $enabled = $cosService->isEnabled();
    echo "CosService::isEnabled() = " . ($enabled ? 'true' : 'false') . "\n";

    if (!$enabled) {
        echo "原因分析：\n";
        echo "  - sys.cos.enabled 是否为 'true': " . (($configs['sys.cos.enabled'] ?? '') === 'true' ? '是' : '否') . "\n";
        echo "  - sys.cos.secretId 是否非空: " . (!empty($configs['sys.cos.secretId'] ?? '') ? '是' : '否') . "\n";
        echo "  - sys.cos.secretKey 是否非空: " . (!empty($configs['sys.cos.secretKey'] ?? '') ? '是' : '否') . "\n";
        echo "  - sys.cos.bucket 是否非空: " . (!empty($configs['sys.cos.bucket'] ?? '') ? '是' : '否') . "\n";
    }
} catch (\Throwable $e) {
    echo "CosService 初始化异常: " . $e->getMessage() . "\n";
}

// 3. 统计本地文件
echo "\n========== 本地文件统计 ==========\n";
$baseDir = public_path() . '/profile';
$subDirs = ['upload', 'avatar', 'customer_avatar'];

foreach ($subDirs as $dir) {
    $fullDir = $baseDir . '/' . $dir;
    $count = 0;
    $size = 0;
    $latestTime = 0;

    if (is_dir($fullDir)) {
        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($fullDir, RecursiveDirectoryIterator::SKIP_DOTS)
        );
        foreach ($iterator as $file) {
            if ($file->isFile()) {
                $count++;
                $size += $file->getSize();
                $mtime = $file->getMTime();
                if ($mtime > $latestTime) {
                    $latestTime = $mtime;
                }
            }
        }
    }

    echo "{$dir}: 文件数={$count}, 总大小=" . formatSize($size);
    if ($latestTime > 0) {
        echo ", 最新文件时间=" . date('Y-m-d H:i:s', $latestTime);
    }
    echo "\n";
}

function formatSize($bytes)
{
    if ($bytes >= 1073741824) {
        return round($bytes / 1073741824, 2) . ' GB';
    } elseif ($bytes >= 1048576) {
        return round($bytes / 1048576, 2) . ' MB';
    } elseif ($bytes >= 1024) {
        return round($bytes / 1024, 2) . ' KB';
    }
    return $bytes . ' B';
}
