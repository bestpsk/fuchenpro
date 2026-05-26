<template>
   <div>
      <i-frame v-model:src="url"></i-frame>
   </div>
</template>

<script setup>
/**
 * @description 数据库监控页面 - Druid监控面板内嵌
 * @description 通过iframe内嵌Druid监控页面，展示数据库连接池和SQL执行情况
 */
import iFrame from '@/components/iFrame'

import { ref } from 'vue'

const url = ref(import.meta.env.VITE_APP_BASE_API + '/druid/login.html')
</script>
