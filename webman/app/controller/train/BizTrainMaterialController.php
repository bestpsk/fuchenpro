<?php

namespace app\controller\train;

use support\Request;
use app\service\BizTrainMaterialService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;
use app\common\ExcelUtil;
use app\model\BizTrainMaterial;

/**
 * 培训学习材料控制器
 */
class BizTrainMaterialController
{
    // 分页查询材料列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new BizTrainMaterialService();
        $params = convert_to_snake_case($request->all());
        // 非管理员按授权过滤
        $userId = $request->loginUser->user->user_id ?? 0;
        $isAdmin = method_exists($request->loginUser->user, 'isAdmin') ? $request->loginUser->user->isAdmin() : false;
        $result = $service->selectMaterialList($params, $isAdmin ? null : $userId);
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取材料详情
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $materialId = intval(end($parts));
        $service = new BizTrainMaterialService();
        $material = $service->selectMaterialById($materialId);
        if (!$material) return AjaxResult::error('材料不存在');
        return AjaxResult::success($material);
    }

    // 新增材料
    public function add(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['create_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizTrainMaterialService();
        $result = $service->insertMaterial($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 修改材料
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = convert_to_snake_case($request->post());
        $data['update_by'] = $request->loginUser->user->user_name ?? '';
        $service = new BizTrainMaterialService();
        $result = $service->updateMaterial($data);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 删除材料
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $materialIds = $request->input('materialIds', '');
        if (!is_array($materialIds)) {
            $materialIds = explode(',', $materialIds);
        }
        $materialIds = array_map('intval', array_filter($materialIds));
        $service = new BizTrainMaterialService();
        $result = $service->deleteMaterialByIds($materialIds);
        return AjaxResult::toAjax($result ? 1 : 0);
    }

    // 导出材料
    public function export(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:export')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $params = convert_to_snake_case($request->all());
        $params['page_size'] = 10000;
        $service = new BizTrainMaterialService();
        $result = $service->selectMaterialList($params);
        $excelUtil = new ExcelUtil(BizTrainMaterial::class);
        return $excelUtil->exportExcel($result->items(), '培训材料数据');
    }

    // 下载材料原始文件（PPT 等），带权限和授权检查
    public function download(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'train:material:query')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $materialId = intval(end($parts));
        if (!$materialId) {
            return AjaxResult::error('材料ID不能为空');
        }
        $service = new BizTrainMaterialService();
        $material = $service->selectMaterialById($materialId);
        if (!$material) {
            return AjaxResult::error('材料不存在');
        }
        if (empty($material->file_url)) {
            return AjaxResult::error('文件路径不存在');
        }

        // 授权检查：非管理员只能下载被授权的材料
        $userId = $request->loginUser->user->user_id ?? 0;
        $isAdmin = method_exists($request->loginUser->user, 'isAdmin') ? $request->loginUser->user->isAdmin() : false;
        if (!$isAdmin) {
            $authService = new \app\service\BizTrainMaterialAuthService();
            if (!$authService->checkMaterialAccess($material->material_id, $userId)) {
                return AjaxResult::error('没有下载此材料的权限');
            }
        }

        $fileUrl = $material->file_url;
        $isRemote = strpos($fileUrl, 'http://') === 0 || strpos($fileUrl, 'https://') === 0;

        // 本地路径规范化为 /profile/upload/yyyymm/xxx.ext
        if (!$isRemote && strpos($fileUrl, '/profile/upload/') !== 0) {
            $fileUrl = '/profile/upload/' . ltrim($fileUrl, '/');
        }

        // 生成下载文件名（使用材料标题 + 原扩展名）
        $ext = pathinfo($fileUrl, PATHINFO_EXTENSION);
        $baseName = $material->title ?: basename($fileUrl);
        if ($ext && !str_ends_with($baseName, '.' . $ext)) {
            $baseName .= '.' . $ext;
        }
        // 清理特殊字符，避免 Content-Disposition 解析问题
        $safeName = str_replace(['"', "\r", "\n", '\\'], '', $baseName);
        $encodedName = rawurlencode($safeName);

        $headers = [
            'Content-Type'           => 'application/octet-stream',
            'Content-Disposition'    => "attachment; filename=\"{$safeName}\"; filename*=UTF-8''{$encodedName}",
            'Cache-Control'          => 'no-store, no-cache, must-revalidate',
            'Pragma'                 => 'no-cache',
            'X-Content-Type-Options' => 'nosniff',
        ];

        // COS 远程文件：下载到临时文件后输出（避免跨域 + 私有桶签名问题）
        if ($isRemote) {
            $cosService = new \app\service\CosService();
            if ($cosService->isEnabled() && $cosService->isCosUrl($fileUrl)) {
                $cosPath = $cosService->parsePathFromUrl($fileUrl);
                if ($cosPath) {
                    $tempPath = sys_get_temp_dir() . '/train_dl_' . uniqid() . '.' . ($ext ?: 'bin');
                    if (!$cosService->downloadToFile($cosPath, $tempPath)) {
                        return AjaxResult::error('文件下载失败，请稍后重试');
                    }
                    register_shutdown_function(function () use ($tempPath) {
                        if (file_exists($tempPath)) {
                            @unlink($tempPath);
                        }
                    });
                    return response()->withFile($tempPath)->withHeaders($headers);
                }
            }
            // 非 COS 的远程 URL：302 重定向
            return redirect($fileUrl);
        }

        // 本地文件：直接输出二进制流（限制只能访问 upload 子目录，禁止目录穿越）
        $uploadDir = realpath(public_path() . '/profile/upload/');
        $realPath = realpath(public_path() . $fileUrl);
        if ($realPath === false || !is_file($realPath) || strpos($realPath, $uploadDir) !== 0) {
            return AjaxResult::error('文件不存在');
        }
        return response()->withFile($realPath)->withHeaders($headers);
    }
}
