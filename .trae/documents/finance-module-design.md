# 财务管理模块设计方案

## 一、模块概述

### 主菜单：财务管理
新增一级菜单"财务管理"，包含三个子菜单：
1. **方案审核** - 财务视角的方案审核管理
2. **报销管理** - 员工报销申请与审批
3. **报销统计** - 报销数据统计报表

---

## 二、方案审核（子菜单）

### 功能说明
复用现有 `biz_plan` 表和审核功能，但提供财务专属视角：
- 默认筛选待审核(audit_status=1)和已驳回(audit_status=4)的方案
- 待审核/已驳回排在最上方
- 财务可进行审核通过/驳回操作
- 支持按企业、方案名称、审核状态筛选

### 数据来源
复用现有方案表 `biz_plan`，审核状态字段：
- `0` - 草稿
- `1` - 待审核（提交后）
- `2` - 已审核（通过）
- `3` - 已完成（发货完毕）
- `4` - 已驳回

### 前端页面
新建 `front/src/views/finance/planAudit/index.vue`，参考现有 `business/plan/index.vue` 但简化为财务视角。

---

## 三、报销管理（子菜单）

### 3.1 业务流程设计

```
员工提交报销申请
       ↓
  选择支出类型
       ↓
┌──────────────────┐
│ 员工支出          │ 公司支出          │
│ (个人先垫付)      │ (公司直接支付)    │
└──────────────────┘
       ↓                ↓
  部门主管审核      财务审核
       ↓                ↓
  财务复核打款      直接支付
       ↓                ↓
    完成              完成
```

### 3.2 数据库设计

#### 报销单表 `fin_reimbursement`
| 字段 | 类型 | 说明 |
|------|------|------|
| reimbursement_id | int | 主键ID |
| reimbursement_no | varchar(32) | 报销单号（自动生成） |
| applicant_id | int | 申请人ID |
| applicant_name | varchar(50) | 申请人姓名 |
| dept_id | int | 所属部门ID |
| dept_name | varchar(100) | 部门名称 |
| apply_date | date | 申请日期 |
| category | char(1) | 分类：1行程买票 2销售费用 3行政支出 4其它 |
| income_amount | decimal(12,2) | 收入金额（如有） |
| expense_amount | decimal(12,2) | 支出金额 |
| expense_type | char(1) | 支出类型：1员工支出 2公司支出 |
| status | char(1) | 状态：0待审核 1已审核 2已驳回 3已支付 |
| voucher_images | text | 凭证图片（JSON数组） |
| remark | varchar(500) | 备注 |
| audit_by | varchar(50) | 审核人 |
| audit_time | datetime | 审核时间 |
| audit_remark | varchar(500) | 审核备注 |
| pay_by | varchar(50) | 支付人 |
| pay_time | datetime | 支付时间 |
| create_by | varchar(50) | 创建人 |
| create_time | datetime | 创建时间 |
| update_by | varchar(50) | 更新人 |
| update_time | datetime | 更新时间 |

#### 报销明细表 `fin_reimbursement_item`（可选，支持多项报销）
| 字段 | 类型 | 说明 |
|------|------|------|
| item_id | int | 主键ID |
| reimbursement_id | int | 报销单ID |
| item_name | varchar(100) | 项目名称 |
| amount | decimal(12,2) | 金额 |
| description | varchar(200) | 说明 |

### 3.3 字典配置

新增字典类型 `fin_reimbursement_category`（报销分类）：
- 1 - 行程买票
- 2 - 销售费用
- 3 - 行政支出
- 4 - 其它

新增字典类型 `fin_reimbursement_expense_type`（支出类型）：
- 1 - 员工支出（个人先垫付，公司后报销）
- 2 - 公司支出（公司直接支付）

新增字典类型 `fin_reimbursement_status`（报销状态）：
- 0 - 待审核
- 1 - 已审核
- 2 - 已驳回
- 3 - 已支付

### 3.4 后端文件

| 文件 | 说明 |
|------|------|
| `app/model/FinReimbursement.php` | 报销单模型 |
| `app/model/FinReimbursementItem.php` | 报销明细模型 |
| `app/service/FinReimbursementService.php` | 报销服务层 |
| `app/controller/finance/FinReimbursementController.php` | 报销控制器 |

### 3.5 前端文件

| 文件 | 说明 |
|------|------|
| `front/src/views/finance/reimbursement/index.vue` | 报销列表页 |
| `front/src/api/finance/reimbursement.js` | 报销API接口 |

### 3.6 功能点

- **新增报销单**：员工填写报销申请，上传凭证图片
- **提交审核**：保存后提交给审核人
- **审核通过/驳回**：审核人操作，可填写审核意见
- **确认支付**：财务确认已打款/支付
- **我的报销**：当前用户查看自己的报销记录
- **待我审核**：审核人查看待审核的报销单

---

## 四、报销统计（子菜单）

### 4.1 统计维度

1. **按时间统计**
   - 月度报销金额趋势图
   - 季度/年度汇总

2. **按分类统计**
   - 各分类报销金额占比（饼图）
   - 行程买票、销售费用、行政支出、其它

3. **按部门统计**
   - 各部门报销金额排名
   - 部门月度报销趋势

4. **按人员统计**
   - 个人报销金额排名
   - 个人报销明细查询

5. **按支出类型统计**
   - 员工支出 vs 公司支出对比

### 4.2 前端页面

| 文件 | 说明 |
|------|------|
| `front/src/views/finance/reimbursementReport/index.vue` | 报销统计页 |

### 4.3 后端接口

| 接口 | 说明 |
|------|------|
| `/finance/reimbursement/report/byMonth` | 按月统计 |
| `/finance/reimbursement/report/byCategory` | 按分类统计 |
| `/finance/reimbursement/report/byDept` | 按部门统计 |
| `/finance/reimbursement/report/byUser` | 按人员统计 |

---

## 五、菜单与权限配置

### 5.1 菜单SQL

```sql
-- 一级菜单：财务管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
VALUES (3000, '财务管理', 0, 5, 'finance', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'money', 'admin', NOW());

-- 子菜单：方案审核
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
VALUES (3001, '方案审核', 3000, 1, 'planAudit', 'finance/planAudit/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:planAudit:list', 'edit', 'admin', NOW());

-- 子菜单：报销管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
VALUES (3002, '报销管理', 3000, 2, 'reimbursement', 'finance/reimbursement/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursement:list', 'form', 'admin', NOW());

-- 子菜单：报销统计
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
VALUES (3003, '报销统计', 3000, 3, 'reimbursementReport', 'finance/reimbursementReport/index', NULL, NULL, 1, 0, 'C', '0', '0', 'finance:reimbursementReport:list', 'chart', 'admin', NOW());
```

### 5.2 权限标识

| 权限 | 说明 |
|------|------|
| `finance:planAudit:list` | 方案审核列表 |
| `finance:planAudit:audit` | 方案审核操作 |
| `finance:reimbursement:list` | 报销列表 |
| `finance:reimbursement:add` | 新增报销 |
| `finance:reimbursement:edit` | 编辑报销 |
| `finance:reimbursement:audit` | 审核报销 |
| `finance:reimbursement:pay` | 确认支付 |
| `finance:reimbursementReport:list` | 报销统计 |

---

## 六、实施步骤

### 步骤1：数据库准备
- 创建报销单表 `fin_reimbursement`
- 创建报销明细表 `fin_reimbursement_item`
- 插入菜单数据
- 插入字典数据

### 步骤2：后端开发
- 创建模型文件
- 创建服务层
- 创建控制器
- 配置路由

### 步骤3：前端开发
- 创建API接口文件
- 创建方案审核页面
- 创建报销管理页面
- 创建报销统计页面

### 步骤4：测试验证
- 测试报销申请流程
- 测试审核流程
- 测试统计报表

---

## 七、文件清单

### 后端文件（新建）
| 文件路径 | 说明 |
|----------|------|
| `app/model/FinReimbursement.php` | 报销单模型 |
| `app/model/FinReimbursementItem.php` | 报销明细模型 |
| `app/service/FinReimbursementService.php` | 报销服务层 |
| `app/controller/finance/FinReimbursementController.php` | 报销控制器 |
| `app/controller/finance/FinPlanAuditController.php` | 方案审核控制器 |

### 前端文件（新建）
| 文件路径 | 说明 |
|----------|------|
| `front/src/views/finance/planAudit/index.vue` | 方案审核页 |
| `front/src/views/finance/reimbursement/index.vue` | 报销管理页 |
| `front/src/views/finance/reimbursementReport/index.vue` | 报销统计页 |
| `front/src/api/finance/reimbursement.js` | 报销API |
| `front/src/api/finance/planAudit.js` | 方案审核API |

### SQL文件（新建）
| 文件路径 | 说明 |
|----------|------|
| `sql/finance_module.sql` | 财务模块数据库脚本 |
