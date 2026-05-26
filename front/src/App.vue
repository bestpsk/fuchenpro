<template>
  <router-view />
</template>

<script setup>
/**
 * @description 根组件 - 应用入口与主题初始化
 * @description 挂载时根据用户设置的主题配置初始化全局主题样式
 */
import useSettingsStore from '@/store/modules/settings'
import { handleThemeStyle } from '@/utils/theme'

onMounted(() => {
  nextTick(() => {
    handleThemeStyle(useSettingsStore().theme)
  })
})
</script>
