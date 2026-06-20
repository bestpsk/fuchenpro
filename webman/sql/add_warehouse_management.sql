-- ============================================
-- 多仓库管理 - 数据库迁移脚本
-- ============================================

-- 1. 创建仓库表
CREATE TABLE IF NOT EXISTS `biz_warehouse` (
  `warehouse_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `warehouse_name` varchar(100) NOT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(30) NOT NULL COMMENT '仓库编码',
  `address` varchar(255) DEFAULT NULL COMMENT '仓库地址',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(50) DEFAULT NULL COMMENT '联系电话',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`warehouse_id`),
  UNIQUE KEY `uk_warehouse_code` (`warehouse_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';

-- 2. 创建仓库用户权限表
CREATE TABLE IF NOT EXISTS `biz_warehouse_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint(20) NOT NULL COMMENT '仓库ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_user` (`warehouse_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库用户权限表';

-- 3. 插入默认仓库
INSERT INTO `biz_warehouse` (`warehouse_id`, `warehouse_name`, `warehouse_code`, `status`) VALUES (1, '默认仓库', 'WH001', '0');

-- 4. 所有现有用户授权到默认仓库
INSERT INTO `biz_warehouse_user` (`warehouse_id`, `user_id`) SELECT 1, `user_id` FROM `sys_user` WHERE `del_flag` = '0' AND `status` = '0';

-- 5. biz_inventory 新增 warehouse_id，修改唯一索引
ALTER TABLE `biz_inventory` ADD COLUMN `warehouse_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '仓库ID' AFTER `inventory_id`;
ALTER TABLE `biz_inventory` DROP INDEX `uk_product_id`;
ALTER TABLE `biz_inventory` ADD UNIQUE KEY `uk_product_warehouse` (`product_id`, `warehouse_id`);

-- 6. biz_stock_in 新增 warehouse_id
ALTER TABLE `biz_stock_in` ADD COLUMN `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER `stock_in_type`;

-- 7. biz_stock_out 新增 warehouse_id
ALTER TABLE `biz_stock_out` ADD COLUMN `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER `stock_out_type`;

-- 8. biz_stock_check 新增 warehouse_id
ALTER TABLE `biz_stock_check` ADD COLUMN `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER `stock_check_no`;

-- 8.5. biz_stock_prepare 新增 warehouse_id
ALTER TABLE `biz_stock_prepare` ADD COLUMN `warehouse_id` bigint(20) DEFAULT NULL COMMENT '仓库ID' AFTER `enterprise_name`;

-- 9. 创建调拨单主表
CREATE TABLE IF NOT EXISTS `biz_stock_transfer` (
  `transfer_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '调拨ID',
  `transfer_no` varchar(30) NOT NULL COMMENT '调拨单号',
  `from_warehouse_id` bigint(20) NOT NULL COMMENT '源仓库ID',
  `from_warehouse_name` varchar(100) DEFAULT NULL COMMENT '源仓库名称',
  `to_warehouse_id` bigint(20) NOT NULL COMMENT '目标仓库ID',
  `to_warehouse_name` varchar(100) DEFAULT NULL COMMENT '目标仓库名称',
  `total_quantity` int(11) DEFAULT 0 COMMENT '总数量',
  `transfer_date` date DEFAULT NULL COMMENT '调拨日期',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态(0待确认 1已确认 2已取消)',
  `remark` text COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`transfer_id`),
  UNIQUE KEY `uk_transfer_no` (`transfer_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨单主表';

-- 10. 创建调拨单明细表
CREATE TABLE IF NOT EXISTS `biz_stock_transfer_item` (
  `item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `transfer_id` bigint(20) NOT NULL COMMENT '调拨单ID',
  `product_id` bigint(20) NOT NULL COMMENT '货品ID',
  `product_name` varchar(100) DEFAULT NULL COMMENT '货品名称',
  `spec` char(1) DEFAULT NULL COMMENT '规格',
  `unit` char(1) DEFAULT NULL COMMENT '单位',
  `pack_qty` int(11) DEFAULT 1 COMMENT '换算比例',
  `unit_type` char(1) DEFAULT '1' COMMENT '单位类型(1主单位 2副单位)',
  `original_quantity` int(11) DEFAULT 0 COMMENT '原始数量',
  `quantity` int(11) DEFAULT 0 COMMENT '调拨数量(最小单位)',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨单明细表';
