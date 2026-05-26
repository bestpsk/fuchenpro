# AppV3首页和订单列表修复计划

## 一、问题分析

### 问题1：首页"查看全部"跳转错误
**当前行为**：点击"查看全部"跳转到工作台页面
**期望行为**：跳转到订单管理列表页

**位置**：`AppV3/src/components/home/OrderList.vue` 第117-119行
```javascript
// 当前代码 - 错误
function handleMore() {
  uni.switchTab({ url: '/pages/work/index' })
}
```

### 问题2：订单列表状态标签显示"未知"
**原因**：模板中使用 `item.order_status ?? item.status` 获取状态值，但后端API返回的是驼峰命名 `orderStatus`

**位置**：`AppV3/src/pages/business/order/index.vue` 第51行
```html
<!-- 当前代码 -->
<view class="status-tag" :class="'status-' + (item.order_status ?? item.status)">
  {{ getOrderStatusName(item.order_status ?? item.status) }}
</view>
```

## 二、修改内容

### 2.1 首页"查看全部"跳转修复
**文件**：`AppV3/src/components/home/OrderList.vue`
**修改**：将跳转目标改为订单管理列表页

```javascript
// 修改后
function handleMore() {
  uni.navigateTo({ url: '/pages/business/order/index' })
}
```

### 2.2 订单列表状态字段兼容
**文件**：`AppV3/src/pages/business/order/index.vue`
**修改**：增加对驼峰字段名的支持

```html
<!-- 修改后 -->
<view class="status-tag" :class="'status-' + (item.order_status ?? item.orderStatus ?? item.status)">
  {{ getOrderStatusName(item.order_status ?? item.orderStatus ?? item.status) }}
</view>
```

## 三、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `AppV3/src/components/home/OrderList.vue` | "查看全部"跳转到订单管理列表 |
| 2 | `AppV3/src/pages/business/order/index.vue` | 状态字段兼容驼峰命名 |
