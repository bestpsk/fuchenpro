<template>
  <view class="reply-container">
    <view class="feedback-info">
      <view class="info-card">
        <view class="card-title">反馈信息</view>
        <view class="info-row">
          <text class="info-label">反馈标题</text>
          <text class="info-value">{{ feedbackDetail.title || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">反馈内容</text>
          <text class="info-value content-text">{{ feedbackDetail.content || '-' }}</text>
        </view>
      </view>
    </view>

    <view class="reply-form">
      <view class="form-card">
        <view class="card-title"><text class="required">*</text>回复内容</view>
        <textarea
          class="form-textarea"
          v-model="replyContent"
          placeholder="请输入回复内容"
          :maxlength="500"
        />
        <text class="char-count">{{ replyContent.length }}/500</text>
      </view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
      <u-button type="primary" text="提交回复" @click="submitReply" :loading="submitting" customStyle="flex:1; height:88rpx; border-radius:44rpx; font-size:30rpx; font-weight:600;"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getFeedback, replyFeedback } from '@/api/admin/feedback'

const feedbackId = ref('')
const feedbackDetail = ref({})
const replyContent = ref('')
const submitting = ref(false)

async function loadDetail(id) {
  try {
    const res = await getFeedback(id)
    feedbackDetail.value = res.data || {}
  } catch (e) {
    console.error('获取反馈详情失败:', e)
  }
}

function goBack() {
  uni.navigateBack({ fail: () => uni.redirectTo({ url: '/pages/admin/feedback/index' }) })
}

async function submitReply() {
  if (!replyContent.value.trim()) {
    uni.showToast({ title: '请输入回复内容', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    await replyFeedback({ feedbackId: feedbackId.value, content: replyContent.value })
    uni.showToast({ title: '回复成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('回复失败:', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const options = page.options || page.$page?.options || {}
  feedbackId.value = options.feedbackId || ''
  if (feedbackId.value) {
    loadDetail(feedbackId.value)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; }
.reply-container { display: flex; flex-direction: column; height: 100%; padding: 24rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }
.required { color: #F53F3F; margin-right: 4rpx; }
.info-row { margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-label { font-size: 26rpx; color: #86909C; margin-bottom: 8rpx; display: block; }
.info-value { font-size: 28rpx; color: #1D2129; display: block; }
.content-text { line-height: 1.6; word-break: break-all; }

.form-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; }
.form-textarea { width: 100%; height: 300rpx; background: #F5F7FA; border-radius: 12rpx; padding: 20rpx 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; line-height: 1.6; }
.char-count { display: block; text-align: right; font-size: 24rpx; color: #C9CDD4; margin-top: 8rpx; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100; }
</style>
