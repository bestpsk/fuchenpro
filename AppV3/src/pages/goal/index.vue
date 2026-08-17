<template>
  <view class="goal-container" :class="{ 'page-ready': pageReady }">
    <!-- 顶部渐变头部 -->
    <view class="header-section"></view>

    <!-- Tab 切换 -->
    <view class="tab-section">
      <view class="tab-item" :class="{ active: activeScope === 'personal' }" @click="switchScope('personal')">
        <text>个人目标</text>
      </view>
      <view class="tab-item" :class="{ active: activeScope === 'team' }" @click="switchScope('team')">
        <text>团队目标</text>
      </view>
    </view>

    <!-- 周期筛选 -->
    <view class="period-filter">
      <view v-for="p in periodOptions" :key="p.value" class="period-tag"
            :class="{ active: activePeriod === p.value }" @click="switchPeriod(p.value)">
        {{ p.label }}
      </view>
    </view>

    <!-- 加载态 -->
    <view v-if="loading" class="loading-wrap">
      <u-loading-icon mode="circle" size="48" color="#3D6DF7"></u-loading-icon>
      <text class="loading-text">加载中...</text>
    </view>

    <!-- 空状态 -->
    <view v-else-if="goalList.length === 0" class="empty-state">
      <view class="empty-icon">
        <u-icon name="empty-data" size="80" color="#C9CDD4" />
      </view>
      <text class="empty-text">暂无{{ activeScope === 'personal' ? '个人' : '团队' }}目标</text>
      <text class="empty-hint">{{ activeScope === 'personal' ? '请联系管理员设置目标' : '需要部门负责人权限' }}</text>
    </view>

    <!-- 目标列表 -->
    <view v-else class="list-wrap">
      <view v-for="item in goalList" :key="item.goalId" class="goal-card" @click="goDetail(item.goalId)">
        <view class="card-header">
          <view class="card-title-wrap">
            <text class="card-title">{{ item.goalName || '未命名目标' }}</text>
            <view class="card-tag" :class="getOwnerClass(item.ownerType)">
              <text>{{ getOwnerLabel(item.ownerType) }}</text>
            </view>
          </view>
          <text class="card-rate" :style="{ color: getRateColor(item.completionRate) }">
            {{ getRateText(item.completionRate) }}
          </text>
        </view>

        <view class="card-owner" v-if="item.ownerName">
          <u-icon name="account" size="12" color="#86909C" />
          <text class="owner-text">{{ item.ownerName }}</text>
        </view>

        <view class="card-values">
          <view class="value-block">
            <text class="value-label">目标值</text>
            <text class="value-num">{{ formatAmount(item.targetValue) }}{{ getMetricUnit(item.metricType) }}</text>
          </view>
          <view class="value-block">
            <text class="value-label">已完成</text>
            <text class="value-num completed">{{ formatAmount(item.completed) }}{{ getMetricUnit(item.metricType) }}</text>
          </view>
        </view>

        <view class="card-progress">
          <view class="progress-bar">
            <view class="progress-fill" :class="getProgressClass(item.completionRate)"
                  :style="{ width: getBarWidth(item.completionRate) }"></view>
          </view>
        </view>

        <view class="card-footer">
          <text class="footer-period">{{ getPeriodLabel(item.periodType) }}</text>
          <text class="footer-diff">差额 {{ formatAmount(item.diff || (item.targetValue - item.completed)) }}{{ getMetricUnit(item.metricType) }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 我的目标 - 展示数据权限内的个人/团队目标进度列表
 * @description Tab 切换个人目标/团队目标，周期筛选，点击跳转详情
 * @description 个人目标：getMyGoals 返回数据权限下所有个人目标
 * @description 团队目标：getTeamGoals 返回数据权限下所有部门目标
 */
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getMyGoals, getTeamGoals } from '@/api/goal'

const loading = ref(true)
const pageReady = ref(false)
const goalList = ref([])
const activeScope = ref('personal')  // personal / team
const activePeriod = ref('')  // ''全部 / '3'月度 / '2'季度 / '1'年度

const periodOptions = [
  { value: '', label: '全部' },
  { value: '3', label: '月度' },
  { value: '2', label: '季度' },
  { value: '1', label: '年度' }
]

const METRIC_MAP = {
  1: { label: '实收业绩', unit: '元' },
  2: { label: '消耗业绩', unit: '元' },
  3: { label: '出货金额', unit: '元' },
  4: { label: '品项件数', unit: '件' },
  5: { label: '品项金额', unit: '元' },
  6: { label: '到店客次', unit: '人次' },
  7: { label: '新客数', unit: '人次' },
  8: { label: '活跃门店数', unit: '家' }
}

const PERIOD_MAP = { 1: '年度', 2: '季度', 3: '月度', 4: '自定义' }
const OWNER_MAP = { 1: '公司', 2: '部门', 3: '门店', 4: '个人' }

function getMetricUnit(type) {
  return METRIC_MAP[type]?.unit || ''
}

function getPeriodLabel(type) {
  return PERIOD_MAP[type] || '-'
}

function getOwnerLabel(type) {
  return OWNER_MAP[type] || '-'
}

function getOwnerClass(type) {
  const map = { 1: 'tag-company', 2: 'tag-dept', 3: 'tag-store', 4: 'tag-personal' }
  return map[type] || ''
}

/** 完成率颜色：<70%红，70-100%橙，>=100%绿 */
function getRateColor(rate) {
  if (rate >= 1) return '#52c41a'
  if (rate >= 0.7) return '#fa8c16'
  return '#f5222d'
}

function getRateText(rate) {
  const r = Number(rate || 0)
  return Math.round(r * 100) + '%'
}

function getBarWidth(rate) {
  const r = Number(rate || 0)
  return Math.min(Math.max(r * 100, 0), 100) + '%'
}

function getProgressClass(rate) {
  if (rate >= 1) return 'fill-green'
  if (rate >= 0.7) return 'fill-orange'
  return 'fill-red'
}

function formatAmount(val) {
  if (val === null || val === undefined || val === '') return '0'
  const num = Number(val)
  if (isNaN(num)) return '0'
  return num.toLocaleString('zh-CN')
}

let isInitialLoad = true

async function loadData() {
  loading.value = true
  try {
    const params = {}
    if (activePeriod.value) params.periodType = activePeriod.value
    const isPersonal = activeScope.value === 'personal'
    const api = isPersonal ? getMyGoals : getTeamGoals
    const res = await api(params)
    let data = res.data || []

    // 初始加载时，个人目标为空则自动切换到团队目标
    if (isInitialLoad && isPersonal && data.length === 0) {
      activeScope.value = 'team'
      const teamRes = await getTeamGoals(params)
      data = teamRes.data || []
    }

    goalList.value = data
  } catch (e) {
    console.error('获取目标数据失败', e)
    goalList.value = []
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
    isInitialLoad = false
  }
}

function switchScope(scope) {
  if (activeScope.value === scope) return
  isInitialLoad = false  // 手动切换后不再自动回退
  activeScope.value = scope
  loadData()
}

function switchPeriod(period) {
  if (activePeriod.value === period) return
  activePeriod.value = period
  loadData()
}

function goDetail(goalId) {
  uni.navigateTo({ url: '/pages/goal/detail?goalId=' + goalId })
}

onShow(() => {
  isInitialLoad = true
  loadData()
  setTimeout(() => {
    pageReady.value = true
  }, 100)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.goal-container {
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
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
  padding: 32rpx 32rpx 72rpx;
  border-radius: 0 0 32rpx 32rpx;
  margin: 0 -24rpx 0;
}

.tab-section {
  display: flex;
  background: #FFFFFF;
  border-radius: 16rpx;
  padding: 8rpx;
  margin: -48rpx 0 0;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.08);
  position: relative;
  z-index: 1;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;
  color: #86909C;
  transition: all 0.3s;

  &.active {
    background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
    color: #FFFFFF;
    font-weight: 600;
  }
}

.period-filter {
  display: flex;
  gap: 12rpx;
  padding: 24rpx 0 16rpx;
  overflow-x: auto;
}

.period-tag {
  flex-shrink: 0;
  padding: 10rpx 24rpx;
  border-radius: 24rpx;
  font-size: 24rpx;
  color: #4E5969;
  background: #FFFFFF;
  border: 1rpx solid #E5E6EB;

  &.active {
    background: #3D6DF7;
    color: #FFFFFF;
    border-color: #3D6DF7;
  }
}

.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;
  gap: 24rpx;
}

.loading-text {
  font-size: 26rpx;
  color: #86909C;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;
  gap: 16rpx;
}

.empty-icon {
  margin-bottom: 8rpx;
}

.empty-text {
  font-size: 30rpx;
  color: #4E5969;
  font-weight: 500;
}

.empty-hint {
  font-size: 24rpx;
  color: #C9CDD4;
}

.list-wrap {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  padding-top: 8rpx;
}

.goal-card {
  background: #FFFFFF;
  border-radius: 20rpx;
  padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12rpx;
}

.card-title-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;
  min-width: 0;
}

.card-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-tag {
  flex-shrink: 0;
  padding: 4rpx 12rpx;
  border-radius: 8rpx;
  font-size: 20rpx;

  &.tag-company { background: #FFF2E8; color: #FF7D00; }
  &.tag-dept { background: #EBF0FF; color: #3D6DF7; }
  &.tag-store { background: #E8FFEA; color: #00B42A; }
  &.tag-personal { background: #F2F3F5; color: #4E5969; }
}

.card-rate {
  font-size: 32rpx;
  font-weight: 700;
  flex-shrink: 0;
  margin-left: 16rpx;
}

.card-owner {
  display: flex;
  align-items: center;
  gap: 6rpx;
  margin-bottom: 20rpx;
}

.owner-text {
  font-size: 24rpx;
  color: #86909C;
}

.card-values {
  display: flex;
  gap: 32rpx;
  margin-bottom: 20rpx;
}

.value-block {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.value-label {
  font-size: 22rpx;
  color: #86909C;
}

.value-num {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;

  &.completed {
    color: #3D6DF7;
  }
}

.card-progress {
  margin-bottom: 16rpx;
}

.progress-bar {
  height: 12rpx;
  background: #F2F3F5;
  border-radius: 6rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 6rpx;
  transition: width 0.3s ease;

  &.fill-green { background: linear-gradient(90deg, #52c41a 0%, #73d13d 100%); }
  &.fill-orange { background: linear-gradient(90deg, #fa8c16 0%, #ffa940 100%); }
  &.fill-red { background: linear-gradient(90deg, #f5222d 0%, #ff7875 100%); }
}

.card-footer {
  display: flex;
  justify-content: space-between;
  font-size: 22rpx;
  color: #86909C;
}

.footer-period {
  color: #3D6DF7;
}

.footer-diff {
  color: #86909C;
}
</style>
