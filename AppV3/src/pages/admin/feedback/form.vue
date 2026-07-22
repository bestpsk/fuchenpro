<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-item">
        <text class="form-label">反馈标题</text>
        <input class="form-input" v-model="form.title" placeholder="请输入反馈标题" />
      </view>
      <view class="form-item">
        <text class="form-label">反馈类型</text>
        <view class="radio-group">
          <view v-for="item in typeOptions" :key="item.value" class="radio-item" :class="{ active: form.feedbackType === item.value }" @click="form.feedbackType = item.value">
            <view class="radio-dot"><view v-if="form.feedbackType === item.value" class="radio-dot-inner"></view></view>
            <text class="radio-text">{{ item.label }}</text>
          </view>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">反馈内容</text>
        <textarea class="form-textarea" v-model="form.content" placeholder="请详细描述您遇到的问题或建议" :maxlength="500" />
        <text class="char-count">{{ form.content.length }}/500</text>
      </view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
      <u-button type="primary" :text="isEdit ? '保存' : '提交'" @click="submitForm" :loading="submitting" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { addFeedback, updateFeedback, getFeedback } from '@/api/admin/feedback'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)
const mode = ref('add')
const feedbackId = ref('')
const isEdit = computed(() => mode.value === 'edit')

const form = reactive({
  title: '',
  feedbackType: '0',
  content: ''
})

const typeOptions = ref([])

async function loadDicts() {
  try {
    const res = await getDicts('biz_feedback_type')
    typeOptions.value = (res.data || []).map(item => ({ label: item.dictLabel, value: item.dictValue }))
    if (typeOptions.value.length > 0 && !form.feedbackType) {
      form.feedbackType = typeOptions.value[0].value
    }
  } catch (e) { console.error('获取反馈类型字典失败:', e) }
}

async function loadDetail(id) {
  try {
    const res = await getFeedback(id)
    const data = res.data || res
    form.title = data.title || ''
    form.feedbackType = String(data.feedbackType ?? '0')
    form.content = data.content || ''
  } catch (e) {
    console.error('加载反馈详情失败:', e)
  }
}

function goBack() {
  uni.navigateBack({ fail: () => uni.redirectTo({ url: '/pages/admin/feedback/index' }) })
}

async function submitForm() {
  if (!form.title.trim()) { uni.showToast({ title: '请输入反馈标题', icon: 'none' }); return }
  if (!form.content.trim()) { uni.showToast({ title: '请输入反馈内容', icon: 'none' }); return }
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateFeedback({ feedbackId: feedbackId.value, ...form })
      uni.showToast({ title: '保存成功', icon: 'success' })
    } else {
      await addFeedback(form)
      uni.showToast({ title: '提交成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交反馈失败:', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadDicts()
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const options = page.options || page.$page?.options || {}
  if (options.mode === 'edit' && options.id) {
    mode.value = 'edit'
    feedbackId.value = options.id
    uni.setNavigationBarTitle({ title: '编辑反馈' })
    loadDetail(options.id)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; }
.form-container { display: flex; flex-direction: column; height: 100%; padding: 24rpx; }

.form-section { flex: 1; background: #fff; border-radius: 16rpx; padding: 32rpx; }
.form-item { margin-bottom: 32rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; display: block; }
.form-input { width: 100%; height: 80rpx; background: #F5F7FA; border-radius: 12rpx; padding: 0 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; }

.radio-group { display: flex; gap: 32rpx; }
.radio-item { display: flex; align-items: center; gap: 12rpx; }
.radio-item.active .radio-text { color: #3D6DF7; }
.radio-dot { width: 32rpx; height: 32rpx; border-radius: 50%; border: 4rpx solid #C9CDD4; display: flex; align-items: center; justify-content: center; transition: border-color 0.2s;
  .radio-item.active & { border-color: #3D6DF7; }
}
.radio-dot-inner { width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
.radio-text { font-size: 28rpx; color: #4E5969; }

.form-textarea { width: 100%; height: 240rpx; background: #F5F7FA; border-radius: 12rpx; padding: 20rpx 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; line-height: 1.6; }
.char-count { display: block; text-align: right; font-size: 24rpx; color: #C9CDD4; margin-top: 8rpx; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100; }
</style>
