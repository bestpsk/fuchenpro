# 前端页面错误修复计划

## 问题分析

### 错误1：方案审核页面
**错误信息**：`TypeError: scope.row.planAmount?.toFixed is not a function`

**原因**：
- 后端返回的 `planAmount` 经过 `TableDataInfo::result()` 的蛇形转驼峰处理后，数值类型可能变为字符串
- 字符串没有 `toFixed` 方法

**解决方案**：
- 使用 `Number()` 转换数值：`Number(scope.row.planAmount || 0).toFixed(2)`
- 或创建格式化函数统一处理

### 错误2：报销管理页面
**错误信息**：`TypeError: Cannot destructure property 'type' of 'vnode' as it is null`

**原因**：
- 字典数据 `fin_reimbursement_category`、`fin_reimbursement_status`、`fin_reimbursement_expense_type` 可能未正确加载
- `dict-tag` 组件在字典数据为空时渲染出错

**解决方案**：
- 添加字典数据加载状态检查
- 为 `dict-tag` 组件添加空值保护

---

## 修复步骤

### 步骤1：修复方案审核页面 (planAudit/index.vue)
- 修改所有 `toFixed` 调用，使用 `Number()` 转换
- 涉及字段：`planAmount`、`giftAmount`、`remainingAmount`、`unitPrice`、`amount`

### 步骤2：修复报销管理页面 (reimbursement/index.vue)
- 修改所有 `toFixed` 调用，使用 `Number()` 转换
- 为 `dict-tag` 组件添加 `v-if` 判断，确保字典数据存在
- 涉及字段：`expenseAmount`、`incomeAmount`

### 步骤3：修复报销统计页面 (reimbursementReport/index.vue)
- 修改所有数值格式化，确保类型正确

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `front/src/views/finance/planAudit/index.vue` | 数值格式化修复 |
| `front/src/views/finance/reimbursement/index.vue` | 数值格式化修复 + 字典空值保护 |
| `front/src/views/finance/reimbursementReport/index.vue` | 数值格式化修复 |
