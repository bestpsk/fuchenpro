# 供货商管理"模块建设中"修复计划

## 问题

点击"供货商管理"菜单提示"模块建设中"，原因是菜单路径的优先级为：

**后端 API 响应 > 本地缓存 > DEFAULT_MENUS**

虽然前端 `menu.js` 的 `DEFAULT_MENUS` 已更新了供货商管理的 path，但后端 `/system/appMenu/grouped` 接口正常返回时，数据完全来自 `app_menu_config` 表，该表中供货商管理的 `path` 字段仍为空。

## 修复方案

### 步骤 1：更新数据库 SQL 文件

在 `webman/sql/add_plan_app_menu.sql` 中追加供货商管理菜单的 UPDATE 语句。

### 步骤 2：执行 SQL

需在数据库中执行 SQL，更新 `app_menu_config` 表中供货商管理的 path：

```sql
UPDATE app_menu_config SET path = '/pages/wms/supplier/index' WHERE group_key = 'wms' AND title = '供货商管理';
```

### 涉及文件

- `webman/sql/add_plan_app_menu.sql` — 追加供货商管理菜单更新 SQL
