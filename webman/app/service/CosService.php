<?php

namespace app\service;

use Qcloud\Cos\Client;

/**
 * 腾讯云COS对象存储服务层
 *
 * 提供文件上传、删除、URL获取等功能，支持通过配置开关切换COS和本地存储
 */
class CosService
{
    private ?Client $client = null;
    private array $config;

    // 初始化COS客户端配置
    public function __construct()
    {
        $this->config = config('cos');
        if ($this->config['enabled'] && !empty($this->config['secret_id']) && !empty($this->config['secret_key'])) {
            $this->client = new Client([
                'region' => $this->config['region'],
                'schema' => 'https',
                'credentials' => [
                    'secretId' => $this->config['secret_id'],
                    'secretKey' => $this->config['secret_key'],
                ],
            ]);
        }
    }

    // 判断COS是否已启用且配置正确
    public function isEnabled(): bool
    {
        return $this->config['enabled'] && $this->client !== null;
    }

    // 上传文件到COS，返回完整URL；若COS未启用则返回null
    public function upload(string $localPath, string $cosPath): ?string
    {
        if (!$this->isEnabled()) {
            return null;
        }

        try {
            $this->client->putObject([
                'Bucket' => $this->config['bucket'],
                'Key' => $cosPath,
                'Body' => fopen($localPath, 'rb'),
            ]);
            return $this->getUrl($cosPath);
        } catch (\Exception $e) {
            \support\Log::error('COS上传失败: ' . $e->getMessage());
            return null;
        }
    }

    // 直接上传文件内容（无需临时文件），返回完整URL
    public function uploadContent(string $content, string $cosPath): ?string
    {
        if (!$this->isEnabled()) {
            return null;
        }

        try {
            $this->client->putObject([
                'Bucket' => $this->config['bucket'],
                'Key' => $cosPath,
                'Body' => $content,
            ]);
            return $this->getUrl($cosPath);
        } catch (\Exception $e) {
            \support\Log::error('COS上传失败: ' . $e->getMessage());
            return null;
        }
    }

    // 从上传的文件对象直接上传到COS，返回完整URL
    public function uploadFile($file, string $cosPath): ?string
    {
        if (!$this->isEnabled()) {
            return null;
        }

        try {
            $tmpPath = $file->getRealPath();
            if (!$tmpPath) {
                $tmpPath = sys_get_temp_dir() . '/' . uniqid('cos_');
                move_uploaded_file($file->getTmpName(), $tmpPath);
            }

            $result = $this->client->putObject([
                'Bucket' => $this->config['bucket'],
                'Key' => $cosPath,
                'Body' => fopen($tmpPath, 'rb'),
            ]);

            if (strpos($tmpPath, sys_get_temp_dir()) === 0) {
                @unlink($tmpPath);
            }

            return $this->getUrl($cosPath);
        } catch (\Exception $e) {
            \support\Log::error('COS上传失败: ' . $e->getMessage());
            return null;
        }
    }

    // 删除COS上的文件
    public function delete(string $cosPath): bool
    {
        if (!$this->isEnabled()) {
            return false;
        }

        try {
            $this->client->deleteObject([
                'Bucket' => $this->config['bucket'],
                'Key' => $cosPath,
            ]);
            return true;
        } catch (\Exception $e) {
            \support\Log::error('COS删除失败: ' . $e->getMessage());
            return false;
        }
    }

    // 根据URL删除COS文件
    public function deleteByUrl(string $url): bool
    {
        $cosPath = $this->parsePathFromUrl($url);
        if ($cosPath) {
            return $this->delete($cosPath);
        }
        return false;
    }

    // 获取COS文件的完整访问URL
    public function getUrl(string $cosPath): string
    {
        return sprintf(
            'https://%s.cos.%s.myqcloud.com/%s',
            $this->config['bucket'],
            $this->config['region'],
            $cosPath
        );
    }

    // 从完整URL解析出COS路径
    public function parsePathFromUrl(string $url): ?string
    {
        $baseUrl = sprintf(
            'https://%s.cos.%s.myqcloud.com/',
            $this->config['bucket'],
            $this->config['region']
        );
        if (strpos($url, $baseUrl) === 0) {
            return substr($url, strlen($baseUrl));
        }
        return null;
    }

    // 判断URL是否为COS URL
    public function isCosUrl(string $url): bool
    {
        $baseUrl = sprintf(
            'https://%s.cos.%s.myqcloud.com/',
            $this->config['bucket'],
            $this->config['region']
        );
        return strpos($url, $baseUrl) === 0;
    }
}
