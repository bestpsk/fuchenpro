# 订单金额显示优化计划

## 一、问题分析

当前订单列表有三列金额：成交金额、实付金额、欠款金额，但不同订单类型的金额含义不同：

| 订单类型 | 成交金额列 | 实付金额列 | 欠款金额列 |
|---------|-----------|-----------|-----------|
| 开单订单 | ✅ 成交金额 | ✅ 实付金额 | ✅ 欠款金额 |
| 操作订单 | ⚠️ 消耗金额（语义不对） | ❌ 显示0 | ❌ 显示0 |
| 还款订单 | ❌ 显示0 | ⚠️ 还款金额（语义不对） | ❌ 显示0 |

## 二、优化方案

### 方案：根据订单类型动态显示金额

**核心思路**：
1. "成交金额"列改为"金额"列，根据订单类型显示对应金额
2. "实付金额"列和"欠款金额"列保持不变，非开单订单显示"-"

**显示逻辑**：

| 列 | 开单订单(0) | 操作订单(1) | 还款订单(2) |
|----|------------|------------|------------|
| 金额 | deal_amount（成交） | deal_amount（消耗） | paid_amount（还款） |
| 实付金额 | paid_amount | - | - |
| 欠款金额 | owed_amount | - | - |

**金额列标签**：可以在金额值后面加一个小标签说明类型（如"成交"、"消耗"、"还款"）

## 三、修改内容

### 3.1 后端修改
**文件**：`webman/app/service/BizRepaymentService.php`
**修改**：还款订单的 `deal_amount` 改为 0（还款不是新的成交）

### 3.2 Web端修改
**文件**：`front/src/views/business/order/index.vue`

**修改1**：金额列标题改为"金额"，根据source_type显示对应值
```vue
<el-table-column label="金额" align="right" width="120">
  <template #default="scope">
    <span style="color: #409eff; font-weight: 500">
      {{ getDisplayAmount(scope.row) }}
    </span>
    <el-tag size="small" :type="getAmountTagType(scope.row.sourceType)" style="margin-left: 4px">
      {{ getAmountLabel(scope.row.sourceType) }}
    </el-tag>
  </template>
</el-table-column>
```

**修改2**：实付金额和欠款金额列，非开单订单显示"-"
```vue
<el-table-column label="实付金额" align="right" width="100">
  <template #default="scope">
    <span v-if="scope.row.sourceType === '0'" style="color: #67c23a; font-weight: 500">
      {{ Number(scope.row.paidAmount || 0).toFixed(2) }}
    </span>
    <span v-else style="color: #909399">-</span>
  </template>
</el-table-column>
```

**新增函数**：
```javascript
function getDisplayAmount(row) {
  const amount = row.sourceType === '2' 
    ? (row.paidAmount || 0)  // 还款订单显示实付金额
    : (row.dealAmount || 0)   // 开单/操作显示成交/消耗金额
  return Number(amount).toFixed(2)
}

function getAmountLabel(sourceType) {
  const map = { '0': '成交', '1': '消耗', '2': '还款' }
  return map[sourceType] || '金额'
}

function getAmountTagType(sourceType) {
  const map = { '0': 'primary', '1': 'warning', '2': 'success' }
  return map[sourceType] || 'info'
}
```

### 3.3 AppV3端修改
**文件**：`AppV3/src/pages/business/order/index.vue`

**修改**：订单卡片金额显示逻辑
```vue
<view class="info-item">
  <text class="label">{{ getAmountLabel(item.source_type || item.sourceType) }}</text>
  <text class="value amount">¥{{ getDisplayAmount(item) }}</text>
</view>
```

**新增函数**：
```javascript
function getDisplayAmount(item) {
  const sourceType = item.source_type || item.sourceType
  const amount = sourceType === '2' 
    ? (item.paid_amount || item.paidAmount || 0)
    : (item.deal_amount || item.dealAmount || 0)
  return Number(amount).toFixed(2)
}

function getAmountLabel(sourceType) {
  const map = { '0': '成交', '1': '消耗', '2': '还款' }
  return map[sourceType] || '金额'
}
```

### 3.4 AppV3订单详情修改
**文件**：`AppV3/src/pages/business/order/detail.vue`

**修改**：根据订单类型调整金额显示区域

## 四、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `webman/app/service/BizRepaymentService.php` | 还款订单deal_amount改为0 |
| 2 | `front/src/views/business/order/index.vue` | 金额列动态显示 + 实付/欠款列条件显示 |
| 3 | `AppV3/src/pages/business/order/index.vue` | 金额显示动态逻辑 |
| 4 | `AppV3/src/pages/business/order/detail.vue` | 金额显示根据订单类型调整 |
