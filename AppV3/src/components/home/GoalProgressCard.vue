<template>
  <view class="goal-card">
    <view class="card-header">
      <view class="header-left">
        <view class="title-bar"></view>
        <text class="card-title">目标进度</text>
      </view>
      <view class="more-btn" @click="goGoalList">
        <text class="more-text">更多</text>
        <u-icon name="arrow-right" size="12" color="#86909C" />
      </view>
    </view>

    <view v-if="loading" class="loading-wrap">
      <u-loading-icon mode="circle" size="32" color="#3D6DF7"></u-loading-icon>
    </view>

    <view v-else-if="!personalGoal.hasGoal && teamSummary.count === 0" class="empty-wrap">
      <text class="empty-text">暂无目标</text>
      <view class="empty-btn" @click="goGoalList">去设置</view>
    </view>

    <view v-else class="progress-list">
      <!-- 我的目标 -->
      <view v-if="personalGoal.hasGoal" class="progress-item" @click="goPersonalGoal">
        <view class="item-header">
          <view class="item-left">
            <view class="item-icon icon-personal">
              <u-icon name="account-fill" size="14" color="#FFFFFF" />
            </view>
            <text class="item-label">我的目标</text>
            <text v-if="personalGoal.goalName" class="item-name">{{ personalGoal.goalName }}</text>
          </view>
          <text class="item-rate" :style="{ color: getRateColor(personalGoal.completionRate) }">
            {{ personalGoal.completionRateText || '0%' }}
          </text>
        </view>
        <view class="progress-bar">
          <view class="progress-fill fill-personal" :style="{ width: getBarWidth(personalGoal.completionRate) }"></view>
        </view>
        <view class="item-footer">
          <text class="footer-completed">已完成 {{ formatAmount(personalGoal.completed) }}{{ personalGoal.metricUnit }}</text>
          <text class="footer-target">目标 {{ formatAmount(personalGoal.targetValue) }}{{ personalGoal.metricUnit }}</text>
        </view>
      </view>

      <!-- 团队目标（部门负责人可见，不合并多部门） -->
      <view v-if="teamSummary.count > 0" class="progress-item" @click="goGoalList">
        <view class="item-header">
          <view class="item-left">
            <view class="item-icon icon-team">
              <u-icon name="home-fill" size="14" color="#FFFFFF" />
            </view>
            <text class="item-label">团队目标</text>
            <text class="item-name">{{ teamSummary.firstDeptName }}</text>
            <text v-if="teamSummary.count > 1" class="item-more-tag">+{{ teamSummary.count - 1 }}</text>
          </view>
          <text class="item-rate" :style="{ color: getRateColor(teamSummary.completionRate) }">
            {{ teamSummary.rateText }}
          </text>
        </view>
        <view class="progress-bar">
          <view class="progress-fill fill-team" :style="{ width: getBarWidth(teamSummary.completionRate) }"></view>
        </view>
        <view class="item-footer">
          <text class="footer-completed">已完成 {{ formatAmount(teamSummary.completed) }}</text>
          <text class="footer-target">目标 {{ formatAmount(teamSummary.targetValue) }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 首页目标进度卡片 - 展示个人目标与团队目标的横向进度条
 * @description 上半区：我的目标（getDailyView，单条本月个人目标）
 * @description 下半区：团队目标（getTeamGoals，部门负责人可见，前端汇总多条部门目标）
 */
import { ref, reactive, onMounted } from 'vue'
import { getDailyView, getTeamGoals } from '@/api/goal'

const loading = ref(true)
const personalGoal = ref({ hasGoal: false })
const teamSummary = reactive({ count: 0, firstDeptName: '', targetValue: 0, completed: 0, completionRate: 0, rateText: '0%' })

/** 口径单位映射 */
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

/** 完成率配色：≥100% 绿 / ≥70% 橙 / <70% 红 */
function getRateColor(rate) {
  if (rate >= 1) return '#00B42A'
  if (rate >= 0.7) return '#FF7D00'
  return '#F53F3F'
}

/** 进度条宽度百分比，封顶 100% */
function getBarWidth(rate) {
  const pct = Math.min(100, Math.max(0, (rate || 0) * 100))
  return pct.toFixed(1) + '%'
}

/** 金额千分位，保留整数 */
function formatAmount(val) {
  if (val === null || val === undefined || val === '') return '0'
  const num = Number(val)
  if (isNaN(num)) return '0'
  return num.toLocaleString('zh-CN', { maximumFractionDigits: 0 })
}

/** 根据个人目标 metricType 取单位 */
function getPersonalUnit() {
  const t = personalGoal.value.metricType
  return METRIC_MAP[t]?.unit || ''
}

async function loadData() {
  loading.value = true
  try {
    const [personalRes, teamRes] = await Promise.allSettled([
      getDailyView(),
      getTeamGoals({ topLevelOnly: 'true' })   // 首页汇总：顶层过滤避免翻倍；不传 periodType 对齐 Web 端"全部"Tab
    ])

    // 个人目标
    if (personalRes.status === 'fulfilled') {
      const res = personalRes.value || {}
      // AjaxResult 对关联数组merge到root（无data字段），索引数组放data字段
      const data = res.data !== undefined ? res.data : res
      data.metricUnit = METRIC_MAP[data.metricType]?.unit || ''
      personalGoal.value = data
    }

    // 团队目标：不合并多部门，取第一个顶层部门显示（多个时显示 +N 标签）
    if (teamRes.status === 'fulfilled') {
      const arr = teamRes.value?.data || []

      // 按周期优先级筛选：月度 > 季度 > 年度
      const monthGoals = arr.filter(g => String(g.periodType) === '3')
      const quarterGoals = arr.filter(g => String(g.periodType) === '2')
      const yearGoals = arr.filter(g => String(g.periodType) === '1')
      const picked = monthGoals.length > 0 ? monthGoals
        : quarterGoals.length > 0 ? quarterGoals
        : yearGoals

      // 不合并：取第一个部门显示，多个时显示 +N 标签（点击跳列表页查看全部）
      if (picked.length > 0) {
        const first = picked[0]
        teamSummary.count = picked.length
        teamSummary.firstDeptName = first.ownerName || '团队目标'
        teamSummary.targetValue = Number(first.targetValue || 0)
        teamSummary.completed = Number(first.completed || 0)
        const rate = teamSummary.targetValue > 0 ? teamSummary.completed / teamSummary.targetValue : 0
        teamSummary.completionRate = rate
        teamSummary.rateText = Math.round(rate * 100) + '%'
      }
    }
  } catch (e) {
    console.error('加载目标进度失败', e)
  } finally {
    loading.value = false
  }
}

function goPersonalGoal() {
  uni.navigateTo({ url: '/pages/goal/index' })
}
function goGoalList() {
  uni.navigateTo({ url: '/pages/goal/index' })
}

onMounted(() => {
  loadData()
})

defineExpose({ refresh: loadData })
</script>

<style lang="scss" scoped>
.goal-card {
  margin: 16rpx 24rpx 0;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;

  .header-left {
    display: flex;
    align-items: center;
    gap: 12rpx;

    .title-bar {
      width: 6rpx;
      height: 28rpx;
      background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
      border-radius: 4rpx;
    }

    .card-title {
      font-size: 30rpx;
      font-weight: 600;
      color: #1D2129;
      letter-spacing: 0.5rpx;
    }
  }

  .more-btn {
    display: flex;
    align-items: center;
    gap: 4rpx;
    padding: 8rpx 12rpx;
    border-radius: 24rpx;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active {
      background: #F5F7FA;
    }

    .more-text {
      font-size: 24rpx;
      color: #86909C;
    }
  }
}

.loading-wrap {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40rpx 0;
}

.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  padding: 32rpx 0;

  .empty-text {
    font-size: 26rpx;
    color: #86909C;
  }

  .empty-btn {
    padding: 10rpx 32rpx;
    background: linear-gradient(90deg, #3D6DF7 0%, #5B8FF9 100%);
    color: #fff;
    font-size: 24rpx;
    border-radius: 32rpx;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active {
      transform: scale(0.96);
      opacity: 0.9;
    }
  }
}

.progress-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.progress-item {
  padding: 16rpx 0;
  border-radius: 12rpx;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    background: #F5F7FA;
    transform: scale(0.99);
  }

  &:not(:last-child) {
    border-bottom: 1rpx solid #F2F3F5;
    padding-bottom: 24rpx;
  }
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;

  .item-left {
    display: flex;
    align-items: center;
    gap: 8rpx;
    flex: 1;
    min-width: 0;
  }

  .item-icon {
    width: 32rpx;
    height: 32rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .icon-personal {
    background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  }

  .icon-team {
    background: linear-gradient(135deg, #FF7D00 0%, #FFB656 100%);
  }

  .item-label {
    font-size: 26rpx;
    font-weight: 600;
    color: #1D2129;
    flex-shrink: 0;
  }

  .item-name {
    font-size: 22rpx;
    color: #86909C;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex: 1;
    min-width: 0;
  }

  .item-more-tag {
    font-size: 20rpx;
    color: #FF7D00;
    background: #FFF2E8;
    padding: 2rpx 8rpx;
    border-radius: 8rpx;
    margin-left: 4rpx;
    flex-shrink: 0;
  }

  .item-rate {
    font-size: 32rpx;
    font-weight: 700;
    letter-spacing: -0.5rpx;
    flex-shrink: 0;
    margin-left: 12rpx;
  }
}

.progress-bar {
  width: 100%;
  height: 16rpx;
  background: #EBEDF0;
  border-radius: 12rpx;
  overflow: hidden;
  margin-bottom: 12rpx;
}

.progress-fill {
  height: 100%;
  border-radius: 12rpx;
  transition: width 0.6s cubic-bezier(0.16, 1, 0.3, 1);
  min-width: 4rpx;
}

.fill-personal {
  background: linear-gradient(90deg, #3D6DF7 0%, #5B8FF9 100%);
}

.fill-team {
  background: linear-gradient(90deg, #FF7D00 0%, #FFB656 100%);
}

.item-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .footer-completed {
    font-size: 22rpx;
    color: #1D2129;
    font-weight: 500;
  }

  .footer-target {
    font-size: 22rpx;
    color: #86909C;
  }
}
</style>
