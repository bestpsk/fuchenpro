# 工作台菜单优化：去掉快捷操作/个人菜单，常用功能显示5个

## 需求
1. 去掉工作台的"快捷操作"和"个人菜单"分组
2. 常用功能显示5个菜单（当前4个）
3. 常用功能是否根据用户点击次数动态展示

## 关于"常用功能"的实现方案

**推荐方案：本地点击计数 + 动态排序**

理由：
- 不需要后端新增表和接口，实现简单
- 数据存本地即可，每个用户设备上自然不同
- 首次使用时显示默认5个，后续根据点击次数动态调整

实现逻辑：
1. 在 `menu.js` store 中增加 `menuClickCounts` 状态，存储在本地 storage
2. 每次 `handleGridClick` 点击菜单时，记录点击次数
3. `quickMenus` getter 改为：从所有分组中收集全部菜单项，按点击次数排序，取前5个
4. 首次使用（无点击记录）时显示默认5个：打卡、开单、行程、订单、考勤打卡

## 实施步骤

### 步骤1：数据库 - 隐藏快捷操作和个人菜单

SQL更新 `app_menu_config` 表，将 `mine_action` 和 `mine_menu` 分组的 `visible` 设为0：
```sql
UPDATE app_menu_config SET visible = 0 WHERE group_key IN ('mine_action', 'mine_menu');
```

### 步骤2：menu.js - 增加点击计数 + 动态常用功能

- 新增 `menuClickCounts` 状态（从本地 storage 初始化）
- 新增 `recordMenuClick(menuId)` action
- 修改 `quickMenus` getter：从所有菜单中按点击次数排序取前5
- DEFAULT_MENUS 中删除 `mine_action` 和 `mine_menu`
- 删除 `mineActions` 和 `mineMenus` getter
- 递增 CACHE_VERSION 为 4

### 步骤3：work/index.vue - 常用功能改为5个 + 记录点击

- `quickDisplayList` 改为 `slice(0, 5)`
- `handleGridClick` 中调用 `menuStore.recordMenuClick(item.id)`
- `menuGroups` 过滤条件增加排除 `mine_action` 和 `mine_menu`

### 步骤4：QuickMenu.vue - 首页快捷菜单同步改为5个

- `displayMenus` 改为 `slice(0, 5)`
- 点击时记录点击次数

### 步骤5：mine/index.vue - 个人中心不再依赖菜单store

- `mine_action` 和 `mine_menu` 改为硬编码（这些是个人中心的固定功能，不需要动态配置）

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| 数据库 | 隐藏 mine_action 和 mine_menu 分组 |
| `AppV3/src/store/modules/menu.js` | 增加点击计数、动态常用功能、删除mine相关 |
| `AppV3/src/pages/work/index.vue` | 常用功能5个、记录点击、过滤mine分组 |
| `AppV3/src/components/home/QuickMenu.vue` | 显示5个、记录点击 |
| `AppV3/src/pages/mine/index.vue` | mine菜单改为硬编码 |
