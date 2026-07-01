<template>
  <view class="container">
    <web-view :src="url" />
  </view>
</template>

<script setup>
/**
 * @description 内嵌网页页 - 外部链接展示
 * @description 通过web-view组件加载外部URL，用于展示用户协议、隐私政策等网页内容
 */
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'

/** 要加载的网页URL */
const url = ref('')

/** 页面加载时从路由参数获取URL并解码 */
onLoad((options) => {
  if (options.url) {
    // URL 白名单校验
    const allowedProtocols = ['http://', 'https://']
    const decodedUrl = decodeURIComponent(options.url)
    if (!allowedProtocols.some(p => decodedUrl.startsWith(p))) {
      uni.showToast({ title: '不支持链接', icon: 'none' })
      setTimeout(() => uni.navigateBack(), 1500)
      return
    }
    url.value = decodedUrl
  }
})
</script>
