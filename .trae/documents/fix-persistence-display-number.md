# 修复Web端销售开单企业和门店持久化后显示数字的问题

## 一、问题分析

**现象**：刷新页面后，企业和门店下拉框显示数字（如 2、3）而不是名称

**原因**：`sessionStorage.getItem()` 返回的值是**字符串**，但赋值给 `ref` 后可能被转为数字（因为选项的 value 是数字）。更关键的是：`el-select` 的 `v-model` 绑定的值与选项的 `value` 类型不匹配时，无法正确显示 label。

**根本原因**：`sessionStorage` 存储的是 ID 数字，恢复时直接赋给了 `currentEnterpriseId`，但 `el-select` 需要的是**字符串类型的值**来匹配选项。

## 二、修复方案

### 文件：`front/src/views/business/sales/index.vue`

**位置**：`onMounted` 中恢复选择的部分

```javascript
// 修改前 - 直接赋值，可能是数字
currentEnterpriseId.value = savedEnterpriseId
currentStoreId.value = savedStoreId

// 修改后 - 确保是字符串类型
currentEnterpriseId.value = String(savedEnterpriseId)
currentStoreId.value = String(savedStoreId)
```

同样，`handleEnterpriseChange` 和 `handleStoreChange` 中存储时也要确保一致性：
- `val` 参数来自 el-select 的 `@change` 事件，已经是正确的类型
- 但为了安全，存储时也转为 String

## 三、修改内容

只需修改 `onMounted` 中的恢复逻辑，确保从 sessionStorage 恢复的值转为字符串。
