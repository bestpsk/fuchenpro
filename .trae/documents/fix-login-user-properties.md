# 修复 LoginUser 属性访问错误计划

## 问题根因分析

### 错误信息
```
Undefined property: app\common\LoginUser::$userName
```

### 根本原因
**FinReimbursementController** 中错误地使用了不存在的属性：

```php
// 错误代码（第44、47行）
$data['applicant_name'] = $loginUser->userName;      // ❌ 不存在
$data['create_by'] = $loginUser->userName;           // ❌ 不存在

// 错误代码（第46行）
$data['dept_name'] = $loginUser->deptName;          // ❌ 不存在
```

**LoginUser 类实际属性**：
```php
class LoginUser {
    public $userId;         // ✅ 存在
    public $deptId;         // ✅ 存在
    public $token;
    // ...
    public $permissions = [];
    public $user = null;    // ✅ SysUser模型实例，包含 user_name, real_name 等
}
```

### 正确的访问方式
通过 `$loginUser->user`（SysUser模型）获取用户信息：
- 登录账号：`$loginUser->user->user_name`
- 真实姓名：`$loginUser->user->real_name`
- 部门ID：`$loginUser->user->dept_id`
- 部门名称：需要查询 `SysDept` 模型

---

## 修复步骤

### 步骤1：修改 FinReimbursementController
文件：`app/controller/finance/FinReimbursementController.php`

修改 `add()` 方法：
```php
// 修复前
$data['applicant_name'] = $loginUser->userName;
$data['dept_name'] = $loginUser->deptName ?? null;
$data['create_by'] = $loginUser->userName;

// 修复后
$user = $loginUser->user;
$data['applicant_name'] = $user->real_name ?: $user->user_name;  // 优先用真实姓名
$data['dept_id'] = $user->dept_id ?? null;

// 获取部门名称
$dept = \app\model\SysDept::find($user->dept_id);
$data['dept_name'] = $dept ? $dept->dept_name : '';

$data['create_by'] = $data['applicant_name'];
```

修改 `edit()` 和其他使用 `$loginUser->userName` 的方法：
```php
// 修复前
$data['update_by'] = $loginUser->userName;

// 修复后
$user = $loginUser->user;
$data['update_by'] = $user->real_name ?: $user->user_name;
```

修改 `audit()` 和 `pay()` 方法中的审核人/支付人字段。

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `app/controller/finance/FinReimbursementController.php` | 所有 `$loginUser->userName` → 通过 `$loginUser->user` 获取 |
