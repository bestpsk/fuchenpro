# 修复：首页下拉刷新过于敏感导致无法正常滚动

## 问题分析

首页使用 `scroll-view` + 自定义 refresher 下拉刷新，存在以下问题：

1. **refresher 触发阈值未配置** — 默认阈值约 50px，快速滑动时很容易误触
2. **无 `refresher-default-style`** — 默认样式可能影响滚动体验
3. **刷新时锁定 800ms** — 刷新期间 scroll-view 被锁定，用户感觉"划不动"

## 修复方案

### 修改文件：`AppV3/src/pages/index.vue`

对 `scroll-view` 做以下调整：

```html
<scroll-view
  scroll-y
  class="main-content"
  :style="{ height: scrollHeight }"
  @refresherrefresh="onPullDownRefresh"
  :refresher-enabled="true"
  :refresher-triggered="isRefreshing"
  :refresher-threshold="80"
  refresher-background="#F5F7FA"
>
```

| 属性 | 当前 | 修改后 | 说明 |
|------|------|--------|------|
| `refresher-threshold` | 未设置(默认50) | **80** | 提高触发阈值，减少误触 |
| `refresher-background` | 未设置(白色) | **#F5F7FA** | 与页面背景一致 |

同时优化刷新逻辑：去掉固定的 800ms 延迟，数据加载完成后立即停止刷新动画。
