# 报销管理页面问题修复计划

## 问题根因分析

### 问题1：图片上传404错误
**现象**：`UploadAjaxError: fail to post /common/upload 404`

**根本原因**：
- 前端环境变量配置 `VITE_APP_BASE_API = '/dev-api'`
- el-upload 组件的 `action="/common/upload"` 使用相对路径
- 请求直接发送到 `/common/upload`，而不是 `/dev-api/common/upload`
- 开发服务器（8088端口）无法处理此路由，返回404

**解决方案**：
- 修改 el-upload 的 action 为完整API路径：`/dev-api/common/upload`

### 问题2：新增报销缺少申请人和部门显示
**现象**：新增报销表单中没有显示申请人（realname）和部门信息

**根本原因**：
- useStore 中已存储 `realName`（第22-23行、第73行）
- 但 **没有存储部门信息**（deptId、deptName）
- 后端 getInfo 接口返回的 user 数据中包含 `deptId` 字段
- 但前端没有存储和使用这些字段

**解决方案**：
1. 在 useStore 的 state 中添加 `deptId` 和 `deptName` 字段
2. 在 getInfo action 中存储部门信息
3. 在报销表单中显示申请人和部门（只读，从登录信息获取）

---

## 修复步骤

### 步骤1：修改前端 useStore 添加部门信息
文件：`front/src/store/modules/user.js`
- state 中添加 `deptId: ''` 和 `deptName: ''`
- getInfo action 中添加 `this.deptId = user.deptId` 和获取部门名称

### 步骤2：修改后端 getInfo 返回部门名称
文件：`app/controller/SysLoginController.php` 或 `app/service/SysUserService.php`
- 确认返回的 user 数据中包含 deptId 和 deptName

### 步骤3：修改报销管理页面
文件：`front/src/views/finance/reimbursement/index.vue`
- 修复上传 action 路径
- 添加申请人和部门显示字段（只读）

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `front/src/store/modules/user.js` | 添加 deptId、deptName 字段 |
| `front/src/views/finance/reimbursement/index.vue` | 修复上传路径、添加申请人和部门显示 |
