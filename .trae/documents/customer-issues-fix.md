# 客户管理问题修复计划

## 问题清单

### 问题1：App端编辑顾客头像保存后，列表不显示头像
**根因**：App端 `detail.vue` 编辑保存时，先调用 `updateCustomer` 更新客户信息（不含avatar字段），再调用 `uploadAvatar` 上传头像。但 `updateCustomer` 的提交数据中没有 `avatar` 字段，且上传头像后返回的URL没有同步到列表数据中。列表从 `searchCustomer` API 获取数据，头像上传成功后需要刷新列表。

**修复方案**：
- App端 `detail.vue` 的 `submitForm` 中，上传头像成功后，需要确保返回的URL被正确保存
- App端 `sales/index.vue` 的客户列表，在 `goCustomerDetail` 返回后需要刷新列表数据
- 检查 `searchCustomer` 接口返回的数据是否包含 `avatar` 字段

### 问题2：App端编辑顾客页面tag图标显示英文字母
**根因**：`detail.vue` 第54行使用 `<u-icon name="tag">` ，但 uView Plus 中没有 `tag` 图标，只有 `tags` 和 `tags-fill`。无效图标名称会显示为英文字母。

**修复方案**：将 `name="tag"` 改为 `name="tags"`

### 问题3：Front端新增客户报错 Unknown column 'avatar'
**根因**：数据库 `biz_customer` 表还没有执行 `add_customer_avatar.sql` 添加 `avatar` 字段。前端 `addCustomer` 提交时包含了 `avatar` 字段（来自新增客户弹窗的头像预览URL `blob:http://...`），但数据库表中没有这个字段。

**修复方案**：
1. **执行SQL**：运行 `add_customer_avatar.sql` 为 `biz_customer` 表添加 `avatar` 字段
2. **修复前端**：`submitCustomerForm` 中提交数据前，应删除 `avatar` 字段中的 blob URL（blob URL不是有效的头像路径，头像应通过 `uploadCustomerAvatar` 接口单独上传）

### 问题4：Front端新增客户性别选项去掉"未知"
**当前**：`sales/index.vue` 第663-666行，性别选项有"男"、"女"、"未知"
**修复方案**：去掉"未知"选项，只保留"男"和"女"，默认值改为 `'0'`（男）

### 问题5：App端新增客户性别选项去掉"未知"
**当前**：`customer/detail.vue` 第104-108行，`genderOptions` 有"男"、"女"、"未知"
**修复方案**：去掉"未知"选项，只保留"男"和"女"，默认值改为 `'0'`

### 问题6：Front端缺少编辑客户功能
**当前**：`sales/index.vue` 只有新增客户弹窗，没有编辑客户功能
**修复方案**：
1. 在客户列表项上添加"编辑"按钮
2. 点击编辑时，复用新增客户弹窗，填充已有客户数据
3. 提交时判断是新增还是编辑，分别调用 `addCustomer` 或 `updateCustomer`
4. 编辑时头像显示当前头像，支持重新上传

## 实施步骤

### 步骤1：执行数据库SQL添加avatar字段
运行 `webman/sql/add_customer_avatar.sql`

### 步骤2：App端 - 修复tag图标
**文件**：`AppV3/src/pages/business/customer/detail.vue`
- 第54行：`name="tag"` → `name="tags"`

### 步骤3：App端 - 去掉性别"未知"选项
**文件**：`AppV3/src/pages/business/customer/detail.vue`
- `genderOptions` 去掉 `{ label: '未知', value: '2' }`
- `form.gender` 默认值改为 `'0'`

### 步骤4：App端 - 修复头像保存后列表不显示
**文件**：`AppV3/src/pages/business/customer/detail.vue`
- 确保上传头像成功后，返回的头像URL正确保存

**文件**：`AppV3/src/pages/business/sales/index.vue`
- 在 `onShow` 生命周期中刷新客户列表（从编辑页返回时自动刷新）

### 步骤5：Front端 - 修复新增客户avatar blob URL问题
**文件**：`front/src/views/business/sales/index.vue`
- `submitCustomerForm` 中，提交数据前删除 `avatar` 字段中的 blob URL
- 头像应仅通过 `uploadCustomerAvatar` 接口上传

### 步骤6：Front端 - 去掉性别"未知"选项
**文件**：`front/src/views/business/sales/index.vue`
- 第663-666行：去掉 `<el-radio value="2">未知</el-radio>`
- `customerForm` 默认 `gender` 改为 `'0'`

### 步骤7：Front端 - 添加编辑客户功能
**文件**：`front/src/views/business/sales/index.vue`
1. 在客户列表项中添加"编辑"按钮
2. 新增 `handleEditCustomer` 函数，加载客户详情填充到弹窗
3. 修改 `submitCustomerForm`，根据是否有 `customerId` 判断新增/编辑
4. 编辑时支持头像重新上传

## 文件变更清单

| 操作 | 文件路径 | 变更内容 |
|------|----------|----------|
| 执行SQL | `webman/sql/add_customer_avatar.sql` | 添加avatar字段到biz_customer表 |
| 修改 | `AppV3/src/pages/business/customer/detail.vue` | 修复tag图标 + 去掉性别"未知" |
| 修改 | `AppV3/src/pages/business/sales/index.vue` | 刷新客户列表显示头像 |
| 修改 | `front/src/views/business/sales/index.vue` | 修复avatar blob + 去掉性别"未知" + 添加编辑客户功能 |
