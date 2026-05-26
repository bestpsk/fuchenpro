# 统一删除接口参数传递方式分析

## 现状调查

### 后端控制器接收方式分类

**方式A：从 URL 路径获取**（`explode('/', $request->path())`）
| 控制器 | 参数名 | 路由 |
|--------|--------|------|
| SysUserController | userIds | `/system/user/{userIds}` |
| SysMenuController | menuId | `/system/menu/{menuId}` |
| SysDeptController | deptId | `/system/dept/{deptId}` |
| HrUserSalaryController | salaryIds | 路径参数 |
| BizScheduleController | scheduleIds | 路径参数 |

**方式B：用 `$request->input()` 获取**（从 URL 查询参数获取）
| 控制器 | 参数名 | 路由 |
|--------|--------|------|
| SysRoleController | roleIds | `/system/role/{roleIds}` |
| SysPostController | postIds | `/system/post/{postIds}` |
| SysConfigController | configIds | `/system/config/{configIds}` |
| SysNoticeController | noticeIds | `/system/notice/{noticeIds}` |
| SysDictDataController | dictCodes | `/system/dict/data/{dictCodes}` |
| SysJobLogController | jobLogIds | `/monitor/jobLog/{jobLogIds}` |
| SysLogininforController | infoIds | `/monitor/logininfor/{infoIds}` |
| BizEnterpriseController | enterpriseIds | 路径参数 |
| BizProductController | productIds | 路径参数 |
| BizSupplierController | supplierIds | 路径参数 |
| BizStockInController | stockInIds | 路径参数 |
| BizStockOutController | stockOutIds | 路径参数 |
| BizStockCheckController | stockCheckIds | 路径参数 |

**方式C：`$request->input()` + 路径回退**（优先 input，回退到路径）
| 控制器 | 参数名 |
|--------|--------|
| BizCustomerController | customerIds |
| BizOperationRecordController | recordIds |
| BizSalesOrderController | orderIds |
| SysDictDataController | dictCodes |

**方式D（报销）：`$request->post()`**（❌ 错误方式，已修复为 input）

### 前端 API 调用方式分类

**方式1：ids 拼在 URL 路径中**（大多数）
```javascript
url: '/system/user/' + userIds, method: 'delete'
url: '/wms/product/' + productId, method: 'delete'
// 等等...
```

**方式2：ids 用 params 传参**（仅报销，刚修改的）
```javascript
url: '/finance/reimbursement', method: 'delete', params: { ids }
```

## 分析结论

### 当前系统存在3种不同的删除参数传递方式，确实比较混乱

但关键问题是：**其他删除功能是否正常工作？**

### 其他删除功能能正常工作的原因

虽然方式A（路径获取）和方式B（input获取）看起来不一致，但它们都能正常工作，因为：

1. **方式A**：前端 `DELETE /system/user/1,2,3` → 路由 `{userIds}` 匹配 → 控制器从路径解析
2. **方式B**：前端 `DELETE /system/role/1,2,3` → 路由 `{roleIds}` 匹配 → 但控制器用 `input()` 获取

**方式B为什么也能工作？** 因为 Webman 路由 `{roleIds}` 匹配后，参数会同时出现在：
- URL 路径中（可从 `path()` 解析）
- 查询参数中（可从 `input()` 获取）

所以 `$request->input('roleIds')` 在路由为 `{roleIds}` 时也能获取到值。

### 是否有必要统一？

**建议：暂不统一，原因如下**

1. **风险大**：涉及 20+ 个控制器和对应的前端 API 文件，改动面太广
2. **当前都能工作**：虽然方式不统一，但功能正常
3. **优先级低**：这是代码风格问题，不是功能问题
4. **容易引入新bug**：修改路由和前后端参数传递方式，可能影响现有功能

**如果将来要统一，推荐做法**：

统一为报销模块的方式（`params` + `$request->input()`），因为：
- 前端代码更简洁：`params: { ids }` 比 `url: '/xxx/' + ids` 更清晰
- 后端代码更简洁：`$request->input('ids')` 比 `explode('/', $request->path())` 更直观
- 符合 RESTful 规范：DELETE 请求参数用查询字符串传递

但这应该是独立的重构任务，不在当前报销模块修复范围内。
