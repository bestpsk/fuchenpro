# AppV3 方案管理功能实现计划

## 一、需求概述

在 AppV3 移动端新增"方案管理"菜单，借鉴 Web 端方案管理（`front/src/views/business/planList/index.vue`）的功能，适配移动端交互模式，实现方案的列表查看、新增/编辑、详情查看、审核流程、状态管理等核心功能。

## 二、现有资源分析

### 后端接口（已就绪，无需修改）

后端 `BizPlanController` 已提供完整的方案管理 API：

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 企业列表 | GET | `/business/plan/enterpriseList` | 新增方案时选择企业 |
| 方案列表 | GET | `/business/plan/list` | 分页查询方案 |
| 方案详情 | GET | `/business/plan/{planId}` | 获取方案详情（含明细、出货记录） |
| 新增方案 | POST | `/business/plan` | 创建方案 |
| 修改方案 | PUT | `/business/plan` | 编辑方案 |
| 删除方案 | DELETE | `/business/plan` | 删除方案 |
| 提交审核 | PUT | `/business/plan/submitAudit/{planId}` | 草稿/驳回 → 待审核 |
| 审核方案 | PUT | `/business/plan/audit` | 待审核 → 已审核/已驳回 |
| 变更状态 | PUT | `/business/plan/changeStatus` | 启用/停用切换 |

### Web 端功能参考

Web 端方案列表页（`planList/index.vue`）核心功能：
- 按企业名称、方案名称、审核状态筛选
- 方案列表展示（编号、企业、名称、回款比例、金额、审核状态等）
- 新增方案（先选企业 → 填写方案信息 + 配赠明细）
- 编辑/查看方案详情
- 提交审核 / 审核通过 / 审核驳回
- 启用/停用状态切换
- 从方案创建出货单

### AppV3 现有模式

- **列表页模式**：蓝色渐变搜索区 + 卡片列表 + 下拉刷新/上拉加载
- **表单页模式**：白色卡片表单 + 底部固定操作栏
- **详情页模式**：多卡片布局 + 条件显示操作按钮
- **组件库**：uview-plus（u-icon, u-popup, u-empty, u-loadmore, u-tag 等）
- **API 封装**：`src/api/business/` 目录下按模块分文件
- **路由注册**：`pages.json` 中静态配置
- **菜单配置**：后端 `app_menu_config` 表 + 前端 `menu.js` 默认菜单降级

## 三、页面规划

### 3.1 方案列表页 — `pages/business/plan/index.vue`

**布局结构**：
```
┌─────────────────────────────┐
│  搜索栏（蓝色渐变背景）       │
│  [🔍 搜索方案/企业名] [筛选▼]│
├─────────────────────────────┤
│  筛选弹窗 (u-popup top)      │
│  审核状态: [全部][草稿][待审核]│
│            [已审核][已驳回]   │
│  [重置] [确定]               │
├─────────────────────────────┤
│  scroll-view 列表区域        │
│  ┌───────────────────────┐  │
│  │ PL20260526001  [草稿]  │  │ ← 卡片 header: 编号 + 审核状态标签
│  │ 🏢 企业名称            │  │ ← 卡片 body
│  │ 📋 方案名称            │  │
│  │ 💰 方案金额 ¥10,000   │  │
│  │ 🎁 配赠 ¥8,000 剩余¥3k│  │
│  │ 📅 2026-01-01~12-31   │  │
│  └───────────────────────┘  │
│  u-loadmore                 │
├─────────────────────────────┤
│  [+] 悬浮新增按钮            │ ← FAB 按钮
└─────────────────────────────┘
```

**核心功能**：
- 关键词搜索（方案名称/企业名称模糊匹配）
- 审核状态筛选（u-popup 选项标签式）
- 分页加载（下拉刷新 + 上拉加载更多）
- 卡片点击进入详情页
- FAB 按钮跳转新增方案

### 3.2 方案表单页 — `pages/business/plan/form.vue`

**布局结构**：
```
┌─────────────────────────────┐
│  基本信息卡片                │
│  🏢 [企业名称        ▶]     │ ← 新增时选择企业（点击弹出企业列表）
│  📋 [方案名称________]      │
│  💰 [回款比例(%)____]       │
│  💵 [方案金额________]      │
│  🎁 [配赠金额________]      │
│  📅 [生效日期    ▶]         │ ← 日期选择器
│  📅 [失效日期    ▶]         │
│  📝 [备注__________]        │
├─────────────────────────────┤
│  配赠明细卡片                │
│  配赠明细 (3项)    [+添加]   │
│  ┌───────────────────────┐  │
│  │ 货品名称  ×10  ¥500   │  │ ← 每行一个明细项
│  │ 供货商 | 单位 | 单价   │  │
│  │              [编辑][删]│  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ ...                    │  │
│  └───────────────────────┘  │
├─────────────────────────────┤
│  [取消]          [保存]      │ ← 固定底部操作栏
└─────────────────────────────┘
```

**核心功能**：
- 三模式复用：`mode=add/edit/view`（view 模式只读）
- 新增时先选企业（u-popup 弹出企业列表，支持搜索）
- 配赠明细：卡片式展示，点击"添加"弹出明细编辑弹窗
- 明细编辑弹窗：货品搜索选择 + 数量/单位/单价输入 + 自动计算金额
- 表单校验：方案名称、企业、方案金额、配赠金额必填
- 保存成功后返回列表页

### 3.3 方案详情页 — `pages/business/plan/detail.vue`

**布局结构**：
```
┌─────────────────────────────┐
│  状态卡片                    │
│  [已审核]  方案编号          │ ← 大号状态标签 + 编号
│  PL20260526001               │
├─────────────────────────────┤
│  基本信息卡片                │
│  🏢 企业名称                │
│  📋 方案名称                │
│  💰 回款比例 30%            │
│  💵 方案金额 ¥10,000       │
│  🎁 配赠金额 ¥8,000        │
│  📦 已出金额 ¥5,000        │
│  📊 剩余金额 ¥3,000        │
│  📅 有效期 2026-01~12      │
├─────────────────────────────┤
│  配赠明细卡片                │
│  配赠明细 (3项)              │
│  ┌───────────────────────┐  │
│  │ 货品名称               │  │
│  │ 数量:10 已出:3 剩余:7  │  │
│  │ 单价 ¥50  金额 ¥500   │  │
│  └───────────────────────┘  │
├─────────────────────────────┤
│  出货记录卡片（已审核时显示） │
│  出货记录 (2条)              │
│  ┌───────────────────────┐  │
│  │ SH20260526001 [已发货] │  │
│  │ 数量:5  金额:¥250     │  │
│  │ 2026-05-26             │  │
│  └───────────────────────┘  │
├─────────────────────────────┤
│  操作按钮区（条件显示）       │
│  [编辑] [提交审核]           │ ← 草稿/已驳回状态
│  [通过] [驳回]               │ ← 待审核状态
│  [创建出货单]                │ ← 已审核状态
│  [启用/停用]                 │ ← 已审核状态
└─────────────────────────────┘
```

**核心功能**：
- 方案基本信息展示
- 配赠明细展示（含已出/剩余数量）
- 出货记录展示（已审核后可见）
- 条件操作按钮：
  - 草稿/已驳回：编辑、提交审核
  - 待审核：审核通过、审核驳回（驳回需填写原因）
  - 已审核：创建出货单、启用/停用
- 审核驳回时弹出输入框填写驳回原因

## 四、文件变更清单

### 4.1 新建文件

| 文件路径 | 说明 |
|---------|------|
| `AppV3/src/api/business/plan.js` | 方案管理 API 接口封装 |
| `AppV3/src/pages/business/plan/index.vue` | 方案列表页 |
| `AppV3/src/pages/business/plan/form.vue` | 方案表单页（新增/编辑） |
| `AppV3/src/pages/business/plan/detail.vue` | 方案详情页 |

### 4.2 修改文件

| 文件路径 | 修改内容 |
|---------|---------|
| `AppV3/src/pages.json` | 注册 3 个新页面路由 |
| `AppV3/src/store/modules/menu.js` | 在 DEFAULT_MENUS 的 business 分组中添加"方案管理"菜单项，递增 CACHE_VERSION |
| 数据库 `app_menu_config` 表 | 新增"方案管理"菜单记录（通过管理后台或 SQL） |

## 五、实施步骤

### 步骤 1：创建方案 API 文件

新建 `AppV3/src/api/business/plan.js`，封装以下接口：

```javascript
import request from '@/utils/request'

export function listPlan(query) {
  return request({ url: '/business/plan/list', method: 'get', params: query })
}

export function listEnterprise(query) {
  return request({ url: '/business/plan/enterpriseList', method: 'get', params: query })
}

export function getPlan(planId) {
  return request({ url: `/business/plan/${planId}`, method: 'get' })
}

export function addPlan(data) {
  return request({ url: '/business/plan', method: 'post', data })
}

export function updatePlan(data) {
  return request({ url: '/business/plan', method: 'put', data })
}

export function delPlan(planIds) {
  return request({ url: '/business/plan', method: 'delete', data: planIds })
}

export function submitAuditPlan(planId) {
  return request({ url: `/business/plan/submitAudit/${planId}`, method: 'put' })
}

export function auditPlan(data) {
  return request({ url: '/business/plan/audit', method: 'put', data })
}

export function changePlanStatus(planId, status) {
  return request({ url: '/business/plan/changeStatus', method: 'put', params: { planId, status } })
}
```

### 步骤 2：注册页面路由

在 `pages.json` 的 `pages` 数组中添加：

```json
{
  "path": "pages/business/plan/index",
  "style": {
    "navigationBarTitleText": "方案管理",
    "navigationBarBackgroundColor": "#3D6DF7",
    "navigationBarTextStyle": "white"
  }
},
{
  "path": "pages/business/plan/form",
  "style": {
    "navigationBarTitleText": "方案信息",
    "navigationBarBackgroundColor": "#3D6DF7",
    "navigationBarTextStyle": "white"
  }
},
{
  "path": "pages/business/plan/detail",
  "style": {
    "navigationBarTitleText": "方案详情",
    "navigationBarBackgroundColor": "#3D6DF7",
    "navigationBarTextStyle": "white"
  }
}
```

### 步骤 3：实现方案列表页

创建 `AppV3/src/pages/business/plan/index.vue`，参照 `order/index.vue` 的模式：

- 蓝色渐变搜索区 + 筛选按钮
- u-popup 审核状态筛选（草稿/待审核/已审核/已完成/已驳回）
- scroll-view 卡片列表 + 下拉刷新/上拉加载
- 审核状态标签（不同状态不同颜色：草稿-灰、待审核-蓝、已审核-绿、已完成-紫、已驳回-红）
- FAB 新增按钮
- 卡片点击跳转详情页

### 步骤 4：实现方案表单页

创建 `AppV3/src/pages/business/plan/form.vue`，参照 `enterprise/form.vue` 的模式：

- 支持 `mode=add/edit/view` 三种模式
- 新增模式下企业选择：u-popup 弹出企业列表（带搜索）
- 基本信息表单字段
- 配赠明细区域：
  - 卡片式展示已有明细
  - "添加明细"按钮弹出明细编辑弹窗
  - 明细编辑弹窗：货品搜索选择 + 数量/单位类型/单价输入
  - 自动计算金额
  - 支持删除明细
- 底部固定操作栏

### 步骤 5：实现方案详情页

创建 `AppV3/src/pages/business/plan/detail.vue`，参照 `order/detail.vue` 的模式：

- 状态卡片（大号状态标签 + 方案编号）
- 基本信息卡片
- 配赠明细卡片
- 出货记录卡片（已审核后显示）
- 条件操作按钮区：
  - 草稿/已驳回 → 编辑、提交审核
  - 待审核 → 审核通过、审核驳回
  - 已审核 → 创建出货单、启用/停用
- 审核驳回弹窗（输入驳回原因）

### 步骤 6：配置菜单

#### 6.1 更新前端默认菜单

修改 `AppV3/src/store/modules/menu.js`：
- 在 `DEFAULT_MENUS` 的 `business` 分组中添加方案管理菜单项
- 递增 `CACHE_VERSION`

```javascript
// business 分组中新增
{ id: 'plan', title: '方案管理', icon: 'file-text', path: '/pages/business/plan/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 6 }
```

#### 6.2 数据库菜单配置

通过管理后台「系统管理 → App菜单配置」添加，或执行 SQL：

```sql
INSERT INTO app_menu_config (group_name, group_key, group_sort, title, icon, path, icon_color, bg_color, sort_order, visible, status, perms)
VALUES ('业务管理', 'business', 2, '方案管理', 'file-text', '/pages/business/plan/index', '#fff', '#FF6B35', 6, 1, '0', 'business:plan:list');
```

## 六、审核状态设计

| 状态值 | 标签 | 颜色 | 允许操作 |
|-------|------|------|---------|
| 0 | 草稿 | #86909C（灰色） | 编辑、提交审核、删除 |
| 1 | 待审核 | #3D6DF7（蓝色） | 审核通过、审核驳回 |
| 2 | 已审核 | #10B981（绿色） | 创建出货单、启用/停用 |
| 3 | 已完成 | #8B5CF6（紫色） | 无 |
| 4 | 已驳回 | #F53F3F（红色） | 编辑、重新提交审核 |

## 七、关键交互细节

### 7.1 新增方案流程

```
点击FAB[+] → 进入表单页(mode=add) → 选择企业(弹窗) → 填写方案信息 → 添加配赠明细 → 保存 → 返回列表
```

### 7.2 审核流程

```
列表/详情 → [提交审核] → 确认弹窗 → 调用API → 刷新状态
详情页 → [审核通过] → 确认弹窗 → 调用API → 刷新状态
详情页 → [审核驳回] → 输入驳回原因弹窗 → 调用API → 刷新状态
```

### 7.3 配赠明细编辑

```
表单页 → [添加明细] → 弹窗选择货品(搜索) → 填写数量/单价 → 自动计算金额 → 确认 → 明细列表更新
明细卡片 → [编辑] → 弹窗回填数据 → 修改 → 确认
明细卡片 → [删除] → 确认弹窗 → 移除
```

## 八、注意事项

1. **后端接口无需修改**：所有方案管理 API 已在 `BizPlanController` 中实现完毕
2. **出货单功能暂不实现**：本次仅实现方案管理的核心功能（列表/新增/编辑/详情/审核），出货单创建作为后续迭代
3. **权限控制**：菜单权限通过 `app_menu_config.perms` 字段控制可见性，按钮级权限可后续细化
4. **缓存版本**：修改 `DEFAULT_MENUS` 后必须递增 `CACHE_VERSION`，否则旧缓存不会失效
5. **样式一致性**：严格遵循 AppV3 现有的颜色体系、圆角规范、字体色阶等样式约定
