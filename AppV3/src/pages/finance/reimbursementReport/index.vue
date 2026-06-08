<template>
  <view class="report-page">
    <scroll-view scroll-y class="report-content" :refresher-enabled="true" :refresher-triggered="refreshing" @refresherrefresh="onRefresh">

      <!-- 统计卡片 -->
      <view class="stat-cards-grid">
        <view class="stat-card blue-card">
          <text class="sc-label">本月报销总额</text>
          <text class="sc-value">¥{{ formatMoney(monthTotal) }}</text>
        </view>
        <view class="stat-card blue-card">
          <text class="sc-label">本年报销总额</text>
          <text class="sc-value">¥{{ formatMoney(yearTotal) }}</text>
        </view>
        <view class="stat-card orange-card">
          <text class="sc-label">员工支出</text>
          <text class="sc-value">¥{{ formatMoney(employeeExpense) }}</text>
        </view>
        <view class="stat-card green-card">
          <text class="sc-label">公司支出</text>
          <text class="sc-value">¥{{ formatMoney(companyExpense) }}</text>
        </view>
      </view>

      <!-- 月度趋势 -->
      <view class="section-block">
        <view class="block-header" @click="monthExpanded = !monthExpanded">
          <text class="block-title">月度趋势</text>
          <u-icon :name="monthExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
        </view>
        <view v-if="monthExpanded" class="chart-section">
          <view v-if="monthData.length > 0" class="bar-chart">
            <view v-for="(item, idx) in monthData" :key="idx" class="bar-item">
              <view class="bar-wrapper">
                <view class="bar-fill" :style="{ height: getBarHeight(item.totalAmount || item.total_expense || 0) }"></view>
              </view>
              <text class="bar-amount">{{ formatShort(item.totalAmount || item.total_expense || 0) }}</text>
              <text class="bar-label">{{ item.month }}</text>
            </view>
          </view>
          <view v-else class="empty-block">
            <text class="empty-text">暂无月度数据</text>
          </view>
        </view>
      </view>

      <!-- 分类占比 -->
      <view class="section-block">
        <view class="block-header" @click="categoryExpanded = !categoryExpanded">
          <text class="block-title">分类占比</text>
          <u-icon :name="categoryExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
        </view>
        <view v-if="categoryExpanded" class="category-section">
          <view v-if="categoryData.length > 0" class="category-list">
            <view v-for="(item, idx) in categoryData" :key="idx" class="category-item">
              <view class="category-header">
                <view class="category-dot" :style="{ background: categoryColors[idx % categoryColors.length] }"></view>
                <text class="category-name">{{ item.categoryName || categoryNames[item.category] || item.category }}</text>
                <text class="category-amount">¥{{ formatMoney(item.totalAmount || item.total_expense || 0) }}</text>
              </view>
              <view class="progress-bar">
                <view class="progress-fill" :style="{ width: getCategoryPercent(item) + '%', background: categoryColors[idx % categoryColors.length] }"></view>
              </view>
              <text class="category-percent">{{ getCategoryPercent(item) }}%</text>
            </view>
          </view>
          <view v-else class="empty-block">
            <text class="empty-text">暂无分类数据</text>
          </view>
        </view>
      </view>

      <!-- 部门报销排名 -->
      <view class="section-block">
        <view class="block-header" @click="deptExpanded = !deptExpanded">
          <text class="block-title">部门报销排名</text>
          <u-icon :name="deptExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
        </view>
        <view v-if="deptExpanded" class="rank-section">
          <view v-if="deptData.length > 0" class="rank-list">
            <view v-for="(item, idx) in deptData" :key="idx" class="rank-item">
              <view class="rank-index" :class="{ 'top3': idx < 3 }">
                <text class="rank-index-text">{{ idx + 1 }}</text>
              </view>
              <view class="rank-info">
                <text class="rank-name">{{ item.deptName }}</text>
                <text class="rank-count">{{ item.count || 0 }}次</text>
              </view>
              <text class="rank-amount">¥{{ formatMoney(item.totalAmount || item.total_expense || 0) }}</text>
            </view>
          </view>
          <view v-else class="empty-block">
            <text class="empty-text">暂无部门数据</text>
          </view>
        </view>
      </view>

      <!-- 个人报销排名 -->
      <view class="section-block">
        <view class="block-header" @click="userExpanded = !userExpanded">
          <text class="block-title">个人报销排名</text>
          <u-icon :name="userExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
        </view>
        <view v-if="userExpanded" class="rank-section">
          <view v-if="userData.length > 0" class="rank-list">
            <view v-for="(item, idx) in userData" :key="idx" class="rank-item">
              <view class="rank-index" :class="{ 'top3': idx < 3 }">
                <text class="rank-index-text">{{ idx + 1 }}</text>
              </view>
              <view class="rank-info">
                <text class="rank-name">{{ item.userName || item.applicantName }}</text>
                <text class="rank-count">{{ item.count || 0 }}次</text>
              </view>
              <text class="rank-amount">¥{{ formatMoney(item.totalAmount || item.total_expense || 0) }}</text>
            </view>
          </view>
          <view v-else class="empty-block">
            <text class="empty-text">暂无个人数据</text>
          </view>
        </view>
      </view>

      <view class="bottom-spacer"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { reportByMonth, reportByCategory, reportByDept, reportByUser, reportByExpenseType } from '@/api/finance/reimbursement'

const monthTotal = ref(0)
const yearTotal = ref(0)
const employeeExpense = ref(0)
const companyExpense = ref(0)

const monthData = ref([])
const categoryData = ref([])
const deptData = ref([])
const userData = ref([])

const monthExpanded = ref(true)
const categoryExpanded = ref(true)
const deptExpanded = ref(true)
const userExpanded = ref(true)

const categoryNames = { '1': '行程买票', '2': '销售费用', '3': '行政支出', '4': '其它' }
const categoryColors = ['#3D6DF7', '#FF6B35', '#00B42A', '#722ED1']

const monthMaxAmount = ref(1)
const loading = ref(false)
const refreshing = ref(false)

function formatMoney(value) {
  const num = Number(value) || 0
  return num.toFixed(2)
}

function formatShort(value) {
  const num = Number(value) || 0
  if (num >= 10000) return (num / 10000).toFixed(1) + '万'
  return num.toFixed(0)
}

function getBarHeight(value) {
  const num = Number(value) || 0
  if (monthMaxAmount.value <= 0) return '0%'
  const percent = Math.max((num / monthMaxAmount.value) * 100, 2)
  return percent + '%'
}

function getCategoryPercent(item) {
  const total = categoryData.value.reduce((s, d) => s + (Number(d.totalAmount ?? d.total_expense) ?? 0), 0)
  if (total <= 0) return 0
  const val = Number(item.totalAmount ?? item.total_expense) ?? 0
  return Math.round((val / total) * 100)
}

async function loadReport() {
  if (loading.value) return
  loading.value = true
  uni.showLoading({ title: '加载中...' })

  const currentYear = new Date().getFullYear()

  try {
    const [monthRes, categoryRes, deptRes, userRes, expenseTypeRes] = await Promise.allSettled([
      reportByMonth({ year: currentYear }),
      reportByCategory({}),
      reportByDept({}),
      reportByUser({}),
      reportByExpenseType({})
    ])

    // 月度趋势
    if (monthRes.status === 'fulfilled') {
      try {
        const mData = monthRes.value.data ?? monthRes.value ?? []
        monthData.value = mData
        const currentMonth = new Date().getMonth() + 1
        const monthItem = mData.find(d => Number(d.month) === currentMonth || String(d.month).endsWith('-' + String(currentMonth).padStart(2, '0')))
        monthTotal.value = monthItem?.totalAmount ?? monthItem?.total_expense ?? 0
        yearTotal.value = mData.reduce((sum, d) => sum + (Number(d.totalAmount ?? d.total_expense) ?? 0), 0)
        monthMaxAmount.value = Math.max(...mData.map(d => Number(d.totalAmount ?? d.total_expense) ?? 0), 1)
      } catch (e) {
        console.error('处理月度报表数据失败:', e)
      }
    } else {
      console.error('加载月度报表失败:', monthRes.reason)
    }

    // 分类占比
    if (categoryRes.status === 'fulfilled') {
      try {
        categoryData.value = categoryRes.value.data ?? categoryRes.value ?? []
      } catch (e) {
        console.error('处理分类报表数据失败:', e)
      }
    } else {
      console.error('加载分类报表失败:', categoryRes.reason)
    }

    // 部门报销排名
    if (deptRes.status === 'fulfilled') {
      try {
        deptData.value = deptRes.value.data ?? deptRes.value ?? []
      } catch (e) {
        console.error('处理部门报表数据失败:', e)
      }
    } else {
      console.error('加载部门报表失败:', deptRes.reason)
    }

    // 个人报销排名
    if (userRes.status === 'fulfilled') {
      try {
        userData.value = userRes.value.data ?? userRes.value ?? []
      } catch (e) {
        console.error('处理个人报表数据失败:', e)
      }
    } else {
      console.error('加载个人报表失败:', userRes.reason)
    }

    // 支出类型
    if (expenseTypeRes.status === 'fulfilled') {
      try {
        const eData = expenseTypeRes.value.data ?? expenseTypeRes.value ?? []
        const empItem = eData.find(d => String(d.expenseType ?? d.expense_type) === '1')
        employeeExpense.value = empItem?.totalAmount ?? empItem?.total_expense ?? 0
        const compItem = eData.find(d => String(d.expenseType ?? d.expense_type) === '2')
        companyExpense.value = compItem?.totalAmount ?? compItem?.total_expense ?? 0
      } catch (e) {
        console.error('处理支出类型报表数据失败:', e)
      }
    } else {
      console.error('加载支出类型报表失败:', expenseTypeRes.reason)
    }
  } finally {
    loading.value = false
    uni.hideLoading()
  }
}

function onRefresh() {
  refreshing.value = true
  loadReport().finally(() => {
    refreshing.value = false
  })
}

onMounted(() => {
  loadReport()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.report-page { display: flex; flex-direction: column; height: 100%; background: #F5F7FA; padding: 0 24rpx; overflow: hidden; box-sizing: border-box; }
.report-content { padding: 0; flex: 1; overflow: hidden; }

.stat-cards-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-top: 24rpx;
}
.stat-card {
  width: calc(50% - 8rpx);
  box-sizing: border-box;
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  &.blue-card { border-left: 6rpx solid #3D6DF7; }
  &.green-card { border-left: 6rpx solid #00B42A; }
  &.orange-card { border-left: 6rpx solid #FF6B35; }
  &.purple-card { border-left: 6rpx solid #722ED1; }
}
.sc-label { font-size: 24rpx; color: #86909C; }
.sc-value { font-size: 32rpx; font-weight: 700; color: #1D2129; line-height: 1.2; }

.section-block {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-top: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.block-title { font-size: 28rpx; font-weight: 600; color: #1D2129; }
.block-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* 月度趋势柱状图 */
.chart-section { margin-top: 16rpx; }
.bar-chart {
  display: flex;
  align-items: flex-end;
  gap: 8rpx;
  height: 320rpx;
  padding: 0 8rpx;
}
.bar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  justify-content: flex-end;
}
.bar-wrapper {
  width: 100%;
  height: 220rpx;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}
.bar-fill {
  width: 70%;
  min-height: 4rpx;
  background: linear-gradient(180deg, #3D6DF7, #6B8FF9);
  border-radius: 6rpx 6rpx 0 0;
  transition: height 0.3s ease;
}
.bar-amount {
  font-size: 18rpx;
  color: #86909C;
  margin-top: 6rpx;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
  text-align: center;
}
.bar-label {
  font-size: 18rpx;
  color: #C9CDD4;
  margin-top: 4rpx;
  white-space: nowrap;
}

/* 分类占比 */
.category-section { margin-top: 16rpx; }
.category-list { display: flex; flex-direction: column; gap: 20rpx; }
.category-item { display: flex; flex-direction: column; gap: 8rpx; }
.category-header {
  display: flex;
  align-items: center;
  gap: 10rpx;
}
.category-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  flex-shrink: 0;
}
.category-name { font-size: 26rpx; color: #1D2129; font-weight: 500; flex: 1; }
.category-amount { font-size: 26rpx; color: #3D6DF7; font-weight: 600; }
.progress-bar {
  height: 16rpx;
  background: #F2F3F5;
  border-radius: 8rpx;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  border-radius: 8rpx;
  transition: width 0.3s ease;
}
.category-percent {
  font-size: 22rpx;
  color: #86909C;
  text-align: right;
}

/* 排名列表 */
.rank-section { margin-top: 16rpx; }
.rank-list { display: flex; flex-direction: column; gap: 12rpx; }
.rank-item {
  display: flex;
  align-items: center;
  padding: 16rpx 20rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  gap: 16rpx;
}
.rank-index {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: #E5E6EB;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  &.top3 { background: #3D6DF7; }
}
.rank-index-text {
  font-size: 24rpx;
  font-weight: 700;
  color: #fff;
}
.rank-index:not(.top3) .rank-index-text { color: #86909C; }
.rank-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}
.rank-name { font-size: 26rpx; color: #1D2129; font-weight: 500; }
.rank-count { font-size: 22rpx; color: #86909C; }
.rank-amount { font-size: 28rpx; color: #3D6DF7; font-weight: 600; flex-shrink: 0; }

.empty-block { padding: 32rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }
.bottom-spacer { height: 40rpx; }
</style>
