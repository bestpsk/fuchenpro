<?php

namespace app\process;

use Workerman\Timer;
use Workerman\Worker;
use app\model\BizAttendanceRecord;
use app\model\BizEmployeeConfig;
use app\model\BizLeave;
use app\model\BizRestDay;
use app\model\BizSchedule;
use support\Db;
use support\Log;

/**
 * 考勤自动补录进程
 *
 * 每小时检查一次，在每天 23:00 后为未打卡的可排班员工生成缺勤记录
 * 排除条件：休息日、请假、法定假日、已确认行程
 */
class AttendanceAutoGenerator
{
    private $lastRunDate = '';

    public function onWorkerStart(Worker $worker)
    {
        // 每 3600 秒（1小时）检查一次
        Timer::add(3600, function () {
            $this->generateAbsentRecords();
        });
    }

    private function generateAbsentRecords()
    {
        $now = time();
        $hour = (int) date('H', $now);
        // 仅在 23:00~23:59 之间执行，避免频繁查询
        if ($hour < 23) {
            return;
        }
        // 防止同一天重复执行
        $today = date('Y-m-d');
        if ($this->lastRunDate === $today) {
            return;
        }
        $this->lastRunDate = $today;

        try {
            // 查询所有可排班员工
            $employees = BizEmployeeConfig::where('is_schedulable', '1')
                ->whereNotNull('user_id')
                ->get(['user_id', 'user_name']);

            if ($employees->isEmpty()) {
                return;
            }

            // 获取当天各种排除日期集合
            $restUserIds = $this->getRestDayUserIds($today);
            $leaveUserIds = $this->getLeaveUserIds($today);
            $scheduleUserIds = $this->getScheduleUserIds($today);
            $isHoliday = $this->isHoliday($today);

            $generated = 0;
            $now = date('Y-m-d H:i:s');

            foreach ($employees as $emp) {
                $userId = $emp->user_id;

                // 排除：法定假日（影响全员）
                if ($isHoliday) {
                    continue;
                }
                // 排除：当天是休息日
                if (in_array($userId, $restUserIds)) {
                    continue;
                }
                // 排除：当天已请假
                if (in_array($userId, $leaveUserIds)) {
                    continue;
                }
                // 排除：当天有已确认行程
                if (in_array($userId, $scheduleUserIds)) {
                    continue;
                }

                // 检查是否已有考勤记录
                $exists = BizAttendanceRecord::where('user_id', $userId)
                    ->where('attendance_date', $today)
                    ->exists();
                if ($exists) {
                    continue;
                }

                // 生成缺勤记录
                BizAttendanceRecord::create([
                    'user_id' => $userId,
                    'user_name' => $emp->user_name,
                    'attendance_date' => $today,
                    'clock_count' => 0,
                    'attendance_status' => '4', // 缺勤
                    'clock_type' => '0',
                    'remark' => '系统自动补录：未打卡',
                    'create_by' => 'system',
                    'create_time' => $now,
                    'update_time' => $now,
                ]);
                $generated++;
            }

            if ($generated > 0) {
                Log::info("考勤自动补录：{$today} 为 {$generated} 名未打卡员工生成缺勤记录");
            }
        } catch (\Throwable $e) {
            Log::error('考勤自动补录异常: ' . $e->getMessage());
        }
    }

    /**
     * 获取当天有休息日的员工ID列表（自定义休息日 + 按周模板）
     */
    private function getRestDayUserIds($date)
    {
        // biz_rest_day 表中的自定义休息日和请假休息日
        $restUserIds = BizRestDay::where('rest_date', $date)
            ->pluck('user_id')
            ->toArray();

        // 按周模板：直接查询 biz_rest_plan 表
        $weekDay = strtolower(date('l', strtotime($date))); // monday, tuesday...
        $plans = Db::table('biz_rest_plan')
            ->where('status', '0') // 启用
            ->where('effective_date', '<=', $date)
            ->where($weekDay, '1')
            ->get(['user_ids']);
        foreach ($plans as $plan) {
            $userIds = array_filter(explode(',', $plan->user_ids), fn($v) => $v > 0);
            $restUserIds = array_merge($restUserIds, $userIds);
        }

        return array_map('intval', array_unique($restUserIds));
    }

    /**
     * 获取当天已通过请假的员工ID列表
     */
    private function getLeaveUserIds($date)
    {
        return BizLeave::where('status', '1')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->pluck('user_id')
            ->toArray();
    }

    /**
     * 获取当天有已确认行程的员工ID列表
     */
    private function getScheduleUserIds($date)
    {
        // biz_schedule 使用 schedule_date 单日期字段
        // 行程状态：0待确认 1已确认 2已完成 3已取消
        return BizSchedule::whereIn('status', ['1', '2'])
            ->where('schedule_date', $date)
            ->pluck('user_id')
            ->unique()
            ->toArray();
    }

    /**
     * 判断当天是否为法定假日
     */
    private function isHoliday($date)
    {
        return Db::table('biz_holiday')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->where('status', '0')
            ->exists();
    }
}
