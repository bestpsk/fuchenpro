-- 清理重复的系统配置项
-- 执行前请先备份数据库

-- 1. 删除重复的初始密码配置（保留 sys.security.initPassword，id=118）
DELETE FROM sys_config WHERE config_id = 2 AND config_key = 'sys.user.initPassword';

-- 2. 删除重复的备份配置（保留 id=128-131）
DELETE FROM sys_config WHERE config_id IN (125, 126, 127);

-- 验证清理结果
SELECT config_id, config_key, config_name FROM sys_config 
WHERE config_key IN ('sys.user.initPassword', 'sys.security.initPassword', 'sys.backup.enabled', 'sys.backup.time', 'sys.backup.retainDays')
ORDER BY config_id;
