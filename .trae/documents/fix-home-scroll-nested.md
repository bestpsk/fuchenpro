# 修复：首页滚动卡顿 — 嵌套scroll-view冲突

## 根因分析

### 问题1：嵌套 scroll-view（核心问题）

页面存在 **双层嵌套 scroll-view**，这是UniApp中已知的滚动冲突场景：

```
index.vue
  └── <scroll-view> (main-content, 外层，带refresher下拉刷新)
       ├── NoticeBar
       ├── StatisticsCard
       └── OrderList.vue
            └── <scroll-view> (order-scroll, 内层嵌套!) ← 冲突根源
```

**现象解释**：
- 用户手指触摸到订单列表区域时，**内层 scroll-view 抢占触摸事件**
- 外层 scroll-view 失去控制 → 无法向下滚回顶部
- 这就是"划上去就划不下来"的直接原因

### 问题2：scrollHeight 高度计算错误

外层 scroll-view 高度 = `windowHeight`（全屏高度）
但 HeaderNav（状态栏+导航栏+欢迎语+快捷菜单）在 scroll-view 上方占据约 300-400rpx 的空间
→ scroll-view 实际高度超出了可视区域

## 修复方案

### 修改1：OrderList.vue — 去掉内层嵌套 scroll-view

将 `<scroll-view scroll-y>` 替换为普通 `<view>`，让内容自然跟随外层滚动：

```html
<!-- 修改前 -->
<scroll-view scroll-y class="order-scroll" :style="{ height: scrollHeight }">
  ...内容...
</scroll-view>

<!-- 修改后 -->
<view class="list-wrapper">
  ...内容...
</view>
```

同时删除 `scrollHeight` 计算属性（不再需要）

### 修改2：index.vue — 修正 scrollHeight 计算

减去 HeaderNav 区域的高度：

```javascript
const scrollHeight = computed(() => {
  const systemInfo = uni.getSystemInfoSync()
  // 状态栏 + 导航区(约88px) + 欢迎语 + 快捷菜单(约100px) ≈ 250px
  const headerHeight = systemInfo.statusBarHeight + 200
  return `${systemInfo.windowHeight - headerHeight}px`
})
```

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `AppV3/src/components/home/OrderList.vue` | 内层 scroll-view 改为普通 view |
| `AppV3/src/pages/index.vue` | 修正 scrollHeight 高度计算 |
