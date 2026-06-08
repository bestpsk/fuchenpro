<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-item">
        <text class="form-label"><text class="required">*</text>公告标题</text>
        <input class="form-input" v-model="form.noticeTitle" placeholder="请输入公告标题" />
      </view>
      <view class="form-item">
        <text class="form-label"><text class="required">*</text>公告类型</text>
        <view class="radio-group">
          <view
            v-for="item in typeOptions"
            :key="item.dictValue"
            class="radio-item"
            :class="{ active: form.noticeType === item.dictValue }"
            @click="form.noticeType = item.dictValue"
          >
            <view class="radio-dot"><view v-if="form.noticeType === item.dictValue" class="radio-dot-inner"></view></view>
            <text class="radio-text">{{ item.dictLabel }}</text>
          </view>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">状态</text>
        <view class="radio-group">
          <view
            v-for="item in statusOptions"
            :key="item.dictValue"
            class="radio-item"
            :class="{ active: form.status === item.dictValue }"
            @click="form.status = item.dictValue"
          >
            <view class="radio-dot"><view v-if="form.status === item.dictValue" class="radio-dot-inner"></view></view>
            <text class="radio-text">{{ item.dictLabel }}</text>
          </view>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">内容</text>

        <!-- 富文本编辑器工具栏 -->
        <view class="editor-toolbar">
          <view class="toolbar-row">
            <view class="toolbar-btn" :class="{ active: formats.bold }" @click="execFormat('bold')">
              <text class="toolbar-text" style="font-weight:bold">B</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.italic }" @click="execFormat('italic')">
              <text class="toolbar-text" style="font-style:italic">I</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.underline }" @click="execFormat('underline')">
              <text class="toolbar-text" style="text-decoration:underline">U</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.strike }" @click="execFormat('strike')">
              <text class="toolbar-text" style="text-decoration:line-through">S</text>
            </view>
            <view class="toolbar-divider"></view>
            <view class="toolbar-btn" @click="execFormat('header', 'H1')">
              <text class="toolbar-text">H1</text>
            </view>
            <view class="toolbar-btn" @click="execFormat('header', 'H2')">
              <text class="toolbar-text">H2</text>
            </view>
            <view class="toolbar-btn" @click="execFormat('header', 'p')">
              <text class="toolbar-text">P</text>
            </view>
            <view class="toolbar-divider"></view>
            <view class="toolbar-btn" :class="{ active: formats.list === 'ordered' }" @click="execFormat('list', 'ordered')">
              <text class="toolbar-text">1.</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.list === 'bullet' }" @click="execFormat('list', 'bullet')">
              <text class="toolbar-text">•</text>
            </view>
          </view>
          <view class="toolbar-row">
            <view class="toolbar-btn" :class="{ active: formats.align === 'left' }" @click="execFormat('align', 'left')">
              <text class="toolbar-text">≡</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.align === 'center' }" @click="execFormat('align', 'center')">
              <text class="toolbar-text">≣</text>
            </view>
            <view class="toolbar-btn" :class="{ active: formats.align === 'right' }" @click="execFormat('align', 'right')">
              <text class="toolbar-text">≡</text>
            </view>
            <view class="toolbar-divider"></view>
            <view class="toolbar-btn" @click="execFormat('color')">
              <text class="toolbar-text">🎨</text>
            </view>
            <view class="toolbar-btn" @click="execFormat('backgroundColor')">
              <text class="toolbar-text">🖌️</text>
            </view>
            <view class="toolbar-divider"></view>
            <view class="toolbar-btn" @click="chooseAndUploadImage">
              <text class="toolbar-text">🖼️</text>
            </view>
            <view class="toolbar-btn" @click="chooseAndUploadVideo">
              <text class="toolbar-text">🎬</text>
            </view>
            <view class="toolbar-divider"></view>
            <view class="toolbar-btn" @click="execFormat('undo')">
              <text class="toolbar-text">↶</text>
            </view>
            <view class="toolbar-btn" @click="execFormat('redo')">
              <text class="toolbar-text">↷</text>
            </view>
            <view class="toolbar-btn" @click="execFormat('removeFormat')">
              <text class="toolbar-text">⌫</text>
            </view>
          </view>
        </view>

        <!-- uni-app 官方 editor 组件（小程序内置，跨端支持） -->
        <editor
          id="noticeEditor"
          class="form-editor"
          :read-only="false"
          :placeholder="'请输入公告内容，支持文字、图片和视频'"
          show-img-size
          show-img-toolbar
          show-img-resize
          @ready="onEditorReady"
          @input="onEditorInput"
          @statuschange="onStatusChange"
        ></editor>
        <text class="char-count">{{ contentLength }} 字</text>
      </view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
      <u-button type="primary" text="提交" @click="submitForm" :loading="submitting" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { getNotice, addNotice, updateNotice } from '@/api/system/notice'
import { getDicts } from '@/api/system/dictData'
import upload from '@/utils/upload'

const submitting = ref(false)
const mode = ref('add')
const noticeId = ref('')
const editorCtx = ref(null)
const contentLength = ref(0)

const form = reactive({
  noticeTitle: '',
  noticeType: '1',
  status: '0',
  noticeContent: ''
})

const typeOptions = ref([])
const statusOptions = ref([])

const formats = reactive({
  bold: false,
  italic: false,
  underline: false,
  strike: false,
  list: '',
  align: ''
})

async function loadDicts() {
  try {
    const [typeRes, statusRes] = await Promise.all([
      getDicts('sys_notice_type'),
      getDicts('sys_notice_status')
    ])
    typeOptions.value = typeRes.data || []
    statusOptions.value = statusRes.data || []
    if (typeOptions.value.length > 0 && !form.noticeType) {
      form.noticeType = typeOptions.value[0].dictValue
    }
    if (statusOptions.value.length > 0 && !form.status) {
      form.status = statusOptions.value[0].dictValue
    }
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

function onEditorReady() {
  // #ifdef MP-WEIXIN
  try {
    const query = uni.createSelectorQuery()
    query.select('#noticeEditor').context((res) => {
      editorCtx.value = res.context
      if (form.noticeContent) {
        setEditorContent(form.noticeContent)
      }
    }).exec()
  } catch (e) {
    console.error('初始化 editor 上下文失败', e)
  }
  // #endif

  // #ifdef H5
  // H5 端 <editor> 是基于 contenteditable 的 DOM 元素
  // 自实现一个轻量级 editorCtx，对外提供与小程序一致的 API
  nextTick(() => {
    editorCtx.value = createH5EditorCtx()
    if (form.noticeContent) {
      setEditorContent(form.noticeContent)
    }
  })
  // #endif
}

// #ifdef H5
/**
 * H5 端 editor 上下文适配层
 * 内部用 document.execCommand + DOM 操作实现，
 * 对外暴露 format / setContents / insertImage 三个核心方法，与小程序端 EditorContext 接口对齐
 */
function createH5EditorCtx() {
  const root = document.querySelector('.form-editor')
  if (!root) {
    console.error('未找到 .form-editor 元素')
    return null
  }
  // 确保编辑器可编辑
  root.setAttribute('contenteditable', 'true')

  // 同步当前内容到 form（用于 input 事件无法触发的场景）
  function sync() {
    form.noticeContent = root.innerHTML
    contentLength.value = (root.innerText || '').length
  }

  // 监听原生 input 事件
  root.addEventListener('input', sync)
  root.addEventListener('blur', sync)

  return {
    format(name, value) {
      // 先聚焦，让光标回到编辑器
      root.focus()
      try {
        switch (name) {
          case 'bold':
            document.execCommand('bold')
            break
          case 'italic':
            document.execCommand('italic')
            break
          case 'underline':
            document.execCommand('underline')
            break
          case 'strike':
            document.execCommand('strikeThrough')
            break
          case 'header':
            document.execCommand('formatBlock', false,
              value === 'H1' ? 'h1' : value === 'H2' ? 'h2' : 'p')
            break
          case 'list':
            document.execCommand(value === 'ordered' ? 'insertOrderedList' : 'insertUnorderedList')
            break
          case 'align':
            document.execCommand('justify' + (
              value === 'left' ? 'Left' :
              value === 'center' ? 'Center' : 'Right'
            ))
            break
          case 'color':
            document.execCommand('foreColor', false, '#3D6DF7')
            break
          case 'backgroundColor':
            document.execCommand('hiliteColor', false, '#FFF7E8')
            break
          case 'undo':
            document.execCommand('undo')
            break
          case 'redo':
            document.execCommand('redo')
            break
          case 'removeFormat':
            document.execCommand('removeFormat')
            break
        }
      } catch (e) {
        console.error('format 调用失败', e)
      }
      sync()
    },
    setContents({ html, success, fail }) {
      try {
        root.innerHTML = html || ''
        sync()
        success && success()
      } catch (e) {
        console.error('setContents 失败', e)
        fail && fail(e)
      }
    },
    insertImage({ src, width, alt, success, fail }) {
      try {
        const img = document.createElement('img')
        img.src = src
        img.style.maxWidth = '100%'
        img.style.height = 'auto'
        if (width) img.style.width = width
        img.alt = alt || ''

        // 插入到当前光标位置
        root.focus()
        const sel = window.getSelection()
        if (sel && sel.rangeCount > 0) {
          const range = sel.getRangeAt(0)
          range.deleteContents()
          range.insertNode(img)
          // 在图片后插入换行，便于后续输入
          const br = document.createElement('br')
          img.parentNode.insertBefore(br, img.nextSibling)
          range.setStartAfter(br)
          range.setEndAfter(br)
          sel.removeAllRanges()
          sel.addRange(range)
        } else {
          root.appendChild(img)
          root.appendChild(document.createElement('br'))
        }
        sync()
        success && success()
      } catch (e) {
        console.error('insertImage 失败', e)
        fail && fail(e)
      }
    }
  }
}
// #endif

function setEditorContent(html) {
  if (!editorCtx.value) return
  try {
    editorCtx.value.setContents({
      html: html,
      success: () => {},
      fail: (e) => { console.error('设置内容失败', e) }
    })
  } catch (e) {
    console.error('setContents 调用失败', e)
  }
}

function onEditorInput(e) {
  // e.detail.html 富文本 HTML
  // e.detail.text 纯文本
  form.noticeContent = e.detail.html || ''
  contentLength.value = (e.detail.text || '').length
}

function onStatusChange(e) {
  // 同步工具栏状态
  const detail = e.detail || {}
  formats.bold = !!detail.bold
  formats.italic = !!detail.italic
  formats.underline = !!detail.underline
  formats.strike = !!detail.strike
  formats.list = detail.list || ''
  formats.align = detail.align || ''
}

function execFormat(name, value) {
  if (!editorCtx.value) {
    uni.showToast({ title: '编辑器未就绪', icon: 'none' })
    return
  }
  try {
    editorCtx.value.format(name, value)
  } catch (e) {
    console.error('format 调用失败', e)
  }
}

function chooseAndUploadImage() {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      const filePath = res.tempFilePaths[0]
      if (filePath) {
        uploadFileAndInsert(filePath, 'image')
      }
    }
  })
}

function chooseAndUploadVideo() {
  uni.chooseVideo({
    sourceType: ['album', 'camera'],
    maxDuration: 60,
    success: (res) => {
      const filePath = res.tempFilePath
      if (filePath) {
        uploadFileAndInsert(filePath, 'video')
      }
    }
  })
}

async function uploadFileAndInsert(filePath, type) {
  uni.showLoading({ title: '上传中...' })
  try {
    const data = await upload({ url: '/common/upload', name: 'file', filePath })
    const url = data?.fileName || data?.url || data?.data?.fileName || data?.data?.url
    if (!url) {
      uni.hideLoading()
      uni.showToast({ title: '上传失败', icon: 'none' })
      return
    }
    uni.hideLoading()
    if (!editorCtx.value) {
      uni.showToast({ title: '编辑器未就绪', icon: 'none' })
      return
    }
    if (type === 'image') {
      editorCtx.value.insertImage({
        src: url,
        width: '100%',
        alt: '图片',
        success: () => {},
        fail: (e) => { console.error('插入图片失败', e) }
      })
    } else if (type === 'video') {
      // 视频用 <video> 标签插入到内容末尾（H5 端能直接渲染，小程序端走 rich-text）
      const currentHtml = form.noticeContent || ''
      const videoHtml = `<p><video src="${url}" controls style="max-width:100%;width:100%"></video></p>`
      editorCtx.value.setContents({
        html: currentHtml + videoHtml,
        success: () => {},
        fail: (e) => { console.error('插入视频失败', e) }
      })
    }
  } catch (e) {
    uni.hideLoading()
    console.error('上传失败', e)
    uni.showToast({ title: '上传失败', icon: 'none' })
  }
}

async function loadDetail(id) {
  try {
    const res = await getNotice(id)
    const data = res.data || {}
    form.noticeTitle = data.noticeTitle || ''
    form.noticeType = data.noticeType || '1'
    form.status = data.status || '0'
    form.noticeContent = data.noticeContent || ''
  } catch (e) {
    console.error('获取公告详情失败:', e)
  }
}

function goBack() {
  uni.navigateBack({ fail: () => uni.redirectTo({ url: '/pages/system/notice/index' }) })
}

async function submitForm() {
  if (!form.noticeTitle.trim()) {
    uni.showToast({ title: '请输入公告标题', icon: 'none' })
    return
  }
  if (!form.noticeType) {
    uni.showToast({ title: '请选择公告类型', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    if (mode.value === 'edit') {
      await updateNotice({ ...form, noticeId: noticeId.value })
    } else {
      await addNotice({ ...form })
    }
    uni.showToast({ title: mode.value === 'edit' ? '修改成功' : '新增成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadDicts()
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const options = page.options || page.$page?.options || {}
  mode.value = options.mode || 'add'
  if (options.id) {
    noticeId.value = options.id
    loadDetail(options.id)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; }
.form-container { display: flex; flex-direction: column; height: 100%; padding: 24rpx; padding-bottom: 160rpx; }

.form-section { flex: 1; background: #fff; border-radius: 16rpx; padding: 32rpx; }
.form-item { margin-bottom: 32rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; display: block; }
.required { color: #F53F3F; margin-right: 4rpx; }
.form-input { width: 100%; height: 80rpx; background: #F5F7FA; border-radius: 12rpx; padding: 0 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; }

.radio-group { display: flex; gap: 32rpx; flex-wrap: wrap; }
.radio-item { display: flex; align-items: center; gap: 12rpx; }
.radio-item.active .radio-text { color: #3D6DF7; }
.radio-dot { width: 32rpx; height: 32rpx; border-radius: 50%; border: 4rpx solid #C9CDD4; display: flex; align-items: center; justify-content: center; transition: border-color 0.2s;
  .radio-item.active & { border-color: #3D6DF7; }
}
.radio-dot-inner { width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
.radio-text { font-size: 28rpx; color: #4E5969; }

/* 富文本编辑器工具栏 */
.editor-toolbar {
  background: #F5F7FA; border-radius: 12rpx 12rpx 0 0; padding: 12rpx 8rpx;
  border: 2rpx solid #E5E6EB; border-bottom: none;
}
.toolbar-row {
  display: flex; flex-wrap: wrap; align-items: center; gap: 4rpx; margin-bottom: 6rpx;
  &:last-child { margin-bottom: 0; }
}
.toolbar-btn {
  min-width: 56rpx; height: 56rpx; padding: 0 12rpx; display: flex; align-items: center; justify-content: center;
  background: #fff; border-radius: 8rpx; transition: all 0.2s;
  &.active { background: #E8F0FE; color: #3D6DF7; }
  &:active { background: #E5E6EB; }
}
.toolbar-text { font-size: 26rpx; color: #1D2129; font-weight: 500; }
.toolbar-divider { width: 2rpx; height: 32rpx; background: #E5E6EB; margin: 0 8rpx; }

.form-editor {
  width: 100%; min-height: 360rpx; max-height: 800rpx; background: #fff;
  border: 2rpx solid #E5E6EB; border-top: none; border-radius: 0 0 12rpx 12rpx;
  padding: 16rpx 20rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box;
}
.char-count { display: block; text-align: right; font-size: 24rpx; color: #C9CDD4; margin-top: 8rpx; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100; }
</style>
