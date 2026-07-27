-- =============================================
-- 修复学习材料菜单下重复的按钮权限
-- 问题：学习材料下可能残留 train:study:query 按钮（应属于在线学习）
-- =============================================

-- 1. 查看学习材料下所有按钮权限（修复前）
SELECT menu_id, menu_name, perms, order_num, parent_id
FROM sys_menu
WHERE parent_id = (
    SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习材料' AND path = 'material') t
)
AND menu_type = 'F'
ORDER BY order_num;

-- 2. 查看在线学习下所有按钮权限（修复前）
SELECT menu_id, menu_name, perms, order_num, parent_id
FROM sys_menu
WHERE parent_id = (
    SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '在线学习' AND path = 'online') t
)
AND menu_type = 'F'
ORDER BY order_num;

-- 3. 删除学习材料下不属于 train:material:* 的按钮（如残留的 train:study:query）
SET @material_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '学习材料' AND path = 'material') t);

DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM (
        SELECT menu_id FROM sys_menu
        WHERE parent_id = @material_menu_id
          AND menu_type = 'F'
          AND perms NOT LIKE 'train:material:%'
    ) tmp
);

DELETE FROM sys_menu
WHERE parent_id = @material_menu_id
  AND menu_type = 'F'
  AND perms NOT LIKE 'train:material:%';

-- 4. 为在线学习添加材料查询按钮权限（如果不存在）
SET @online_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '在线学习' AND path = 'online') t);

INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '材料查询', @online_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'train:study:query', '#', 'admin', NOW()
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @online_menu_id AND perms = 'train:study:query'
);

-- 5. 为管理员角色分配在线学习的材料查询按钮权限
SET @admin_role_id = 1;
SET @study_query_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id = @online_menu_id AND perms = 'train:study:query') t);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, @study_query_menu_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = @admin_role_id AND menu_id = @study_query_menu_id
);

-- 6. 验证：学习材料下按钮权限（修复后）
SELECT menu_id, menu_name, perms, order_num
FROM sys_menu
WHERE parent_id = @material_menu_id
AND menu_type = 'F'
ORDER BY order_num;

-- 7. 验证：在线学习下按钮权限（修复后）
SELECT menu_id, menu_name, perms, order_num
FROM sys_menu
WHERE parent_id = @online_menu_id
AND menu_type = 'F'
ORDER BY order_num;
