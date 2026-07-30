<?php

namespace app\service;

use app\model\BizAttendanceRecord;
use app\model\BizAttendanceRule;
use app\model\SysUser;
use app\service\DataScopeService;
use support\Db;

/**
 * 考勤记录服务层，处理考勤打卡（内勤/外勤）、上下班判断、迟到早退计算和月度统计
 */
class BizAttendanceRecordService
{
    // 按条件分页查询考勤日记录列表
    public function selectRecordList($params = [])
    {
        $query = BizAttendanceRecord::query();

        if (!empty($params['user_id'])) {
            $query->where('user_id', $params['user_id']);
        }
        if (!empty($params['user_name'])) {
            $query->where('user_name', 'like', '%' . $params['user_name'] . '%');
        }
        if (!empty($params['attendance_date'])) {
            $query->where('attendance_date', $params['attendance_date']);
        }
        if (!empty($params['start_date']) && !empty($params['end_date'])) {
            $query->whereBetween('attendance_date', [$params['start_date'], $params['end_date']]);
        }
        if (isset($params['attendance_status']) && $params['attendance_status'] !== '') {
            $query->where('attendance_status', $params['attendance_status']);
        }
        if (isset($params['clock_type']) && $params['clock_type'] !== '') {
            $query->where('clock_type', $params['clock_type']);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('user_id', $visibleUserIds);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('attendance_date', 'desc')->orderBy('record_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询考勤日记录详情，含打卡明细

    public function selectRecordById($recordId)
    {
        return BizAttendanceRecord::find($recordId);
    }

    public function getTodayRecord($userId)
    {
        $today = date('Y-m-d');
        return BizAttendanceRecord::where('user_id', $userId)
            ->where('attendance_date', $today)
            ->first();
    }

    public function clock($data)
    {
        return Db::transaction(function () use ($data) {
            $userId = $data['user_id'];
            $userName = $data['user_name'] ?? '';
            $now = date('Y-m-d H:i:s');
            $today = date('Y-m-d');
            $clockType = $data['clock_type'] ?? '0';
            $outsideReason = $data['outside_reason'] ?? '';

            if ($clockType === '1' && empty($outsideReason)) {
                return ['error' => '外勤打卡请填写外勤事由'];
            }

            $configService = new BizAttendanceConfigService();
            $rule = $configService->getUserRuleByClockType($userId, $clockType);

            // 坐班打卡必须有考勤规则，外勤打卡允许无规则
            if ($clockType === '0' && !$rule) {
                return ['error' => '未配置考勤规则，请联系管理员'];
            }

            if ($clockType === '0' && $rule) {
                if ($rule->work_latitude && $rule->work_longitude && !empty($data['latitude']) && !empty($data['longitude'])) {
                    $distance = $this->calculateDistance(
                        $data['latitude'], $data['longitude'],
                        $rule->work_latitude, $rule->work_longitude
                    );
                    \support\Log::info('考勤距离校验(clock)', [
                        'user_id' => $userId,
                        'user_location' => [$data['latitude'], $data['longitude']],
                        'rule_location' => [$rule->work_latitude, $rule->work_longitude],
                        'distance' => $distance,
                        'allowed_distance' => $rule->allowed_distance,
                        'is_in_range' => $distance <= $rule->allowed_distance
                    ]);
                    if ($distance > $rule->allowed_distance) {
                        return ['error' => '不在考勤范围内，距离考勤点' . intval($distance) . '米'];
                    }
                }
            } else if ($clockType === '1') {
                \support\Log::info('外勤打卡-跳过距离校验', [
                    'user_id' => $userId,
                    'clockType' => $clockType
                ]);
            }

            $record = BizAttendanceRecord::where('user_id', $userId)
                ->where('attendance_date', $today)
                ->first();

            if (!$record) {
                try {
                    $record = BizAttendanceRecord::create([
                        'user_id' => $userId,
                        'user_name' => $userName,
                        'attendance_date' => $today,
                        'clock_count' => 0,
                        'attendance_status' => '0',
                        'clock_type' => $clockType,
                        'rule_id' => $rule ? $rule->rule_id : null,
                        'outside_reason' => $outsideReason,
                        'create_by' => $userName,
                        'create_time' => $now,
                    ]);
                } catch (\Throwable $e) {
                    // 并发时唯一键冲突，重新查询已创建的记录
                    $record = BizAttendanceRecord::where('user_id', $userId)
                        ->where('attendance_date', $today)
                        ->first();
                    if (!$record) {
                        throw $e;
                    }
                }
            }

            $clockData = [
                'record_id' => $record->record_id,
                'user_id' => $userId,
                'user_name' => $userName,
                'clock_time' => $now,
                'clock_type' => $this->determineClockType($record),
                'work_type' => $clockType,
                'latitude' => $data['latitude'] ?? null,
                'longitude' => $data['longitude'] ?? null,
                'address' => $data['address'] ?? '',
                'photo' => $data['photo'] ?? '',
                'outside_reason' => $outsideReason,
            ];

            \app\model\BizAttendanceClock::create($clockData);

            $this->updateRecordSummary($record, $clockType, $rule);

            return BizAttendanceRecord::find($record->record_id);
        });
    }

    private function determineClockType($record)
    {
        return $record->clock_count == 0 ? '0' : '1';
    }

    private function updateRecordSummary($record, $clockType = '0', $rule = null)
    {
        $clockCount = \app\model\BizAttendanceClock::where('record_id', $record->record_id)->count();
        $firstClock = \app\model\BizAttendanceClock::where('record_id', $record->record_id)
            ->orderBy('clock_time', 'asc')
            ->first();
        $lastClock = \app\model\BizAttendanceClock::where('record_id', $record->record_id)
            ->orderBy('clock_time', 'desc')
            ->first();

        $attendanceStatus = $this->calculateAttendanceStatus($firstClock, $lastClock, $record->user_id);

        $updateData = [
            'clock_count' => $clockCount,
            'clock_in_time' => $firstClock ? $firstClock->clock_time : null,
            'clock_out_time' => $lastClock ? $lastClock->clock_time : null,
            'clock_in_latitude' => $firstClock ? $firstClock->latitude : null,
            'clock_in_longitude' => $firstClock ? $firstClock->longitude : null,
            'clock_in_address' => $firstClock ? $firstClock->address : '',
            'clock_in_photo' => $firstClock ? $firstClock->photo : '',
            'clock_out_latitude' => $lastClock ? $lastClock->latitude : null,
            'clock_out_longitude' => $lastClock ? $lastClock->longitude : null,
            'clock_out_address' => $lastClock ? $lastClock->address : '',
            'clock_out_photo' => $lastClock ? $lastClock->photo : '',
            'attendance_status' => $attendanceStatus,
            'rule_id' => $rule ? $rule->rule_id : ($record->rule_id ?? null),
            'outside_reason' => $firstClock ? ($firstClock->outside_reason ?? '') : '',
            'update_time' => date('Y-m-d H:i:s'),
        ];
        // clock_type 仅首次打卡时设置，避免后续打卡覆盖记录类型（先坐班后外勤应保留坐班类型）
        if ($clockCount <= 1) {
            $updateData['clock_type'] = $clockType;
        }
        $record->update($updateData);
    }

    private function calculateAttendanceStatus($firstClock, $lastClock, $userId)
    {
        $configService = new \app\service\BizAttendanceConfigService();
        // 根据首次打卡的 work_type 确定规则类型
        $clockType = $firstClock ? ($firstClock->work_type ?? '0') : '0';
        $rule = $configService->getUserRuleByClockType($userId, $clockType);

        if (!$rule) {
            return '0';
        }

        // 弹性打卡模式：按工时判断
        if ((string)$rule->work_mode === '1') {
            if (!$firstClock) {
                return '4'; // 缺勤：完全无打卡记录
            }
            // 只有上班打卡（无下班打卡）：状态为正常（进行中），待下班打卡后计算工时
            if (!$lastClock || $lastClock->clock_id === $firstClock->clock_id) {
                return '0'; // 正常（进行中）
            }
            $firstTime = strtotime($firstClock->clock_time);
            $lastTime = strtotime($lastClock->clock_time);
            $workHours = ($lastTime - $firstTime) / 3600;
            $requiredHours = floatval($rule->required_work_hours);
            if ($workHours < $requiredHours) {
                return '1'; // 工时不足 → 迟到
            }
            return '0'; // 正常
        }

        // 固定时间模式：迟到/早退判断
        if (!$firstClock) {
            return '4'; // 缺勤：完全无打卡记录
        }

        $isLate = false;
        $isEarly = false;

        if ($firstClock && $rule->work_start_time) {
            $firstTime = date('H:i:s', strtotime($firstClock->clock_time));
            $workStartTime = $rule->work_start_time;
            $lateThreshold = $rule->late_threshold;
            $lateTime = date('H:i:s', strtotime("$workStartTime + $lateThreshold minutes"));
            if ($firstTime > $lateTime) {
                $isLate = true;
            }
        }

        if ($lastClock && $firstClock && $lastClock->clock_id !== $firstClock->clock_id && $rule->work_end_time) {
            $lastTime = date('H:i:s', strtotime($lastClock->clock_time));
            $workEndTime = $rule->work_end_time;
            $earlyThreshold = $rule->early_leave_threshold;
            $earlyTime = date('H:i:s', strtotime("$workEndTime - $earlyThreshold minutes"));
            if ($lastTime < $earlyTime) {
                $isEarly = true;
            }
        }

        if ($isLate && $isEarly) return '3';
        if ($isLate) return '1';
        if ($isEarly) return '2';
        return '0';
    }

    public function getTodayClockList($userId)
    {
        $today = date('Y-m-d');
        $record = BizAttendanceRecord::where('user_id', $userId)
            ->where('attendance_date', $today)
            ->first();

        if (!$record) {
            return [];
        }

        return \app\model\BizAttendanceClock::where('record_id', $record->record_id)
            ->orderBy('clock_time', 'asc')
            ->get();
    }

    public function getMonthStats($userId, $month)
    {
        $startDate = $month . '-01';
        $endDate = date('Y-m-t', strtotime($startDate));

        $records = BizAttendanceRecord::where('user_id', $userId)
            ->whereBetween('attendance_date', [$startDate, $endDate])
            ->get();

        $stats = [
            'normal' => 0,
            'late' => 0,
            'early' => 0,
            'late_and_early' => 0,
            'absent' => 0,
            'rest_days' => 0,
            'leave_days' => 0,
            'holiday_days' => 0,
            'total' => $records->count()
        ];

        foreach ($records as $record) {
            switch ($record->attendance_status) {
                case '0': $stats['normal']++; break;
                case '1': $stats['late']++; break;
                case '2': $stats['early']++; break;
                case '3': $stats['late_and_early']++; break;
                case '4': $stats['absent']++; break;
            }
        }

        // 补充查询请假/休息/法定假日天数（考勤记录不含这些状态）
        $statsService = new \app\service\BizAttendanceStatsService();
        $stats['rest_days'] = $statsService->getRestDaysCount([$userId], $startDate, $endDate)[$userId] ?? 0;
        $stats['leave_days'] = $statsService->getLeaveDaysCount([$userId], $startDate, $endDate)[$userId] ?? 0;
        $stats['holiday_days'] = $statsService->getHolidayDaysCount($startDate, $endDate);
        // 应出勤 = 正常+迟到+早退+迟到早退+缺勤+请假
        $stats['should_attend'] = $stats['normal'] + $stats['late'] + $stats['early']
                                + $stats['late_and_early'] + $stats['absent'] + $stats['leave_days'];

        return $stats;
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000;
        $lat1Rad = deg2rad($lat1);
        $lat2Rad = deg2rad($lat2);
        $deltaLat = deg2rad($lat2 - $lat1);
        $deltaLon = deg2rad($lon2 - $lon1);

        $a = sin($deltaLat / 2) * sin($deltaLat / 2) +
            cos($lat1Rad) * cos($lat2Rad) *
            sin($deltaLon / 2) * sin($deltaLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
