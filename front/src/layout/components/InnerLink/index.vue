<template>
  <div :style="'height:' + height" v-loading="loading" element-loading-text="正在加载页面，请稍候！">
    <iframe
      :id="iframeId"
      style="width: 100%; height: 100%"
      :src="src"
      ref="iframeRef"
      frameborder="no"
    ></iframe>
  </div>
</template>

<script setup>
/**
 * @description 内嵌链接组件 - iframe方式嵌入外部页面
 * @description 将外部URL通过iframe嵌入到系统内容区，支持自适应高度
 */
const props = defineProps({
  src: {
    type: String,
    default: "/"
  },
  iframeId: {
    type: String
  }
})

const loading = ref(true)
const height = ref(document.documentElement.clientHeight - 94.5 + 'px')
const iframeRef = ref(null)

onMounted(() => {
  if (iframeRef.value) {
    iframeRef.value.onload = () => {
      loading.value = false
    }
  }
})
</script>
