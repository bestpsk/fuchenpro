<template>
  <view class="statistics-card">
    <view class="card-header">
      <view class="header-left">
        <view class="title-bar"></view>
        <text class="card-title">数据概览</text>
      </view>
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

    <view class="stats-grid">
      <view
        v-for="(item, index) in statsList"
        :key="index"
        class="stat-card"
      >
        <view class="stat-icon" :style="{ background: item.gradient }">
          <u-icon :name="item.icon" size="22" color="#FFFFFF" />
        </view>
        <text class="stat-label">{{ item.label }}</text>
        <text class="stat-value-today" :style="{ color: item.color }">{{ item.todayValue }}</text>
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

/** 指标项的图标/配色/渐变映射，与 QuickMenu colorPalette 保持一致 */
const LABEL_MAP = {
  '成交客数': { icon: 'account-fill', color: '#3D6DF7', gradient: 'linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%)' },
  '成交金额': { icon: 'rmb-circle-fill', color: '#FF7D00', gradient: 'linear-gradient(135deg, #FF7D00 0%, #FFA940 100%)' },
  '实付金额': { icon: 'checkmark-circle-fill', color: '#00B42A', gradient: 'linear-gradient(135deg, #00B42A 0%, #4ECB3D 100%)' }
}

const defaultStats = [
  { label: '成交客数', todayValue: '0', monthValue: '0' },
  { label: '成交金额', todayValue: '¥0', monthValue: '¥0' },
  { label: '实付金额', todayValue: '¥0', monthValue: '¥0' }
]

/** 补全图标/颜色/渐变字段 */
function decorate(list) {
  return list.map(item => {
    const cfg = LABEL_MAP[item.label] || { icon: 'empty-data', color: '#3D6DF7', gradient: 'linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%)' }
    return { ...item, icon: cfg.icon, color: cfg.color, gradient: cfg.gradient }
  })
}

const statsList = ref(decorate(props.data.length > 0 ? props.data : defaultStats))

watch(() => props.data, (val) => {
  if (val && val.length > 0) {
    const filtered = val.filter(item => {
      const today = String(item.todayValue).replace(/[¥,]/g, '')
      const month = String(item.monthValue).replace(/[¥,]/g, '')
      return parseFloat(today) !== 0 || parseFloat(month) !== 0
    })
    statsList.value = decorate(filtered.length > 0 ? filtered : defaultStats)
  } else {
    statsList.value = decorate(defaultStats)
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
  padding: 24rpx 24rpx 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
  position: relative;
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
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active {
      background: #F5F7FA;
      transform: scale(0.92);
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

.stats-grid {
  display: flex;
  justify-content: space-between;
  gap: 16rpx;
}

.stat-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  padding: 20rpx 8rpx 16rpx;
  border-radius: 16rpx;
  background: #FAFBFF;
  box-sizing: border-box;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    background: #F0F3FF;
    transform: scale(0.96);
  }
}

.stat-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 12rpx rgba(61, 109, 247, 0.18);
  flex-shrink: 0;
}

.stat-label {
  font-size: 24rpx;
  color: #86909C;
  font-weight: 400;
}

.stat-value-today {
  font-size: 40rpx;
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.5rpx;
  text-align: center;
  word-break: break-all;
}

.stat-value-month {
  font-size: 22rpx;
  color: #86909C;
  font-weight: 400;
  line-height: 1.2;
}
</style>
