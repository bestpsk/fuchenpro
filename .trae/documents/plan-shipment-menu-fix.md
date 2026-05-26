# 方案详情出货功能 + 供货商菜单修复计划

## 问题一：方案详情页出货按钮不显示

### 原因分析

`canShipment` 的条件是 `planInfo.value.auditStatus === '2'`（严格等于字符串 `'2'`），但后端返回的 `auditStatus` 可能是数字 `2` 而非字符串 `'2'`，导致严格等于比较失败，出货按钮不渲染。

### 修复方案

在 `detail.vue` 中修改 `canShipment` 和其他审核状态相关的 computed 属性，使用 `String()` 转换确保类型一致：

```javascript
const canEdit = computed(() => {
  const s = String(planInfo.value.auditStatus)
  return s === '0' || s === '4'
})
const canSubmitAudit = computed(() => {
  const s = String(planInfo.value.auditStatus)
  return s === '0' || s === '4'
})
const canAuditPass = computed(() => String(planInfo.value.auditStatus) === '1')
const canAuditReject = computed(() => String(planInfo.value.auditStatus) === '1')
const canShipment = computed(() => String(planInfo.value.auditStatus) === '2' && parseFloat(planInfo.value.remainingAmount) > 0)
const canToggleStatus = computed(() => String(planInfo.value.auditStatus) === '2')
```

同样修复 `getAuditStatusLabel` 函数中的 `String()` 转换（已有）。

### 涉及文件

- `AppV3/src/pages/business/plan/detail.vue` — 修复 computed 属性的类型比较

## 问题二：供货商管理点击提示"模块建设中"

### 原因分析

菜单路径的优先级为：**后端 API 响应 > 本地缓存 > DEFAULT_MENUS**。

虽然我们已更新了 `menu.js` 中 `DEFAULT_MENUS` 的供货商管理 path，但后端 API `/system/appMenu/grouped` 正常返回数据时会**完全覆盖** DEFAULT_MENUS。后端 `app_menu_config` 表中供货商管理的 `path` 字段仍为空，导致点击时触发"模块建设中"提示。

### 修复方案

需要更新数据库 `app_menu_config` 表中供货商管理的 path 字段。执行 SQL：

```sql
UPDATE app_menu_config SET path = '/pages/wms/supplier/index' WHERE group_key = 'wms' AND title = '供货商管理';
```

同时更新 `add_plan_app_menu.sql` 文件，将供货商管理的 SQL 也加入。

### 涉及文件

- `webman/sql/add_plan_app_menu.sql` — 追加供货商管理菜单更新 SQL
