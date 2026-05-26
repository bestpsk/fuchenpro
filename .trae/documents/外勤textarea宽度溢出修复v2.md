# 外勤事由 textarea 宽度溢出修复计划（第二次）

## 问题分析

之前的 `::v-deep` 方案未生效，问题仍然存在。重新分析根因：

### DOM 渲染结构
```html
<uni-textarea class="outside-input">   ← class 应用在此元素上
  <div class="uni-textarea-wrapper">
    <textarea class="uni-textarea-textarea"></textarea>
  </div>
</uni-textarea>
```

### 真正的根因

`.outside-input` 样式设置了 `width: 100%` + `padding: 20rpx`，但**缺少 `box-sizing: border-box`**！

在默认的 `content-box` 模型下：
- 实际宽度 = 100%父宽 + 左padding(20rpx) + 右padding(20rpx) = 超出父容器 40rpx

这就是为什么 textarea 始终比 card 宽 40rpx 的原因。

### 之前的 `::v-deep` 为什么没生效

1. `.outside-input` 本身就缺 `box-sizing: border-box`，内部子元素再怎么约束也没用
2. Vue 3 推荐的深度选择器语法是 `:deep()` 而非 `::v-deep`

## 修改文件

`AppV3/src/pages/attendance/index.vue`

## 实施步骤

### 步骤1：给 .outside-input 添加 box-sizing: border-box

这是核心修复——让 padding 包含在 100% 宽度内，不再溢出：

```scss
.outside-input {
  width: 100%;
  height: 100rpx;
  box-sizing: border-box;   // 新增：核心修复
  background: #F7F8FA;
  border-radius: 14rpx;
  padding: 20rpx;
  // ...
}
```

### 步骤2：修正深度选择器语法

将 `::v-deep` 改为 Vue 3 推荐的 `:deep()` 语法，确保样式能穿透到 uni-textarea 内部：

```scss
.outside-input {
  // ...

  :deep(.uni-textarea-wrapper) {
    width: 100%;
    box-sizing: border-box;
  }

  :deep(.uni-textarea-textarea) {
    width: 100% !important;
    box-sizing: border-box;
  }
}
```

### 步骤3：移除 .outside-card 的 overflow: hidden

溢出根因修复后，不再需要 `overflow: hidden` 来掩盖问题，移除以避免内容被意外裁剪。
