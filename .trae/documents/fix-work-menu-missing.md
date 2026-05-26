# AppV3工作台动态菜单消失问题修复

## 一、问题分析

**现象**：admin管理员登录后，只能看到"常用功能"（quick分组），其他分组（业务管理、考勤管理、系统管理等）都不见了。

**可能原因**：
1. **AppV3缓存问题**：之前API返回的数据格式不同，被缓存了旧数据
2. **后端权限过滤问题**：`isAdmin()` 可能对admin用户返回false
3. **API返回数据格式问题**：后端返回的分组结构与前端期望不一致

**排查结果**：
- 数据库数据正确：visible=1的菜单有quick、business、attendance、system、mine_action、mine_menu
- admin的user_id=1，`isAdmin()` 返回true，权限过滤不会执行
- 后端返回的字段名（group_key等）与前端期望一致

**最可能的原因**：AppV3缓存了旧数据。`loadMenus()` 先读取缓存，如果缓存中有旧格式数据，会先使用旧数据。然后API返回新数据后更新。但如果缓存中的数据结构不包含新分组，就会显示不完整。

## 二、修复方案

### 2.1 确保缓存清除
用户退出登录时已经调用 `clearCache()`，但需要确保重新登录后能正确加载新数据。

### 2.2 修改menu store的loadMenus方法
在API返回数据后，确保正确处理所有分组。同时增加一个版本号机制，当数据结构变化时自动清除旧缓存。

### 2.3 修改work/index.vue
确保 `menuGroups` 正确处理API返回的数据。

## 三、修改内容

### 3.1 menu.js - 增加缓存版本号
```javascript
const CACHE_KEY = 'app_menu_config'
const CACHE_VERSION = 2  // 数据结构变更时递增

// loadMenus中检查版本号
const cached = uni.getStorageSync(CACHE_KEY)
if (cached && cached._version === CACHE_VERSION) {
  this.menus = cached.data
  this.loaded = true
}
// 保存时带版本号
uni.setStorageSync(CACHE_KEY, { _version: CACHE_VERSION, data: menuMap })
```

### 3.2 work/index.vue - 增加调试和容错
确保 `menuGroups` 正确处理各种数据格式。
