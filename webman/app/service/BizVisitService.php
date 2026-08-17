<?php

namespace app\service;

use app\model\BizVisitTemplate;
use app\model\BizVisitTemplateItem;
use app\model\BizVisitTask;
use app\model\BizVisitAnswer;
use app\model\BizEnterprise;
use app\service\DataScopeService;
use support\Db;
use support\Log;

/**
 * 满意度回访服务层
 * 支持员工填写和H5链接填写两种模式，含问卷模板管理、满意度统计
 * 数据可见范围以 sys_role.data_scope 为依据，复用 DataScopeService
 */
class BizVisitService
{
    // token 默认有效期（天）
    const TOKEN_TTL_DAYS = 7;

    // ==================== 模板管理 ====================

    /**
     * 分页查询模板列表
     */
    public function selectTemplateList($params = [])
    {
        $query = BizVisitTemplate::query();

        if (!empty($params['template_name'])) {
            $query->where('template_name', 'like', '%' . $params['template_name'] . '%');
        }
        if (!empty($params['visit_type'])) {
            $query->where('visit_type', $params['visit_type']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->withCount('items')->orderBy('template_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    /**
     * 模板详情（含题目列表）
     */
    public function selectTemplateById($templateId)
    {
        $template = BizVisitTemplate::find($templateId);
        if (!$template) return null;

        $items = BizVisitTemplateItem::where('template_id', $templateId)
            ->orderBy('sort_order', 'asc')
            ->get()
            ->toArray();

        // options JSON 解码
        foreach ($items as &$item) {
            if (!empty($item['options'])) {
                $item['options'] = json_decode($item['options'], true) ?: [];
            } else {
                $item['options'] = [];
            }
        }

        return [
            'template' => $template,
            'items' => $items,
        ];
    }

    /**
     * 新增模板+题目（事务）
     * @param array $data 模板数据
     * @param array $items 题目列表 [{question_title, question_type, options, sort_order, required}]
     */
    public function insertTemplate($data, $items = [])
    {
        $now = date('Y-m-d H:i:s');
        $data['create_time'] = $now;

        Db::beginTransaction();
        try {
            $template = BizVisitTemplate::create($data);

            if (!empty($items)) {
                $this->syncTemplateItems($template->template_id, $items, $now);
            }

            Db::commit();
            return $template;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 修改模板+题目（事务，先删后插题目）
     */
    public function updateTemplate($data, $items = [])
    {
        $templateId = intval($data['template_id'] ?? 0);
        $template = BizVisitTemplate::find($templateId);
        if (!$template) {
            throw new \RuntimeException('模板不存在');
        }

        $now = date('Y-m-d H:i:s');
        $data['update_time'] = $now;

        Db::beginTransaction();
        try {
            $template->fill($data)->save();

            // 先删后插题目
            BizVisitTemplateItem::where('template_id', $templateId)->delete();
            if (!empty($items)) {
                $this->syncTemplateItems($templateId, $items, $now);
            }

            Db::commit();
            return $template;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 删除模板（校验是否被任务引用）
     */
    public function deleteTemplateByIds($ids)
    {
        $ids = array_map('intval', (array)$ids);

        // 校验是否被回访任务引用
        $usedCount = BizVisitTask::whereIn('template_id', $ids)->count();
        if ($usedCount > 0) {
            throw new \RuntimeException('该模板已被回访任务引用，无法删除');
        }

        Db::beginTransaction();
        try {
            BizVisitTemplateItem::whereIn('template_id', $ids)->delete();
            $result = BizVisitTemplate::whereIn('template_id', $ids)->delete();
            Db::commit();
            return $result;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 同步模板题目（批量插入）
     */
    private function syncTemplateItems($templateId, $items, $now)
    {
        $rows = [];
        foreach ($items as $idx => $item) {
            $options = $item['options'] ?? null;
            if (is_array($options)) {
                $options = json_encode($options, JSON_UNESCAPED_UNICODE);
            }
            $rows[] = [
                'template_id' => $templateId,
                'question_title' => $item['question_title'] ?? '',
                'question_type' => $item['question_type'] ?? '4',
                'options' => $options,
                'sort_order' => $item['sort_order'] ?? $idx,
                'required' => $item['required'] ?? '0',
                'create_time' => $now,
            ];
        }
        if (!empty($rows)) {
            // 分批插入避免超限
            foreach (array_chunk($rows, 100) as $chunk) {
                BizVisitTemplateItem::insert($chunk);
            }
        }
    }

    // ==================== 回访任务管理 ====================

    /**
     * 分页查询回访任务列表（含数据权限过滤）
     */
    public function selectVisitList($params = [])
    {
        $query = BizVisitTask::query()->where('del_flag', '0');

        if (!empty($params['enterprise_name'])) {
            $query->where('enterprise_name', 'like', '%' . $params['enterprise_name'] . '%');
        }
        if (!empty($params['enterprise_id'])) {
            $query->where('enterprise_id', intval($params['enterprise_id']));
        }
        if (!empty($params['visit_type'])) {
            $query->where('visit_type', $params['visit_type']);
        }
        if (!empty($params['visit_mode'])) {
            $query->where('visit_mode', $params['visit_mode']);
        }
        if (isset($params['visit_status']) && $params['visit_status'] !== '') {
            $query->where('visit_status', $params['visit_status']);
        }
        if (!empty($params['template_id'])) {
            $query->where('template_id', intval($params['template_id']));
        }
        if (!empty($params['visitor_user_id'])) {
            $query->where('visitor_user_id', intval($params['visitor_user_id']));
        }
        if (!empty($params['start_date'])) {
            $query->where('create_time', '>=', $params['start_date'] . ' 00:00:00');
        }
        if (!empty($params['end_date'])) {
            $query->where('create_time', '<=', $params['end_date'] . ' 23:59:59');
        }

        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $this->applyVisitScope($query, $params['login_user']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('visit_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    /**
     * 数据权限过滤
     * 可见范围 = 我创建的回访任务 OR 归属我管辖企业的回访任务
     */
    public function applyVisitScope($query, $loginUser)
    {
        if (empty($loginUser) || $loginUser->isAdmin()) {
            return $query;
        }

        $visibleUserIds = DataScopeService::getVisibleUserIds($loginUser);
        $myUserId = $loginUser->userId;

        // 我管辖的企业IDs（通过 biz_enterprise.server_user_id FIND_IN_SET）
        $myEnterpriseIds = BizEnterprise::where(function ($q) use ($visibleUserIds) {
            foreach ($visibleUserIds as $uid) {
                $q->orWhereRaw('FIND_IN_SET(?, server_user_id)', [$uid]);
            }
        })->pluck('enterprise_id')->toArray();

        $query->where(function ($q) use ($visibleUserIds, $myUserId, $myEnterpriseIds) {
            // 我创建的回访任务
            $q->whereIn('visitor_user_id', $visibleUserIds)
              // 我管辖企业的回访任务
              ->orWhereIn('enterprise_id', $myEnterpriseIds);
        });

        return $query;
    }

    /**
     * 回访任务详情（含模板题目+已填答案）
     */
    public function selectVisitById($visitId)
    {
        $task = BizVisitTask::find($visitId);
        if (!$task) return null;

        // 获取模板题目（含options解码）
        $items = BizVisitTemplateItem::where('template_id', $task->template_id)
            ->orderBy('sort_order', 'asc')
            ->get()
            ->toArray();

        foreach ($items as &$item) {
            if (!empty($item['options'])) {
                $item['options'] = json_decode($item['options'], true) ?: [];
            } else {
                $item['options'] = [];
            }
        }

        // 获取已填答案，按 item_id 索引
        $answers = BizVisitAnswer::where('visit_id', $visitId)
            ->get()
            ->keyBy('item_id')
            ->toArray();

        return [
            'task' => $task,
            'items' => $items,
            'answers' => $answers,
        ];
    }

    /**
     * 新增回访任务
     * 模式1(员工填写)：直接创建任务，可附带答案
     * 模式2(H5链接)：创建任务+生成token+设置过期时间
     */
    public function insertVisit($data, $answers = [])
    {
        $now = date('Y-m-d H:i:s');
        $data['create_time'] = $now;

        // 冗余回访类型（从模板获取）
        if (!empty($data['template_id'])) {
            $template = BizVisitTemplate::find($data['template_id']);
            if ($template) {
                $data['visit_type'] = $template->visit_type;
            }
        }

        // H5链接模式：生成token
        if (($data['visit_mode'] ?? '1') === '2') {
            $data['visit_token'] = bin2hex(random_bytes(16));
            $data['token_expire_time'] = date('Y-m-d H:i:s', strtotime('+' . self::TOKEN_TTL_DAYS . ' days'));
        }

        // 员工填写模式且附带答案：标记为已完成
        $hasAnswers = !empty($answers);
        if (($data['visit_mode'] ?? '1') === '1' && $hasAnswers) {
            $data['visit_status'] = '1';
            $data['visit_time'] = $now;
        }

        Db::beginTransaction();
        try {
            $task = BizVisitTask::create($data);

            // 保存答案（员工填写模式）
            if ($hasAnswers) {
                $this->saveAnswers($task->visit_id, $task->template_id, $answers, $now);
                // 计算满意度评分
                $score = $this->calculateSatisfactionScore($task->visit_id);
                if ($score !== null) {
                    $task->satisfaction_score = $score;
                    $task->save();
                }
            }

            Db::commit();
            return $task;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 修改回访任务（可选更新答案）
     * @param array $data 任务数据
     * @param array|null $answers 答案列表（null=不更新答案，[]清空答案，非空=更新答案）
     */
    public function updateVisit($data, $answers = null)
    {
        $visitId = intval($data['visit_id'] ?? 0);
        $task = BizVisitTask::find($visitId);
        if (!$task) {
            throw new \RuntimeException('回访任务不存在');
        }

        $now = date('Y-m-d H:i:s');
        $data['update_time'] = $now;

        Db::beginTransaction();
        try {
            $task->fill($data)->save();

            // 如果传了 answers，更新答案（先删后插 + 重新计算满意度）
            if ($answers !== null) {
                BizVisitAnswer::where('visit_id', $visitId)->delete();
                if (!empty($answers)) {
                    $this->saveAnswers($visitId, $task->template_id, $answers, $now);
                }
                // 重新计算满意度
                $score = $this->calculateSatisfactionScore($visitId);
                $task->satisfaction_score = $score;
                // 员工填写模式下有答案且未标记完成，标记为已完成
                if (!empty($answers) && $task->visit_status === '0' && $task->visit_mode === '1') {
                    $task->visit_status = '1';
                    $task->visit_time = $now;
                }
                $task->save();
            }

            Db::commit();
            return $task;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 软删除回访任务
     */
    public function deleteVisitByIds($ids)
    {
        $ids = array_map('intval', (array)$ids);
        return BizVisitTask::whereIn('visit_id', $ids)->update(['del_flag' => '2', 'update_time' => date('Y-m-d H:i:s')]);
    }

    /**
     * 为已有任务生成/刷新H5链接token
     */
    public function generateLink($visitId)
    {
        $task = BizVisitTask::find($visitId);
        if (!$task) {
            throw new \RuntimeException('回访任务不存在');
        }

        $task->visit_token = bin2hex(random_bytes(16));
        $task->token_expire_time = date('Y-m-d H:i:s', strtotime('+' . self::TOKEN_TTL_DAYS . ' days'));
        $task->visit_mode = '2'; // 确保为H5模式
        if ($task->visit_status === '2') {
            $task->visit_status = '0'; // 已取消的重新激活为待回访
        }
        $task->update_time = date('Y-m-d H:i:s');
        $task->save();

        return $task;
    }

    // ==================== H5公共接口 ====================

    /**
     * 根据token获取H5表单数据（模板题目+企业信息，不含敏感数据）
     */
    public function getPublicForm($token)
    {
        $task = BizVisitTask::where('visit_token', $token)->where('del_flag', '0')->first();
        if (!$task) {
            throw new \RuntimeException('回访问卷不存在');
        }

        // 校验token是否过期
        if ($task->token_expire_time && strtotime($task->token_expire_time) < time()) {
            throw new \RuntimeException('回访问卷链接已过期，请联系服务人员重新发送');
        }

        // 校验是否已填写
        if ($task->visit_status === '1') {
            throw new \RuntimeException('该回访问卷已填写完成');
        }

        // 获取模板题目
        $items = BizVisitTemplateItem::where('template_id', $task->template_id)
            ->orderBy('sort_order', 'asc')
            ->get()
            ->toArray();

        foreach ($items as &$item) {
            if (!empty($item['options'])) {
                $item['options'] = json_decode($item['options'], true) ?: [];
            } else {
                $item['options'] = [];
            }
        }

        $template = BizVisitTemplate::find($task->template_id);

        return [
            'visit_id' => $task->visit_id,
            'enterprise_name' => $task->enterprise_name,
            'template_name' => $template ? $template->template_name : '',
            'description' => $template ? $template->description : '',
            'items' => $items,
            'contact_name' => $task->contact_name,
            'contact_phone' => $task->contact_phone,
        ];
    }

    /**
     * H5公共提交（校验token，保存答案，计算满意度，更新状态）
     * @param string $token H5链接token
     * @param array $answers 答案列表 [{item_id, answer_value, answer_text}]
     * @param array $contactInfo 企业负责人信息 {contact_name, contact_phone}
     */
    public function submitVisitForm($token, $answers, $contactInfo = [])
    {
        $task = BizVisitTask::where('visit_token', $token)->where('del_flag', '0')->first();
        if (!$task) {
            throw new \RuntimeException('回访问卷不存在');
        }

        // 校验token是否过期
        if ($task->token_expire_time && strtotime($task->token_expire_time) < time()) {
            throw new \RuntimeException('回访问卷链接已过期，请联系服务人员重新发送');
        }

        // 校验是否已填写
        if ($task->visit_status === '1') {
            throw new \RuntimeException('该回访问卷已填写完成，请勿重复提交');
        }

        $now = date('Y-m-d H:i:s');

        // 校验必填题
        $this->validateRequiredAnswers($task->template_id, $answers);

        Db::beginTransaction();
        try {
            // 保存答案
            $this->saveAnswers($task->visit_id, $task->template_id, $answers, $now);

            // 更新任务状态
            $task->visit_status = '1';
            $task->visit_time = $now;
            if (!empty($contactInfo['contact_name'])) {
                $task->contact_name = $contactInfo['contact_name'];
            }
            if (!empty($contactInfo['contact_phone'])) {
                $task->contact_phone = $contactInfo['contact_phone'];
            }

            // 计算满意度评分
            $score = $this->calculateSatisfactionScore($task->visit_id);
            if ($score !== null) {
                $task->satisfaction_score = $score;
            }

            $task->update_time = $now;
            $task->save();

            Db::commit();
            return $task;
        } catch (\Throwable $e) {
            Db::rollBack();
            throw $e;
        }
    }

    /**
     * 校验必填题是否已作答
     */
    private function validateRequiredAnswers($templateId, $answers)
    {
        $requiredItems = BizVisitTemplateItem::where('template_id', $templateId)
            ->where('required', '0')
            ->get();

        $answerMap = [];
        foreach ($answers as $ans) {
            $itemId = $ans['item_id'] ?? 0;
            $answerMap[$itemId] = $ans;
        }

        foreach ($requiredItems as $item) {
            $ans = $answerMap[$item->item_id] ?? null;
            $value = $ans['answer_value'] ?? '';
            $text = $ans['answer_text'] ?? '';
            if (empty($value) && empty($text)) {
                throw new \RuntimeException('题目"' . $item->question_title . '"为必填项，请完成填写');
            }
        }
    }

    /**
     * 保存答案（冗余题目内容和题型）
     */
    private function saveAnswers($visitId, $templateId, $answers, $now)
    {
        // 获取模板题目信息用于冗余
        $items = BizVisitTemplateItem::where('template_id', $templateId)
            ->get()
            ->keyBy('item_id');

        $rows = [];
        foreach ($answers as $ans) {
            $itemId = intval($ans['item_id'] ?? 0);
            $item = $items->get($itemId);
            if (!$item) continue;

            // 多选题答案转为逗号分隔
            $answerValue = $ans['answer_value'] ?? '';
            if (is_array($answerValue)) {
                $answerValue = implode(',', $answerValue);
            }

            $rows[] = [
                'visit_id' => $visitId,
                'item_id' => $itemId,
                'question_title' => $item->question_title,
                'question_type' => $item->question_type,
                'answer_value' => $answerValue,
                'answer_text' => $ans['answer_text'] ?? null,
                'create_time' => $now,
            ];
        }

        if (!empty($rows)) {
            BizVisitAnswer::insert($rows);
        }
    }

    /**
     * 计算满意度评分（取所有评分题答案的平均值，1-5分制）
     */
    public function calculateSatisfactionScore($visitId)
    {
        $answers = BizVisitAnswer::where('visit_id', $visitId)
            ->where('question_type', '3') // 评分题
            ->get();

        if ($answers->isEmpty()) {
            return null;
        }

        $sum = 0;
        $count = 0;
        foreach ($answers as $ans) {
            $val = floatval($ans->answer_value);
            if ($val > 0) {
                $sum += $val;
                $count++;
            }
        }

        return $count > 0 ? round($sum / $count, 1) : null;
    }

    // ==================== 满意度统计 ====================

    /**
     * 满意度统计（按企业分组）
     * @param array $params 筛选条件(visit_type/start_date/end_date/login_user)
     */
    public function selectVisitStats($params = [])
    {
        $query = BizVisitTask::query()
            ->where('del_flag', '0')
            ->where('visit_status', '1'); // 只统计已完成的

        if (!empty($params['visit_type'])) {
            $query->where('visit_type', $params['visit_type']);
        }
        if (!empty($params['start_date'])) {
            $query->where('visit_time', '>=', $params['start_date'] . ' 00:00:00');
        }
        if (!empty($params['end_date'])) {
            $query->where('visit_time', '<=', $params['end_date'] . ' 23:59:59');
        }

        // 数据权限过滤
        if (!empty($params['login_user'])) {
            $this->applyVisitScope($query, $params['login_user']);
        }

        // 按企业分组统计
        $stats = $query->select(
                'enterprise_id',
                'enterprise_name',
                Db::raw('COUNT(*) as total_count'),
                Db::raw('AVG(satisfaction_score) as avg_score'),
                Db::raw('SUM(CASE WHEN satisfaction_score >= 4 THEN 1 ELSE 0 END) as satisfied_count')
            )
            ->groupBy('enterprise_id', 'enterprise_name')
            ->orderByDesc('avg_score')
            ->get()
            ->toArray();

        return $stats;
    }
}
