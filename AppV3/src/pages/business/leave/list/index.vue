<template>
  <view class="leave-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索单号/休假类型"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
    </view>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="leaveList.length > 0" class="card-list">
        <view
          v-for="item in leaveList"
          :key="item.leaveId"
          class="leave-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="no-wrap">
              <u-icon name="file-text" size="16" color="#86909C"></u-icon>
              <text class="no-text">{{ item.leaveNo || '-' }}</text>
            </view>
            <view class="status-tag" :class="getStatusClass(item.status)">{{ getStatusName(item.status) }}</view>
          </view>

          <view class="card-body">
            <view class="type-row">
              <view class="type-tag">{{ item.typeName || '未分类' }}</view>
              <view class="days-tag">{{ item.leaveDays || 0 }} 天</view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <u-icon name="calendar" size="14" color="#86909C"></u-icon>
                <text class="info-text">{{ item.startDate }} {{ getSegmentShort(item.startTimeSegment) }} 至 {{ item.endDate }} {{ getSegmentShort(item.endTimeSegment) }}</text>
              </view>
            </view>
            <view class="info-row" v-if="item.reason">
              <view class="info-item">
                <text class="reason-text">{{ item.reason }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-arrow">
              <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无请假记录"
        :marginTop="100"
      ></u-empty>

      <u-loadmore
        :status="loadStatus"
        :loading-text="'加载中...'"
        :loadmore-text="'上拉加载更多'"
        :nomore-text="'没有更多了'"
        :marginTop="20"
      />
    </scroll-view>

    <view class="fab-btn" @click="goApply">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 我的请假列表页 - 显示当前用户请假记录
 * @description 支持关键词搜索、分页加载、下拉刷新，点击卡片跳转详情页，
 * 右下角悬浮按钮跳转申请页
 */
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listLeave } from '@/api/business/leave'

const leaveList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')

/** 搜索防抖定时器 */
let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: ''
})

const statusMap = {
  '0': { name: '待审核', class: 'status-info' },
  '1': { name: '已通过', class: 'status-success' },
  '2': { name: '已拒绝', class: 'status-danger' },
  '3': { name: '已撤销', class: 'status-warning' }
}

const segmentMap = { '1': '全天', '2': '上午', '3': '下午' }

function getStatusName(value) {
  return statusMap[String(value)] ? statusMap[String(value)].name : '-'
}

function getStatusClass(value) {
  return statusMap[String(value)] ? statusMap[String(value)].class : ''
}

function getSegmentShort(value) {
  const v = String(value || '')
  return segmentMap[v] || ''
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

/** 加载请假列表，支持分页和关键词搜索 */
async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const response = await listLeave({ ...queryParams })
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      leaveList.value = list
    } else {
      leaveList.value = [...leaveList.value, ...list]
    }

    if (leaveList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取请假列表失败:', e)
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

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    handleSearch()
  }, 500)
}

function clearKeyword() {
  queryParams.keyword = ''
  handleSearch()
}

function goDetail(item) {
  uni.navigateTo({
    url: `/pages/business/leave/detail/index?leaveId=${item.leaveId}`
  })
}

function goApply() {
  uni.navigateTo({
    url: '/pages/business/leave/apply/index'
  })
}

onMounted(() => {
  getList(true)
})

onShow(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.leave-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}

.search-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 36rpx;
  padding: 0 28rpx;
  height: 72rpx;
  gap: 12rpx;
  box-sizing: border-box;
}

.search-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  height: 72rpx;
  min-width: 0;
}

.search-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.clear-btn {
  flex-shrink: 0;
  padding: 8rpx;
  display: flex;
  align-items: center;
}

.list-scroll {
  flex: 1;
  overflow: hidden;
  padding: 20rpx 0;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.leave-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.no-wrap {
  display: flex;
  align-items: center;
  gap: 8rpx;
  flex: 1;
  min-width: 0;
}

.no-text {
  font-size: 26rpx;
  color: #4E5969;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;
  flex-shrink: 0;

  &.status-info {
    background: #E8F0FE;
    color: #3D6DF7;
  }

  &.status-success {
    background: #E8FFEA;
    color: #00B42A;
  }

  &.status-danger {
    background: #FFF1F0;
    color: #F53F3F;
  }

  &.status-warning {
    background: #FFF7E8;
    color: #FF7D00;
  }
}

.card-body {
  padding: 0;
}

.type-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}

.type-tag {
  padding: 6rpx 16rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  border-radius: 6rpx;
  font-size: 24rpx;
  font-weight: 500;
}

.days-tag {
  font-size: 26rpx;
  color: #FF6B35;
  font-weight: 600;
}

.info-row {
  margin-bottom: 12rpx;

  &:last-child {
    margin-bottom: 0;
  }
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.info-text {
  font-size: 24rpx;
  color: #4E5969;
}

.reason-text {
  font-size: 24rpx;
  color: #86909C;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid #F2F3F5;
}

.time-text {
  font-size: 22rpx;
  color: #C9CDD4;
}

.action-arrow {
  display: flex;
  align-items: center;
}

.fab-btn {
  position: fixed;
  right: 32rpx;
  bottom: 120rpx;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #3D6DF7, #5B8DEF);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);

  &:active {
    transform: scale(0.95);
    opacity: 0.9;
  }
}
</style>
