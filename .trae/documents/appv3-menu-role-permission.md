# AppV3工作台菜单权限统一方案

## 一、核心思路

**AppV3工作台直接从 `sys_menu` 读取菜单，与Web端完全同步**

不再使用 `app_menu_config` 独立配置，而是直接读取 `sys_menu` 中用户有权限的菜单，按Web端的一级分类（业务管理、考勤管理、进销存管理、财务管理、系统管理）分组显示。

## 二、Web端一级菜单结构（作为App分组）

| 一级菜单 | menu_id | icon | App端显示 |
|---------|---------|------|----------|
| 业务管理 | 2000 | peoples | ✅ 显示 |
| 考勤管理 | 2012 | time | ✅ 显示 |
| 进销存管理 | 2021 | shopping | ✅ 显示 |
| 财务管理 | 3000 | money | ✅ 显示 |
| 系统管理 | 1 | system | ✅ 显示 |

## 三、Web端二级菜单 → App端菜单映射

### 业务管理
| Web菜单 | perms | App显示 | App路径 |
|---------|-------|---------|---------|
| 企业管理 | business:enterprise:list | ✅ | /pages/business/enterprise/index |
| 门店管理 | business:store:list | ✅ | /pages/business/store/index |
| 行程安排 | business:schedule:list | ✅ | /pages/business/schedule/index |
| 销售开单 | business:sales:list | ✅ | /pages/business/sales/index |
| 订单管理 | business:order:list | ✅ | /pages/business/order/index |
| 方案管理 | business:plan:list | ❌ 暂无App页面 | - |

### 考勤管理
| Web菜单 | perms | App显示 | App路径 |
|---------|-------|---------|---------|
| 考勤记录 | business:attendance:record:list | ✅ | /pages/attendance/index |
| 考勤规则 | business:attendance:rule:list | ❌ 暂无App页面 | - |
| 考勤配置 | business:attendance:config:list | ❌ 暂无App页面 | - |

### 进销存管理
| Web菜单 | perms | App显示 | App路径 |
|---------|-------|---------|---------|
| 供货商管理 | wms:supplier:list | ❌ 暂无App页面 | - |
| 货品管理 | wms:product:list | ❌ 暂无App页面 | - |
| 入库管理 | wms:stockIn:list | ❌ 暂无App页面 | - |
| 出库管理 | wms:stockOut:list | ❌ 暂无App页面 | - |
| 库存查看 | wms:inventory:list | ❌ 暂无App页面 | - |
| 库存盘点 | wms:stockCheck:list | ❌ 暂无App页面 | - |
| 店企业出货 | wms:enterpriseShipment:list | ❌ 暂无App页面 | - |
| 进销存报表 | wms:report:list | ❌ 暂无App页面 | - |

### 财务管理
| Web菜单 | perms | App显示 | App路径 |
|---------|-------|---------|---------|
| 方案审核 | finance:planAudit:list | ❌ 暂无App页面 | - |
| 报销管理 | finance:reimbursement:list | ❌ 暂无App页面 | - |
| 报销统计 | finance:reimbursementReport:list | ❌ 暂无App页面 | - |

### 系统管理
| Web菜单 | perms | App显示 | App路径 |
|---------|-------|---------|---------|
| 用户管理 | system:user:list | ❌ 暂无App页面 | - |
| 角色管理 | system:role:list | ❌ 暂无App页面 | - |
| ... | ... | ❌ | - |

## 四、实现方案

### 方案选择：在 app_menu_config 中增加 perms 字段 + 后端权限过滤

**为什么不用"直接读取sys_menu"方案？**
- sys_menu 的 path 是Web端路由（如 `/business/sales`），App端路由不同（如 `/pages/business/sales/index`）
- sys_menu 的 icon 是Web端图标名，App端使用不同的图标体系
- app_menu_config 已经有完整的App端配置（图标、颜色、路径），只需加权限过滤

### 具体实现

#### 4.1 数据库修改

```sql
-- 1. app_menu_config 新增 perms 字段
ALTER TABLE app_menu_config ADD COLUMN perms varchar(100) DEFAULT '' COMMENT '权限标识（复用sys_menu的perms，为空表示不控制权限）' AFTER path;

-- 2. 新增分组：考勤管理、进销存管理、财务管理
-- 先插入新分组（group_sort: quick=1, business=2, attendance=3, wms=4, finance=5, system=6, mine_action=7, mine_menu=8）

-- 考勤管理分组
INSERT INTO app_menu_config (group_name, group_key, group_sort, title, icon, path, icon_color, bg_color, sort_order, visible, status, perms, create_by, create_time) VALUES
('考勤管理', 'attendance', 3, '打卡', 'clock', '/pages/attendance/index', '#fff', '#FF6B35', 1, 1, '0', 'business:attendance:record:list', 'admin', NOW());

-- 进销存管理分组（暂无App页面，先创建占位，visible=0）
INSERT INTO app_menu_config (group_name, group_key, group_sort, title, icon, path, icon_color, bg_color, sort_order, visible, status, perms, create_by, create_time) VALUES
('进销存管理', 'wms', 4, '供货商管理', 'account', '', '#fff', '#00B42A', 1, 0, '0', 'wms:supplier:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '货品管理', 'grid', '', '#fff', '#00B42A', 2, 0, '0', 'wms:product:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '入库管理', 'arrow-down', '', '#fff', '#00B42A', 3, 0, '0', 'wms:stockIn:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '出库管理', 'arrow-up', '', '#fff', '#00B42A', 4, 0, '0', 'wms:stockOut:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '库存查看', 'list', '', '#fff', '#00B42A', 5, 0, '0', 'wms:inventory:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '库存盘点', 'file-text', '', '#fff', '#00B42A', 6, 0, '0', 'wms:stockCheck:list', 'admin', NOW()),
('进销存管理', 'wms', 4, '进销存报表', 'chart', '', '#fff', '#00B42A', 7, 0, '0', 'wms:report:list', 'admin', NOW());

-- 财务管理分组（暂无App页面，先创建占位，visible=0）
INSERT INTO app_menu_config (group_name, group_key, group_sort, title, icon, path, icon_color, bg_color, sort_order, visible, status, perms, create_by, create_time) VALUES
('财务管理', 'finance', 5, '方案审核', 'edit-pen', '', '#fff', '#F53F3F', 1, 0, '0', 'finance:planAudit:list', 'admin', NOW()),
('财务管理', 'finance', 5, '报销管理', 'file-text', '', '#fff', '#F53F3F', 2, 0, '0', 'finance:reimbursement:list', 'admin', NOW()),
('财务管理', 'finance', 5, '报销统计', 'chart', '', '#fff', '#F53F3F', 3, 0, '0', 'finance:reimbursementReport:list', 'admin', NOW());

-- 3. 为现有菜单配置权限标识
UPDATE app_menu_config SET perms = 'business:attendance:record:list' WHERE id = 1;
UPDATE app_menu_config SET perms = 'business:sales:list' WHERE id = 2;
UPDATE app_menu_config SET perms = 'business:schedule:list' WHERE id = 3;
UPDATE app_menu_config SET perms = 'business:order:list' WHERE id = 4;
UPDATE app_menu_config SET perms = 'business:enterprise:list' WHERE id = 9;
UPDATE app_menu_config SET perms = 'business:store:list' WHERE id = 10;
UPDATE app_menu_config SET perms = 'business:schedule:list' WHERE id = 11;
UPDATE app_menu_config SET perms = 'business:sales:list' WHERE id = 12;
UPDATE app_menu_config SET perms = 'business:sales:list' WHERE id = 13;
UPDATE app_menu_config SET perms = 'business:order:list' WHERE id = 14;
UPDATE app_menu_config SET perms = 'system:user:list' WHERE id = 15;
UPDATE app_menu_config SET perms = 'system:role:list' WHERE id = 16;
UPDATE app_menu_config SET perms = 'system:menu:list' WHERE id = 17;
UPDATE app_menu_config SET perms = 'system:dept:list' WHERE id = 18;
UPDATE app_menu_config SET perms = 'system:post:list' WHERE id = 19;
UPDATE app_menu_config SET perms = 'system:dict:list' WHERE id = 20;
UPDATE app_menu_config SET perms = 'system:config:list' WHERE id = 21;
UPDATE app_menu_config SET perms = 'system:notice:list' WHERE id = 22;

-- 4. 更新现有分组的 group_sort
UPDATE app_menu_config SET group_sort = 1 WHERE group_key = 'quick';
UPDATE app_menu_config SET group_sort = 2 WHERE group_key = 'business';
UPDATE app_menu_config SET group_sort = 6 WHERE group_key = 'system';
UPDATE app_menu_config SET group_sort = 7 WHERE group_key = 'mine_action';
UPDATE app_menu_config SET group_sort = 8 WHERE group_key = 'mine_menu';
```

#### 4.2 后端修改

**文件**：`webman/app/service/AppMenuConfigService.php`

修改 `getGroupedMenus()` 方法，增加权限过滤：

```php
public function getGroupedMenus($userId = null)
{
    $query = AppMenuConfig::where('status', '0')
        ->where('visible', 1);

    if ($userId !== null) {
        $user = \app\model\SysUser::find($userId);
        if ($user && !$user->isAdmin()) {
            $permService = new SysPermissionService();
            $userPerms = $permService->getMenuPermission($user);
            $query->where(function ($q) use ($userPerms) {
                $q->where('perms', '')
                  ->orWhereNull('perms')
                  ->orWhereIn('perms', $userPerms);
            });
        }
    }

    $menus = $query->orderBy('group_sort', 'asc')
        ->orderBy('sort_order', 'asc')
        ->get();

    $grouped = [];
    foreach ($menus as $menu) {
        $key = $menu['group_key'];
        if (!isset($grouped[$key])) {
            $grouped[$key] = [
                'group_name' => $menu['group_name'],
                'group_key' => $menu['group_key'],
                'group_sort' => $menu['group_sort'],
                'items' => []
            ];
        }
        $grouped[$key]['items'][] = [
            'id' => $menu['id'],
            'title' => $menu['title'],
            'icon' => $menu['icon'],
            'path' => $menu['path'],
            'icon_color' => $menu['icon_color'],
            'bg_color' => $menu['bg_color'],
            'sort_order' => $menu['sort_order'],
        ];
    }

    return array_values(array_filter($grouped, fn($g) => count($g['items']) > 0));
}
```

**文件**：`webman/app/controller/system/AppMenuConfigController.php`

```php
public function grouped(Request $request)
{
    $service = new AppMenuConfigService();
    $userId = $request->loginUser->user->user_id ?? null;
    $menus = $service->getGroupedMenus($userId);
    return AjaxResult::success($menus);
}
```

#### 4.3 AppV3工作台页面修改

**文件**：`AppV3/src/pages/work/index.vue`

当前工作台硬编码了"常用功能"、"业务管理"、"系统管理"三个分区，需要改为动态渲染从后端获取的所有分组：

```vue
<template>
  <view class="work-container">
    <!-- 轮播图 -->
    <view class="swiper-section">...</view>
    
    <!-- 搜索 -->
    <view class="search-card">...</view>
    
    <!-- 动态菜单分组 -->
    <view v-for="group in menuGroups" :key="group.group_key" class="grid-card">
      <view class="card-header">
        <text class="card-title">{{ group.group_name }}</text>
      </view>
      <view class="divider"></view>
      <view class="grid-body">
        <view class="grid-row">
          <view v-for="item in group.items" :key="item.id" class="grid-item" @click="handleGridClick(item)">
            <view class="icon-wrapper" :style="{ backgroundColor: item.bg_color || item.bgColor || '#3D6DF7' }">
              <u-icon :name="item.icon" size="22" :color="item.icon_color || item.iconColor || '#fff'" />
            </view>
            <text class="grid-text">{{ item.title }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { useMenuStore } from '@/store/modules/menu'

const menuStore = useMenuStore()

const menuGroups = computed(() => {
  return menuStore.menus ? Object.values(menuStore.menus) : []
})
</script>
```

#### 4.4 管理后台修改

**文件**：`front/src/views/system/appMenu/index.vue`

在菜单编辑表单中增加"权限标识"字段。

## 五、权限分配流程

**完全复用现有的角色管理界面**：

1. 管理员进入「系统管理 → 角色管理」
2. 编辑某个角色
3. 在「菜单权限」中勾选：
   - ✅ 销售开单 → Web端显示 + App端显示"开单"
   - ✅ 门店管理 → Web端显示 + App端显示"门店管理"
   - ✅ 考勤记录 → Web端显示 + App端显示"打卡"
4. 保存后生效

## 六、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | SQL脚本 | app_menu_config新增perms + 新增分组 + 更新perms |
| 2 | `webman/app/service/AppMenuConfigService.php` | getGroupedMenus增加权限过滤 |
| 3 | `webman/app/controller/system/AppMenuConfigController.php` | grouped传入userId |
| 4 | `AppV3/src/pages/work/index.vue` | 动态渲染菜单分组 |
| 5 | `front/src/views/system/appMenu/index.vue` | 新增权限标识字段编辑 |
