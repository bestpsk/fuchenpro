# 修复：删除数据库中残留的"打卡"记录

## 根因

前端代码已改好（DEFAULT_QUICK_ITEMS 和 DEFAULT_MENUS.quick 都已去掉"打卡"），但 **数据库 `app_menu_config` 表的 `quick` 分组中还有原始的"打卡"记录未删除**。

API 返回数据后，`quickMenus` getter 优先使用 `menus.quick.items`（数据库数据），只有为空时才回退到 DEFAULT_QUICK_ITEMS。所以数据库中的旧数据覆盖了前端的修改。

## 修复方案

### 步骤1：SQL 删除/更新数据库记录
```sql
-- 1. 删除 quick 分组中的"打卡"（与考勤管理的"考勤打卡"重复）
DELETE FROM app_menu_config WHERE group_key = 'quick' AND title = '打卡';

-- 2. 同时清理 quick 分组中不需要的个人中心类菜单（个人信息、修改密码、应用设置、日志查询）
DELETE FROM app_menu_config WHERE group_key = 'quick' AND title IN ('个人信息', '修改密码', '应用设置', '日志查询');
```

### 步骤2：验证
- CACHE_VERSION 已经是 5，上次改动后缓存应已失效
- 如果用户还有旧缓存，可能需要退出重新登录

## 修改文件
| 文件 | 操作 |
|------|------|
| 数据库 | 删除 quick 分组的"打卡"及多余个人中心菜单 |
