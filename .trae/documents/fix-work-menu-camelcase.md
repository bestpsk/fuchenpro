# 修复：AppV3工作台动态菜单不显示（根因：snake_case/camelCase不匹配）

## 根本原因

**`AjaxResult::success()` 自动将所有 snake_case 键名转换为 camelCase**，但前端代码使用 snake_case 访问属性，导致所有属性读取为 `undefined`。

### 转换对照表

| 后端返回（snake_case） | API实际返回（camelCase） | 前端代码使用 | 结果 |
|---|---|---|---|
| `group_key` | `groupKey` | `group.group_key` | ❌ `undefined` |
| `group_name` | `groupName` | `group.group_name` | ❌ `undefined` |
| `group_sort` | `groupSort` | - | - |
| `icon_color` | `iconColor` | `item.icon_color` | ❌ `undefined` |
| `bg_color` | `bgColor` | `item.bg_color` | ❌ `undefined` |
| `sort_order` | `sortOrder` | - | - |

### 关键代码追踪

1. **menu.js 第92行**：`menuMap[group.group_key] = group`
   - `group.group_key` → `undefined` → 所有分组都映射到 `undefined` 键
   - `menuMap` = `{undefined: 最后一个group}` → 只有一个无效键

2. **work/index.vue 第89行**：`g.group_key && g.group_key !== 'quick'`
   - `g.group_key` → `undefined` → falsy → 所有分组被过滤掉
   - `menuGroups` = `[]` → 不渲染任何动态菜单

3. **work/index.vue 第49行**：`{{ group.group_name }}`
   - `group.group_name` → `undefined` → 分组标题不显示

4. **work/index.vue 第47行**：`:key="group.group_key"`
   - `group.group_key` → `undefined` → Vue key 重复

### 为什么"常用功能"能显示

"常用功能"区块的 `quickDisplayList` 使用 `menuStore.quickMenus`，该 getter 有 `DEFAULT_MENUS.quick.items` 回退。由于 `state.menus.quick` 为 `undefined`（key 是 `undefined` 而非 `quick`），所以回退到默认值。

## 修复方案

### 修改1：menu.js - 使用 camelCase 属性名

**文件**: `f:\fuchen\AppV3\src\store\modules\menu.js`

将 `group.group_key` 改为 `group.groupKey`：

```javascript
// 修改前
menuMap[group.group_key] = group

// 修改后
menuMap[group.groupKey] = group
```

### 修改2：work/index.vue - 使用 camelCase 属性名

**文件**: `f:\fuchen\AppV3\src\pages\work\index.vue`

模板和脚本中的 snake_case 全部改为 camelCase：

```html
<!-- 修改前 -->
<view v-for="group in menuGroups" :key="group.group_key" class="grid-card">
  <text class="card-title">{{ group.group_name }}</text>

<!-- 修改后 -->
<view v-for="group in menuGroups" :key="group.groupKey" class="grid-card">
  <text class="card-title">{{ group.groupName }}</text>
```

```javascript
// 修改前
return Object.values(menuStore.menus).filter(g => g && g.group_key && g.group_key !== 'quick' && g.items && g.items.length > 0)

// 修改后
return Object.values(menuStore.menus).filter(g => g && g.groupKey && g.groupKey !== 'quick' && g.items && g.items.length > 0)
```

items 中的属性也统一用 camelCase（去掉 snake_case 回退）：

```html
<!-- 修改前 -->
<view class="quick-icon" :style="{ backgroundColor: item.bgColor || item.bg_color || '#E8F0FE' }">
  <u-icon :name="item.icon" size="18" :color="item.iconColor || item.icon_color || '#3D6DF7'" />

<!-- 修改后 -->
<view class="quick-icon" :style="{ backgroundColor: item.bgColor || '#E8F0FE' }">
  <u-icon :name="item.icon" size="18" :color="item.iconColor || '#3D6DF7'" />
```

```html
<!-- 修改前 -->
<view class="icon-wrapper" :style="{ backgroundColor: item.bg_color || item.bgColor || '#3D6DF7' }">
  <u-icon :name="item.icon" size="22" :color="item.icon_color || item.iconColor || '#fff'" />

<!-- 修改后 -->
<view class="icon-wrapper" :style="{ backgroundColor: item.bgColor || '#3D6DF7' }">
  <u-icon :name="item.icon" size="22" :color="item.iconColor || '#fff'" />
```

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `AppV3/src/store/modules/menu.js` | `group.group_key` → `group.groupKey` |
| `AppV3/src/pages/work/index.vue` | 所有 snake_case 属性改为 camelCase |
