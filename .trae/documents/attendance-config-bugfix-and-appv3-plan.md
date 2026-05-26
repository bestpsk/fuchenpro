# 考勤配置 Bug 修复 & AppV3 考勤配置规划

## 一、Bug 根因分析

### 错误现象
```
Error: Array to string conversion
SQL: insert into `biz_attendance_config` (`config_name`, `rule_id`, `config_type`, `user_ids`, `dept_id`, ...) 
     values (测试部门, 1, 2, ?, 105, ...)
```

### 根因
当 `config_type=2`（部门级）时，前端 `form.userIds` 为空数组 `[]`，经 `convert_to_snake_case` 转为 `user_ids: []`。
后端 `insertConfig()` 中 `!empty($data['user_ids'])` 对空数组返回 `false`（PHP 中 `empty([])` 为 `true`），
导致 `implode` 转换被跳过，空数组 `[]` 直接传入 Eloquent `create()`，PDO 绑定参数时触发 "Array to string conversion"。

### 次要问题
- `dept_id` 字段为 `int(11)`，只能存储单个部门 ID，不支持多选
- 前端 `el-tree-select` 未设置 `multiple` 属性，只能选一个部门
- 后端 `getUserRule()` 只用 `where('dept_id', $user->dept_id)` 精确匹配，不支持多部门

---

## 二、修复方案：dept_id → dept_ids（参照 user_ids 模式）

### 步骤 1：数据库变更

**新建 SQL 迁移脚本** `webman/sql/alter_attendance_config_dept_ids.sql`：

```sql
-- 将 dept_id (int) 改为 dept_ids (varchar)，支持多部门逗号分隔
ALTER TABLE `biz_attendance_config` 
  CHANGE COLUMN `dept_id` `dept_ids` varchar(500) DEFAULT NULL COMMENT '部门ID列表（逗号分隔）';

-- 删除旧索引
ALTER TABLE `biz_attendance_config` DROP INDEX `idx_dept_id`;

-- 新索引（可选，FIND_IN_SET 无法用普通索引加速，保留以备精确查询）
ALTER TABLE `biz_attendance_config` ADD INDEX `idx_dept_ids` (`dept_ids`(100));
```

### 步骤 2：后端 Model 修改

**文件**：`webman/app/model/BizAttendanceConfig.php`

- `fillable` 中 `dept_id` → `dept_ids`
- 删除 `dept()` 关联方法（`belongsTo` 单条关联不再适用）
- 新增 `getDeptIdsArrayAttribute()` 访问器（逗号分隔 → 整数数组）
- 新增 `getDeptsAttribute()` 访问器（根据 dept_ids 获取部门模型集合）

```php
protected $fillable = [
    'config_name', 'rule_id', 'config_type', 'user_ids', 'dept_ids',
    'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
];

public function getDeptIdsArrayAttribute()
{
    if (empty($this->dept_ids)) return [];
    return array_map('intval', array_filter(explode(',', $this->dept_ids)));
}

public function getDeptsAttribute()
{
    $ids = $this->dept_ids_array;
    if (empty($ids)) return [];
    return SysDept::whereIn('dept_id', $ids)->get();
}
```

### 步骤 3：后端 Service 修改

**文件**：`webman/app/service/BizAttendanceConfigService.php`

**3.1 `insertConfig()` 方法**：
- 修复空数组 bug：对 `user_ids` 和 `dept_ids`，无论是否为空数组都做转换
- 空数组转为 `null` 或空字符串

```php
public function insertConfig($data)
{
    if (isset($data['user_ids']) && is_array($data['user_ids'])) {
        $data['user_ids'] = !empty($data['user_ids']) ? implode(',', $data['user_ids']) : null;
    }
    if (isset($data['dept_ids']) && is_array($data['dept_ids'])) {
        $data['dept_ids'] = !empty($data['dept_ids']) ? implode(',', $data['dept_ids']) : null;
    }
    $data['create_time'] = date('Y-m-d H:i:s');
    return BizAttendanceConfig::create($data);
}
```

**3.2 `updateConfig()` 方法**：
- 同样处理 `dept_ids` 数组转逗号字符串
- fillable 白名单中 `dept_id` → `dept_ids`

```php
public function updateConfig($data)
{
    if (isset($data['user_ids']) && is_array($data['user_ids'])) {
        $data['user_ids'] = !empty($data['user_ids']) ? implode(',', $data['user_ids']) : null;
    }
    if (isset($data['dept_ids']) && is_array($data['dept_ids'])) {
        $data['dept_ids'] = !empty($data['dept_ids']) ? implode(',', $data['dept_ids']) : null;
    }
    $data['update_time'] = date('Y-m-d H:i:s');
    $fillable = [
        'config_name', 'rule_id', 'config_type', 'user_ids', 'dept_ids',
        'status', 'remark', 'create_by', 'create_time', 'update_by', 'update_time'
    ];
    $updateData = array_intersect_key($data, array_flip($fillable));
    return BizAttendanceConfig::where('config_id', $data['config_id'])->update($updateData);
}
```

**3.3 `selectConfigList()` 方法**：
- `with(['rule', 'dept'])` → `with(['rule'])`（移除单条 dept 关联，列表中通过访问器获取多部门名称）

**3.4 `getUserRule()` 方法**：
- 部门匹配逻辑从 `where('dept_id', $user->dept_id)` 改为 `whereRaw("FIND_IN_SET(?, dept_ids)", [$user->dept_id])`

```php
public function getUserRule($userId)
{
    // 1. 用户级配置
    $userConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, user_ids)", [$userId])
        ->where('config_type', 1)->where('status', '0')->first();
    if ($userConfig) return BizAttendanceRule::find($userConfig->rule_id);

    // 2. 部门级配置（支持多部门）
    $user = SysUser::find($userId);
    if ($user && $user->dept_id) {
        $deptConfig = BizAttendanceConfig::whereRaw("FIND_IN_SET(?, dept_ids)", [$user->dept_id])
            ->where('config_type', 2)->where('status', '0')->first();
        if ($deptConfig) return BizAttendanceRule::find($deptConfig->rule_id);
    }

    // 3. 默认规则
    return (new BizAttendanceRuleService())->getActiveRule();
}
```

### 步骤 4：前端 config.vue 修改

**文件**：`front/src/views/business/attendance/config.vue`

**4.1 部门选择器改为多选**：
```html
<!-- 旧 -->
<el-tree-select v-model="form.deptId" :data="deptOptions" :props="{...}" check-strictly />

<!-- 新 -->
<el-tree-select v-model="form.deptIds" :data="deptOptions" :props="{...}" multiple 
  :render-after-expand="false" show-checkbox check-strictly 
  collapse-tags collapse-tags-tooltip />
```

**4.2 表单数据模型**：
- `reset()` 中 `deptId: undefined` → `deptIds: []`
- `handleConfigTypeChange()` 中 `form.value.deptId = undefined` → `form.value.deptIds = []`

**4.3 编辑回填**：
```javascript
// handleUpdate 中增加 dept_ids 数组转换
if (form.value.deptIds && typeof form.value.deptIds === 'string') {
    form.value.deptIds = form.value.deptIds.split(',').map(id => parseInt(id))
}
```

**4.4 列表展示**：
- 关联部门列：从 `scope.row.dept?.deptName` 改为显示多个部门名称
```html
<template #default="scope">
  <template v-if="scope.row.configType === 2">
    {{ getDeptNames(scope.row.deptIds) }}
  </template>
  <span v-else>-</span>
</template>
```

新增 `getDeptNames()` 方法：
```javascript
function getDeptNames(deptIds) {
    if (!deptIds) return '-'
    const ids = deptIds.split(',').map(id => parseInt(id))
    const names = ids.map(id => {
        const dept = findDeptById(deptOptions.value, id)
        return dept ? dept.label : id
    })
    return names.join(', ')
}
```

---

## 三、AppV3 考勤配置页面规划

### 当前状态
- AppV3 菜单中已有「考勤配置」入口（id: 53），但 `path` 为空，页面未实现
- AppV3 已有考勤 API 层 `attendance.js`，但只有 `getUserAttendanceRule()` 一个配置相关接口
- AppV3 目前只有「考勤打卡」和「考勤记录」两个页面

### 规划方案

#### 3.1 新增页面：`pages/attendance/config.vue`

**功能**：考勤配置列表 + 新增/编辑（移动端适配版）

**页面结构**：
1. **顶部筛选**：配置类型 Tab（全部/用户级/部门级）
2. **配置列表**：卡片式布局，每张卡片显示：
   - 配置名称 + 状态标签
   - 配置类型标签（用户级/部门级）
   - 考勤规则名称
   - 关联用户/部门（折叠展示）
   - 操作按钮（编辑/删除）
3. **新增/编辑弹窗**（底部弹出 sheet）：
   - 配置名称输入
   - 配置类型选择（用户级/部门级）
   - 考勤规则下拉选择
   - 关联用户多选（用户级时显示）
   - 关联部门多选（部门级时显示，树形选择）
   - 状态开关
   - 备注输入

#### 3.2 API 层扩展

**文件**：`AppV3/src/api/attendance.js`

新增接口：
```javascript
export function listAttendanceConfig(params) {
    return request({ url: '/business/attendance/config/list', method: 'get', params })
}
export function getAttendanceConfig(configId) {
    return request({ url: '/business/attendance/config/' + configId, method: 'get' })
}
export function addAttendanceConfig(data) {
    return request({ url: '/business/attendance/config', method: 'post', data })
}
export function updateAttendanceConfig(data) {
    return request({ url: '/business/attendance/config', method: 'put', data })
}
export function delAttendanceConfig(configIds) {
    return request({ url: '/business/attendance/config', method: 'delete', params: { configIds } })
}
```

复用已有的部门树和用户列表接口（需确认 AppV3 是否已有，如没有则新增）：
```javascript
// 部门树
export function getDeptTree() {
    return request({ url: '/system/dept/treeselect', method: 'get' })
}
// 用户列表
export function listUser(params) {
    return request({ url: '/system/user/list', method: 'get', params })
}
// 考勤规则列表
export function listAttendanceRule(params) {
    return request({ url: '/business/attendance/rule/list', method: 'get', params })
}
```

#### 3.3 路由注册

**文件**：`AppV3/src/pages.json`

```json
{ "path": "pages/attendance/config", "style": { "navigationBarTitleText": "考勤配置" } }
```

#### 3.4 菜单配置更新

**文件**：`AppV3/src/store/modules/menu.js`

考勤配置菜单项 path 更新：
```javascript
{ id: 53, title: '考勤配置', icon: 'grid', path: '/pages/attendance/config', ... }
```

---

## 四、实施步骤总览

| 序号 | 任务 | 涉及文件 |
|------|------|----------|
| 1 | 创建数据库迁移 SQL | `webman/sql/alter_attendance_config_dept_ids.sql` |
| 2 | 执行 SQL 迁移 | 数据库 |
| 3 | 修改后端 Model | `webman/app/model/BizAttendanceConfig.php` |
| 4 | 修改后端 Service | `webman/app/service/BizAttendanceConfigService.php` |
| 5 | 修改前端配置页面 | `front/src/views/business/attendance/config.vue` |
| 6 | 验证 front 端考勤配置多部门功能 | 浏览器 |
| 7 | AppV3 新增考勤配置 API | `AppV3/src/api/attendance.js` |
| 8 | AppV3 新增考勤配置页面 | `AppV3/src/pages/attendance/config.vue` |
| 9 | AppV3 注册路由 | `AppV3/src/pages.json` |
| 10 | AppV3 更新菜单配置 | `AppV3/src/store/modules/menu.js` |
| 11 | 端到端验证 | 全链路 |
