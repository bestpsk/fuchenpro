# 方案审核页面问题修复计划

## 问题根因分析

### 问题1：操作列太窄（按钮跳行）
**现象**：操作列宽度200px，3个按钮（查看、通过、驳回）显示不下
**根本原因**：宽度设置不足
**解决方案**：增加操作列宽度到250px

### 问题2：方案详情-企业名称不显示
**现象**：列表中企业名称显示，但详情中不显示
**根本原因**：
- 列表查询 `selectPlanList()` 手动添加了 `enterprise_name` 字段
- 详情查询 `selectPlanById()` 返回关联对象 `enterprise`，没有 `enterprise_name` 字段
- 前端使用 `viewForm.enterpriseName`，但详情数据中不存在此字段

**解决方案**：修改 `selectPlanById()` 方法，手动添加 `enterprise_name` 字段

### 问题3：审核状态不显示
**现象**：详情中审核状态不显示
**根本原因**：
- 后端字段 `audit_status` 驼峰转换后是 `auditStatus`
- 字典数据 `audit_status` 可能未正确加载
- 需要检查字典数据是否存在

**解决方案**：
1. 添加字典空值保护
2. 确认字典数据正确加载

### 问题4：方案明细-单价不显示
**现象**：方案明细表格中单价列不显示
**根本原因**：
- 数据库表 `biz_plan_item` 中单价字段是 `sale_price`（销售价格）
- 前端使用 `scope.row.unitPrice`
- 后端返回的是 `salePrice`，不是 `unitPrice`

**解决方案**：修改前端使用正确的字段名 `salePrice`

---

## 修复步骤

### 步骤1：修改后端 `BizPlanService::selectPlanById()`
添加 `enterprise_name` 字段，与列表查询保持一致

### 步骤2：修改前端 `planAudit/index.vue`
1. 操作列宽度从200px改为250px
2. 方案明细单价字段从 `unitPrice` 改为 `salePrice`
3. 添加字典空值保护

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `app/service/BizPlanService.php` | `selectPlanById()` 添加 `enterprise_name` 字段 |
| `front/src/views/finance/planAudit/index.vue` | 操作列宽度、单价字段名、字典空值保护 |
