<?php

namespace app\process;

use Workerman\Timer;
use Workerman\Worker;
use app\service\BizTrainStudyLogService;

/**
 * 学习会话超时清理进程
 *
 * 每 10 分钟检查一次，清理超时未结束的学习会话
 * 规则：status='0' 且 start_time 超过 2 小时，标记为异常中断
 */
class StudySessionCleaner
{
    public function onWorkerStart(Worker $worker)
    {
        // 每 10 分钟执行一次
        Timer::add(600, function () {
            $this->cleanTimeoutSessions();
        });
    }

    private function cleanTimeoutSessions()
    {
        try {
            $service = new BizTrainStudyLogService();
            $count = $service->cleanTimeoutSessions();
            if ($count > 0) {
                \support\Log::info("学习会话清理：标记 {$count} 个超时会话为异常中断");
            }
        } catch (\Throwable $e) {
            \support\Log::error('学习会话清理异常: ' . $e->getMessage());
        }
    }
}
