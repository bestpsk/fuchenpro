# 添加 App 菜单配置路由菜单计划

## 目标
在管理后台的侧边栏"系统管理"目录下添加"App菜单配置"菜单项，使管理员可以访问 `system/appMenu/index.vue` 页面。

## 需要做的事情

### 1. 在 `sys_menu` 表中插入菜单记录

现有最大 menu_id = 2093，新菜单从 2100 开始。

**二级菜单（menu_type='C'）：**
- menu_id: 2100
- menu_name: 'App菜单配置'
- parent_id: 1（系统管理目录）
- path: 'appMenu'
- component: 'system/appMenu/index'
- perms: 'system:appMenu:list'
- icon: 'phone'（或 'guide'）
- order_num: 9（排在通知公告之后）

**三级按钮权限（menu_type='F'）：**
- 2101: App菜单查询 (system:appMenu:query)
- 2102: App菜单新增 (system:appMenu:add)
- 2103: App菜单修改 (system:appMenu:edit)
- 2104: App菜单删除 (system:appMenu:remove)

### 2. 无需修改前端路由

该项目的路由是**后端动态加载**的（通过 `getRouters` API），只要 `sys_menu` 表中配置了正确的 `path` 和 `component`，前端会自动注册路由并显示在侧边栏。

`component: 'system/appMenu/index'` 会被 `loadView()` 自动匹配到 `views/system/appMenu/index.vue`，该文件已在上一步创建。

### 3. 执行 SQL

创建一个 SQL 文件 `webman/sql/add_app_menu_config_menu.sql`，包含上述 INSERT 语句。用户执行后即可在管理后台看到菜单。
