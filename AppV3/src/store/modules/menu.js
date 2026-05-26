import { defineStore } from 'pinia'
import { getGroupedMenus } from '@/api/system/appMenu'

const DEFAULT_MENUS = {
  quick: {
    groupName: '常用功能',
    groupKey: 'quick',
    items: [
      { id: 50, title: '考勤打卡', icon: 'clock', path: '/pages/attendance/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 1 },
      { id: 2, title: '开单', icon: 'file-text', path: '/pages/business/sales/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 2 },
      { id: 3, title: '行程', icon: 'calendar', path: '/pages/business/schedule/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 3 },
      { id: 4, title: '订单', icon: 'list', path: '/pages/business/order/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 4 },
      { id: 10, title: '企业管理', icon: 'home-fill', path: '/pages/business/enterprise/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 5 }
    ]
  },
  business: {
    groupName: '业务管理',
    groupKey: 'business',
    items: [
      { id: 10, title: '企业管理', icon: 'home-fill', path: '/pages/business/enterprise/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 1 },
      { id: 11, title: '门店管理', icon: 'home', path: '/pages/business/store/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 2 },
      { id: 12, title: '行程安排', icon: 'calendar', path: '/pages/business/schedule/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 3 },
      { id: 13, title: '销售开单', icon: 'edit-pen', path: '/pages/business/sales/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 4 },
      { id: 15, title: '订单管理', icon: 'list', path: '/pages/business/order/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 5 },
      { id: 16, title: '方案管理', icon: 'file-text', path: '/pages/business/plan/index', iconColor: '#fff', bgColor: '#FF6B35', sortOrder: 6 }
    ]
  },
  attendance: {
    groupName: '考勤管理',
    groupKey: 'attendance',
    items: [
      { id: 50, title: '考勤打卡', icon: 'clock', path: '/pages/attendance/index', iconColor: '#fff', bgColor: '#F59E0B', sortOrder: 1 },
      { id: 51, title: '考勤记录', icon: 'file-text', path: '/pages/attendance/record', iconColor: '#fff', bgColor: '#F59E0B', sortOrder: 2 },
      { id: 52, title: '考勤规则', icon: 'setting', path: '', iconColor: '#fff', bgColor: '#F59E0B', sortOrder: 3 },
      { id: 53, title: '考勤配置', icon: 'grid', path: '/pages/attendance/config', iconColor: '#fff', bgColor: '#F59E0B', sortOrder: 4 }
    ]
  },
  wms: {
    groupName: '进销存管理',
    groupKey: 'wms',
    items: [
      { id: 60, title: '供货商管理', icon: 'account', path: '/pages/wms/supplier/index', iconColor: '#fff', bgColor: '#10B981', sortOrder: 1 },
      { id: 61, title: '货品管理', icon: 'list', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 2 },
      { id: 62, title: '入库管理', icon: 'arrow-down', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 3 },
      { id: 63, title: '出库管理', icon: 'arrow-up', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 4 },
      { id: 64, title: '库存查看', icon: 'search', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 5 },
      { id: 65, title: '库存盘点', icon: 'checkmark-circle', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 6 },
      { id: 66, title: '店企业出货', icon: 'car', path: '/pages/wms/shipment/index', iconColor: '#fff', bgColor: '#10B981', sortOrder: 7 },
      { id: 67, title: '进销存报表', icon: 'list-dot', path: '', iconColor: '#fff', bgColor: '#10B981', sortOrder: 8 }
    ]
  },
  finance: {
    groupName: '财务管理',
    groupKey: 'finance',
    items: [
      { id: 70, title: '方案审核', icon: 'checkmark', path: '/pages/business/plan/index', iconColor: '#fff', bgColor: '#8B5CF6', sortOrder: 1 },
      { id: 71, title: '报销管理', icon: 'edit-pen', path: '', iconColor: '#fff', bgColor: '#8B5CF6', sortOrder: 2 },
      { id: 72, title: '报销统计', icon: 'file-text', path: '', iconColor: '#fff', bgColor: '#8B5CF6', sortOrder: 3 }
    ]
  },
  system: {
    groupName: '系统管理',
    groupKey: 'system',
    items: [
      { id: 20, title: '用户管理', icon: 'account', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 1 },
      { id: 21, title: '角色管理', icon: 'man-add', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 2 },
      { id: 22, title: '菜单管理', icon: 'list', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 3 },
      { id: 23, title: '部门管理', icon: 'home', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 4 },
      { id: 24, title: '岗位管理', icon: 'bookmark', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 5 },
      { id: 25, title: '字典管理', icon: 'file-text', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 6 },
      { id: 26, title: '参数设置', icon: 'setting', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 7 },
      { id: 27, title: '通知公告', icon: 'chat', path: '', iconColor: '#fff', bgColor: '#3D6DF7', sortOrder: 8 }
    ]
  }
}

const CACHE_KEY = 'app_menu_config'
const CACHE_VERSION = 8
const CLICK_COUNTS_KEY = 'app_menu_click_counts'

const DEFAULT_QUICK_ITEMS = [
  { id: 50, title: '考勤打卡', icon: 'clock', path: '/pages/attendance/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 1 },
  { id: 2, title: '开单', icon: 'file-text', path: '/pages/business/sales/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 2 },
  { id: 3, title: '行程', icon: 'calendar', path: '/pages/business/schedule/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 3 },
  { id: 4, title: '订单', icon: 'list', path: '/pages/business/order/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 4 },
  { id: 10, title: '企业管理', icon: 'home-fill', path: '/pages/business/enterprise/index', iconColor: '#3D6DF7', bgColor: '#E8F0FE', sortOrder: 5 }
]

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
      if (allItems.length === 0) return DEFAULT_QUICK_ITEMS

      const counts = state.clickCounts
      const hasClickData = Object.keys(counts).length > 0

      if (!hasClickData) return DEFAULT_QUICK_ITEMS

      const sorted = [...allItems].sort((a, b) => {
        return (counts[b.id] || 0) - (counts[a.id] || 0)
      })
      return sorted.slice(0, 5)
    },

    businessMenus: (state) => state.menus.business?.items || DEFAULT_MENUS.business.items,
    systemMenus: (state) => state.menus.system?.items || DEFAULT_MENUS.system.items
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
        console.log('[MenuStore] API response:', JSON.stringify(res?.code), 'data length:', res?.data?.length)
        if (res.code === 200 && res.data && res.data.length > 0) {
          const menuMap = {}
          for (const group of res.data) {
            menuMap[group.groupKey] = group
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
