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
        <VueOfficePdf :src="arrayBuffer" class="office-component" />
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

<script setup name="TrainStudyPreview">
import { ref, onMounted, onBeforeUnmount, watch, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import VueOfficePdf from '@vue-office/pdf'
import VueOfficeDocx from '@vue-office/docx'
import VueOfficeExcel from '@vue-office/excel'
import '@vue-office/docx/lib/index.css'
import '@vue-office/excel/lib/index.css'
import { getStudyMaterial, startStudy, endStudy } from '@/api/train/study'
import { getToken } from '@/utils/auth'
import { getCachedFile, setCachedFile, buildCacheKey } from '@/utils/materialCache'

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
      arrayBuffer.value = cached.arrayBuffer
      return
    }
  }
  try {
    const response = await fetch(fileUrl.value, {
      headers: { Authorization: 'Bearer ' + getToken() }
    })
    if (!response.ok) {
      throw new Error('HTTP ' + response.status)
    }
    arrayBuffer.value = await response.arrayBuffer()
    // 写入缓存
    if (cacheKey && arrayBuffer.value) {
      await setCachedFile(cacheKey, route.query.materialId, arrayBuffer.value)
    }
  } catch (e) {
    console.error('加载文件二进制失败:', e)
    // 兜底：不带鉴权重试（本地存储通常无需鉴权）
    try {
      const response = await fetch(fileUrl.value)
      arrayBuffer.value = await response.arrayBuffer()
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

function goBack() {
  handleEndStudy()
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

onMounted(() => {
  loadMaterial()
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
    elapsedSeconds.value = 0
    loading.value = true
    stopTimer()
    loadMaterial()
  }
})

// 兜底：组件卸载时结束学习
onBeforeUnmount(() => {
  handleEndStudy()
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
</style>
