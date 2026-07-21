-- =============================================
-- 卡项管理导出权限补充
-- 说明：PC 端导出按钮使用 v-hasPermi="['business:cardItem:export']"，
--       但数据库缺少该权限菜单，导致导出按钮对所有用户不可见，
--       且后端 BizCardItemController::export() 未做权限校验存在越权风险。
--       本脚本新增导出权限并分配给管理员角色。
-- 执行方式：手动执行
-- =============================================

-- 1. 新增卡项导出按钮权限（挂在"卡项管理"菜单下）
SET @card_item_menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
SELECT '卡项导出', @card_item_menu_id, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:cardItem:export', '#', 'admin', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'business:cardItem:export' AND parent_id = @card_item_menu_id);

-- 2. 为管理员角色（role_id=1）分配导出权限
SET @export_menu_id = (SELECT menu_id FROM sys_menu WHERE perms = 'business:cardItem:export');
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, @export_menu_id);
