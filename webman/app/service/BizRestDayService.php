<?php

namespace app\service;

use app\model\BizRestDay;
use app\model\BizRestPlan;
use app\model\BizLeave;
use app\model\BizLeaveType;
use app\model\BizHoliday;
use app\model\BizSchedule;
use support\Db;

/**
 * 统一休息日服务
 * 管理所有类型的休息日：custom(自定义) / plan(方案按日期) / leave(请假通过)
 * 合并查询时只需查 biz_rest_day + biz_rest_plan(按周) + biz_holiday 三个数据源
 */
class BizRestDayService
{
    /** 自定义休息日默认颜色 */
    const COLOR_CUSTOM = '#00B42A';
    /** 方案休息日默认颜色 */
    const COLOR_PLAN = '#3D6DF7';
    /** 请假默认颜色 */
    const COLOR_LEAVE = '#FF9900';
    /** 法定假日颜色 */
    const COLOR_HOLIDAY = '#F53F3F';

    /**
     * 保存自定义休息日（排班设置弹窗调用）
     * 先删除该用户所有 source='custom' 的记录，再批量插入
     * 验证：typeId 必填（移除"自定义"默认类型）、日期冲突检查（行程+其他来源休息日）
     */
    public function saveCustomRestDates($userId, $restDates)
    {
        // 兼容旧格式：字符串数组转为对象数组（旧数据无类型，回退为空typeName）
        $normalized = [];
        foreach ($restDates as $item) {
            if (is_string($item)) {
                $normalized[] = ['date' => $item, 'typeId' => null, 'typeName' => ''];
            } elseif (is_array($item) && isset($item['date'])) {
                $normalized[] = [
                    'date' => $item['date'],
                    'typeId' => $item['typeId'] ?? null,
                    'typeName' => $item['typeName'] ?? ''
                ];
            }
        }
        // 去重
        $unique = [];
        $seen = [];
        foreach ($normalized as $item) {
            if (!in_array($item['date'], $seen)) {
                $seen[] = $item['date'];
                $unique[] = $item;
            }
        }

        // 验证：每条记录必须选择休假类型
        foreach ($unique as $item) {
            if (empty($item['typeId'])) {
                throw new \Exception('请为日期 ' . $item['date'] . ' 选择休息日类型（如需新类型请到休假管理-休假类型添加）');
            }
            // 补充 typeName（前端可能只传了 typeId）
            if (empty($item['typeName'])) {
                $type = BizLeaveType::find($item['typeId']);
                $item['typeName'] = $type ? $type->type_name : '未知类型';
            }
        }

        // 冲突检查：行程 + 其他来源休息日（排除 custom 自身，因为先删后插）
        $dates = array_column($unique, 'date');
        $conflicts = $this->checkConflicts($userId, $dates, 'custom');
        if (!empty($conflicts)) {
            $messages = array_map(fn($c) => $c['date'] . '(' . $c['reason'] . ')', $conflicts);
            throw new \Exception('以下日期无法设置休息日，存在冲突：' . implode('、', $messages));
        }

        // 查询休假类型颜色
        $typeColors = $this->getTypeColorMap();

        Db::beginTransaction();
        try {
            BizRestDay::where('user_id', $userId)->where('source_type', 'custom')->delete();
            $now = date('Y-m-d H:i:s');
            $rows = [];
            foreach ($unique as $item) {
                $typeId = $item['typeId'] ?? null;
                $rows[] = [
                    'user_id' => $userId,
                    'rest_date' => $item['date'],
                    'source_type' => 'custom',
                    'source_id' => null,
                    'type_id' => $typeId,
                    'type_name' => $item['typeName'],
                    'color' => $typeColors[$typeId] ?? self::COLOR_CUSTOM,
                    'create_time' => $now,
                ];
            }
            if (!empty($rows)) {
                BizRestDay::insert($rows);
            }
            Db::commit();
            return true;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 保存方案按日期休息日（休假管理按日期模式调用）
     * 为每个员工×每个日期生成一条记录
     */
    public function savePlanRestDates($planId, $userIds, $dates, $typeName = '方案休息')
    {
        Db::beginTransaction();
        try {
            BizRestDay::where('source_type', 'plan')->where('source_id', $planId)->delete();
            $now = date('Y-m-d H:i:s');
            $rows = [];
            foreach ($userIds as $uid) {
                foreach ($dates as $date) {
                    $rows[] = [
                        'user_id' => $uid,
                        'rest_date' => $date,
                        'source_type' => 'plan',
                        'source_id' => $planId,
                        'type_id' => null,
                        'type_name' => $typeName,
                        'color' => self::COLOR_PLAN,
                        'create_time' => $now,
                    ];
                }
            }
            if (!empty($rows)) {
                BizRestDay::insert($rows);
            }
            Db::commit();
            return true;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 删除方案按日期休息日
     */
    public function removePlanRestDates($planId)
    {
        return BizRestDay::where('source_type', 'plan')->where('source_id', $planId)->delete();
    }

    /**
     * 请假审批通过时生成休息日记录
     * 验证：日期冲突检查（行程+其他来源休息日），排除当前 leave 自身
     */
    public function generateLeaveRestDates($leaveId)
    {
        $leave = BizLeave::with('leaveType')->find($leaveId);
        if (!$leave || $leave->status !== '1') return false;

        $start = strtotime($leave->start_date);
        $end = strtotime($leave->end_date);

        // 冲突检查：行程 + 其他来源休息日（排除当前 leave 自身）
        $dates = [];
        for ($d = $start; $d <= $end; $d += 86400) {
            $dates[] = date('Y-m-d', $d);
        }
        $conflicts = $this->checkConflicts($leave->user_id, $dates, 'leave', $leaveId);
        if (!empty($conflicts)) {
            $messages = array_map(fn($c) => $c['date'] . '(' . $c['reason'] . ')', $conflicts);
            throw new \Exception('请假日期存在冲突，无法审批通过：' . implode('、', $messages) . '。请先处理冲突行程或休息日');
        }

        // 先删除旧的（防止重复）
        $this->removeLeaveRestDates($leaveId);

        $typeId = $leave->leave_type_id;
        $typeName = $leave->leaveType->type_name ?? '请假';
        $color = $leave->leaveType->color ?? self::COLOR_LEAVE;
        $now = date('Y-m-d H:i:s');

        $rows = [];
        for ($d = $start; $d <= $end; $d += 86400) {
            $rows[] = [
                'user_id' => $leave->user_id,
                'rest_date' => date('Y-m-d', $d),
                'source_type' => 'leave',
                'source_id' => $leaveId,
                'type_id' => $typeId,
                'type_name' => $typeName,
                'color' => $color,
                'create_time' => $now,
            ];
        }
        if (!empty($rows)) {
            BizRestDay::insert($rows);
        }
        return true;
    }

    /**
     * 请假撤销/拒绝时删除休息日记录
     */
    public function removeLeaveRestDates($leaveId)
    {
        return BizRestDay::where('source_type', 'leave')->where('source_id', $leaveId)->delete();
    }

    /**
     * 获取员工自定义休息日（排班设置弹窗回显用）
     */
    public function getCustomRestDates($userId)
    {
        $rows = BizRestDay::where('user_id', $userId)
            ->where('source_type', 'custom')
            ->orderBy('rest_date')
            ->get();
        $result = [];
        foreach ($rows as $row) {
            $result[] = [
                'date' => $row->rest_date,
                'typeId' => $row->type_id,
                'typeName' => $row->type_name
            ];
        }
        return $result;
    }

    /**
     * 检查休息日冲突（行程 + 已有休息日）
     * @param int $userId
     * @param array $dates 日期数组 ['2026-07-01', ...]
     * @param string|null $excludeSource 排除的来源类型（如 'custom' 表示不检查自定义来源）
     * @param int|null $excludeSourceId 排除的来源ID（如 leave_id，避免检查自身）
     * @return array 冲突日期列表 [{date, reason}]
     */
    public function checkConflicts($userId, $dates, $excludeSource = null, $excludeSourceId = null)
    {
        if (empty($dates)) return [];

        $conflicts = [];

        // 检查1：biz_schedule 表是否有该员工该日期的行程
        $schedules = BizSchedule::where('user_id', $userId)
            ->whereIn('schedule_date', $dates)
            ->pluck('schedule_date')
            ->toArray();
        foreach ($schedules as $date) {
            $conflicts[] = ['date' => $date, 'reason' => '已有行程安排'];
        }

        // 检查2：biz_rest_day 表是否有其他来源的休息日
        $query = BizRestDay::where('user_id', $userId)
            ->whereIn('rest_date', $dates);
        if ($excludeSource) {
            $query->where('source_type', '!=', $excludeSource);
        }
        if ($excludeSourceId !== null) {
            // 排除 (source_id=excludeSourceId AND source_type=excludeSource) 的记录（即排除自身）
            // 注意：此时若 $excludeSource 已通过上面 where('source_type', '!=', ...) 排除，此条件不会生效
            // 若未传 $excludeSource（仅传 excludeSourceId），则排除指定 source_id 的记录
            $query->whereNot(function ($q2) use ($excludeSource, $excludeSourceId) {
                $q2->where('source_id', $excludeSourceId);
                if ($excludeSource) {
                    $q2->where('source_type', $excludeSource);
                }
            });
        }
        $existingRestDays = $query->get(['rest_date', 'source_type', 'type_name']);
        foreach ($existingRestDays as $rd) {
            $sourceLabel = ['custom' => '配置休息日', 'plan' => '休假方案', 'leave' => '请假'][$rd->source_type] ?? '休息日';
            $conflicts[] = ['date' => $rd->rest_date, 'reason' => '已有' . $sourceLabel . '(' . $rd->type_name . ')'];
        }

        // 去重（同一日期可能有多个冲突）
        $unique = [];
        $seen = [];
        foreach ($conflicts as $c) {
            if (!in_array($c['date'], $seen)) {
                $seen[] = $c['date'];
                $unique[] = $c;
            }
        }
        return $unique;
    }

    /**
     * 批量获取多员工某月所有休息日（含custom/plan/leave + 按周方案 + 法定假日）
     * 统一入口，替代原 getAllRestDatesBatch 的4源合并逻辑
     * @param bool $returnDefaultRest 是否对未配置方案的员工返回默认周末休息
     *                                - false（默认）：未配置则返回空，用于行程安排/配置弹窗
     *                                - true：未配置则返回默认周六日休息，用于"我的考勤"等用户视角页面
     * @param array|null $dateRange 自定义日期范围 ['start' => 'Y-m-d', 'end' => 'Y-m-d']
     *                               - 为 null 时按 $yearMonth 计算单月范围（默认行为）
     *                               - 传入时覆盖单月范围，用于配置弹窗跨月查看
     */
    public function getRestDatesBatch($userIds, $yearMonth, $returnDefaultRest = false, $dateRange = null)
    {
        if (empty($userIds)) return [];

        // 支持自定义日期范围（跨月），默认按单月计算
        if ($dateRange && !empty($dateRange['start']) && !empty($dateRange['end'])) {
            $startDate = $dateRange['start'];
            $endDate = $dateRange['end'];
        } else {
            $startDate = $yearMonth . '-01';
            $endDate = date('Y-m-t', strtotime($startDate));
        }

        // 1. 查询 biz_rest_day（一次SQL搞定custom+plan+leave）
        $restDays = BizRestDay::whereIn('user_id', $userIds)
            ->whereBetween('rest_date', [$startDate, $endDate])
            ->get();
        $restDayMap = []; // {userId: {dateStr: {type, typeName, color, typeId}}}
        foreach ($restDays as $rd) {
            // 优先级：holiday > leave > plan > custom（同一日期不覆盖已有记录）
            $priority = ['custom' => 1, 'plan' => 2, 'leave' => 3];
            $existing = $restDayMap[$rd->user_id][$rd->rest_date] ?? null;
            if (!$existing || ($priority[$rd->source_type] ?? 0) > ($priority[$existing['source_type']] ?? 0)) {
                $restDayMap[$rd->user_id][$rd->rest_date] = [
                    'date' => $rd->rest_date,
                    'type' => $rd->source_type,
                    'typeName' => $rd->type_name,
                    'color' => $rd->color,
                    'typeId' => $rd->type_id,
                ];
            }
        }

        // 2. 查询 biz_rest_plan 按周模板（动态生成日期）
        $restPlanService = new BizRestPlanService();
        if ($dateRange) {
            $weeklyResult = $restPlanService->getRestDatesByRange($userIds, $startDate, $endDate, $returnDefaultRest);
        } else {
            $weeklyResult = $restPlanService->getRestDatesByMonth($userIds, $yearMonth, $returnDefaultRest);
        }
        $weeklyMap = [];
        foreach ($weeklyResult as $item) {
            $uid = $item['userId'] ?? null;
            if ($uid) {
                $weeklyMap[$uid] = $item['restDates'] ?? [];
            }
        }

        // 3. 查询 biz_holiday 法定假日
        $holidays = BizHoliday::where('status', '0')
            ->where(function ($q) use ($startDate, $endDate) {
                $q->whereBetween('start_date', [$startDate, $endDate])
                  ->orWhereBetween('end_date', [$startDate, $endDate])
                  ->orWhere(function ($q2) use ($startDate, $endDate) {
                      $q2->where('start_date', '<=', $startDate)
                         ->where('end_date', '>=', $endDate);
                  });
            })
            ->get();
        $holidayDates = [];
        foreach ($holidays as $holiday) {
            $start = max(strtotime($holiday->start_date), strtotime($startDate));
            $end = min(strtotime($holiday->end_date), strtotime($endDate));
            for ($d = $start; $d <= $end; $d += 86400) {
                $dateStr = date('Y-m-d', $d);
                $holidayDates[$dateStr] = $holiday->holiday_name;
            }
        }

        // 4. 按员工合并
        $result = [];
        foreach ($userIds as $userId) {
            $allDates = [];

            // 按周模板（优先级最低）
            foreach (($weeklyMap[$userId] ?? []) as $date) {
                $allDates[$date] = ['date' => $date, 'type' => 'weekly', 'typeName' => '轮休', 'color' => self::COLOR_PLAN];
            }
            // biz_rest_day 中的记录（覆盖按周）
            foreach (($restDayMap[$userId] ?? []) as $date => $info) {
                $allDates[$date] = $info;
            }
            // 法定假日（优先级最高）
            foreach ($holidayDates as $date => $name) {
                $allDates[$date] = ['date' => $date, 'type' => 'holiday', 'typeName' => $name, 'color' => self::COLOR_HOLIDAY];
            }

            ksort($allDates);
            $dates = array_values($allDates);

            // 类型汇总
            $typeCount = [];
            foreach ($dates as $item) {
                $type = $item['type'];
                if (!isset($typeCount[$type])) {
                    $typeCount[$type] = ['type' => $type, 'name' => $item['typeName'], 'color' => $item['color'], 'count' => 0];
                }
                $typeCount[$type]['count']++;
            }

            $result[] = [
                'userId' => $userId,
                'dates' => $dates,
                'typeList' => array_values($typeCount)
            ];
        }

        return $result;
    }

    /**
     * 获取单个员工某月所有休息日
     * @param bool $returnDefaultRest 默认 true（我的考勤页保留默认周末休息）
     */
    public function getAllRestDates($userId, $yearMonth, $returnDefaultRest = true)
    {
        $batch = $this->getRestDatesBatch([$userId], $yearMonth, $returnDefaultRest);
        if (!empty($batch)) {
            $data = $batch[0];
            return [
                'dates' => $data['dates'],
                'typeList' => $data['typeList'],
                'yearMonth' => $yearMonth
            ];
        }
        return ['dates' => [], 'typeList' => [], 'yearMonth' => $yearMonth];
    }

    /**
     * 获取单个员工全部休息日（不限月份，覆盖 2年前~1年后范围）
     * 用于配置休息日弹窗跨月查看和回显已存日期
     * @param bool $returnDefaultRest 默认 false（配置弹窗不返回默认周末）
     */
    public function getAllRestDatesAll($userId, $returnDefaultRest = false)
    {
        // 2年前 ~ 1年后，与 AppV3 日历可导航范围一致
        $startDate = date('Y-m-01', strtotime('-2 years'));
        $endDate = date('Y-m-t', strtotime('+1 year'));

        $batch = $this->getRestDatesBatch([$userId], null, $returnDefaultRest, [
            'start' => $startDate,
            'end' => $endDate,
        ]);
        if (!empty($batch)) {
            $data = $batch[0];
            return [
                'dates' => $data['dates'],
                'typeList' => $data['typeList'],
            ];
        }
        return ['dates' => [], 'typeList' => []];
    }

    /**
     * 获取休假类型颜色映射
     */
    private function getTypeColorMap()
    {
        return BizLeaveType::pluck('color', 'type_id')->toArray();
    }
}
