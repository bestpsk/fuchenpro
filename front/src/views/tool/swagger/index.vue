<template>
   <i-frame v-model:src="url"></i-frame>
</template>

<script setup>
/**
 * @description Swagger文档页面 - API文档内嵌展示
 * @description 通过iframe内嵌Swagger UI页面，展示后端API文档
 */
import iFrame from '@/components/iFrame'

const url = ref(import.meta.env.VITE_APP_BASE_API + "/swagger-ui/index.html")
</script>
