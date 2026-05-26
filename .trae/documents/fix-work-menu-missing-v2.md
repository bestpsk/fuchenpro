# AppV3工作台动态菜单不显示问题修复

## 一、问题分析

**现象**：重新登录后，只能看到"常用功能"，其他分组（业务管理、考勤管理等）不显示

**排查思路**：
1. 数据库数据正确 ✅
2. 后端权限过滤对admin不生效 ✅
3. 路由和中间件正常 ✅
4. 缓存版本号已更新 ✅

**最可能的原因**：API调用失败或返回数据格式不匹配

**关键线索**：
- "常用功能"显示 → `quickDisplayList` 使用 `menuStore.quickMenus`，这个getter会回退到 `DEFAULT_MENUS`
- 其他分组不显示 → `menuGroups` 使用 `Object.values(menuStore.menus)`，如果 `menus` 是空对象则不显示
- 这说明 **API可能没有成功返回数据**，`menuStore.menus` 是空对象

## 二、修复方案

### 2.1 menu.js - 增加API失败时的回退逻辑

当API调用失败时，应该使用DEFAULT_MENUS作为回退，而不是让menus为空。

### 2.2 menu.js - 增加调试日志

在loadMenus中添加console.log，方便排查问题。

### 2.3 work/index.vue - 增加DEFAULT_MENUS回退

当menuGroups为空时，使用DEFAULT_MENUS中的非quick分组作为回退。

## 三、修改内容

### 3.1 menu.js - 修复loadMenus回退逻辑

```javascript
async loadMenus() {
  try {
    const cached = uni.getStorageSync(CACHE_KEY)
    if (cached && cached._version === CACHE_VERSION && cached.data) {
      this.menus = cached.data
      this.loaded = true
    }
    const res = await getGroupedMenus()
    console.log('[MenuStore] API response:', JSON.stringify(res?.code), 'data length:', res?.data?.length)
    if (res.code === 200 && res.data && res.data.length > 0) {
      const menuMap = {}
      for (const group of res.data) {
        menuMap[group.group_key] = group
      }
      this.menus = menuMap
      this.loaded = true
      uni.setStorageSync(CACHE_KEY, { _version: CACHE_VERSION, data: menuMap })
    } else if (!this.loaded) {
      this.menus = DEFAULT_MENUS
      this.loaded = true
    }
  } catch (e) {
    console.warn('加载菜单配置失败，使用默认菜单', e)
    if (!this.loaded) {
      this.menus = DEFAULT_MENUS
      this.loaded = true
    }
  }
}
```

### 3.2 work/index.vue - menuGroups增加DEFAULT_MENUS回退

```javascript
import { useMenuStore } from '@/store/modules/menu'
import { DEFAULT_MENUS } from '@/store/modules/menu'  // 需要export

const menuGroups = computed(() => {
  const menus = menuStore.menus && Object.keys(menuStore.menus).length > 0 
    ? menuStore.menus 
    : DEFAULT_MENUS
  return Object.values(menus).filter(g => g && g.group_key && g.group_key !== 'quick' && g.items && g.items.length > 0)
})
```

### 3.3 menu.js - 导出DEFAULT_MENUS

需要将DEFAULT_MENUS导出，供work/index.vue使用。
