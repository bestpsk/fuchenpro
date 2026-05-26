# 订单列表：显示完整订单编号 + 类型Tag

## 问题
1. 列表页订单编号显示为 SO10、SO9 等简短格式（因为 `order_no` 可能为空，走了 fallback）
2. 详情页能正确显示 SO202605120005 完整编号
3. 需要在编号后面加类型 Tag：销售 / 还款 / 操作

## 分析
- 当前列表接口 `/business/sales/list` 只返回销售订单数据，`biz_sales_order` 表有 `order_no` 字段（如 SO202605120005）
- 列表页 fallback `'SO' + order_id` 说明后端可能没返回 `order_no` 字段或字段名为空
- 当前页面只展示销售订单类型，后续可能需要聚合还款和操作记录

## 修改文件

`AppV3/src/pages/business/order/index.vue`

### 模板改动
- 第47行：order-no 文本改为优先使用实际 `order_no`
- 第47-48行之间：在 order-no 和 status-tag 之间插入**类型 Tag**

```html
<view class="card-header">
  <text class="order-no">{{ displayOrderNo(item) }}</text>
  <view class="type-tag" :class="'type-' + getOrderType(item)">{{ getOrderTypeName(item) }}</view>
  <view class="status-tag" ...>{{ getOrderStatusName(...) }}</view>
</view>
```

### 脚本改动
新增两个函数：

- `displayOrderNo(item)` — 返回完整订单编号，fallback 用 ID 补全
- `getOrderType(item)` / `getOrderTypeName(item)` — 返回订单类型标识/名称

当前列表只有销售订单，默认返回 `'sale'` / `'销售'`。预留扩展：
- `sale` → 销售（蓝色）
- `repay` → 还款（绿色）
- `operation` → 操作（橙色）

### 样式改动
新增 `.type-tag` 及其变体样式：
- `.type-sale` → 蓝色背景 #E8F0FE + 蓝字 #3D6DF7
- `.type-repay` → 绿色背景 #E8FFEA + 绿字 #00B42A
- `.type-operation` → 橙色背景 #FFF7E8 + 橙字 #FF7D00
