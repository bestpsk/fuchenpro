<script>
  import config from './config'
  import { getToken } from '@/utils/auth'
  import { useMenuStore } from '@/store/modules/menu'

  export default {
    onLaunch() {
      this.initApp()
    },
    methods: {
      initApp() {
        this.globalData.config = config
        if (getToken()) {
          const menuStore = useMenuStore()
          menuStore.loadMenus()
        }
        // #ifdef H5
        this.checkLogin()
        // #endif
      },
      checkLogin() {
        if (!getToken()) {
          uni.reLaunch({ url: '/pages/login' })
        }
      }
    },
    globalData: {
      config: {}
    }
  }
</script>

<style lang="scss">
  @import '@/static/scss/common.scss';
  @import 'uview-plus/theme.scss';
  @import 'uview-plus/index.scss';

  /* uview-plus 图标字体 */
  @font-face {
    font-family: 'uicon-iconfont';
    src: url('/static/uview-plus/uicon-iconfont.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;
    font-display: block;
  }

  /* H5 端 uni-editor 默认 display:inline 会导致高度不生效，统一为 block */
  uni-editor {
    display: block;
  }

  /* ============ 全局动效规范（钉钉/企业微信风） ============ */
  page {
    /* 全局过渡：可点击元素默认使用 150ms 缓出 */
    view, text, button, scroll-view, swiper, swiper-item {
      transition-timing-function: cubic-bezier(0.16, 1, 0.3, 1);
    }
  }

  /* 全局按钮点击反馈（钉钉/企业微信风：克制细腻） */
  button {
    &::after { border: none; }
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active:not([disabled]) {
      transform: scale(0.98);
      opacity: 0.85;
    }
  }
</style>
