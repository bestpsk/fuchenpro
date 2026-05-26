<template>
  <div v-loading="loading" :style="'height:' + height">
    <iframe 
      :src="url" 
      frameborder="no" 
      style="width: 100%; height: 100%" 
      scrolling="auto" />
  </div>
</template>

<script setup>
/**
 * @description 内嵌框架组件 - iframe页面嵌入与自适应
 * @description 将外部URL通过iframe嵌入，支持自适应高度和loading状态
 */
const props = defineProps({
  src: {
    type: String,
    required: true
  }
})

const height = ref(document.documentElement.clientHeight - 94.5 + "px;")
const loading = ref(true)
const url = computed(() => props.src)

onMounted(() => {
  setTimeout(() => {
    loading.value = false
  }, 300)
  window.onresize = function temp() {
    height.value = document.documentElement.clientHeight - 94.5 + "px;"
  }
})
</script>
