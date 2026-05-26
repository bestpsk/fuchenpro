# 腾讯云COS图片显示问题修复

## 一、问题分析

### 现象
1. **Web端销售开单-操作抽屉**：上传图片后显示破损图标
2. **AppV3端档案详情**：图片显示"加载失败"

### 根本原因

#### 1. 后端上传接口返回格式（COS模式）
```json
{
  "code": 200,
  "fileName": "20260522/xxx.jpg",           // 相对路径
  "url": "https://xxx.cos.myqcloud.com/upload/20260522/xxx.jpg"  // 完整COS URL
}
```

#### 2. Web端ImageUpload组件问题
**文件**：`front/src/components/ImageUpload/index.vue` 第180行

```javascript
// 当前代码 - 存储相对路径
uploadList.value.push({ name: res.fileName, url: res.fileName })

// 问题：存储的是 fileName（相对路径），显示时会拼接本地baseUrl
// 结果：http://localhost:8080/profile/upload/20260522/xxx.jpg → 404错误
// 正确：应该存储 res.url（完整COS URL）
```

#### 3. AppV3端操作页面问题
**文件**：`AppV3/src/pages/business/sales/operation.vue` 第427-428行

```javascript
// 当前代码
const url = res.url || res.fileName  // ✅ 获取正确
form.beforePhoto.push({ url: e.url, name: url })  // ❌ e.url是本地临时路径！

// 问题：e.url 是 uni.chooseImage 返回的本地临时路径（如 file://xxx）
// 刷新后本地临时路径失效，图片无法显示
```

## 二、修改内容

### 2.1 Web端 ImageUpload组件修复
**文件**：`front/src/components/ImageUpload/index.vue`
**位置**：第180行

```javascript
// 修改前
uploadList.value.push({ name: res.fileName, url: res.fileName })

// 修改后 - 优先使用完整URL
uploadList.value.push({ name: res.fileName, url: res.url || res.fileName })
```

### 2.2 AppV3端操作页面修复
**文件**：`AppV3/src/pages/business/sales/operation.vue`
**位置**：第427-428行 和 第440-441行

```javascript
// 修改前
const url = res.url || res.fileName
form.beforePhoto.push({ url: e.url, name: url })

// 修改后 - 使用服务器返回的URL
const url = res.url || res.fileName
form.beforePhoto.push({ url: url, name: url })
```

afterPhoto 同理修改。

## 三、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `front/src/components/ImageUpload/index.vue` | 上传成功后优先存储res.url |
| 2 | `AppV3/src/pages/business/sales/operation.vue` | 使用服务器URL而非本地临时路径 |

## 四、已有数据兼容说明

对于数据库中已存储的相对路径数据，前端显示逻辑已有兼容处理：
- 如果URL以 `http` 开头，直接使用
- 否则拼接本地路径

但COS模式下需要确保存储的是完整URL。如需修复历史数据，可执行SQL将相对路径替换为完整COS URL。
