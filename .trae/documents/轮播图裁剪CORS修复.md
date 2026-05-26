# 轮播图裁剪 CORS 跨域错误修复

## 问题分析

错误：`net::ERR_FAILED https://mydream-1302682813.cos.ap-shanghai.myqcloud.com/upload/...`

**根因**：编辑已有轮播图时，`onCropOpened()` 将 COS 完整 URL 传给 `vue-cropper`，`vue-cropper` 内部用 canvas 绘制图片，浏览器因 CORS 策略阻止跨域图片的 canvas 读取。

**触发链路**：
1. 用户点击"修改"轮播图 → `handleUpdate()` → `form.image = "/profile/upload/..."`
2. 用户点击图片上的"点击重新裁剪" → `openCropDialog()`
3. `onCropOpened()` → `cropOptions.img = getImageUrl(form.image)` → 拼接为完整 COS URL
4. `vue-cropper` 尝试加载该 URL → `checkedImg()` → canvas 绘制 → CORS 阻止 → `ERR_FAILED`

## 修复方案

**不在裁剪弹窗中预加载已有远程图片**。改为：
- 裁剪弹窗打开时，如果有已有图片，显示静态预览提示"请选择新图片替换"
- 只有用户主动选择本地文件后，才将图片加载到 `vue-cropper` 裁剪
- 这样完全避免了跨域加载远程图片的问题

## 修改文件

`front/src/views/system/banner/index.vue`

## 实施步骤

### 步骤1：修改 onCropOpened，不加载远程图片

```javascript
function onCropOpened() {
  cropVisible.value = true
  // 不再加载远程图片到裁剪器，避免CORS问题
  // 用户需要选择新的本地图片进行裁剪
}
```

### 步骤2：在裁剪弹窗中添加已有图片的静态预览提示

在裁剪弹窗的 vue-cropper 区域，当没有选择新图片但已有远程图片时，显示静态预览：

```html
<el-col :span="16" style="height: 400px">
  <vue-cropper ... v-if="cropVisible && cropOptions.img" />
  <div v-else-if="cropVisible && !cropOptions.img" class="crop-placeholder">
    <el-icon :size="48" color="#c0c4cc"><Plus /></el-icon>
    <p>请点击下方"选择图片"按钮选取本地图片</p>
  </div>
</el-col>
```

### 步骤3：添加占位区域样式

```scss
.crop-placeholder {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  border-radius: 8px;
  border: 1px dashed #dcdfe6;
  color: #909399;
  font-size: 14px;
}
```
