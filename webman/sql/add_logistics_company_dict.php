<?php
// 创建 logistics_company 字典类型和数据
require __DIR__ . '/../vendor/autoload.php';

$config = require __DIR__ . '/../config/database.php';
$connections = $config['connections'] ?? $config;
$dbConfig = $connections['mysql'] ?? ($connections['default'] ?? []);

try {
    $dsn = "mysql:host={$dbConfig['host']};port=" . ($dbConfig['port'] ?? 3306) . ";dbname={$dbConfig['database']};charset=utf8mb4";
    $pdo = new PDO($dsn, $dbConfig['username'], $dbConfig['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    // 检查字典类型是否已存在
    $stmt = $pdo->query("SELECT dict_id FROM sys_dict_type WHERE dict_type = 'logistics_company'");
    if ($stmt->rowCount() > 0) {
        echo "logistics_company 字典类型已存在，跳过创建\n";
    } else {
        $pdo->exec("INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) VALUES ('物流公司', 'logistics_company', '0', 'admin', NOW(), '物流公司列表')");
        echo "已创建 logistics_company 字典类型\n";
    }

    // 插入字典数据（使用 INSERT IGNORE 避免重复）
    $dictData = [
        [1,  '顺丰速运', 'shunfeng',    'primary'],
        [2,  '中通快递', 'zhongtong',   'primary'],
        [3,  '圆通速递', 'yuantong',    'primary'],
        [4,  '申通快递', 'shentong',    'primary'],
        [5,  '韵达快递', 'yunda',       'primary'],
        [6,  '百世快递', 'baishi',      'primary'],
        [7,  '极兔速递', 'jitu',        'primary'],
        [8,  '邮政EMS',  'ems',         'primary'],
        [9,  '德邦快递', 'debang',      'primary'],
        [10, '京东物流', 'jd',          'primary'],
        [11, '天天快递', 'tiantian',    'primary'],
        [12, '宅急送',   'zhaijisong',  'primary'],
    ];
    $inserted = 0;
    foreach ($dictData as $row) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES (?, ?, ?, 'logistics_company', '', ?, 'N', '0', 'admin', NOW())");
        $stmt->execute($row);
        if ($stmt->rowCount() > 0) $inserted++;
    }
    echo "已插入 {$inserted} 条 logistics_company 字典数据\n";

    echo "迁移完成！\n";
} catch (Exception $e) {
    echo "迁移失败: " . $e->getMessage() . "\n";
}
