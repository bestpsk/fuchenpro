-- =============================================
-- 数据完整性修复SQL脚本
-- 修复审计字段默认值不一致问题
-- =============================================

-- biz_attendance_config: 审计字段 DEFAULT NULL → 统一默认值
ALTER TABLE `biz_attendance_config`
  MODIFY `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  MODIFY `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  MODIFY `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  MODIFY `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';

-- biz_plan: 审计字段 DEFAULT NULL → 统一默认值
ALTER TABLE `biz_plan`
  MODIFY `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  MODIFY `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  MODIFY `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  MODIFY `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';

-- biz_shipment: 审计字段 DEFAULT NULL → 统一默认值
ALTER TABLE `biz_shipment`
  MODIFY `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  MODIFY `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  MODIFY `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  MODIFY `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';

-- biz_repayment_record: 审计字段 DEFAULT NULL → 统一默认值
ALTER TABLE `biz_repayment_record`
  MODIFY `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  MODIFY `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  MODIFY `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  MODIFY `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
