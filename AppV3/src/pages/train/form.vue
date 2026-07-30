<template>
  <view class="form-container">
    <scroll-view scroll-y class="form-scroll">
      <view class="form-section">
        <view class="form-item">
          <text class="form-label"><text class="required">*</text>材料标题</text>
          <input
            class="form-input"
            type="text"
            v-model="form.title"
            placeholder="请输入材料标题"
            placeholder-class="form-placeholder"
          />
        </view>

        <view class="form-item" @click="openCategoryPicker">
          <text class="form-label"><text class="required">*</text>材料分类</text>
          <view class="form-picker">
            <text :class="['picker-text', form.category ? 'active' : '']">
              {{ getCategoryName(form.category) || '请选择分类' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-item" @click="openFileTypePicker">
          <text class="form-label"><text class="required">*</text>文件类型</text>
          <view class="form-picker">
            <text :class="['picker-text', form.fileType ? 'active' : '']">
              {{ getFileTypeName(form.fileType) || '请选择文件类型' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-item">
          <text class="form-label"><text class="required">*</text>材料文件</text>
          <view class="upload-file-wrap">
            <view v-if="form.fileUrl" class="file-preview">
              <u-icon name="file-text" size="40" color="#3D6DF7"></u-icon>
              <text class="file-name">{{ fileName }}</text>
              <view class="file-change" @click="chooseMaterialFile">更换</view>
            </view>
            <view v-else class="upload-add-box" @click="chooseMaterialFile">
              <u-icon name="plus" size="32" color="#86909C"></u-icon>
              <text class="upload-tip">点击上传材料文件</text>
            </view>
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">封面图</text>
          <view class="upload-image-wrap">
            <view v-if="form.coverUrl" class="cover-preview">
              <image :src="getFullUrl(form.coverUrl)" mode="aspectFill" class="cover-img" />
              <view class="cover-delete" @click="removeCover">
                <u-icon name="close" size="10" color="#fff"></u-icon>
              </view>
            </view>
            <view v-else class="upload-add-box" @click="chooseCover">
              <u-icon name="plus" size="32" color="#86909C"></u-icon>
              <text class="upload-tip">点击上传封面</text>
            </view>
          </view>
        </view>

        <view class="form-row">
          <view class="form-item half">
            <text class="form-label">建议时长(秒)</text>
            <input
              class="form-input"
              type="number"
              v-model.number="form.studyDuration"
              placeholder="0"
              placeholder-class="form-placeholder"
            />
          </view>
          <view class="form-item half">
            <text class="form-label">排序</text>
            <input
              class="form-input"
              type="number"
              v-model.number="form.sort"
              placeholder="0"
              placeholder-class="form-placeholder"
            />
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">状态</text>
          <view class="radio-group">
            <view
              v-for="item in statusOptions"
              :key="item.value"
              class="radio-item"
              :class="{ active: form.status === item.value }"
              @click="form.status = item.value"
            >
              <view class="radio-dot"><view v-if="form.status === item.value" class="radio-dot-inner"></view></view>
              <text class="radio-text">{{ item.label }}</text>
            </view>
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">材料简介</text>
          <textarea
            class="form-textarea"
            v-model="form.description"
            placeholder="请输入材料简介"
            placeholder-class="form-placeholder"
            :maxlength="500"
            auto-height
          />
        </view>
      </view>
    </scroll-view>

    <view class="form-footer">
      <view class="btn-cancel" @click="goBack">
        <text>取消</text>
      </view>
      <view class="btn-submit" :class="{ loading: submitting }" @click="submitForm">
        <text>{{ submitting ? '提交中...' : '保存' }}</text>
      </view>
    </view>

    <u-picker
      :show="showCategoryPicker"
      :columns="[categoryColumns]"
      keyName="label"
      title="选择材料分类"
      @confirm="onCategoryConfirm"
      @cancel="showCategoryPicker = false"
      @close="showCategoryPicker = false"
    ></u-picker>

    <u-picker
      :show="showFileTypePicker"
      :columns="[fileTypeColumns]"
      keyName="label"
      title="选择文件类型"
      @confirm="onFileTypeConfirm"
      @cancel="showFileTypePicker = false"
      @close="showFileTypePicker = false"
    ></u-picker>
  </view>
</template>

<script setup>
/**
 * @description 学习材料新增/编辑页
 * @description 支持新增和修改学习材料，含材料文件、封面图上传
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getMaterial, addMaterial, updateMaterial } from '@/api/train/material'
import { getDicts } from '@/api/system/dictData'
import upload from '@/utils/upload'
import config from '@/config'

const BASE_URL = config.baseUrl || ''

const mode = ref('add')
const materialId = ref(null)
const submitting = ref(false)
const showCategoryPicker = ref(false)
const showFileTypePicker = ref(false)
const categoryOptions = ref([])
const fileTypeOptions = ref([])
const statusOptions = ref([])

const form = reactive({
  title: '',
  category: '',
  fileType: '',
  fileUrl: '',
  fileSize: 0,
  coverUrl: '',
  studyDuration: 0,
  sort: 0,
  status: '0',
  description: ''
})

const categoryColumns = computed(() => categoryOptions.value)
const fileTypeColumns = computed(() => fileTypeOptions.value)

const fileName = computed(() => {
  if (!form.fileUrl) return ''
  return form.fileUrl.split('/').pop() || form.fileUrl
})

function getFullUrl(url) {
  if (!url) return ''
  return url.startsWith('http') ? url : BASE_URL + url
}

function getCategoryName(value) {
  const item = categoryOptions.value.find(c => c.value === value)
  return item ? item.label : ''
}

function getFileTypeName(value) {
  const item = fileTypeOptions.value.find(c => c.value === value)
  return item ? item.label : ''
}

function openCategoryPicker() {
  showCategoryPicker.value = true
}

function openFileTypePicker() {
  showFileTypePicker.value = true
}

function onCategoryConfirm(e) {
  const item = e.value[0]
  if (item) form.category = item.value
  showCategoryPicker.value = false
}

function onFileTypeConfirm(e) {
  const item = e.value[0]
  if (item) form.fileType = item.value
  showFileTypePicker.value = false
}

function chooseMaterialFile() {
  // #ifdef H5 || APP-PLUS
  if (typeof uni.chooseFile === 'function') {
    uni.chooseFile({
      count: 1,
      type: 'all',
      extension: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      success: (res) => handleUploadFile(res.tempFilePaths[0] || res.tempFiles[0]?.path),
      fail: (err) => {
        if (err && err.errMsg && !err.errMsg.includes('cancel')) {
          uni.showToast({ title: '选择文件失败', icon: 'none' })
        }
      }
    })
    return
  }
  // #endif

  // #ifdef MP-WEIXIN
  if (typeof uni.chooseMessageFile === 'function') {
    uni.chooseMessageFile({
      count: 1,
      type: 'file',
      extension: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      success: (res) => handleUploadFile(res.tempFiles[0]?.path),
      fail: () => {}
    })
    return
  }
  // #endif

  // 兜底：选择图片
  uni.chooseImage({
    count: 1,
    success: (res) => handleUploadFile(res.tempFilePaths[0])
  })
}

async function handleUploadFile(filePath) {
  if (!filePath) return
  uni.showLoading({ title: '上传中...', mask: true })
  try {
    const res = await upload({ url: '/common/upload', filePath, name: 'file' })
    if (res.code === 200) {
      form.fileUrl = res.url || res.fileName || ''
      form.fileSize = res.fileSize || 0
      uni.showToast({ title: '上传成功', icon: 'success' })
    } else {
      uni.showToast({ title: res.msg || '上传失败', icon: 'none' })
    }
  } catch (e) {
    console.error('上传材料文件失败:', e)
    uni.showToast({ title: '上传失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function chooseCover() {
  uni.chooseImage({
    count: 1,
    success: (res) => handleUploadCover(res.tempFilePaths[0])
  })
}

async function handleUploadCover(filePath) {
  if (!filePath) return
  uni.showLoading({ title: '上传中...', mask: true })
  try {
    const res = await upload({ url: '/common/upload', filePath, name: 'file' })
    if (res.code === 200) {
      form.coverUrl = res.url || res.fileName || ''
      uni.showToast({ title: '上传成功', icon: 'success' })
    } else {
      uni.showToast({ title: res.msg || '上传失败', icon: 'none' })
    }
  } catch (e) {
    console.error('上传封面失败:', e)
    uni.showToast({ title: '上传失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function removeCover() {
  form.coverUrl = ''
}

function goBack() {
  uni.navigateBack()
}

async function loadMaterialInfo() {
  if (!materialId.value) return
  uni.showLoading({ title: '加载中...', mask: true })
  try {
    const res = await getMaterial(materialId.value)
    const data = res.data || {}
    Object.assign(form, {
      title: data.title || '',
      category: data.category || '',
      fileType: data.fileType || '',
      fileUrl: data.fileUrl || '',
      fileSize: data.fileSize || 0,
      coverUrl: data.coverUrl || '',
      studyDuration: data.studyDuration || 0,
      sort: data.sort || 0,
      status: String(data.status ?? '0'),
      description: data.description || ''
    })
  } catch (e) {
    console.error('加载材料详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function submitForm() {
  if (!form.title.trim()) {
    uni.showToast({ title: '请输入材料标题', icon: 'none' })
    return
  }
  if (!form.category) {
    uni.showToast({ title: '请选择材料分类', icon: 'none' })
    return
  }
  if (!form.fileType) {
    uni.showToast({ title: '请选择文件类型', icon: 'none' })
    return
  }
  if (!form.fileUrl) {
    uni.showToast({ title: '请上传材料文件', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    const payload = {
      title: form.title.trim(),
      category: form.category,
      fileType: form.fileType,
      fileUrl: form.fileUrl,
      fileSize: Number(form.fileSize) || 0,
      coverUrl: form.coverUrl || '',
      studyDuration: Number(form.studyDuration) || 0,
      sort: Number(form.sort) || 0,
      status: form.status,
      description: form.description || ''
    }

    if (mode.value === 'edit') {
      payload.materialId = materialId.value
      await updateMaterial(payload)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addMaterial(payload)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交学习材料失败:', e)
    uni.showToast({ title: e?.msg || e?.message || '操作失败', icon: 'none', duration: 2000 })
  } finally {
    submitting.value = false
  }
}

onLoad((options) => {
  mode.value = options.mode === 'edit' ? 'edit' : 'add'
  materialId.value = parseInt(options.materialId) || null
})

onMounted(async () => {
  try {
    const [catRes, typeRes, statusRes] = await Promise.all([
      getDicts('biz_train_material_category'),
      getDicts('biz_train_material_file_type'),
      getDicts('sys_normal_disable')
    ])
    categoryOptions.value = (catRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    fileTypeOptions.value = (typeRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    statusOptions.value = (statusRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.warn('加载字典失败', e)
  }

  if (mode.value === 'edit' && materialId.value) {
    await loadMaterialInfo()
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.form-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.form-scroll {
  flex: 1;
  overflow: hidden;
}

.form-section {
  padding: 20rpx 24rpx;
}

.form-item {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;

  .form-label {
    display: block;
    font-size: 28rpx;
    color: #1D2129;
    font-weight: 500;
    margin-bottom: 16rpx;

    .required {
      color: #F53F3F;
      margin-right: 4rpx;
    }
  }

  .form-input {
    width: 100%;
    height: 72rpx;
    font-size: 28rpx;
    color: #1D2129;
    min-width: 0;
  }

  .form-picker {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 72rpx;

    .picker-text {
      font-size: 28rpx;
      color: #86909C;

      &.active {
        color: #1D2129;
      }
    }
  }

  .form-textarea {
    width: 100%;
    min-height: 160rpx;
    font-size: 28rpx;
    color: #1D2129;
    line-height: 1.6;
  }

  &.half {
    flex: 1;
    margin-bottom: 0;
  }
}

.form-row {
  display: flex;
  gap: 20rpx;
  margin-bottom: 20rpx;
}

.form-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.radio-group {
  display: flex;
  flex-wrap: wrap;
  gap: 24rpx;
}

.radio-item {
  display: flex;
  align-items: center;
  gap: 10rpx;

  .radio-dot {
    width: 32rpx;
    height: 32rpx;
    border-radius: 50%;
    border: 4rpx solid #C9CDD4;
    display: flex;
    align-items: center;
    justify-content: center;

    .radio-dot-inner {
      width: 16rpx;
      height: 16rpx;
      border-radius: 50%;
      background: #3D6DF7;
    }
  }

  &.active {
    .radio-dot {
      border-color: #3D6DF7;
    }
  }

  .radio-text {
    font-size: 28rpx;
    color: #1D2129;
  }
}

.upload-file-wrap,
.upload-image-wrap {
  .upload-add-box {
    width: 200rpx;
    height: 200rpx;
    border-radius: 12rpx;
    border: 2rpx dashed #C9CDD4;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12rpx;

    .upload-tip {
      font-size: 24rpx;
      color: #86909C;
    }
  }
}

.file-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx;
  background: #F5F7FA;
  border-radius: 12rpx;

  .file-name {
    font-size: 26rpx;
    color: #1D2129;
    word-break: break-all;
    text-align: center;
  }

  .file-change {
    font-size: 26rpx;
    color: #3D6DF7;
    padding: 8rpx 24rpx;
    background: #E8F0FE;
    border-radius: 8rpx;
  }
}

.cover-preview {
  position: relative;
  width: 200rpx;
  height: 200rpx;
  border-radius: 12rpx;
  overflow: hidden;

  .cover-img {
    width: 100%;
    height: 100%;
  }

  .cover-delete {
    position: absolute;
    top: 8rpx;
    right: 8rpx;
    width: 36rpx;
    height: 36rpx;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.form-footer {
  flex-shrink: 0;
  display: flex;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.04);

  .btn-cancel,
  .btn-submit {
    flex: 1;
    height: 80rpx;
    border-radius: 40rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30rpx;
  }

  .btn-cancel {
    background: #F5F7FA;
    color: #4E5969;
  }

  .btn-submit {
    background: #3D6DF7;
    color: #fff;

    &.loading {
      opacity: 0.7;
    }

    &:active {
      opacity: 0.9;
    }
  }
}
</style>
