# 修复订单列表显示异常

## 问题分析

从截图对比：
- **订单列表页**：金额显示 ¥0.00，状态显示"未知"
- **订单详情页**：金额正确显示 ¥200.00，状态正确显示"已完成"

### 根本原因

后端返回 **snake_case** 字段名（如 `deal_amount`、`order_status`、`customer_name`），但列表页使用了 **camelCase** 字段名（如 `totalAmount`、`status`、`customerName`）。

详情页之所以正常，是因为它做了多字段名兼容（detail.vue 第52行）：
```js
orderInfo.dealAmount || orderInfo.deal_amount || orderInfo.totalAmount || '0.00'
```

而列表页没有做兼容处理。

## 需要修改的字段映射

| 列表页当前字段 | 后端实际返回字段 |
|--------------|---------------|
| `item.status` | `item.order_status` |
| `item.totalAmount` | `item.deal_amount` |
| `item.customerName` | `item.customer_name` |
| `item.storeName` | `item.store_name` |
| `item.createTime` | `item.create_time` |
| `item.orderNo` | `item.order_no` |
| `item.orderId` | `item.order_id` |

## 修改文件

`AppV3/src/pages/business/order/index.vue`：
- 模板中所有字段引用改为 snake_case
- `getOrderStatusName()` 的 status 比较逻辑适配后端返回值
