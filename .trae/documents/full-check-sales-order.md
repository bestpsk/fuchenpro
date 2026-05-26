# Web端和AppV3销售开单全面排查与修复

## 一、已发现的问题清单

### 问题1：Web端销售开单企业和门店选择不能持久化
**严重程度**：高
**现象**：刷新页面后企业和门店选择丢失，需要重新选择
**原因**：Web端 `currentEnterpriseId` 和 `currentStoreId` 只是 `ref(null)`，没有持久化到 localStorage
**对比**：AppV3端已实现 `uni.setStorageSync` 持久化

**修复方案**：
- 选择企业/门店时保存到 `sessionStorage`（用session而非local，避免切换用户残留）
- 页面加载时从 `sessionStorage` 恢复

### 问题2：财务审核没有前置条件校验
**严重程度**：高
**现象**：企业未审核时，财务审核开关也能操作
**原因**：财务审核的 `el-switch` 没有禁用条件，只检查了 `financeAuditStatus === '1'`
**业务规则**：必须企业审核通过后，财务才能审核

**修复方案**：
- 财务审核开关增加禁用条件：`enterpriseAuditStatus !== '1'`
- 后端也应增加校验

### 问题3：订单管理详情弹窗中金额显示未优化
**严重程度**：低
**现象**：详情弹窗中成交金额/实付金额/欠款金额对操作和还款订单没有条件显示
**修复方案**：与列表一致，值为0时显示"-"

### 问题4：AppV3订单详情审核按钮状态判断不严谨
**严重程度**：中
**现象**：`canAudit` 计算属性可能没有考虑订单状态
**修复方案**：检查并确保审核按钮只在正确的状态下显示

### 问题5：Web端销售开单操作标签显示"已成交"不合理
**严重程度**：低
**现象**：持卡明细中套餐状态标签显示"已成交"，但按新逻辑开单即成交，应该改为"使用中"/"已用完"
**修复方案**：套餐状态标签改为"使用中"（status='1'）和"已用完"（status='2'）

---

## 二、修改内容

### 2.1 Web端销售开单 - 企业门店持久化
**文件**：`front/src/views/business/sales/index.vue`

**修改1**：`handleEnterpriseChange` 保存到sessionStorage
```javascript
function handleEnterpriseChange(val) {
  currentStoreId.value = null
  storeOptions.value = []
  currentCustomer.value = null
  currentCustomerId.value = null
  customerList.value = []
  if (val) {
    loadStoreList(val)
    sessionStorage.setItem('sales_enterpriseId', val)
  } else {
    sessionStorage.removeItem('sales_enterpriseId')
  }
  sessionStorage.removeItem('sales_storeId')
}
```

**修改2**：`handleStoreChange` 保存到sessionStorage
```javascript
function handleStoreChange() {
  currentCustomer.value = null
  currentCustomerId.value = null
  customerList.value = []
  if (currentStoreId.value) {
    loadCustomerList()
    sessionStorage.setItem('sales_storeId', currentStoreId.value)
  } else {
    sessionStorage.removeItem('sales_storeId')
  }
}
```

**修改3**：`onMounted` 恢复选择
```javascript
onMounted(() => {
  loadEnterpriseList()
  loadUserList()
  operationForm.value.operatorUserId = userStore.id
  operationForm.value.operatorUserName = userStore.nickName || ''
  // 恢复持久化的企业门店选择
  const savedEnterpriseId = sessionStorage.getItem('sales_enterpriseId')
  const savedStoreId = sessionStorage.getItem('sales_storeId')
  if (savedEnterpriseId) {
    currentEnterpriseId.value = savedEnterpriseId
    loadStoreList(savedEnterpriseId)
    if (savedStoreId) {
      currentStoreId.value = savedStoreId
      loadCustomerList()
    }
  }
})
```

### 2.2 订单管理 - 财务审核前置条件
**文件**：`front/src/views/business/order/index.vue`

**修改1**：财务审核开关增加禁用条件
```html
<el-switch v-model="scope.row.financeAuditStatus" active-value="1" inactive-value="0"
  :disabled="scope.row.financeAuditStatus === '1' || scope.row.enterpriseAuditStatus !== '1'"
  @change="handleFinanceAudit(scope.row)"
  v-hasPermi="['business:order:financeAudit']" />
```

**修改2**：后端增加校验
**文件**：`webman/app/service/BizSalesOrderService.php`
```php
public function financeAudit($orderId, $auditBy)
{
    $order = BizSalesOrder::find($orderId);
    if (!$order) return false;
    if ($order->enterprise_audit_status !== '1') return false;  // 新增校验
    return BizSalesOrder::where('order_id', $orderId)->update([
        'finance_audit_status' => '1',
        'finance_audit_by' => $auditBy,
        'finance_audit_time' => date('Y-m-d H:i:s'),
        'order_status' => '2'
    ]);
}
```

### 2.3 AppV3订单详情 - 审核按钮条件
**文件**：`AppV3/src/pages/business/order/detail.vue`

当前审核按钮已基于 `orderStatus` 判断，逻辑正确：
- orderStatus='0' → 显示"企业审核"和"取消订单"
- orderStatus='1' → 显示"财务审核"

无需修改。

### 2.4 Web端套餐状态标签优化
**文件**：`front/src/views/business/sales/index.vue`

**修改**：将"已成交"改为"使用中"
```html
<!-- 修改前 -->
<el-tag :type="pkg.status === '2' ? 'info' : 'success'" size="small">{{ pkg.status === '2' ? '已用完' : '已成交' }}</el-tag>

<!-- 修改后 -->
<el-tag :type="pkg.status === '2' ? 'info' : 'success'" size="small">{{ pkg.status === '2' ? '已用完' : '使用中' }}</el-tag>
```

### 2.5 订单详情弹窗金额显示优化
**文件**：`front/src/views/business/order/index.vue`

**修改**：详情弹窗中成交金额/实付金额/欠款金额，值为0时显示"-"

---

## 三、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `front/src/views/business/sales/index.vue` | 企业门店持久化 + 套餐状态标签 |
| 2 | `front/src/views/business/order/index.vue` | 财务审核前置条件 + 详情金额显示 |
| 3 | `webman/app/service/BizSalesOrderService.php` | 财务审核后端校验 |
