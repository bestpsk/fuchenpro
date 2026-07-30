/**
 * @description 全局配置 - 应用基础信息和第三方服务配置
 * @description 定义后端API基础路径、应用名称/版本/Logo等元信息、隐私政策和用户协议链接，
 * 以及高德地图Web服务Key等第三方服务密钥
 */
export default {
  /** 后端API基础路径，开发环境通过vite代理，生产环境通过.env.production配置 */
  baseUrl: import.meta.env.VITE_APP_BASE_API || '/prod-api',
  /** 应用基本信息，用于关于页面、登录页等处展示 */
  appInfo: {
    name: "赛诺美生",
    version: "1.0.0",
    logo: import.meta.env.BASE_URL + "static/logo.png",
    site_url: "https://fuchenpro.com",
    /** 法律合规文档链接，登录/注册页展示 */
    agreements: [
      { title: "用户服务协议", url: "/pages/agreement/user" },
      { title: "隐私政策", url: "/pages/agreement/privacy" }
    ]
  },
  /** 高德地图Web服务Key，从后端配置获取，此处不再硬编码 */
  amap: {
    webServiceKey: ''
  }
}
