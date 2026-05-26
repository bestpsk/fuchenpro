# 方案详情页图标和单位显示修复计划

## 问题

1. **图标显示异常**：`percent`（分成）、`upload`（提交人）、`wallet`（剩余金额）三个图标名在 uview-plus 中不存在，导致显示英文文字而非图标
2. **单位显示不具体**：配赠明细中单位只显示"主单位整"/"副单位拆"，没有显示具体的单位名称（如盒、套、箱等）

## 修复内容

### 1. 图标替换（detail.vue + form.vue）

| 原图标名 | 用途 | 替换为 | 说明 |
|---------|------|--------|------|
| `percent` | 分成比例 | `share` | uview-plus 内置，语义接近"分成" |
| `upload` | 提交人 | `arrow-up` | uview-plus 内置，向上箭头代表"提交" |
| `wallet` | 剩余金额 | `bag` | uview-plus 内置，钱袋语义接近"余额" |

涉及文件：
- `AppV3/src/pages/business/plan/detail.vue`
- `AppV3/src/pages/business/plan/form.vue`

### 2. 单位显示修复（detail.vue）

将配赠明细中的单位显示格式改为：`具体单位（整/拆）`

例如：
- 主单位：`箱（整）`
- 副单位：`支（拆）`

实现方式：使用 `item.spec` 字段获取具体单位名，拼接 `（整）` 或 `（拆）`

```javascript
// 模板中
{{ (item.spec || '-') + (item.unitType === '1' ? '（整）' : '（拆）') }}
```
