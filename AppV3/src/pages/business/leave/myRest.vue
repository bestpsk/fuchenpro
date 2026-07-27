<template>
  <view class="my-rest-container">
    <!-- 月份选择器 -->
    <view class="month-selector">
      <view class="month-btn" @click="changeMonth(-1)">
        <u-icon name="arrow-left" size="14" color="#3D6DF7" />
      </view>
      <view class="month-display">
        <text class="month-text">{{ displayMonth }}</text>
      </view>
      <view class="month-btn" @click="changeMonth(1)">
        <u-icon name="arrow-right" size="14" color="#3D6DF7" />
      </view>
      <view class="today-btn" @click="goToday">本月</view>
    </view>

    <!-- 类型图例 -->
    <view class="legend-card" v-if="typeList.length > 0">
      <view class="legend-grid">
        <view v-for="t in typeList" :key="t.type" class="legend-item">
          <view class="legend-dot" :style="{ backgroundColor: t.color }"></view>
          <text class="legend-name">{{ t.name }}</text>
          <text class="legend-count">{{ t.count }}天</text>
        </view>
      </view>
    </view>

    <!-- 休息日列表 -->
    <view class="date-list-card" v-if="dates.length > 0">
      <view v-for="item in dates" :key="item.date" class="date-row">
        <view class="date-info">
          <text class="date-day">{{ getDay(item.date) }}</text>
          <text class="date-weekday">{{ getWeekday(item.date) }}</text>
        </view>
        <view class="type-badge" :style="{ backgroundColor: item.color + '15', color: item.color, borderColor: item.color + '30' }">
          {{ item.typeName }}
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-else-if="!loading" class="empty-state">
      <u-icon name="calendar" size="48" color="#C9CDD4" />
      <text class="empty-text">本月暂无休息日</text>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 我的休息日 - 按月份展示所有类型的休息日
 * @description 类型包括：每周休息、指定休息、请假、法定假期
 */
import { ref, computed, onMounted } from 'vue'
import { getMyRestCalendarDetailed } from '@/api/business/leave'

const dates = ref([])
const typeList = ref([])
const loading = ref(false)
const currentYearMonth = ref(getCurrentYearMonth())

const displayMonth = computed(() => {
  if (!currentYearMonth.value) return ''
  const parts = currentYearMonth.value.split('-')
  return `${parts[0]}年${parts[1]}月`
})

function getCurrentYearMonth() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

function changeMonth(delta) {
  const parts = currentYearMonth.value.split('-')
  const year = parseInt(parts[0])
  const month = parseInt(parts[1]) + delta
  if (month < 1) {
    currentYearMonth.value = `${year - 1}-12`
  } else if (month > 12) {
    currentYearMonth.value = `${year + 1}-01`
  } else {
    currentYearMonth.value = `${year}-${String(month).padStart(2, '0')}`
  }
  loadData()
}

function goToday() {
  currentYearMonth.value = getCurrentYearMonth()
  loadData()
}

function getDay(dateStr) {
  if (!dateStr) return '-'
  const parts = dateStr.split('-')
  return `${parts[1]}-${parts[2]}`
}

function getWeekday(dateStr) {
  if (!dateStr) return ''
  const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  const idx = new Date(dateStr).getDay()
  return days[idx] || ''
}

async function loadData() {
  loading.value = true
  try {
    const res = await getMyRestCalendarDetailed({ yearMonth: currentYearMonth.value })
    const data = res.data || res
    dates.value = data.dates || []
    typeList.value = data.typeList || []
  } catch (e) {
    console.error('加载休息日数据失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
    dates.value = []
    typeList.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.my-rest-container {
  min-height: 100vh;
  padding: 24rpx;
  padding-bottom: 60rpx;
}

/* 月份选择器 */
.month-selector {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 24rpx;
  padding: 20rpx 24rpx;
  background: #fff;
  border-radius: 16rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}

.month-btn {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(61, 109, 247, 0.08);
  border-radius: 50%;
}

.month-display {
  flex: 1;
  text-align: center;
}

.month-text {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.today-btn {
  padding: 8rpx 24rpx;
  background: #3D6DF7;
  border-radius: 24rpx;
  font-size: 24rpx;
  color: #fff;
}

/* 类型图例 */
.legend-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}

.legend-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 8rpx 16rpx;
  background: #F7F8FA;
  border-radius: 20rpx;
}

.legend-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
}

.legend-name {
  font-size: 24rpx;
  color: #4E5969;
}

.legend-count {
  font-size: 22rpx;
  color: #86909C;
}

/* 休息日列表 */
.date-list-card {
  background: #fff;
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}

.date-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 28rpx;
  border-bottom: 1rpx solid #F0F0F0;

  &:last-child {
    border-bottom: none;
  }
}

.date-info {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.date-day {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 600;
}

.date-weekday {
  font-size: 24rpx;
  color: #86909C;
}

.type-badge {
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  border: 1rpx solid transparent;
  font-size: 24rpx;
  font-weight: 500;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 0 80rpx;
  gap: 16rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #86909C;
}
</style>
