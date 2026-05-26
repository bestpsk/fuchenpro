# 报销管理模块全面排查与修复计划（修订版）

## 问题汇总

| 问题 | 严重程度 | 现象 |
|------|---------|------|
| 操作列宽度太窄 | 高 | 按钮变成3排，布局混乱 |
| 状态重复显示 | 高 | 状态列显示2个相同的tag |
| 申请日期不显示 | 高 | 列表和详情中申请日期为空 |
| 支出金额不显示 | 高 | 列表和详情中支出金额显示¥0.00 |
| 点击编辑报错 | **严重** | `TypeError: Cannot read properties of undefined (reading 'expenseAmount')` |
| 点击查看失败 | **严重** | 提示"获取报销详情失败" |

## 系统已有的自动转换机制

### 后端自动转换（已确认）

1. **TableDataInfo 类**（`app/common/TableDataInfo.php`）
   - `result()` 方法自动调用 `convertToCamelCase()`
   - 将蛇形字段转换为驼峰返回前端

2. **AjaxResult 类**（`app/common/AjaxResult.php`）
   - `success()` 方法自动调用 `convertToCamelCase()`
   - 将蛇形字段转换为驼峰返回前端

3. **convert_to_snake_case() 函数**（`app/functions.php`）
   - 将前端驼峰参数转换为蛇形

### 当前报销控制器代码分析

```php
// list 方法 - 第42-47行
public function list(Request $request)
{
    $params = $request->all();  // ⚠️ 缺少 convert_to_snake_case()
    $result = $this->service->selectReimbursementList($params);
    return TableDataInfo::result($result->items(), $result->total());  // ✅ 会自动转换
}

// info 方法 - 第50-58行
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if ($result) {
        $data = $result->toArray();  // ✅ toArray() 后会被 AjaxResult 自动转换
        return AjaxResult::success('', $data);
    }
    return AjaxResult::error('数据不存在');
}
```

**结论**：后端转换机制正常，应该能返回驼峰字段。

## 根本原因排查

### 可能原因1：模型 $casts 配置干扰

**当前配置**：
```php
protected $casts = [
    'apply_date' => 'date:Y-m-d',      // 使用蛇形键名
    'expense_amount' => 'decimal:2',   // 使用蛇形键名
    'income_amount' => 'decimal:2',
];
```

**问题**：`$casts` 使用蛇形键名，可能导致 `toArray()` 返回时保留了蛇形格式。

### 可能原因2：前端字典数据问题

**状态列代码**：
```vue
<dict-tag v-if="fin_reimbursement_status?.length" :options="fin_reimbursement_status" :value="scope.row.status" />
```

如果字典数据配置有问题，可能导致重复渲染。

### 可能原因3：前端数据接收问题

**getList 函数**：
```javascript
reimbursementList.value = response.rows  // 直接赋值，未做任何处理
```

如果后端返回的数据格式不符合预期，前端没有容错处理。

## 修复方案

### 步骤1：添加调试日志（临时）

**文件**：`webman/app/controller/finance/FinReimbursementController.php`

**修改 list 方法**：
```php
public function list(Request $request)
{
    $params = $request->all();
    $result = $this->service->selectReimbursementList($params);

    // 临时调试：查看原始数据格式
    \support\Log::info('报销列表原始数据', [
        'first_item' => $result->items()[0] ?? null,
        'first_item_array' => ($result->items()[0] ?? null)?->toArray()
    ]);

    return TableDataInfo::result($result->items(), $result->total());
}
```

**修改 info 方法**：
```php
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if ($result) {
        $data = $result->toArray();

        // 临时调试：查看转换前后的数据
        \support\Log::info('报销详情数据', [
            'original' => $result,
            'toArray' => $data
        ]);

        return AjaxResult::success('', $data);
    }
    return AjaxResult::error('数据不存在');
}
```

### 步骤2：修复前端操作列宽度

**文件**：`front/src/views/finance/reimbursement/index.vue` 第64行

```vue
<!-- 修改前 -->
<el-table-column label="操作" align="center" min-width="200" fixed="right">

<!-- 修改后：增加宽度，确保按钮单行显示 -->
<el-table-column label="操作" align="center" width="280" fixed="right">
```

### 步骤3：修复状态显示组件

**文件**：`front/src/views/finance/reimbursement/index.vue` 第58-63行

**方案A：简化 dict-tag 使用**
```vue
<el-table-column label="状态" align="center" prop="status" min-width="100">
  <template #default="scope">
    <dict-tag :options="fin_reimbursement_status" :value="scope.row.status" />
  </template>
</el-table-column>
```

**方案B：改用 el-tag（推荐）**
```vue
<el-table-column label="状态" align="center" prop="status" min-width="100">
  <template #default="scope">
    <el-tag :type="getStatusType(scope.row.status)">
      {{ getStatusLabel(scope.row.status) }}
    </el-tag>
  </template>
</el-table-column>
```

**添加辅助函数**（在 script 中）：
```javascript
function getStatusType(status) {
  const types = {
    '0': 'info',      // 待审核
    '1': 'success',   // 已审核
    '2': 'danger',    // 已拒绝
    '3': 'warning'    // 已支付
  }
  return types[status] || 'info'
}

function getStatusLabel(status) {
  const labels = {
    '0': '待审核',
    '1': '已审核',
    '2': '已拒绝',
    '3': '已支付'
  }
  return labels[status] || status
}
```

### 步骤4：修复前端编辑函数

**文件**：`front/src/views/finance/reimbursement/index.vue` 第311-330行

```javascript
function handleUpdate(row) {
  reset()
  getReimbursement(row.reimbursementId).then(response => {
    console.log('编辑数据响应:', response)  // 临时调试

    if (response && response.data) {
      const data = response.data
      console.log('data.expenseAmount:', data.expenseAmount)  // 临时调试

      form.value = {
        ...data,
        expenseAmount: parseFloat(data.expenseAmount || 0),
        incomeAmount: parseFloat(data.incomeAmount || 0),
        applyDate: data.applyDate || ''
      }

      const images = parseImages(data.voucherImages)
      fileList.value = images.map((url, idx) => ({
        name: 'img' + idx,
        url: url,
        response: { data: { url: url } }
      }))

      open.value = true
      title.value = '编辑报销'
    } else {
      proxy.$modal.msgError('获取报销详情失败')
    }
  }).catch(error => {
    console.error('获取报销详情失败:', error)
    proxy.$modal.msgError('获取报销详情失败')
  })
}
```

### 步骤5：修复前端列表数据接收

**文件**：`front/src/views/finance/reimbursement/index.vue` 第281-288行

```javascript
function getList() {
  loading.value = true
  listReimbursement(queryParams.value).then(response => {
    console.log('列表数据响应:', response)  // 临时调试
    console.log('第一条数据:', response.rows[0])  // 临时调试

    reimbursementList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(error => {
    console.error('获取列表失败:', error)
    loading.value = false
  })
}
```

### 步骤6：修复后端参数转换（可选）

**文件**：`webman/app/controller/finance/FinReimbursementController.php` 第44行

```php
// 修改前
$params = $request->all();

// 修改后（参考其他控制器）
$params = convert_to_snake_case($request->all());
```

## 执行顺序

### 阶段1：添加调试（了解真实情况）
1. 后端添加调试日志
2. 前端添加 console.log
3. 刷新页面，查看浏览器控制台和后端日志
4. 根据实际数据格式确定问题根源

### 阶段2：修复前端显示问题
5. 修复操作列宽度（200→280）
6. 修复状态显示组件（改用 el-tag）
7. 修复编辑函数错误处理
8. 修复列表数据接收容错

### 阶段3：根据调试结果修复后端
9. 如果发现数据格式问题，修复模型或控制器
10. 如果参数转换问题，添加 convert_to_snake_case()

### 阶段4：清理调试代码
11. 移除临时调试日志
12. 移除临时 console.log

## 预期效果

修复后：
- ✅ 列表：申请日期、支出金额正确显示
- ✅ 列表：状态显示单个 el-tag
- ✅ 列表：操作按钮单行显示
- ✅ 查看：弹窗正常打开，所有字段正确显示
- ✅ 编辑：数据正确回显，图片正常显示
- ✅ 控制台：能看到实际的数据格式，便于定位问题

## 调试重点

**需要确认的关键问题**：
1. 后端返回的数据是驼峰还是蛇形？
2. 前端接收到的数据格式是什么？
3. expenseAmount 字段是否存在？值是什么？
4. status 字段的值和类型是什么？

**调试方法**：
1. 浏览器控制台查看 Network 请求的 Response
2. 浏览器控制台查看 console.log 输出
3. 后端日志文件查看 Log::info 输出
