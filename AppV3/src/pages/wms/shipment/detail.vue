<template>
  <view class="detail-container">
    <!-- 基本信息 -->
    <view class="info-card">
      <view class="card-header-row">
        <text class="shipment-no">{{ info.stockOutNo || '-' }}</text>
        <view class="status-badge" :class="'status-' + String(info.status)">{{ getStatusLabel(info.status) }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">出库类型</text>
          <text class="info-value">{{ info.stockOutType === '1' ? '销售出库' : info.stockOutType === '2' ? '领用出库' : '其他' }}</text>
        </view>
        <view class="info-row" v-if="info.warehouseName">
          <text class="info-label">仓库</text>
          <text class="info-value">{{ info.warehouseName }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">企业</text>
          <text class="info-value">{{ info.enterpriseName || '-' }}</text>
        </view>
        <view class="info-row" v-if="info.planId">
          <text class="info-label">关联方案</text>
          <text class="info-value">{{ info.planName || '-' }}</text>
        </view>
        <view class="info-row" v-if="info.prepareId">
          <text class="info-label">来源</text>
          <text class="info-value">备货出库</text>
        </view>
        <view class="info-row">
          <text class="info-label">发货方式</text>
          <text class="info-value">{{ getShipTypeLabel(info.shipType) }}</text>
        </view>
        <view class="info-row" v-if="info.stockOutDate">
          <text class="info-label">出库日期</text>
          <text class="info-value">{{ info.stockOutDate }}</text>
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

    <!-- 收货信息 -->
    <view class="info-card" v-if="info.contactPerson || info.contactPhone || info.shippingAddress">
      <view class="card-title">收货信息</view>
      <view class="info-body">
        <view class="info-row" v-if="info.contactPerson">
          <text class="info-label">收货人</text>
          <text class="info-value">{{ info.contactPerson }}</text>
        </view>
        <view class="info-row" v-if="info.contactPhone">
          <text class="info-label">收货电话</text>
          <text class="info-value phone-link" @click="callPhone">{{ info.contactPhone }}</text>
        </view>
        <view class="info-row" v-if="info.shippingAddress">
          <text class="info-label">收货地址</text>
          <text class="info-value">{{ info.shippingAddress }}</text>
        </view>
      </view>
    </view>

    <!-- 物流信息 -->
    <view class="info-card" v-if="String(info.shipType) === '2' && (String(info.status) === '2' || String(info.status) === '3')">
      <view class="card-title">物流信息</view>
      <view class="info-body">
        <view class="info-row" v-if="info.logisticsCompany">
          <text class="info-label">物流公司</text>
          <text class="info-value">{{ info.logisticsCompany }}</text>
        </view>
        <view class="info-row" v-if="info.logisticsNo">
          <text class="info-label">物流单号</text>
          <text class="info-value">{{ info.logisticsNo }}</text>
        </view>
        <view class="info-row" v-if="info.shipmentDate">
          <text class="info-label">发货日期</text>
          <text class="info-value">{{ info.shipmentDate }}</text>
        </view>
        <view class="info-row" v-if="info.receiptDate">
          <text class="info-label">收货日期</text>
          <text class="info-value">{{ info.receiptDate }}</text>
        </view>
        <view class="info-row" v-if="shipmentImageList.length > 0">
          <text class="info-label">发货凭证</text>
          <view class="image-list">
            <image v-for="(img, idx) in shipmentImageList" :key="idx" :src="img" mode="aspectFill" class="detail-image" @click="previewImage(img)" />
          </view>
        </view>
      </view>
    </view>

    <!-- 出库明细 -->
    <view class="info-card" v-if="stockOutItems.length > 0">
      <view class="section-header">
        <view class="card-title">出库明细</view>
        <text class="item-count">{{ stockOutItems.length }}项</text>
      </view>
      <view v-for="(item, idx) in stockOutItems" :key="idx" class="item-card">
        <view class="item-header">
          <text class="item-index">{{ idx + 1 }}.</text>
          <text class="item-name">{{ item.productName || '-' }}</text>
          <text v-if="item.supplierName" class="supplier-tag">{{ item.supplierName }}</text>
        </view>
        <view class="item-body">
          <view class="info-line">
            <view class="info-left">
              <text class="info-label">单位类型</text>
              <text class="info-value">{{ item.unitType === '2' ? '副单位(拆)' : '主单位(整)' }}</text>
            </view>
            <view class="info-right">
              <text class="info-label">数量</text>
              <text class="info-value">{{ getDisplayQuantity(item) }}{{ getItemUnitLabel(item) }}</text>
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

    <!-- 操作按钮 -->
    <view class="action-section" v-if="showActions">
      <view class="action-btns">
        <u-button v-if="canConfirm" type="success" text="确认出库" @click="handleConfirm"></u-button>
        <u-button v-if="canShip" type="primary" text="发货" @click="showShipPopup = true"></u-button>
        <u-button v-if="canConfirmReceipt" type="success" text="确认收货" @click="handleConfirmReceipt"></u-button>
      </view>
    </view>

    <!-- 发货抽屉 -->
    <u-popup :show="showShipPopup" mode="bottom" round="16" @close="showShipPopup = false">
      <view class="drawer-content">
        <view class="drawer-handle"></view>
        <view class="drawer-header">
          <view v-if="showLogisticsView" class="drawer-back" @click="showLogisticsView = false"><u-icon name="arrow-left" size="20" color="#4E5969"></u-icon></view>
          <text class="drawer-title">{{ showLogisticsView ? '选择物流公司' : '填写物流信息' }}</text>
          <view class="drawer-close" @click="showShipPopup = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <!-- 物流信息表单 -->
        <scroll-view v-if="!showLogisticsView" scroll-y class="drawer-body">
          <view class="popup-field">
            <view class="popup-field-label">发货方式</view>
            <view class="ship-type-options">
              <view class="ship-type-item" :class="{ active: shipForm.shipTypeIndex === 0 }" @click="shipForm.shipTypeIndex = 0">自提</view>
              <view class="ship-type-item" :class="{ active: shipForm.shipTypeIndex === 1 }" @click="shipForm.shipTypeIndex = 1">物流</view>
            </view>
          </view>
          <view v-if="shipForm.shipTypeIndex === 1">
            <view class="popup-field">
              <view class="popup-field-label">物流公司</view>
              <view class="form-picker" @click="showLogisticsView = true">{{ shipForm.logisticsCompany || '请选择物流公司' }}</view>
            </view>
            <view class="popup-field">
              <view class="popup-field-label">物流单号</view>
              <view class="popup-input-box">
                <input class="popup-input" type="text" v-model="shipForm.logisticsNo" placeholder="请输入物流单号" placeholder-class="field-placeholder" />
              </view>
            </view>
          </view>
          <view class="popup-field">
            <view class="popup-field-label">发货凭证</view>
            <view class="image-upload">
              <view class="upload-item" v-for="(img, idx) in shipForm.shipmentImages" :key="idx">
                <image :src="img" mode="aspectFill" @click="previewShipImage(img)" />
                <view class="remove-btn" @click="removeImage(idx)">×</view>
              </view>
              <view class="upload-add" @click="chooseImage" v-if="shipForm.shipmentImages.length < 5">
                <text>+</text>
              </view>
            </view>
          </view>
          <view class="popup-field">
            <view class="popup-field-label">备注</view>
            <textarea v-model="shipForm.remark" placeholder="请输入备注" class="form-textarea" />
          </view>
        </scroll-view>
        <!-- 物流公司选择列表 -->
        <scroll-view v-else scroll-y class="drawer-body">
          <view class="logistics-list-item" :class="{ active: shipForm.logisticsCompany === item }" v-for="(item, idx) in logisticsCompanyOptions" :key="idx" @click="onSelectLogistics(item)">
            <text>{{ item }}</text>
            <u-icon v-if="shipForm.logisticsCompany === item" name="checkmark" color="#3D6DF7" size="36rpx"></u-icon>
          </view>
          <view class="logistics-list-empty" v-if="logisticsCompanyOptions.length === 0">
            <text>暂无物流公司数据</text>
          </view>
        </scroll-view>
        <view class="drawer-actions" v-if="!showLogisticsView">
          <u-button type="info" plain text="取消" @click="showShipPopup = false"></u-button>
          <u-button type="primary" text="确认发货" @click="confirmShip"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 自定义图片预览（z-index高于弹窗） -->
    <view class="image-preview-overlay" v-if="showImagePreview" @click="showImagePreview = false">
      <view class="image-preview-close" @click.stop="showImagePreview = false">×</view>
      <image :src="previewImageUrl" mode="aspectFit" class="image-preview-img" @click.stop />
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getStockOut, confirmStockOut, shipStockOut, confirmReceipt } from '@/api/wms/stockOut'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'
import { getToken } from '@/utils/auth'
import config from '@/config'

const info = ref({})
const stockOutItems = ref([])
const stockOutId = ref(null)
const showShipPopup = ref(false)
const showLogisticsView = ref(false)
const showImagePreview = ref(false)
const previewImageUrl = ref('')
const shipForm = ref({ logisticsCompany: '', logisticsNo: '', shipTypeIndex: 1, shipmentImages: [], remark: '' })
const logisticsCompanyOptions = ref([])
const productUnitDict = ref([])
const productSpecDict = ref([])

function getUnitLabel(item) {
  if (!item.unit) return ''
  const dict = productUnitDict.value.find(d => d.value === String(item.unit))
  return dict ? dict.label : ''
}

function getSpecLabel(item) {
  if (!item.spec) return ''
  const dict = productSpecDict.value.find(d => d.value === String(item.spec))
  return dict ? dict.label : ''
}

function getItemUnitLabel(item) {
  return item.unitType === '2' ? getSpecLabel(item) : getUnitLabel(item)
}

function getDisplayQuantity(item) {
  const unitType = item.unitType || '1'
  const packQty = item.packQty || 1
  if (unitType === '1' && packQty > 1) {
    return Math.round((item.quantity || 0) / packQty * 10000) / 10000
  }
  return item.quantity || 0
}

const shipmentImageList = computed(() => {
  try {
    return JSON.parse(info.value.shipmentImages || '[]')
  } catch { return [] }
})

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

function previewImage(url) {
  uni.previewImage({ urls: shipmentImageList.value, current: url })
}

function onSelectLogistics(item) {
  shipForm.value.logisticsCompany = item
  showLogisticsView.value = false
}

function chooseImage() {
  uni.chooseImage({
    count: 5 - shipForm.value.shipmentImages.length,
    success: (res) => {
      res.tempFilePaths.forEach(path => {
        uni.uploadFile({
          url: config.baseUrl + '/common/upload',
          filePath: path,
          name: 'file',
          header: { Authorization: 'Bearer ' + getToken() },
          success: (uploadRes) => {
            const data = JSON.parse(uploadRes.data)
            if (data.code === 200) {
              shipForm.value.shipmentImages.push(data.url || data.fileName)
            }
          }
        })
      })
    }
  })
}

function removeImage(idx) {
  shipForm.value.shipmentImages.splice(idx, 1)
}

function previewShipImage(url) {
  previewImageUrl.value = url
  showImagePreview.value = true
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
  if (shipForm.value.shipTypeIndex === 1) {
    if (!shipForm.value.logisticsCompany.trim()) { uni.showToast({ title: '请选择物流公司', icon: 'none' }); return }
    if (!shipForm.value.logisticsNo.trim()) { uni.showToast({ title: '请输入物流单号', icon: 'none' }); return }
  }
  try {
    await shipStockOut(stockOutId.value, {
      ship_type: String(shipForm.value.shipTypeIndex + 1),
      logistics_company: shipForm.value.logisticsCompany,
      logistics_no: shipForm.value.logisticsNo,
      shipment_images: JSON.stringify(shipForm.value.shipmentImages),
      remark: shipForm.value.remark
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
  getDicts('logistics_company').then(res => {
    logisticsCompanyOptions.value = (res.data || []).map(d => d.dictLabel)
  }).catch(() => { logisticsCompanyOptions.value = [] })
  getDicts('biz_product_unit').then(res => {
    productUnitDict.value = (res.data || []).map(d => ({ value: d.dictValue, label: d.dictLabel }))
  })
  getDicts('biz_product_spec').then(res => {
    productSpecDict.value = (res.data || []).map(d => ({ value: d.dictValue, label: d.dictLabel }))
  })
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
  .supplier-tag { font-size: 22rpx; color: #3D6DF7; background: #F0F3FF; padding: 4rpx 14rpx; border-radius: 6rpx; flex-shrink: 0; margin-left: auto; }
}
.item-body { display: flex; flex-direction: column; gap: 10rpx; padding-left: 32rpx; }
.info-line { display: flex; align-items: center; justify-content: space-between; font-size: 25rpx; line-height: 1.6;
  .info-left { display: flex; align-items: center; gap: 8rpx; flex: 1; }
  .info-right { display: flex; align-items: center; gap: 8rpx; flex-shrink: 0; margin-left: auto; min-width: 200rpx; justify-content: flex-end; }
  .info-label { color: #86909C; white-space: nowrap; font-size: 24rpx; }
  .info-value { color: #4E5969; font-size: 25rpx;
    &.amount { color: #FF6B35; font-weight: 600; }
  }
}

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}

.popup-content { padding: 30rpx; background: #fff; border-radius: 16rpx; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; text-align: center; }
.popup-input-box { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 16rpx; }
.popup-input { width: 100%; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.popup-field { margin-bottom: 8rpx; }
.popup-field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 8rpx; }
.popup-actions { display: flex; gap: 20rpx; margin-top: 24rpx; .u-button { flex: 1; } }

.drawer-content { background: #fff; border-radius: 16rpx 16rpx 0 0; max-height: 80vh; display: flex; flex-direction: column; }
.drawer-handle { width: 64rpx; height: 8rpx; background: #E5E6EB; border-radius: 4rpx; margin: 16rpx auto 0; }
.drawer-header { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 32rpx 16rpx; }
.drawer-title { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; text-align: center; }
.drawer-close { padding: 8rpx; }
.drawer-back { padding: 8rpx; margin-right: 8rpx; }
.drawer-body { flex: 1; padding: 0 32rpx; max-height: 55vh; }
.drawer-actions { display: flex; gap: 20rpx; padding: 20rpx 32rpx 40rpx; border-top: 1rpx solid #F2F3F5; .u-button { flex: 1; } }

.logistics-list-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 0; border-bottom: 1rpx solid #F2F3F5; font-size: 28rpx; color: #1D2129;
  &.active { color: #3D6DF7; font-weight: 500; }
}
.logistics-list-empty { padding: 60rpx 0; text-align: center; font-size: 26rpx; color: #86909C; }

.form-picker { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; font-size: 28rpx; color: #1D2129; margin-bottom: 16rpx; }
.form-textarea { width: 100%; background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; font-size: 28rpx; color: #1D2129; min-height: 120rpx; box-sizing: border-box; }
.image-upload { display: flex; flex-wrap: wrap; gap: 16rpx; margin-bottom: 16rpx; }
.upload-item { position: relative; width: 140rpx; height: 140rpx; border-radius: 12rpx; overflow: hidden;
  image { width: 100%; height: 100%; }
  .remove-btn { position: absolute; top: 0; right: 0; width: 36rpx; height: 36rpx; background: rgba(0,0,0,0.5); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 24rpx; border-radius: 0 0 0 12rpx; }
}
.upload-add { width: 140rpx; height: 140rpx; border: 2rpx dashed #C9CDD4; border-radius: 12rpx; display: flex; align-items: center; justify-content: center;
  text { font-size: 48rpx; color: #C9CDD4; }
}

.image-list { display: flex; flex-wrap: wrap; gap: 12rpx; flex: 1; }
.detail-image { width: 120rpx; height: 120rpx; border-radius: 8rpx; }

.ship-type-options { display: flex; gap: 16rpx; margin-bottom: 16rpx; }
.ship-type-item { flex: 1; text-align: center; padding: 16rpx 0; border-radius: 12rpx; background: #F7F8FA; font-size: 28rpx; color: #4E5969; transition: all 0.2s;
  &.active { background: #E8F0FE; color: #3D6DF7; font-weight: 600; }
}

.image-preview-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 9999; background: rgba(0, 0, 0, 0.9); display: flex; align-items: center; justify-content: center; }
.image-preview-close { position: absolute; top: 60rpx; right: 30rpx; width: 60rpx; height: 60rpx; color: #fff; font-size: 48rpx; display: flex; align-items: center; justify-content: center; z-index: 10000; }
.image-preview-img { width: 100%; height: 80vh; }
</style>
