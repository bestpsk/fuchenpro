# AppV3 店企业出货管理实现计划

## 一、需求概述

在 AppV3 移动端实现"店企业出货"功能，借鉴 Web 端 `front/src/views/wms/enterpriseShipment/index.vue` 的功能，适配移动端交互，界面扁平化高级感。

## 二、现有资源

### 后端接口（已就绪，无需修改）

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 出货单列表 | GET | `/business/shipment/list` | 分页查询，支持 shipmentNo/enterpriseName/shipmentStatus/planId 筛选 |
| 出货单详情 | GET | `/business/shipment/{shipmentId}` | 获取详情（含明细、方案、企业） |
| 新增出货单 | POST | `/business/shipment` | 创建出货单（含明细） |
| 修改出货单 | PUT | `/business/shipment` | 仅待审核状态可修改 |
| 删除出货单 | DELETE | `/business/shipment` | 仅待审核状态可删除 |
| 审核出货单 | PUT | `/business/shipment/audit` | 通过/驳回 |
| 发货 | PUT | `/business/shipment/ship` | 填写物流信息 |
| 确认收货 | PUT | `/business/shipment/confirmReceipt/{shipmentId}` | 确认收货（扣库存+更新方案金额） |

### 出货状态流转

```
0(待审核) → 1(已审核) → 2(已发货) → 3(已收货)
   └→ 4(已驳回)
```

### 数据模型

出货单主表：shipmentNo、enterpriseId/Name、planId、contactPerson/Phone、shippingAddress、totalQuantity、totalAmount、shipmentStatus、logisticsCompany/No、shipmentDate、receiptDate、remark

出货明细：productId/Name、supplierId/Name、unitType、packQty、quantity、spec、salePrice、discountPrice、amount、planItemId

### 已有页面

方案详情页已有"出货"按钮（`canShipment`），跳转到 `/pages/business/plan/shipment?planId=xxx`，且 shipment.vue 页面已存在。

## 三、页面规划

### 3.1 出货单列表页 — `pages/wms/shipment/index.vue`

**布局结构**：
```
┌─────────────────────────────────┐
│  搜索区（白色背景，轻量设计）     │
│  [🔍 搜索出货单号/企业名] [筛选] │
├─────────────────────────────────┤
│  筛选弹窗                        │
│  状态: [全部][待审核][已审核]     │
│        [已发货][已收货][已驳回]   │
├─────────────────────────────────┤
│  scroll-view 列表区域            │
│  ┌─────────────────────────────┐│
│  │ SH20260526001      [待审核]  ││ ← 单号 + 状态标签
│  │ 馥田诗                      ││ ← 企业名称
│  │ 数量: 11  金额: ¥70,580    ││ ← 总数量 + 总金额
│  │ 2026-05-08                  ││ ← 创建时间
│  └─────────────────────────────┘│
│  u-loadmore                     │
└─────────────────────────────────┘
```

**核心功能**：
- 关键词搜索（出货单号/企业名称）
- 状态筛选（5种状态）
- 分页加载
- 卡片点击进入详情页
- 状态标签颜色：待审核-黄、已审核-蓝、已发货-绿、已收货-紫、已驳回-红

### 3.2 出货单详情页 — `pages/wms/shipment/detail.vue`

**布局结构**：
```
┌─────────────────────────────────┐
│  SH20260526001          [待审核] │ ← 单号 + 状态
├─────────────────────────────────┤
│  基本信息                        │
│  企业      馥田诗               │
│  方案      馥田诗 0%方案        │
│  收货人    张经理               │
│  收货电话  138xxxx  [拨打]      │
│  收货地址  南京市...            │
│  总数量    11                   │
│  总金额    ¥70,580             │
│  备注      ...                  │
├─────────────────────────────────┤
│  出货明细 (3项)                  │
│  ┌─────────────────────────────┐│
│  │ 1. 测试1                    ││
│  │ 供货商: 南京伊美荟           ││
│  │ 数量:10  单价:¥6800         ││
│  │ 折扣价:¥6418  金额:¥64180  ││
│  └─────────────────────────────┘│
├─────────────────────────────────┤
│  物流信息（已发货后显示）         │
│  物流公司  顺丰速运              │
│  物流单号  SF1234567890         │
│  发货日期  2026-05-10           │
├─────────────────────────────────┤
│  [审核通过] [审核驳回]           │ ← 待审核时
│  [发货]                         │ ← 已审核时
│  [确认收货]                     │ ← 已发货时
└─────────────────────────────────┘
```

**核心功能**：
- 出货单基本信息展示
- 出货明细展示（含供货商、数量、单价、折扣价、金额）
- 物流信息展示（已发货后可见）
- 条件操作按钮：
  - 待审核 → 审核通过、审核驳回
  - 已审核 → 发货（弹窗填写物流信息）
  - 已发货 → 确认收货
- 发货弹窗：输入物流公司+物流单号
- 电话可拨打

### 3.3 出货单创建页 — 已有 `pages/business/plan/shipment.vue`

方案详情页的"出货"按钮已跳转到此页面，无需新建。但需确认该页面功能完整。

## 四、文件变更清单

### 新建文件

| 文件路径 | 说明 |
|---------|------|
| `AppV3/src/api/business/shipment.js` | 出货单 API 接口封装 |
| `AppV3/src/pages/wms/shipment/index.vue` | 出货单列表页 |
| `AppV3/src/pages/wms/shipment/detail.vue` | 出货单详情页 |

### 修改文件

| 文件路径 | 修改内容 |
|---------|---------|
| `AppV3/src/pages.json` | 注册 2 个新页面路由 |
| `AppV3/src/store/modules/menu.js` | 更新 wms 分组"店企业出货"菜单项 path，递增 CACHE_VERSION |
| `webman/sql/add_plan_app_menu.sql` | 追加出货管理菜单更新 SQL |

## 五、实施步骤

### 步骤 1：创建出货单 API 文件

新建 `AppV3/src/api/business/shipment.js`，封装 8 个接口。

### 步骤 2：注册页面路由

在 `pages.json` 中添加 2 个路由：
- `pages/wms/shipment/index` — 出货管理
- `pages/wms/shipment/detail` — 出货详情

### 步骤 3：实现出货单列表页

创建 `pages/wms/shipment/index.vue`，扁平化高级感设计：
- 白色轻量搜索区
- 极简卡片列表（单号+状态→企业→数量+金额→时间）
- 状态筛选弹窗（5种状态）
- FAB 按钮暂不加（出货从方案详情创建）

### 步骤 4：实现出货单详情页

创建 `pages/wms/shipment/detail.vue`：
- 单号+状态标签（头部行）
- 基本信息卡片
- 出货明细卡片
- 物流信息卡片（已发货后显示）
- 条件操作按钮区
- 发货弹窗（物流公司+物流单号）
- 审核驳回弹窗

### 步骤 5：配置菜单

- 更新 `menu.js` 中 wms 分组"店企业出货"菜单项 path
- 递增 CACHE_VERSION
- 更新 SQL 文件

## 六、扁平化高级感设计要点

与供货商管理保持一致的设计语言：
1. **搜索区**：白色背景+微阴影，轻量简洁
2. **卡片**：极简风格，信息层次分明
3. **状态标签**：精致胶囊样式，5色状态体系
4. **配色**：灰阶为主，绿色系 `#10B981` 为进销存强调色
5. **间距**：更大留白，呼吸感强
