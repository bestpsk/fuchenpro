# 操作记录纳入订单管理 - 完整实施方案（含冗余清理）

## 一、方案核心

操作提交时双写：`biz_operation_record` + `biz_sales_order`(source_type=1)，与还款模式一致。

## 二、数据库改动

### 1. biz_sales_order 新增字段

```sql
ALTER TABLE `biz_sales_order`
  ADD COLUMN `source_type` char(1) NOT NULL DEFAULT '0' COMMENT '来源类型（0开单 1操作 2还款 3手动）' AFTER `order_status`,
  ADD COLUMN `operation_batch_id` varchar(32) DEFAULT NULL COMMENT '操作批次ID（来源为操作时关联）' AFTER `source_type`;

UPDATE `biz_sales_order` SET `source_type` = '0' WHERE `order_status` IN ('0', '1', '2');
UPDATE `biz_sales_order` SET `source_type` = '2' WHERE `order_status` = '3';
```

### 2. biz_sales_order 删除冗余字段 `total_amount`

`total_amount` 不在表结构中（BizRepaymentService 第131行写入但表无此列），MySQL 会忽略不存在的字段。应从代码中移除对 `total_amount` 的引用，统一使用 `deal_amount`。

### 3. biz_order_item 删除冗余字段 `is_deal` 和 `plan_price`

`is_deal` 和 `plan_price` 不在表结构中（BizRepaymentService 第155-156行写入但表无此列），应从代码中移除。

## 三、后端改动

### 4. BizSalesOrder Model - 新增字段到 fillable

文件：`webman/app/model/BizSalesOrder.php`
- fillable 新增 `source_type`, `operation_batch_id`

### 5. BizOperationRecordService - 操作提交时同步创建订单

文件：`webman/app/service/BizOperationRecordService.php`
- `insertRecord()` 中 `BizOperationRecord::create($data)` 后调用 `createOperationOrder($record)`
- 新增 `createOperationOrder($record)` 方法
- 新增 `generateOperationOrderNo()` 方法（格式 OP+日期+序号）

### 6. BizRepaymentService - 补充 source_type + 清理冗余字段

文件：`webman/app/service/BizRepaymentService.php`
- `createRepaymentOrder()` 添加 `'source_type' => '2'`
- 移除 `'total_amount' => $repaymentAmount`（冗余，deal_amount 已有值）
- 移除 `'is_deal' => 1` 和 `'plan_price' => $repaymentAmount`（biz_order_item 表无此列）

### 7. BizSalesOrderService - 移除硬编码 source_type

文件：`webman/app/service/BizSalesOrderService.php`
- 移除 `$item['source_type'] = '0';` 硬编码

## 四、前端改动

### 8. AppV3 订单管理 - 按类型跳转

文件：`AppV3/src/pages/business/order/index.vue`
- `goDetail(item)` 根据 source_type 跳转不同页面

### 9. AppV3 订单详情 - 支持操作类型

文件：`AppV3/src/pages/business/order/detail.vue`
- source_type=1 时展示操作详情（品项、次数、对比照等）

## 五、改动文件清单

| 文件 | 改动 |
|------|------|
| SQL (新增) | biz_sales_order 新增 source_type + operation_batch_id |
| `BizSalesOrder.php` | fillable 新增字段 |
| `BizOperationRecordService.php` | insertRecord 后同步创建订单 + 新增方法 |
| `BizRepaymentService.php` | 补充 source_type='2' + 清理冗余字段引用 |
| `BizSalesOrderService.php` | 移除硬编码 source_type |
| `AppV3/order/index.vue` | 按类型跳转 |
| `AppV3/order/detail.vue` | 支持操作类型详情 |
