/**
 * @description 插件注册入口 - 全局挂载通用工具插件
 * @description 将页签操作、权限验证、缓存操作、弹窗操作、文件下载等插件
 * 注册到Vue全局属性，使组件内可通过 this.$tab / $auth / $cache / $modal / $download 调用
 */
import tab from './tab'
import auth from './auth'
import cache from './cache'
import modal from './modal'
import download from './download'

export default function installPlugins(app){
  /** 页签操作插件，管理标签页的打开/关闭/刷新 */
  app.config.globalProperties.$tab = tab
  /** 认证对象插件，提供权限和角色判断方法 */
  app.config.globalProperties.$auth = auth
  /** 缓存对象插件，封装sessionStorage和localStorage操作 */
  app.config.globalProperties.$cache = cache
  /** 模态框对象插件，封装消息提示/确认框/通知/加载遮罩 */
  app.config.globalProperties.$modal = modal
  /** 下载文件插件，提供文件名/资源路径/ZIP三种下载方式 */
  app.config.globalProperties.$download = download
}
