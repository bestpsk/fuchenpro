<template>
  <view class="detail-container">
    <view v-if="loading" class="loading-wrap">
      <u-icon name="loading" size="24" color="#3D6DF7"></u-icon>
      <text class="loading-text">加载中...</text>
    </view>
    <view v-else-if="detail" class="detail-content">
      <view class="detail-header">
        <text class="detail-title">{{ detail.aboutTitle }}</text>
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
        <rich-text v-if="detail.aboutContent" :nodes="processedContent" class="rich-content"></rich-text>
        <view v-else class="empty-content">
          <u-icon name="file-text" size="40" color="#C9CDD4"></u-icon>
          <text>暂无内容</text>
        </view>
      </view>
    </view>
    <view v-else class="empty-content">
      <u-icon name="file-text" size="40" color="#C9CDD4"></u-icon>
      <text>内容不存在或已删除</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getAbout } from '@/api/admin/about'
import config from '@/config'

const detail = ref(null)
const loading = ref(false)

const processedContent = computed(() => {
  const html = detail.value?.aboutContent
  if (!html) return ''
  // 补全相对路径图片为绝对 URL（以 /profile/ 开头），已是绝对 URL(http)的不重复拼接
  let result = html.replace(/src="\/profile\//g, `src="${config.baseUrl}/profile/`)
  // 统一图片样式，确保自适应宽度
  result = result.replace(/<img\s+/gi, '<img style="max-width:100%;height:auto;" ')
  return result
})

onLoad((options) => {
  const aboutId = options?.aboutId
  if (aboutId) {
    loadDetail(aboutId)
  }
})

function loadDetail(aboutId) {
  loading.value = true
  getAbout(aboutId).then(res => {
    detail.value = res.data || null
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
