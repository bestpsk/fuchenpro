<?php

namespace app\controller\system;

use support\Request;
use app\service\DatabaseBackupService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 数据库备份管理控制器
 *
 * 提供备份记录查询、手动备份、下载、删除及配置管理等功能
 */
class DatabaseBackupController
{
    // 查询备份记录列表
    public function list(Request $request)
    {
        $params = convert_to_snake_case($request->all());
        $result = DatabaseBackupService::getBackupList($params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 获取备份详情
    public function getInfo(Request $request, $backupId)
    {
        $backup = DatabaseBackupService::getBackupInfo($backupId);
        if (!$backup) {
            return AjaxResult::error('备份记录不存在');
        }
        return AjaxResult::success($backup);
    }

    // 手动执行备份
    public function execute(Request $request)
    {
        $result = DatabaseBackupService::executeBackup('manual');
        if ($result['success']) {
            return AjaxResult::success($result['message']);
        }
        return AjaxResult::error($result['message']);
    }

    // 删除备份记录
    public function remove(Request $request)
    {
        $backupIds = explode(',', $request->input('backupIds', ''));
        $backupIds = array_map('intval', array_filter($backupIds));
        if (empty($backupIds)) {
            return AjaxResult::error('请选择要删除的备份记录');
        }
        return AjaxResult::toAjax(DatabaseBackupService::deleteBackup($backupIds) ? 1 : 0);
    }

    // 下载备份文件
    public function download(Request $request)
    {
        $backupId = $request->post('backupId');
        if (!$backupId) {
            return AjaxResult::error('请指定备份记录');
        }

        $backup = DatabaseBackupService::getBackupInfo($backupId);
        if (!$backup || $backup->status !== 'success') {
            return AjaxResult::error('备份记录不存在或不可用');
        }

        // 优先从本地文件下载
        $localPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
        if (file_exists($localPath)) {
            return response()->download($localPath, $backup->file_name);
        }

        // 本地没有，从COS下载到临时文件再返回
        if ($backup->cos_path) {
            $cosService = new \app\service\CosService();
            $content = $cosService->getObjectContent($backup->cos_path);
            if ($content !== null) {
                // 写入临时文件再下载
                $tmpPath = runtime_path() . 'backup' . DIRECTORY_SEPARATOR . $backup->file_name;
                file_put_contents($tmpPath, $content);
                return response()->download($tmpPath, $backup->file_name);
            }
        }

        return AjaxResult::error('备份文件不可下载（本地文件已清理且COS读取失败）');
    }

    // 预览备份文件
    public function preview(Request $request, $backupId)
    {
        $result = DatabaseBackupService::previewBackup($backupId);
        if (!$result['success']) {
            return AjaxResult::error($result['message']);
        }
        return AjaxResult::success($result);
    }

    // 获取备份配置
    public function getConfig(Request $request)
    {
        $config = DatabaseBackupService::getBackupConfig();
        return AjaxResult::success($config);
    }

    // 更新备份配置
    public function updateConfig(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        DatabaseBackupService::updateBackupConfig($data);
        return AjaxResult::success();
    }
}
