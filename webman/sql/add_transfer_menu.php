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

    // 1. 查找进销存管理的菜单ID（作为父级）
    $stmt = $pdo->query("SELECT menu_id FROM sys_menu WHERE menu_name = '进销存管理' AND menu_type = 'M' LIMIT 1");
    $parent = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$parent) {
        echo "未找到进销存管理菜单\n";
        exit(1);
    }
    $parentId = $parent['menu_id'];
    echo "进销存管理菜单ID: {$parentId}\n";

    // 2. 检查调拨管理菜单是否已存在
    $stmt = $pdo->query("SELECT menu_id FROM sys_menu WHERE menu_name = '调拨管理' LIMIT 1");
    if ($stmt->rowCount() > 0) {
        echo "调拨管理菜单已存在，跳过\n";
    } else {
        // 获取当前最大order_num
        $stmt = $pdo->query("SELECT MAX(order_num) as max_order FROM sys_menu WHERE parent_id = {$parentId}");
        $maxOrder = $stmt->fetch(PDO::FETCH_ASSOC)['max_order'] ?? 0;

        // 插入调拨管理页面菜单
        $pdo->exec("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
            VALUES ('调拨管理', {$parentId}, " . ($maxOrder + 1) . ", 'stockTransfer', 'wms/stockTransfer/index', 'C', '0', '0', 'wms:transfer:list', 'guide', 'admin', NOW(), '', NULL, '调拨管理菜单')");

        $transferMenuId = $pdo->lastInsertId();
        echo "调拨管理菜单创建成功，ID: {$transferMenuId}\n";

        // 插入按钮权限
        $buttons = [
            ['调拨查询', 'wms:transfer:query'],
            ['调拨新增', 'wms:transfer:add'],
            ['调拨修改', 'wms:transfer:edit'],
            ['调拨删除', 'wms:transfer:remove'],
            ['调拨确认', 'wms:transfer:confirm'],
        ];
        foreach ($buttons as $i => $btn) {
            $pdo->exec("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
                VALUES ('{$btn[0]}', {$transferMenuId}, " . ($i + 1) . ", '', '', 'F', '0', '0', '{$btn[1]}', '#', 'admin', NOW(), '', NULL, '')");
        }
        echo "调拨管理按钮权限创建成功\n";

        // 3. 为admin角色（role_id=1）分配权限
        $stmt = $pdo->query("SELECT role_id FROM sys_role WHERE role_key = 'admin' LIMIT 1");
        $adminRole = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($adminRole) {
            $roleId = $adminRole['role_id'];
            // 获取所有调拨管理相关菜单ID
            $stmt = $pdo->query("SELECT menu_id FROM sys_menu WHERE menu_name = '调拨管理' OR parent_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '调拨管理' LIMIT 1)");
            $menuIds = $stmt->fetchAll(PDO::FETCH_COLUMN);
            foreach ($menuIds as $menuId) {
                $pdo->exec("INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES ({$roleId}, {$menuId})");
            }
            echo "admin角色权限分配成功\n";
        }
    }

    echo "完成!\n";
} catch (PDOException $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
