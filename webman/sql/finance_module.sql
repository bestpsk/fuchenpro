-- =============================================
-- 财务管理模块数据库脚本
-- =============================================

-- 1. 报销单表
CREATE TABLE IF NOT EXISTS `fin_reimbursement` (
  `reimbursement_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `reimbursement_no` varchar(32) NOT NULL COMMENT '报销单号',
  `applicant_id` int(11) NOT NULL COMMENT '申请人ID',
  `applicant_name` varchar(50) DEFAULT NULL COMMENT '申请人姓名',
  `dept_id` int(11) DEFAULT NULL COMMENT '所属部门ID',
  `dept_name` varchar(100) DEFAULT NULL COMMENT '部门名称',
  `apply_date` date DEFAULT NULL COMMENT '申请日期',
  `category` char(1) DEFAULT '4' COMMENT '分类：1行程买票 2销售费用 3行政支出 4其它',
  `income_amount` decimal(12,2) DEFAULT '0.00' COMMENT '收入金额',
  `expense_amount` decimal(12,2) DEFAULT '0.00' COMMENT '支出金额',
  `expense_type` char(1) DEFAULT '1' COMMENT '支出类型：1员工支出 2公司支出',
  `status` char(1) DEFAULT '0' COMMENT '状态：0待审核 1已审核 2已驳回 3已支付',
  `voucher_images` text COMMENT '凭证图片JSON数组',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `audit_by` varchar(50) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审核备注',
  `pay_by` varchar(50) DEFAULT NULL COMMENT '支付人',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `create_by` varchar(50) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(50) DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`reimbursement_id`),
  UNIQUE KEY `uk_reimbursement_no` (`reimbursement_no`),
  KEY `idx_applicant_id` (`applicant_id`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_status` (`status`),
  KEY `idx_apply_date` (`apply_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报销单表';

-- 2. 报销明细表
CREATE TABLE IF NOT EXISTS `fin_reimbursement_item` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `reimbursement_id` int(11) NOT NULL COMMENT '报销单ID',
  `item_name` varchar(100) DEFAULT NULL COMMENT '项目名称',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '金额',
  `description` varchar(200) DEFAULT NULL COMMENT '说明',
  PRIMARY KEY (`item_id`),
  KEY `idx_reimbursement_id` (`reimbursement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报销明细表';

-- 3. 字典类型
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES
('报销分类', 'fin_reimbursement_category', '0', 'admin', NOW(), '报销单分类'),
('支出类型', 'fin_reimbursement_expense_type', '0', 'admin', NOW(), '报销支出类型'),
('报销状态', 'fin_reimbursement_status', '0', 'admin', NOW(), '报销单状态');

-- 4. 字典数据
INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, '行程买票', '1', 'fin_reimbursement_category', '', 'primary', 'N', '0', 'admin', NOW(), NULL),
(2, '销售费用', '2', 'fin_reimbursement_category', '', 'success', 'N', '0', 'admin', NOW(), NULL),
(3, '行政支出', '3', 'fin_reimbursement_category', '', 'warning', 'N', '0', 'admin', NOW(), NULL),
(4, '其它', '4', 'fin_reimbursement_category', '', 'info', 'Y', '0', 'admin', NOW(), NULL);

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, '员工支出', '1', 'fin_reimbursement_expense_type', '', 'primary', 'Y', '0', 'admin', NOW(), '个人先垫付，公司后报销'),
(2, '公司支出', '2', 'fin_reimbursement_expense_type', '', 'success', 'N', '0', 'admin', NOW(), '公司直接支付');

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(0, '待审核', '0', 'fin_reimbursement_status', '', 'warning', 'Y', '0', 'admin', NOW(), NULL),
(1, '已审核', '1', 'fin_reimbursement_status', '', 'success', 'N', '0', 'admin', NOW(), NULL),
(2, '已驳回', '2', 'fin_reimbursement_status', '', 'danger', 'N', '0', 'admin', NOW(), NULL),
(3, '已支付', '3', 'fin_reimbursement_status', '', 'info', 'N', '0', 'admin', NOW(), NULL);

-- 5. 菜单数据
-- 一级菜单：财务管理
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES (3000, '财务管理', 0, 5, 'finance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'money', 'admin', NOW(), NULL, NULL, '财务管理目录');

-- 子菜单：方案审核
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES (3001, '方案审核', 3000, 1, 'planAudit', 'finance/planAudit/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:planAudit:list', 'edit', 'admin', NOW(), NULL, NULL, '方案审核菜单');

-- 子菜单：报销管理
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES (3002, '报销管理', 3000, 2, 'reimbursement', 'finance/reimbursement/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursement:list', 'form', 'admin', NOW(), NULL, NULL, '报销管理菜单');

-- 子菜单：报销统计
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES (3003, '报销统计', 3000, 3, 'reimbursementReport', 'finance/reimbursementReport/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursementReport:list', 'chart', 'admin', NOW(), NULL, NULL, '报销统计菜单');

-- 6. 按钮权限
-- 方案审核按钮
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('方案审核查询', 3001, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:planAudit:query', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('方案审核操作', 3001, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:planAudit:audit', '#', 'admin', NOW(), NULL, NULL, '');

-- 报销管理按钮
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销查询', 3002, 1, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:query', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销新增', 3002, 2, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:add', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销编辑', 3002, 3, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:edit', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销删除', 3002, 4, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:remove', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销审核', 3002, 5, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:audit', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销支付', 3002, 6, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:pay', '#', 'admin', NOW(), NULL, NULL, '');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('报销导出', 3002, 7, '', NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'finance:reimbursement:export', '#', 'admin', NOW(), NULL, NULL, '');
