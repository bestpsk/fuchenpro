<?php

echo "=== 执行多仓库管理数据库迁移 ===\n\n";

$configFile = dirname(__DIR__) . '/config/database.php';
$config = include $configFile;
$mysql = $config['connections']['mysql'];

try {
    $dsn = "mysql:host={$mysql['host']};port={$mysql['port']};dbname={$mysql['database']};charset=utf8mb4";
    $pdo = new PDO($dsn, $mysql['username'], $mysql['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    echo "✓ 数据库连接成功\n\n";

    // ========== 第一步：执行 SQL 文件 ==========
    $sqlFile = __DIR__ . '/add_warehouse_management.sql';
    if (!file_exists($sqlFile)) {
        echo "✗ SQL文件不存在: $sqlFile\n";
        exit(1);
    }

    echo "读取SQL文件...\n";
    $sql = file_get_contents($sqlFile);

    $statements = [];
    $current = '';
    $lines = explode("\n", $sql);

    foreach ($lines as $line) {
        $trimmed = trim($line);
        if ($trimmed === '' || strpos($trimmed, '--') === 0) {
            continue;
        }
        $current .= $line . "\n";
        if (substr(rtrim($trimmed), -1) === ';') {
            $stmt = trim($current);
            if ($stmt !== '') {
                $statements[] = $stmt;
            }
            $current = '';
        }
    }

    if (trim($current) !== '') {
        $statements[] = trim($current);
    }

    echo "共 " . count($statements) . " 条SQL语句待执行\n\n";

    $success = 0;
    $failed = 0;

    foreach ($statements as $i => $stmt) {
        $preview = substr(preg_replace('/\s+/', ' ', $stmt), 0, 80);
        try {
            $pdo->exec($stmt);
            $success++;
            echo "  ✓ [" . ($i + 1) . "] {$preview}\n";
        } catch (PDOException $e) {
            $failed++;
            $errMsg = $e->getMessage();
            if (strpos($errMsg, 'Duplicate column') !== false || strpos($errMsg, 'Duplicate entry') !== false || strpos($errMsg, 'already exists') !== false) {
                echo "  ○ [" . ($i + 1) . "] {$preview} (已存在，跳过)\n";
                $success++;
                $failed--;
            } else {
                echo "  ✗ [" . ($i + 1) . "] {$preview}\n";
                echo "    错误: {$errMsg}\n";
            }
        }
    }

    echo "\nSQL文件执行完成: 成功 {$success}, 失败 {$failed}\n\n";

    // ========== 第二步：插入菜单数据 ==========
    echo "插入菜单和权限数据...\n\n";

    $now = date('Y-m-d H:i:s');

    // 仓库管理菜单（二级菜单，parent_id=2021 进销存管理）
    $menuSqls = [
        // 仓库管理 C类型菜单
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`) VALUES (3067, '仓库管理', 2021, 8, 'warehouse', 'wms/warehouse/index', 'WmsWarehouse', 1, 0, 'C', '0', '0', 'all', 'wms:warehouse:list', 'build', 'admin', '{$now}')",
        // 仓库管理按钮权限
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3068, '仓库查询', 3067, 1, '', '', 'F', 'wms:warehouse:query', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3069, '仓库新增', 3067, 2, '', '', 'F', 'wms:warehouse:add', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3070, '仓库修改', 3067, 3, '', '', 'F', 'wms:warehouse:edit', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3071, '仓库删除', 3067, 4, '', '', 'F', 'wms:warehouse:remove', 'admin', '{$now}')",

        // 调拨管理 C类型菜单
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`) VALUES (3072, '调拨管理', 2021, 9, 'stockTransfer', 'wms/stockTransfer/index', 'WmsStockTransfer', 1, 0, 'C', '0', '0', 'all', 'wms:transfer:list', 'switch', 'admin', '{$now}')",
        // 调拨管理按钮权限
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3073, '调拨查询', 3072, 1, '', '', 'F', 'wms:transfer:query', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3074, '调拨新增', 3072, 2, '', '', 'F', 'wms:transfer:add', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3075, '调拨修改', 3072, 3, '', '', 'F', 'wms:transfer:edit', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3076, '调拨删除', 3072, 4, '', '', 'F', 'wms:transfer:remove', 'admin', '{$now}')",
        "INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `perms`, `create_by`, `create_time`) VALUES (3077, '调拨确认', 3072, 5, '', '', 'F', 'wms:transfer:confirm', 'admin', '{$now}')",
    ];

    foreach ($menuSqls as $i => $sql) {
        try {
            $pdo->exec($sql);
            echo "  ✓ 菜单 [" . ($i + 1) . "] 插入成功\n";
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
                echo "  ○ 菜单 [" . ($i + 1) . "] 已存在，跳过\n";
            } else {
                echo "  ✗ 菜单 [" . ($i + 1) . "] 插入失败: " . $e->getMessage() . "\n";
            }
        }
    }

    // ========== 第三步：给管理员角色分配菜单权限 ==========
    echo "\n分配管理员角色权限...\n";

    $menuIds = [3067, 3068, 3069, 3070, 3071, 3072, 3073, 3074, 3075, 3076, 3077];
    foreach ($menuIds as $menuId) {
        try {
            $pdo->exec("INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, {$menuId})");
            echo "  ✓ 角色1 -> 菜单{$menuId}\n";
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
                echo "  ○ 角色1 -> 菜单{$menuId} (已存在)\n";
            } else {
                echo "  ✗ 角色1 -> 菜单{$menuId} 失败: " . $e->getMessage() . "\n";
            }
        }
    }

    // ========== 第四步：验证 ==========
    echo "\n验证迁移结果...\n\n";

    // 验证表
    $tables = $pdo->query("SHOW TABLES LIKE 'biz_warehouse%'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('biz_warehouse', $tables) ? "  ✓ biz_warehouse 表已创建\n" : "  ✗ biz_warehouse 表未创建\n";
    echo in_array('biz_warehouse_user', $tables) ? "  ✓ biz_warehouse_user 表已创建\n" : "  ✗ biz_warehouse_user 表未创建\n";

    $transferTables = $pdo->query("SHOW TABLES LIKE 'biz_stock_transfer%'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('biz_stock_transfer', $transferTables) ? "  ✓ biz_stock_transfer 表已创建\n" : "  ✗ biz_stock_transfer 表未创建\n";
    echo in_array('biz_stock_transfer_item', $transferTables) ? "  ✓ biz_stock_transfer_item 表已创建\n" : "  ✗ biz_stock_transfer_item 表未创建\n";

    // 验证默认仓库
    $whCount = $pdo->query("SELECT COUNT(*) FROM biz_warehouse WHERE warehouse_id = 1")->fetchColumn();
    echo $whCount > 0 ? "  ✓ 默认仓库已插入\n" : "  ✗ 默认仓库未插入\n";

    // 验证字段
    $invCols = $pdo->query("SHOW COLUMNS FROM biz_inventory LIKE 'warehouse_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('warehouse_id', $invCols) ? "  ✓ biz_inventory.warehouse_id 字段已添加\n" : "  ✗ biz_inventory.warehouse_id 字段未添加\n";

    $siCols = $pdo->query("SHOW COLUMNS FROM biz_stock_in LIKE 'warehouse_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('warehouse_id', $siCols) ? "  ✓ biz_stock_in.warehouse_id 字段已添加\n" : "  ✗ biz_stock_in.warehouse_id 字段未添加\n";

    $soCols = $pdo->query("SHOW COLUMNS FROM biz_stock_out LIKE 'warehouse_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('warehouse_id', $soCols) ? "  ✓ biz_stock_out.warehouse_id 字段已添加\n" : "  ✗ biz_stock_out.warehouse_id 字段未添加\n";

    $scCols = $pdo->query("SHOW COLUMNS FROM biz_stock_check LIKE 'warehouse_id'")->fetchAll(PDO::FETCH_COLUMN);
    echo in_array('warehouse_id', $scCols) ? "  ✓ biz_stock_check.warehouse_id 字段已添加\n" : "  ✗ biz_stock_check.warehouse_id 字段未添加\n";

    // 验证菜单
    $whMenu = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE menu_name = '仓库管理'")->fetchColumn();
    echo $whMenu > 0 ? "  ✓ 仓库管理菜单已插入\n" : "  ✗ 仓库管理菜单未插入\n";

    $tfMenu = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE menu_name = '调拨管理'")->fetchColumn();
    echo $tfMenu > 0 ? "  ✓ 调拨管理菜单已插入\n" : "  ✗ 调拨管理菜单未插入\n";

    // 验证权限
    $whPerms = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE perms LIKE 'wms:warehouse:%'")->fetchColumn();
    echo $whPerms >= 5 ? "  ✓ 仓库管理权限标识完整({$whPerms}个)\n" : "  ✗ 仓库管理权限标识不完整({$whPerms}个)\n";

    $tfPerms = $pdo->query("SELECT COUNT(*) FROM sys_menu WHERE perms LIKE 'wms:transfer:%'")->fetchColumn();
    echo $tfPerms >= 6 ? "  ✓ 调拨管理权限标识完整({$tfPerms}个)\n" : "  ✗ 调拨管理权限标识不完整({$tfPerms}个)\n";

    // 验证角色权限
    $roleMenuCount = $pdo->query("SELECT COUNT(*) FROM sys_role_menu WHERE role_id = 1 AND menu_id IN (3067,3068,3069,3070,3071,3072,3073,3074,3075,3076,3077)")->fetchColumn();
    echo $roleMenuCount >= 11 ? "  ✓ 管理员角色权限已分配({$roleMenuCount}个)\n" : "  ✗ 管理员角色权限不完整({$roleMenuCount}个)\n";

    echo "\n✓ 迁移完成！\n";

} catch (PDOException $e) {
    echo "✗ 连接失败: " . $e->getMessage() . "\n";
}
