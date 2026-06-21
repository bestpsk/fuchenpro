<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="transfer-no">{{ info.transferNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.status)">{{ getStatusLabel(info.status) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row" v-if="info.fromWarehouseName">
          <text class="info-label">源仓库</text>
          <text class="info-value">{{ info.fromWarehouseName }}</text>
        </view>
        <view class="info-row" v-if="info.toWarehouseName">
          <text class="info-label">目标仓库</text>
          <text class="info-value">{{ info.toWarehouseName }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">总数量</text>
          <text class="info-value">{{ info.totalQuantity || 0 }}</text>
        </view>
        <view class="info-row" v-if="info.transferDate">
          <text class="info-label">调拨日期</text>
          <text class="info-value">{{ formatTime(info.transferDate) }}</text>
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

    <view class="info-card" v-if="transferItems.length > 0">
      <view class="section-header">
        <view class="card-title">调拨明细</view>
        <text class="item-count">{{ transferItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in transferItems" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-index">{{ idx + 1 }}.</text>
          <text class="item-name">{{ item.productName || '-' }}</text>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">单位类型</text>
              <text class="info-value">{{ item.unitType === '1' ? '主单位(整)' : '副单位(拆)' }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">规格</text>
              <text class="info-value">{{ item.unitType === '1' ? (getUnitLabel(item.unit) || '-') : (getSpecLabel(item.spec) || '-') }}</text>
            </view>
          </view>
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">数量</text>
              <text class="info-value">{{ item.unitType === '1' && item.packQty > 1 ? (item.originalQuantity || item.quantity) : item.quantity }}</text>
            </view>
            <view class="info-right" v-if="item.packQty && item.packQty > 1">
              <text class="info-label">换算</text>
              <text class="info-value">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canConfirm" type="success" text="确认调拨" @click="handleConfirm"></u-button>
        <u-button v-if="canCancelConfirm" type="warning" text="取消确认" @click="handleCancelConfirm"></u-button>
        <u-button v-if="canDelete" type="error" plain text="删除" @click="handleDelete"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getStockTransfer, confirmStockTransfer, cancelConfirmStockTransfer, delStockTransfer } from '@/api/wms/stockTransfer'
import { getDicts } from '@/api/system/dictData'

const info = ref({})
const transferItems = ref([])
const transferId = ref(null)

const unitOptions = ref([])
const specOptions = ref([])

function getUnitLabel(value) {
  if (value === undefined || value === null || value === '') return ''
  const item = unitOptions.value.find(d => String(d.dictValue) === String(value))
  return item ? item.dictLabel : String(value)
}

function getSpecLabel(value) {
  if (value === undefined || value === null || value === '') return ''
  const item = specOptions.value.find(d => String(d.dictValue) === String(value))
  return item ? item.dictLabel : String(value)
}

async function loadDicts() {
  try {
    const [unitRes, specRes] = await Promise.all([
      getDicts('biz_product_unit'),
      getDicts('biz_product_spec')
    ])
    unitOptions.value = (unitRes.data || unitRes) || []
    specOptions.value = (specRes.data || specRes) || []
  } catch (e) { console.error('加载字典失败:', e) }
}

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认', '2': '已取消' }
  return map[String(status)] || '未知'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

const canConfirm = computed(() => String(info.value.status) === '0')
const canCancelConfirm = computed(() => String(info.value.status) === '1')
const canDelete = computed(() => String(info.value.status) === '0')
const showActions = computed(() => canConfirm.value || canCancelConfirm.value || canDelete.value)

async function loadDetail() {
  if (!transferId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockTransfer(transferId.value)
    const data = response.data || response
    info.value = data
    transferItems.value = data.items || []
  } catch (e) {
    console.error('加载调拨详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function handleConfirm() {
  uni.showModal({ title: '提示', content: '确认调拨后将从源仓库扣减库存并计入目标仓库，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockTransfer(transferId.value)
        uni.showToast({ title: '确认调拨成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('确认调拨失败:', e) }
    }
  }})
}

function handleCancelConfirm() {
  uni.showModal({ title: '提示', content: '确认取消调拨？取消后库存数量将回退。', success: async (res) => {
    if (res.confirm) {
      try {
        await cancelConfirmStockTransfer(transferId.value)
        uni.showToast({ title: '取消确认成功', icon: 'success' })
        loadDetail()
      } catch (e) { console.error('取消确认失败:', e) }
    }
  }})
}

function handleDelete() {
  uni.showModal({ title: '提示', content: '确认删除该调拨单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockTransfer(transferId.value)
        uni.showToast({ title: '删除成功', icon: 'success' })
        setTimeout(() => {
          const pages = getCurrentPages()
          if (pages.length > 1) uni.navigateBack()
          else uni.redirectTo({ url: '/pages/wms/stockTransfer/index' })
        }, 1500)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

onLoad((options) => {
  transferId.value = options.id ? parseInt(options.id) : null
  loadDicts()
  loadDetail()
})

onShow(() => {
  if (transferId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 24rpx 28rpx; margin-bottom: 16rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; padding-bottom: 16rpx; border-bottom: 1rpx solid #F2F3F5; }
.transfer-no { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #ff9900; }
  &.status-1 { background: #E8F8F0; color: #00b42a; }
  &.status-2 { background: #F2F3F5; color: #86909c; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 16rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 14rpx; border-radius: 6rpx; }

.info-body { display: flex; flex-direction: column; gap: 12rpx; }
.info-row { display: flex; align-items: center; gap: 16rpx; padding: 8rpx 0; }
.info-label { font-size: 26rpx; color: #86909C; width: 120rpx; flex-shrink: 0; text-align: right; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.remark-text { word-break: break-all; line-height: 1.6; }
}

.item-card { background: #FAFBFC; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 12rpx; border: 1rpx solid #F0F1F3; &:last-child { margin-bottom: 0; } }
.item-header { display: flex; align-items: center; margin-bottom: 10rpx;
  .item-index { font-size: 26rpx; color: #86909C; font-weight: 500; margin-right: 8rpx; }
  .item-name { font-size: 27rpx; color: #1D2129; font-weight: 500; flex: 1; }
}
.item-body { display: flex; flex-direction: column; gap: 12rpx; }
.info-line { display: flex; align-items: center; justify-content: space-between; height: 64rpx;
  .info-left { display: flex; align-items: center; gap: 8rpx; flex: 1; }
  .info-right { display: flex; align-items: center; gap: 8rpx; flex-shrink: 0; margin-left: auto; }
  .info-label { color: #86909C; white-space: nowrap; font-size: 24rpx; width: 80rpx; text-align: right; }
  .info-value { color: #4E5969; font-size: 27rpx; }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 16rpx 24rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 12rpx;
  .u-button { flex: 1; }
}
</style>
