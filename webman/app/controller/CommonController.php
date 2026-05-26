<?php

namespace app\controller;

use support\Request;
use app\common\AjaxResult;
use app\service\CosService;

/**
 * 公共接口控制器
 *
 * 提供文件上传和下载等通用功能接口，不需要权限认证
 */
class CommonController
{
    // 通用文件上传，支持COS云存储和本地存储，通过配置切换
    public function upload(Request $request)
    {
        $file = $request->file('file');
        if (!$file || !$file->isValid()) {
            return AjaxResult::error('上传文件异常');
        }

        $ext = $file->getUploadExtension() ?: 'bin';
        $filename = date('Ymd') . '/' . md5(uniqid()) . '.' . $ext;

        $cosService = new CosService();
        if ($cosService->isEnabled()) {
            $cosPath = 'upload/' . $filename;
            $url = $cosService->uploadFile($file, $cosPath);
            if ($url) {
                return AjaxResult::success('', [
                    'fileName' => $filename,
                    'url' => $url,
                    'newFileName' => basename($filename),
                    'originalFilename' => $file->getUploadName(),
                ]);
            }
            return AjaxResult::error('COS上传失败');
        }

        $uploadDir = public_path() . '/profile/upload/';
        $fullPath = $uploadDir . $filename;
        $dir = dirname($fullPath);
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        $file->move($fullPath);
        $url = '/profile/upload/' . $filename;
        return AjaxResult::success('', [
            'fileName' => $filename,
            'url' => $url,
            'newFileName' => basename($filename),
            'originalFilename' => $file->getUploadName(),
        ]);
    }

    // 根据文件名下载已上传的文件（仅支持本地存储的文件）
    public function downloads(Request $request)
    {
        $fileName = $request->input('fileName', '');
        $filePath = public_path() . '/profile/upload/' . $fileName;
        if (!file_exists($filePath)) {
            return AjaxResult::error('文件不存在');
        }
        return response()->download($filePath);
    }
}
