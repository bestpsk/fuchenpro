# 还款订单金额字段优化计划

## 一、问题分析

### 当前实现
还款订单创建时（BizRepaymentService.php 第131-133行）：
```php
'deal_amount' => $repaymentAmount,  // 还款金额
'paid_amount' => $repaymentAmount,  // 还款金额
'owed_amount' => 0,
```

### 问题
- 还款是偿还之前的欠款，不是新的"成交"（销售）行为
- 把还款金额同时存到 `deal_amount` 和 `paid_amount`，语义上有歧义
- 在订单列表中，还款订单会显示"成交金额 = 还款金额"，但实际上这不是一笔新的成交

### 优化方案
```php
'deal_amount' => 0,                 // 0表示不是新的成交
'paid_amount' => $repaymentAmount,  // 实际收到的还款金额
'owed_amount' => 0,
```

## 二、各订单类型金额字段对比

| 订单类型 | source_type | deal_amount | paid_amount | owed_amount | 说明 |
|---------|-------------|-------------|-------------|-------------|------|
| 开单订单 | 0 | 成交金额 | 实付金额 | 成交-实付 | 正常销售，三者都显示 |
| 操作订单 | 1 | 消耗金额 | 0 | 0 | 消耗已购套餐，只显示消耗金额 |
| 还款订单 | 2 | **0** | 还款金额 | 0 | 偿还欠款，只显示还款金额 |

## 三、修改内容

### 3.1 后端修改
**文件**：`webman/app/service/BizRepaymentService.php`
**位置**：第131行
**修改**：
```php
// 修改前
'deal_amount' => $repaymentAmount,
'paid_amount' => $repaymentAmount,
'owed_amount' => 0,

// 修改后
'deal_amount' => 0,
'paid_amount' => $repaymentAmount,
'owed_amount' => 0,
```

### 3.2 前端显示优化
由于还款订单的 `deal_amount = 0`，前端在显示时需要根据 `source_type` 来判断显示哪个字段：

**订单列表显示逻辑**：
- `source_type = 0`（开单）：显示 deal_amount（成交金额）
- `source_type = 1`（操作）：显示 deal_amount（消耗金额）
- `source_type = 2`（还款）：显示 paid_amount（还款金额）

**当前前端实现已兼容**：
- `front/order/index.vue`：金额列显示 `deal_amount || dealAmount || totalAmount`
- `AppV3/order/index.vue`：金额列显示 `deal_amount || dealAmount || totalAmount`

需要修改为根据 source_type 判断显示字段。

## 四、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `webman/app/service/BizRepaymentService.php` | 还款订单deal_amount改为0 |
| 2 | `front/src/views/business/order/index.vue` | 金额列根据source_type显示 |
| 3 | `AppV3/src/pages/business/order/index.vue` | 金额列根据source_type显示 |
| 4 | `AppV3/src/pages/business/order/detail.vue` | 金额显示根据source_type调整 |
