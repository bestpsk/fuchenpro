<?php
$pdo = new PDO('mysql:host=127.0.0.1;port=3306;dbname=fuchenpro;charset=utf8mb4', 'fuchenpro', '123456');
$pdo->exec("ALTER TABLE biz_stock_prepare ADD COLUMN warehouse_id bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER enterprise_name");
echo "OK\n";
