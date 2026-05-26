# 方案详情--出货功能实施计划

## 现状分析

**当前移动端（AppV3）方案详情页**（[detail.vue](file:///f:/fuchen/AppV3/src/pages/business/plan/detail.vue)）：
- ✅ 已展示方案基本信息、操作记录、配赠明细、出货记录
- ✅ 已有操作按钮：编辑、提交审核、审核通过/驳回、启用/停用
- ❌ **缺少"出货"按钮**：已审核方案（`auditStatus === '2'`）无法创建出货单
- ❌ **缺少出货API**：`AppV3/src/api/business/` 下没有 `shipment.js`
- ❌ **缺少出货表单页面**：没有新建出货单的页面

**参考Web端**（[planList/index.vue](file:///f:/fuchen/front/src/views/business/planList/index.vue)）出货功能：
- 已审核方案可点击"出货"按钮
- 新建出货单弹窗：关联方案/企业信息、收货人/电话/地址、出货明细（含折扣单价）、备注
- 出货明细来源于方案配赠明细（剩余数量 > 0 的项），支持添加其他货品
- 校验：出货总金额不能大于方案剩余金额
- 提交调用 `addShipment` 接口

**后端API已就绪**：`/business/shipment` 路由已配置，`BizShipmentService` 已实现完整的出货单创建逻辑

## 实施步骤

### 步骤1：创建出货API文件

**新建文件**：`AppV3/src/api/business/shipment.js`

参考Web端 [shipment.js](file:///f:/fuchen/front/src/api/business/shipment.js)，创建移动端出货API，包含：
- `addShipment(data)` - 新增出货单（核心，本次必须）
- `listShipment(query)` - 查询出货单列表
- `getShipment(shipmentId)` - 查询出货单详情
- `auditShipment(data)` - 审核出货单
- `shipShipment(data)` - 发货操作
- `confirmReceipt(shipmentId)` - 确认收货
- `delShipment(shipmentIds)` - 删除出货单
- `updateShipment(data)` - 修改出货单

### 步骤2：创建出货表单页面

**新建文件**：`AppV3/src/pages/business/plan/shipment.vue`

参考Web端出货弹窗逻辑和移动端 [form.vue](file:///f:/fuchen/AppV3/src/pages/business/plan/form.vue) 的UI风格，创建出货表单页面：

**页面结构**：
1. **方案信息区**（只读）：关联方案、企业名称、回款比例
2. **收货信息区**（可编辑）：收货人、收货电话、收货地址（默认从企业信息带入）
3. **出货明细区**：
   - 从方案配赠明细中筛选 `remainingQuantity > 0` 的项，自动填充
   - 每项显示：货品名称、供货商、单位类型、数量（可修改，上限为剩余数量）、折扣单价（可修改）、总金额（自动计算）
   - 支持删除明细项
   - 支持添加其他货品（参考Web端 `addCustomProduct`）
4. **金额汇总**：总金额 + 方案剩余金额对比
5. **备注**
6. **底部操作栏**：取消 + 确认提交

**业务逻辑**：
- 页面通过URL参数接收 `planId`
- 加载方案详情后自动填充出货表单
- 出货明细数量上限为 `remainingQuantity`
- 折扣单价默认等于 `salePrice`，可手动修改
- 总金额 = Σ(折扣单价 × 数量)
- 提交校验：明细非空、总金额 ≤ 剩余金额
- 提交成功后返回方案详情页并刷新

### 步骤3：修改方案详情页，添加出货按钮

**修改文件**：`AppV3/src/pages/business/plan/detail.vue`

1. 在操作按钮区域添加"出货"按钮：
   - 显示条件：`auditStatus === '2'`（已审核）且 `remainingAmount > 0`（还有剩余金额）
   - 按钮样式：参考现有按钮风格，使用 `type="primary"` 或自定义颜色
2. 添加 `canShipment` 计算属性
3. 添加 `goShipment()` 方法，跳转到出货表单页面
4. 更新 `showActions` 计算属性，包含出货条件
5. 在 `onMounted` 或页面 `onShow` 时刷新数据（出货后返回需要刷新）

### 步骤4：注册新页面路由

**修改文件**：`AppV3/src/pages.json`

在 `pages` 数组中添加出货表单页面路由：
```json
{ "path": "pages/business/plan/shipment", "style": { "navigationBarTitleText": "新建出货单", "navigationBarBackgroundColor": "#3D6DF7", "navigationBarTextStyle": "white" } }
```

## 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|----------|------|
| 新建 | `AppV3/src/api/business/shipment.js` | 出货API接口 |
| 新建 | `AppV3/src/pages/business/plan/shipment.vue` | 出货表单页面 |
| 修改 | `AppV3/src/pages/business/plan/detail.vue` | 添加出货按钮和跳转逻辑 |
| 修改 | `AppV3/src/pages.json` | 注册出货页面路由 |

## 出货业务流程

```
方案详情页 → 点击"出货"按钮 → 跳转出货表单页 → 填写收货信息/修改明细 → 提交 → 返回详情页（刷新）
```

后端处理（已有）：
```
创建出货单(shipment_status=0) → 待审核 → 审核通过(1) → 发货(2) → 确认收货(3)
```
