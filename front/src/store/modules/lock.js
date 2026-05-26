/**
 * @description 锁屏状态管理 - 屏幕锁定与解锁
 * @description 管理屏幕锁定状态和锁定前路径，使用localStorage持久化，
 * 解锁后恢复到锁定前的页面
 */
const LOCK_KEY = 'screen-lock'
const LOCK_PATH_KEY = 'screen-lock-path'

export const useLockStore = defineStore('lock', {
  state: () => ({
    /** 是否已锁屏，从localStorage恢复 */
    isLock: JSON.parse(localStorage.getItem(LOCK_KEY) || 'false'),
    /** 锁屏前的页面路径，解锁后跳回 */
    lockPath: localStorage.getItem(LOCK_PATH_KEY) || '/index'
  }),
  actions: {
    /** 锁定屏幕，记录当前路径用于解锁后恢复 */
    lockScreen(currentPath) {
      this.lockPath = currentPath || '/index'
      localStorage.setItem(LOCK_PATH_KEY, this.lockPath)
      this.isLock = true
      localStorage.setItem(LOCK_KEY, 'true')
    },
    /** 解锁屏幕，清除锁定状态和路径记录 */
    unlockScreen() {
      this.isLock = false
      localStorage.setItem(LOCK_KEY, 'false')
      this.lockPath = '/index'
      localStorage.setItem(LOCK_PATH_KEY, '/index')
    }
  }
})

export default useLockStore
