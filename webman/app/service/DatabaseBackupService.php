<?php

namespace app\service;

use app\model\SysDbBackup;
use app\service\SysConfigService;

/**
 * 数据库备份服务层
 *
 * 提供 mysqldump 备份、COS上传、备份记录管理及过期清理等功能
 */
class DatabaseBackupService
{
    // 执行数据库备份
    public static function executeBackup($type = 'auto')
    {
        $startTime = microtime(true);
        $dbConfig = config('database.connections.mysql', []);

        $host = $dbConfig['host'] ?? '127.0.0.1';
        $port = $dbConfig['port'] ?? '3306';
        $database = $dbConfig['database'] ?? 'fuchenpro';
        $username = $dbConfig['username'] ?? 'root';
        $password = $dbConfig['password'] ?? '';

        $timestamp = date('Ymd_His');
        $fileName = "{$database}_{$timestamp}.sql";
        $backupDir = runtime_path() . 'backup';

        if (!is_dir($backupDir)) {
            mkdir($backupDir, 0755, true);
        }

        $tmpFile = $backupDir . DIRECTORY_SEPARATOR . $fileName;

        // 读取mysqldump路径配置
        $mysqldumpPath = SysConfigService::getConfigValue('sys.backup.mysqldumpPath', 'mysqldump');

        // 构建 mysqldump 命令（使用 escapeshellarg 防止命令注入）
        $escMysqldumpPath = escapeshellarg($mysqldumpPath);
        $escHost = escapeshellarg($host);
        $escPort = escapeshellarg($port);
        $escUsername = escapeshellarg($username);
        $escDatabase = escapeshellarg($database);
        $escTmpFile = escapeshellarg($tmpFile);
        $passwordArg = $password ? '-p' . escapeshellarg($password) : '';
        $command = $escMysqldumpPath . " -h{$escHost} -P{$escPort} -u{$escUsername} {$passwordArg} --single-transaction --routines --triggers {$escDatabase} > {$escTmpFile} 2>&1";

        exec($command, $output, $returnCode);

        if ($returnCode !== 0 || !file_exists($tmpFile) || filesize($tmpFile) === 0) {
            $errorMsg = implode("\n", $output);
            @unlink($tmpFile);

            // 记录失败日志
            SysDbBackup::create([
                'file_name' => $fileName,
                'file_size' => 0,
                'cos_path' => '',
                'cos_url' => '',
                'backup_type' => $type,
                'status' => 'failed',
                'duration' => round(microtime(true) - $startTime, 2),
                'error_message' => $errorMsg ?: 'mysqldump执行失败',
                'create_time' => date('Y-m-d H:i:s'),
            ]);

            return ['success' => false, 'message' => '备份失败: ' . ($errorMsg ?: 'mysqldump执行失败')];
        }

        $fileSize = filesize($tmpFile);

        // 上传到 COS
        $cosPath = "backup/{$fileName}";
        $cosUrl = '';
        $cosService = new CosService();

        if ($cosService->isEnabled()) {
            $cosUrl = $cosService->upload($tmpFile, $cosPath);
            if (!$cosUrl) {
                @unlink($tmpFile);
                SysDbBackup::create([
                    'file_name' => $fileName,
                    'file_size' => $fileSize,
                    'cos_path' => $cosPath,
                    'cos_url' => '',
                    'backup_type' => $type,
                    'status' => 'failed',
                    'duration' => round(microtime(true) - $startTime, 2),
                    'error_message' => 'COS上传失败',
                    'create_time' => date('Y-m-d H:i:s'),
                ]);
                return ['success' => false, 'message' => '备份文件已生成但COS上传失败'];
            }
        } else {
            // COS未启用，仅本地存储
            $cosPath = '';
        }

        // 保留本地文件，供下载/预览使用，由cleanOldBackups统一清理

        // 记录成功日志
        $duration = round(microtime(true) - $startTime, 2);
        SysDbBackup::create([
            'file_name' => $fileName,
            'file_size' => $fileSize,
            'cos_path' => $cosPath,
            'cos_url' => $cosUrl ?: '',
            'backup_type' => $type,
            'status' => 'success',
            'duration' => $duration,
            'error_message' => '',
            'create_time' => date('Y-m-d H:i:s'),
        ]);

        return ['success' => true, 'message' => '备份成功', 'duration' => $duration, 'fileSize' => $fileSize];
    }

    // 查询备份记录列表
    public static function getBackupList($params = [])
    {
        $query = SysDbBackup::query();

        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }
        if (!empty($params['backup_type'])) {
            $query->where('backup_type', $params['backup_type']);
        }
        if (!empty($params['begin_time'])) {
            $query->where('create_time', '>=', $params['begin_time']);
        }
        if (!empty($params['end_time'])) {
            $query->where('create_time', '<=', $params['end_time']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('backup_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 获取备份详情
    public static function getBackupInfo($backupId)
    {
        return SysDbBackup::find($backupId);
    }

    // 删除备份记录及COS文件和本地文件
    public static function deleteBackup($backupIds)
    {
        $backups = SysDbBackup::whereIn('backup_id', $backupIds)->get();
        $cosService = new CosService();

        foreach ($backups as $backup) {
            // 删除COS文件
            if ($backup->cos_path && $cosService->isEnabled()) {
                $cosService->delete($backup->cos_path);
            }
            // 删除本地文件
            $localPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
            if (file_exists($localPath)) {
                @unlink($localPath);
            }
        }

        return SysDbBackup::whereIn('backup_id', $backupIds)->delete();
    }

    // 清理过期备份（同时清理COS文件和本地文件）
    public static function cleanOldBackups($retainDays = 30)
    {
        $expireDate = date('Y-m-d H:i:s', strtotime("-{$retainDays} days"));
        $oldBackups = SysDbBackup::where('create_time', '<', $expireDate)->get();

        $cosService = new CosService();
        $ids = [];

        foreach ($oldBackups as $backup) {
            // 删除COS文件
            if ($backup->cos_path && $cosService->isEnabled()) {
                $cosService->delete($backup->cos_path);
            }
            // 删除本地文件
            $localPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
            if (file_exists($localPath)) {
                @unlink($localPath);
            }
            $ids[] = $backup->backup_id;
        }

        if (!empty($ids)) {
            SysDbBackup::whereIn('backup_id', $ids)->delete();
        }

        return count($ids);
    }

    // 获取备份配置
    public static function getBackupConfig()
    {
        return [
            'enabled' => SysConfigService::getConfigValue('sys.backup.enabled', 'true') === 'true',
            'backupTime' => SysConfigService::getConfigValue('sys.backup.time', '02:00'),
            'retainDays' => intval(SysConfigService::getConfigValue('sys.backup.retainDays', '30')),
            'mysqldumpPath' => SysConfigService::getConfigValue('sys.backup.mysqldumpPath', 'mysqldump'),
        ];
    }

    // 更新备份配置
    public static function updateBackupConfig($config)
    {
        if (isset($config['enabled'])) {
            SysConfigService::setConfigValue('sys.backup.enabled', $config['enabled'] ? 'true' : 'false', '数据库备份启用');
        }
        if (isset($config['backupTime'])) {
            SysConfigService::setConfigValue('sys.backup.time', $config['backupTime'], '数据库备份时间');
        }
        if (isset($config['retainDays'])) {
            SysConfigService::setConfigValue('sys.backup.retainDays', strval($config['retainDays']), '备份保留天数');
        }
        if (isset($config['mysqldumpPath'])) {
            SysConfigService::setConfigValue('sys.backup.mysqldumpPath', $config['mysqldumpPath'], 'mysqldump路径');
        }
        return true;
    }

    // 下载备份文件内容
    public static function downloadBackupFile($backupId)
    {
        $backup = self::getBackupInfo($backupId);
        if (!$backup) {
            return null;
        }

        $content = null;

        // 优先从本地读取（更快更可靠）
        $localPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
        if (file_exists($localPath)) {
            $content = file_get_contents($localPath);
        }

        // 本地没有，从COS获取
        if ($content === null && $backup->cos_path) {
            $cosService = new CosService();
            $content = $cosService->getObjectContent($backup->cos_path);
            if ($content === null) {
                \support\Log::error("备份文件下载失败: backupId={$backupId}, cosPath={$backup->cos_path}, 本地文件不存在: {$localPath}");
            }
        }

        if ($content === null) {
            return null;
        }

        return [
            'content' => $content,
            'fileName' => $backup->file_name,
        ];
    }

    // 预览备份文件内容（限制前500行）
    public static function previewBackup($backupId)
    {
        $backup = self::getBackupInfo($backupId);
        if (!$backup) {
            return ['success' => false, 'message' => '备份记录不存在'];
        }

        if ($backup->status !== 'success') {
            return ['success' => false, 'message' => '备份文件不可用'];
        }

        $content = null;

        // 优先从本地读取
        $localPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
        if (file_exists($localPath)) {
            $content = file_get_contents($localPath);
        }

        // 本地没有，从COS获取
        if ($content === null && $backup->cos_path) {
            $cosService = new CosService();
            $content = $cosService->getObjectContent($backup->cos_path);
            if ($content === null) {
                \support\Log::error("备份文件预览失败: backupId={$backupId}, cosPath={$backup->cos_path}, 本地文件不存在: {$localPath}");
            }
        }

        if ($content === null) {
            return ['success' => false, 'message' => '无法读取备份文件（本地文件已清理且COS读取失败）'];
        }

        // 限制前500行
        $lines = explode("\n", $content);
        $totalLines = count($lines);
        $previewLines = array_slice($lines, 0, 500);
        $previewContent = implode("\n", $previewLines);

        return [
            'success' => true,
            'content' => $previewContent,
            'totalLines' => $totalLines,
            'previewLines' => min(500, $totalLines),
            'truncated' => $totalLines > 500,
            'fileName' => $backup->file_name,
        ];
    }

    // 格式化文件大小
    public static function formatFileSize($bytes)
    {
        if ($bytes >= 1073741824) {
            return round($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            return round($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return round($bytes / 1024, 2) . ' KB';
        }
        return $bytes . ' B';
    }
}
