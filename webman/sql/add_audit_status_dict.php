<?php
// 创建 audit_status 字典类型和数据
require __DIR__ . '/../vendor/autoload.php';

$config = require __DIR__ . '/../config/database.php';
$connections = $config['connections'] ?? $config;
$dbConfig = $connections['mysql'] ?? ($connections['default'] ?? []);

try {
    $dsn = "mysql:host={$dbConfig['host']};port=" . ($dbConfig['port'] ?? 3306) . ";dbname={$dbConfig['database']};charset=utf8mb4";
    $pdo = new PDO($dsn, $dbConfig['username'], $dbConfig['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    // 检查字典类型是否已存在
    $stmt = $pdo->query("SELECT dict_id FROM sys_dict_type WHERE dict_type = 'audit_status'");
    if ($stmt->rowCount() > 0) {
        echo "audit_status 字典类型已存在，跳过创建\n";
    } else {
        $pdo->exec("INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) VALUES ('审核状态', 'audit_status', '0', 'admin', NOW(), '方案审核状态')");
        echo "已创建 audit_status 字典类型\n";
    }

    // 插入字典数据（使用 INSERT IGNORE 避免重复）
    $dictData = [
        [1, '草稿', '0', 'info', 'Y'],
        [2, '待审核', '1', 'primary', 'N'],
        [3, '已审核', '2', 'success', 'N'],
        [4, '已完成', '3', 'warning', 'N'],
        [5, '已驳回', '4', 'danger', 'N'],
    ];
    $inserted = 0;
    foreach ($dictData as $row) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES (?, ?, ?, 'audit_status', '', ?, ?, '0', 'admin', NOW())");
        $stmt->execute($row);
        if ($stmt->rowCount() > 0) $inserted++;
    }
    echo "已插入 {$inserted} 条 audit_status 字典数据\n";

    echo "迁移完成！\n";
} catch (Exception $e) {
    echo "迁移失败: " . $e->getMessage() . "\n";
}
