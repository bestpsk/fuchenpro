<template>
  <view class="about-container">
    <view class="top-bar">
      <view class="search-wrap">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" v-model="queryParams.aboutTitle" placeholder="搜索标题" confirm-type="search" @confirm="handleSearch" />
        <u-icon v-if="queryParams.aboutTitle" name="close-circle-fill" size="16" color="#C9CDD4" @click="clearSearch"></u-icon>
      </view>
    </view>

    <scroll-view scroll-y class="list-scroll" :style="{ height: scrollHeight + 'px' }" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="aboutList.length > 0" class="card-list">
        <view v-for="item in aboutList" :key="item.aboutId" class="about-card" @click="goDetail(item)">
          <view class="card-top">
            <image v-if="item.coverUrl" class="cover-img" :src="getFullUrl(item.coverUrl)" mode="aspectFill" />
            <view v-else class="cover-placeholder">
              <u-icon name="file-text" size="32" color="#C9CDD4"></u-icon>
            </view>
            <view class="card-info">
              <text class="card-title">{{ item.aboutTitle }}</text>
              <view class="card-meta">
                <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-disabled'">{{ item.status === '0' ? '正常' : '已关闭' }}</view>
                <text class="card-time">{{ formatTime(item.createTime) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无企业小报" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listAbout } from '@/api/admin/about'
import config from '@/config'

const BASE_URL = config.baseUrl || ''

const aboutList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const scrollHeight = ref(600)

const queryParams = reactive({ pageNum: 1, pageSize: 10, aboutTitle: '' })

function getFullUrl(url) {
  if (!url) return ''
  return url.startsWith('http') ? url : BASE_URL + url
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const response = await listAbout(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    aboutList.value = isRefresh ? list : [...aboutList.value, ...list]
    loadStatus.value = aboutList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取企业小报列表失败:', e)
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

function handleSearch() {
  getList(true)
}

function clearSearch() {
  queryParams.aboutTitle = ''
  getList(true)
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/admin/about/detail?aboutId=${item.aboutId}` })
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function calcScrollHeight() {
  const systemInfo = uni.getSystemInfoSync()
  scrollHeight.value = systemInfo.windowHeight - 60
}

onMounted(() => {
  calcScrollHeight()
  getList(true)
})

onShow(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.about-container { display: flex; flex-direction: column; min-height: 100vh; }

.top-bar { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #F2F3F5; flex-shrink: 0; }
.search-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: #F2F3F5;
  border-radius: 28rpx;
  padding: 12rpx 24rpx;
}
.search-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
  height: 36rpx;
  line-height: 36rpx;
}

.list-scroll { padding: 20rpx 30rpx; flex: 1; box-sizing: border-box; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.about-card {
  background: #fff; border-radius: 16rpx; padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}

.card-top {
  display: flex;
  gap: 20rpx;
}

.cover-img {
  width: 140rpx; height: 140rpx; border-radius: 12rpx; flex-shrink: 0;
}

.cover-placeholder {
  width: 140rpx; height: 140rpx; border-radius: 12rpx; flex-shrink: 0;
  background: #F5F7FA; display: flex; align-items: center; justify-content: center;
}

.card-info {
  flex: 1; display: flex; flex-direction: column; justify-content: space-between; min-width: 0;
}

.card-title { font-size: 28rpx; color: #1D2129; font-weight: 500; line-height: 1.5; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; }

.card-meta { display: flex; align-items: center; gap: 16rpx; margin-top: 12rpx; }
.status-tag { padding: 4rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-normal { background: #E8FFEA; color: #00B42A; }
  &.status-disabled { background: #F2F3F5; color: #86909C; }
}
.card-time { font-size: 24rpx; color: #86909C; }
</style>
