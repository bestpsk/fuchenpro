UPDATE `app_menu_config` SET `group_sort` = 6 WHERE `group_key` = 'system';
UPDATE `app_menu_config` SET `group_sort` = 7 WHERE `group_key` = 'mine_action';
UPDATE `app_menu_config` SET `group_sort` = 8 WHERE `group_key` = 'mine_menu';

INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`) VALUES
('考勤管理', 'attendance', 3, '考勤打卡', 'clock', '/pages/attendance/index', '#fff', '#F59E0B', 1, 1, '0'),
('考勤管理', 'attendance', 3, '考勤记录', 'file-text', '/pages/attendance/record', '#fff', '#F59E0B', 2, 1, '0'),
('考勤管理', 'attendance', 3, '考勤规则', 'setting', '', '#fff', '#F59E0B', 3, 1, '0'),
('考勤管理', 'attendance', 3, '考勤配置', 'grid', '', '#fff', '#F59E0B', 4, 1, '0'),
('进销存管理', 'wms', 4, '供货商管理', 'account', '', '#fff', '#10B981', 1, 1, '0'),
('进销存管理', 'wms', 4, '货品管理', 'list', '', '#fff', '#10B981', 2, 1, '0'),
('进销存管理', 'wms', 4, '入库管理', 'arrow-down', '', '#fff', '#10B981', 3, 1, '0'),
('进销存管理', 'wms', 4, '出库管理', 'arrow-up', '', '#fff', '#10B981', 4, 1, '0'),
('进销存管理', 'wms', 4, '库存查看', 'search', '', '#fff', '#10B981', 5, 1, '0'),
('进销存管理', 'wms', 4, '库存盘点', 'checkmark-circle', '', '#fff', '#10B981', 6, 1, '0'),
('进销存管理', 'wms', 4, '店企业出货', 'car', '', '#fff', '#10B981', 7, 1, '0'),
('进销存管理', 'wms', 4, '进销存报表', 'bar-chart', '', '#fff', '#10B981', 8, 1, '0'),
('财务管理', 'finance', 5, '方案审核', 'checkmark', '', '#fff', '#8B5CF6', 1, 1, '0'),
('财务管理', 'finance', 5, '报销管理', 'edit-pen', '', '#fff', '#8B5CF6', 2, 1, '0'),
('财务管理', 'finance', 5, '报销统计', 'bar-chart', '', '#fff', '#8B5CF6', 3, 1, '0');
