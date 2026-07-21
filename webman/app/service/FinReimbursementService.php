<?php

namespace app\service;

use app\model\FinReimbursement;
use app\model\FinReimbursementItem;
use app\service\DataScopeService;

/**
 * 报销服务层，处理报销单的增删改查、审核流程和统计报表
 */
class FinReimbursementService
{
    // 按条件分页查询报销单列表
    public function selectReimbursementList($params = [])
    {
        $query = FinReimbursement::with(['applicant', 'dept']);

        if (!empty($params['applicant_id'])) {
            $query->where('applicant_id', $params['applicant_id']);
        }
        if (!empty($params['applicant_name'])) {
            $query->where('applicant_name', 'like', '%' . $params['applicant_name'] . '%');
        }
        if (!empty($params['dept_id'])) {
            $query->where('dept_id', $params['dept_id']);
        }
        if (!empty($params['category'])) {
            $query->where('category', $params['category']);
        }
        if (!empty($params['expense_type'])) {
            $query->where('expense_type', $params['expense_type']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['apply_date_start'])) {
            $query->where('apply_date', '>=', $params['apply_date_start']);
        }
        if (!empty($params['apply_date_end'])) {
            $query->where('apply_date', '<=', $params['apply_date_end']);
        }
        if (!empty($params['reimbursement_no'])) {
            $query->where('reimbursement_no', 'like', '%' . $params['reimbursement_no'] . '%');
        }
        // 统一关键字搜索（AppV3 传入 keyword，对单号/申请人做 OR 匹配）
        if (!empty($params['keyword'])) {
            $keyword = $params['keyword'];
            $query->where(function ($q) use ($keyword) {
                $q->where('reimbursement_no', 'like', '%' . $keyword . '%')
                  ->orWhere('applicant_name', 'like', '%' . $keyword . '%');
            });
        }
        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('reimbursement_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        return $result;
    }

    // 根据ID查询报销单详情
    public function selectReimbursementById($id)
    {
        return FinReimbursement::with(['items', 'applicant', 'dept'])->find($id);
    }

    // 生成报销单号
    public function generateReimbursementNo()
    {
        $today = date('Ymd');
        $last = FinReimbursement::where('reimbursement_no', 'like', 'BX' . $today . '%')
            ->orderBy('reimbursement_id', 'desc')
            ->first();

        if ($last) {
            $lastSeq = intval(substr($last->reimbursement_no, -4));
            $seq = $lastSeq + 1;
        } else {
            $seq = 1;
        }

        return 'BX' . $today . str_pad($seq, 4, '0', STR_PAD_LEFT);
    }

    // 新增报销单
    public function insertReimbursement($data)
    {
        $data['reimbursement_no'] = $this->generateReimbursementNo();
        $data['status'] = '0';
        $data['create_time'] = date('Y-m-d H:i:s');

        $items = $data['items'] ?? [];
        unset($data['items']);

        $reimbursement = FinReimbursement::create($data);

        if (!empty($items)) {
            $this->syncItems($reimbursement->reimbursement_id, $items);
        }

        return $reimbursement;
    }

    // 更新报销单
    public function updateReimbursement($data)
    {
        $reimbursement = FinReimbursement::find($data['reimbursement_id']);
        if (!$reimbursement) {
            return false;
        }

        if ($reimbursement->status !== '0') {
            return false;
        }

        $items = $data['items'] ?? [];
        unset($data['items']);

        $data['update_time'] = date('Y-m-d H:i:s');

        $fillable = [
            'apply_date', 'category', 'income_amount', 'expense_amount', 'expense_type',
            'voucher_images', 'remark', 'update_by', 'update_time'
        ];
        $updateData = array_intersect_key($data, array_flip($fillable));

        $result = FinReimbursement::where('reimbursement_id', $data['reimbursement_id'])->update($updateData);

        if (!empty($items)) {
            $this->syncItems($data['reimbursement_id'], $items);
        }

        return $result;
    }

    // 同步报销明细
    private function syncItems($reimbursementId, $items)
    {
        FinReimbursementItem::where('reimbursement_id', $reimbursementId)->delete();

        foreach ($items as $item) {
            $item['reimbursement_id'] = $reimbursementId;
            FinReimbursementItem::create($item);
        }
    }

    // 批量删除报销单
    public function deleteReimbursementByIds($ids)
    {
        foreach ($ids as $id) {
            $reimbursement = FinReimbursement::find($id);
            if ($reimbursement && $reimbursement->status !== '0') {
                return false;
            }
        }
        FinReimbursementItem::whereIn('reimbursement_id', $ids)->delete();
        return FinReimbursement::whereIn('reimbursement_id', $ids)->delete();
    }

    // 审核报销单
    public function audit($data)
    {
        $reimbursement = FinReimbursement::find($data['reimbursement_id']);
        if (!$reimbursement || $reimbursement->status !== '0') {
            return false;
        }

        $passed = $data['passed'] ?? true;
        $updateData = [
            'audit_by' => $data['audit_by'] ?? '',
            'audit_time' => date('Y-m-d H:i:s'),
            'audit_remark' => $data['audit_remark'] ?? '',
            'status' => $passed ? '1' : '2',
            'update_time' => date('Y-m-d H:i:s')
        ];

        return FinReimbursement::where('reimbursement_id', $data['reimbursement_id'])->update($updateData);
    }

    // 确认支付
    public function pay($data)
    {
        $reimbursement = FinReimbursement::find($data['reimbursement_id']);
        if (!$reimbursement || $reimbursement->status !== '1') {
            return false;
        }

        $updateData = [
            'pay_by' => $data['pay_by'] ?? '',
            'pay_time' => date('Y-m-d H:i:s'),
            'status' => '3',
            'update_time' => date('Y-m-d H:i:s')
        ];

        return FinReimbursement::where('reimbursement_id', $data['reimbursement_id'])->update($updateData);
    }

    // 按月统计报销金额
    public function reportByMonth($params = [])
    {
        $query = FinReimbursement::selectRaw("
            YEAR(apply_date) as year,
            MONTH(apply_date) as month,
            SUM(expense_amount) as total_expense,
            SUM(income_amount) as total_income,
            COUNT(*) as count
        ")->whereIn('status', ['0', '1', '3']);

        if (!empty($params['apply_date_start']) && !empty($params['apply_date_end'])) {
            $query->whereBetween('apply_date', [$params['apply_date_start'], $params['apply_date_end']]);
        } else {
            $year = $params['year'] ?? date('Y');
            $query->whereYear('apply_date', $year);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        return $query->groupByRaw('DATE_FORMAT(apply_date, "%Y-%m")')->orderBy('year')->orderBy('month')->get();
    }

    // 按分类统计
    public function reportByCategory($params = [])
    {
        $query = FinReimbursement::selectRaw("
            category,
            SUM(expense_amount) as total_expense,
            COUNT(*) as count
        ")->whereIn('status', ['0', '1', '3']);

        if (!empty($params['apply_date_start']) && !empty($params['apply_date_end'])) {
            $query->whereBetween('apply_date', [$params['apply_date_start'], $params['apply_date_end']]);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        return $query->groupBy('category')->get();
    }

    // 按部门统计
    public function reportByDept($params = [])
    {
        $query = FinReimbursement::selectRaw("
            dept_id,
            dept_name,
            SUM(expense_amount) as total_expense,
            COUNT(*) as count
        ")->whereIn('status', ['0', '1', '3'])->whereNotNull('dept_id');

        if (!empty($params['apply_date_start']) && !empty($params['apply_date_end'])) {
            $query->whereBetween('apply_date', [$params['apply_date_start'], $params['apply_date_end']]);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        return $query->groupBy('dept_id', 'dept_name')->orderByDesc('total_expense')->get();
    }

    // 按人员统计
    public function reportByUser($params = [])
    {
        $query = FinReimbursement::selectRaw("
            applicant_id,
            applicant_name,
            SUM(expense_amount) as total_expense,
            COUNT(*) as count
        ")->whereIn('status', ['0', '1', '3']);

        if (!empty($params['apply_date_start']) && !empty($params['apply_date_end'])) {
            $query->whereBetween('apply_date', [$params['apply_date_start'], $params['apply_date_end']]);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        return $query->groupBy('applicant_id', 'applicant_name')->orderByDesc('total_expense')->limit(20)->get();
    }

    // 按支出类型统计
    public function reportByExpenseType($params = [])
    {
        $query = FinReimbursement::selectRaw("
            expense_type,
            SUM(expense_amount) as total_expense,
            COUNT(*) as count
        ")->whereIn('status', ['0', '1', '3']);

        if (!empty($params['apply_date_start']) && !empty($params['apply_date_end'])) {
            $query->whereBetween('apply_date', [$params['apply_date_start'], $params['apply_date_end']]);
        }

        if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
            $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
            $query->whereIn('applicant_id', $visibleUserIds);
        }

        $result = $query->groupBy('expense_type')->get();
        // 转换为驼峰命名以匹配前端 expenseType 字段
        return $result->map(function ($item) {
            return [
                'expenseType' => $item->expense_type,
                'totalExpense' => (float)$item->total_expense,
                'count' => (int)$item->count
            ];
        });
    }
}
