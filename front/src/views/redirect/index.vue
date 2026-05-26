<template>
  <div></div>
</template>

<script setup>
/**
 * @description 重定向页面 - 路由刷新中间页
 * @description 用于标签页刷新功能，通过重定向到当前路径实现组件重新加载
 */
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const { params, query } = route
const { path } = params

/** 将 /redirect/path 重定向到 /path，触发目标组件重新渲染 */
router.replace({ path: '/' + path, query })
</script>