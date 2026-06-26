<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="stockin-no">{{ info.stockInNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.status)">{{ getStatusLabel(info.status) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">入库类型</text>
          <text class="info-value">{{ getStockInTypeLabel(info.stockInType) }}</text>
        </view>
        <view class="info-row" v-if="info.warehouseName">
          <text class="info-label">仓库</text>
          <text class="info-value">{{ info.warehouseName }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">供货商</text>
          <text class="info-value">{{ info.supplierName || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">操作人</text>
          <text class="info-value">{{ info.operatorName || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">总数量</text>
          <text class="info-value">{{ info.totalQuantity || 0 }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">总金额</text>
          <text class="info-value amount">¥{{ formatAmount(info.totalAmount) }}</text>
        </view>
        <view class="info-row" v-if="info.stockInDate">
          <text class="info-label">入库日期</text>
          <text class="info-value">{{ formatTime(info.stockInDate) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">创建时间</text>
          <text class="info-value">{{ formatTime(info.createTime) }}</text>
        </view>
        <view class="info-row" v-if="info.remark">
          <text class="info-label">备注</text>
          <text class="info-value remark-text">{{ info.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="stockInItems.length > 0">
      <view class="section-header">
        <view class="card-title">
          <u-icon name="arrow-down" size="16" color="#3D6DF7"></u-icon>
          <text>入库明细</text>
        </view>
        <text class="item-count">{{ stockInItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in stockInItems" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-index">{{ idx + 1 }}.</text>
          <text class="item-name">{{ item.productName || '-' }}</text>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">规格</text>
              <text class="info-value">{{ item.displaySpec || '-' }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">数量</text>
              <text class="info-value">{{ item.displayQuantity || 0 }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">单价</text>
              <text class="info-value">¥{{ formatAmount(item.displayPrice) }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">金额</text>
              <text class="info-value amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
          </view>
          <view class="info-line" v-if="item.productionDate">
            <view class="info-left">
              <text class="info-label">生产日期</text>
              <text class="info-value">{{ formatTime(item.productionDate) }}</text>
            </view>
            <view class="info-right" v-if="item.expiryDate">
              <text class="info-label">有效期至</text>
              <text class="info-value" :class="{ 'expiry-warn': getExpiryClass(item.expiryDate) === 'warning', 'expiry-expired': getExpiryClass(item.expiryDate) === 'expired' }">{{ formatTime(item.expiryDate) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canConfirm" type="success" text="确认入库" @click="handleConfirm"></u-button>
        <u-button v-if="canCancelConfirm" type="warning" text="取消确认" @click="handleCancelConfirm"></u-button>
        <u-button v-if="canEdit" type="primary" plain text="编辑" @click="goEdit"></u-button>
        <u-button v-if="canDelete" type="error" plain text="删除" @click="handleDelete"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getStockIn, delStockIn, confirmStockIn, cancelConfirmStockIn } from '@/api/wms/stockIn'
import { checkPermi } from '@/utils/permission'

const info = ref({})
const stockInItems = ref([])
const stockInId = ref(null)

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认' }
  return map[String(status)] || '未知'
}

function getStockInTypeLabel(stockInType) {
  const map = { '1': '采购入库', '2': '退货入库', '3': '其他入库' }
  return map[String(stockInType)] || '-'
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

function getExpiryClass(expiryDate) {
  if (!expiryDate) return ''
  const now = new Date()
  const expiry = new Date(expiryDate)
  const diffDays = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24))
  if (diffDays < 0) return 'expired'
  if (diffDays <= 30) return 'warning'
  return ''
}

const canConfirm = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockIn:confirm'))
const canCancelConfirm = computed(() => String(info.value.status) === '1' && checkPermi('wms:stockIn:edit'))
const canEdit = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockIn:edit'))
const canDelete = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockIn:remove'))
const showActions = computed(() => canConfirm.value || canCancelConfirm.value || canEdit.value || canDelete.value)

async function loadDetail() {
  if (!stockInId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockIn(stockInId.value)
    const data = response.data || response
    info.value = data
    stockInItems.value = (data.items || []).map(item => {
      const unitType = item.unitType || '1'
      const packQty = item.packQty || 1
      const purchasePrice = item.purchasePrice || 0
      let displayPrice = purchasePrice
      let displayQuantity = item.quantity || 0
      if (unitType === '1' && packQty > 1) {
        displayPrice = Math.round(purchasePrice * packQty * 100) / 100
        displayQuantity = Math.round(displayQuantity / packQty * 10000) / 10000
      }
      return {
        ...item,
        displayQuantity,
        displayPrice,
        displaySpec: unitType === '1' ? '主单位(整)' : '副单位(拆)'
      }
    })
  } catch (e) {
    console.error('加载入库详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function handleConfirm() {
  uni.showModal({ title: '提示', content: '确认入库后将增加库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockIn(stockInId.value)
        uni.showToast({ title: '确认入库成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认入库失败:', e) }
    }
  }})
}

function handleCancelConfirm() {
  uni.showModal({ title: '提示', content: '确认取消入库？取消后库存数量将回退。', success: async (res) => {
    if (res.confirm) {
      try {
        await cancelConfirmStockIn(stockInId.value)
        uni.showToast({ title: '取消确认成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('取消确认失败:', e) }
    }
  }})
}

function goEdit() {
  uni.navigateTo({ url: `/pages/wms/stockIn/form?mode=edit&id=${stockInId.value}` })
}

function handleDelete() {
  uni.showModal({ title: '提示', content: '确认删除该入库单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockIn(stockInId.value)
        uni.showToast({ title: '删除成功', icon: 'success' })
        setTimeout(() => {
          const pages = getCurrentPages()
          if (pages.length > 1) uni.navigateBack()
          else uni.redirectTo({ url: '/pages/wms/stockIn/index' })
        }, 1500)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  stockInId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})

onShow(() => {
  if (stockInId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.stockin-no { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
}

.card-title { display: flex; align-items: center; gap: 8rpx; font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 16rpx; border-radius: 4rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 100rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.amount { color: #FF6B35; font-weight: 600; }
  &.remark-text { word-break: break-all; line-height: 1.6; }
  &.expiry-warn { color: #FF7D00; }
  &.expiry-expired { color: #F53F3F; }
}

.item-card { padding: 20rpx 0; border-bottom: 1rpx solid #F2F3F5; &:last-child { border-bottom: none; } }
.item-header { display: flex; align-items: center; margin-bottom: 12rpx;
  .item-index { font-size: 26rpx; color: #86909C; font-weight: 500; margin-right: 8rpx; }
  .item-name { font-size: 27rpx; color: #1D2129; font-weight: 500; flex: 1; }
}
.item-body { display: flex; flex-direction: column; gap: 10rpx; padding-left: 32rpx; }
.info-line { display: flex; align-items: center; justify-content: space-between; font-size: 25rpx; line-height: 1.6;
  .info-left { display: flex; align-items: center; gap: 8rpx; flex: 1; }
  .info-right { display: flex; align-items: center; gap: 8rpx; flex-shrink: 0; margin-left: auto; }
  .info-label { color: #86909C; white-space: nowrap; font-size: 24rpx; }
  .info-value { color: #4E5969; font-size: 25rpx;
    &.amount { color: #FF6B35; font-weight: 600; }
  }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}
</style>
