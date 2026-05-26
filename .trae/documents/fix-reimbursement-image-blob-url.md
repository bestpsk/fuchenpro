# 报销凭证图片问题修复计划

## 根本原因

### 问题1：数据库存储 blob URL 而非 COS URL

**上传接口响应格式**（CommonController.php 第32-37行）：
```php
return AjaxResult::success('', [
    'fileName' => $filename,
    'url' => $url,           // COS URL: https://mydream-xxx.cos.ap-shanghai.myqcloud.com/upload/xxx.jpg
    'newFileName' => basename($filename),
    'originalFilename' => $file->getUploadName(),
]);
```

由于 `AjaxResult::success('', $data)` 传入关联数组，数据被 merge 到响应顶层：
```json
{
  "code": 200,
  "msg": "操作成功",
  "fileName": "20260520/xxx.jpg",
  "url": "https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/20260520/xxx.jpg",
  "newFileName": "xxx.jpg",
  "originalFilename": "xxx.jpg"
}
```

**前端 updateVoucherImages 函数**（index.vue 第436-438行）：
```javascript
function updateVoucherImages(list) {
  const urls = list.filter(f => f.response?.data?.url || f.url).map(f => f.response?.data?.url || f.url)
  form.value.voucherImages = JSON.stringify(urls)
}
```

**问题链路**：
1. `f.response` = `{ code: 200, msg: '操作成功', fileName: '...', url: 'https://cos.../xxx.jpg', ... }`
2. `f.response?.data?.url` → **undefined**（因为 `url` 在顶层，不在 `data` 下）
3. 回退到 `f.url` → **`blob:http://192.168.2.74:8088/xxx`**（el-upload 内部预览 URL）
4. blob URL 被保存到数据库

**这就是为什么**：
- 上传后不刷新：blob URL 在同一浏览器会话有效，图片可显示
- 刷新/重新登录后：blob URL 失效，图片加载失败

### 问题2：编辑时图片不能放大预览

el-upload 的 picture-card 模式，外部回显的 fileList 没有绑定 `on-preview` 事件处理函数。

## 修复方案

### 步骤1：修复 updateVoucherImages 函数（核心修复）

**文件**：`front/src/views/finance/reimbursement/index.vue` 第436-438行

**修改前**：
```javascript
function updateVoucherImages(list) {
  const urls = list.filter(f => f.response?.data?.url || f.url).map(f => f.response?.data?.url || f.url)
  form.value.voucherImages = JSON.stringify(urls)
}
```

**修改后**：
```javascript
function updateVoucherImages(list) {
  const urls = list.map(f => {
    if (f.response && f.response.url) return f.response.url
    if (f.response && f.response.data && f.response.data.url) return f.response.data.url
    if (f.url && !f.url.startsWith('blob:')) return f.url
    return ''
  }).filter(url => url)
  form.value.voucherImages = JSON.stringify(urls)
}
```

**逻辑说明**：
1. 优先取 `f.response.url`（上传接口响应的顶层 url 字段）
2. 其次取 `f.response.data.url`（兼容 data 嵌套格式）
3. 最后取 `f.url`（但排除 blob URL）
4. 过滤掉空值

### 步骤2：修复 handleUpdate 中的图片回显

**文件**：`front/src/views/finance/reimbursement/index.vue` handleUpdate 函数

**修改前**：
```javascript
const images = parseImages(data.voucherImages)
fileList.value = images.map((url, idx) => ({
  name: 'img' + idx,
  url: url,
  response: { data: { url: url } }
}))
```

**修改后**：
```javascript
const images = parseImages(data.voucherImages)
fileList.value = images.map((url, idx) => ({
  name: 'img' + idx,
  url: url,
  response: { url: url }
}))
```

**说明**：`response` 结构需要与上传成功后的格式一致（url 在顶层），这样 `updateVoucherImages` 才能正确提取 URL。

### 步骤3：添加编辑弹窗图片预览功能

**文件**：`front/src/views/finance/reimbursement/index.vue`

**3a. 为 el-upload 添加 on-preview 事件**（第127行）：
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
```

**3b. 添加预览相关变量和函数**：
```javascript
const previewVisible = ref(false)
const previewUrl = ref('')

function handlePreview(file) {
  const url = file.response?.url || file.response?.data?.url || file.url
  if (url && !url.startsWith('blob:')) {
    previewUrl.value = url
    previewVisible.value = true
  }
}
```

**3c. 添加预览对话框**（在模板中）：
```vue
<el-dialog v-model="previewVisible" title="图片预览" width="600px" append-to-body>
  <img :src="previewUrl" style="width: 100%" />
</el-dialog>
```

### 步骤4：修复已有数据库中的 blob URL 数据

对于已经保存了 blob URL 的记录，需要手动修复数据库数据。

**SQL 修复脚本**（需要根据实际情况调整）：
```sql
-- 查看受影响的记录
SELECT reimbursement_id, voucher_images FROM fin_reimbursement WHERE voucher_images LIKE '%blob:%';

-- 由于 blob URL 无法还原为 COS URL，这些记录的图片数据已无法恢复
-- 只能清空无效的图片数据
UPDATE fin_reimbursement SET voucher_images = '[]' WHERE voucher_images LIKE '%blob:%';
```

**注意**：已保存的 blob URL 无法还原为 COS URL，这些图片数据已丢失。修复后需要用户重新上传。

## 执行顺序

1. 修复 `updateVoucherImages` 函数（核心）
2. 修复 `handleUpdate` 中的图片回显
3. 添加编辑弹窗图片预览功能
4. 修复数据库中的 blob URL 数据

## 预期效果

修复后：
- ✅ 上传图片后，COS URL 正确保存到数据库
- ✅ 刷新页面后图片正常显示
- ✅ 重新登录后图片正常显示
- ✅ 编辑弹窗中点击图片可放大预览
- ✅ 详情弹窗中图片可点击放大预览（已有功能）
