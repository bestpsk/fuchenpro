<?php

namespace app\service;

use app\model\BizHoliday;
use app\model\BizLeaveType;

/**
 * 公共假期日历服务层
 */
class BizHolidayService
{
    /**
     * 分页查询假期列表
     */
    public function selectList($params = [])
    {
        $query = BizHoliday::query()->with('leaveType');

        if (!empty($params['holiday_name'])) {
            $query->where('holiday_name', 'like', '%' . $params['holiday_name'] . '%');
        }
        if (!empty($params['year'])) {
            $query->where('year', $params['year']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $query->orderBy('start_date', 'desc');

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->paginate($pageSize, ['*'], 'page', $pageNum);

        foreach ($result->items() as $item) {
            if ($item->leaveType) {
                $item->type_name = $item->leaveType->type_name;
                $item->leave_type_name = $item->leaveType->type_name;
            }
        }

        return $result;
    }

    public function selectById($holidayId)
    {
        return BizHoliday::with('leaveType')->find($holidayId);
    }

    /**
     * 检查某天是否公共假期
     */
    public function isHoliday($date)
    {
        return BizHoliday::where('status', '0')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->exists();
    }

    /**
     * 获取某天的公共假期信息
     */
    public function getHolidayOnDate($date)
    {
        return BizHoliday::where('status', '0')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->first();
    }

    /**
     * 获取某月的所有公共假期日期列表
     */
    public function getHolidayDatesByMonth($yearMonth)
    {
        $startDate = $yearMonth . '-01';
        $endDate = date('Y-m-t', strtotime($startDate));

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

        $dates = [];
        foreach ($holidays as $holiday) {
            $start = max(strtotime($holiday->start_date), strtotime($startDate));
            $end = min(strtotime($holiday->end_date), strtotime($endDate));
            for ($date = $start; $date <= $end; $date += 86400) {
                $dates[] = date('Y-m-d', $date);
            }
        }
        return $dates;
    }

    public function insert($data)
    {
        $this->checkDateOverlap($data['start_date'], $data['end_date']);
        $data['year'] = $data['year'] ?? date('Y', strtotime($data['start_date']));
        $data['create_time'] = date('Y-m-d H:i:s');
        return BizHoliday::create($data);
    }

    public function update($data)
    {
        if (empty($data['holiday_id'])) {
            throw new \Exception('假期ID不能为空');
        }
        $holiday = BizHoliday::find($data['holiday_id']);
        if (!$holiday) {
            throw new \Exception('假期不存在');
        }
        $this->checkDateOverlap($data['start_date'] ?? $holiday->start_date, $data['end_date'] ?? $holiday->end_date, $data['holiday_id']);
        unset($data['holiday_id']);
        $holiday->fill($data)->save();
        return true;
    }

    /**
     * 检查假期日期范围是否与已有假期重叠
     */
    private function checkDateOverlap($startDate, $endDate, $excludeId = null)
    {
        $query = BizHoliday::where('status', '0')
            ->where(function ($q) use ($startDate, $endDate) {
                $q->whereBetween('start_date', [$startDate, $endDate])
                  ->orWhereBetween('end_date', [$startDate, $endDate])
                  ->orWhere(function ($q2) use ($startDate, $endDate) {
                      $q2->where('start_date', '<=', $startDate)
                         ->where('end_date', '>=', $endDate);
                  });
            });
        if ($excludeId) {
            $query->where('holiday_id', '!=', $excludeId);
        }
        if ($query->exists()) {
            throw new \Exception('假期日期范围与已有假期重叠');
        }
    }

    public function deleteByIds($holidayIds)
    {
        return BizHoliday::whereIn('holiday_id', $holidayIds)->delete();
    }
}
