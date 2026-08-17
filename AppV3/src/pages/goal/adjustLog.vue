<template>
  <view class="adjust-log-container">
    <!-- 搜索栏 -->
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.goalName" placeholder="搜索目标名称" placeholder-class="search-placeholder" confirm-type="search" @confirm="handleSearch" />
        <view v-if="queryParams.goalName" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
    </view>

    <!-- 筛选弹窗 -->
    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">操作人</view>
          <input class="form-input" type="text" v-model="queryParams.adjustBy" placeholder="请输入操作人" />
        </view>
        <view class="form-item">
          <view class="form-label">调整日期</view>
          <view class="date-range">
            <view class="date-picker-value" @click="openDatePicker('start')">
              <text :class="{ 'placeholder-text': !queryParams.beginTime }">{{ queryParams.beginTime || '开始日期' }}</text>
            </view>
            <text class="date-separator">-</text>
            <view class="date-picker-value" @click="openDatePicker('end')">
              <text :class="{ 'placeholder-text': !queryParams.endTime }">{{ queryParams.endTime || '结束日期' }}</text>
            </view>
          </view>
        </view>
        <view class="popup-btns">
          <view class="popup-btn reset" @click="resetFilter">重置</view>
          <view class="popup-btn confirm" @click="confirmFilter">确定</view>
        </view>
      </view>
    </u-popup>

    <!-- 日期选择器 -->
    <u-datetime-picker :show="showDatePicker" mode="date" v-model="datePickerValue" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>

    <!-- 列表 -->
    <view class="list-wrap">
      <view v-if="list.length > 0">
        <view v-for="(item, index) in list" :key="item.logId || index" class="log-card">
          <view class="card-top">
            <text class="goal-name">{{ item.goalName }}</text>
            <view class="metric-tag">{{ getMetricTypeLabel(item.metricType) }}</view>
          </view>
          <view class="card-owner">
            <u-icon name="account" size="13" color="#86909C"></u-icon>
            <text class="owner-text">{{ item.ownerName || '-' }}</text>
          </view>
          <view class="value-compare">
            <view class="value-block">
              <text class="value-label">原值</text>
              <text class="value-old">{{ formatNumber(item.oldValue) }}</text>
            </view>
            <view class="value-arrow">
              <u-icon name="arrow-right" size="14" color="#86909C"></u-icon>
            </view>
            <view class="value-block">
              <text class="value-label">新值</text>
              <text class="value-new">{{ formatNumber(item.newValue) }}</text>
            </view>
            <view class="value-diff" :class="getDiffClass(item)">
              <text>{{ getDiffText(item) }}</text>
            </view>
          </view>
          <view class="card-reason">
            <text class="reason-label">调整原因：</text>
            <text class="reason-text">{{ item.reason }}</text>
          </view>
          <view class="card-footer">
            <view class="footer-item">
              <u-icon name="account-fill" size="12" color="#86909C"></u-icon>
              <text class="footer-text">{{ item.adjustBy }}</text>
            </view>
            <view class="footer-item">
              <u-icon name="clock" size="12" color="#86909C"></u-icon>
              <text class="footer-text">{{ formatTime(item.adjustTime) }}</text>
            </view>
          </view>
        </view>
      </view>

      <view v-else-if="!loading" class="empty-state">
        <u-icon name="empty-data" size="80" color="#C9CDD4"></u-icon>
        <text class="empty-text">暂无调整记录</text>
      </view>

      <view v-if="loading" class="loading-more">
        <u-icon name="loading" size="16" color="#3D6DF7"></u-icon>
        <text>加载中...</text>
      </view>
      <view v-else-if="list.length > 0 && !hasMore" class="no-more">
        <text>没有更多了</text>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 调整记录列表页 - 展示目标调整历史记录
 */
import { ref, reactive } from 'vue'
import { onLoad, onShow, onReachBottom } from '@dcloudio/uni-app'
import { listAdjustLog } from '@/api/goal'

const metricTypeMap = {
  1: '实收业绩', 2: '消耗业绩', 3: '出货金额', 4: '品项件数',
  5: '品项金额', 6: '到店客次', 7: '新客数', 8: '活跃门店数'
}

function getMetricTypeLabel(val) {
  return metricTypeMap[String(val)] || '-'
}

function formatNumber(val) {
  if (val === null || val === undefined || val === '') return '0'
  const num = Number(val)
  if (isNaN(num)) return '0'
  return num.toLocaleString('zh-CN')
}

function formatTime(time) {
  if (!time) return '-'
  return String(time).replace('T', ' ').substring(0, 16)
}

function getDiffClass(item) {
  const diff = Number(item.newValue) - Number(item.oldValue)
  return diff >= 0 ? 'diff-up' : 'diff-down'
}

function getDiffText(item) {
  const diff = Number(item.newValue) - Number(item.oldValue)
  const absDiff = Math.abs(diff)
  const sign = diff >= 0 ? '↑ +' : '↓ '
  return sign + formatNumber(absDiff)
}

const list = ref([])
const loading = ref(false)
const hasMore = ref(true)
const showFilter = ref(false)
const showDatePicker = ref(false)
const datePickerValue = ref(Date.now())
const datePickType = ref('start')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  goalName: '',
  adjustBy: '',
  beginTime: '',
  endTime: ''
})

async function loadList(reset = false) {
  if (loading.value) return
  if (reset) {
    queryParams.pageNum = 1
    hasMore.value = true
  }
  if (!hasMore.value) return
  loading.value = true
  try {
    const res = await listAdjustLog(queryParams)
    const rows = res.rows || []
    if (reset) {
      list.value = rows
    } else {
      list.value = [...list.value, ...rows]
    }
    const total = res.total || 0
    hasMore.value = list.value.length < total
  } catch (e) {
    console.error('加载调整记录失败', e)
    if (reset) list.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  loadList(true)
}

function clearKeyword() {
  queryParams.goalName = ''
  loadList(true)
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.adjustBy = ''
  queryParams.beginTime = ''
  queryParams.endTime = ''
}

function confirmFilter() {
  showFilter.value = false
  loadList(true)
}

function openDatePicker(type) {
  datePickType.value = type
  const refTime = type === 'start' ? queryParams.beginTime : queryParams.endTime
  datePickerValue.value = refTime ? new Date(refTime).getTime() : Date.now()
  showDatePicker.value = true
}

function onDateConfirm(e) {
  const d = new Date(e.value)
  const dateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  if (datePickType.value === 'start') {
    queryParams.beginTime = dateStr
  } else {
    queryParams.endTime = dateStr
  }
  showDatePicker.value = false
}

onLoad((options) => {
  if (options.goalId) {
    queryParams.goalId = options.goalId
  }
})

onShow(() => {
  loadList(true)
})

onReachBottom(() => {
  if (hasMore.value && !loading.value) {
    queryParams.pageNum++
    loadList()
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.adjust-log-container {
  min-height: 100vh;
  padding-bottom: 40rpx;
}

.search-section {
  padding: 16rpx 24rpx;
  background: #fff;
  position: sticky;
  top: 0;
  z-index: 10;
}

.search-box {
  display: flex;
  align-items: center;
  background: #F5F7FA;
  border-radius: 32rpx;
  padding: 12rpx 24rpx;
  gap: 12rpx;
}

.search-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
}

.search-placeholder {
  color: #C9CDD4;
  font-size: 26rpx;
}

.clear-btn {
  display: flex;
  align-items: center;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 4rpx;
  font-size: 24rpx;
  color: #3D6DF7;
  padding-left: 16rpx;
  border-left: 1rpx solid #E5E6EB;
}

.icon-rotate {
  transform: rotate(180deg);
  transition: transform 0.2s;
}

/* 筛选弹窗 */
.popup-content {
  padding: 32rpx 24rpx;
}

.popup-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #1D2129;
  margin-bottom: 24rpx;
}

.form-item {
  margin-bottom: 28rpx;
}

.form-label {
  font-size: 26rpx;
  color: #4E5969;
  margin-bottom: 12rpx;
}

.form-input {
  background: #F5F7FA;
  border-radius: 8rpx;
  padding: 16rpx 24rpx;
  font-size: 26rpx;
  color: #1D2129;
  width: 100%;
  box-sizing: border-box;
}

.date-range {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.date-picker-value {
  flex: 1;
  background: #F5F7FA;
  border-radius: 8rpx;
  padding: 16rpx 24rpx;
  font-size: 26rpx;
  color: #1D2129;
  text-align: center;
}

.placeholder-text {
  color: #C9CDD4;
}

.date-separator {
  color: #86909C;
}

.popup-btns {
  display: flex;
  gap: 24rpx;
  margin-top: 32rpx;
}

.popup-btn {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;

  &.reset {
    background: #F5F7FA;
    color: #4E5969;
  }

  &.confirm {
    background: #3D6DF7;
    color: #fff;
  }
}

/* 列表 */
.list-wrap {
  padding: 16rpx 24rpx;
}

.log-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.goal-name {
  flex: 1;
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.metric-tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;
  background: rgba(230, 162, 60, 0.1);
  color: #e6a23c;
  flex-shrink: 0;
}

.card-owner {
  display: flex;
  align-items: center;
  gap: 6rpx;
  margin-bottom: 16rpx;
}

.owner-text {
  font-size: 22rpx;
  color: #86909C;
}

.value-compare {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 16rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  margin-bottom: 16rpx;
}

.value-block {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  flex: 1;
}

.value-label {
  font-size: 22rpx;
  color: #86909C;
}

.value-old {
  font-size: 28rpx;
  color: #909399;
  font-weight: 600;
  text-decoration: line-through;
}

.value-new {
  font-size: 28rpx;
  color: #3D6DF7;
  font-weight: 700;
}

.value-arrow {
  display: flex;
  align-items: center;
}

.value-diff {
  padding: 8rpx 16rpx;
  border-radius: 8rpx;
  font-size: 24rpx;
  font-weight: 600;

  &.diff-up {
    background: rgba(82, 196, 26, 0.1);
    color: #52c41a;
  }

  &.diff-down {
    background: rgba(245, 34, 45, 0.1);
    color: #f5222d;
  }
}

.card-reason {
  margin-bottom: 16rpx;
  padding: 12rpx 16rpx;
  background: #F7F8FA;
  border-radius: 8rpx;
}

.reason-label {
  font-size: 24rpx;
  color: #86909C;
}

.reason-text {
  font-size: 24rpx;
  color: #4E5969;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12rpx;
  border-top: 1rpx solid #F0F0F0;
}

.footer-item {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.footer-text {
  font-size: 22rpx;
  color: #86909C;
}

/* 空状态/加载 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;
  gap: 16rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #86909C;
}

.loading-more,
.no-more {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24rpx;
  gap: 8rpx;
  font-size: 24rpx;
  color: #86909C;
}
</style>
