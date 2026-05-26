# 外勤事由 textarea 宽度溢出修复计划

## 问题分析

用户选中了浏览器中渲染后的 DOM 结构：

```html
<uni-textarea class="outside-input">
  <div class="uni-textarea-wrapper">
    <textarea class="uni-textarea-textarea"></textarea>
  </div>
</uni-textarea>
```

**根因**：UniApp 的 `<textarea>` 组件在 H5 端编译为 `<uni-textarea>` 自定义组件，其内部 `.uni-textarea-wrapper` / `.uni-textarea-textarea` 有默认的宽度样式，导致即使外层 `.outside-input` 设了 `width: 100%`，内部实际渲染的 textarea 仍然超出父容器。

## 修改文件

`AppV3/src/pages/attendance/index.vue`

## 实施步骤

### 步骤1：给 .outside-input 添加穿透样式约束内部元素

通过深度选择器（`::v-deep` 或 `>>>`）限制 `uni-textarea` 内部子元素的宽度，防止溢出：

```scss
.outside-input {
  width: 100%;
  height: 100rpx;
  // ... 其他现有样式保持不变

  ::v-deep .uni-textarea-wrapper {
    width: 100%;
    box-sizing: border-box;
  }

  ::v-deep .uni-textarea-textarea {
    width: 100% !important;
    box-sizing: border-box;
  }
}
```

### 步骤2：确保 .outside-card 容器约束生效

确认 `.outside-card` 已有 `box-sizing: border-box` 和 `overflow: hidden`（已在上次修改中添加），双重保障不溢出。
