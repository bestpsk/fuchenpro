<template>
  <div class="preview-page">
    <div class="preview-header">
      <div class="header-left">
        <el-button link icon="ArrowLeft" @click="goBack">返回</el-button>
        <el-divider direction="vertical" />
        <span class="material-title">{{ material?.title || '加载中...' }}</span>
        <el-tag v-if="material" size="small" :type="getTypeTagType(material.fileType)" class="type-tag">
          {{ getFileTypeName(material.fileType) }}
        </el-tag>
      </div>
    </div>

    <div class="preview-content" v-loading="loading" element-loading-text="文件加载中...">
      <!-- 图片 -->
      <div v-if="material?.fileType === '1' && fileUrl" class="image-view">
        <img :src="fileUrl" class="content-img" />
      </div>

      <!-- PDF / PPT（PPT 已服务端转 PDF） -->
      <div v-else-if="(material?.fileType === '2' || material?.fileType === '3') && arrayBuffer" class="pdf-view">
        <VueOfficePdf v-if="!pdfError" :src="arrayBuffer" :staticFileUrl="pdfStaticUrl" class="office-component" @error="handlePdfError" />
        <div v-else class="pdf-error-fallback">
          <el-empty description="文档预览失败，可能是文档格式复杂或文件损坏">
            <div style="display: flex; gap: 8px;">
              <el-button type="primary" icon="Refresh" @click="retryLoad">重新加载</el-button>
              <el-button icon="Download" @click="downloadOriginal">下载原文件</el-button>
            </div>
          </el-empty>
        </div>
      </div>

      <!-- Word -->
      <div v-else-if="material?.fileType === '4' && arrayBuffer" class="word-view">
        <VueOfficeDocx :src="arrayBuffer" class="office-component" />
      </div>

      <!-- Excel -->
      <div v-else-if="material?.fileType === '6' && arrayBuffer" class="excel-view">
        <VueOfficeExcel :src="arrayBuffer" class="office-component" />
      </div>

      <!-- 文本 -->
      <div v-else-if="material?.fileType === '5' && textContent" class="text-view">
        <pre class="text-content">{{ textContent }}</pre>
      </div>

      <!-- 不支持 -->
      <el-empty v-else-if="!loading" description="暂不支持此文件类型预览" />
    </div>
  </div>
</template>

<script setup name="TrainPreview">
import { ref, onMounted, onBeforeUnmount, watch, getCurrentInstance, onErrorCaptured } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import VueOfficePdf from '@vue-office/pdf'
import VueOfficeDocx from '@vue-office/docx'
import VueOfficeExcel from '@vue-office/excel'
import '@vue-office/docx/lib/index.css'
import '@vue-office/excel/lib/index.css'
import { getStudyMaterial, startStudy, endStudy } from '@/api/train/study'
import { getToken } from '@/utils/auth'
import { getCachedFile, setCachedFile, clearCachedFile, buildCacheKey } from '@/utils/materialCache'

const { proxy } = getCurrentInstance()
const route = useRoute()
const router = useRouter()

const material = ref(null)
const fileUrl = ref('')
const arrayBuffer = ref(null)
const textContent = ref('')
const loading = ref(true)
const sessionId = ref('')

// 学习计时
const elapsedSeconds = ref(0)
let elapsedTimer = null
let hasEnded = false

const baseUrl = import.meta.env.VITE_APP_BASE_API
// pdfjs 静态资源本地路径（cmaps 已本地化到 public/pdfjs/cmaps，避免依赖 unpkg CDN 国内访问失败导致中文方块）
const pdfStaticUrl = '/pdfjs/'

// PDF 渲染错误状态
const pdfError = ref(false)

/**
 * 校验 ArrayBuffer 是否为有效 PDF（检查 %PDF 魔数）
 * PDF 文件以 "%PDF-" 开头（ASCII: 25 50 44 46 2D）
 */
function isPdfArrayBuffer(buf) {
  if (!buf || buf.byteLength < 5) return false
  const bytes = new Uint8Array(buf.byteLength >= 5 ? buf.slice(0, 5) : buf)
  const magic = String.fromCharCode.apply(null, bytes)
  return magic === '%PDF-'
}

function getFileTypeName(value) {
  const map = { '1': '图片', '2': 'PDF', '3': 'PPT', '4': 'Word', '5': '文本', '6': 'Excel' }
  return map[value] || '未知'
}

function getTypeTagType(value) {
  const map = { '1': 'primary', '2': 'success', '3': 'warning', '4': 'info', '5': '', '6': 'danger' }
  return map[value] || ''
}

// 拼接完整可访问URL
function buildFullUrl(url) {
  if (!url) return ''
  return url.startsWith('http') ? url : baseUrl + url
}

async function loadMaterial() {
  const materialId = route.query.materialId
  if (!materialId) {
    proxy.$modal.msgError('材料ID不能为空')
    loading.value = false
    return
  }

  try {
    const res = await getStudyMaterial(materialId)
    material.value = res.data

    if (!material.value.fileUrl) {
      proxy.$modal.msgError('材料文件地址为空')
      loading.value = false
      return
    }

    const fileType = material.value.fileType

    // 图片：直接用原始 URL（静态文件可访问，无需 DRM）
    if (fileType === '1') {
      fileUrl.value = buildFullUrl(material.value.fileUrl)
      loading.value = false
      return
    }

    // 其他类型（PDF/PPT/Word/Excel/文本）：走 DRM 文件流接口，触发服务端 PPT→PDF 转换
    const startRes = await startStudy(materialId)
    sessionId.value = startRes.sessionId
    fileUrl.value = baseUrl + '/train/studyLog/file/' + sessionId.value

    // 构造缓存键：materialId + updateTime（材料更新后自动失效）
    const cacheKey = buildCacheKey(materialId, material.value.updateTime)

    // 启动学习计时
    startTimer()

    // 文本：fetch文本内容
    if (fileType === '5') {
      await loadTextContent(cacheKey)
      return
    }

    // PDF/PPT/Word/Excel：fetch ArrayBuffer（PPT 已服务端转 PDF）
    if (['2', '3', '4', '6'].includes(fileType)) {
      await loadArrayBuffer(cacheKey)
    }
  } catch (e) {
    console.error('加载材料失败:', e)
    proxy.$modal.msgError('加载失败: ' + (e.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 加载二进制数据（带鉴权，支持缓存）
async function loadArrayBuffer(cacheKey) {
  // 先查缓存
  if (cacheKey) {
    const cached = await getCachedFile(cacheKey)
    if (cached && cached.arrayBuffer) {
      // 校验缓存数据是否为有效 PDF/PPT（仅对 fileType 2/3 校验，防止损坏数据反复导致组件崩溃）
      if (material.value?.fileType === '2' || material.value?.fileType === '3') {
        if (!isPdfArrayBuffer(cached.arrayBuffer)) {
          console.warn('[preview] 缓存数据非有效 PDF，清除损坏缓存:', cacheKey)
          await clearCachedFile(cacheKey)
        } else {
          arrayBuffer.value = cached.arrayBuffer
          return
        }
      } else {
        arrayBuffer.value = cached.arrayBuffer
        return
      }
    }
  }
  try {
    const response = await fetch(fileUrl.value, {
      headers: { Authorization: 'Bearer ' + getToken() }
    })
    if (!response.ok) {
      throw new Error('HTTP ' + response.status)
    }
    const buf = await response.arrayBuffer()
    // 校验响应是否为有效 PDF（PPT 已服务端转 PDF，fileType 2/3 均应为 PDF）
    if (material.value?.fileType === '2' || material.value?.fileType === '3') {
      if (!isPdfArrayBuffer(buf)) {
        throw new Error('服务端返回的数据不是有效 PDF（可能是 PPT 转换失败）')
      }
    }
    arrayBuffer.value = buf
    // 写入缓存
    if (cacheKey && arrayBuffer.value) {
      await setCachedFile(cacheKey, route.query.materialId, arrayBuffer.value)
    }
  } catch (e) {
    console.error('加载文件二进制失败:', e)
    // 兜底：不带鉴权重试（本地存储通常无需鉴权）
    try {
      const response = await fetch(fileUrl.value)
      const buf = await response.arrayBuffer()
      // 兜底响应同样需要校验
      if (material.value?.fileType === '2' || material.value?.fileType === '3') {
        if (!isPdfArrayBuffer(buf)) {
          throw new Error('服务端兜底返回的数据不是有效 PDF')
        }
      }
      arrayBuffer.value = buf
      if (cacheKey && arrayBuffer.value) {
        await setCachedFile(cacheKey, route.query.materialId, arrayBuffer.value)
      }
    } catch (e2) {
      throw new Error('文件加载失败: ' + e2.message)
    }
  }
}

async function loadTextContent(cacheKey) {
  // 先查缓存
  if (cacheKey) {
    const cached = await getCachedFile(cacheKey)
    if (cached && cached.arrayBuffer) {
      textContent.value = new TextDecoder().decode(cached.arrayBuffer)
      return
    }
  }
  try {
    const response = await fetch(fileUrl.value, {
      headers: { Authorization: 'Bearer ' + getToken() }
    })
    textContent.value = await response.text()
    // 写入缓存
    if (cacheKey && textContent.value) {
      const buf = new TextEncoder().encode(textContent.value).buffer
      await setCachedFile(cacheKey, route.query.materialId, buf)
    }
  } catch (e) {
    const response = await fetch(fileUrl.value)
    textContent.value = await response.text()
    if (cacheKey && textContent.value) {
      const buf = new TextEncoder().encode(textContent.value).buffer
      await setCachedFile(cacheKey, route.query.materialId, buf)
    }
  }
}

async function goBack() {
  await handleEndStudy()
  router.back()
}

// 学习计时器
function startTimer() {
  elapsedTimer = setInterval(() => {
    elapsedSeconds.value++
  }, 1000)
}

function stopTimer() {
  if (elapsedTimer) {
    clearInterval(elapsedTimer)
    elapsedTimer = null
  }
}

// 结束学习，记录有效时长
async function handleEndStudy() {
  if (hasEnded || !sessionId.value) return
  hasEnded = true
  stopTimer()
  try {
    await endStudy(sessionId.value, elapsedSeconds.value)
  } catch (e) {
    console.error('结束学习失败:', e)
  }
}

// beforeunload 事件处理：关闭浏览器标签页时发送结束学习请求
function onBeforeUnload() {
  if (hasEnded || !sessionId.value) return
  hasEnded = true
  stopTimer()
  const BEACON_URL = baseUrl + '/train/studyLog/end'
  const payload = JSON.stringify({
    sessionId: sessionId.value,
    validDuration: elapsedSeconds.value
  })
  // 优先 fetch keepalive（比 sendBeacon 更可靠，支持 application/json，避免 net::ERR_ABORTED）
  try {
    fetch(BEACON_URL, {
      method: 'POST',
      body: payload,
      keepalive: true,
      headers: { 'Content-Type': 'application/json' }
    }).catch(() => {})
  } catch (e) {
    // 降级 sendBeacon
    if (typeof navigator !== 'undefined' && navigator.sendBeacon) {
      try { navigator.sendBeacon(BEACON_URL, payload) } catch (e2) {}
    }
  }
}

// visibilitychange 事件处理：切换标签页时暂停/恢复计时器
function onVisibilityChange() {
  if (document.hidden) {
    stopTimer()
  } else {
    if (!hasEnded && sessionId.value && !elapsedTimer) {
      startTimer()
    }
  }
}

// PDF 渲染错误处理
function handlePdfError(err) {
  console.error('[preview] VueOfficePdf 渲染错误:', err)
  pdfError.value = true
}

// 组件级错误捕获（错误边界）：防止 VueOfficePdf 崩溃导致整个路由组件白屏
onErrorCaptured((err, instance, info) => {
  console.error('[preview] 组件错误捕获:', err, info)
  // 仅在 PDF/PPT 类型时触发 fallback
  if (material.value?.fileType === '2' || material.value?.fileType === '3') {
    pdfError.value = true
  }
  return false  // 阻止错误继续向上传播
})

// 下载原文件（使用 DRM 文件流接口）
function downloadOriginal() {
  if (!fileUrl.value) return
  const a = document.createElement('a')
  a.href = fileUrl.value
  a.download = material.value?.title || 'document'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}

// 重新加载：清除损坏缓存 + 重置错误状态 + 重新加载
async function retryLoad() {
  pdfError.value = false
  arrayBuffer.value = null
  loading.value = true
  // 清除可能损坏的缓存
  const cacheKey = buildCacheKey(route.query.materialId, material.value?.updateTime)
  await clearCachedFile(cacheKey)
  try {
    await loadArrayBuffer(cacheKey)
  } catch (e) {
    console.error('[preview] 重新加载失败:', e)
    proxy.$modal.msgError('重新加载失败: ' + (e.message || '未知错误'))
    pdfError.value = true
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadMaterial()
  window.addEventListener('beforeunload', onBeforeUnload)
  document.addEventListener('visibilitychange', onVisibilityChange)
})

// 监听路由参数变化（组件复用时 onMounted 不触发，需手动监听）
watch(() => route.query.materialId, (newId, oldId) => {
  if (newId && newId !== oldId) {
    // 重置状态
    material.value = null
    arrayBuffer.value = null
    textContent.value = ''
    fileUrl.value = ''
    sessionId.value = ''
    hasEnded = false
    pdfError.value = false  // 重置错误状态
    elapsedSeconds.value = 0
    loading.value = true
    stopTimer()
    loadMaterial()
  }
})

// 兜底：组件卸载时结束学习
onBeforeUnmount(() => {
  handleEndStudy()
  window.removeEventListener('beforeunload', onBeforeUnload)
  document.removeEventListener('visibilitychange', onVisibilityChange)
})
</script>

<style scoped>
.preview-page {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 84px);
  background: #f5f7fa;
}

.preview-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 4px;
}

.material-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin: 0 8px;
}

.type-tag {
  margin-left: 8px;
}

.preview-content {
  flex: 1;
  overflow: auto;
  padding: 20px;
  display: flex;
  justify-content: center;
}

.image-view {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  width: 100%;
}

.content-img {
  max-width: 100%;
  border-radius: 4px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.pdf-view,
.word-view,
.excel-view {
  width: 100%;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* 中文字体回退：@vue-office/docx 只应用 ascii 字体，需兜底确保中文用系统字体渲染，避免方块乱码 */
.word-view :deep(.docx-wrapper),
.word-view :deep(.docx-wrapper *) {
  font-family: "Microsoft YaHei", "微软雅黑", "PingFang SC", "Hiragino Sans GB",
               "SimSun", "宋体", Calibri, Arial, sans-serif !important;
}

.office-component {
  min-height: 600px;
}

.text-view {
  width: 100%;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  padding: 20px;
}

.text-content {
  white-space: pre-wrap;
  word-break: break-word;
  font-family: inherit;
  font-size: 14px;
  line-height: 1.6;
  color: #303133;
  margin: 0;
}

.pdf-error-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 400px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}
</style>
