INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
SELECT '订单来源类型', 'biz_source_type', '0', 'admin', NOW(), '订单来源类型字典（开单/操作/还款/手动）'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_dict_type` WHERE `dict_type` = 'biz_source_type');

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(1, '开单', '0', 'biz_source_type', '', 'primary', 'Y', '0', 'admin', NOW(), '销售开单'),
(2, '操作', '1', 'biz_source_type', '', 'success', 'N', '0', 'admin', NOW(), '项目操作'),
(3, '还款', '2', 'biz_source_type', '', 'warning', 'N', '0', 'admin', NOW(), '客户还款'),
(4, '手动', '3', 'biz_source_type', '', 'info', 'N', '0', 'admin', NOW(), '手动建档');
