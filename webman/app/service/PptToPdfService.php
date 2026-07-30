<?php

namespace app\service;

/**
 * PPT/PPTX 转 PDF 服务（基于 LibreOffice headless）
 * - 懒转换：首次预览时触发，结果缓存为同名 .pdf 文件
 * - mtime 失效：源文件更新后自动重转
 * - 并发安全：flock 防止多请求重复执行
 */
class PptToPdfService
{
    /**
     * 获取或创建 PPT 对应的 PDF（带缓存）
     *
     * @param string $pptAbsPath PPT 源文件绝对路径
     * @return string 转换后的 PDF 绝对路径
     * @throws \Exception
     */
    public function getOrCreatePdf(string $pptAbsPath): string
    {
        $pdfPath = substr($pptAbsPath, 0, strrpos($pptAbsPath, '.')) . '.pdf';

        // 缓存命中：PDF 已存在且不早于源文件修改时间
        if (is_file($pdfPath) && filemtime($pdfPath) >= filemtime($pptAbsPath)) {
            return $pdfPath;
        }

        // 文件锁防并发重复转换
        $lockPath = $pdfPath . '.lock';
        $lock = fopen($lockPath, 'c');
        if (!$lock || !flock($lock, LOCK_EX)) {
            throw new \Exception('PPT 转换忙，请稍后重试');
        }
        try {
            // 二次检查：其他进程可能已完成转换
            if (is_file($pdfPath) && filemtime($pdfPath) >= filemtime($pptAbsPath)) {
                return $pdfPath;
            }
            @unlink($pdfPath);
            $this->runConversion($pptAbsPath, dirname($pptAbsPath));
            if (!is_file($pdfPath)) {
                throw new \Exception('LibreOffice 转换未生成 PDF');
            }
            return $pdfPath;
        } finally {
            @flock($lock, LOCK_UN);
            @fclose($lock);
            @unlink($lockPath);
        }
    }

    /**
     * 执行 LibreOffice headless 转换
     *
     * @param string $pptPath PPT 源文件路径
     * @param string $outDir  输出目录
     * @throws \Exception
     */
    private function runConversion(string $pptPath, string $outDir): void
    {
        $soffice = $this->getSofficePath();

        // 指定 LibreOffice 用户配置目录（固定路径，确保字体缓存可写且一致）
        $userInstallation = 'file:///tmp/libreoffice_user';

        $cmd = escapeshellarg($soffice)
             . ' --headless --norestore --convert-to pdf'
             . ' -env:UserInstallation=' . escapeshellarg($userInstallation)
             . ' --outdir ' . escapeshellarg($outDir) . ' ' . escapeshellarg($pptPath);

        $descriptors = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        // 传递环境变量：HOME（LibreOffice 配置目录）、LANG/LC_ALL（中文字体渲染）
        $env = array_merge(getenv(), [
            'HOME' => '/tmp',
            'LANG' => 'zh_CN.UTF-8',
            'LC_ALL' => 'zh_CN.UTF-8',
        ]);

        $proc = proc_open($cmd, $descriptors, $pipes, null, $env);
        if (!is_resource($proc)) {
            throw new \Exception('无法启动 LibreOffice 进程');
        }
        fclose($pipes[0]);
        $stdout = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);
        fclose($pipes[2]);
        $code = proc_close($proc);
        if ($code !== 0) {
            error_log('[PPT->PDF] LibreOffice 退出码 ' . $code . ' stderr: ' . $stderr . ' stdout: ' . $stdout);
            throw new \Exception('LibreOffice 退出码 ' . $code . ': ' . trim($stderr . ' ' . $stdout));
        }
    }

    /**
     * 解析 LibreOffice 可执行文件路径
     * 优先取 .env 的 LIBREOFFICE_PATH，否则尝试常见安装路径
     *
     * @return string
     * @throws \Exception
     */
    private function getSofficePath(): string
    {
        $env = getenv('LIBREOFFICE_PATH');
        if ($env && is_file($env)) {
            return $env;
        }
        $candidates = [
            // Windows：优先 soffice.com（控制台版本，会等待转换完成并输出 stdout/stderr）
            'C:\Program Files\LibreOffice\program\soffice.com',
            'C:\Program Files\LibreOffice\program\soffice.exe',
            'C:\Program Files (x86)\LibreOffice\program\soffice.com',
            'C:\Program Files (x86)\LibreOffice\program\soffice.exe',
            '/usr/bin/soffice',
            '/usr/local/bin/soffice',
        ];
        foreach ($candidates as $c) {
            if (is_file($c)) {
                return $c;
            }
        }
        throw new \Exception('未找到 LibreOffice，请在 .env 配置 LIBREOFFICE_PATH');
    }
}
