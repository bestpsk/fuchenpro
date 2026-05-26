# AppV3 移动端菜单可配置化方案

## 一、现状分析

### 当前问题
AppV3 的菜单在多处**硬编码**，分散在不同组件中，无法动态调整：

| 位置 | 菜单数 | 硬编码方式 |
|------|--------|-----------|
| [QuickMenu.vue](file:///f:/fuchen/AppV3/src/components/home/QuickMenu.vue) | 4项 | `ref([...])` 写死 |
| [work/index.vue](file:///f:/fuchen/AppV3/src/pages/work/index.vue) | 18项（3组） | `ref([...])` 写死 |
| [mine/index.vue](file:///f:/fuchen/AppV3/src/pages/mine/index.vue) | 8项（2组） | 模板中直接写死 |

### 已有基础设施
- 后端已有 `sys_menu` 表和完整的菜单管理 CRUD API（`/system/menu/*`）
- 管理后台（`front/`）已有菜单管理页面，支持树形结构、图标选择、排序等
- 后端已有 `getRouters` API 可根据用户角色返回权限菜单

### 核心差异
PC 端菜单是**侧边栏树形结构**，移动端菜单是**分组网格卡片**布局，两者结构完全不同，不宜复用同一张表。

---

## 二、方案设计

### 整体架构

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  管理后台 (front) │────▶│  后端 API (webman) │◀────│  移动端 (AppV3)  │
│  菜单配置+预览    │     │  app_menu_config  │     │  动态加载菜单    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

### 数据库设计 - `app_menu_config` 表

```sql
CREATE TABLE `app_menu_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_name` varchar(50) NOT NULL DEFAULT '' COMMENT '分组名称（如：常用功能、业务管理）',
  `group_key` varchar(50) NOT NULL DEFAULT '' COMMENT '分组标识（如：quick、business、system、mine_action、mine_menu）',
  `group_sort` int NOT NULL DEFAULT 0 COMMENT '分组排序（数字越小越靠前）',
  `title` varchar(50) NOT NULL COMMENT '菜单标题',
  `icon` varchar(100) NOT NULL DEFAULT '' COMMENT '图标名称（uview-plus图标名）',
  `path` varchar(255) NOT NULL DEFAULT '' COMMENT '跳转路径（空表示建设中）',
  `icon_color` varchar(20) NOT NULL DEFAULT '#3D6DF7' COMMENT '图标颜色',
  `bg_color` varchar(20) NOT NULL DEFAULT '#E8F0FE' COMMENT '图标背景色',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '组内排序',
  `visible` tinyint NOT NULL DEFAULT 1 COMMENT '是否显示（1显示 0隐藏）',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`)
) COMMENT='App移动端菜单配置表';
```

**分组标识说明：**

| group_key | group_name | 对应位置 |
|-----------|-----------|---------|
| `quick` | 常用功能 | 首页快捷菜单 + 工作台常用功能 |
| `business` | 业务管理 | 工作台业务管理区 |
| `system` | 系统管理 | 工作台系统管理区 |
| `mine_action` | 快捷操作 | 我的-快捷操作区 |
| `mine_menu` | 个人菜单 | 我的-菜单列表区 |

---

## 三、实施步骤

### 第一步：后端 - 创建数据表和API

#### 1.1 创建数据库表
- 执行 SQL 创建 `app_menu_config` 表
- 插入初始数据（从当前硬编码菜单迁移）

#### 1.2 创建 Model
- 文件：`webman/app/model/AppMenuConfig.php`
- 映射 `app_menu_config` 表

#### 1.3 创建 Service
- 文件：`webman/app/service/AppMenuConfigService.php`
- 方法：
  - `list($params)` - 查询菜单列表（支持按 group_key 筛选）
  - `getGroupedMenus()` - 获取按分组组织的菜单（供移动端调用）
  - `getInfo($id)` - 获取单条详情
  - `add($data)` - 新增菜单项
  - `edit($data)` - 修改菜单项
  - `remove($id)` - 删除菜单项
  - `updateSort($data)` - 批量更新排序
  - `changeStatus($id, $status)` - 切换显示/隐藏

#### 1.4 创建 Controller
- 文件：`webman/app/controller/system/AppMenuConfigController.php`
- 对外暴露 RESTful API

#### 1.5 注册路由
- 在 `webman/config/route.php` 中添加路由：
  - `GET /system/appMenu/list` - 列表
  - `GET /system/appMenu/grouped` - 分组菜单（移动端用）
  - `GET /system/appMenu/{id}` - 详情
  - `POST /system/appMenu` - 新增
  - `PUT /system/appMenu` - 修改
  - `DELETE /system/appMenu` - 删除
  - `PUT /system/appMenu/updateSort` - 排序
  - `PUT /system/appMenu/changeStatus` - 切换状态

### 第二步：管理后台 - 菜单配置页面（含预览）

#### 2.1 创建 API 模块
- 文件：`front/src/api/system/appMenu.js`
- 封装所有 appMenu 相关接口

#### 2.2 创建菜单配置页面
- 文件：`front/src/views/system/appMenu/index.vue`
- **左侧**：菜单配置区
  - 按分组展示菜单项（Tab 切换或折叠面板）
  - 支持新增、编辑、删除菜单项
  - 支持拖拽排序
  - 支持切换显示/隐藏
  - 支持选择 uview-plus 图标
- **右侧**：手机预览区
  - 模拟手机屏幕（375×667）
  - 实时预览菜单布局效果
  - 可切换预览"首页"/"工作台"/"我的"三个页面

#### 2.3 创建图标选择组件
- 文件：`front/src/components/UviewIconSelect/index.vue`
- 展示 uview-plus 常用图标列表供选择

#### 2.4 注册路由和菜单
- 在管理后台路由中添加 `/system/appMenu` 路由
- 在 `sys_menu` 表中插入"App菜单配置"菜单项

### 第三步：移动端 - 动态菜单加载

#### 3.1 创建 API 模块
- 文件：`AppV3/src/api/system/appMenu.js`
- 封装获取分组菜单接口

#### 3.2 创建 Pinia Store
- 文件：`AppV3/src/store/modules/menu.js`
- 管理菜单数据状态
- 支持本地缓存（避免每次启动都请求）
- 提供 `loadMenus()` 和 `refreshMenus()` 方法

#### 3.3 改造 QuickMenu.vue
- 从 store 获取 `quick` 分组菜单
- 保留"更多"按钮
- 降级处理：API 请求失败时使用本地默认菜单

#### 3.4 改造 work/index.vue
- 从 store 获取 `quick`、`business`、`system` 分组菜单
- 动态渲染各组菜单
- 保留搜索功能

#### 3.5 改造 mine/index.vue
- 从 store 获取 `mine_action`、`mine_menu` 分组菜单
- 动态渲染快捷操作和菜单列表

#### 3.6 在 App.vue 中预加载
- 应用启动时调用 `loadMenus()` 预加载菜单配置
- 登录成功后刷新菜单

---

## 四、初始数据 SQL

```sql
INSERT INTO `app_menu_config` (`group_name`, `group_key`, `group_sort`, `title`, `icon`, `path`, `icon_color`, `bg_color`, `sort_order`, `visible`, `status`) VALUES
-- 常用功能（首页快捷菜单 + 工作台）
('常用功能', 'quick', 1, '打卡', 'clock', '/pages/attendance/index', '#3D6DF7', '#E8F0FE', 1, 1, '0'),
('常用功能', 'quick', 1, '开单', 'file-text', '/pages/business/sales/index', '#3D6DF7', '#E8F0FE', 2, 1, '0'),
('常用功能', 'quick', 1, '行程', 'calendar', '/pages/business/schedule/index', '#3D6DF7', '#E8F0FE', 3, 1, '0'),
('常用功能', 'quick', 1, '订单', 'list', '/pages/business/order/index', '#3D6DF7', '#E8F0FE', 4, 1, '0'),
('常用功能', 'quick', 1, '个人信息', 'account-fill', '/pages/mine/info/index', '#3D6DF7', '#E8F0FE', 5, 1, '0'),
('常用功能', 'quick', 1, '修改密码', 'lock-fill', '/pages/mine/pwd/index', '#3D6DF7', '#E8F0FE', 6, 1, '0'),
('常用功能', 'quick', 1, '应用设置', 'setting', '/pages/mine/setting/index', '#3D6DF7', '#E8F0FE', 7, 1, '0'),
('常用功能', 'quick', 1, '日志查询', 'file-text', '', '#3D6DF7', '#E8F0FE', 8, 1, '0'),

-- 业务管理
('业务管理', 'business', 2, '企业管理', 'home-fill', '/pages/business/enterprise/index', '#fff', '#FF6B35', 1, 1, '0'),
('业务管理', 'business', 2, '门店管理', 'shop', '/pages/business/store/index', '#fff', '#FF6B35', 2, 1, '0'),
('业务管理', 'business', 2, '行程安排', 'calendar', '/pages/business/schedule/index', '#fff', '#FF6B35', 3, 1, '0'),
('业务管理', 'business', 2, '销售开单', 'edit-pen', '/pages/business/sales/index', '#fff', '#FF6B35', 4, 1, '0'),
('业务管理', 'business', 2, '项目操作', 'grid', '/pages/business/operation/index', '#fff', '#FF6B35', 5, 1, '0'),
('业务管理', 'business', 2, '订单管理', 'list', '/pages/business/order/index', '#fff', '#FF6B35', 6, 1, '0'),

-- 系统管理
('系统管理', 'system', 3, '用户管理', 'account', '', '#fff', '#3D6DF7', 1, 1, '0'),
('系统管理', 'system', 3, '角色管理', 'man-add', '', '#fff', '#3D6DF7', 2, 1, '0'),
('系统管理', 'system', 3, '菜单管理', 'list', '', '#fff', '#3D6DF7', 3, 1, '0'),
('系统管理', 'system', 3, '部门管理', 'home', '', '#fff', '#3D6DF7', 4, 1, '0'),
('系统管理', 'system', 3, '岗位管理', 'bookmark', '', '#fff', '#3D6DF7', 5, 1, '0'),
('系统管理', 'system', 3, '字典管理', 'file-text', '', '#fff', '#3D6DF7', 6, 1, '0'),
('系统管理', 'system', 3, '参数设置', 'setting', '', '#fff', '#3D6DF7', 7, 1, '0'),
('系统管理', 'system', 3, '通知公告', 'chat', '', '#fff', '#3D6DF7', 8, 1, '0'),

-- 我的-快捷操作
('快捷操作', 'mine_action', 4, '在线客服', 'chat', '', '#666', '#f5f5f5', 1, 1, '0'),
('快捷操作', 'mine_action', 4, '反馈社区', 'edit-pen', '', '#666', '#f5f5f5', 2, 1, '0'),
('快捷操作', 'mine_action', 4, '点赞我们', 'thumb-up', '', '#666', '#f5f5f5', 3, 1, '0'),
('快捷操作', 'mine_action', 4, '关于我们', 'info-circle', '/pages/mine/about/index', '#666', '#f5f5f5', 4, 1, '0'),

-- 我的-菜单列表
('个人菜单', 'mine_menu', 5, '编辑资料', 'edit-pen', '/pages/mine/info/edit', '#3c96f3', '#e8f2ff', 1, 1, '0'),
('个人菜单', 'mine_menu', 5, '常见问题', 'question-circle', '/pages/mine/help/index', '#3c96f3', '#e8f2ff', 2, 1, '0'),
('个人菜单', 'mine_menu', 5, '关于我们', 'info-circle', '/pages/mine/about/index', '#3c96f3', '#e8f2ff', 3, 1, '0'),
('个人菜单', 'mine_menu', 5, '应用设置', 'setting', '/pages/mine/setting/index', '#3c96f3', '#e8f2ff', 4, 1, '0');
```

---

## 五、管理后台预览界面设计

```
┌──────────────────────────────────────────────────────────────┐
│  App菜单配置                                                   │
├──────────────────────────┬───────────────────────────────────┤
│                          │                                   │
│  [常用功能] [业务管理]     │     ┌─────────────────────┐       │
│  [系统管理] [快捷操作]     │     │   📱 手机预览        │       │
│  [个人菜单]              │     │                     │       │
│                          │     │  ┌───┐ ┌───┐ ┌───┐  │       │
│  ┌──────────────────┐   │     │  │打卡│ │开单│ │行程│  │       │
│  │ 打卡  ✏️ 🗑️ 👁️   │   │     │  └───┘ └───┘ └───┘  │       │
│  │ /pages/attendance │   │     │  ┌───┐ ┌───┐        │       │
│  ├──────────────────┤   │     │  │订单│ │更多│        │       │
│  │ 开单  ✏️ 🗑️ 👁️   │   │     │  └───┘ └───┘        │       │
│  │ /pages/sales/...  │   │     │                     │       │
│  ├──────────────────┤   │     │  ── 常用功能 ──       │       │
│  │ ...              │   │     │  ┌───┐ ┌───┐ ┌───┐  │       │
│  └──────────────────┘   │     │  │   │ │   │ │   │  │       │
│                          │     │  └───┘ └───┘ └───┘  │       │
│  [+ 新增菜单项]           │     │                     │       │
│                          │     └─────────────────────┘       │
│                          │     [首页] [工作台] [我的]          │
└──────────────────────────┴───────────────────────────────────┘
```

**预览功能要点：**
- 右侧模拟 iPhone 外壳，内部实时渲染菜单效果
- 底部 Tab 切换预览不同页面（首页/工作台/我的）
- 左侧修改菜单后右侧实时更新预览
- 预览中的菜单项可点击（展示跳转路径提示）

---

## 六、降级与容错策略

1. **API 请求失败**：使用本地硬编码的默认菜单作为 fallback
2. **本地缓存**：菜单数据缓存到 `uni.setStorageSync`，下次启动先读缓存
3. **版本控制**：菜单数据带版本号，后端菜单变更时前端自动刷新缓存
4. **TabBar 不可动态化**：UniApp 的 tabBar 必须在 `pages.json` 中静态配置，这部分保持不变

---

## 七、文件变更清单

### 新增文件
| 文件 | 说明 |
|------|------|
| `webman/app/model/AppMenuConfig.php` | 菜单配置模型 |
| `webman/app/service/AppMenuConfigService.php` | 菜单配置服务 |
| `webman/app/controller/system/AppMenuConfigController.php` | 菜单配置控制器 |
| `webman/sql/create_app_menu_config.sql` | 建表+初始数据SQL |
| `front/src/api/system/appMenu.js` | 管理后台API模块 |
| `front/src/views/system/appMenu/index.vue` | 菜单配置页面（含预览） |
| `front/src/components/UviewIconSelect/index.vue` | uview图标选择器 |
| `AppV3/src/api/system/appMenu.js` | 移动端API模块 |
| `AppV3/src/store/modules/menu.js` | 菜单状态管理 |

### 修改文件
| 文件 | 变更内容 |
|------|---------|
| `webman/config/route.php` | 添加 appMenu 路由 |
| `AppV3/src/components/home/QuickMenu.vue` | 改为动态菜单 |
| `AppV3/src/pages/work/index.vue` | 改为动态菜单 |
| `AppV3/src/pages/mine/index.vue` | 改为动态菜单 |
| `AppV3/src/App.vue` | 启动时预加载菜单 |
