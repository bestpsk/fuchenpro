-- =============================================
-- 修复培训管理菜单背景色：#10B981(绿) → #3D6DF7(蓝)
-- 与系统主题色统一
-- =============================================

-- 获取"培训管理"顶级目录ID
SET @train_root_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '培训管理' AND parent_id = 0) t);

-- 1. 更新培训管理父级菜单的 bg_color
UPDATE sys_app_menu SET bg_color = '#3D6DF7' WHERE menu_id = @train_root_id;

-- 2. 更新培训管理下所有子菜单的 bg_color
UPDATE sys_app_menu
SET bg_color = '#3D6DF7'
WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE parent_id = @train_root_id
);

-- 验证
SELECT am.menu_id, m.menu_name, am.bg_color
FROM sys_app_menu am
JOIN sys_menu m ON am.menu_id = m.menu_id
WHERE m.menu_name = '培训管理' AND m.parent_id = 0
   OR m.parent_id = @train_root_id;
