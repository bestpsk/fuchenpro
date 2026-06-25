-- =============================================
-- 补充安全策略配置缺失项 + 高德地图配置
-- 说明：基于 fuchen.sql 数据库导出，仅插入缺失的配置项
-- =============================================

INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`) VALUES
('验证码有效期', 'sys.account.captchaExpire', '5', 'Y', 'admin', NOW(), '验证码有效期（分钟）'),
('密码最大错误次数', 'sys.account.maxRetryCount', '5', 'Y', 'admin', NOW(), '密码错误次数上限（次）'),
('密码锁定时间', 'sys.account.lockTime', '10', 'Y', 'admin', NOW(), '密码错误锁定时间（分钟）'),
('高德Web服务Key', 'sys.amap.webServiceKey', 'd184e115457658cbcf3f92ed8e3a1772', 'Y', 'admin', NOW(), '用于APP端逆地理编码和IP定位，修改后立即生效'),
('高德JS API Key', 'sys.amap.jsApiKey', '', 'Y', 'admin', NOW(), '用于Web端地图组件加载，修改后刷新页面生效'),
('高德安全密钥', 'sys.amap.securityJsCode', '', 'Y', 'admin', NOW(), 'JS API安全密钥，与JS API Key配合使用');

-- 验证插入结果
SELECT config_id, config_name, config_key, config_value FROM sys_config
WHERE config_key IN ('sys.account.captchaExpire', 'sys.account.maxRetryCount', 'sys.account.lockTime',
                     'sys.amap.webServiceKey', 'sys.amap.jsApiKey', 'sys.amap.securityJsCode')
ORDER BY config_id;
