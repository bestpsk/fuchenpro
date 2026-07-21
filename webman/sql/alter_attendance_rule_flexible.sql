-- =============================================
-- 考勤规则增强：区分坐班/外勤 + 弹性打卡模式
-- 执行顺序：1.加字段 -> 2.更新默认数据 -> 3.新增外勤默认规则 -> 4.字典
-- =============================================

-- 1. 为 biz_attendance_rule 添加新字段
ALTER TABLE `biz_attendance_rule`
  ADD COLUMN `clock_type` char(1) NOT NULL DEFAULT '0' COMMENT '打卡类型(0坐班 1外勤)' AFTER `rule_name`,
  ADD COLUMN `work_mode` char(1) NOT NULL DEFAULT '0' COMMENT '工作模式(0固定时间 1弹性打卡)' AFTER `clock_type`,
  ADD COLUMN `required_work_hours` decimal(4,1) NOT NULL DEFAULT 8.0 COMMENT '弹性打卡每日所需工时(小时)' AFTER `work_mode`;

-- 2. 更新默认规则：标为坐班+固定时间
UPDATE `biz_attendance_rule` SET `clock_type` = '0', `work_mode` = '0' WHERE `rule_name` = '标准班';

-- 3. 新增默认外勤弹性打卡规则
INSERT INTO `biz_attendance_rule` (`rule_name`, `clock_type`, `work_mode`, `required_work_hours`, `work_start_time`, `work_end_time`, `late_threshold`, `early_leave_threshold`, `allowed_distance`, `status`, `remark`, `create_by`)
VALUES ('外勤弹性班', '1', '1', 8.0, '09:00:00', '18:00:00', 0, 0, 500, '0', '默认外勤弹性打卡规则', 'admin');

-- 4. 新增字典类型：工作模式
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES ('工作模式', 'biz_work_mode', '0', 'admin', NOW(), '考勤工作模式');

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`) VALUES
(1, '固定时间', '0', 'biz_work_mode', '', 'primary', 'Y', '0', 'admin', NOW()),
(2, '弹性打卡', '1', 'biz_work_mode', '', 'success', 'N', '0', 'admin', NOW());
