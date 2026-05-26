# 统一命名转换规范计划

## 现状分析

### 当前转换机制

| 层级 | 机制 | 状态 |
|------|------|------|
| **请求入参**（驼峰→蛇形） | `convert_to_snake_case($request->all())` | ✅ 各控制器已使用 |
| **列表响应**（蛇形→驼峰） | `TableDataInfo::result()` 内置 `convertToCamelCase()` | ✅ 自动转换 |
| **详情/操作响应**（蛇形→驼峰） | `AjaxResult::success()` 内置 `convertToCamelCase()` | ✅ 自动转换 |

### 问题根源：FinReimbursementController 与其他控制器不一致

**其他控制器的标准模式**（如 BizStoreController、BizCustomerController、SysPostController 等 20+ 个控制器）：
```php
// ✅ 标准模式：直接传模型对象给 AjaxResult::success()
public function getInfo(Request $request)
{
    $parts = explode('/', $request->path());
    $id = intval(end($parts));
    $service = new XxxService();
    $model = $service->selectById($id);
    if (!$model) return AjaxResult::error('不存在');
    return AjaxResult::success($model);  // ← 传模型对象，AjaxResult 自动 toArray() + 转驼峰
}
```

**FinReimbursementController 的非标准模式**：
```php
// ❌ 非标准：手动 toArray() 后传数组
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if ($result) {
        $data = $result->toArray();  // ← 手动转数组
        return AjaxResult::success('', $data);  // ← 传数组，AjaxResult 判断为关联数组后 merge 到顶层
    }
    return AjaxResult::error('数据不存在');
}
```

### AjaxResult::success() 的关键逻辑

```php
public static function success($msg = '操作成功', $data = null)
{
    if (is_array($msg) || is_object($msg)) {
        $data = $msg;       // ← 传模型对象时，$msg 被当作 $data
        $msg = '操作成功';
    }

    if ($data !== null) {
        if (is_array($data)) {
            $data = self::convertToCamelCase($data);
            if (self::isAssociative($data)) {
                $result = array_merge($result, $data);  // ← 关联数组：merge 到顶层！
            } else {
                $result['data'] = $data;
            }
        } elseif (is_object($data)) {
            $result['data'] = self::convertToCamelCase($data->toArray());  // ← 对象：放 data 下
        }
    }
}
```

**问题**：
1. 传**模型对象**：`AjaxResult::success($model)` → `{ code: 200, msg: '操作成功', data: { reimbursementId: 1, ... } }` ✅
2. 传**关联数组**：`AjaxResult::success('', $array)` → `{ code: 200, msg: '操作成功', reimbursementId: 1, ... }` ❌ 字段被 merge 到顶层！
3. 前端期望：`response.data.expenseAmount`，但实际变成了 `response.expenseAmount`

### 还有一个问题：info 方法获取 ID 的方式不一致

**其他控制器**（标准模式）：
```php
public function getInfo(Request $request)
{
    $parts = explode('/', $request->path());
    $id = intval(end($parts));
    // ...
}
```

**FinReimbursementController**（非标准）：
```php
public function info(Request $request, $id)  // ← 从路由参数直接获取
{
    // ...
}
```

路由配置：
```php
Route::get('/finance/reimbursement/{id}', [FinReimbursementController::class, 'info']);
```

这种方式本身没问题，但需要确认 `$id` 是否正确传入。

### add/edit 方法也缺少参数转换

**其他控制器**（标准模式）：
```php
public function add(Request $request)
{
    $data = convert_to_snake_case($request->post());  // ← 驼峰转蛇形
    // ...
}
```

**FinReimbursementController**（非标准）：
```php
public function add(Request $request)
{
    $data = $request->post();  // ← 缺少 convert_to_snake_case()
    // ...
}

public function edit(Request $request)
{
    $data = $request->post();  // ← 缺少 convert_to_snake_case()
    // ...
}
```

## 修复方案

### 统一规范（参考 ruoyi-vue3 和现有控制器模式）

**入参转换**：控制器中使用 `convert_to_snake_case()` 转换前端驼峰参数
**出参转换**：直接传模型对象给 `AjaxResult::success()`，由其自动 `toArray()` + `convertToCamelCase()`

### 步骤1：修复 FinReimbursementController 的 info 方法

**修改前**：
```php
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if ($result) {
        $data = $result->toArray();
        return AjaxResult::success('', $data);
    }
    return AjaxResult::error('数据不存在');
}
```

**修改后**（与其他控制器统一）：
```php
public function info(Request $request, $id)
{
    $result = $this->service->selectReimbursementById($id);
    if (!$result) return AjaxResult::error('数据不存在');
    return AjaxResult::success($result);
}
```

**关键变化**：
- 移除手动 `toArray()`
- 直接传模型对象给 `AjaxResult::success($result)`
- AjaxResult 会自动：`$result->toArray()` → `convertToCamelCase()` → 放入 `data` 字段
- 前端 `response.data.expenseAmount` 就能正确获取到值

### 步骤2：修复 add 方法 - 添加参数转换

**修改前**：
```php
public function add(Request $request)
{
    $data = $request->post();
    // ...
}
```

**修改后**：
```php
public function add(Request $request)
{
    $data = convert_to_snake_case($request->post());
    // ...
}
```

### 步骤3：修复 edit 方法 - 添加参数转换

**修改前**：
```php
public function edit(Request $request)
{
    $data = $request->post();
    // ...
}
```

**修改后**：
```php
public function edit(Request $request)
{
    $data = convert_to_snake_case($request->post());
    // ...
}
```

### 步骤4：修复 audit/pay/remove 方法 - 添加参数转换

```php
public function audit(Request $request)
{
    $data = convert_to_snake_case($request->post());
    // ...
}

public function pay(Request $request)
{
    $data = convert_to_snake_case($request->post());
    // ...
}
```

### 步骤5：修复 report 方法 - 添加参数转换

```php
public function reportByMonth(Request $request)
{
    $params = convert_to_snake_case($request->get());
    // ...
}
// 同理其他 report 方法
```

### 步骤6：移除调试日志

移除之前添加的临时调试代码：
```php
\support\Log::info('报销列表原始数据', [...]);
\support\Log::info('报销详情数据', [...]);
```

### 步骤7：修复前端 handleView/handleUpdate 中的数据访问路径

由于修复后 AjaxResult 返回 `{ code: 200, msg: '', data: {...} }`，前端 `response.data` 可以正确获取数据，无需修改前端代码。

但需要移除之前添加的临时调试 console.log：
```javascript
// 移除这些
console.log('列表数据响应:', response)
console.log('第一条数据:', response.rows[0])
console.log('编辑数据响应:', response)
console.log('data.expenseAmount:', data.expenseAmount)
```

### 步骤8：修复模型 $casts 配置

当前 `$casts` 使用蛇形键名，与模型 `$snakeAttributes = true` 配合时应该没有问题，因为 Eloquent 会自动处理。但为了一致性，保持当前配置不变。

## 执行顺序

1. 修复 FinReimbursementController（核心）
2. 移除调试日志
3. 移除前端调试 console.log
4. PHP 语法检查
5. 测试验证

## 预期效果

修复后：
- ✅ 列表：申请日期、支出金额正确显示（TableDataInfo 自动转驼峰）
- ✅ 查看：弹窗正常打开，`response.data` 正确包含所有字段
- ✅ 编辑：数据正确回显，`response.data.expenseAmount` 有值
- ✅ 新增/编辑：前端驼峰参数正确转换为蛇形存入数据库
- ✅ 与其他 20+ 个控制器保持一致的编码规范

## 风险评估

- **极低风险**：修改方式与其他已正常运行的控制器完全一致
- **不影响现有功能**：AjaxResult 的自动转换机制已在所有其他模块验证通过
- **易于回滚**：改动量小，仅涉及一个控制器文件
