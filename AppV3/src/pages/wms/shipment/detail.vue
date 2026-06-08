<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="shipment-no">{{ info.stockOutNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.status)">{{ getStatusLabel(info.status) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">企业</text>
          <text class="info-value">{{ info.enterpriseName || '-' }}</text>
        </view>
        <view class="info-row" v-if="info.planId">
          <text class="info-label">关联方案</text>
          <text class="info-value">{{ info.planName || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">发货方式</text>
          <text class="info-value">{{ getShipTypeLabel(info.shipType) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">收货人</text>
          <text class="info-value">{{ info.contactPerson || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">收货电话</text>
          <text class="info-value phone-link" v-if="info.contactPhone" @click="callPhone">{{ info.contactPhone }}</text>
          <text class="info-value" v-else>-</text>
        </view>
        <view class="info-row" v-if="info.shippingAddress">
          <text class="info-label">收货地址</text>
          <text class="info-value">{{ info.shippingAddress }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">总数量</text>
          <text class="info-value">{{ info.totalQuantity || 0 }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">总金额</text>
          <text class="info-value amount">¥{{ formatAmount(info.totalAmount) }}</text>
        </view>
        <view class="info-row" v-if="info.remark">
          <text class="info-label">备注</text>
          <text class="info-value remark-text">{{ info.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="stockOutItems.length > 0">
      <view class="section-header">
        <view class="card-title">出库明细</view>
        <text class="item-count">{{ stockOutItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in stockOutItems" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-index">{{ idx + 1 }}.</text>
          <text class="item-name">{{ item.productName || '-' }}</text>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">供货商</text>
              <text class="info-value">{{ item.supplierName || '-' }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">数量</text>
              <text class="info-value">{{ item.quantity || 0 }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">单价</text>
              <text class="info-value">¥{{ formatAmount(item.price || item.salePrice) }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">金额</text>
              <text class="info-value amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="String(info.shipType) === '2' && (String(info.status) === '2' || String(info.status) === '3')">
      <view class="card-title">物流信息</view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">物流公司</text>
          <text class="info-value">{{ info.logisticsCompany || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">物流单号</text>
          <text class="info-value">{{ info.logisticsNo || '-' }}</text>
        </view>
        <view class="info-row" v-if="info.shipDate">
          <text class="info-label">发货日期</text>
          <text class="info-value">{{ info.shipDate }}</text>
        </view>
        <view class="info-row" v-if="info.receiptDate">
          <text class="info-label">收货日期</text>
          <text class="info-value">{{ info.receiptDate }}</text>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canConfirm" type="success" text="确认出库" @click="handleConfirm"></u-button>
        <u-button v-if="canShip" type="primary" text="发货" @click="showShipPopup = true"></u-button>
        <u-button v-if="canConfirmReceipt" type="success" text="确认收货" @click="handleConfirmReceipt"></u-button>
      </view>
    </view>

    <u-popup :show="showShipPopup" mode="center" round="16" @close="showShipPopup = false">
      <view class="popup-content">
        <view class="popup-title">填写物流信息</view>
        <view class="popup-field">
          <view class="popup-field-label">物流公司</view>
          <view class="popup-input-box">
            <input class="popup-input" type="text" v-model="shipForm.logisticsCompany" placeholder="请输入物流公司" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="popup-field">
          <view class="popup-field-label">物流单号</view>
          <view class="popup-input-box">
            <input class="popup-input" type="text" v-model="shipForm.logisticsNo" placeholder="请输入物流单号" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="取消" @click="showShipPopup = false"></u-button>
          <u-button type="primary" text="确认发货" @click="confirmShip"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getStockOut, confirmStockOut, shipStockOut, confirmReceipt } from '@/api/wms/stockOut'
import { checkPermi } from '@/utils/permission'

const info = ref({})
const stockOutItems = ref([])
const stockOutId = ref(null)
const showShipPopup = ref(false)
const shipForm = reactive({ logisticsCompany: '', logisticsNo: '' })

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认(待发货)', '2': '已发货', '3': '已完成' }
  return map[String(status)] || '未知'
}

function getShipTypeLabel(shipType) {
  const map = { '0': '无需发货', '1': '自提', '2': '物流' }
  return map[String(shipType)] || '-'
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

const canConfirm = computed(() => String(info.value.status) === '0' && checkPermi('wms:stockOut:confirm'))
const canShip = computed(() => String(info.value.status) === '1' && checkPermi('wms:stockOut:ship'))
const canConfirmReceipt = computed(() => String(info.value.status) === '2' && checkPermi('wms:stockOut:confirmReceipt'))
const showActions = computed(() => canConfirm.value || canShip.value || canConfirmReceipt.value)

async function loadDetail() {
  if (!stockOutId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockOut(stockOutId.value)
    const data = response.data || response
    info.value = data
    stockOutItems.value = data.items || []
  } catch (e) {
    console.error('加载出库详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function callPhone() {
  if (info.value.contactPhone) uni.makePhoneCall({ phoneNumber: info.value.contactPhone })
}

function handleConfirm() {
  uni.showModal({ title: '提示', content: '确认出库后将减少库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockOut(stockOutId.value)
        uni.showToast({ title: '确认出库成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认出库失败:', e) }
    }
  }})
}

async function confirmShip() {
  if (!shipForm.logisticsCompany.trim()) { uni.showToast({ title: '请输入物流公司', icon: 'none' }); return }
  if (!shipForm.logisticsNo.trim()) { uni.showToast({ title: '请输入物流单号', icon: 'none' }); return }
  try {
    await shipStockOut(stockOutId.value, {
      shipType: '2',
      logisticsCompany: shipForm.logisticsCompany,
      logisticsNo: shipForm.logisticsNo
    })
    uni.showToast({ title: '发货成功', icon: 'success' })
    showShipPopup.value = false
    loadDetail()
  } catch (e) { console.error('发货失败:', e) }
}

function handleConfirmReceipt() {
  uni.showModal({ title: '提示', content: '确认已收货？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmReceipt(stockOutId.value)
        uni.showToast({ title: '确认收货成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认收货失败:', e) }
    }
  }})
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  stockOutId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})

onShow(() => {
  if (stockOutId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.shipment-no { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #e8f0fe; color: #3D6DF7; }
  &.status-3 { background: #F0E8FF; color: #8B5CF6; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 16rpx; border-radius: 4rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 100rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.phone-link { color: #3D6DF7; }
  &.amount { color: #FF6B35; font-weight: 600; }
  &.remark-text { word-break: break-all; line-height: 1.6; }
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

.popup-content { padding: 30rpx; background: #fff; border-radius: 16rpx; width: 600rpx; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; text-align: center; }
.popup-input-box { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 16rpx; }
.popup-input { width: 100%; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.popup-field { margin-bottom: 8rpx; }
.popup-field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 8rpx; }
.popup-actions { display: flex; gap: 20rpx; margin-top: 24rpx; .u-button { flex: 1; } }
</style>
