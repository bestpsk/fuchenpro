-- =============================================
-- 删除 biz_attendance_record 表的冗余字段
-- first_clock_time/last_clock_time 与 clock_in_time/clock_out_time 完全重复
-- 执行前请确认已无代码使用这两个字段（Model $fillable 和 Service 已清理）
-- =============================================

ALTER TABLE `biz_attendance_record`
  DROP COLUMN `first_clock_time`,
  DROP COLUMN `last_clock_time`;
