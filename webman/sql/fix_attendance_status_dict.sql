-- 补充考勤状态字典数据（迟到+缺勤、早退+缺勤）
INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(5, '迟到+缺勤', '5', 'biz_attendance_status', '', 'danger', 'N', '0', 'admin', NOW(), '迟到且缺勤（无下班打卡）'),
(6, '早退+缺勤', '6', 'biz_attendance_status', '', 'danger', 'N', '0', 'admin', NOW(), '早退且缺勤（无下班打卡）');
