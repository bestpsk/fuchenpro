# 修复：用户管理删除用户提示"访问资源不存在"

## 问题分析

### 现象
- 报销管理删除正常 ✅
- 用户管理等其他模块删除提示"访问资源不存在" ❌

### 根本原因：Webman 进程未重启，旧路由仍在内存中

Webman 是常驻内存框架，路由配置在启动时加载并缓存。之前重构将路由从路径参数改为查询参数：

```php
// 旧路由（仍在内存中）
Route::delete('/system/user/{userIds}', [..., 'remove']);

// 新路由（在 route.php 文件中，但未加载到内存）
Route::delete('/system/user', [..., 'remove']);
```

**为什么报销管理正常？** 因为报销管理（finance/reimbursement）是新写的模块，路由从一开始就是 `Route::delete('/finance/reimbursement', ...)` 没有路径参数，不存在旧路由缓存的问题。

**为什么其他模块不正常？** 因为其他模块的路由从 `{xxxIds}` 路径参数版本改为了无路径参数版本，但 Webman 进程没有重启，内存中仍然是旧路由。当前端发送 `DELETE /system/user?userId=123` 时，旧路由期望路径是 `/system/user/123`，匹配失败 → 404。

**为什么 Windows 上不会自动重载？** 查看 `config/process.php` 第57行：
```php
'enable_file_monitor' => !in_array('-d', $argv) && DIRECTORY_SEPARATOR === '/',
```
`DIRECTORY_SEPARATOR === '/'` 在 Windows 上是 `false`，所以文件监控在 Windows 上是**禁用**的，修改路由文件后不会自动重载。

### 错误链路

1. 前端发送 `DELETE /dev-api/system/user?userId=123`
2. Vite 代理重写为 `DELETE /system/user?userId=123`
3. Webman 路由匹配：旧路由期望 `DELETE /system/user/{userIds}`，路径 `/system/user` 不匹配
4. FastRoute 返回 `NOT_FOUND`
5. 兜底路由 `Route::any('/{path:.+}', ...)` 匹配，返回 `{'code': 404, 'msg': '接口不存在'}`
6. 前端响应拦截器：`code === 404` → `errorCode['404']` → "访问资源不存在"

## 修复方案

### 步骤1：重启 Webman 进程

关闭当前运行的 Webman 进程，然后重新启动：

```bash
# 在 webman 目录下
# 先关闭旧进程（Ctrl+C 关闭运行 windows.php 的终端，或 taskkill）
taskkill /F /IM php.exe

# 重新启动
php windows.php
```

### 步骤2：验证修复

重启后，在前端用户管理页面尝试删除用户，确认不再提示"访问资源不存在"。

### 注意事项

- 以后修改 `config/route.php` 后，**必须重启 Webman 进程**才能生效
- Windows 上文件监控是禁用的，不会自动重载路由配置
- 可以考虑在开发环境中启用文件监控，修改 `config/process.php` 中的 `enable_file_monitor` 配置
