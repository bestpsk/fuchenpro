<?php

namespace app\service;

use app\model\SysJob;
use app\model\SysJobLog;

/**
 * 定时任务服务层，处理定时任务的增删改查、状态变更和立即执行
 */
class SysJobService
{
    // 按条件分页查询定时任务列表
    public function selectJobList($params = [])
    {
        $query = SysJob::query();

        if (!empty($params['job_name'])) {
            $query->where('job_name', 'like', '%' . $params['job_name'] . '%');
        }
        if (!empty($params['job_group'])) {
            $query->where('job_group', $params['job_group']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        if (!empty($params['invoke_target'])) {
            $query->where('invoke_target', 'like', '%' . $params['invoke_target'] . '%');
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('job_id', 'asc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 根据ID查询定时任务详情
    public function selectJobById($jobId)
    {
        return SysJob::find($jobId);
    }

    // 新增定时任务
    public function insertJob($data)
    {
        // 校验cron表达式
        if (!empty($data['cron_expression']) && !$this->validateCronExpression($data['cron_expression'])) {
            throw new \Exception('cron表达式格式不正确');
        }
        $data['create_time'] = date('Y-m-d H:i:s');
        return SysJob::create($data);
    }

    // 更新定时任务信息
    public function updateJob($data)
    {
        // 校验cron表达式
        if (!empty($data['cron_expression']) && !$this->validateCronExpression($data['cron_expression'])) {
            throw new \Exception('cron表达式格式不正确');
        }
        $data['update_time'] = date('Y-m-d H:i:s');
        return SysJob::where('job_id', $data['job_id'])->update($data);
    }

    // 批量删除定时任务
    public function deleteJobByIds($jobIds)
    {
        return SysJob::whereIn('job_id', $jobIds)->delete();
    }

    // 修改定时任务状态（启用/停用）
    public function changeStatus($jobId, $status)
    {
        return SysJob::where('job_id', $jobId)->update([
            'status' => $status,
            'update_time' => date('Y-m-d H:i:s'),
        ]);
    }

    /**
     * 立即执行一次定时任务
     * 解析invoke_target并通过反射调用app\job命名空间下的类方法
     */
    public function run($job)
    {
        $startTime = microtime(true);
        $jobLog = new SysJobLog();
        $jobLog->job_name = $job->job_name;
        $jobLog->job_group = $job->job_group;
        $jobLog->invoke_target = $job->invoke_target;
        $jobLog->start_time = date('Y-m-d H:i:s');

        try {
            $result = $this->invokeTarget($job->invoke_target);
            $costTime = round((microtime(true) - $startTime) * 1000, 2);
            $jobLog->job_message = $job->job_name . ' 总共耗时：' . $costTime . '毫秒';
            $jobLog->status = '0';
            $jobLog->exception_info = is_string($result) ? mb_substr($result, 0, 2000) : '';
        } catch (\Throwable $e) {
            $costTime = round((microtime(true) - $startTime) * 1000, 2);
            $jobLog->job_message = $job->job_name . ' 总共耗时：' . $costTime . '毫秒，执行失败';
            $jobLog->status = '1';
            $jobLog->exception_info = mb_substr($e->getMessage(), 0, 2000);
        }

        $jobLog->end_time = date('Y-m-d H:i:s');
        $jobLog->create_time = date('Y-m-d H:i:s');
        $jobLog->save();
        return true;
    }

    /**
     * 解析并调用invoke_target
     * 支持格式：ClassName@method(arg1,arg2) 或 ClassName@method
     * 仅允许调用 app\job 命名空间下的类
     */
    private function invokeTarget(string $invokeTarget)
    {
        $invokeTarget = trim($invokeTarget);
        if (empty($invokeTarget)) {
            throw new \Exception('调用目标字符串不能为空');
        }

        // 解析参数（支持带括号和不带括号两种格式）
        $args = [];
        if (preg_match('/^(.+?)\((.*)\)$/', $invokeTarget, $matches)) {
            $main = $matches[1];
            $argsStr = trim($matches[2]);
            if ($argsStr !== '') {
                foreach (explode(',', $argsStr) as $arg) {
                    $arg = trim($arg);
                    // 去除字符串引号
                    if (preg_match('/^["\'](.*)["\']$/', $arg, $m)) {
                        $args[] = $m[1];
                    } elseif (is_numeric($arg)) {
                        $args[] = strpos($arg, '.') !== false ? (float)$arg : (int)$arg;
                    } elseif (in_array(strtolower($arg), ['true', 'false'], true)) {
                        $args[] = strtolower($arg) === 'true';
                    } else {
                        $args[] = $arg;
                    }
                }
            }
        } else {
            $main = $invokeTarget;
        }

        // 解析类名和方法名（格式：ClassName@method）
        if (strpos($main, '@') === false) {
            throw new \Exception('调用目标格式不支持，请使用 ClassName@method 格式');
        }
        [$className, $methodName] = explode('@', $main, 2);
        $className = trim($className);
        $methodName = trim($methodName);

        if (empty($className) || empty($methodName)) {
            throw new \Exception('调用目标类名或方法名不能为空');
        }

        // 安全限制：仅允许调用 app\job 命名空间下的类
        $fullClass = 'app\\job\\' . $className;
        if (!class_exists($fullClass)) {
            throw new \Exception('调用目标类不存在：' . $className . '（仅允许调用 app\job 命名空间下的类）');
        }

        if (!method_exists($fullClass, $methodName)) {
            throw new \Exception('调用目标方法不存在：' . $className . '@' . $methodName);
        }

        // 通过反射调用公共静态方法
        $reflection = new \ReflectionMethod($fullClass, $methodName);
        if (!$reflection->isPublic() || !$reflection->isStatic()) {
            throw new \Exception('仅允许调用类的公共静态方法');
        }

        return $reflection->invokeArgs(null, $args);
    }

    /**
     * 校验cron表达式格式（支持5-7段）
     * 每段允许：* / 数字 , - / 等标准cron字符
     */
    private function validateCronExpression(string $expression): bool
    {
        $expression = trim($expression);
        if (empty($expression)) {
            return false;
        }
        $parts = preg_split('/\s+/', $expression);
        if (count($parts) < 5 || count($parts) > 7) {
            return false;
        }
        // 每段允许的字符：数字、* / , - ?
        foreach ($parts as $part) {
            if (!preg_match('/^[\d*,\/\-?]+$/', $part)) {
                return false;
            }
        }
        return true;
    }
}
