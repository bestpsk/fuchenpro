-- =============================================
-- 删除废弃的 biz_employee_rest_day 表
-- 该表已被 biz_rest_plan/biz_rest_plan_employee/biz_rest_plan_date 三表替代
-- 所有相关代码（Model/Service/Controller/Route）已清理完毕
-- 执行前请确认 biz_rest_plan 系列表数据已完整迁移
-- =============================================

DROP TABLE IF EXISTS `biz_employee_rest_day`;
