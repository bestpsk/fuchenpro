-- =============================================
-- 修复下店目的字典值标签
-- 将"启动销售"改为"销售"、"售后服务"改为"售后"、"洽谈业务"改为"业务"
-- =============================================

UPDATE `sys_dict_data` SET `dict_label` = '销售' WHERE `dict_type` = 'biz_schedule_purpose' AND `dict_value` = '2' AND `dict_label` = '启动销售';
UPDATE `sys_dict_data` SET `dict_label` = '售后' WHERE `dict_type` = 'biz_schedule_purpose' AND `dict_value` = '3' AND `dict_label` = '售后服务';
UPDATE `sys_dict_data` SET `dict_label` = '业务' WHERE `dict_type` = 'biz_schedule_purpose' AND `dict_value` = '4' AND `dict_label` = '洽谈业务';
