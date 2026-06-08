-- =============================================
-- 系统配置菜单及配置项数据库脚本
-- =============================================

-- 1. 插入菜单（放在系统管理下，order_num=9排在轮播图管理后面）
SET @system_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '系统管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('系统配置', @system_menu_id, 9, 'sysConfig', 'system/sysConfig/index', NULL, 'SysConfig', 1, 0, 'C', '0', '0', 'system:sysConfig:list', 'edit', 'admin', NOW());

-- 2. 插入配置项
INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`) VALUES
('登录过期时间', 'sys.login.expireTime', '300', 'Y', 'admin', NOW(), 'Token有效期（分钟），影响Web端和APP端'),
('启用腾讯云COS', 'sys.cos.enabled', 'false', 'Y', 'admin', NOW(), '是否启用腾讯云对象存储'),
('腾讯云SecretId', 'sys.cos.secretId', '', 'Y', 'admin', NOW(), '腾讯云COS SecretId'),
('腾讯云SecretKey', 'sys.cos.secretKey', '', 'Y', 'admin', NOW(), '腾讯云COS SecretKey'),
('COS存储桶名称', 'sys.cos.bucket', '', 'Y', 'admin', NOW(), '腾讯云COS存储桶名称'),
('COS地域', 'sys.cos.region', 'ap-shanghai', 'Y', 'admin', NOW(), '腾讯云COS地域'),
('COS自定义域名', 'sys.cos.domain', '', 'Y', 'admin', NOW(), '腾讯云COS自定义域名'),
('允许修改套餐次数', 'biz.sales.packageQuantityEditable', 'true', 'Y', 'admin', NOW(), '销售开单中是否允许修改套餐次数，影响Web端和APP端'),
('允许修改套餐成交金额', 'biz.sales.packageDealAmountEditable', 'true', 'Y', 'admin', NOW(), '销售开单中是否允许修改套餐成交金额，影响Web端和APP端'),
('允许修改套餐实付金额', 'biz.sales.packagePaidAmountEditable', 'true', 'Y', 'admin', NOW(), '销售开单中是否允许修改套餐实付金额，影响Web端和APP端');
