<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="product-name">{{ info.productName || '-' }}</text>
        <view class="status-badge" :class="isWarn ? 'status-warn' : 'status-normal'">{{ isWarn ? '预警' : '正常' }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">货品编码</text>
          <text class="info-value">{{ info.productCode || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">类别</text>
          <text class="info-value">{{ info.category || '-' }}</text>
        </view>
      </view>
    </view>

    <view class="info-card">
      <view class="card-title">库存信息</view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">库存数量</text>
          <text class="info-value quantity">{{ info.quantityDisplay || info.quantity || 0 }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">预警数量</text>
          <text class="info-value">{{ info.warnQty ?? '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">库存状态</text>
          <text class="info-value" :class="isWarn ? 'warn-text' : 'normal-text'">{{ isWarn ? '预警' : '正常' }}</text>
        </view>
      </view>
    </view>

    <view class="info-card">
      <view class="card-title">价格信息</view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">进货价</text>
          <text class="info-value price">¥{{ formatAmount(info.purchasePrice) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">出货价</text>
          <text class="info-value price">¥{{ formatAmount(info.salePrice) }}</text>
        </view>
      </view>
    </view>

    <view class="info-card">
      <view class="card-title">时间记录</view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">最后入库</text>
          <text class="info-value">{{ formatTime(info.lastInTime) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">最后出库</text>
          <text class="info-value">{{ formatTime(info.lastOutTime) }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getInventory } from '@/api/wms/inventory'

const info = ref({})
const productId = ref(null)

const isWarn = computed(() => {
  const item = info.value
  return item.quantity !== undefined && item.quantity !== null && item.warnQty !== undefined && item.warnQty !== null && item.quantity <= item.warnQty
})

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatTime(time) {
  if (!time) return '-'
  return String(time).substring(0, 16)
}

async function loadDetail() {
  if (!productId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getInventory(productId.value)
    info.value = response.data || response
  } catch (e) {
    console.error('加载库存详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  productId.value = options.productId || null
  loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.product-name { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-normal { background: #e8f0fe; color: #00B42A; }
  &.status-warn { background: #FFECE8; color: #F53F3F; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 120rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.quantity { font-weight: 600; }
  &.price { color: #FF6B35; font-weight: 500; }
  &.normal-text { color: #00B42A; font-weight: 500; }
  &.warn-text { color: #F53F3F; font-weight: 500; }
}
</style>
