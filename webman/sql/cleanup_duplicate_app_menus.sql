-- =============================================
-- 清理APP菜单重复记录
-- 当 sys_menu 中同一菜单名同时存在 client_type='all' 和 'app' 时，
-- 将 sys_app_menu 和 sys_role_menu 迁移到 client_type='all' 的记录，
-- 然后删除 client_type='app' 的重复 sys_menu 记录
-- =============================================

-- 1. 迁移 sys_app_menu：将关联到 client_type='app' 重复菜单的记录迁移到 client_type='all' 的菜单
UPDATE sys_app_menu sam
INNER JOIN sys_menu m_app ON sam.menu_id = m_app.menu_id AND m_app.client_type = 'app'
INNER JOIN sys_menu m_all ON m_all.menu_name = m_app.menu_name
    AND m_all.menu_type = m_app.menu_type
    AND m_all.parent_id = m_app.parent_id
    AND m_all.client_type = 'all'
    AND m_all.status = '0'
SET sam.menu_id = m_all.menu_id
WHERE m_app.client_type = 'app'
  AND m_all.menu_id != m_app.menu_id;

-- 2. 迁移 sys_role_menu：将关联到 client_type='app' 重复菜单的角色权限迁移到 client_type='all' 的菜单
-- 先删除已存在的重复记录（避免唯一键冲突）
DELETE sr FROM sys_role_menu sr
INNER JOIN sys_menu m_app ON sr.menu_id = m_app.menu_id AND m_app.client_type = 'app'
INNER JOIN sys_role_menu sr2 ON sr2.role_id = sr.role_id
INNER JOIN sys_menu m_all ON sr2.menu_id = m_all.menu_id
    AND m_all.menu_name = m_app.menu_name
    AND m_all.menu_type = m_app.menu_type
    AND m_all.client_type = 'all'
WHERE m_app.client_type = 'app'
  AND m_all.menu_id != m_app.menu_id;

-- 然后迁移
UPDATE sys_role_menu sr
INNER JOIN sys_menu m_app ON sr.menu_id = m_app.menu_id AND m_app.client_type = 'app'
INNER JOIN sys_menu m_all ON m_all.menu_name = m_app.menu_name
    AND m_all.menu_type = m_app.menu_type
    AND m_all.parent_id = m_app.parent_id
    AND m_all.client_type = 'all'
    AND m_all.status = '0'
SET sr.menu_id = m_all.menu_id
WHERE m_app.client_type = 'app'
  AND m_all.menu_id != m_app.menu_id;

-- 3. 删除 client_type='app' 的子菜单（按钮权限 F类型）
DELETE FROM sys_menu WHERE client_type = 'app'
  AND menu_type = 'F'
  AND parent_id IN (
    SELECT t.menu_id FROM (
      SELECT m_app.menu_id
      FROM sys_menu m_app
      INNER JOIN sys_menu m_all ON m_all.menu_name = m_app.menu_name
        AND m_all.menu_type = m_app.menu_type
        AND m_all.parent_id = m_app.parent_id
        AND m_all.client_type = 'all'
      WHERE m_app.client_type = 'app' AND m_app.menu_type = 'C'
    ) t
  );

-- 4. 删除 client_type='app' 的重复菜单（C类型）
DELETE m_app FROM sys_menu m_app
INNER JOIN sys_menu m_all ON m_all.menu_name = m_app.menu_name
  AND m_all.menu_type = m_app.menu_type
  AND m_all.parent_id = m_app.parent_id
  AND m_all.client_type = 'all'
  AND m_all.status = '0'
WHERE m_app.client_type = 'app'
  AND m_app.menu_type = 'C';

-- 5. 清理可能残留的 sys_app_menu 孤儿记录（menu_id 已不存在于 sys_menu）
DELETE FROM sys_app_menu WHERE menu_id NOT IN (SELECT menu_id FROM sys_menu);

-- 6. 清理可能残留的 sys_role_menu 孤儿记录
DELETE FROM sys_role_menu WHERE menu_id NOT IN (SELECT menu_id FROM sys_menu);

-- 7. 验证：检查是否还有重复菜单
SELECT m1.menu_name, m1.menu_type, m1.client_type, m1.menu_id, m2.menu_id AS dup_menu_id
FROM sys_menu m1
INNER JOIN sys_menu m2 ON m1.menu_name = m2.menu_name
  AND m1.menu_type = m2.menu_type
  AND m1.parent_id = m2.parent_id
  AND m1.menu_id < m2.menu_id
WHERE m1.status = '0' AND m2.status = '0'
  AND m1.menu_type IN ('C', 'M');
