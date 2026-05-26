# 销售开单--付款方式改为品项级别

## 需求变更

**原方案**：一个订单一种付款方式（`biz_sales_order.payment_method`）
**新方案**：每个品项独立选择付款方式（`biz_order_item.payment_method`）

原因：一个套餐中可能包含多种付款方式的品项，如部分现金、部分划卡、部分赠送。

## 实施步骤

### 步骤1：数据库变更

**1.1 `biz_order_item` 添加 `payment_method` 字段**：
```sql
ALTER TABLE biz_order_item ADD COLUMN payment_method varchar(50) DEFAULT 'cash' COMMENT '付款方式' AFTER owed_amount;
```

**1.2 `biz_sales_order` 的 `payment_method` 字段保留**，但含义变为"主要付款方式"（取品项中最多的付款方式），或者直接删除。建议保留作为冗余字段，方便列表筛选和统计。

### 步骤2：后端 - 模型添加 payment_method

**文件**：`webman/app/model/BizOrderItem.php`

在 `$fillable` 数组中添加 `'payment_method'`

### 步骤3：后端 - 服务层调整

**文件**：`webman/app/service/BizSalesOrderService.php`

1. `insertOrder` 方法：
   - 删除订单级别的赠送逻辑（`payment_method === 'gift'` 判断）
   - 改为品项级别：遍历每个品项，如果品项的 `payment_method === 'gift'`，则该品项的金额设为0
   - 在 `$convertedItem` 中添加 `payment_method` 字段
   - 订单的 `payment_method` 可取品项中第一个的值，或取出现最多的值

2. `updateOrder` 方法：同上调整

### 步骤4：Front端 - 付款方式改为品项级别

**文件**：`front/src/views/business/sales/index.vue`

1. **模板变更**：
   - 删除订单级别的付款方式单选按钮组
   - 在品项表格中添加"付款方式"列（下拉选择），位于"品项名称"列之后
   ```html
   <el-table-column label="付款方式" width="120">
     <template #default="scope">
       <el-select v-model="scope.row.paymentMethod" size="small" @change="onItemPaymentMethodChange(scope.$index)" style="width: 100%">
         <el-option v-for="dict in biz_payment_method" :key="dict.value" :label="dict.label" :value="dict.value" />
       </el-select>
     </template>
   </el-table-column>
   ```
   - 成交金额和实付金额列的禁用条件改为：`scope.row.paymentMethod === 'gift'`

2. **JS变更**：
   - 删除 `orderPaymentMethod` ref
   - 删除 `onPaymentMethodChange` 函数
   - `addOrderItemRow` 中每个品项添加 `paymentMethod: 'cash'`
   - 新增 `onItemPaymentMethodChange(index)` 函数：选择"赠送"时该品项金额设为0
   - `submitOrder` 中：删除订单级别的 `paymentMethod`，品项数据中添加 `paymentMethod`
   - 提交成功后不再需要重置 `orderPaymentMethod`

3. **订单记录列表**：付款方式列改为显示品项的付款方式（可能多种，用标签组显示）

### 步骤5：App端 - 付款方式改为品项级别

**文件**：`AppV3/src/pages/business/sales/order.vue`

1. **模板变更**：
   - 删除订单级别的付款方式选择区域（`.payment-section`）
   - 在每个品项卡片中添加付款方式选择（标签式按钮组）
   - 成交金额和实付金额的禁用条件改为：`item.paymentMethod === 'gift'`

2. **JS变更**：
   - 删除 `orderPaymentMethod` ref 和 `selectOrderPaymentMethod` 函数
   - `orderItems.value.push` 中每个品项添加 `paymentMethod: 'cash'`
   - 新增品项级别的付款方式切换函数
   - `submitOrder` 中：品项数据中添加 `paymentMethod`
   - 提交成功后不再需要重置 `orderPaymentMethod`

3. **订单记录列表**：付款方式显示改为品项级别

## 文件变更清单

| 操作 | 文件路径 | 变更内容 |
|------|----------|----------|
| 执行SQL | 数据库 | biz_order_item 添加 payment_method 字段 |
| 修改 | `webman/app/model/BizOrderItem.php` | fillable 添加 payment_method |
| 修改 | `webman/app/service/BizSalesOrderService.php` | 赠送逻辑从订单级改为品项级 + convertedItem 添加 payment_method |
| 修改 | `front/src/views/business/sales/index.vue` | 付款方式从订单级改为品项级（表格列） |
| 修改 | `AppV3/src/pages/business/sales/order.vue` | 付款方式从订单级改为品项级（卡片内选择） |
