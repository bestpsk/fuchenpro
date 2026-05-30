<template>
  <view class="statistics-card">
    <view class="card-header">
      <text class="card-title">数据概览</text>
      <view class="header-actions">
        <view class="refresh-btn" @click="handleRefresh">
          <u-icon name="reload" size="16" color="#86909C" />
        </view>
        <view class="more-btn" @click="handleMore">
          <text class="more-text">更多</text>
          <u-icon name="arrow-right" size="12" color="#86909C" />
        </view>
      </view>
    </view>

    <view class="divider"></view>

    <view class="stats-grid">
      <view
        v-for="(item, index) in statsList"
        :key="index"
        class="stat-item"
      >
        <text class="stat-label">{{ item.label }}</text>
        <text class="stat-value-today">{{ item.todayValue }}</text>
        <text class="stat-value-month">本月 {{ item.monthValue }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['refresh'])

const defaultStats = [
  { label: '成交客数', todayValue: '0', monthValue: '0' },
  { label: '成交金额', todayValue: '¥0', monthValue: '¥0' },
  { label: '实付金额', todayValue: '¥0', monthValue: '¥0' },
  { label: '欠款金额', todayValue: '¥0', monthValue: '¥0' },
  { label: '现金', todayValue: '¥0', monthValue: '¥0' },
  { label: '耗卡', todayValue: '¥0', monthValue: '¥0' },
  { label: '赠送', todayValue: '0', monthValue: '0' },
  { label: '操作客数', todayValue: '0', monthValue: '0' },
  { label: '操作金额', todayValue: '¥0', monthValue: '¥0' }
]

const statsList = ref(props.data.length > 0 ? props.data : defaultStats)

watch(() => props.data, (val) => {
  if (val && val.length > 0) {
    statsList.value = val.filter(item => {
      const today = String(item.todayValue).replace(/[¥,]/g, '')
      const month = String(item.monthValue).replace(/[¥,]/g, '')
      return parseFloat(today) !== 0 || parseFloat(month) !== 0
    })
  }
}, { deep: true })

function handleRefresh() {
  emit('refresh')
}

function handleMore() {
  uni.navigateTo({ url: '/pages/statistics/index' })
}
</script>

<style lang="scss" scoped>
.statistics-card {
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

  .card-title {
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 16rpx;
  }

  .refresh-btn {
    width: 52rpx;
    height: 52rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;

    &:active {
      background: #F5F7FA;
    }
  }

  .more-btn {
    display: flex;
    align-items: center;
    gap: 4rpx;
    padding: 8rpx 12rpx;
    border-radius: 24rpx;

    &:active {
      background: #F5F7FA;
    }

    .more-text {
      font-size: 24rpx;
      color: #86909C;
    }
  }
}

.divider {
  height: 1rpx;
  background: #E5E6EB;
  margin: 18rpx 0;
}

.stats-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx 0;
}

.stat-item {
  width: 33.33%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
  box-sizing: border-box;

  .stat-label {
    font-size: 22rpx;
    color: #86909C;
  }

  .stat-value-today {
    font-size: 32rpx;
    font-weight: 700;
    color: #3D6DF7;
    line-height: 1;
  }

  .stat-value-month {
    font-size: 20rpx;
    color: #86909C;
    font-weight: 400;
    line-height: 1.4;
  }
}
</style>
