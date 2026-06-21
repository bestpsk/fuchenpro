<?php

namespace app\process;

use Workerman\Timer;
use Workerman\Worker;
use app\service\DatabaseBackupService;
use app\service\SysConfigService;

/**
 * 数据库备份定时调度进程
 *
 * 每分钟检查是否到达备份时间，自动执行数据库备份
 */
class BackupScheduler
{
    // 上次执行备份的日期，防止同一天重复执行
    private string $lastBackupDate = '';

    public function onWorkerStart(Worker $worker)
    {
        // 每分钟检查一次
        Timer::add(60, function () {
            $this->checkAndExecute();
        });
    }

    private function checkAndExecute()
    {
        try {
            $enabled = SysConfigService::getConfigValue('sys.backup.enabled', 'true');
            if ($enabled !== 'true') {
                return;
            }

            $backupTime = SysConfigService::getConfigValue('sys.backup.time', '02:00');
            $currentTime = date('H:i');
            $currentDate = date('Y-m-d');

            // 检查是否到达备份时间且今天尚未执行
            if ($currentTime === $backupTime && $this->lastBackupDate !== $currentDate) {
                $this->lastBackupDate = $currentDate;

                \support\Log::info('开始执行定时数据库备份...');
                $result = DatabaseBackupService::executeBackup('auto');

                if ($result['success']) {
                    \support\Log::info('定时数据库备份完成: ' . $result['message']);
                } else {
                    \support\Log::error('定时数据库备份失败: ' . $result['message']);
                }

                // 清理过期备份
                $retainDays = intval(SysConfigService::getConfigValue('sys.backup.retainDays', '30'));
                $cleaned = DatabaseBackupService::cleanOldBackups($retainDays);
                if ($cleaned > 0) {
                    \support\Log::info("清理了 {$cleaned} 个过期备份");
                }
            }
        } catch (\Throwable $e) {
            \support\Log::error('备份调度异常: ' . $e->getMessage());
        }
    }
}
