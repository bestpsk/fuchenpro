<template>
  <view class="detail-container">
    <view v-if="detail" class="detail-content">
      <view class="detail-card">
        <view class="card-header-row">
          <text class="detail-title">{{ detail.title }}</text>
          <view class="status-badge" :class="'status-' + String(detail.status)">{{ getStatusLabel(detail.status) }}</view>
        </view>
        <view class="info-body">
          <view class="info-row">
            <text class="info-label">反馈类型</text>
            <text class="info-value">{{ getTypeLabel(detail.feedbackType) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">创建人</text>
            <text class="info-value">{{ detail.createNickName || detail.createBy }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">创建时间</text>
            <text class="info-value">{{ formatTime(detail.createTime) }}</text>
          </view>
        </view>
      </view>

      <view class="detail-card">
        <view class="card-title">反馈内容</view>
        <text class="content-text">{{ detail.content }}</text>
      </view>

      <view class="detail-card" v-if="detail.replies && detail.replies.length > 0">
        <view class="card-title">回复记录</view>
        <view class="reply-list">
          <view v-for="reply in detail.replies" :key="reply.replyId" class="reply-item">
            <view class="reply-header">
              <text class="reply-author">{{ reply.createNickName || reply.createBy }}</text>
              <text class="reply-time">{{ formatTime(reply.createTime) }}</text>
            </view>
            <text class="reply-content">{{ reply.content }}</text>
          </view>
        </view>
      </view>
    </view>

    <u-empty v-else-if="!loading" mode="data" text="反馈不存在" :marginTop="100"></u-empty>

    <view v-if="detail" class="bottom-actions">
      <view v-if="checkPermi('admin:feedback:reply')" class="action-btn reply" @click="goReply">
        <u-icon name="chat" size="16"></u-icon>
        <text>回复</text>
      </view>
      <view v-if="checkPermi('admin:feedback:edit')" class="action-btn edit" @click="goEdit">
        <u-icon name="edit-pen" size="16"></u-icon>
        <text>编辑</text>
      </view>
      <view v-if="checkPermi('admin:feedback:remove')" class="action-btn delete" @click="handleDelete">
        <u-icon name="trash" size="16"></u-icon>
        <text>删除</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getFeedback, delFeedback } from '@/api/admin/feedback'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const detail = ref(null)
const loading = ref(false)
const feedbackId = ref('')
const typeOptions = ref([])
const statusOptions = ref([])

async function loadDicts() {
  try {
    const [typeRes, statusRes] = await Promise.all([
      getDicts('biz_feedback_type'),
      getDicts('biz_feedback_status')
    ])
    typeOptions.value = (typeRes.data || []).map(item => ({ label: item.dictLabel, value: item.dictValue }))
    statusOptions.value = (statusRes.data || []).map(item => ({ label: item.dictLabel, value: item.dictValue }))
  } catch (e) { console.error('获取字典失败:', e) }
}

function getTypeLabel(type) {
  const item = typeOptions.value.find(o => o.value === String(type))
  return item ? item.label : '其他'
}

function getStatusLabel(status) {
  const item = statusOptions.value.find(o => o.value === String(status))
  return item ? item.label : '未知'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

async function loadDetail(id) {
  loading.value = true
  try {
    const response = await getFeedback(id)
    detail.value = response.data || response
  } catch (e) { console.error('获取反馈详情失败:', e) }
  finally { loading.value = false }
}

function goReply() {
  uni.navigateTo({ url: `/pages/admin/feedback/reply?feedbackId=${feedbackId.value}` })
}

function goEdit() {
  uni.navigateTo({ url: `/pages/admin/feedback/form?mode=edit&id=${feedbackId.value}` })
}

function handleDelete() {
  uni.showModal({
    title: '提示',
    content: `是否确认删除反馈"${detail.value?.title}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delFeedback(feedbackId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => {
            uni.navigateBack()
          }, 1500)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

onMounted(() => {
  loadDicts()
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const id = page.options?.id || page.$page?.options?.id
  if (id) {
    feedbackId.value = id
    loadDetail(id)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { padding: 24rpx; padding-bottom: 140rpx; }

.detail-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.detail-title { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #e8f0fe; color: #3D6DF7; }
  &.status-2 { background: #f6ffed; color: #52c41a; }
  &.status-3 { background: #F2F3F5; color: #86909C; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 100rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1; }

.content-text { font-size: 28rpx; color: #4E5969; line-height: 1.8; word-break: break-all; }

.reply-list { display: flex; flex-direction: column; gap: 20rpx; }
.reply-item { background: #F5F7FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.reply-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10rpx; }
.reply-author { font-size: 26rpx; font-weight: 500; color: #1D2129; }
.reply-time { font-size: 22rpx; color: #86909C; }
.reply-content { font-size: 26rpx; color: #4E5969; line-height: 1.6; }

.bottom-actions {
  position: fixed; left: 0; right: 0; bottom: 0; display: flex; align-items: center;
  justify-content: center; gap: 24rpx; padding: 20rpx 30rpx; padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff; box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.08); z-index: 100;
}
.action-btn {
  display: flex; align-items: center; justify-content: center; gap: 8rpx;
  padding: 16rpx 32rpx; border-radius: 36rpx; font-size: 28rpx; font-weight: 500;
  &.reply { color: #fff; background: linear-gradient(135deg, #3D6DF7, #5B8DEF); }
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
  &:active { opacity: 0.7; }
}
</style>
