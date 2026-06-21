-- 数据库备份功能 SQL（安全版本，可重复执行）

-- 创建备份记录表（已存在则跳过）
CREATE TABLE IF NOT EXISTS `sys_db_backup` (
  `backup_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '备份ID',
  `file_name` varchar(200) NOT NULL DEFAULT '' COMMENT '备份文件名',
  `file_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '文件大小(字节)',
  `cos_path` varchar(500) DEFAULT '' COMMENT 'COS存储路径',
  `cos_url` varchar(500) DEFAULT '' COMMENT 'COS访问URL',
  `backup_type` varchar(20) NOT NULL DEFAULT 'auto' COMMENT '备份类型(auto自动/manual手动)',
  `status` varchar(20) NOT NULL DEFAULT 'success' COMMENT '状态(success成功/failed失败)',
  `duration` decimal(10,2) DEFAULT 0 COMMENT '耗时(秒)',
  `error_message` text COMMENT '错误信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`backup_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='数据库备份记录表';

-- 插入备份配置项（已存在则跳过）
INSERT IGNORE INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_time`) VALUES
('数据库备份启用', 'sys.backup.enabled', 'true', 'Y', NOW()),
('数据库备份时间', 'sys.backup.time', '02:00', 'Y', NOW()),
('备份保留天数', 'sys.backup.retainDays', '30', 'Y', NOW()),
('mysqldump路径', 'sys.backup.mysqldumpPath', 'mysqldump', 'Y', NOW());

-- 在系统管理下新增"数据库备份"菜单（已存在则跳过）
INSERT IGNORE INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `client_type`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES
(3083, '数据库备份', 1, 10, 'dbBackup', 'system/backup/index', NULL, 'DbBackup', 1, 0, 'C', '0', '0', 'all', 'system:backup:list', 'upload', 'admin', NOW(), '', NULL, '数据库备份菜单');

-- 为管理员角色分配菜单权限（已存在则跳过）
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 3083);
