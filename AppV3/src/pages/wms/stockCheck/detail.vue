<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="check-no">{{ info.stockCheckNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.status)">{{ getStatusLabel(info.status) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">盘点日期</text>
          <text class="info-value">{{ info.checkDate || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">操作人</text>
          <text class="info-value">{{ info.operatorName || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">创建时间</text>
          <text class="info-value">{{ formatTime(info.createTime) }}</text>
        </view>
        <view v-if="info.remark" class="info-row">
          <text class="info-label">备注</text>
          <text class="info-value remark-text">{{ info.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="stockCheckItems.length > 0">
      <view class="section-header">
        <view class="card-title">盘点明细</view>
        <text class="item-count">{{ stockCheckItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in stockCheckItems" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-index">{{ idx + 1 }}.</text>
          <text class="item-name">{{ item.productName || '-' }}</text>
          <text class="item-code">{{ item.productCode || '-' }}</text>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">系统库存</text>
              <text class="info-value">{{ item.systemQuantity || 0 }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">实际数量</text>
              <text class="info-value">{{ item.actualQuantity || 0 }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">差异数量</text>
              <text v-if="getDiff(item) > 0" class="info-value diff-positive">+{{ getDiff(item) }}</text>
              <text v-else-if="getDiff(item) < 0" class="info-value diff-negative">{{ getDiff(item) }}</text>
              <text v-else class="info-value diff-zero">0</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canConfirm" type="success" text="确认盘点" @click="handleConfirm"></u-button>
        <u-button v-if="canEdit" type="primary" plain text="编辑" @click="goEdit"></u-button>
        <u-button v-if="canDelete" type="error" plain text="删除" @click="handleDelete"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getStockCheck, delStockCheck, confirmStockCheck } from '@/api/wms/stockCheck'
import { checkPermi } from '@/utils/permission'

const info = ref({})
const stockCheckItems = ref([])
const stockCheckId = ref(null)

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认' }
  return map[String(status)] || '未知'
}

function formatTime(time) {
  if (!time) return '-'
  return String(time).substring(0, 16)
}

function getDiff(item) {
  return (Number(item.actualQuantity) || 0) - (Number(item.systemQuantity) || 0)
}

const canConfirm = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockCheck:confirm'))
const canEdit = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockCheck:edit'))
const canDelete = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockCheck:remove'))
const showActions = computed(() => canConfirm.value || canEdit.value || canDelete.value)

async function loadDetail() {
  if (!stockCheckId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockCheck(stockCheckId.value)
    const data = response.data || response
    info.value = data
    stockCheckItems.value = data.items || []
  } catch (e) {
    console.error('加载盘点详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function handleConfirm() {
  uni.showModal({ title: '提示', content: '确认盘点后将调整库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockCheck(stockCheckId.value)
        uni.showToast({ title: '确认盘点成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认盘点失败:', e) }
    }
  }})
}

function goEdit() {
  uni.navigateTo({ url: `/pages/wms/stockCheck/form?mode=edit&id=${stockCheckId.value}` })
}

function handleDelete() {
  uni.showModal({ title: '提示', content: '确认删除该盘点单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockCheck(stockCheckId.value)
        uni.showToast({ title: '删除成功', icon: 'success' })
        setTimeout(() => {
          const pages = getCurrentPages()
          if (pages.length > 1) uni.navigateBack()
          else uni.redirectTo({ url: '/pages/wms/stockCheck/index' })
        }, 1500)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  stockCheckId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})

onShow(() => {
  if (stockCheckId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.check-no { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 16rpx; border-radius: 4rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 100rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.remark-text { word-break: break-all; line-height: 1.6; }
}

.item-card { padding: 20rpx 0; border-bottom: 1rpx solid #F2F3F5; &:last-child { border-bottom: none; } }
.item-header { display: flex; align-items: center; margin-bottom: 12rpx;
  .item-index { font-size: 26rpx; color: #86909C; font-weight: 500; margin-right: 8rpx; }
  .item-name { font-size: 27rpx; color: #1D2129; font-weight: 500; flex: 1; }
  .item-code { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
}
.item-body { display: flex; flex-direction: column; gap: 10rpx; padding-left: 32rpx; }
.info-line { display: flex; align-items: center; justify-content: space-between; font-size: 25rpx; line-height: 1.6;
  .info-left { display: flex; align-items: center; gap: 8rpx; flex: 1; }
  .info-right { display: flex; align-items: center; gap: 8rpx; flex-shrink: 0; margin-left: auto; }
  .info-label { color: #86909C; white-space: nowrap; font-size: 24rpx; }
  .info-value { color: #4E5969; font-size: 25rpx;
    &.diff-positive { color: #00B42A; font-weight: 600; }
    &.diff-negative { color: #F53F3F; font-weight: 600; }
    &.diff-zero { color: #C9CDD4; }
  }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}
</style>
