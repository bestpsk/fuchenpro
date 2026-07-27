-- 为 sys_logininfor 添加 user_name 索引
-- 理由：登录日志表的 user_name 模糊查询（如按用户名搜索）目前全表扫描
-- 影响范围：SysLogininforService::selectLogininforList 方法
-- 执行方式：手动在 MySQL 中执行

ALTER TABLE `sys_logininfor` ADD INDEX `idx_sys_logininfor_un` (`user_name`);
