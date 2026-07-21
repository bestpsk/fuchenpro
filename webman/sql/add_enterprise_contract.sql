-- =====================================================
-- 企业管理新增合同签订字段和合同上传功能
-- 执行前请备份 biz_enterprise 表
-- =====================================================

-- 1. 新增字段（如果不存在）
SET @dbname = DATABASE();
SET @tablename = 'biz_enterprise';

-- 添加 contract_status
SET @colname = 'contract_status';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  'ALTER TABLE biz_enterprise ADD COLUMN contract_status char(1) NOT NULL DEFAULT ''0'' COMMENT ''合同签订(0未签约 1已签约)'' AFTER cooperation_end_date'
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 contract_files
SET @colname = 'contract_files';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  'ALTER TABLE biz_enterprise ADD COLUMN contract_files text DEFAULT NULL COMMENT ''合同文件(逗号分隔URL)'' AFTER contract_status'
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. 字典类型（如果不存在）
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time)
SELECT '合同签订状态', 'biz_contract_status', '0', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'biz_contract_status');

-- 3. 字典数据（如果不存在）
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time)
SELECT 1, '未签约', '0', 'biz_contract_status', '', 'info', 'Y', '0', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'biz_contract_status' AND dict_value = '0');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time)
SELECT 2, '已签约', '1', 'biz_contract_status', '', 'success', 'N', '0', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'biz_contract_status' AND dict_value = '1');
