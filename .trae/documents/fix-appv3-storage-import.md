# 修复 AppV3 启动报错 - storage 导入问题

## 问题分析

`src/store/modules/menu.js` 中导入了不存在的函数：
```js
import { getStorage, setStorage } from '@/utils/storage'
```

但 `src/utils/storage.js` 导出的是默认对象：
```js
export default storage  // { set, get, remove, clean }
```

## 解决方案

考虑到**未来菜单会根据用户-角色权限动态变化**，菜单缓存应该与用户数据绑定。因此使用聚合存储更合适：

1. 当用户切换/退出时，聚合存储会被清空，菜单缓存也会随之清除
2. 新用户登录后会重新加载该用户的菜单配置

**修改方案**：导入默认 storage 对象
```js
import storage from '@/utils/storage'
// 使用 storage.get(key) 和 storage.set(key, value)
```

## 修改文件

`AppV3/src/store/modules/menu.js`:
- 第3行：`import { getStorage, setStorage } from '@/utils/storage'` → `import storage from '@/utils/storage'`
- `loadMenus()` 中：`getStorage(CACHE_KEY)` → `storage.get(CACHE_KEY)`
- `loadMenus()` 中：`setStorage(CACHE_KEY, menuMap)` → `storage.set(CACHE_KEY, menuMap)`
- `refreshMenus()` 中：`setStorage(CACHE_KEY, menuMap)` → `storage.set(CACHE_KEY, menuMap)`

## 注意事项

由于 `storage.set()` 有白名单限制（只允许 `avatar`, `id`, `name`, `roles`, `permissions`），需要将 `CACHE_KEY` 添加到白名单，或者使用 `uni.setStorageSync` 作为替代方案。

**最终方案**：使用 `uni.getStorageSync` / `uni.setStorageSync`，但在用户退出登录时清除菜单缓存（在 `user.js` 的 logout action 中调用 `uni.removeStorageSync(CACHE_KEY)`）。
