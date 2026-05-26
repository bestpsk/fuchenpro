# 修复Web端销售开单企业和门店持久化显示数字问题

## 一、根本原因分析

**不是类型问题，而是时序问题！**

```
onMounted() {
  loadEnterpriseList()  // 异步请求，需要时间
  // ↓ 立即执行
  currentEnterpriseId = "2"  // ← 此时 enterpriseOptions 还是 [] !!!
  loadStoreList("2")       // 又一个异步请求
  // ↓ 立即执行
  currentStoreId = "3"     // ← 此时 storeOptions 还是 [] !!!
}

// 几百毫秒后 API 返回了...
// enterpriseOptions = [{ enterpriseId: 2, ... }]  ← 太晚了，el-select 已经渲染了数字
// storeOptions = [{ storeId: 3, ... }]             ← 太晚了
```

**el-select 在选项列表为空时就绑定了 value，无法找到对应选项，所以直接显示 value 的原始值。**

## 二、修复方案

将恢复选择的逻辑移到 **异步加载回调内部**，确保选项列表加载完成后再设置选中值。

### 文件：`front/src/views/business/sales/index.vue`

**修改1**：删除 onMounted 中的直接赋值逻辑

```javascript
onMounted(() => {
  loadEnterpriseList()
  loadUserList()
  operationForm.value.operatorUserId = userStore.id
  operationForm.value.operatorUserName = userStore.nickName || ''
})
```

**修改2**：在 `loadEnterpriseList` 回调中恢复企业选择和门店

```javascript
function loadEnterpriseList() {
  searchEnterpriseApi('').then(res => {
    enterpriseOptions.value = res.data || []
    const savedEnterpriseId = sessionStorage.getItem('sales_enterpriseId')
    if (savedEnterpriseId) {
      currentEnterpriseId.value = Number(savedEnterpriseId)
      loadStoreList(savedEnterpriseId)  // 继续加载门店并恢复
    }
  })
}
```

**修改3**：在 `loadStoreList` 回调中恢复门店选择

```javascript
function loadStoreList(enterpriseId) {
  searchStore('', enterpriseId).then(res => {
    storeOptions.value = res.data || []
    const savedStoreId = sessionStorage.getItem('sales_storeId')
    if (savedStoreId && storeOptions.value.length > 0) {
      currentStoreId.value = Number(savedStoreId)
      loadCustomerList()
    }
  })
}
```

**关键点**：
- 使用 `Number()` 而非 `String()`，因为后端返回的 ID 是整数，el-option 的 :value 也是数字
- 恢复逻辑放在 `.then()` 回调内，确保选项列表已填充
