# 修复 LoginUser 属性错误 + 申请人显示问题

## 问题分析

### 问题1：仍然报错 `$userName` 未定义
**原因**：`FinPlanAuditController.php:53` 还在使用 `$loginUser->userName`

### 问题2：申请人显示"当前用户"
**原因链路分析**：
1. 前端表单使用 `userStore.realName`
2. `userStore.realName` 来自 `getInfo()` 接口返回的 `user.realName`
3. 后端 `SysLoginController::getInfo()` 调用 `Helpers::userToCamelCase($userData)`
4. 数据库字段 `real_name` → 驼峰转换 → `realName`
5. **可能原因**：数据库中当前用户的 `real_name` 字段为空

---

## 修复步骤

### 步骤1：修复 FinPlanAuditController
第53行 `$loginUser->userName` 改为通过 `$loginUser->user` 获取

### 步骤2：确认前端显示逻辑
- 前端已用 `userStore.realName || '当前用户'` 作为回退
- 如果 realName 为空则显示"当前用户"
- **根本解决**：确保数据库 `sys_user.real_name` 字段有值
- **临时方案**：前端改用 `userStore.name`（登录账号）作为备选

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `app/controller/finance/FinPlanAuditController.php` | 修复 `$loginUser->userName` |
| `front/src/views/finance/reimbursement/index.vue` | 申请人显示改为 `name \|\| realName \|\| '当前用户'` |
