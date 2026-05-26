# 销售开单和订单管理优化计划

## 一、核心业务逻辑变更

### 1.1 统一订单状态映射（去掉已成交/未成交）

**状态流转**：待确认(0) → 企业已审(1) → 财务已审(2) → 已取消(4)

| 状态值 | 新映射   | 触发操作                                     | 适用订单类型       |
|--------|----------|----------------------------------------------|-------------------|
| 0      | 待确认   | 销售开单提交时                                | 开单订单           |
| 1      | 企业已审 | 企业审核通过时                                | 开单订单、操作订单(自动) |
| 2      | 财务已审 | 财务审核通过时（=订单完成）                    | 开单订单、还款订单(自动) |
| 4      | 已取消   | 仅待确认状态下可取消                          | 开单订单           |

**特殊订单自动状态**：
- 操作订单（source_type='1'）：创建时直接设为 `'1'`（企业已审），无需审核流程
- 还款订单（source_type='2'）：创建时直接设为 `'2'`（财务已审），即时完成

**当前问题**：
- `front/sales/index.vue` 第799行：`{ '0': '未成交', '1': '已成交', ... }`
- `AppV3/sales/order.vue` 第526行：`{ '0': '未成交', '1': '已成交', ... }`
- 前端开单提交时传 `orderStatus: '1'`，应改为 `'0'`
- 后端审核只更新审核状态字段，未联动更新 `order_status`

### 1.2 订单类型独立显示
- 来源类型（开单/操作/还款/手动）不再和订单编号混在一起，独立显示

### 1.3 去掉方案金额
- AppV3订单详情页仍显示"方案价"，需移除

### 1.4 新增门店成交人
- AppV3订单列表和详情页需补充门店成交人显示

### 1.5 新增取消订单功能
- 仅在待确认(0)状态下可取消，取消后状态变为已取消(4)
- 需后端新增取消接口，前端新增取消按钮

---

## 二、后端修改

### 2.1 BizSalesOrderService.php - 企业审核联动
**文件**：`webman/app/service/BizSalesOrderService.php`
**修改**：`enterpriseAudit()` 方法，增加 `order_status = '1'` 更新

```php
public function enterpriseAudit($orderId, $auditBy)
{
    return BizSalesOrder::where('order_id', $orderId)->update([
        'enterprise_audit_status' => '1',
        'enterprise_audit_by' => $auditBy,
        'enterprise_audit_time' => date('Y-m-d H:i:s'),
        'order_status' => '1'
    ]);
}
```

### 2.2 BizSalesOrderService.php - 财务审核联动
**修改**：`financeAudit()` 方法，增加 `order_status = '2'` 更新

```php
public function financeAudit($orderId, $auditBy)
{
    return BizSalesOrder::where('order_id', $orderId)->update([
        'finance_audit_status' => '1',
        'finance_audit_by' => $auditBy,
        'finance_audit_time' => date('Y-m-d H:i:s'),
        'order_status' => '2'
    ]);
}
```

### 2.3 BizSalesOrderService.php - 新增取消订单方法
**新增**：`cancelOrder()` 方法

```php
public function cancelOrder($orderId)
{
    $order = BizSalesOrder::find($orderId);
    if (!$order) return false;
    if ($order->order_status !== '0') return false;
    return BizSalesOrder::where('order_id', $orderId)->update([
        'order_status' => '4',
        'update_time' => date('Y-m-d H:i:s')
    ]);
}
```

### 2.4 BizSalesOrderController.php - 新增取消订单接口
**文件**：`webman/app/controller/business/BizSalesOrderController.php`
**新增**：`cancel()` 方法

```php
public function cancel(Request $request)
{
    $orderId = $request->post('orderId');
    $service = new BizSalesOrderService();
    $result = $service->cancelOrder($orderId);
    if (!$result) return AjaxResult::error('取消失败，仅待确认订单可取消');
    return AjaxResult::success('取消成功');
}
```

### 2.5 BizRepaymentService.php - 还款订单状态改为'2'
**文件**：`webman/app/service/BizRepaymentService.php`
**修改**：第134行，还款订单创建时 `order_status` 从 `'3'` 改为 `'2'`

### 2.6 字典数据更新
**需执行SQL**：

```sql
DELETE FROM sys_dict_data WHERE dict_type = 'biz_order_status';
INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, dict_sort, status, create_by, create_time) VALUES
('biz_order_status', '待确认', '0', 1, '0', 'admin', NOW()),
('biz_order_status', '企业已审', '1', 2, '0', 'admin', NOW()),
('biz_order_status', '财务已审', '2', 3, '0', 'admin', NOW()),
('biz_order_status', '已取消', '4', 5, '0', 'admin', NOW());
```

---

## 三、Web端修改

### 3.1 front/src/views/business/order/index.vue ✅ 已完成
- ✅ 类型独立列
- ✅ 移除方案金额
- ✅ 新增门店成交人
- ✅ 统一状态映射

**需补充**：
- 状态筛选选项更新为：待确认/企业已审/财务已审/已取消（去掉已完成）
- 状态映射函数更新：`{ '0': '待确认', '1': '企业已审', '2': '财务已审', '4': '已取消' }`
- 新增取消订单按钮（仅待确认状态显示）

### 3.2 front/src/views/business/sales/index.vue
**文件**：`front/src/views/business/sales/index.vue`

#### 3.2.1 开单提交 - orderStatus改为'0'
**位置**：第903行 `submitOrder()` 函数
```javascript
orderStatus: '0',  // 原为 '1'
```

#### 3.2.2 统一订单状态映射
**位置**：第798-801行 `getOrderStatusName()` 函数
```javascript
function getOrderStatusName(status) {
  const map = { '0': '待确认', '1': '企业已审', '2': '财务已审', '4': '已取消' }
  return map[status] || '未知'
}
```

#### 3.2.3 移除开单记录Tab中的"是否成交"筛选
**位置**：第444-447行，删除"是否成交"下拉框
同时移除变量 `orderRecordDealStatus`（第749行）和 `loadOrderRecords()` 中的引用（第1066-1068行）

#### 3.2.4 清理调试console.log
**位置**：第1092-1133行 `loadOperationRecords()` 和 `getOperatorRealName()` 中的 console.log

---

## 四、AppV3端修改

### 4.1 AppV3/src/pages/business/order/index.vue

#### 4.1.1 统一订单状态选项
```javascript
const orderStatusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '企业已审', value: '1' },
  { label: '财务已审', value: '2' },
  { label: '已取消', value: '4' }
])
```

#### 4.1.2 订单卡片新增门店成交人
在card-body中新增成交人显示行

#### 4.1.3 统一getOrderStatusName映射
与状态选项保持一致

### 4.2 AppV3/src/pages/business/order/detail.vue

#### 4.2.1 统一订单状态映射
```javascript
const statusMap = {
  '0': '待确认',
  '1': '企业已审',
  '2': '财务已审',
  '4': '已取消'
}
```

#### 4.2.2 移除"方案价"显示
删除第105-115行方案价相关代码

#### 4.2.3 移除"已成交"标签
删除第100行 `<text v-if="item.isDeal === '1' || item.is_deal === '1'" class="deal-tag">已成交</text>`

#### 4.2.4 新增门店成交人显示
在info-body中门店信息行之后新增

#### 4.2.5 修改getUnitPrice计算逻辑
从基于planPrice改为基于dealAmount计算

#### 4.2.6 审核按钮文案更新
- 待确认(0)状态：显示"企业审核"按钮
- 企业已审(1)状态：显示"财务审核"按钮
- 新增：待确认(0)状态显示"取消订单"按钮

#### 4.2.7 操作记录模式下"方案价"改为"消耗金额"
第134-145行操作记录模式中的"方案价"改为"消耗金额"

### 4.3 AppV3/src/pages/business/sales/order.vue

#### 4.3.1 开单提交 - orderStatus改为'0'
第493行 `orderStatus: '0'`

#### 4.3.2 统一订单状态映射
```javascript
function getOrderStatusName(status) {
  const map = { '0': '待确认', '1': '企业已审', '2': '财务已审', '4': '已取消' }
  return map[status] || '未知'
}
```

#### 4.3.3 开单记录状态标签样式更新
```scss
&.st-0 { background: #FFF7E8; color: #FF7D00; }  // 待确认-橙色
&.st-1 { background: #E8F0FE; color: #3D6DF7; }  // 企业已审-蓝色
&.st-2 { background: #E8FFEA; color: #00B42A; }  // 财务已审-绿色
&.st-4 { background: #F2F3F5; color: #86909C; }  // 已取消-灰色
```

---

## 五、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `webman/app/service/BizSalesOrderService.php` | 企业审核/财务审核联动order_status + 新增cancelOrder() |
| 2 | `webman/app/controller/business/BizSalesOrderController.php` | 新增cancel()接口 |
| 3 | `webman/app/service/BizRepaymentService.php` | 还款订单order_status从'3'改为'2' |
| 4 | `front/src/views/business/order/index.vue` | 状态映射更新 + 新增取消按钮 |
| 5 | `front/src/views/business/sales/index.vue` | orderStatus改'0' + 统一状态 + 移除成交筛选 + 清理日志 |
| 6 | `AppV3/src/pages/business/order/index.vue` | 统一状态选项 + 新增门店成交人 |
| 7 | `AppV3/src/pages/business/order/detail.vue` | 统一状态 + 移除方案价 + 移除已成交标签 + 新增门店成交人 + 修改单价计算 + 更新审核按钮 + 新增取消按钮 |
| 8 | `AppV3/src/pages/business/sales/order.vue` | orderStatus改'0' + 统一状态映射 + 更新样式 |
| 9 | `front/src/api/business/salesOrder.js` | 新增cancelOrder API |
| 10 | `AppV3/src/api/business/salesOrder.js` | 新增cancelOrder API |
