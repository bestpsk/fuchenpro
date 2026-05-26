# 订单列表类型标签 - 借鉴首页逻辑 + 字典化

## 核心发现

首页 OrderList 的数据来自 `listArchive` API（客户归档表），有 `source_type` 字段（'0'=开单, '1'=操作, '2'=还款, '3'=手动）。订单列表的数据来自 `listSalesOrder` API（销售订单表），**没有** `source_type` 字段。

## 是否需要加字典？

**建议：加入字典。** 原因：

1. **与系统架构一致** — 项目已有完整的字典管理模块（`sys_dict_type` + `sys_dict_data`），管理后台可配置
2. **前端动态获取** — 不需要在前端硬编码映射关系，改名字/增减类型只改数据库
3. **复用性高** — 首页、订单列表、详情页等多处共用同一套字典
4. **扩展性好** — 未来新增来源类型时无需改代码

## 完整方案

### 第一步：添加字典数据

在 `sys_dict_data` 表中插入订单来源类型字典：

| dict_type | dict_label | dict_value | dict_sort | css_class | list_class | is_default |
|-----------|------------|------------|-----------|-----------|-----------|-----------|
| biz_source_type | 订单来源类型 | 0 | 1 | primary (蓝) | success | Y |
| biz_source_type | 订单来源类型 | 1 | 2 | success (绿) | info | N |
| biz_source_type | 订单来源类型 | 2 | 3 | warning (橙) | info | N |
| biz_source_type | 订单来源类型 | 3 | 4 | info (灰) | info | N |

同时在 `sys_dict_type` 中注册字典类型（如不存在）。

### 第二步：后端 - 补充 source_type + 字典接口

1. **BizSalesOrderService.php** — `selectOrderList()` 每条记录补充 `source_type => '0'`
2. 后端已有 `/system/dict/data/type/{dictType}` 接口可直接使用

### 第三步：前端 - 字典驱动渲染

**API 层**：新增或复用字典获取接口

**Store 层**：缓存 `biz_source_type` 字典数据

**order/index.vue 改动**：
- 用 `<u-tag>` 替换自定义 type-tag
- 从字典数据中匹配标签文字和颜色
- 降级：字典加载失败时使用本地默认值

## 映射规则

| dict_value | dict_label | u-tag type | 说明 |
|------------|-----------|------------|------|
| 0 | 开单 | primary | 销售订单默认值 |
| 1 | 操作 | success | 操作记录 |
| 2 | 还款 | warning | 还款记录 |
| 3 | 手动 | info | 手动建档 |

## 改动文件清单

| 文件 | 改动 |
|------|------|
| SQL 文件 | 插入 `biz_source_type` 字典数据和类型 |
| `webman/app/service/BizSalesOrderService.php` | list 方法补充 source_type |
| `AppV3/src/api/system/dictData.js` | 复用或新建字典查询接口 |
| `AppV3/src/store/modules/dict.js` | 新建字典 store（缓存） |
| `AppV3/src/pages/business/order/index.vue` | u-tag + 字典驱动渲染 |
