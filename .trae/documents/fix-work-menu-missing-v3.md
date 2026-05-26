# 修复：AppV3工作台动态菜单登录后不显示

## 问题分析

### 根本原因
**登录成功后从未调用 `menuStore.loadMenus()`**，导致动态菜单数据为空。

### 完整调用链分析

1. **App启动** → `App.vue` `onLaunch` → 检查 `getToken()` → **此时用户未登录，token为空** → `loadMenus()` 被跳过
2. **用户登录** → `login.vue` `pwdLogin()` → `userStore.loginAction()`（设置token） → `userStore.getInfoAction()` → `uni.reLaunch({ url: '/pages/index' })` → **没有调用 `loadMenus()`！**
3. **用户进入工作台** → `menuStore.menus` 为 `{}` → `menuGroups` 计算属性返回 `[]` → 只显示硬编码的"常用功能"

### 为什么"常用功能"能显示
"常用功能"区块是模板中硬编码的，`quickDisplayList` 使用 `menuStore.quickMenus`，该 getter 有 `DEFAULT_MENUS.quick.items` 的回退逻辑。

### 为什么重新登录也不显示
- 退出登录时 `logOut()` 调用了 `useMenuStore().clearCache()` 清空了菜单缓存
- 重新登录后 `pwdLogin()` 仍然没有调用 `loadMenus()`
- 所以菜单数据始终为空

## 修复方案

### 修改1：login.vue - 登录成功后加载菜单（核心修复）

**文件**: `f:\fuchen\AppV3\src\pages\login.vue`

在 `pwdLogin()` 函数中，登录成功后、跳转页面前，调用 `menuStore.loadMenus()`：

```javascript
import { useMenuStore } from '@/store/modules/menu'

async function pwdLogin() {
  try {
    await userStore.loginAction(loginForm.value)
    uni.hideLoading()
    await userStore.getInfoAction()
    // 登录成功后加载动态菜单
    const menuStore = useMenuStore()
    await menuStore.loadMenus()
    uni.reLaunch({ url: '/pages/index' })
  } catch {
    uni.hideLoading()
    if (captchaEnabled.value) {
      getCode()
    }
  }
}
```

### 修改2：work/index.vue - 页面显示时确保菜单已加载（安全兜底）

**文件**: `f:\fuchen\AppV3\src\pages\work\index.vue`

添加 `onShow` 生命周期钩子，确保每次进入工作台页面时菜单数据已加载：

```javascript
import { onShow } from '@dcloudio/uni-app'

onShow(() => {
  if (!menuStore.loaded) {
    menuStore.loadMenus()
  }
})
```

### 修改3：menu.js - 优化 loadMenus 的 API 空数据回退逻辑

**文件**: `f:\fuchen\AppV3\src\store\modules\menu.js`

当前 `loadMenus` 在 API 返回空数组时（`res.data` 为 `[]`），会将 `this.menus` 设为空对象 `{}`，导致页面什么都不显示。应增加空数据回退到 DEFAULT_MENUS 的逻辑：

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

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `AppV3/src/pages/login.vue` | 登录成功后调用 `menuStore.loadMenus()` |
| `AppV3/src/pages/work/index.vue` | 添加 `onShow` 钩子确保菜单已加载 |
| `AppV3/src/store/modules/menu.js` | 优化空数据回退逻辑 + 增加调试日志 |
