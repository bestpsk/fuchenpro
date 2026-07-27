<?php

namespace app\service;

use app\model\BizLeave;
use app\model\BizLeaveType;
use app\service\DataScopeService;
use support\Db;

/**
 * 休假记录/请假单服务层
 * 处理请假CRUD、审批流程、日历查询（供行程安排集成使用）
 */
class BizLeaveService
{
    /**
     * 分页查询请假单列表
     */
    public function selectList($params = [])
    {
        $query = BizLeave::query()->with('leaveType');

        if (!empty($params['user_name'])) {
            $query->where('user_name', 'like', '%' . $params['user_name'] . '%');
        }
        if (!empty($params['user_id'])) {
            $query->where('user_id', $params['user_id']);
        }
        if (!empty($params['leave_type_id'])) {
            $query->where('leave_type_id', $params['leave_type_id']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['start_date']) && !empty($params['end_date'])) {
            $query->where(function ($q) use ($params) {
                $q->whereBetween('start_date', [$params['start_date'], $params['end_date']])
                  ->orWhereBetween('end_date', [$params['start_date'], $params['end_date']])
                  ->orWhere(function ($q2) use ($params) {
                      $q2->where('start_date', '<=', $params['start_date'])
                         ->where('end_date', '>=', $params['end_date']);
                  });
            });
        }

        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $loginUser = $params['login_user'];
            if (!$loginUser->isAdmin()) {
                // 普通用户只看自己的请假单
                $query->where('user_id', $loginUser->user->user_id);
            }
        }

        $query->orderBy('create_time', 'desc');

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->paginate($pageSize, ['*'], 'page', $pageNum);

        // 附加类型信息
        foreach ($result->items() as $item) {
            if ($item->leaveType) {
                $item->type_name = $item->leaveType->type_name;
                $item->type_code = $item->leaveType->type_code;
                $item->type_color = $item->leaveType->color;
                $item->need_approval = $item->leaveType->need_approval;
            }
        }

        return $result;
    }

    public function selectById($leaveId)
    {
        $leave = BizLeave::with('leaveType')->find($leaveId);
        if ($leave && $leave->leaveType) {
            $leave->type_name = $leave->leaveType->type_name;
            $leave->type_code = $leave->leaveType->type_code;
            $leave->type_color = $leave->leaveType->color;
        }
        return $leave;
    }

    /**
     * 生成请假单号（使用 MAX 提取当天最大序号 +1，避免删除记录后序号重复）
     */
    private function generateLeaveNo()
    {
        $date = date('Ymd');
        $prefix = 'LV' . $date;
        $maxNo = BizLeave::where('leave_no', 'like', $prefix . '%')
            ->orderByRaw('LENGTH(leave_no) DESC, leave_no DESC')
            ->value('leave_no');
        $seq = 1;
        if ($maxNo) {
            $seq = intval(substr($maxNo, -4)) + 1;
        }
        return $prefix . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }

    /**
     * 计算休假天数
     */
    private function calculateLeaveDays($data)
    {
        $startDate = strtotime($data['start_date']);
        $endDate = strtotime($data['end_date']);
        $days = ($endDate - $startDate) / 86400 + 1;

        // 处理半天
        $startTimeType = $data['start_time_type'] ?? '0';
        $endTimeType = $data['end_time_type'] ?? '0';

        if ($days == 1) {
            // 同一天
            if ($startTimeType == '1' && $endTimeType == '2') {
                // 上午到下午 = 半天
                return 0.5;
            } elseif ($startTimeType == '2' && $endTimeType == '1') {
                return 0.5;
            }
            return 1.0;
        }

        // 跨天：第一天可能半天，最后一天可能半天
        $totalDays = $days;
        if ($startTimeType == '1') {
            $totalDays -= 0.5; // 第一天上午开始
        }
        if ($endTimeType == '2') {
            $totalDays -= 0.5; // 最后一天下午结束
        }
        return $totalDays;
    }

    /**
     * 新增请假单
     */
    public function insert($data)
    {
        $leaveTypeId = $data['leave_type_id'] ?? 0;
        $leaveType = BizLeaveType::find($leaveTypeId);
        if (!$leaveType) {
            throw new \Exception('休假类型不存在');
        }

        // 验证重复请假（排除已撤销 status=3 和已拒绝 status=2）
        $overlapping = BizLeave::where('user_id', $data['user_id'])
            ->whereIn('status', ['0', '1'])
            ->where(function ($q) use ($data) {
                $q->whereBetween('start_date', [$data['start_date'], $data['end_date']])
                  ->orWhereBetween('end_date', [$data['start_date'], $data['end_date']])
                  ->orWhere(function ($q2) use ($data) {
                      $q2->where('start_date', '<=', $data['start_date'])
                         ->where('end_date', '>=', $data['end_date']);
                  });
            })
            ->first();
        if ($overlapping) {
            throw new \Exception('该日期范围已有请假记录（' . $overlapping->leave_no . '），不能重复请假');
        }

        // 重试机制：处理并发情况下 leave_no 唯一键冲突
        $maxRetries = 3;
        for ($i = 0; $i < $maxRetries; $i++) {
            $data['leave_no'] = $this->generateLeaveNo();
            $data['leave_days'] = $this->calculateLeaveDays($data);
            // 根据休假类型决定是否需要审批
            if ($leaveType->need_approval == 0) {
                $data['status'] = '1';
                $data['approver_id'] = $data['user_id'];
                $data['approver_name'] = $data['user_name'];
                $data['approve_time'] = date('Y-m-d H:i:s');
                $data['approve_remark'] = '免审批类型，自动通过';
            } else {
                $data['status'] = '0';
            }
            $data['create_time'] = date('Y-m-d H:i:s');
            try {
                return BizLeave::create($data);
            } catch (\Exception $e) {
                if ($i === $maxRetries - 1) {
                    throw $e;
                }
                // 唯一键冲突，重试生成新单号
                continue;
            }
        }
    }

    /**
     * 审核通过
     */
    public function approve($leaveId, $approverId, $approverName, $remark = '')
    {
        $leave = BizLeave::find($leaveId);
        if (!$leave) {
            throw new \Exception('请假单不存在');
        }
        if ($leave->status != '0') {
            throw new \Exception('该请假单不在待审核状态');
        }

        $leave->status = '1';
        $leave->approver_id = $approverId;
        $leave->approver_name = $approverName;
        $leave->approve_time = date('Y-m-d H:i:s');
        $leave->approve_remark = $remark;
        $leave->save();
        return true;
    }

    /**
     * 审核驳回
     */
    public function reject($leaveId, $approverId, $approverName, $remark = '')
    {
        $leave = BizLeave::find($leaveId);
        if (!$leave) {
            throw new \Exception('请假单不存在');
        }
        if ($leave->status != '0') {
            throw new \Exception('该请假单不在待审核状态');
        }

        $leave->status = '2';
        $leave->approver_id = $approverId;
        $leave->approver_name = $approverName;
        $leave->approve_time = date('Y-m-d H:i:s');
        $leave->approve_remark = $remark;
        $leave->save();
        return true;
    }

    /**
     * 撤销请假单（仅待审核状态可撤销）
     */
    public function cancel($leaveId, $userId)
    {
        $leave = BizLeave::find($leaveId);
        if (!$leave) {
            throw new \Exception('请假单不存在');
        }
        if ($leave->user_id != $userId) {
            throw new \Exception('只能撤销自己的请假单');
        }
        if ($leave->status != '0') {
            throw new \Exception('只能撤销待审核的请假单');
        }

        $leave->status = '3';
        $leave->save();
        return true;
    }

    /**
     * 删除请假单
     */
    public function deleteByIds($leaveIds)
    {
        return BizLeave::whereIn('leave_id', $leaveIds)->delete();
    }

    /**
     * 获取员工某月的休假日期列表（供行程安排日历集成使用）
     * 返回格式: {userId: [{date, label, color, type}]}
     */
    public function getLeaveCalendar($userIds, $yearMonth)
    {
        $startDate = $yearMonth . '-01';
        $endDate = date('Y-m-t', strtotime($startDate));

        $leaves = BizLeave::with('leaveType')
            ->whereIn('user_id', $userIds)
            ->where('status', '1') // 已通过
            ->where(function ($q) use ($startDate, $endDate) {
                $q->whereBetween('start_date', [$startDate, $endDate])
                  ->orWhereBetween('end_date', [$startDate, $endDate])
                  ->orWhere(function ($q2) use ($startDate, $endDate) {
                      $q2->where('start_date', '<=', $startDate)
                         ->where('end_date', '>=', $endDate);
                  });
            })
            ->get();

        $result = [];
        foreach ($userIds as $userId) {
            $result[$userId] = [];
        }

        foreach ($leaves as $leave) {
            $userId = $leave->user_id;
            if (!isset($result[$userId])) {
                $result[$userId] = [];
            }

            // 展开日期范围
            $start = max(strtotime($leave->start_date), strtotime($startDate));
            $end = min(strtotime($leave->end_date), strtotime($endDate));

            for ($date = $start; $date <= $end; $date += 86400) {
                $dateStr = date('Y-m-d', $date);
                $result[$userId][] = [
                    'date' => $dateStr,
                    'label' => $leave->leaveType->type_name ?? '休假',
                    'color' => $leave->leaveType->color ?? '#3D6DF7',
                    'type' => $leave->leaveType->type_code ?? 'leave',
                ];
            }
        }

        return $result;
    }

    /**
     * 检查某员工某天是否有已通过休假
     */
    public function hasLeaveOnDate($userId, $date)
    {
        return BizLeave::where('user_id', $userId)
            ->where('status', '1')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->exists();
    }

    /**
     * 获取某员工某天的休假信息
     */
    public function getLeaveOnDate($userId, $date)
    {
        return BizLeave::with('leaveType')
            ->where('user_id', $userId)
            ->where('status', '1')
            ->where('start_date', '<=', $date)
            ->where('end_date', '>=', $date)
            ->first();
    }
}
