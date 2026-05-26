# 修复报销单删除功能

## 问题现象
选中报销订单 → 点击删除 → 提示删除成功 → 但数据列表依然存在

## 根本原因

前端发送 `DELETE /finance/reimbursement/1`（ids 在 URL 路径中），后端用 `$request->post('ids', [])` 接收（从 POST body 中取），永远拿到空数组。

## 修复方案

参考 `f:\fuchen\参考.txt`，DELETE 请求前端用 `params` 传参（拼接在 URL 后），后端用 `$request->input()` 接收。

### 步骤1：修改前端 API 调用方式

**文件**：`front/src/api/finance/reimbursement.js` 第34-39行

**修改前**：
```javascript
export function delReimbursement(ids) {
  return request({
    url: '/finance/reimbursement/' + ids,   // ids 在路径中
    method: 'delete'
  })
}
```

**修改后**：
```javascript
export function delReimbursement(ids) {
  return request({
    url: '/finance/reimbursement',
    method: 'delete',
    params: { ids }                          // ids 用 params 传参
  })
}
```

前端发送的请求变为：`DELETE /finance/reimbursement?ids=1` 或 `DELETE /finance/reimbursement?ids[]=1&ids[]=2`

### 步骤2：修改后端路由

**文件**：`webman/config/route.php` 第345行

**修改前**：
```php
Route::delete('/finance/reimbursement/{ids}', [FinReimbursementController::class, 'remove']);
```

**修改后**：
```php
Route::delete('/finance/reimbursement', [FinReimbursementController::class, 'remove']);
```

### 步骤3：修改后端控制器，用 $request->input() 接收

**文件**：`webman/app/controller/finance/FinReimbursementController.php` 第91-103行

**修改前**：
```php
public function remove(Request $request)
{
    $ids = $request->post('ids', []);  // ❌ DELETE 请求没有 POST body
    if (!is_array($ids)) {
        $ids = explode(',', $ids);
    }
    // ...
}
```

**修改后**：
```php
public function remove(Request $request)
{
    $ids = $request->input('ids', []);  // ✅ 用 input() 接收 URL 参数
    if (!is_array($ids)) {
        $ids = explode(',', $ids);
    }
    $ids = array_map('intval', $ids);

    $result = $this->service->deleteReimbursementByIds($ids);
    if ($result === false) {
        return AjaxResult::error('删除失败，只有待审核状态才能删除');
    }
    return AjaxResult::success('删除成功');
}
```

## 执行步骤

1. 修改前端 API 调用方式（params 传参）
2. 修改后端路由（移除 {ids}）
3. 修改后端控制器（用 $request->input() 接收）
4. PHP 语法检查
