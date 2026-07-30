<?php

namespace app\controller\train;

use support\Request;
use app\service\BizTrainStudyLogService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 培训学习日志控制器，管理端查询学习记录、App端学习会话管理
 */
class BizTrainStudyLogController
{
    // 管理端：分页查询学习记录
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:studyLog:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizTrainStudyLogService();
        $params = convert_to_snake_case($request->all());
        $result = $service->selectLogList($params, $request->loginUser);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // App端：查询当前用户学习记录
    public function myList(Request $request)
    {
        $service = new BizTrainStudyLogService();
        $params = convert_to_snake_case($request->all());
        $userId = $request->loginUser->user->user_id ?? 0;
        $result = $service->selectMyLogs($userId, $params);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // App端：获取材料详情（员工学习入口，无需管理权限）
    public function getMaterialInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $materialId = intval(end($parts));
        if (!$materialId) {
            return AjaxResult::error('材料ID不能为空');
        }
        try {
            $service = new BizTrainStudyLogService();
            $userId = $request->loginUser->user->user_id ?? null;
            $material = $service->getMaterialInfo($materialId, $userId);
            if (!$material) {
                return AjaxResult::error('材料不存在或已下架');
            }
            return AjaxResult::success($material);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // App端：开始学习，生成会话与临时授权URL
    public function start(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $materialId = intval($data['material_id'] ?? 0);
        if (!$materialId) {
            return AjaxResult::error('材料ID不能为空');
        }
        $userId = $request->loginUser->user->user_id ?? 0;
        try {
            $service = new BizTrainStudyLogService();
            $result = $service->startStudy($userId, $materialId);
            return AjaxResult::success($result);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // App端：心跳上报，每15秒调用一次
    public function heartbeat(Request $request)
    {
        $data = convert_to_snake_case($request->post());
        $sessionId = $data['session_id'] ?? '';
        if (!$sessionId) {
            return AjaxResult::error('会话ID不能为空');
        }
        try {
            $service = new BizTrainStudyLogService();
            $service->heartbeat($sessionId, $data);
            return AjaxResult::success('心跳成功');
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // App端：结束学习，后端校验有效时长
    public function end(Request $request)
    {
        // 兼容 sendBeacon 的 text/plain 请求
        $rawBody = $request->rawBody();
        $contentType = $request->header('content-type', '');
        if ($rawBody && strpos($contentType, 'text/plain') !== false) {
            $data = json_decode($rawBody, true) ?? [];
            // 转为蛇形命名
            $data = convert_to_snake_case($data);
        } else {
            $data = convert_to_snake_case($request->post());
        }

        $sessionId = $data['session_id'] ?? '';
        $validDuration = intval($data['valid_duration'] ?? 0);
        if (!$sessionId) {
            return AjaxResult::error('会话ID不能为空');
        }
        try {
            $service = new BizTrainStudyLogService();
            $service->endStudy($sessionId, $validDuration);
            return AjaxResult::success('结束学习成功');
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // App端：获取临时授权访问URL（有效期≤10分钟）
    public function getMaterialUrl(Request $request)
    {
        $parts = explode('/', $request->path());
        $sessionId = end($parts);
        if (!$sessionId) {
            return AjaxResult::error('会话ID不能为空');
        }
        try {
            $service = new BizTrainStudyLogService();
            $url = $service->getMaterialUrl($sessionId);
            return AjaxResult::success('', ['url' => $url]);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }

    // App端：文件流接口（DRM 临时授权），无需 Authorization 头
    // 会话本身即为临时凭证，有效期≤10 分钟，心跳续期
    public function file(Request $request)
    {
        $parts = explode('/', $request->path());
        $sessionId = end($parts);
        if (!$sessionId) {
            return AjaxResult::error('会话ID不能为空');
        }
        try {
            $service = new BizTrainStudyLogService();
            $info = $service->resolveFilePath($sessionId);

            // COS 等远程 URL：302 重定向（URL 自带签名鉴权）
            if ($info['type'] === 'remote') {
                return redirect($info['path']);
            }

            // 本地文件：以二进制流输出
            $realPath = $info['path'];
            $mime = $info['mime'];
            $fileName = basename($realPath);

            // 强制 inline 展示（禁止触发下载对话框）
            return response()->withFile($realPath)->withHeaders([
                'Content-Type'        => $mime,
                'Content-Disposition' => 'inline; filename="' . $fileName . '"',
                'Cache-Control'        => 'no-store, no-cache, must-revalidate',
                'Pragma'               => 'no-cache',
                'X-Content-Type-Options' => 'nosniff',
            ]);
        } catch (\Throwable $e) {
            return AjaxResult::error($e->getMessage());
        }
    }
}
