-- ============================================================
-- 赛诺美生 - 旧权限 business:sales:* 清理脚本
-- 目的：清理已迁移至 business:order:* 的旧权限残留
-- 注意：此脚本需手动执行（项目约定）
-- ============================================================

-- =============================================
-- 步骤 0：执行前预检查（只读，确认待清理数据）
-- =============================================

-- 0.1 确认旧权限残留存在（应返回 6 条：menu_id 2066-2071）
SELECT menu_id, menu_name, parent_id, perms, create_time
FROM sys_menu
WHERE perms LIKE 'business:sales:%'
  AND perms <> 'business:sales:list'
ORDER BY menu_id;

-- 0.2 确认新权限已存在（应返回 1 条：menu_id 2074）
SELECT menu_id, menu_name, parent_id, perms, create_time
FROM sys_menu
WHERE perms = 'business:order:enterpriseAudit';

-- 0.3 确认新权限 financeAudit 已存在（应返回 1 条：menu_id 2075）
SELECT menu_id, menu_name, parent_id, perms, create_time
FROM sys_menu
WHERE perms = 'business:order:financeAudit';

-- 0.4 查看这些旧权限是否被角色引用（执行前确认影响范围）
SELECT rm.role_id, rm.menu_id, sm.perms
FROM sys_role_menu rm
JOIN sys_menu sm ON rm.menu_id = sm.menu_id
WHERE sm.perms IN (
    'business:sales:query',
    'business:sales:add',
    'business:sales:edit',
    'business:sales:remove',
    'business:sales:enterpriseAudit',
    'business:sales:financeAudit'
);

-- =============================================
-- 步骤 1：先删除 sys_role_menu 中的角色引用（外键依赖）
-- =============================================

DELETE FROM sys_role_menu
WHERE menu_id IN (2066, 2067, 2068, 2069, 2070, 2071);

-- =============================================
-- 步骤 2：删除 sys_menu 中的旧权限记录
-- =============================================

DELETE FROM sys_menu
WHERE menu_id IN (2066, 2067, 2068, 2069, 2070, 2071);

-- =============================================
-- 步骤 3：执行后验证
-- =============================================

-- 3.1 确认旧权限已删除（应返回 0 条）
SELECT menu_id, menu_name, perms
FROM sys_menu
WHERE perms LIKE 'business:sales:%'
  AND perms <> 'business:sales:list';

-- 3.2 确认旧权限的角色引用已清除（应返回 0 条）
SELECT rm.role_id, rm.menu_id
FROM sys_role_menu rm
JOIN sys_menu sm ON rm.menu_id = sm.menu_id
WHERE sm.perms IN (
    'business:sales:query',
    'business:sales:add',
    'business:sales:edit',
    'business:sales:remove',
    'business:sales:enterpriseAudit',
    'business:sales:financeAudit'
);

-- 3.3 确认新权限 business:order:* 完好（应返回至少 2 条：2074 + 2075）
SELECT menu_id, menu_name, parent_id, perms
FROM sys_menu
WHERE perms LIKE 'business:order:%'
ORDER BY menu_id;

-- 3.4 确认父级菜单 business:sales:list (2065) 仍在（用于 AppV3 销售页导航）
SELECT menu_id, menu_name, perms
FROM sys_menu
WHERE perms = 'business:sales:list';
