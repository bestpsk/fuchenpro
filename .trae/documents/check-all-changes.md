# Web端 + App端 改动完整性检查报告

## AppV3 端 - 全部通过 ✅

| 文件 | 检查项 | 状态 |
|------|--------|------|
| `store/modules/menu.js` | uni.getStorageSync/setStorageSync | ✅ |
| `store/modules/dict.js` | 文件存在，含降级默认值 | ✅ |
| `api/system/dictData.js` | 文件存在 | ✅ |
| `api/system/appMenu.js` | 文件存在 | ✅ |
| `components/home/QuickMenu.vue` | menu store 动态读取 | ✅ |
| `pages/work/index.vue` | menu store 动态读取 | ✅ |
| `pages/mine/index.vue` | menu store 动态读取 | ✅ |
| `pages/business/order/index.vue` | u-tag + 字典驱动 | ✅ |
| `pages/business/order/detail.vue` | source_type=1 自动切换操作模式 | ✅ |
| `App.vue` | onLaunch 预加载菜单 | ✅ |

## Front Web端 - 需要补充 ⚠️

| 文件 | 检查项 | 状态 |
|------|--------|------|
| `views/business/order/index.vue` | 订单列表缺少 source_type 类型标签 | ❌ 需补充 |
| `views/system/appMenu/index.vue` | App菜单配置页面 | ✅ 已创建 |

### 需要补充的改动

**`front/src/views/business/order/index.vue`**：

当前订单管理列表没有显示来源类型标签，需要：
1. 在表格中新增"来源类型"列，使用 `<el-tag>` 显示（开单/操作/还款/手动）
2. 查询条件中增加来源类型筛选
3. 颜色映射：开单=primary蓝, 操作=success绿, 还款=warning橙, 手动=info灰

该页面已有 `getSourceTypeLabel` 和 `getSourceTypeTagType` 函数（在 sales/index.vue 的档案模块中），可复用相同逻辑。
