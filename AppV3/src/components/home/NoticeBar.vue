<template>
  <view class="notice-card" v-if="noticeList.length > 0">
    <view class="notice-icon">
      <u-icon name="volume" size="18" color="#FFFFFF" />
    </view>
    <swiper class="notice-swiper" vertical autoplay circular interval="3000" duration="500">
      <swiper-item v-for="(item, index) in noticeList" :key="index">
        <view class="notice-item" @click="handleNoticeClick(item)">
          <text class="notice-type">[{{ item.typeLabel }}]</text>
          <text class="notice-content">{{ item.content }}</text>
        </view>
      </swiper-item>
    </swiper>
    <view class="notice-more" @click="handleMoreNotice">
      <u-icon name="arrow-right" size="14" color="#86909C" />
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listNoticeTop, markNoticeRead } from '@/api/system/notice'

const typeMap = { '1': '通知', '2': '公告' }

const noticeList = ref([])

function loadNotices() {
  listNoticeTop().then(res => {
    const list = Array.isArray(res.data?.list) ? res.data.list
               : Array.isArray(res.list) ? res.list
               : (Array.isArray(res.data) ? res.data : [])
    noticeList.value = list.map(item => ({
      ...item,
      typeLabel: typeMap[item.noticeType] || '消息',
      content: item.noticeTitle
    }))
  }).catch(() => {})
}

function handleNoticeClick(item) {
  if (!item.isRead) {
    markNoticeRead(item.noticeId).catch(() => {})
  }
  uni.navigateTo({ url: `/pages/system/notice/detail?noticeId=${item.noticeId}` })
}

function handleMoreNotice() {
  uni.navigateTo({ url: '/pages/system/notice/index' })
}

onMounted(() => loadNotices())

defineExpose({ loadNotices })
</script>

<style lang="scss" scoped>
.notice-card {
  margin: 8rpx 24rpx 0;
  background: #fff;
  border-radius: 20rpx;
  padding: 18rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.notice-icon {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: #3D6DF7;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.notice-swiper {
  flex: 1;
  height: 44rpx;
}

.notice-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  height: 44rpx;
  line-height: 44rpx;
}

.notice-type {
  font-size: 23rpx;
  color: #3D6DF7;
  font-weight: 500;
  flex-shrink: 0;
}

.notice-content {
  font-size: 23rpx;
  color: #4E5969;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.notice-more {
  width: 44rpx;
  height: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &:active {
    opacity: 0.6;
  }
}
</style>
