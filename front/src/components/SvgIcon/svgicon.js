/**
 * @description SVG图标注册插件 - 批量注册Element Plus图标组件
 * @description 将@element-plus/icons-vue中的所有图标组件全局注册到Vue应用，
 * 使模板中可直接使用图标组件名引用
 */
import * as components from '@element-plus/icons-vue'

export default {
  install: (app) => {
    for (const key in components) {
      const componentConfig = components[key]
      app.component(componentConfig.name, componentConfig)
    }
  }
}
