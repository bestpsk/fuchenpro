<template>
  <view class="stats-container">
    <!-- 筛选区 -->
    <view class="filter-section">
      <view class="filter-row">
        <view class="date-pickers" @click="showDatePicker = true">
          <text class="date-text">{{ dateRange[0] || '开始日期' }}</text>
          <text class="date-sep">~</text>
          <text class="date-text">{{ dateRange[1] || '结束日期' }}</text>
        </view>
      </view>
      <view class="filter-row">
        <input
          class="filter-input"
          v-model="queryParams.userName"
          placeholder="用户姓名"
          confirm-type="search"
          @confirm="handleQuery"
        />
        <input
          class="filter-input"
          v-model="queryParams.materialTitle"
          placeholder="材料标题"
          confirm-type="search"
          @confirm="handleQuery"
        />
      </view>
      <view class="filter-actions">
        <view class="search-btn" @click="handleQuery">查询</view>
        <view class="reset-btn" @click="handleReset">重置</view>
      </view>
    </view>

    <!-- 汇总卡片 -->
    <view class="summary-section" v-if="summary">
      <view class="summary-item">
        <text class="summary-label">总时长</text>
        <text class="summary-value">{{ formatDuration(summary.totalDuration) }}</text>
      </view>
      <view class="summary-item">
        <text class="summary-label">总次数</text>
        <text class="summary-value">{{ summary.totalCount || 0 }}</text>
      </view>
      <view class="summary-item">
        <text class="summary-label">人数</text>
        <text class="summary-value">{{ summary.userCount || 0 }}</text>
      </view>
      <view class="summary-item">
        <text class="summary-label">材料数</text>
        <text class="summary-value">{{ summary.materialCount || 0 }}</text>
      </view>
    </view>

    <!-- 统计列表 -->
    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="statsList.length > 0" class="card-list">
        <view v-for="(item, index) in statsList" :key="index" class="stats-card">
          <view class="card-header">
            <view class="user-info">
              <view class="user-avatar">
                <u-icon name="account-fill" size="20" color="#3D6DF7"></u-icon>
              </view>
              <view class="user-text">
                <text class="user-name">{{ item.userName }}</text>
                <text class="dept-name">{{ item.deptName || '未分配部门' }}</text>
              </view>
            </view>
          </view>
          <view class="card-body">
            <view class="material-row">
              <u-icon name="file-text" size="14" color="#86909C"></u-icon>
              <text class="material-title">{{ item.materialTitle }}</text>
            </view>
            <view class="stats-row">
              <view class="stat-item">
                <text class="stat-label">学习时长</text>
                <text class="stat-value duration">{{ formatDuration(item.totalDuration) }}</text>
              </view>
              <view class="stat-item">
                <text class="stat-label">学习次数</text>
                <text class="stat-value count">{{ item.studyCount }}</text>
              </view>
              <view class="stat-item">
                <text class="stat-label">最后学习</text>
                <text class="stat-value time">{{ formatTime(item.lastStudyTime) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty v-else-if="!loading" mode="data" text="暂无统计数据" :marginTop="100"></u-empty>

      <u-loadmore
        :status="loadStatus"
        :loading-text="'加载中...'"
        :loadmore-text="'上拉加载更多'"
        :nomore-text="'没有更多了'"
        :marginTop="20"
      />
    </scroll-view>

    <!-- 日期选择弹窗 -->
    <u-popup :show="showDatePicker" mode="bottom" @close="showDatePicker = false" :round="16">
      <view class="date-popup">
        <view class="popup-header">
          <text class="popup-title">选择日期范围</text>
          <text class="popup-close" @click="showDatePicker = false">关闭</text>
        </view>
        <view class="shortcut-list">
          <view
            v-for="opt in shortcutOptions"
            :key="opt.value"
            class="shortcut-item"
            :class="{ active: shortcut === opt.value }"
            @click="applyShortcut(opt.value)"
          >{{ opt.label }}</view>
        </view>
        <view class="date-inputs">
          <view class="date-input-box" @click="pickDate('start')">
            <text>{{ dateRange[0] || '选择开始日期' }}</text>
          </view>
          <text class="date-sep">~</text>
          <view class="date-input-box" @click="pickDate('end')">
            <text>{{ dateRange[1] || '选择结束日期' }}</text>
          </view>
        </view>
        <view class="popup-actions">
          <view class="popup-btn confirm" @click="confirmDate">确定</view>
          <view class="popup-btn cancel" @click="showDatePicker = false">取消</view>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker
      :show="showDatePickerItem"
      mode="date"
      @confirm="onDatePicked"
      @cancel="showDatePickerItem = false"
    />
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listStudyStats, getStudyStatsSummary } from '@/api/train/material'

const statsList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const summary = ref(null)
const showDatePicker = ref(false)
const showDatePickerItem = ref(false)
const dateRange = reactive(['', ''])
const shortcut = ref('')
const pickTarget = ref('start')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  userName: '',
  materialTitle: '',
})

const shortcutOptions = [
  { label: '今天', value: 'today' },
  { label: '本周', value: 'week' },
  { label: '本月', value: 'month' },
  { label: '上月', value: 'lastMonth' },
]

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  seconds = parseInt(seconds)
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  if (h > 0) return `${h}时${m}分`
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

function formatTime(time) {
  if (!time) return '-'
  return time.substring(5, 16)
}

function formatDate(d) {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function applyShortcut(val) {
  shortcut.value = val
  const now = new Date()
  let start, end
  switch (val) {
    case 'today':
      start = end = now
      break
    case 'week': {
      const day = now.getDay() || 7
      start = new Date(now)
      start.setDate(now.getDate() - day + 1)
      end = now
      break
    }
    case 'month':
      start = new Date(now.getFullYear(), now.getMonth(), 1)
      end = now
      break
    case 'lastMonth':
      start = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      end = new Date(now.getFullYear(), now.getMonth(), 0)
      break
  }
  dateRange[0] = formatDate(start)
  dateRange[1] = formatDate(end)
}

function pickDate(target) {
  pickTarget.value = target
  showDatePickerItem.value = true
}

function onDatePicked(e) {
  const d = new Date(e.value)
  if (pickTarget.value === 'start') {
    dateRange[0] = formatDate(d)
  } else {
    dateRange[1] = formatDate(d)
  }
  shortcut.value = ''
  showDatePickerItem.value = false
}

function confirmDate() {
  showDatePicker.value = false
  handleQuery()
}

function getList() {
  loading.value = true
  const params = { ...queryParams }
  if (dateRange[0]) params.startDate = dateRange[0]
  if (dateRange[1]) params.endDate = dateRange[1]
  listStudyStats(params).then(res => {
    if (res.code === 200) {
      statsList.value = params.pageNum === 1 ? res.rows : [...statsList.value, ...res.rows]
      loadStatus.value = res.rows.length < queryParams.pageSize ? 'nomore' : 'loadmore'
    }
    loading.value = false
    refreshing.value = false
  }).catch(() => {
    loading.value = false
    refreshing.value = false
  })
  getStudyStatsSummary(params).then(res => {
    if (res.code === 200) summary.value = res.data
  })
}

function getSummary() {
  const params = { ...queryParams }
  if (dateRange[0]) params.startDate = dateRange[0]
  if (dateRange[1]) params.endDate = dateRange[1]
  getStudyStatsSummary(params).then(res => {
    if (res.code === 200) summary.value = res.data
  })
}

function loadMore() {
  if (loadStatus.value !== 'nomore') {
    queryParams.pageNum++
    getList()
  }
}

function onPullDownRefresh() {
  refreshing.value = true
  queryParams.pageNum = 1
  getList()
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
  getSummary()
}

function handleReset() {
  queryParams.userName = ''
  queryParams.materialTitle = ''
  dateRange[0] = ''
  dateRange[1] = ''
  shortcut.value = ''
  handleQuery()
}

onShow(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
.stats-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f6f7;
}

.filter-section {
  background: #fff;
  padding: 16rpx 24rpx;
}

.filter-row {
  display: flex;
  gap: 16rpx;
  margin-bottom: 12rpx;
}

.date-pickers {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 64rpx;
  background: #f5f6f7;
  border-radius: 8rpx;
  font-size: 26rpx;
}

.date-text {
  color: #333;
}

.date-sep {
  margin: 0 12rpx;
  color: #86909c;
}

.filter-input {
  flex: 1;
  height: 64rpx;
  background: #f5f6f7;
  border-radius: 8rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
}

.filter-actions {
  display: flex;
  gap: 16rpx;
}

.search-btn {
  flex: 1;
  height: 64rpx;
  line-height: 64rpx;
  text-align: center;
  background: #3D6DF7;
  color: #fff;
  border-radius: 8rpx;
  font-size: 26rpx;
}

.reset-btn {
  flex: 1;
  height: 64rpx;
  line-height: 64rpx;
  text-align: center;
  background: #f5f6f7;
  color: #333;
  border-radius: 8rpx;
  font-size: 26rpx;
}

.summary-section {
  display: flex;
  background: #fff;
  margin: 16rpx 0;
  padding: 20rpx 0;
}

.summary-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.summary-label {
  font-size: 22rpx;
  color: #86909c;
  margin-bottom: 8rpx;
}

.summary-value {
  font-size: 32rpx;
  font-weight: 600;
  color: #3D6DF7;
}

.list-scroll {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.card-list {
  padding: 0 24rpx 24rpx;
}

.stats-card {
  background: #fff;
  border-radius: 16rpx;
  margin-bottom: 20rpx;
  overflow: hidden;
}

.card-header {
  padding: 24rpx 24rpx 16rpx;
  border-bottom: 1rpx solid #f0f0f0;
}

.user-info {
  display: flex;
  align-items: center;
}

.user-avatar {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: #E8F0FE;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16rpx;
}

.user-text {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 28rpx;
  font-weight: 500;
  color: #1d2129;
}

.dept-name {
  font-size: 22rpx;
  color: #86909c;
  margin-top: 4rpx;
}

.card-body {
  padding: 20rpx 24rpx;
}

.material-row {
  display: flex;
  align-items: center;
  margin-bottom: 16rpx;
}

.material-title {
  font-size: 26rpx;
  color: #4e5969;
  margin-left: 8rpx;
}

.stats-row {
  display: flex;
  justify-content: space-between;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
}

.stat-label {
  font-size: 22rpx;
  color: #86909c;
  margin-bottom: 6rpx;
}

.stat-value {
  font-size: 28rpx;
  font-weight: 600;
}

.stat-value.duration {
  color: #3D6DF7;
}

.stat-value.count {
  color: #3D6DF7;
}

.stat-value.time {
  font-size: 24rpx;
  font-weight: 400;
  color: #86909c;
}

.date-popup {
  padding: 32rpx;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.popup-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1d2129;
}

.popup-close {
  font-size: 26rpx;
  color: #86909c;
}

.shortcut-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

.shortcut-item {
  padding: 12rpx 32rpx;
  background: #f5f6f7;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #4e5969;
}

.shortcut-item.active {
  background: #3D6DF7;
  color: #fff;
}

.date-inputs {
  display: flex;
  align-items: center;
  margin-bottom: 24rpx;
}

.date-input-box {
  flex: 1;
  height: 72rpx;
  line-height: 72rpx;
  text-align: center;
  background: #f5f6f7;
  border-radius: 8rpx;
  font-size: 26rpx;
}

.popup-actions {
  display: flex;
  gap: 16rpx;
}

.popup-btn {
  flex: 1;
  height: 80rpx;
  line-height: 80rpx;
  text-align: center;
  border-radius: 8rpx;
  font-size: 28rpx;
}

.popup-btn.confirm {
  background: #3D6DF7;
  color: #fff;
}

.popup-btn.cancel {
  background: #f5f6f7;
  color: #4e5969;
}
</style>
