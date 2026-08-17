<template>
  <view class="dashboard-container">
    <!-- 顶部筛选 -->
    <view class="filter-section">
      <view class="filter-row">
        <view class="search-box" @click="toggleFilter">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <text class="filter-text">筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
        <view class="rank-btn" :class="{ active: rankingMode }" @click="toggleRanking">
          <u-icon name="arrow-up" size="14" :color="rankingMode ? '#fff' : '#e6a23c'"></u-icon>
          <text>{{ rankingMode ? '退出排名' : '按完成率排名' }}</text>
        </view>
      </view>
    </view>

    <!-- 筛选弹窗 -->
    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">口径类型</view>
          <view class="form-options">
            <view v-for="item in metricTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.metricType === item.value }" @click="setFilter('metricType', item.value)">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">周期类型</view>
          <view class="form-options">
            <view v-for="item in periodTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.periodType === item.value }" @click="setFilter('periodType', item.value)">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">归属层级</view>
          <view class="form-options">
            <view v-for="item in ownerTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.ownerType === item.value }" @click="setFilter('ownerType', item.value)">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-btns">
          <view class="popup-btn reset" @click="resetFilter">重置</view>
          <view class="popup-btn confirm" @click="confirmFilter">确定</view>
        </view>
      </view>
    </u-popup>

    <!-- 汇总卡片 -->
    <view class="summary-grid">
      <view class="summary-card summary-total">
        <text class="summary-label">目标总数</text>
        <text class="summary-value">{{ summary.total }}</text>
        <text class="summary-sub">个目标</text>
      </view>
      <view class="summary-card summary-avg">
        <text class="summary-label">平均完成率</text>
        <text class="summary-value">{{ summary.avgRateText }}</text>
        <text class="summary-sub">整体进度</text>
      </view>
      <view class="summary-card summary-achieved">
        <text class="summary-label">已达成</text>
        <text class="summary-value">{{ summary.achieved }}</text>
        <text class="summary-sub">≥ 100%</text>
      </view>
      <view class="summary-card summary-warning">
        <text class="summary-label">预警</text>
        <text class="summary-value">{{ summary.warning }}</text>
        <text class="summary-sub">&lt; 70%</text>
      </view>
    </view>

    <!-- 进度列表 -->
    <view class="list-wrap">
      <view v-if="list.length > 0">
        <view v-for="(item, index) in list" :key="item.goalId || index" class="progress-card" @click="handleDetail(item)">
          <view v-if="rankingMode" class="rank-badge" :class="getRankClass(index)">
            <text>{{ index + 1 }}</text>
          </view>
          <view class="card-main">
            <view class="card-top">
              <text class="goal-name">{{ item.goalName }}</text>
              <view class="rate-tag" :style="{ color: getRateColor(item.completionRate), background: getRateBg(item.completionRate) }">
                <text>{{ formatRate(item.completionRate) }}</text>
              </view>
            </view>
            <view class="card-tags">
              <view class="tag tag-owner">{{ getOwnerTypeLabel(item.ownerType) }} · {{ item.ownerName }}</view>
              <view class="tag tag-metric">{{ getMetricTypeLabel(item.metricType) }}</view>
            </view>
            <view class="progress-bar-wrap">
              <view class="progress-bar-bg">
                <view class="progress-bar-fill" :style="{ width: getRatePercent(item.completionRate), background: getRateColor(item.completionRate) }"></view>
              </view>
            </view>
            <view class="card-values">
              <view class="value-item">
                <text class="value-label">目标</text>
                <text class="value-text">{{ formatNumber(item.targetValue) }}{{ item.unit }}</text>
              </view>
              <view class="value-item">
                <text class="value-label">已完成</text>
                <text class="value-text text-green">{{ formatNumber(item.completed) }}{{ item.unit }}</text>
              </view>
              <view class="value-item">
                <text class="value-label">差额</text>
                <text class="value-text" :class="getDiffClass(item.diff)">{{ formatNumber(item.diff) }}{{ item.unit }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view v-else-if="!loading" class="empty-state">
        <u-icon name="empty-data" size="80" color="#C9CDD4"></u-icon>
        <text class="empty-text">暂无目标进度数据</text>
      </view>

      <view v-if="loading" class="loading-more">
        <u-icon name="loading" size="16" color="#3D6DF7"></u-icon>
        <text>加载中...</text>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 目标看板页 - 展示目标进度概览、汇总、排名
 */
import { ref, reactive, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getGoalProgress, getGoalRanking } from '@/api/goal'

const ownerTypeOptions = [
  { value: '1', label: '公司' },
  { value: '2', label: '部门' },
  { value: '3', label: '门店' },
  { value: '4', label: '个人' }
]
const periodTypeOptions = [
  { value: '1', label: '年度' },
  { value: '2', label: '季度' },
  { value: '3', label: '月度' },
  { value: '4', label: '自定义' }
]
const metricTypeOptions = [
  { value: '1', label: '实收业绩' },
  { value: '2', label: '消耗业绩' },
  { value: '3', label: '出货金额' },
  { value: '4', label: '品项件数' },
  { value: '5', label: '品项金额' },
  { value: '6', label: '到店客次' },
  { value: '7', label: '新客数' },
  { value: '8', label: '活跃门店数' }
]

const metricTypeMap = Object.fromEntries(metricTypeOptions.map(o => [o.value, o.label]))
const ownerTypeMap = Object.fromEntries(ownerTypeOptions.map(o => [o.value, o.label]))

const list = ref([])
const loading = ref(false)
const showFilter = ref(false)
const rankingMode = ref(false)
const summary = reactive({
  total: 0,
  avgRateText: '0%',
  achieved: 0,
  warning: 0
})

const queryParams = reactive({
  metricType: '',
  periodType: '',
  ownerType: ''
})

function getOwnerTypeLabel(val) {
  return ownerTypeMap[String(val)] || '-'
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

function formatRate(rate) {
  const r = Number(rate) || 0
  return Math.round(r * 100) + '%'
}

function getRatePercent(rate) {
  const r = Number(rate) || 0
  return Math.min(Math.max(r * 100, 0), 100) + '%'
}

function getRateColor(rate) {
  const r = Number(rate) || 0
  if (r >= 1) return '#52c41a'
  if (r >= 0.7) return '#fa8c16'
  return '#f5222d'
}

function getRateBg(rate) {
  const color = getRateColor(rate)
  return color + '1a'
}

function getDiffClass(diff) {
  const d = Number(diff) || 0
  return d >= 0 ? 'text-green' : 'text-red'
}

function getRankClass(index) {
  if (index === 0) return 'rank-gold'
  if (index === 1) return 'rank-silver'
  if (index === 2) return 'rank-bronze'
  return ''
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function setFilter(key, value) {
  if (queryParams[key] === value) {
    queryParams[key] = ''
  } else {
    queryParams[key] = value
  }
}

function resetFilter() {
  queryParams.metricType = ''
  queryParams.periodType = ''
  queryParams.ownerType = ''
}

function confirmFilter() {
  showFilter.value = false
  loadList()
}

function toggleRanking() {
  rankingMode.value = !rankingMode.value
  loadList()
}

async function loadList() {
  loading.value = true
  try {
    const api = rankingMode.value ? getGoalRanking : getGoalProgress
    const res = await api(queryParams)
    const data = res.data || []
    list.value = Array.isArray(data) ? data : []

    // 计算汇总
    const total = list.value.length
    const rates = list.value.map(i => Number(i.completionRate) || 0)
    const avgRate = total > 0 ? rates.reduce((s, r) => s + r, 0) / total : 0
    const achieved = rates.filter(r => r >= 1).length
    const warning = rates.filter(r => r < 0.7).length

    summary.total = total
    summary.avgRateText = Math.round(avgRate * 100) + '%'
    summary.achieved = achieved
    summary.warning = warning
  } catch (e) {
    console.error('加载看板失败', e)
    list.value = []
  } finally {
    loading.value = false
  }
}

function handleDetail(item) {
  if (item.goalId) {
    uni.navigateTo({ url: '/pages/goal/detail?goalId=' + item.goalId })
  }
}

onShow(() => {
  loadList()
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.dashboard-container {
  min-height: 100vh;
  padding-bottom: 40rpx;
}

/* 筛选栏 */
.filter-section {
  padding: 16rpx 24rpx;
  background: #fff;
  position: sticky;
  top: 0;
  z-index: 10;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.search-box {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: #F5F7FA;
  border-radius: 32rpx;
  padding: 12rpx 24rpx;
}

.filter-text {
  flex: 1;
  font-size: 26rpx;
  color: #86909C;
}

.icon-rotate {
  transform: rotate(180deg);
  transition: transform 0.2s;
}

.rank-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 12rpx 24rpx;
  border-radius: 32rpx;
  background: rgba(230, 162, 60, 0.1);
  color: #e6a23c;
  font-size: 24rpx;

  &.active {
    background: #e6a23c;
    color: #fff;
  }
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

.form-options {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.option-tag {
  font-size: 24rpx;
  color: #4E5969;
  background: #F5F7FA;
  padding: 10rpx 24rpx;
  border-radius: 8rpx;
  border: 1rpx solid transparent;

  &.active {
    color: #3D6DF7;
    background: #E8F0FE;
    border-color: #3D6DF7;
  }
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

/* 汇总卡片 */
.summary-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16rpx;
  padding: 16rpx 24rpx;
}

.summary-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.summary-label {
  font-size: 24rpx;
  color: #86909C;
}

.summary-value {
  font-size: 40rpx;
  font-weight: 700;
  color: #1D2129;
}

.summary-sub {
  font-size: 22rpx;
  color: #C9CDD4;
}

/* 进度列表 */
.list-wrap {
  padding: 0 24rpx;
}

.progress-card {
  background: #fff;
  border-radius: 16rpx;
  margin-bottom: 16rpx;
  padding: 24rpx;
  display: flex;
  gap: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.rank-badge {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  font-weight: 700;
  background: #F5F7FA;
  color: #86909C;
  flex-shrink: 0;

  &.rank-gold {
    background: linear-gradient(135deg, #FFD700, #FFA500);
    color: #fff;
  }

  &.rank-silver {
    background: linear-gradient(135deg, #C0C0C0, #A8A8A8);
    color: #fff;
  }

  &.rank-bronze {
    background: linear-gradient(135deg, #CD7F32, #B87333);
    color: #fff;
  }
}

.card-main {
  flex: 1;
  min-width: 0;
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

.rate-tag {
  padding: 4rpx 12rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 600;
  flex-shrink: 0;
}

.card-tags {
  display: flex;
  gap: 8rpx;
  margin-bottom: 16rpx;
  flex-wrap: wrap;
}

.tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 240rpx;

  &.tag-owner {
    background: rgba(61, 109, 247, 0.08);
    color: #3D6DF7;
  }

  &.tag-metric {
    background: rgba(230, 162, 60, 0.1);
    color: #e6a23c;
  }
}

.progress-bar-wrap {
  margin-bottom: 16rpx;
}

.progress-bar-bg {
  width: 100%;
  height: 12rpx;
  background: #EBEDF0;
  border-radius: 6rpx;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  border-radius: 6rpx;
  transition: width 0.4s ease;
}

.card-values {
  display: flex;
  gap: 32rpx;
}

.value-item {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.value-label {
  font-size: 22rpx;
  color: #86909C;
}

.value-text {
  font-size: 26rpx;
  color: #1D2129;
  font-weight: 600;
}

.text-green {
  color: #52c41a;
}

.text-red {
  color: #f5222d;
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

.loading-more {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24rpx;
  gap: 8rpx;
  font-size: 24rpx;
  color: #86909C;
}
</style>
