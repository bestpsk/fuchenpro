# 销售开单--添加付款方式功能

## 需求分析

### 付款方式类型
| 付款方式 | 字典值 | 特殊规则 |
|----------|--------|----------|
| 现金 | cash | 无 |
| 划卡 | card | 无 |
| 置换 | exchange | 无 |
| 赠送 | gift | 成交金额=0，实付金额=0 |

**赠送规则**：选择"赠送"时，成交金额和实付金额自动设为0，且不可编辑。

### 设计决策
- 付款方式使用**数据字典**（`biz_payment_method`），方便后台管理和扩展
- 付款方式加在**订单级别**（`biz_sales_order`），一个订单一种付款方式
- 前端通过 `useDict` 加载字典，与现有 `biz_customer_tag` 等字典使用方式一致

## 实施步骤

### 步骤1：后端 - 数据库变更

**1.1 添加 payment_method 字段**：
```sql
ALTER TABLE biz_sales_order ADD COLUMN payment_method varchar(50) DEFAULT 'cash' COMMENT '付款方式' AFTER owed_amount;
```

**1.2 添加付款方式字典**（字典类型：`biz_payment_method`）：
```sql
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
SELECT '付款方式', 'biz_payment_method', '0', 'admin', NOW(), '销售开单付款方式'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_dict_type` WHERE `dict_type` = 'biz_payment_method');

INSERT INTO `sys_dict_data` (`dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(1, '现金', 'cash', 'biz_payment_method', '', 'primary', 'Y', '0', 'admin', NOW(), '现金支付'),
(2, '划卡', 'card', 'biz_payment_method', '', 'success', 'N', '0', 'admin', NOW(), '刷卡支付'),
(3, '置换', 'exchange', 'biz_payment_method', '', 'warning', 'N', '0', 'admin', NOW(), '置换支付'),
(4, '赠送', 'gift', 'biz_payment_method', '', 'danger', 'N', '0', 'admin', NOW(), '赠送（成交0实付0）');
```

### 步骤2：后端 - 模型添加 payment_method

**文件**：`webman/app/model/BizSalesOrder.php`

在 `$fillable` 数组中添加 `'payment_method'`

### 步骤3：后端 - 服务层处理赠送逻辑

**文件**：`webman/app/service/BizSalesOrderService.php`

在 `insertOrder` 和 `updateOrder` 方法中，如果 `payment_method` 为 `gift`，强制将金额设为0：

```php
// insertOrder 中，创建订单前
if (($data['payment_method'] ?? '') === 'gift') {
    $data['deal_amount'] = 0;
    $data['paid_amount'] = 0;
    $data['owed_amount'] = 0;
    foreach ($items as &$item) {
        $item['price'] = $item['deal_amount'] = $item['paid_amount'] = 0;
    }
    unset($item);
}
```

### 步骤4：Front端 - 开单表单添加付款方式

**文件**：`front/src/views/business/sales/index.vue`

1. **加载字典**：`useDict` 中添加 `"biz_payment_method"`
   ```js
   const { biz_customer_tag, biz_archive_type, biz_payment_method } = useDict("biz_customer_tag", "biz_archive_type", "biz_payment_method")
   ```

2. **模板变更**（开单Tab）：
   - 在品项表格上方或"门店成交人"行上方，添加付款方式选择：
   ```html
   <div style="margin-top: 12px; display: flex; align-items: center; gap: 8px">
     <span class="stat-label" style="font-size:13px; white-space:nowrap">付款方式</span>
     <el-radio-group v-model="orderPaymentMethod" size="small" @change="onPaymentMethodChange">
       <el-radio-button v-for="dict in biz_payment_method" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio-button>
     </el-radio-group>
   </div>
   ```

3. **JS变更**：
   - 新增 `orderPaymentMethod` ref，默认值 `'cash'`
   - 新增 `onPaymentMethodChange` 函数：选择"赠送"时，所有品项的成交金额和实付金额设为0
   - 成交金额和实付金额列：当 `orderPaymentMethod === 'gift'` 时禁用输入
   - 修改 `submitOrder`：提交数据中添加 `paymentMethod: orderPaymentMethod.value`
   - 提交成功后重置 `orderPaymentMethod` 为 `'cash'`

4. **订单记录列表**：添加付款方式列，使用 `<dict-tag>` 组件显示

### 步骤5：App端 - 开单表单添加付款方式

**文件**：`AppV3/src/pages/business/sales/order.vue`

1. **加载字典**：App端需要通过API获取字典数据，或直接定义（App端通常硬编码字典选项，与现有还款支付方式一致）

2. **模板变更**（开单区域）：
   - 在品项列表下方添加付款方式选择（标签式按钮组）：
   ```html
   <view class="payment-section">
     <text class="section-label">付款方式</text>
     <view class="payment-methods">
       <view v-for="method in orderPaymentMethods" :key="method.value"
         class="method-tag" :class="{ active: orderPaymentMethod === method.value }"
         @click="selectOrderPaymentMethod(method.value)">
         <text>{{ method.label }}</text>
       </view>
     </view>
   </view>
   ```

3. **JS变更**：
   - 新增 `orderPaymentMethods` 数组（与字典值一致）：`[{ label: '现金', value: 'cash' }, { label: '划卡', value: 'card' }, { label: '置换', value: 'exchange' }, { label: '赠送', value: 'gift' }]`
   - 新增 `orderPaymentMethod` ref，默认值 `'cash'`
   - 新增 `selectOrderPaymentMethod` 函数：选择"赠送"时自动将成交/实付金额设为0
   - 成交金额和实付金额输入框：当 `orderPaymentMethod === 'gift'` 时禁用
   - 修改 `submitOrder`：提交数据中添加 `paymentMethod: orderPaymentMethod.value`
   - 提交成功后重置 `orderPaymentMethod` 为 `'cash'`

4. **订单记录列表**：添加付款方式显示

## 文件变更清单

| 操作 | 文件路径 | 变更内容 |
|------|----------|----------|
| 执行SQL | 数据库 | biz_sales_order 添加 payment_method 字段 + 添加 biz_payment_method 字典 |
| 修改 | `webman/app/model/BizSalesOrder.php` | fillable 添加 payment_method |
| 修改 | `webman/app/service/BizSalesOrderService.php` | insertOrder/updateOrder 处理赠送逻辑 |
| 修改 | `front/src/views/business/sales/index.vue` | useDict加载字典 + 开单表单添加付款方式 + 赠送逻辑 + 订单记录显示 |
| 修改 | `AppV3/src/pages/business/sales/order.vue` | 开单表单添加付款方式 + 赠送逻辑 + 订单记录显示 |
