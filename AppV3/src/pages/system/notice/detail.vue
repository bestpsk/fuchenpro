<template>
  <view class="detail-container">
    <view v-if="loading" class="loading-wrap">
      <u-icon name="loading" size="24" color="#3D6DF7"></u-icon>
      <text class="loading-text">加载中...</text>
    </view>
    <view v-else-if="detail" class="detail-content">
      <view class="detail-header">
        <view class="type-tag" :class="'type-' + detail.noticeType">{{ detail.noticeType === '1' ? '通知' : '公告' }}</view>
        <text class="detail-title">{{ detail.noticeTitle }}</text>
      </view>
      <view class="detail-meta">
        <view class="meta-item">
          <u-icon name="account" size="14" color="#86909C"></u-icon>
          <text>{{ detail.createNickName || '-' }}</text>
        </view>
        <view class="meta-item">
          <u-icon name="clock" size="14" color="#86909C"></u-icon>
          <text>{{ detail.createTime || '-' }}</text>
        </view>
      </view>
      <view class="detail-divider"></view>
      <view class="detail-body">
        <rich-text v-if="detail.noticeContent" :nodes="processedContent" class="rich-content"></rich-text>
        <view v-else class="empty-content">
          <u-icon name="file-text" size="40" color="#C9CDD4"></u-icon>
          <text>暂无内容</text>
        </view>
      </view>
    </view>
    <view v-else class="empty-content">
      <u-icon name="file-text" size="40" color="#C9CDD4"></u-icon>
      <text>公告不存在或已删除</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getNotice, markNoticeRead } from '@/api/system/notice'

const detail = ref(null)
const loading = ref(false)

const processedContent = computed(() => {
  const html = detail.value?.noticeContent
  if (!html) return ''
  return html.replace(/<img\s+/gi, '<img style="max-width:100%;height:auto;" ')
})

onLoad((options) => {
  const noticeId = options?.noticeId
  if (noticeId) {
    loadDetail(noticeId)
  }
})

function loadDetail(noticeId) {
  loading.value = true
  getNotice(noticeId).then(res => {
    detail.value = res.data || null
    if (detail.value) {
      markNoticeRead(noticeId).catch(() => {})
    }
  }).catch(() => {
    detail.value = null
  }).finally(() => {
    loading.value = false
  })
}
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; }

.loading-wrap { display: flex; flex-direction: column; align-items: center; justify-content: center; padding-top: 200rpx; gap: 16rpx; }
.loading-text { font-size: 28rpx; color: #86909C; }

.detail-content { background: #fff; border-radius: 16rpx; padding: 36rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04); }

.detail-header { margin-bottom: 24rpx; }
.type-tag { display: inline-block; padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; margin-bottom: 16rpx;
  &.type-1 { background: #FFF7E8; color: #FF7D00; }
  &.type-2 { background: #E8FFEA; color: #00B42A; }
}
.detail-title { font-size: 36rpx; font-weight: 700; color: #1D2129; line-height: 1.5; display: block; }

.detail-meta { display: flex; align-items: center; gap: 32rpx; padding: 20rpx 0; }
.meta-item { display: flex; align-items: center; gap: 8rpx; font-size: 24rpx; color: #86909C; }

.detail-divider { height: 1rpx; background: #F2F3F5; margin: 8rpx 0 28rpx; }

.detail-body { min-height: 200rpx; }
.rich-content { font-size: 28rpx; color: #4E5969; line-height: 1.8; word-break: break-word; }

.empty-content { display: flex; flex-direction: column; align-items: center; justify-content: center; padding-top: 200rpx; gap: 16rpx;
  text { font-size: 28rpx; color: #86909C; }
}
</style>
