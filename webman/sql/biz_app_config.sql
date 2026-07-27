-- =============================================
-- App 常见问题 & 关于我们 - 参数配置初始数据
-- 通过 sys_config 表存储，管理员在"系统管理 > 参数设置"中修改
-- 执行后需在 Web 端"参数设置"页面点击"刷新缓存"或重启后端
-- =============================================

-- 1. 关于我们配置
INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`) VALUES
('应用名称', 'app.about.name', '赛诺美生', 'Y', 'admin', NOW(), 'App关于我们页显示的应用名称'),
('官方邮箱', 'app.about.email', 'contact@fuchenpro.com', 'Y', 'admin', NOW(), 'App关于我们页显示的官方邮箱'),
('版权信息', 'app.about.copyright', 'Copyright © 2025 fuchenpro.com All Rights Reserved.', 'Y', 'admin', NOW(), 'App关于我们页显示的版权信息');

-- 2. 常见问题配置（JSON 格式：分类 + 问答列表）
INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`) VALUES
('常见问题', 'app.faq.content', '[{"title":"赛诺美生问题","childList":[{"title":"赛诺美生开源吗？","content":"开源"},{"title":"赛诺美生可以商用吗？","content":"可以"},{"title":"赛诺美生官网地址多少？","content":"https://fuchenpro.com"}]},{"title":"其他问题","childList":[{"title":"如何退出登录？","content":"请点击[我的] - [应用设置] - [退出登录]即可退出登录"},{"title":"如何修改用户头像？","content":"请点击[我的] - [选择头像] - [点击提交]即可更换用户头像"},{"title":"如何修改登录密码？","content":"请点击[我的] - [应用设置] - [修改密码]即可修改登录密码"}]}]', 'Y', 'admin', NOW(), 'App常见问题页的问答数据，JSON格式：[{title,childList:[{title,content}]}]');
