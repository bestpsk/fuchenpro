-- =============================================
-- 卡项管理模块数据库脚本
-- =============================================

-- 1. 卡项目录表
DROP TABLE IF EXISTS `biz_card_item`;
CREATE TABLE `biz_card_item` (
  `card_item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '卡项ID',
  `card_item_name` varchar(100) NOT NULL COMMENT '卡项名称',
  `card_item_code` varchar(50) DEFAULT NULL COMMENT '卡项编码',
  `category` char(1) NOT NULL DEFAULT '1' COMMENT '类别(1面部 2身体 3仪器 4其他)',
  `default_quantity` int NOT NULL DEFAULT 1 COMMENT '默认次数',
  `suggested_price` decimal(12,2) DEFAULT 0.00 COMMENT '建议成交价',
  `default_unit_price` decimal(12,2) DEFAULT 0.00 COMMENT '默认单次价',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`card_item_id`),
  UNIQUE KEY `uk_card_item_code` (`card_item_code`),
  KEY `idx_card_item_name` (`card_item_name`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡项目录表';

-- 2. 卡项关联货品表
DROP TABLE IF EXISTS `biz_card_item_product`;
CREATE TABLE `biz_card_item_product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `card_item_id` bigint NOT NULL COMMENT '卡项ID',
  `product_id` bigint NOT NULL COMMENT '货品ID',
  `unit_type` char(1) NOT NULL DEFAULT '1' COMMENT '单位类型(1主单位-整 2副单位-拆)',
  `pack_qty` int DEFAULT 1 COMMENT '换算比例(1主单位=多少副单位)',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '消耗数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_card_item_id` (`card_item_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡项关联货品表';

-- 3. 订单明细表新增卡项ID字段
ALTER TABLE `biz_order_item` ADD COLUMN `card_item_id` bigint DEFAULT NULL COMMENT '卡项ID' AFTER `order_id`;
ALTER TABLE `biz_order_item` ADD KEY `idx_card_item_id` (`card_item_id`);

-- 4. 套餐明细表新增卡项ID字段
ALTER TABLE `biz_package_item` ADD COLUMN `card_item_id` bigint DEFAULT NULL COMMENT '卡项ID' AFTER `package_id`;
ALTER TABLE `biz_package_item` ADD KEY `idx_card_item_id` (`card_item_id`);

-- 5. 插入菜单数据
SET @business_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('卡项管理', @business_menu_id, 4, 'cardItem', 'business/cardItem/index', NULL, 'CardItem', 1, 0, 'C', '0', '0', 'business:cardItem:list', 'component', 'admin', NOW());

-- 卡项管理按钮权限
SET @card_item_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '卡项管理' AND path = 'cardItem') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('卡项查询', @card_item_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:cardItem:query', '#', 'admin', NOW()),
('卡项新增', @card_item_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:cardItem:add', '#', 'admin', NOW()),
('卡项修改', @card_item_menu_id, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:cardItem:edit', '#', 'admin', NOW()),
('卡项删除', @card_item_menu_id, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:cardItem:remove', '#', 'admin', NOW());

-- 6. 为管理员角色分配菜单权限
SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @card_item_menu_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @card_item_menu_id;

-- 7. 插入字典类型
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) VALUES
('卡项类别', 'biz_card_item_category', '0', 'admin', NOW(), '卡项类别列表');

-- 8. 插入字典数据
INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '面部', '1', 'biz_card_item_category', '', 'primary', 'Y', '0', 'admin', NOW()),
(2, '身体', '2', 'biz_card_item_category', '', 'success', 'N', '0', 'admin', NOW()),
(3, '仪器', '3', 'biz_card_item_category', '', 'warning', 'N', '0', 'admin', NOW()),
(4, '其他', '4', 'biz_card_item_category', '', 'info', 'N', '0', 'admin', NOW());

-- 9. 卡项关联货品表新增单位类型字段（如果表已存在）
-- ALTER TABLE `biz_card_item_product` ADD COLUMN `unit_type` char(1) NOT NULL DEFAULT '1' COMMENT '单位类型(1主单位-整 2副单位-拆)' AFTER `product_id`;
-- ALTER TABLE `biz_card_item_product` ADD COLUMN `pack_qty` int DEFAULT 1 COMMENT '换算比例(1主单位=多少副单位)' AFTER `unit_type`;

-- =============================================
-- 备货管理模块数据库脚本
-- =============================================

-- 10. 备货表
DROP TABLE IF EXISTS `biz_stock_prepare`;
CREATE TABLE `biz_stock_prepare` (
  `prepare_id` bigint NOT NULL AUTO_INCREMENT COMMENT '备货ID',
  `prepare_no` varchar(30) NOT NULL COMMENT '备货编号(SP+日期+4位序号)',
  `order_id` bigint DEFAULT NULL COMMENT '来源订单ID',
  `order_no` varchar(30) DEFAULT NULL COMMENT '来源订单编号',
  `customer_id` bigint DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `enterprise_id` bigint NOT NULL COMMENT '企业ID',
  `enterprise_name` varchar(100) DEFAULT NULL COMMENT '企业名称',
  `store_id` bigint DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  `total_quantity` int DEFAULT 0 COMMENT '总数量(最小单位)',
  `total_amount` decimal(12,2) DEFAULT 0.00 COMMENT '总金额',
  `shipped_quantity` int DEFAULT 0 COMMENT '已出库数量',
  `shipped_amount` decimal(12,2) DEFAULT 0.00 COMMENT '已出库金额',
  `remaining_quantity` int DEFAULT 0 COMMENT '剩余待出数量',
  `remaining_amount` decimal(12,2) DEFAULT 0.00 COMMENT '剩余待出金额',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待备货 1部分出库 2已出完 3已取消)',
  `remark` text DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`prepare_id`),
  UNIQUE KEY `uk_prepare_no` (`prepare_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_enterprise_id` (`enterprise_id`),
  KEY `idx_store_id` (`store_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='备货表';

-- 11. 备货明细表
DROP TABLE IF EXISTS `biz_stock_prepare_item`;
CREATE TABLE `biz_stock_prepare_item` (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `prepare_id` bigint NOT NULL COMMENT '备货ID',
  `card_item_id` bigint DEFAULT NULL COMMENT '卡项ID',
  `product_id` bigint NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) NOT NULL COMMENT '货品名称',
  `unit` varchar(20) DEFAULT NULL COMMENT '主单位',
  `spec` varchar(100) DEFAULT NULL COMMENT '副单位/规格',
  `unit_type` char(1) NOT NULL DEFAULT '1' COMMENT '单位类型(1主单位-整 2副单位-拆)',
  `pack_qty` int DEFAULT 1 COMMENT '换算比例',
  `sale_price` decimal(10,2) DEFAULT 0.00 COMMENT '出货价',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '数量(最小单位)',
  `amount` decimal(12,2) DEFAULT 0.00 COMMENT '金额',
  `shipped_quantity` int NOT NULL DEFAULT 0 COMMENT '已出库数量',
  `shipped_amount` decimal(12,2) DEFAULT 0.00 COMMENT '已出库金额',
  `remaining_quantity` int NOT NULL DEFAULT 0 COMMENT '剩余待出数量',
  `remaining_amount` decimal(12,2) DEFAULT 0.00 COMMENT '剩余待出金额',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`),
  KEY `idx_prepare_id` (`prepare_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='备货明细表';

-- 11.2 库存-订单关联表
DROP TABLE IF EXISTS `biz_stock_prepare_order`;
CREATE TABLE `biz_stock_prepare_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `prepare_id` bigint NOT NULL COMMENT '备货ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `order_no` varchar(30) DEFAULT NULL COMMENT '订单编号',
  `customer_id` bigint DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(50) DEFAULT NULL COMMENT '客户姓名',
  `store_id` bigint DEFAULT NULL COMMENT '门店ID',
  `store_name` varchar(100) DEFAULT NULL COMMENT '门店名称',
  PRIMARY KEY (`id`),
  KEY `idx_prepare_id` (`prepare_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存-订单关联表';

-- 11.1 出库单新增来源备货ID
-- ALTER TABLE `biz_stock_out` ADD COLUMN `prepare_id` bigint DEFAULT NULL COMMENT '来源备货ID' AFTER `stock_out_type`;

-- 12. 企业备货菜单
SET @business_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0) t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`)
VALUES ('企业备货', @business_menu_id, 5, 'stockPrepare', 'business/stockPrepare/index', NULL, 'StockPrepare', 1, 0, 'C', '0', '0', 'business:stockPrepare:list', 'component', 'admin', NOW());

SET @stock_prepare_menu_id = (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_name = '企业备货' AND path = 'stockPrepare') t);
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`) VALUES
('备货查询', @stock_prepare_menu_id, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:stockPrepare:query', '#', 'admin', NOW()),
('备货出库', @stock_prepare_menu_id, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'business:stockPrepare:stockOut', '#', 'admin', NOW());

SET @admin_role_id = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (@admin_role_id, @stock_prepare_menu_id);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT @admin_role_id, menu_id FROM sys_menu WHERE parent_id = @stock_prepare_menu_id;

-- 13. 备货状态字典
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) VALUES
('备货状态', 'biz_stock_prepare_status', '0', 'admin', NOW(), '备货状态列表');

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '待备货', '0', 'biz_stock_prepare_status', '', 'primary', 'Y', '0', 'admin', NOW()),
(2, '部分出库', '1', 'biz_stock_prepare_status', '', 'warning', 'N', '0', 'admin', NOW()),
(3, '已出完', '2', 'biz_stock_prepare_status', '', 'success', 'N', '0', 'admin', NOW()),
(4, '已取消', '3', 'biz_stock_prepare_status', '', 'info', 'N', '0', 'admin', NOW());
