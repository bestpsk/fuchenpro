# AppV3工作台添加完整菜单分组

## 目标
在工作台页面显示Web端所有重要菜单分组：业务管理、考勤管理、进销存管理、财务管理及其子菜单。

## 当前状态
`app_menu_config` 表只有5个分组：常用功能、业务管理、系统管理、快捷操作、个人菜单。
缺少：考勤管理、进销存管理、财务管理。

## 实施步骤

### 步骤1：创建SQL插入新菜单数据

新增3个分组及子菜单，调整现有分组的 group_sort 排序：

| 分组 | group_key | group_sort | 子菜单 |
|------|-----------|------------|--------|
| 常用功能 | quick | 1 | 不变 |
| 业务管理 | business | 2 | 不变 |
| **考勤管理** | **attendance** | **3** | 考勤打卡、考勤记录、考勤规则、考勤配置 |
| **进销存管理** | **wms** | **4** | 供货商管理、货品管理、入库管理、出库管理、库存查看、库存盘点、店企业出货、进销存报表 |
| **财务管理** | **finance** | **5** | 方案审核、报销管理、报销统计 |
| 系统管理 | system | 6 | 原3→6 |
| 快捷操作 | mine_action | 7 | 原4→7 |
| 个人菜单 | mine_menu | 8 | 原5→8 |

颜色方案：
- 考勤管理：琥珀色 #F59E0B
- 进销存管理：翠绿色 #10B981
- 财务管理：紫色 #8B5CF6

已有AppV3页面的子菜单设置path：
- 考勤打卡 → /pages/attendance/index
- 考勤记录 → /pages/attendance/record
- 其他暂无页面的设空path，点击提示"模块建设中"

### 步骤2：用PHP脚本执行SQL

创建PHP脚本执行SQL，插入新菜单数据并更新排序。

### 步骤3：更新 DEFAULT_MENUS（menu.js）

在 `DEFAULT_MENUS` 中添加考勤管理、进销存管理、财务管理三个分组，确保API失败时也有回退菜单。

### 步骤4：修复 refreshMenus 的 camelCase 问题

`refreshMenus` 方法中 `group.group_key` 应改为 `group.groupKey`（之前漏改）。

### 步骤5：递增缓存版本号

CACHE_VERSION 从 2 改为 3，使旧缓存失效，确保新菜单数据能正确加载。

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `webman/sql/add_app_menu_groups.sql` | 新增菜单分组数据的SQL |
| `webman/execute_add_menu_groups.php` | 执行SQL的PHP脚本 |
| `AppV3/src/store/modules/menu.js` | 更新DEFAULT_MENUS、修复refreshMenus、递增CACHE_VERSION |
