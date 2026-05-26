/**
 * @description Pinia状态管理入口 - 全局Store初始化
 * @description 创建Pinia实例供应用挂载，各模块store通过defineStore按需引入
 */
const store = createPinia()

export default store
