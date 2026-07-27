<template>
  <view class="study-container">
    <!-- 加载状态 -->
    <view v-if="loading" class="loading-box">
      <u-loading-icon mode="circle" size="40" color="#3D6DF7"></u-loading-icon>
      <text class="loading-text">{{ loadingText }}</text>
    </view>

    <view v-else-if="!material" class="loading-box">
      <u-icon name="info-circle" size="40" color="#C9CDD4"></u-icon>
      <text class="loading-text">材料不存在或已下架</text>
    </view>

    <!-- 文件预览：通过本地 viewer.html 加载 web-view -->
    <view v-else-if="viewerUrl" class="viewer-wrapper">
      <web-view :src="viewerUrl" class="viewer-webview" @message="onWebViewMessage"></web-view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 学习页 - DRM会话管理
 * @description 所有文件类型统一通过本地 viewer.html 加载 web-view 预览
 * @description 本页负责：会话开始/心跳上报/切屏检测/结束学习
 * @description 注：web-view 全屏覆盖，水印改为依赖 viewer 内部禁用右键/选择/长按实现 DRM
 */
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { onLoad, onShow, onHide, onUnload } from '@dcloudio/uni-app'
import { startStudy, heartbeat, endStudy, getMaterialInfo } from '@/api/train/material'
import config from '@/config'

const BASE_URL = config.baseUrl || ''

const materialId = ref(0)
const material = ref(null)
const viewerUrl = ref('')
const loading = ref(true)
const loadingText = ref('正在加载学习材料...')
const sessionId = ref('')
const elapsedSeconds = ref(0)
const switchCount = ref(0)

let heartbeatTimer = null
let elapsedTimer = null
let isPaused = false
let hasEnded = false

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

onLoad((options) => {
  materialId.value = parseInt(options.materialId) || 0
  initStudy()
})

async function initStudy() {
  if (!materialId.value) {
    loading.value = false
    return
  }
  try {
    loadingText.value = '正在准备学习环境...'

    // 并行执行：获取材料详情 + 创建学习会话（两者互不依赖，materialId 已知）
    const [detailRes, startRes] = await Promise.all([
      getMaterialInfo(materialId.value),
      startStudy(materialId.value)
    ])

    material.value = detailRes.data
    sessionId.value = startRes.sessionId

    // 直接使用后端文件流接口（DRM 临时授权，会话即凭证，无需单独获取 URL）
    const fileType = material.value.fileType
    const fileStreamUrl = `${BASE_URL}/train/studyLog/file/${sessionId.value}`
    // 传递 materialId 和 updateTime 用于 viewer.html 的 IndexedDB 缓存键
    const updateTime = material.value.updateTime || ''
    viewerUrl.value = `/static/office-viewer/viewer.html?type=${fileType}&file=${encodeURIComponent(fileStreamUrl)}&mid=${materialId.value}&ut=${encodeURIComponent(updateTime)}`

    // 启动心跳与计时
    startTimers()
  } catch (e) {
    console.error('[train/detail] 初始化学习失败:', e, 'code=', e && e.code, 'msg=', e && e.msg, 'message=', e && e.message)
    // request.js 已对非200响应调用 toast()，此处仅补充未覆盖的场景
    const errMsg = (e && (e.msg || e.message)) || '加载失败'
    if (!errMsg.includes('timeout') && !errMsg.includes('接口')) {
      uni.showToast({ title: errMsg, icon: 'none' })
    }
  } finally {
    loading.value = false
  }
}

function startTimers() {
  // 心跳定时器：每15秒上报
  heartbeatTimer = setInterval(async () => {
    if (isPaused || !sessionId.value) return
    try {
      await heartbeat(sessionId.value, {
        switchCount: 0,
        pauseCount: 0
      })
    } catch (e) {
      console.warn('心跳失败:', e)
    }
  }, 15000)

  // 计时器：每秒累加（仅用于内部统计，不展示）
  elapsedTimer = setInterval(() => {
    if (!isPaused) {
      elapsedSeconds.value++
    }
  }, 1000)
}

function stopTimers() {
  if (heartbeatTimer) { clearInterval(heartbeatTimer); heartbeatTimer = null }
  if (elapsedTimer) { clearInterval(elapsedTimer); elapsedTimer = null }
}

// 页面可见性：切屏时暂停计时并上报
onShow(() => {
  isPaused = false
})

onHide(() => {
  if (isPaused) return
  isPaused = true
  switchCount.value++
  // 上报切屏
  if (sessionId.value) {
    heartbeat(sessionId.value, { switchCount: 1, pauseCount: 0 }).catch(() => {})
  }
})

async function handleEndStudy() {
  if (hasEnded) return
  hasEnded = true
  stopTimers()
  if (sessionId.value) {
    try {
      await endStudy(sessionId.value, elapsedSeconds.value)
      uni.showToast({ title: '学习已结束', icon: 'success' })
    } catch (e) {
      console.error('结束学习失败:', e)
    }
  }
  setTimeout(() => uni.navigateBack(), 1000)
}

// web-view 消息回调（预留，可扩展 PPT 翻页事件等）
function onWebViewMessage(e) {
}

// 页面卸载时可靠发送结束学习请求
onUnload(() => {
  stopTimers()
  if (!hasEnded && sessionId.value) {
    // 使用 sendBeacon 保证请求发出（不受页面卸载影响）
    const BEACON_URL = `${BASE_URL}/train/studyLog/end`
    const payload = JSON.stringify({
      sessionId: sessionId.value,
      validDuration: elapsedSeconds.value
    })
    const sent = navigator.sendBeacon(BEACON_URL, payload)
  }
})

onUnmounted(() => {
  stopTimers()
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.study-container {
  position: relative;
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.loading-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 20rpx;
}

.loading-text {
  font-size: 26rpx;
  color: #86909C;
}

.viewer-wrapper {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.viewer-webview {
  width: 100%;
  height: 100%;
  border: 0;
}
</style>
