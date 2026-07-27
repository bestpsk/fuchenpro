-- 为 sys_oper_log 添加 oper_name 索引
-- 理由：操作日志表的 oper_name 模糊查询（如按操作人员搜索）目前全表扫描
-- 影响范围：SysOperLogService::selectOperLogList 方法
-- 执行方式：手动在 MySQL 中执行

ALTER TABLE `sys_oper_log` ADD INDEX `idx_sys_oper_log_on` (`oper_name`);
