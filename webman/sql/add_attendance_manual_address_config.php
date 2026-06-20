<?php
/**
 * 新增考勤配置项：允许手动输入打卡地址
 */
require __DIR__ . '/../vendor/autoload.php';

$config = require __DIR__ . '/../config/database.php';
$connection = $config['connections'][$config['default']];

$pdo = new PDO(
    "mysql:host={$connection['host']};port={$connection['port']};dbname={$connection['database']}",
    $connection['username'],
    $connection['password'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

// 检查是否已存在
$stmt = $pdo->prepare("SELECT COUNT(*) FROM sys_config WHERE config_key = ?");
$stmt->execute(['biz.attendance.allowManualAddress']);
if ($stmt->fetchColumn() > 0) {
    echo "配置项 biz.attendance.allowManualAddress 已存在，跳过插入\n";
    exit(0);
}

$pdo->prepare("INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_time, remark) VALUES (?, ?, ?, ?, NOW(), ?)")->execute([
    '允许手动输入打卡地址',
    'biz.attendance.allowManualAddress',
    'true',
    'Y',
    '控制APP端考勤打卡是否允许手动输入地址，关闭后定位失败时无法手动输入'
]);

echo "成功插入配置项 biz.attendance.allowManualAddress\n";
