/**
 * @description 动态标题 - 根据路由菜单项设置浏览器标签页标题
 * @description 从路由meta中提取标题，拼接应用名称后设置为document.title
 */
import defaultSettings from '@/settings'
import useSettingsStore from '@/store/modules/settings'

/**
 * 动态修改标题
 */
export function useDynamicTitle() {
  const settingsStore = useSettingsStore()
  if (settingsStore.dynamicTitle) {
    document.title = settingsStore.title + ' - ' + defaultSettings.title
  } else {
    document.title = defaultSettings.title
  }
}