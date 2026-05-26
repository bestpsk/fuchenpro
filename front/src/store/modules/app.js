/**
 * @description 应用状态管理 - 侧边栏与设备信息
 * @description 管理侧边栏展开/折叠状态（Cookie持久化）、设备类型（desktop/mobile）、
 * UI组件尺寸等全局应用状态
 */
import Cookies from 'js-cookie'

const useAppStore = defineStore(
  'app',
  {
    state: () => ({
      /** 侧边栏状态：opened是否展开、withoutAnimation是否禁用动画、hide是否隐藏 */
      sidebar: {
        opened: Cookies.get('sidebarStatus') ? !!+Cookies.get('sidebarStatus') : true,
        withoutAnimation: false,
        hide: false
      },
      /** 当前设备类型：desktop或mobile */
      device: 'desktop',
      /** UI组件尺寸：default/medium/small/mini，Cookie持久化 */
      size: Cookies.get('size') || 'default'
    }),
    actions: {
      /** 切换侧边栏展开/折叠，隐藏状态下不响应，状态写入Cookie持久化 */
      toggleSideBar(withoutAnimation) {
        if (this.sidebar.hide) {
          return false
        }
        this.sidebar.opened = !this.sidebar.opened
        this.sidebar.withoutAnimation = withoutAnimation
        if (this.sidebar.opened) {
          Cookies.set('sidebarStatus', 1)
        } else {
          Cookies.set('sidebarStatus', 0)
        }
      },
      /** 关闭侧边栏，带动画控制参数 */
      closeSideBar({ withoutAnimation }) {
        Cookies.set('sidebarStatus', 0)
        this.sidebar.opened = false
        this.sidebar.withoutAnimation = withoutAnimation
      },
      /** 切换设备类型（响应式布局用） */
      toggleDevice(device) {
        this.device = device
      },
      /** 设置UI组件尺寸并持久化到Cookie */
      setSize(size) {
        this.size = size
        Cookies.set('size', size)
      },
      /** 切换侧边栏隐藏/显示（顶部导航模式下隐藏侧边栏） */
      toggleSideBarHide(status) {
        this.sidebar.hide = status
      }
    }
  })

export default useAppStore
