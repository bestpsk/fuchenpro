<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="shipment-no">{{ info.shipmentNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.shipmentStatus)">{{ getStatusLabel(info.shipmentStatus) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">企业</text>
          <text class="info-value">{{ info.enterpriseName || (info.enterprise && info.enterprise.enterpriseName) || '-' }}</text>
        </view>
        <view class="info-row" v-if="info.plan && info.plan.planName">
          <text class="info-label">方案</text>
          <text class="info-value">{{ info.plan.planName }}</text>
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

    <view class="info-card" v-if="shipmentItems.length > 0">
      <view class="section-header">
        <view class="card-title">出货明细</view>
        <text class="item-count">{{ shipmentItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in shipmentItems" :key="idx" class="item-card">
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
              <text class="info-value">¥{{ formatAmount(item.salePrice) }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">折扣价</text>
              <text class="info-value price">¥{{ formatAmount(item.discountPrice) }}</text>
            </view>
          </view>
          <view class="info-line summary-line">
            <view class="info-left">
              <text class="info-label">金额</text>
              <text class="info-value amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="String(info.shipmentStatus) === '2' || String(info.shipmentStatus) === '3'">
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
        <view class="info-row" v-if="info.shipmentDate">
          <text class="info-label">发货日期</text>
          <text class="info-value">{{ info.shipmentDate }}</text>
        </view>
        <view class="info-row" v-if="info.receiptDate">
          <text class="info-label">收货日期</text>
          <text class="info-value">{{ info.receiptDate }}</text>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canAuditPass" type="success" text="审核通过" @click="handleAuditPass"></u-button>
        <u-button v-if="canAuditReject" type="error" plain text="审核驳回" @click="handleAuditReject"></u-button>
        <u-button v-if="canShip" type="primary" text="发货" @click="showShipPopup = true"></u-button>
        <u-button v-if="canConfirm" type="success" text="确认收货" @click="handleConfirmReceipt"></u-button>
      </view>
    </view>

    <u-popup :show="showRejectPopup" mode="center" round="16" @close="showRejectPopup = false">
      <view class="popup-content">
        <view class="popup-title">驳回原因</view>
        <view class="popup-input-box">
          <textarea class="popup-textarea" v-model="rejectReason" placeholder="请输入驳回原因" placeholder-class="field-placeholder" :maxlength="200" auto-height></textarea>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="取消" @click="showRejectPopup = false"></u-button>
          <u-button type="error" text="确认驳回" @click="confirmReject"></u-button>
        </view>
      </view>
    </u-popup>

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
import { getShipment, auditShipment, shipShipment, confirmReceipt } from '@/api/business/shipment'

const info = ref({})
const shipmentItems = ref([])
const shipmentId = ref(null)
const showRejectPopup = ref(false)
const showShipPopup = ref(false)
const rejectReason = ref('')
const shipForm = reactive({ logisticsCompany: '', logisticsNo: '' })

function getStatusLabel(status) {
  const map = { '0': '待审核', '1': '已审核', '2': '已发货', '3': '已收货', '4': '已驳回' }
  return map[String(status)] || '未知'
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

const canAuditPass = computed(() => String(info.value.shipmentStatus) === '0')
const canAuditReject = computed(() => String(info.value.shipmentStatus) === '0')
const canShip = computed(() => String(info.value.shipmentStatus) === '1')
const canConfirm = computed(() => String(info.value.shipmentStatus) === '2')
const showActions = computed(() => canAuditPass.value || canAuditReject.value || canShip.value || canConfirm.value)

async function loadDetail() {
  if (!shipmentId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getShipment(shipmentId.value)
    const data = response.data || response
    info.value = data
    shipmentItems.value = data.items || []
  } catch (e) {
    console.error('加载出货详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function callPhone() {
  if (info.value.contactPhone) uni.makePhoneCall({ phoneNumber: info.value.contactPhone })
}

function handleAuditPass() {
  uni.showModal({ title: '提示', content: '确认审核通过?', success: async (res) => {
    if (res.confirm) {
      try {
        await auditShipment({ shipmentId: shipmentId.value, passed: true })
        uni.showToast({ title: '审核通过', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('审核失败:', e) }
    }
  }})
}

function handleAuditReject() {
  rejectReason.value = ''
  showRejectPopup.value = true
}

async function confirmReject() {
  if (!rejectReason.value.trim()) { uni.showToast({ title: '请输入驳回原因', icon: 'none' }); return }
  try {
    await auditShipment({ shipmentId: shipmentId.value, passed: false, auditRemark: rejectReason.value })
    uni.showToast({ title: '已驳回', icon: 'success' })
    showRejectPopup.value = false
    loadDetail()
  } catch (e) { console.error('驳回失败:', e) }
}

async function confirmShip() {
  if (!shipForm.logisticsCompany.trim()) { uni.showToast({ title: '请输入物流公司', icon: 'none' }); return }
  if (!shipForm.logisticsNo.trim()) { uni.showToast({ title: '请输入物流单号', icon: 'none' }); return }
  try {
    await shipShipment({ shipmentId: shipmentId.value, logisticsCompany: shipForm.logisticsCompany, logisticsNo: shipForm.logisticsNo })
    uni.showToast({ title: '发货成功', icon: 'success' })
    showShipPopup.value = false
    loadDetail()
  } catch (e) { console.error('发货失败:', e) }
}

function handleConfirmReceipt() {
  uni.showModal({ title: '提示', content: '确认已收货？确认后将扣减库存和更新方案金额。', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmReceipt(shipmentId.value)
        uni.showToast({ title: '已确认收货', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认收货失败:', e) }
    }
  }})
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  shipmentId.value = options.id ? parseInt(options.id) : null
  loadDetail()
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
  &.status-4 { background: #FFECE8; color: #F53F3F; }
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
    &.price { color: #FF6B35; font-weight: 500; }
    &.amount { color: #FF6B35; font-weight: 600; }
  }
  &.summary-line { margin-top: 4rpx; padding-top: 6rpx; }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}

.popup-content { padding: 30rpx; background: #fff; border-radius: 16rpx; width: 600rpx; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; text-align: center; }
.popup-input-box { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 16rpx; }
.popup-textarea { width: 100%; min-height: 160rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; }
.popup-input { width: 100%; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.popup-field { margin-bottom: 8rpx; }
.popup-field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 8rpx; }
.popup-actions { display: flex; gap: 20rpx; margin-top: 24rpx; .u-button { flex: 1; } }
</style>
