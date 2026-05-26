# 订单金额字段存储优化计划

## 一、问题分析

### 当前各订单类型金额字段存储情况

| 订单类型 | source_type | deal_amount | paid_amount | owed_amount | 问题 |
|---------|-------------|-------------|-------------|-------------|------|
| 开单订单 | 0 | 成交金额 | 实付金额 | 成交-实付 | ✅ 正确 |
| 操作订单 | 1 | 消耗金额 | 0 | 0 | ✅ 正确 |
| 还款订单 | 2 | **还款金额** | 还款金额 | 0 | ❌ deal_amount应为0 |

### 问题说明
还款订单当前把还款金额同时存到 `deal_amount` 和 `paid_amount`，但还款是偿还之前的欠款，不是新的"成交"行为，`deal_amount` 应该为 0。

## 二、优化方案

### 目标存储结构

| 订单类型 | source_type | deal_amount | paid_amount | owed_amount | 显示说明 |
|---------|-------------|-------------|-------------|-------------|----------|
| 开单订单 | 0 | 成交金额 | 实付金额 | 成交-实付 | 三列都显示 |
| 操作订单 | 1 | 消耗金额 | 0 | 0 | 只显示成交金额（消耗） |
| 还款订单 | 2 | **0** | 还款金额 | 0 | 只显示实付金额（还款） |

### 前端显示逻辑
保持三列（成交金额、实付金额、欠款金额），值为0时显示灰色"-"：
- 开单订单：三列都有值，正常显示
- 操作订单：成交金额有值（消耗），实付和欠款显示"-"
- 还款订单：实付金额有值（还款），成交和欠款显示"-"

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

### 3.2 Web端显示优化

**文件**：`front/src/views/business/order/index.vue`

**修改**：成交金额、实付金额、欠款金额列，值为0时显示灰色"-"

```vue
<el-table-column label="成交金额" align="right" prop="dealAmount" width="100">
  <template #default="scope">
    <span v-if="Number(scope.row.dealAmount || 0) > 0" style="color: #409eff; font-weight: 500">
      {{ Number(scope.row.dealAmount).toFixed(2) }}
    </span>
    <span v-else style="color: #909399">-</span>
  </template>
</el-table-column>
<el-table-column label="实付金额" align="right" prop="paidAmount" width="100">
  <template #default="scope">
    <span v-if="Number(scope.row.paidAmount || 0) > 0" style="color: #67c23a; font-weight: 500">
      {{ Number(scope.row.paidAmount).toFixed(2) }}
    </span>
    <span v-else style="color: #909399">-</span>
  </template>
</el-table-column>
<el-table-column label="欠款金额" align="right" prop="owedAmount" width="100">
  <template #default="scope">
    <span v-if="Number(scope.row.owedAmount || 0) > 0" style="color: #f56c6c; font-weight: 500">
      {{ Number(scope.row.owedAmount).toFixed(2) }}
    </span>
    <span v-else style="color: #909399">-</span>
  </template>
</el-table-column>
```

### 3.3 AppV3端显示优化

**文件**：`AppV3/src/pages/business/order/index.vue`

**修改**：订单卡片金额显示，根据值是否为0决定显示

**文件**：`AppV3/src/pages/business/order/detail.vue`

**修改**：详情页金额显示，根据值是否为0决定显示

## 四、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `webman/app/service/BizRepaymentService.php` | 还款订单deal_amount改为0 |
| 2 | `front/src/views/business/order/index.vue` | 金额列值为0时显示"-" |
| 3 | `AppV3/src/pages/business/order/index.vue` | 金额显示优化 |
| 4 | `AppV3/src/pages/business/order/detail.vue` | 金额显示优化 |

## 五、数据迁移（可选）

如果需要修正已有的还款订单数据，可执行SQL：
```sql
UPDATE biz_sales_order SET deal_amount = 0 WHERE source_type = '2' AND deal_amount > 0;
```
