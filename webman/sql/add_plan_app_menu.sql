INSERT INTO app_menu_config (group_name, group_key, group_sort, title, icon, path, icon_color, bg_color, sort_order, visible, status, perms)
VALUES ('业务管理', 'business', 2, '方案管理', 'file-text', '/pages/business/plan/index', '#fff', '#FF6B35', 6, 1, '0', 'business:plan:list');

UPDATE app_menu_config SET path = '/pages/business/plan/index' WHERE group_key = 'finance' AND title = '方案审核';

UPDATE app_menu_config SET path = '/pages/wms/supplier/index' WHERE group_key = 'wms' AND title = '供货商管理';

UPDATE app_menu_config SET path = '/pages/wms/shipment/index' WHERE group_key = 'wms' AND title = '店企业出货';
