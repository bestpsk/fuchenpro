<?php

namespace app\process;

use Workerman\Timer;
use Workerman\Worker;
use app\model\BizGoal;
use app\service\BizGoalService;
use app\service\BizGoalProgressService;
use app\service\SysConfigService;
use support\Db;
use support\Log;

/**
 * 目标管理定时任务进程
 * 1. 每日凌晨2点重算所有启用目标的日目标（排班变更后次日重算）
 * 2. 预警检测：距周期结束N天完成率低于阈值→推送站内消息(sys_notice)
 */
class GoalDailyGenerator
{
    public function onWorkerStart(Worker $worker)
    {
        // 每 3600 秒检查一次
        Timer::add(3600, function () {
            $this->run();
        });
    }

    private function run()
    {
        $hour = (int) date('H');
        // 凌晨2点重算日目标
        if ($hour === 2) {
            $this->regenerateDailyGoals();
        }
        // 9点后检测预警（避免凌晨误报）
        if ($hour >= 9 && $hour <= 21) {
            $this->detectWarnings();
        }
    }

    /**
     * 重算所有启用月度/自定义目标的日目标
     */
    private function regenerateDailyGoals()
    {
        $today = date('Y-m-d');
        $key = 'goal_daily_gen:' . $today;
        if (\support\Redis::get($key)) return; // 当天已执行
        \support\Redis::setex($key, 86400, 1);

        try {
            $goals = BizGoal::where('status', '0')
                ->whereIn('period_type', ['3', '4'])
                ->where('end_date', '>=', $today)
                ->get();

            $service = new BizGoalService();
            $count = 0;
            foreach ($goals as $goal) {
                try {
                    $service->generateDailyGoals($goal->goal_id);
                    $count++;
                } catch (\Throwable $e) {
                    Log::error('目标日目标重算失败', ['goal_id' => $goal->goal_id, 'error' => $e->getMessage()]);
                }
            }
            Log::info('目标日目标重算完成', ['count' => $count]);
        } catch (\Throwable $e) {
            Log::error('目标日目标重算异常', ['error' => $e->getMessage()]);
        }
    }

    /**
     * 预警检测
     */
    private function detectWarnings()
    {
        $warnDays = intval(SysConfigService::getConfigValue('goal.warn.days', '3'));
        $warnRate = floatval(SysConfigService::getConfigValue('goal.warn.rate', '0.70'));
        $today = date('Y-m-d');

        // 距周期结束N天内的启用目标
        $warnDeadline = date('Y-m-d', strtotime("+{$warnDays} days"));
        $goals = BizGoal::where('status', '0')
            ->where('end_date', '<=', $warnDeadline)
            ->where('end_date', '>=', $today)
            ->get();

        $progressService = new BizGoalProgressService();
        foreach ($goals as $goal) {
            try {
                $progress = $progressService->calculateProgress($goal);
                if (!$progress) continue;

                // 完成率低于阈值
                if (($progress['completion_rate'] ?? 0) < $warnRate) {
                    $this->pushNotice(
                        sprintf('目标预警：%s 完成率 %.0f%%', $goal->goal_name, $progress['completion_rate'] * 100),
                        sprintf('<p>目标「%s」距周期结束剩 %d 天，当前完成率 %.1f%%，低于预警阈值 %.0f%%</p>',
                            $goal->goal_name,
                            $progress['remain_work_days'],
                            $progress['completion_rate'] * 100,
                            $warnRate * 100)
                    );
                }

                // 达成里程碑（100%）
                if (($progress['completion_rate'] ?? 0) >= 1 && !$this->isMilestoneNotified($goal->goal_id)) {
                    $this->pushNotice(
                        sprintf('目标达成：%s 已完成', $goal->goal_name),
                        sprintf('<p>恭喜！目标「%s」已完成 %.2f，达成率 %.1f%%</p>',
                            $goal->goal_name, $progress['completed'], $progress['completion_rate'] * 100)
                    );
                    $this->markMilestoneNotified($goal->goal_id);
                }
            } catch (\Throwable $e) {
                Log::error('目标预警检测失败', ['goal_id' => $goal->goal_id, 'error' => $e->getMessage()]);
            }
        }
    }

    // 推送站内消息（sys_notice，notice_type=1 通知）
    private function pushNotice($title, $content)
    {
        try {
            Db::table('sys_notice')->insert([
                'notice_title' => mb_substr($title, 0, 50),
                'notice_type' => '1',
                'notice_content' => $content,
                'status' => '0',
                'create_by' => 'system',
                'create_time' => date('Y-m-d H:i:s'),
                'remark' => '目标管理自动预警',
            ]);
        } catch (\Throwable $e) {
            Log::error('目标预警推送失败', ['title' => $title, 'error' => $e->getMessage()]);
        }
    }

    // 里程碑通知去重（当天只通知一次）
    private function isMilestoneNotified($goalId)
    {
        return (bool) \support\Redis::get('goal_milestone:' . $goalId . ':' . date('Y-m-d'));
    }

    private function markMilestoneNotified($goalId)
    {
        \support\Redis::setex('goal_milestone:' . $goalId . ':' . date('Y-m-d'), 86400, 1);
    }
}
