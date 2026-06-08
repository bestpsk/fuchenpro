-- ============================================================
-- 菜单管理和APP菜单配置检查修复
-- 修复日期: 2026-06-06
-- ============================================================

-- ============ 第1步：补全缺失的APP菜单配置 ============

-- 1.1 为企业备货(3044)添加sys_app_menu记录（当前缺失）
INSERT INTO sys_app_menu (menu_id, app_path, app_icon, bg_color, icon_color, sort_order, visible, create_by, create_time, update_by, update_time)
SELECT 3044, '/pages/business/stockPrepare/index', 'shopping-cart', '#FF6B35', '#fff', 8, 1, 'admin', NOW(), '', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_app_menu WHERE menu_id = 3044);

-- 1.2 为进销存报表(2057)补上app_path（APPV3存在/pages/wms/report/index页面）
UPDATE sys_app_menu SET app_path = '/pages/wms/report/index' WHERE menu_id = 2057 AND (app_path IS NULL OR app_path = '');

-- ============ 第2步：隐藏无APP页面的菜单 ============

-- 2.1 岗位管理(104) - APP页面已存在（/pages/system/post/index）
-- 2026-06-08: 经 fix_app_menu_dept_post.sql 补全路径，APP 端已支持
-- 如需恢复隐藏，请同时删除 fix_app_menu_dept_post.sql 中的对应行
-- UPDATE sys_app_menu SET visible = 0 WHERE menu_id = 104;

-- 2.2 菜单管理(102) - APP无此页面
UPDATE sys_app_menu SET visible = 0 WHERE menu_id = 102;

-- 2.3 参数设置(106) - APP无此页面
UPDATE sys_app_menu SET visible = 0 WHERE menu_id = 106;

-- 2.4 部门管理(103) - APP页面已存在（/pages/system/dept/index）
-- 2026-06-08: 经 fix_app_menu_dept_post.sql 补全路径，APP 端已支持
-- 如需恢复隐藏，请同时删除 fix_app_menu_dept_post.sql 中的对应行
-- UPDATE sys_app_menu SET visible = 0, app_path = '' WHERE menu_id = 103;

-- 2.5 角色管理(101) - APP无此页面，路径无效
UPDATE sys_app_menu SET visible = 0, app_path = '' WHERE menu_id = 101;

-- 2.6 字典管理(105) - APP无此页面，路径无效
UPDATE sys_app_menu SET visible = 0, app_path = '' WHERE menu_id = 105;

-- ============ 第3步：删除冗余的sys_app_menu记录 ============

-- 3.1 删除店企业出货(2088) - sys_menu中已无此菜单
DELETE FROM sys_app_menu WHERE menu_id = 2088;

-- 3.2 删除考勤打卡目录(3030) - 与2012(考勤管理)重复
DELETE FROM sys_app_menu WHERE menu_id = 3030;

-- 3.3 删除app版考勤记录(3032) - 与2013(all版)重复
DELETE FROM sys_app_menu WHERE menu_id = 3032;

-- 3.4 删除app版考勤配置(3033) - 与2080(all版)重复
DELETE FROM sys_app_menu WHERE menu_id = 3033;

-- 3.5 删除app版卡项管理(3051) - 与3034(all版)重复
DELETE FROM sys_app_menu WHERE menu_id = 3051;

-- 3.6 删除app版企业备货(3055) - 与3044(all版)重复
DELETE FROM sys_app_menu WHERE menu_id = 3055;

-- 3.7 删除app版考勤规则(3062) - 与2014(all版)重复
DELETE FROM sys_app_menu WHERE menu_id = 3062;

-- ============ 第4步：删除冗余的sys_menu记录 ============

-- 4.1 删除app版考勤规则(3062)的子菜单（按钮权限F类型）
DELETE FROM sys_menu WHERE menu_id IN (3063, 3064, 3065);

-- 4.2 删除冗余的app版菜单
DELETE FROM sys_menu WHERE menu_id IN (3030, 3032, 3033, 3051, 3055, 3062);

-- ============ 第5步：清理sys_role_menu孤儿记录 ============

-- 5.1 清理已删除菜单的角色权限关联
DELETE FROM sys_role_menu WHERE menu_id IN (3030, 3032, 3033, 3051, 3055, 3062, 3063, 3064, 3065, 2088);

-- ============ 第6步：验证 ============

-- 6.1 验证sys_app_menu中无重复menu_name
SELECT m.menu_name, COUNT(*) as cnt
FROM sys_app_menu am
JOIN sys_menu m ON am.menu_id = m.menu_id
WHERE m.menu_type = 'C' AND m.status = '0'
GROUP BY m.menu_name
HAVING cnt > 1;

-- 6.2 验证sys_app_menu中无空app_path且visible=1的记录
SELECT am.*, m.menu_name
FROM sys_app_menu am
JOIN sys_menu m ON am.menu_id = m.menu_id
WHERE m.menu_type = 'C' AND am.visible = 1 AND (am.app_path IS NULL OR am.app_path = '');

-- 6.3 验证所有C类型菜单都有sys_app_menu记录
SELECT m.menu_id, m.menu_name, m.parent_id, m.client_type
FROM sys_menu m
LEFT JOIN sys_app_menu am ON m.menu_id = am.menu_id
WHERE m.menu_type = 'C' AND m.status = '0' AND m.client_type IN ('all', 'app')
AND am.app_menu_id IS NULL;
