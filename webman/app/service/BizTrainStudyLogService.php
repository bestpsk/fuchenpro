<?php

namespace app\service;

use app\model\BizTrainStudyLog;
use app\model\BizTrainMaterial;
use app\model\SysUser;
use app\service\RedisService;
use support\Db;

/**
 * 培训学习日志服务层，处理学习会话、心跳上报、时长校验
 */
class BizTrainStudyLogService
{
    // 临时授权URL的Redis键前缀与有效期(秒)
    const TEMP_URL_PREFIX = 'train:url:';
    const TEMP_URL_TTL = 600;

    // App端：获取材料详情（员工学习入口，无需管理权限）
    public function getMaterialInfo($materialId, $userId = null)
    {
        $material = BizTrainMaterial::where('material_id', $materialId)
            ->where('del_flag', '0')
            ->where('status', '0')
            ->first();
        if (!$material) {
            return null;
        }
        // 授权检查
        if ($userId !== null) {
            $authService = new BizTrainMaterialAuthService();
            if (!$authService->checkMaterialAccess($materialId, $userId)) {
                throw new \Exception('您没有权限查看此材料');
            }
        }
        // 规范化 fileUrl
        $material->file_url = $this->buildFileUrl($material->file_url);
        return $material;
    }

    // 分页查询学习记录（管理端）
    // $loginUser 非null时按数据权限过滤
    public function selectLogList($params = [], $loginUser = null)
    {
        $query = BizTrainStudyLog::query();

        if (!empty($params['user_id'])) {
            $query->where('user_id', $params['user_id']);
        }
        if (!empty($params['material_id'])) {
            $query->where('material_id', $params['material_id']);
        }
        if (!empty($params['user_name'])) {
            $userIds = SysUser::where('user_name', 'like', '%' . $params['user_name'] . '%')
                ->orWhere('nick_name', 'like', '%' . $params['user_name'] . '%')
                ->pluck('user_id')->all();
            $query->whereIn('user_id', $userIds);
        }
        if (!empty($params['material_title'])) {
            $materialIds = BizTrainMaterial::where('title', 'like', '%' . $params['material_title'] . '%')
                ->pluck('material_id')->all();
            $query->whereIn('material_id', $materialIds);
        }
        if (!empty($params['start_date']) && !empty($params['end_date'])) {
            $query->whereBetween('start_time', [$params['start_date'] . ' 00:00:00', $params['end_date'] . ' 23:59:59']);
        }

        // 数据权限过滤：非管理员只能看到权限范围内的用户学习记录
        if ($loginUser !== null) {
            DataScopeService::applyUserScope($query, $loginUser, 'user_id');
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('log_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);

        // 批量关联用户名和材料标题
        $userIds = $result->getCollection()->pluck('user_id')->unique()->values()->all();
        $materialIds = $result->getCollection()->pluck('material_id')->unique()->values()->all();
        $users = SysUser::whereIn('user_id', $userIds)->where('del_flag', '0')->get()->keyBy('user_id');
        $materials = BizTrainMaterial::whereIn('material_id', $materialIds)->get()->keyBy('material_id');

        foreach ($result->items() as $item) {
            $user = $users->get($item->user_id);
            $item->user_name = $user ? ($user->nick_name ?: $user->user_name) : '';
            $item->phonenumber = $user ? $user->phonenumber : '';
            $material = $materials->get($item->material_id);
            $item->material_title = $material ? $material->title : '';
        }

        return $result;
    }

    // 查询当前用户学习记录
    public function selectMyLogs($userId, $params = [])
    {
        $params['user_id'] = $userId;
        return $this->selectLogList($params);
    }

    // 开始学习：创建会话，返回session_id并生成临时URL
    public function startStudy($userId, $materialId)
    {
        $material = BizTrainMaterial::where('material_id', $materialId)
            ->where('del_flag', '0')
            ->where('status', '0')
            ->first();
        if (!$material) {
            throw new \Exception('材料不存在或已下架');
        }
        // 授权检查
        $authService = new BizTrainMaterialAuthService();
        if (!$authService->checkMaterialAccess($materialId, $userId)) {
            throw new \Exception('您没有权限学习此材料');
        }

        // 同一材料同一用户进行中的会话先结束，避免重复会话
        BizTrainStudyLog::where('user_id', $userId)
            ->where('material_id', $materialId)
            ->where('status', '0')
            ->update(['status' => '2', 'end_time' => date('Y-m-d H:i:s')]);

        $sessionId = $this->generateSessionId();
        $now = date('Y-m-d H:i:s');
        $log = BizTrainStudyLog::create([
            'user_id' => $userId,
            'material_id' => $materialId,
            'session_id' => $sessionId,
            'start_time' => $now,
            'status' => '0',
            'create_time' => $now,
        ]);

        // 生成临时授权URL（规范化为完整可访问URL）
        $this->setTempUrl($sessionId, $this->buildFileUrl($material->file_url));

        return [
            'session_id' => $sessionId,
            'material' => $material,
        ];
    }

    // 心跳上报：校验会话有效性，累计切屏/暂停次数
    public function heartbeat($sessionId, $data)
    {
        $log = BizTrainStudyLog::where('session_id', $sessionId)->where('status', '0')->first();
        if (!$log) {
            throw new \Exception('学习会话无效或已结束');
        }

        $update = [];
        if (isset($data['switch_count'])) {
            $update['switch_count'] = $log->switch_count + intval($data['switch_count']);
        }
        if (isset($data['pause_count'])) {
            $update['pause_count'] = $log->pause_count + intval($data['pause_count']);
        }
        if (!empty($update)) {
            $log->fill($update)->save();
        }

        // 续期临时URL
        $this->setTempUrl($sessionId, $this->getTempUrl($sessionId));
        return true;
    }

    // 结束学习：后端校验有效时长
    public function endStudy($sessionId, $validDuration = 0)
    {
        $log = BizTrainStudyLog::where('session_id', $sessionId)->where('status', '0')->first();
        if (!$log) {
            return false;
        }

        $now = time();
        $start = strtotime($log->start_time);
        $maxDuration = $now - $start; // 不超过实际跨度
        $validDuration = max(0, min(intval($validDuration), $maxDuration));

        $log->end_time = date('Y-m-d H:i:s', $now);
        $log->valid_duration = $validDuration;
        $log->status = '1';
        $log->save();

        // 清理临时URL
        RedisService::delete(self::TEMP_URL_PREFIX . $sessionId);

        return true;
    }

    /**
     * 定时任务：清理超时未结束的学习会话
     * 规则：status='0' 且 start_time 超过 2 小时，标记为异常中断
     * @return int 清理的记录数
     */
    public function cleanTimeoutSessions()
    {
        $timeout = time() - 7200; // 2 小时
        $timeoutTime = date('Y-m-d H:i:s', $timeout);

        return BizTrainStudyLog::where('status', '0')
            ->where('start_time', '<', $timeoutTime)
            ->update([
                'status' => '2',
                'end_time' => $timeoutTime
            ]);
    }

    // 获取临时授权URL
    public function getMaterialUrl($sessionId)
    {
        $url = $this->getTempUrl($sessionId);
        if (!$url) {
            throw new \Exception('临时授权已过期，请重新开始学习');
        }
        // 续期
        $this->setTempUrl($sessionId, $url);
        return $url;
    }

    // 解析会话对应的本地文件绝对路径或 COS URL
    // 返回 ['type' => 'local|remote', 'path' => '...', 'mime' => '...']
    // type=local: path 为文件系统绝对路径，调用方需自行读取并输出二进制
    // type=remote: path 为完整 URL（如 COS），调用方应 302 重定向
    public function resolveFilePath($sessionId)
    {
        $url = $this->getTempUrl($sessionId);
        if (!$url) {
            throw new \Exception('临时授权已过期，请重新开始学习');
        }
        // 续期
        $this->setTempUrl($sessionId, $url);

        // COS URL：下载到临时文件，按本地文件处理（避免跨域 + 支持PPT转换）
        if (strpos($url, 'http://') === 0 || strpos($url, 'https://') === 0) {
            $cosService = new \app\service\CosService();
            if ($cosService->isEnabled() && $cosService->isCosUrl($url)) {
                $cosPath = $cosService->parsePathFromUrl($url);
                if ($cosPath) {
                    $ext = strtolower(pathinfo($url, PATHINFO_EXTENSION)) ?: 'bin';
                    $tempPath = sys_get_temp_dir() . '/train_' . uniqid() . '.' . $ext;
                    if (!$cosService->downloadToFile($cosPath, $tempPath)) {
                        throw new \Exception('文件下载失败，请稍后重试');
                    }
                    register_shutdown_function(function () use ($tempPath) {
                        if (file_exists($tempPath)) {
                            @unlink($tempPath);
                        }
                    });

                    // PPT/PPTX 服务端转 PDF
                    if (in_array($ext, ['ppt', 'pptx'], true)) {
                        try {
                            $pptService = new \app\service\PptToPdfService();
                            $pdfPath = $pptService->getOrCreatePdf($tempPath);
                            @unlink($tempPath);
                            return ['type' => 'local', 'path' => $pdfPath, 'mime' => 'application/pdf'];
                        } catch (\Throwable $e) {
                            error_log('[PPT->PDF] 转换失败: ' . $e->getMessage());
                            throw new \Exception('PPT 预览转换失败，请联系管理员');
                        }
                    }

                    return ['type' => 'local', 'path' => $tempPath, 'mime' => $this->guessMime($tempPath)];
                }
            }

            // 非 COS 的远程 URL：保持302重定向
            return ['type' => 'remote', 'path' => $url, 'mime' => $this->guessMime($url)];
        }

        // 本地路径：规范化为 /profile/upload/yyyymm/xxx.ext
        $localRelative = $url;
        if (strpos($url, '/profile/upload/') !== 0) {
            $localRelative = '/profile/upload/' . ltrim($url, '/');
        }

        $absPath = public_path() . $localRelative;
        $realPath = realpath($absPath);
        if ($realPath === false || !is_file($realPath)) {
            throw new \Exception('文件不存在');
        }

        // PPT/PPTX 服务端转 PDF（懒转换 + 文件缓存）
        $ext = strtolower(pathinfo($realPath, PATHINFO_EXTENSION));
        if (in_array($ext, ['ppt', 'pptx'], true)) {
            try {
                $pptService = new \app\service\PptToPdfService();
                $pdfPath = $pptService->getOrCreatePdf($realPath);
                return ['type' => 'local', 'path' => $pdfPath, 'mime' => 'application/pdf'];
            } catch (\Throwable $e) {
                error_log('[PPT->PDF] 转换失败: ' . $e->getMessage());
                throw new \Exception('PPT 预览转换失败，请联系管理员');
            }
        }

        return ['type' => 'local', 'path' => $realPath, 'mime' => $this->guessMime($realPath)];
    }

    // 根据扩展名推断 MIME 类型
    private function guessMime($path)
    {
        $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        $map = [
            'pdf'  => 'application/pdf',
            'doc'  => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls'  => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'ppt'  => 'application/vnd.ms-powerpoint',
            'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'txt'  => 'text/plain; charset=utf-8',
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png'  => 'image/png',
            'gif'  => 'image/gif',
            'bmp'  => 'image/bmp',
            'webp' => 'image/webp',
        ];
        return $map[$ext] ?? 'application/octet-stream';
    }

    // 生成会话ID
    private function generateSessionId()
    {
        return md5(uniqid(mt_rand(), true) . time());
    }

    // 规范化文件URL为完整可访问路径
    // file_url 字段存储格式：
    //   - COS: 完整 URL（http:// 或 https:// 开头）
    //   - 本地存储: 相对路径（/profile/upload/yyyymm/xxx.pdf）
    //   - 兼容旧数据: 仅 fileName（yyyymm/xxx.pdf），需拼接 /profile/upload/ 前缀
    private function buildFileUrl($fileUrl)
    {
        if (!$fileUrl) return '';
        // 已是完整 URL（COS 场景）或已带 /profile/upload/ 前缀（本地存储）
        if (strpos($fileUrl, 'http://') === 0 || strpos($fileUrl, 'https://') === 0
            || strpos($fileUrl, '/profile/upload/') === 0) {
            return $fileUrl;
        }
        // 旧数据：仅 fileName，拼接完整路径
        return '/profile/upload/' . ltrim($fileUrl, '/');
    }

    // 存储临时URL到Redis
    private function setTempUrl($sessionId, $fileUrl)
    {
        if (!$fileUrl) return;
        RedisService::set(self::TEMP_URL_PREFIX . $sessionId, $fileUrl, self::TEMP_URL_TTL);
    }

    // 读取临时URL
    private function getTempUrl($sessionId)
    {
        return RedisService::get(self::TEMP_URL_PREFIX . $sessionId);
    }
}
