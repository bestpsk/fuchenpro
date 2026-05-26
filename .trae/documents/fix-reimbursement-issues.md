# 报销单模块问题修复计划

## 问题分析

根据用户提供的4张截图，发现以下问题：

### 图2 - 列表页面问题
| 问题描述 | 严重程度 | 根本原因分析 |
|---------|---------|------------|
| 数据列宽度未占满100% | 中 | 表格列宽固定，未使用自适应布局 |
| 申请日期不显示 | 高 | 字段映射或数据返回问题 |
| 支出金额显示¥0.00（应为399.00） | **高** | 字段映射错误：前端用`expenseAmount`，后端可能返回`expense_amount` |
| 状态出现两个"待审核"tag | **高** | status字段值异常或渲染逻辑重复 |
| 操作列跳行 | 中 | 列宽度不够导致换行 |

### 图3 - 查看详情问题
| 问题描述 | 严重程度 | 根本原因分析 |
|---------|---------|------------|
| 凭证图片不显示 | **高** | 图片URL解析失败或COS访问权限问题 |
| 申请日期不显示 | 高 | 同列表页问题 |
| 支出金额/收入金额显示0.00 | **高** | 同列表页字段映射问题 |
| 状态显示两个"待审核"tag | **高** | 同列表页问题 |

### 图4 - 编辑报销单问题
| 问题描述 | 严重程度 | 根本原因分析 |
|---------|---------|------------|
| 支出金额/收入金额显示0.00 | **高** | 编辑时数据回显失败 |
| 凭证图片不显示 | **高** | 编辑时图片回显逻辑有问题 |

## 根本原因定位

### 问题1：字段名称映射不一致
**现象**：支出金额、收入金额、申请日期等字段在列表、详情、编辑页面都显示为空或0

**原因分析**：
- 前端使用驼峰命名：`expenseAmount`, `incomeAmount`, `applyDate`
- 后端数据库使用下划线命名：`expense_amount`, `income_amount`, `apply_date`
- Webman/Eloquent ORM默认支持自动转换，但需要在模型中配置`$casts`或确保JSON序列化正确

**验证方式**：
```javascript
// 前端代码 (index.vue)
scope.row.expenseAmount  // 期望获取 expense_amount 的值

// 后端返回的数据结构可能是：
{ expense_amount: 399.00 }  // 而非 { expenseAmount: 399.00 }
```

### 问题2：状态字段重复显示
**现象**：状态列显示两个"待审核"tag

**原因分析**：
- 可能是`dict-tag`组件接收到了数组类型的status值
- 或者后端返回了包含多个status的数据结构

**验证方向**：
- 检查数据库中status字段的实际值
- 检查后端返回数据的序列化格式

### 问题3：图片不显示
**现象**：新增时有图片，但详情和编辑时图片不显示

**原因分析**：
- 新增时图片上传成功，URL存储到`voucher_images`字段（JSON数组格式）
- 详情/编辑时解析`voucher_images`失败
- 或COS URL无法访问（跨域、签名过期等）

**当前代码逻辑**：
```javascript
// index.vue 第245-251行
function parseImages(jsonStr) {
  try {
    return JSON.parse(jsonStr || '[]')
  } catch {
    return []
  }
}
```

## 修复方案

### 步骤1：修复FinReimbursement模型 - 添加字段转换和序列化配置

**文件**：`f:\fuchen\webman\app\model\FinReimbursement.php`

**修改内容**：
```php
protected $casts = [
    'apply_date' => 'date:Y-m-d',
    'expense_amount' => 'decimal:2',
    'income_amount' => 'decimal:2',
    'audit_time' => 'datetime:Y-m-d H:i:s',
    'pay_time' => 'datetime:Y-m-d H:i:s',
    'create_time' => 'datetime:Y-m-d H:i:s',
    'update_time' => 'datetime:Y-m-d H:i:s',
];

// 添加蛇形转驼峰的属性访问器（如果框架未自动处理）
public function getExpenseAmountAttribute($value) {
    return (float) $value;
}

public function getIncomeAmountAttribute($value) {
    return (float) $value;
}

public function getApplyDateAttribute($value) {
    return $value ? substr($value, 0, 10) : null;
}
```

### 步骤2：修复控制器 - 确保返回数据格式正确

**文件**：`f:\fuchen\webman\app\controller\finance\FinReimbursementController.php`

**修改info方法**：
```php
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if ($result) {
        // 确保返回的是数组格式，且字段名转换为驼峰
        $data = $result->toArray();
        // 显式转换关键字段
        $data['expenseAmount'] = (float) ($data['expense_amount'] ?? 0);
        $data['incomeAmount'] = (float) ($data['income_amount'] ?? 0);
        $data['applyDate'] = $data['apply_date'] ?? '';
        return AjaxResult::success('', $data);
    }
    return AjaxResult::error('数据不存在');
}
```

### 步骤3：修复列表查询 - 添加字段别名

**文件**：`f:\fuchen\webman\app\service\FinReimbursementService.php`

**修改selectReimbursementList方法**：
```php
public function selectReimbursementList($params = [])
{
    $query = FinReimbursement::with(['applicant', 'dept'])
        ->select([
            '*',
            'expense_amount as expenseAmount',  // 添加别名
            'income_amount as incomeAmount',
            'apply_date as applyDate',
            'voucher_images as voucherImages'
        ]);
    
    // ... 其他查询条件保持不变
    
    return $query->orderBy('reimbursement_id', 'desc')
        ->paginate($pageSize, ['*'], 'page', $pageNum);
}
```

### 步骤4：修复前端表格 - 自适应列宽

**文件**：`f:\fuchen\front\src\views\finance\reimbursement\index.vue`

**修改el-table配置**：
```vue
<el-table 
  v-loading="loading" 
  :data="reimbursementList" 
  @selection-change="handleSelectionChange"
  style="width: 100%"
  table-layout="auto">  <!-- 添加自动布局 -->
  
  <!-- 移除固定width，使用min-width -->
  <el-table-column type="selection" width="55" align="center" />
  <el-table-column label="报销单号" align="center" prop="reimbursementNo" min-width="150" />
  <el-table-column label="申请人" align="center" prop="applicantName" min-width="100" />
  <!-- ... 其他列类似 ... -->
  <el-table-column label="操作" align="center" min-width="200" fixed="right">
```

### 步骤5：修复图片显示问题

**文件**：`f:\fuchen\front\src\views\finance\reimbursement\index.vue`

**修改handleUpdate方法和parseImages函数**：
```javascript
// 修改handleUpdate - 正确回显图片
function handleUpdate(row) {
  reset()
  getReimbursement(row.reimbursementId).then(response => {
    const data = response.data
    form.value = {
      ...data,
      expenseAmount: parseFloat(data.expenseAmount) || 0,
      incomeAmount: parseFloat(data.incomeAmount) || 0,
      applyDate: data.applyDate || ''
    }
    
    // 修复图片回显
    const images = parseImages(data.voucherImages)
    fileList.value = images.map((url, idx) => ({
      name: 'img' + idx,
      url: url,
      response: { data: { url: url } }  // 添加response结构以匹配上传组件格式
    }))
    
    open.value = true
    title.value = '编辑报销'
  })
}

// 增强parseImages的错误处理
function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) {
      return parsed.filter(url => url && typeof url === 'string')
    }
    return []
  } catch (e) {
    console.error('图片解析失败:', e, jsonStr)
    // 如果不是JSON格式，尝试作为单个URL处理
    if (typeof jsonStr === 'string' && jsonStr.startsWith('http')) {
      return [jsonStr]
    }
    return []
  }
}
```

### 步骤6：调试状态字段重复问题

**临时添加调试代码**：
```vue
<!-- 在列表的状态列临时添加原始值显示 -->
<el-table-column label="状态" align="center" prop="status" min-width="120">
  <template #default="scope">
    <div>
      <span style="color: #999; font-size: 12px">[{{ scope.row.status }}]</span>
      <br/>
      <dict-tag :options="fin_reimbursement_status" :value="scope.row.status" />
    </div>
  </template>
</el-table-column>
```

**检查点**：
1. 查看数据库中该记录的status字段值是否正常（应该是单个字符如'0'）
2. 检查是否有触发器或其他逻辑导致status被重复设置
3. 检查字典数据`fin_reimbursement_status`是否配置正确

## 执行顺序

1. **步骤1**：修复模型层（最根本）
2. **步骤2+3**：修复服务层和控制器层
3. **步骤4**：优化前端表格展示
4. **步骤5**：修复图片显示
5. **步骤6**：调试并解决状态重复问题

## 验证清单

完成后需验证以下功能：

- [ ] 新增报销单：所有字段正确保存
- [ ] 列表展示：金额、日期、状态正确显示，列宽自适应
- [ ] 查看详情：所有字段包括图片正确显示
- [ ] 编辑报销单：数据正确回显，图片可编辑
- [ ] 审核流程：状态正确变更
- [ ] 支付流程：状态最终变为"已支付"

## 风险评估

- **低风险**：主要是字段映射和显示问题，不影响核心业务逻辑
- **注意事项**：
  - 修改前备份数据库
  - 先在测试环境验证
  - 注意COS图片URL的有效性
