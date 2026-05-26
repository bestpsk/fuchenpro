# AppV3订单列表门店显示格式优化

## 一、问题分析

**当前显示**：门店只显示 `store_name`（如"宜川店"）
**期望显示**：`企业名称·门店名称`（如"逆龄奢·宜川店"）

## 二、修改内容

### 文件：`AppV3/src/pages/business/order/index.vue`

**位置**：第56行
```html
<!-- 修改前 -->
<view class="info-item"><text class="label">门店</text><text class="value">{{ item.store_name || item.storeName || '-' }}</text></view>

<!-- 修改后 -->
<view class="info-item"><text class="label">门店</text><text class="value">{{ getStoreDisplay(item) }}</text></view>
```

**新增函数**：
```javascript
function getStoreDisplay(item) {
  const enterprise = item.enterprise_name || item.enterpriseName || ''
  const store = item.store_name || item.storeName || ''
  if (enterprise && store) return `${enterprise}·${store}`
  if (store) return store
  return '-'
}
```

## 三、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `AppV3/src/pages/business/order/index.vue` | 门店显示改为"企业·门店"格式 |
