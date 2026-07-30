import { defineStore } from 'pinia'
import { getGroupedMenus } from '@/api/system/appMenu'

const CACHE_KEY = 'app_menu_config'
const CACHE_VERSION = 15
const CLICK_COUNTS_KEY = 'app_menu_click_counts'

export const useMenuStore = defineStore('menu', {
  state: () => ({
    menus: {},
    loaded: false,
    clickCounts: JSON.parse(uni.getStorageSync(CLICK_COUNTS_KEY) || '{}')
  }),

  getters: {
    allMenuItems: (state) => {
      const items = []
      for (const group of Object.values(state.menus)) {
        if (group && group.items) {
          items.push(...group.items)
        }
      }
      return items
    },

    quickMenus: (state) => {
      const allItems = []
      for (const group of Object.values(state.menus)) {
        if (group && group.groupKey !== 'quick' && group.items) {
          allItems.push(...group.items)
        }
      }
      if (allItems.length === 0) return []

      const counts = state.clickCounts
      const hasClickData = Object.keys(counts).length > 0

      if (!hasClickData) {
        return [...allItems].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0)).slice(0, 5)
      }

      return [...allItems].sort((a, b) => (counts[b.id] || 0) - (counts[a.id] || 0)).slice(0, 5)
    },
  },

  actions: {
    recordMenuClick(menuId) {
      if (!menuId) return
      this.clickCounts[menuId] = (this.clickCounts[menuId] || 0) + 1
      uni.setStorageSync(CLICK_COUNTS_KEY, JSON.stringify(this.clickCounts))
    },

    async loadMenus() {
      try {
        const cached = uni.getStorageSync(CACHE_KEY)
        if (cached && cached._version === CACHE_VERSION && cached.data) {
          this.menus = cached.data
          this.loaded = true
        }
        const res = await getGroupedMenus()
        if (res.code === 200 && res.data && res.data.length > 0) {
          const menuMap = {}
          for (const group of res.data) {
            menuMap[group.groupKey] = group
          }
          this.menus = menuMap
          this.loaded = true
          uni.setStorageSync(CACHE_KEY, { _version: CACHE_VERSION, data: menuMap })
        } else if (!this.loaded) {
          this.menus = {}
          this.loaded = true
        }
      } catch (e) {
        console.warn('加载菜单配置失败', e)
        if (!this.loaded) {
          this.menus = {}
          this.loaded = true
        }
      }
    },

    async refreshMenus() {
      try {
        const res = await getGroupedMenus()
        if (res.code === 200 && res.data) {
          const menuMap = {}
          for (const group of res.data) {
            menuMap[group.groupKey] = group
          }
          this.menus = menuMap
          this.loaded = true
          uni.setStorageSync(CACHE_KEY, { _version: CACHE_VERSION, data: menuMap })
        }
      } catch (e) {
        console.warn('刷新菜单配置失败', e)
      }
    },

    clearCache() {
      uni.removeStorageSync(CACHE_KEY)
      this.menus = {}
      this.loaded = false
    }
  }
})
