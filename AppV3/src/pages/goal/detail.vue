<template>
  <view class="goal-detail-container" :class="{ 'page-ready': pageReady }">
    <!-- 顶部渐变头部 -->
    <view class="header-section">
      <text class="header-title">{{ goalData.goalName || '目标详情' }}</text>
      <view class="header-tags">
        <view class="header-tag">{{ getOwnerTypeLabel(goalData.ownerType) }}</view>
        <view class="header-tag">{{ getMetricTypeLabel(goalData.metricType) }}</view>
        <view class="header-tag">{{ getPeriodTypeLabel(goalData.periodType) }}</view>
      </view>
    </view>

    <!-- 加载骨架 -->
    <view v-if="loading" class="loading-wrap">
      <view class="skeleton-card">
        <u-icon name="loading" size="32" color="#3D6DF7"></u-icon>
        <text class="loading-text">加载中...</text>
      </view>
    </view>

    <view v-else-if="goalData.goalId" class="detail-content">
      <!-- 目标值卡片 + 完成率圆环 -->
      <view class="main-card">
        <view class="main-card-top">
          <view class="target-block">
            <text class="target-label">目标值</text>
            <view class="target-value-row">
              <text class="target-value">{{ formatNumber(goalData.targetValue) }}</text>
              <text class="target-unit">{{ goalData.unit }}</text>
            </view>
            <view class="completed-row">
              <text class="completed-label">已完成</text>
              <text class="completed-value">{{ formatNumber(progressData.completed) }}{{ goalData.unit }}</text>
            </view>
            <view class="diff-row">
              <text class="diff-label">差额</text>
              <text class="diff-value">{{ formatNumber(progressData.diff) }}{{ goalData.unit }}</text>
            </view>
          </view>

          <!-- 圆环进度 -->
          <view class="ring-wrap">
            <view class="ring-bg" :style="ringStyle">
              <view class="ring-inner">
                <text class="ring-percent" :style="{ color: rateColor }">{{ completionRateText }}</text>
                <text class="ring-label">完成率</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 基本信息 -->
      <view class="info-card">
        <view class="card-header">
          <text class="card-title">基本信息</text>
        </view>
        <view class="info-grid">
          <view class="info-cell">
            <text class="info-cell-label">归属名称</text>
            <text class="info-cell-value">{{ goalData.ownerName || '-' }}</text>
          </view>
          <view class="info-cell">
            <text class="info-cell-label">周期名称</text>
            <text class="info-cell-value">{{ goalData.periodName || '-' }}</text>
          </view>
          <view class="info-cell">
            <text class="info-cell-label">起止日期</text>
            <text class="info-cell-value">{{ goalData.startDate }} ~ {{ goalData.endDate }}</text>
          </view>
          <view class="info-cell">
            <text class="info-cell-label">状态</text>
            <text class="info-cell-value">
              <text :class="goalData.status === '0' ? 'text-green' : 'text-gray'">{{ goalData.status === '0' ? '启用' : '停用' }}</text>
            </text>
          </view>
          <view v-if="goalData.activityName" class="info-cell">
            <text class="info-cell-label">活动名称</text>
            <text class="info-cell-value">{{ goalData.activityName }}</text>
          </view>
          <view v-if="goalData.remark" class="info-cell info-cell-full">
            <text class="info-cell-label">备注</text>
            <text class="info-cell-value">{{ goalData.remark }}</text>
          </view>
        </view>
      </view>

      <!-- 核心指标 -->
      <view class="metrics-card">
        <view class="card-header">
          <text class="card-title">核心指标</text>
        </view>
        <view class="metrics-grid">
          <view class="metric-cell">
            <text class="metric-cell-label">已过天数</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value">{{ progressData.passedWorkDays ?? 0 }}</text>
              <text class="metric-cell-unit">天</text>
            </view>
          </view>
          <view class="metric-cell">
            <text class="metric-cell-label">剩余天数</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value">{{ progressData.remainWorkDays ?? 0 }}</text>
              <text class="metric-cell-unit">天</text>
            </view>
          </view>
          <view class="metric-cell">
            <text class="metric-cell-label">当前日均产出</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value">{{ formatNumber(progressData.currentDaily) }}</text>
              <text class="metric-cell-unit">{{ goalData.unit }}/天</text>
            </view>
          </view>
          <view class="metric-cell">
            <text class="metric-cell-label">剩余日均需完成</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value remain-need">{{ formatNumber(progressData.remainDailyNeed) }}</text>
              <text class="metric-cell-unit">{{ goalData.unit }}/天</text>
            </view>
          </view>
          <view class="metric-cell">
            <text class="metric-cell-label">预计达成日</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value metric-cell-date">{{ formatAchieveDate(progressData.expectedAchieveDate) }}</text>
            </view>
          </view>
          <view class="metric-cell">
            <text class="metric-cell-label">月末预测完成率</text>
            <view class="metric-cell-value-row">
              <text class="metric-cell-value" :style="{ color: forecastColor }">{{ forecastRateText }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 操作按钮 -->
      <view class="action-bar">
        <view class="action-btn adjust" @click="openAdjustPopup">
          <u-icon name="edit-pen" size="16" color="#fff"></u-icon>
          <text class="action-btn-text">调整目标</text>
        </view>
        <view class="action-btn edit" @click="handleEdit">
          <u-icon name="edit" size="16" color="#3D6DF7"></u-icon>
          <text class="action-btn-text">编辑</text>
        </view>
        <view class="action-btn log" @click="handleViewLog">
          <u-icon name="file-text" size="16" color="#e6a23c"></u-icon>
          <text class="action-btn-text">调整记录</text>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-else class="empty-state">
      <u-icon name="empty-data" size="80" color="#C9CDD4"></u-icon>
      <text class="empty-text">目标不存在或已删除</text>
    </view>

    <!-- 调整目标弹窗 -->
    <u-popup :show="showAdjust" mode="center" round="16" @close="closeAdjustPopup">
      <view class="adjust-popup">
        <view class="adjust-title">调整目标值</view>
        <view class="adjust-form">
          <view class="adjust-item">
            <text class="adjust-label">当前目标值</text>
            <text class="adjust-current">{{ formatNumber(goalData.targetValue) }}{{ goalData.unit }}</text>
          </view>
          <view class="adjust-item">
            <text class="adjust-label">新目标值</text>
            <u-number-box v-model="adjustForm.newValue" :min="0" :step="100" :precision="2" :inputWidth="120"></u-number-box>
          </view>
          <view class="adjust-item adjust-item-column">
            <text class="adjust-label">调整原因</text>
            <textarea class="adjust-textarea" v-model="adjustForm.reason" placeholder="请输入调整原因" maxlength="500"></textarea>
          </view>
        </view>
        <view class="adjust-btns">
          <view class="adjust-btn cancel" @click="closeAdjustPopup">取消</view>
          <view class="adjust-btn confirm" @click="submitAdjust">确定</view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 目标详情页 - 展示目标基本信息、进度、核心指标，支持调整目标值
 */
import { ref, reactive, computed } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getGoal, getGoalProgress, adjustGoal } from '@/api/goal'

const metricTypeMap = {
  1: '实收业绩', 2: '消耗业绩', 3: '出货金额', 4: '品项件数',
  5: '品项金额', 6: '到店客次', 7: '新客数', 8: '活跃门店数'
}
const ownerTypeMap = { 1: '公司', 2: '部门', 3: '门店', 4: '个人' }
const periodTypeMap = { 1: '年度', 2: '季度', 3: '月度', 4: '自定义' }

function getMetricTypeLabel(val) {
  return metricTypeMap[val] || '-'
}
function getOwnerTypeLabel(val) {
  return ownerTypeMap[val] || '-'
}
function getPeriodTypeLabel(val) {
  return periodTypeMap[val] || '-'
}

const loading = ref(true)
const pageReady = ref(false)
const goalData = ref({})
const progressData = ref({})
const showAdjust = ref(false)
const adjustForm = reactive({
  goalId: null,
  newValue: 0,
  reason: ''
})

function formatNumber(val) {
  if (val === null || val === undefined || val === '') return '0'
  const num = Number(val)
  if (isNaN(num)) return '0'
  return num.toLocaleString('zh-CN')
}

function formatAchieveDate(date) {
  if (!date) return '本月内'
  const str = String(date)
  const m = str.match(/(\d{4})-(\d{1,2})-(\d{1,2})/)
  if (m) return `${parseInt(m[2])}月${parseInt(m[3])}日`
  return str
}

function getRateColor(rate) {
  if (rate >= 1) return '#52c41a'
  if (rate >= 0.7) return '#fa8c16'
  return '#f5222d'
}

const rateColor = computed(() => getRateColor(progressData.value.completionRate || 0))
const forecastColor = computed(() => getRateColor(progressData.value.forecastRate || 0))

const completionRateText = computed(() => {
  const rate = progressData.value.completionRate || 0
  return Math.round(rate * 100) + '%'
})

const forecastRateText = computed(() => {
  const rate = progressData.value.forecastRate || 0
  return Math.round(rate * 100) + '%'
})

const ringPercent = computed(() => {
  const rate = progressData.value.completionRate || 0
  return Math.min(Math.max(rate * 100, 0), 100)
})

const ringStyle = computed(() => {
  const pct = ringPercent.value
  const color = rateColor.value
  return {
    background: `conic-gradient(${color} 0% ${pct}%, #EBEDF0 ${pct}% 100%)`
  }
})

async function loadDetail(goalId) {
  loading.value = true
  try {
    const [goalRes, progressRes] = await Promise.all([
      getGoal(goalId),
      getGoalProgress({ goalId })
    ])
    goalData.value = goalRes.data || {}
    progressData.value = progressRes.data || {}
  } catch (e) {
    console.error('加载目标详情失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function openAdjustPopup() {
  adjustForm.goalId = goalData.value.goalId
  adjustForm.newValue = Number(goalData.value.targetValue) || 0
  adjustForm.reason = ''
  showAdjust.value = true
}

function closeAdjustPopup() {
  showAdjust.value = false
}

async function submitAdjust() {
  if (!adjustForm.reason || !adjustForm.reason.trim()) {
    uni.showToast({ title: '请输入调整原因', icon: 'none' })
    return
  }
  try {
    await adjustGoal({
      goalId: adjustForm.goalId,
      newValue: adjustForm.newValue,
      reason: adjustForm.reason.trim()
    })
    uni.showToast({ title: '调整成功', icon: 'success' })
    showAdjust.value = false
    loadDetail(adjustForm.goalId)
  } catch (e) {
    console.error('调整失败', e)
  }
}

function handleEdit() {
  uni.navigateTo({ url: '/pages/goal/form?goalId=' + goalData.value.goalId })
}

function handleViewLog() {
  uni.navigateTo({ url: '/pages/goal/adjustLog?goalId=' + goalData.value.goalId })
}

onLoad((options) => {
  const goalId = options.goalId
  if (goalId) {
    loadDetail(goalId)
  }
})

onShow(() => {
  if (goalData.value.goalId) {
    loadDetail(goalData.value.goalId)
  }
  setTimeout(() => {
    pageReady.value = true
  }, 100)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.goal-detail-container {
  min-height: 100vh;
  padding: 0 24rpx 40rpx;
  opacity: 0;
  transform: translateY(20rpx);
  transition: opacity 0.5s ease, transform 0.5s ease;

  &.page-ready {
    opacity: 1;
    transform: translateY(0);
  }
}

.header-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 56rpx 24rpx 48rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
  margin: -24rpx -24rpx 28rpx;
  border-radius: 0 0 36rpx 36rpx;
}

.header-title {
  font-size: 34rpx;
  color: #fff;
  font-weight: 700;
}

.header-tags {
  display: flex;
  gap: 12rpx;
  flex-wrap: wrap;
  justify-content: center;
}

.header-tag {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.9);
  background: rgba(255, 255, 255, 0.15);
  padding: 4rpx 16rpx;
  border-radius: 12rpx;
}

.loading-wrap {
  display: flex;
  justify-content: center;
  padding: 120rpx 0;
}

.skeleton-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.loading-text {
  font-size: 26rpx;
  color: #86909C;
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

/* 主卡片 */
.main-card {
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx 28rpx;
  box-shadow: 0 4rpx 24rpx rgba(61, 109, 247, 0.08);
}

.main-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24rpx;
}

.target-block {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 14rpx;
  min-width: 0;
}

.target-label,
.completed-label,
.diff-label {
  font-size: 24rpx;
  color: #86909C;
}

.target-value-row {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}

.target-value {
  font-size: 56rpx;
  font-weight: 700;
  color: #1D2129;
  line-height: 1.1;
}

.target-unit {
  font-size: 26rpx;
  color: #86909C;
}

.completed-row,
.diff-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.completed-label,
.diff-label {
  width: 80rpx;
}

.completed-value {
  font-size: 26rpx;
  color: #4E5969;
  font-weight: 600;
}

.diff-value {
  font-size: 26rpx;
  color: #fa8c16;
  font-weight: 600;
}

.ring-wrap {
  width: 200rpx;
  height: 200rpx;
  flex-shrink: 0;
}

.ring-bg {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ring-inner {
  width: 156rpx;
  height: 156rpx;
  border-radius: 50%;
  background: #fff;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4rpx;
}

.ring-percent {
  font-size: 32rpx;
  font-weight: 700;
}

.ring-label {
  font-size: 20rpx;
  color: #86909C;
}

/* 信息卡片 */
.info-card,
.metrics-card {
  background: #fff;
  border-radius: 20rpx;
  padding: 28rpx;
  box-shadow: 0 4rpx 20rpx rgba(61, 109, 247, 0.06);
}

.card-header {
  margin-bottom: 24rpx;
}

.card-title {
  font-size: 29rpx;
  font-weight: 700;
  color: #1D2129;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20rpx;
}

.info-cell {
  display: flex;
  flex-direction: column;
  gap: 8rpx;

  &.info-cell-full {
    grid-column: 1 / -1;
  }
}

.info-cell-label {
  font-size: 23rpx;
  color: #86909C;
}

.info-cell-value {
  font-size: 26rpx;
  color: #1D2129;
}

.text-green {
  color: #52c41a;
}

.text-gray {
  color: #909399;
}

/* 核心指标 */
.metrics-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20rpx;
}

.metric-cell {
  background: #F7F8FA;
  border-radius: 14rpx;
  padding: 24rpx 20rpx;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.metric-cell-label {
  font-size: 23rpx;
  color: #86909C;
}

.metric-cell-value-row {
  display: flex;
  align-items: baseline;
  gap: 6rpx;
}

.metric-cell-value {
  font-size: 32rpx;
  font-weight: 700;
  color: #1D2129;
}

.metric-cell-date {
  font-size: 30rpx;
}

.metric-cell-unit {
  font-size: 22rpx;
  color: #86909C;
}

.remain-need {
  color: #3D6DF7;
}

/* 操作按钮 */
.action-bar {
  display: flex;
  gap: 16rpx;
  padding: 8rpx 0;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  padding: 24rpx 0;
  border-radius: 16rpx;
  background: #fff;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &.adjust {
    background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);

    .action-btn-text {
      color: #fff;
    }
  }
}

.action-btn-text {
  font-size: 24rpx;
  color: #4E5969;
}

/* 空状态 */
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

/* 调整弹窗 */
.adjust-popup {
  padding: 32rpx;
  width: 600rpx;
}

.adjust-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #1D2129;
  text-align: center;
  margin-bottom: 24rpx;
}

.adjust-form {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.adjust-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;

  &.adjust-item-column {
    flex-direction: column;
    align-items: flex-start;
  }
}

.adjust-label {
  font-size: 26rpx;
  color: #4E5969;
}

.adjust-current {
  font-size: 28rpx;
  color: #3D6DF7;
  font-weight: 600;
}

.adjust-textarea {
  width: 100%;
  min-height: 120rpx;
  background: #F5F7FA;
  border-radius: 12rpx;
  padding: 16rpx;
  font-size: 26rpx;
  color: #1D2129;
}

.adjust-btns {
  display: flex;
  gap: 24rpx;
  margin-top: 32rpx;
}

.adjust-btn {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;

  &.cancel {
    background: #F5F7FA;
    color: #4E5969;
  }

  &.confirm {
    background: #3D6DF7;
    color: #fff;
  }
}
</style>
