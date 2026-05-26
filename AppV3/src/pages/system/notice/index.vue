<template>
  <view class="notice-container">
    <view class="top-bar">
      <view class="top-bar-inner">
        <text class="top-bar-title">通知公告</text>
        <view v-if="noticeList.length > 0" class="mark-all-btn" @click="handleMarkAllRead">
          <u-icon name="checkmark" size="14" color="#3D6DF7"></u-icon>
          <text>全部已读</text>
        </view>
      </view>
    </view>

    <scroll-view scroll-y class="list-scroll" :style="{ height: scrollHeight + 'px' }" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="noticeList.length > 0" class="card-list">
        <view v-for="item in noticeList" :key="item.noticeId" class="notice-card" :class="{ 'is-read': item.isRead }" @click="goDetail(item)">
          <view class="card-header">
            <view class="type-tag" :class="'type-' + item.noticeType">{{ item.noticeType === '1' ? '通知' : '公告' }}</view>
            <text class="card-time">{{ formatTime(item.createTime) }}</text>
          </view>
          <view class="card-body">
            <text class="card-title">{{ item.noticeTitle }}</text>
          </view>
          <view v-if="!item.isRead" class="unread-dot"></view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无通知公告" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { listNotice, markNoticeReadAll } from '@/api/system/notice'

const noticeList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const scrollHeight = ref(600)

const queryParams = reactive({ pageNum: 1, pageSize: 10 })

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const response = await listNotice(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    noticeList.value = isRefresh ? list : [...noticeList.value, ...list]
    loadStatus.value = noticeList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取通知列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

function onPullDownRefresh() {
  refreshing.value = true
  getList(true)
}

function handleMarkAllRead() {
  markNoticeReadAll().then(() => {
    noticeList.value = noticeList.value.map(item => ({ ...item, isRead: true }))
    uni.showToast({ title: '已全部标记为已读', icon: 'success' })
  }).catch(() => {})
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/system/notice/detail?noticeId=${item.noticeId}` })
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function calcScrollHeight() {
  const systemInfo = uni.getSystemInfoSync()
  scrollHeight.value = systemInfo.windowHeight - 100
}

onMounted(() => {
  calcScrollHeight()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.notice-container { min-height: 100vh; }

.top-bar { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #F2F3F5; }
.top-bar-inner { display: flex; justify-content: space-between; align-items: center; }
.top-bar-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.mark-all-btn { display: flex; align-items: center; gap: 6rpx; padding: 10rpx 20rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
  &:active { opacity: 0.7; }
}

.list-scroll { padding: 20rpx 24rpx; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.notice-card { position: relative; background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
  &.is-read { opacity: 0.6; }
}

.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.type-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.type-1 { background: #FFF7E8; color: #FF7D00; }
  &.type-2 { background: #E8FFEA; color: #00B42A; }
}
.card-time { font-size: 24rpx; color: #86909C; }

.card-body { padding-top: 4rpx; }
.card-title { font-size: 28rpx; color: #1D2129; font-weight: 500; line-height: 1.5; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; }

.unread-dot { position: absolute; top: 24rpx; right: 24rpx; width: 16rpx; height: 16rpx; border-radius: 50%; background: #F53F3F; }
</style>
