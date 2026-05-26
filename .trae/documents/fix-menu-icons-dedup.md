# 修复：去掉项目操作、去重打卡、修复异常图标

## 问题清单

### 1. 去掉"项目操作"菜单
- 功能已包含在销售开单中
- 需从数据库和 DEFAULT_MENUS 中删除（id=14）

### 2. 打卡/考勤打卡重复 → 保留考勤打卡，删除打卡
- DEFAULT_QUICK_ITEMS 中删除"打卡"(id=1)，保留"考勤打卡"(id=50)
- 常用功能默认5个改为：考勤打卡、开单、行程、订单、企业管理

### 3. 图标显示异常（uview-plus不支持的图标名）

| 当前图标 | 使用位置 | 状态 | 替换为 |
|---------|---------|------|--------|
| `shop` | 门店管理 | ❌ 不支持 | `home` |
| `bar-chart` | 进销存报表 | ❌ 不支持 | `list-dot` |
| `bar-chart` | 报销统计 | ❌ 不支持 | `file-text` |

## 实施步骤

### 步骤1：数据库更新
```sql
DELETE FROM app_menu_config WHERE title = '项目操作' AND group_key = 'business';
UPDATE app_menu_config SET icon = 'home' WHERE icon = 'shop';
UPDATE app_menu_config SET icon = 'list-dot' WHERE title = '进销存报表' AND icon = 'bar-chart';
UPDATE app_menu_config SET icon = 'file-text' WHERE title = '报销统计' AND icon = 'bar-chart';
```

### 步骤2：menu.js 更新
- DEFAULT_MENUS.business.items 删除"项目操作"(id=14)
- DEFAULT_MENUS.quick.items 和 DEFAULT_QUICK_ITEMS 删除"打卡"(id=1)，保留"考勤打卡"
- 所有 `shop` → `home`
- 所有 `bar-chart` → 按上下文替换
- CACHE_VERSION 递增为 5
