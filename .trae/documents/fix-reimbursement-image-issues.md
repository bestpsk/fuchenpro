# 报销凭证图片问题修复计划

## 问题现象

### 问题1：编辑时图片不能点击放大

* 编辑报销弹窗中，凭证图片显示正常（有缩略图）

* 点击图片上的放大镜图标无法触发预览

### 问题2：刷新页面后图片加载失败（严重）

* 图片上传后不刷新页面：可以正常查看/编辑

* 刷新页面或重新登录后：详情页显示"加载失败"

## 根本原因分析

### 问题1分析：el-upload 组件的图片预览机制

**当前代码** (index.vue 第127行)：

```vue
<el-upload :action="uploadUrl" list-type="picture-card" :file-list="fileList">
```

**回显时的 fileList 格式** (第348-352行)：

```javascript
fileList.value = images.map((url, idx) => ({
  name: 'img' + idx,
  url: url,                              // ← 用于显示缩略图
  response: { data: { url: url } }       // ← 上传响应结构
}))
```

**Element Plus el-upload 的 picture-card 预览机制**：

* 组件内部使用 `ElImage` 组件渲染缩略图

* 点击放大需要依赖组件内部的 `handlePreview` 方法

* 该方法会读取 `file.url` 或 `file.response.url`

* **关键问题**：如果 `fileList` 是外部传入的（非用户上传），组件可能不会正确绑定预览事件

### 问题2分析：COS URL 访问权限

**COS 服务返回的 URL 格式** (CosService.php 第140-148行)：

```php
public function getUrl(string $cosPath): string
{
    return sprintf(
        'https://%s.cos.%s.myqcloud.com/%s',
        $this->config['bucket'],      // mydream-1302682813
        $this->config['region'],      // ap-shanghai
        $cosPath                        // upload/20260520/xxx.jpg
    );
}
// 返回示例：https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260520/xxx.jpg
```

**这是标准的公开读 URL（无签名）**

**为什么上传后可以访问，刷新后不行？**

| 场景      | 行为     | 原因                |
| ------- | ------ | ----------------- |
| 上传后立即查看 | ✅ 正常   | 浏览器可能有缓存，或同一会话内有效 |
| 刷新页面    | ❌ 加载失败 | 浏览器重新请求，被 COS 拒绝  |

**最可能的原因**：

#### 原因A：COS 存储桶权限不是"公有读"

* 腾讯云 COS 默认权限是"私有读写"

* 公开读 URL 只能在存储桶设置为"公有读"时才有效

* 如果是私有权限，需要签名 URL 才能访问

#### 原因B：COS 防盗链设置

* COS 可以设置 Referer 白名单

* 如果设置了防盗链，浏览器直接访问会被拒绝

* 只有从指定域名发起的请求才能访问

#### 原因C：CORS 跨域问题

* 如果前端域名与 COS 域名不同

* 可能存在跨域访问限制

## 修复方案

### 方案A：修复编辑时图片放大功能（前端）

**方法1：为 el-upload 添加预览插槽（推荐）**

修改编辑表单中的 el-upload 组件：

```vue
<el-upload
  :action="uploadUrl"
  list-type="picture-card"
  :file-list="fileList"
  :headers="uploadHeaders"
  :on-success="handleUploadSuccess"
  :on-remove="handleUploadRemove"
  :on-preview="handlePreview"
  accept="image/*"
>
  <el-icon><Plus /></el-icon>
</el-upload>

<!-- 添加图片预览 -->
<el-image-viewer
  v-if="showPreview"
  :url-list="previewUrls"
  @close="showPreview = false"
/>
```

添加预览相关函数：

```javascript
const showPreview = ref(false)
const previewUrls = ref([])

function handlePreview(file) {
  previewUrls.value = [file.url || file.response?.data?.url]
  showPreview.value = true
}
```

**方法2：使用 el-image 替代 el-upload 的内置预览**

### 方案B：解决刷新后图片加载失败问题

#### 子方案B1：检查并配置 COS 存储桶权限（推荐）

**操作步骤**：

1. 登录腾讯云控制台 → 对象存储 → 存储桶列表
2. 找到 `mydream-1302682813` 存储桶
3. 点击「基础配置」→「访问权限」
4. 确认权限设置为 **「公有读私有写」**
5. 如果是「私有读写」，修改为「公有读私有写」

**验证方法**：

* 直接在浏览器地址栏输入 COS URL

* 如果能正常显示图片，说明权限正确

* 如果显示 AccessDenied 或 403，说明权限不足

#### 子方案B2：使用签名 URL（如果必须保持私有权限）

如果 COS 必须保持私有权限，需要修改后端返回签名 URL：

**修改 CosService.php**：

```php
// 添加签名URL生成方法
public function getSignedUrl(string $cosPath, int $expiresInSeconds = 3600): string
{
    $signedUrl = $this->client->getObjectUrl(
        [
            'Bucket' => $this->config['bucket'],
            'Key' => $cosPath,
            'Sign' => ['Expires' => $expiresInSeconds],
        ]
    );
    return $signedUrl;
}

// 修改 getUrl 方法，返回签名 URL
public function getUrl(string $cosPath): string
{
    // 返回签名URL，有效期1小时
    return $this->getSignedUrl($cosPath, 3600);
}
```

**缺点**：

* 签名 URL 有时效性（默认1小时）

* 刷新页面后如果过期仍会失败

* 不适合长期展示的场景

#### 子方案B3：添加后端图片代理接口（最稳定）

**新增控制器方法**：

```php
// CommonController.php
public function proxyImage(Request $request)
{
    $url = $request->input('url', '');
    
    // 安全检查：只允许代理本项目的 COS URL
    $allowedDomain = config('cos.bucket') . '.cos.' . config('cos.region') . '.myqcloud.com';
    if (strpos($url, $allowedDomain) === false) {
        return AjaxResult::error('非法请求');
    }

    // 使用 COS SDK 获取对象内容
    $cosService = new CosService();
    $cosPath = $cosService->parsePathFromUrl($url);
    
    if (!$cosPath) {
        return AjaxResult::error('无效的URL');
    }

    try {
        $client = $cosService->getClient();
        $result = $client->getObject([
            'Bucket' => config('cos.bucket'),
            'Key' => $cosPath,
        ]);
        
        // 设置正确的 Content-Type
        $contentType = $result['ContentType'] ?? 'image/jpeg';
        header('Content-Type: ' . $contentType);
        header('Cache-Control: public, max-age=86400'); // 缓存24小时
        
        echo $result['Body'];
    } catch (\Exception $e) {
        http_response_code(404);
        echo '图片不存在';
    }
}
```

**前端修改**：

```javascript
// 将 COS URL 转换为代理 URL
function getProxyUrl(cosUrl) {
  return import.meta.env.VITE_APP_BASE_API + '/common/proxy-image?url=' + encodeURIComponent(cosUrl)
}

// 在 parseImages 中使用代理
function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) {
      return parsed.filter(url => url && typeof url === 'string').map(url => getProxyUrl(url))
    }
    return []
  } catch (e) {
    console.error('图片解析失败:', e, jsonStr)
    return []
  }
}
```

## 推荐执行顺序

### 阶段1：快速诊断（确定根本原因）

1. 在浏览器直接访问一张 COS URL（从数据库中获取）
2. 确认是否能正常显示图片
3. 如果能显示 → 问题在前端解析或缓存
4. 如果不能显示 → COS 权限问题

### 阶段2：修复编辑放大功能

1. 为 el-upload 添加 `:on-preview` 事件处理
2. 添加 `el-image-viewer` 组件实现预览

### 阶段3：根据诊断结果修复加载失败

1. **如果是 COS 权限问题**：修改存储桶为"公有读私有写"
2. **如果必须保持私有**：实施子方案 B2 或 B3

## 风险评估

| 方案          | 改动量   | 稳定性      | 推荐度   |
| ----------- | ----- | -------- | ----- |
| A1 (预览插槽)   | 小     | 高        | ⭐⭐⭐⭐⭐ |
| B1 (改COS权限) | 无代码改动 | 取决于运维    | ⭐⭐⭐⭐⭐ |
| B2 (签名URL)  | 中     | 中（有时效限制） | ⭐⭐⭐   |
| B3 (代理接口)   | 大     | 高        | ⭐⭐⭐⭐  |

## 预期效果

修复后：

* ✅ 编辑时点击图片可正常放大预览

* ✅ 详情页图片正常显示，无"加载失败"

* ✅ 刷新页面后图片仍然可用

* ✅ 重新登录后图片仍然可用

