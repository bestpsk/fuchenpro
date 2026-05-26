<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="plan-no">{{ planInfo.planNo || '-' }}</text>
        <view class="status-tag" :class="'status-' + planInfo.auditStatus">{{ getAuditStatusLabel(planInfo.auditStatus) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <u-icon name="home-fill" size="20" color="#86909C" />
          <text class="label">企业</text>
          <text class="value">{{ planInfo.enterpriseName || (planInfo.enterprise && planInfo.enterprise.enterpriseName) || '-' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="file-text" size="20" color="#86909C" />
          <text class="label">方案</text>
          <text class="value">{{ planInfo.planName || '-' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="share" size="20" color="#86909C" />
          <text class="label">分成</text>
          <text class="value">{{ planInfo.commissionRate || 0 }}%</text>
        </view>
        <view class="info-row">
          <u-icon name="rmb-circle" size="20" color="#86909C" />
          <text class="label">方案金额</text>
          <text class="value amount">¥{{ formatAmount(planInfo.planAmount) }}</text>
        </view>
        <view class="info-row">
          <u-icon name="gift" size="20" color="#86909C" />
          <text class="label">配赠金额</text>
          <text class="value amount">¥{{ formatAmount(planInfo.giftAmount) }}</text>
        </view>
        <view class="info-row">
          <u-icon name="car" size="20" color="#86909C" />
          <text class="label">已出金额</text>
          <text class="value">¥{{ formatAmount(planInfo.shippedAmount) }}</text>
        </view>
        <view class="info-row">
          <u-icon name="bag" size="20" color="#86909C" />
          <text class="label">剩余金额</text>
          <text class="value" :class="{ 'amount-warning': parseFloat(planInfo.remainingAmount) <= 0 }">¥{{ formatAmount(planInfo.remainingAmount) }}</text>
        </view>
        <view class="info-row">
          <u-icon name="calendar" size="20" color="#86909C" />
          <text class="label">有效期</text>
          <text class="value">{{ formatDateRange(planInfo.effectiveDate, planInfo.expiryDate) }}</text>
        </view>
        <view v-if="planInfo.remark" class="info-row">
          <u-icon name="edit-pen" size="20" color="#86909C" />
          <text class="label">备注</text>
          <text class="value remark-text">{{ planInfo.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="planInfo.createBy || planInfo.submitBy || planInfo.auditBy">
      <view class="card-title">操作记录</view>
      <view class="info-body">
        <view v-if="planInfo.createBy" class="info-row">
          <u-icon name="man" size="20" color="#86909C" />
          <text class="label">创建人</text>
          <text class="value">{{ planInfo.createBy }}</text>
          <text class="value time">{{ formatTime(planInfo.createTime) }}</text>
        </view>
        <view v-if="planInfo.submitBy" class="info-row">
          <u-icon name="arrow-up" size="20" color="#86909C" />
          <text class="label">提交人</text>
          <text class="value">{{ planInfo.submitBy }}</text>
          <text class="value time">{{ formatTime(planInfo.submitTime) }}</text>
        </view>
        <view v-if="planInfo.auditBy" class="info-row">
          <u-icon name="checkmark" size="20" color="#86909C" />
          <text class="label">审核人</text>
          <text class="value">{{ planInfo.auditBy }}</text>
          <text class="value time">{{ formatTime(planInfo.auditTime) }}</text>
        </view>
        <view v-if="planInfo.auditRemark" class="info-row">
          <u-icon name="chat" size="20" color="#86909C" />
          <text class="label">审核备注</text>
          <text class="value remark-text">{{ planInfo.auditRemark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="planItems.length > 0">
      <view class="section-header">
        <view class="card-title">配赠明细</view>
        <text class="item-count">{{ planItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in planItems" :key="idx" class="item-card">
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
              <text class="info-label">单位</text>
              <text class="info-value">{{ (item.spec || '-') + (item.unitType === '1' ? '（整）' : '（拆）') }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">数量</text>
              <text class="info-value">{{ item.quantity || 0 }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">单价</text>
              <text class="info-value price">¥{{ formatAmount(item.salePrice) }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">已出</text>
              <text class="info-value">{{ item.shippedQuantity || 0 }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">剩余</text>
              <text class="info-value">{{ item.remainingQuantity || 0 }}</text>
            </view>
          </view>
          <view class="info-line summary-line">
            <view class="info-left">
              <text class="info-label">总金额</text>
              <text class="info-value amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="planShipments.length > 0">
      <view class="section-header">
        <view class="card-title">出货记录</view>
        <text class="item-count">{{ planShipments.length }}条</text>
      </view>
      <view v-for="(item, idx) in planShipments" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-name">{{ item.shipmentNo || '-' }}</text>
          <view class="shipment-status" :class="'shipment-' + item.shipmentStatus">{{ getShipmentStatusLabel(item.shipmentStatus) }}</view>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">数量</text>
              <text class="info-value">{{ item.totalQuantity || 0 }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">金额</text>
              <text class="info-value price">¥{{ formatAmount(item.totalAmount) }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">时间</text>
              <text class="info-value">{{ formatTime(item.createTime) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canEdit" type="primary" plain text="编辑" @click="goEdit"></u-button>
        <u-button v-if="canSubmitAudit" type="warning" text="提交审核" @click="handleSubmitAudit"></u-button>
        <u-button v-if="canAuditPass" type="success" text="审核通过" @click="handleAuditPass"></u-button>
        <u-button v-if="canAuditReject" type="error" plain text="审核驳回" @click="handleAuditReject"></u-button>
        <u-button v-if="canShipment" type="primary" text="出货" @click="goShipment"></u-button>
        <u-button v-if="canToggleStatus" :type="planInfo.status === '0' ? 'error' : 'success'" plain :text="planInfo.status === '0' ? '停用' : '启用'" @click="handleToggleStatus"></u-button>
      </view>
    </view>

    <u-popup :show="showRejectPopup" mode="center" round="16" @close="showRejectPopup = false">
      <view class="reject-content">
        <view class="reject-title">驳回原因</view>
        <view class="reject-input-box">
          <textarea class="reject-textarea" v-model="rejectReason" placeholder="请输入驳回原因" placeholder-class="field-placeholder" :maxlength="200" auto-height></textarea>
        </view>
        <view class="reject-actions">
          <u-button type="info" plain text="取消" @click="showRejectPopup = false"></u-button>
          <u-button type="error" text="确认驳回" @click="confirmReject"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getPlan, submitAuditPlan, auditPlan, changePlanStatus } from '@/api/business/plan'

const planInfo = ref({})
const planItems = ref([])
const planShipments = ref([])
const planId = ref(null)
const showRejectPopup = ref(false)
const rejectReason = ref('')

const canEdit = computed(() => {
  const s = planInfo.value.auditStatus
  return s === '0' || s === '4'
})

const canSubmitAudit = computed(() => {
  const s = planInfo.value.auditStatus
  return s === '0' || s === '4'
})

const canAuditPass = computed(() => planInfo.value.auditStatus === '1')
const canAuditReject = computed(() => planInfo.value.auditStatus === '1')
const canToggleStatus = computed(() => planInfo.value.auditStatus === '2')
const canShipment = computed(() => planInfo.value.auditStatus === '2' && parseFloat(planInfo.value.remainingAmount) > 0)
const showActions = computed(() => canEdit.value || canSubmitAudit.value || canAuditPass.value || canAuditReject.value || canShipment.value || canToggleStatus.value)

function getAuditStatusLabel(status) {
  const map = { '0': '草稿', '1': '待审核', '2': '已审核', '3': '已完成', '4': '已驳回' }
  return map[String(status)] || '未知'
}

function getShipmentStatusLabel(status) {
  const map = { '0': '待审核', '1': '已审核', '2': '已发货', '3': '已收货', '4': '已驳回' }
  return map[String(status)] || '未知'
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatDateRange(start, end) {
  if (!start && !end) return '-'
  const s = start ? start.substring(0, 10) : ''
  const e = end ? end.substring(0, 10) : ''
  if (s && e) return s + ' ~ ' + e
  return s || e
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

async function loadDetail() {
  if (!planId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getPlan(planId.value)
    const data = response.data || response
    planInfo.value = data
    planItems.value = data.items || []
    planShipments.value = data.shipments || []
  } catch (e) {
    console.error('加载方案详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function goEdit() {
  uni.navigateTo({ url: `/pages/business/plan/form?mode=edit&id=${planId.value}` })
}

function goShipment() {
  uni.navigateTo({ url: `/pages/business/plan/shipment?planId=${planId.value}` })
}

function handleSubmitAudit() {
  uni.showModal({ title: '提示', content: '确认提交审核?', success: async (res) => {
    if (res.confirm) {
      try {
        await submitAuditPlan(planId.value)
        uni.showToast({ title: '提交成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('提交审核失败:', e) }
    }
  }})
}

function handleAuditPass() {
  uni.showModal({ title: '提示', content: '确认审核通过?', success: async (res) => {
    if (res.confirm) {
      try {
        await auditPlan({ planId: planId.value, passed: true })
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
    await auditPlan({ planId: planId.value, passed: false, auditRemark: rejectReason.value })
    uni.showToast({ title: '已驳回', icon: 'success' })
    showRejectPopup.value = false
    loadDetail()
  } catch (e) { console.error('驳回失败:', e) }
}

function handleToggleStatus() {
  const newStatus = planInfo.value.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? '启用' : '停用'
  uni.showModal({ title: '提示', content: `确认${text}该方案?`, success: async (res) => {
    if (res.confirm) {
      try {
        await changePlanStatus(planId.value, newStatus)
        uni.showToast({ title: `${text}成功`, icon: 'success' })
        loadDetail()
      } catch (e) { console.error('状态变更失败:', e) }
    }
  }})
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  planId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})

onShow(() => {
  if (planId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 180rpx; }

.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.plan-no { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.status-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #F2F3F5; color: #86909C; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #E8FFEA; color: #00B42A; }
  &.status-3 { background: #F0E8FF; color: #8B5CF6; }
  &.status-4 { background: #FFECE8; color: #F53F3F; }
}

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 24rpx; box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05); }
.card-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 16rpx; border-radius: 4rpx; }

.info-body { display: flex; flex-direction: column; gap: 10rpx; }
.info-row { display: flex; align-items: center; gap: 10rpx;
  .u-icon { flex-shrink: 0; }
  &.amount-row { margin-top: 4rpx; padding-top: 8rpx; }
}
.label { font-size: 26rpx; color: #86909C; min-width: 80rpx; }
.value { font-size: 27rpx; color: #1D2129; flex: 1;
  &.amount { color: #FF6B35; font-weight: 600; font-size: 30rpx; }
  &.amount-warning { color: #F53F3F; font-weight: 600; }
  &.time { font-size: 24rpx; color: #86909C; flex: none; }
  &.remark-text { word-break: break-all; }
}

.item-card { padding: 20rpx 0; border-bottom: 1rpx solid #F2F3F5; &:last-child { border-bottom: none; } }
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx;
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

.shipment-status { padding: 4rpx 12rpx; border-radius: 4rpx; font-size: 22rpx; font-weight: 500;
  &.shipment-0 { background: #FFF7E8; color: #FF7D00; }
  &.shipment-1 { background: #E8F0FE; color: #3D6DF7; }
  &.shipment-2 { background: #E8FFEA; color: #00B42A; }
  &.shipment-3 { background: #F0E8FF; color: #8B5CF6; }
  &.shipment-4 { background: #FFECE8; color: #F53F3F; }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.08); z-index: 100; }
.action-btns { display: flex; gap: 16rpx; flex-wrap: wrap;
  .u-button { flex: 1; min-width: 140rpx; }
}

.reject-content { padding: 30rpx; background: #fff; border-radius: 16rpx; width: 600rpx; }
.reject-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; text-align: center; }
.reject-input-box { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 24rpx; }
.reject-textarea { width: 100%; min-height: 160rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; }
.reject-actions { display: flex; gap: 20rpx; .u-button { flex: 1; } }
</style>
