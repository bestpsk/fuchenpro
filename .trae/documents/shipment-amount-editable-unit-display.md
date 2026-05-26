# 出货明细--总金额可编辑 & 单位显示优化

## 需求分析

### 需求1：总金额可编辑，编辑后反算折扣单价
- 当前：出货明细中"总金额"是只读的，由 `折扣单价 × 数量` 自动计算
- 目标：总金额也可编辑，编辑总金额后，折扣单价 = 总金额 ÷ 数量（反算）
- 影响范围：**App端 + Web端**（3个Web页面 + 1个App页面）

### 需求2：App端添加货品时单位类型显示具体单位名
- 当前：显示"主单位整"/"副单位拆"
- 目标：显示如"盒（主单位整）"/"支（副单位拆）"，前面加上具体的单位名
- 影响范围：**App端**出货表单页面

## 现有代码关键信息

### 单位映射关系（全项目统一）
```js
const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
```
- `unit` 字段：主单位代码 → `unitMap[unit]` 得到主单位名称（如"盒"）
- `spec` 字段：副单位代码 → `specMap[spec]` 得到副单位名称（如"支"）
- `unitType === '1'`：主单位整，对应 `unitLabel`
- `unitType === '2'`：副单位拆，对应 `specLabel`

### 方案明细数据结构
- `BizPlanItem.spec`：存的是单位名称字符串（如"箱"或"支"），只存当前选中单位类型的名称
- `BizPlanItem` 有 `product()` 关联，但 `selectPlanById` 未嵌套加载 `items.product`
- 需要修改后端加载 `items.product`，以便前端获取货品的 `unit`/`spec` 代码来映射 `unitLabel`/`specLabel`

### 现有Bug：unitLabel/specLabel 为空
Web端 `plan/index.vue` 和 `enterprise/index.vue` 中 `handleCreateShipment` 设为空字符串：
```js
unitLabel: item.unitType === '1' ? '' : '', specLabel: item.spec || ''
```
需要修复。

## 实施步骤

### 步骤1：后端 - 方案详情接口加载明细的货品关联

**文件**：[webman/app/service/BizPlanService.php](file:///f:/fuchen/webman/app/service/BizPlanService.php) 第65行

将 `items` 改为 `items.product`，使方案明细嵌套加载关联货品信息：
```php
// 原
$plan = BizPlan::with(['items', 'enterprise', 'shipments.items'])->find($planId);
// 改为
$plan = BizPlan::with(['items.product', 'enterprise', 'shipments.items'])->find($planId);
```

这样前端可通过 `item.product.unit` 和 `item.product.spec` 获取货品的单位代码，再映射为单位名称。

### 步骤2：Web端 - planList/index.vue

**文件**：[front/src/views/business/planList/index.vue](file:///f:/fuchen/front/src/views/business/planList/index.vue)

1. **总金额列可编辑**（约第322-324行）：
   - 将"总金额"列从纯文本 `{{ scope.row.amount || 0 }}` 改为 `el-input-number`
   - 绑定 `@change="onShipmentAmountChange(scope.$index)"`

2. **新增 `onShipmentAmountChange` 函数**：
   ```js
   function onShipmentAmountChange(index) {
     const item = shipmentForm.value.items[index]
     const qty = parseInt(item.quantity) || 0
     if (qty > 0) {
       item.discountPrice = Math.round((parseFloat(item.amount) / qty) * 100) / 100
     }
   }
   ```

3. **修复 `handleCreateShipment` 中的 unitLabel/specLabel**（约第596-616行）：
   - 利用后端返回的 `item.product.unit` / `item.product.spec` 代码映射
   ```js
   unitLabel: unitMap[item.product?.unit] || '',
   specLabel: specMap[item.product?.spec] || ''
   ```

### 步骤3：Web端 - plan/index.vue

**文件**：[front/src/views/business/plan/index.vue](file:///f:/fuchen/front/src/views/business/plan/index.vue)

同步骤2的变更：
1. 总金额列改为 `el-input-number`
2. 新增 `onShipmentAmountChange` 函数
3. 修复 `handleCreateShipment` 中的 unitLabel/specLabel

### 步骤4：Web端 - enterprise/index.vue

**文件**：[front/src/views/business/enterprise/index.vue](file:///f:/fuchen/front/src/views/business/enterprise/index.vue)

同步骤2的变更：
1. 总金额列改为 `el-input-number`
2. 新增 `onShipmentAmountChange` 函数
3. 修复 `handleCreateShipment` 中的 unitLabel/specLabel

### 步骤5：App端 - shipment.vue

**文件**：[AppV3/src/pages/business/plan/shipment.vue](file:///f:/fuchen/AppV3/src/pages/business/plan/shipment.vue)

1. **出货明细列表中总金额可编辑**（约第89-92行）：
   - 将总金额从 `<text>` 改为 `<input type="digit">`
   - 绑定 `@input="onAmountChange(index)"`

2. **新增 `onAmountChange` 函数**：
   ```js
   function onAmountChange(index) {
     const item = form.items[index]
     const qty = parseInt(item.quantity) || 0
     if (qty > 0) {
       item.discountPrice = Math.round((parseFloat(item.amount) / qty) * 100) / 100
     }
   }
   ```

3. **添加货品弹窗中总金额可编辑**（约第154-157行）：
   - 将总金额从 `<text>` 改为 `<input type="digit">`
   - 修改 `calcItemFormAmount` 逻辑，支持双向计算：
     - 编辑折扣单价时：总金额 = 折扣单价 × 数量
     - 编辑总金额时：折扣单价 = 总金额 ÷ 数量
   - 新增 `onItemFormAmountChange` 函数处理总金额输入

4. **单位显示优化**：
   - 出货明细列表（约第72行）：`{{ item.unitType === '1' ? '主单位整' : '副单位拆' }}` → `{{ getUnitTypeLabel(item) }}`
   - 添加货品弹窗（约第136行）：同上
   - 单位类型选择器（约第186行）：选项动态加上具体单位名
   - 新增 `getUnitTypeLabel` 函数和 `unitTypeColumns` 计算属性

5. **修复 `loadPlanDetail` 中方案明细项的 unitLabel/specLabel**：
   - 利用后端返回的 `item.product.unit` / `item.product.spec` 代码映射
   ```js
   unitLabel: unitMap[item.product?.unit] || '',
   specLabel: specMap[item.product?.spec] || ''
   ```

## 文件变更清单

| 操作 | 文件路径 | 变更内容 |
|------|----------|----------|
| 修改 | `webman/app/service/BizPlanService.php` | selectPlanById 加载 items.product 关联 |
| 修改 | `front/src/views/business/planList/index.vue` | 总金额可编辑 + 反算函数 + 修复unitLabel/specLabel |
| 修改 | `front/src/views/business/plan/index.vue` | 总金额可编辑 + 反算函数 + 修复unitLabel/specLabel |
| 修改 | `front/src/views/business/enterprise/index.vue` | 总金额可编辑 + 反算函数 + 修复unitLabel/specLabel |
| 修改 | `AppV3/src/pages/business/plan/shipment.vue` | 总金额可编辑 + 单位显示优化 + 修复unitLabel/specLabel |
