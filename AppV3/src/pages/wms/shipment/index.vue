<template>
  <view class="shipment-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索出库单号/企业名称" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" :class="{ active: hasActiveFilters }" @click="toggleFilter">
          <u-icon name="list" size="12" :color="hasActiveFilters ? '#3D6DF7' : '#4E5969'"></u-icon>
          <text>筛选</text>
        </view>
      </view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">出库状态</view>
          <view class="form-options">
            <view v-for="item in statusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">配送方式</view>
          <view class="form-options">
            <view v-for="item in shipTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.shipType === item.value }" @click="queryParams.shipType = queryParams.shipType === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="stockOutList.length > 0" class="card-list">
        <view v-for="item in stockOutList" :key="item.stockOutId" class="shipment-card" @click="goDetail(item)">
          <view class="card-header">
            <text class="shipment-no">{{ item.stockOutNo || '-' }}</text>
            <view class="status-badge" :class="'status-' + String(item.status)">{{ getStatusLabel(item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <text class="info-value enterprise">{{ item.enterpriseName || '-' }}</text>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">发货方式</text>
                <text class="info-value">{{ getShipTypeLabel(item.shipType) }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">数量</text>
                <text class="info-value">{{ item.totalQuantity || 0 }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">金额</text>
                <text class="info-value amount">¥{{ formatAmount(item.totalAmount) }}</text>
              </view>
            </view>
            <view class="info-row">
              <text class="info-time">{{ formatTime(item.createTime) }}</text>
            </view>
          </view>
          <view class="card-actions" v-if="hasActions(item)" @click.stop>
            <view v-if="canConfirm(item)" class="action-tag confirm" @click.stop="handleConfirm(item)">确认出库</view>
            <view v-if="String(item.status) === '1'" class="action-tag cancel" @click.stop="handleCancelConfirm(item)">取消确认</view>
            <view v-if="canShip(item)" class="action-tag ship" @click.stop="handleShip(item)">发货</view>
            <view v-if="canConfirmReceipt(item)" class="action-tag receipt" @click.stop="handleConfirmReceipt(item)">确认收货</view>
            <view v-if="canEdit(item)" class="action-tag edit" @click.stop="goEdit(item)">编辑</view>
            <view v-if="canDelete(item)" class="action-tag delete" @click.stop="handleDelete(item)">删除</view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无出库数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

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
                <image :src="img" mode="aspectFill" @click="previewImage(img)" />
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

    <u-popup :show="showConfirmWarehousePicker" mode="bottom" round="16" @close="showConfirmWarehousePicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择出库仓库</text>
          <view class="picker-close" @click="showConfirmWarehousePicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <picker :range="confirmWarehouseNames" @change="onConfirmWarehouseChange">
          <view class="warehouse-picker-list">
            <view v-for="(w, idx) in confirmWarehouseList" :key="w.warehouseId" class="warehouse-picker-item" @click="onConfirmWarehouseChange({ detail: { value: idx } })">
              <text>{{ w.warehouseName }}</text>
            </view>
          </view>
        </picker>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listStockOut, delStockOut, confirmStockOut, cancelConfirmStockOut, shipStockOut, confirmReceipt } from '@/api/wms/stockOut'
import { getDicts } from '@/api/system/dictData'
import { listWarehouse } from '@/api/wms/warehouse'
import { checkPermi } from '@/utils/permission'
import { useWarehouse } from '@/composables/useWarehouse'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { getToken } from '@/utils/auth'
import config from '@/config'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const stockOutList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showShipPopup = ref(false)
const showLogisticsView = ref(false)
const currentShipItem = ref(null)
const shipForm = ref({ logisticsCompany: '', logisticsNo: '', shipTypeIndex: 1, shipmentImages: [], remark: '' })
const showConfirmWarehousePicker = ref(false)
const confirmWarehouseList = ref([])
const confirmingStockOutId = ref(null)
const confirmWarehouseNames = computed(() => confirmWarehouseList.value.map(w => w.warehouseName))
const confirmWarehouseIndex = ref(0)
const logisticsCompanyOptions = ref([])

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => (queryParams.status !== '' && queryParams.status !== undefined) || (queryParams.shipType !== '' && queryParams.shipType !== undefined))

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '', shipType: '', warehouseId: '' })

const statusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '已确认(待发货)', value: '1' },
  { label: '已发货', value: '2' },
  { label: '已完成', value: '3' }
])

const shipTypeOptions = ref([
  { label: '无需发货', value: '0' },
  { label: '自提', value: '1' },
  { label: '物流', value: '2' }
])

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

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

function canConfirm(item) { return String(item.status) === '0' && checkPermi('wms:stockOut:confirm') }
function canShip(item) { return String(item.status) === '1' && checkPermi('wms:stockOut:ship') }
function canConfirmReceipt(item) { return String(item.status) === '2' && checkPermi('wms:stockOut:receipt') }
function canEdit(item) { return String(item.status) === '0' && checkPermi('wms:stockOut:edit') }
function canDelete(item) { return String(item.status) === '0' && checkPermi('wms:stockOut:remove') }
function hasActions(item) { return canConfirm(item) || canShip(item) || canConfirmReceipt(item) || canEdit(item) || canDelete(item) }

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.status !== '' && queryParams.status !== undefined) params.status = queryParams.status
    if (queryParams.shipType !== '' && queryParams.shipType !== undefined) params.shipType = queryParams.shipType
    if (queryParams.keyword) { params.stockOutNo = queryParams.keyword; params.enterpriseName = queryParams.keyword }
    if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
    const response = await listStockOut(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    stockOutList.value = isRefresh ? list : [...stockOutList.value, ...list]
    loadStatus.value = stockOutList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取出库列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.status = ''; queryParams.shipType = '' }
function confirmFilter() { showFilter.value = false; getList(true) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/shipment/detail?id=${item.stockOutId}` })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/wms/shipment/edit?id=${item.stockOutId}` })
}

function handleConfirm(item) {
  if (!item.warehouseId) {
    // 出库单未指定仓库，弹出仓库选择
    confirmingStockOutId.value = item.stockOutId
    loadConfirmWarehouses()
    return
  }
  uni.showModal({ title: '提示', content: '确认出库后将减少库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockOut(item.stockOutId)
        uni.showToast({ title: '确认出库成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('确认出库失败:', e) }
    }
  }})
}

async function loadConfirmWarehouses() {
  try {
    const res = await listWarehouse({ status: '0' })
    confirmWarehouseList.value = res.rows || res.data || []
    if (confirmWarehouseList.value.length > 0) {
      showConfirmWarehousePicker.value = true
    } else {
      uni.showToast({ title: '暂无可用仓库', icon: 'none' })
    }
  } catch (e) {
    uni.showToast({ title: '加载仓库失败', icon: 'none' })
  }
}

function onConfirmWarehouseChange(e) {
  const idx = e.detail.value
  const warehouse = confirmWarehouseList.value[idx]
  if (!warehouse) return
  showConfirmWarehousePicker.value = false
  uni.showModal({ title: '提示', content: `确认从【${warehouse.warehouseName}】出库？`, success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockOut(confirmingStockOutId.value, warehouse.warehouseId)
        uni.showToast({ title: '确认出库成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('确认出库失败:', e) }
    }
  }})
}

function handleCancelConfirm(item) {
  uni.showModal({
    title: '提示',
    content: '确认取消出库？取消后将恢复库存',
    success: (res) => {
      if (res.confirm) {
        cancelConfirmStockOut(item.stockOutId).then(() => {
          uni.showToast({ title: '取消确认成功', icon: 'success' })
          getList()
        })
      }
    }
  })
}

function handleShip(item) {
  currentShipItem.value = item
  shipForm.value = { logisticsCompany: '', logisticsNo: '', shipTypeIndex: 1, shipmentImages: [], remark: '' }
  showLogisticsView.value = false
  showShipPopup.value = true
}

async function confirmShip() {
  if (shipForm.value.shipTypeIndex === 1) {
    if (!shipForm.value.logisticsCompany.trim()) { uni.showToast({ title: '请选择物流公司', icon: 'none' }); return }
    if (!shipForm.value.logisticsNo.trim()) { uni.showToast({ title: '请输入物流单号', icon: 'none' }); return }
  }
  try {
    await shipStockOut(currentShipItem.value.stockOutId, {
      ship_type: String(shipForm.value.shipTypeIndex + 1),
      logistics_company: shipForm.value.logisticsCompany,
      logistics_no: shipForm.value.logisticsNo,
      shipment_images: JSON.stringify(shipForm.value.shipmentImages),
      remark: shipForm.value.remark
    })
    uni.showToast({ title: '发货成功', icon: 'success' })
    showShipPopup.value = false
    getList(true)
  } catch (e) { console.error('发货失败:', e) }
}

function handleConfirmReceipt(item) {
  uni.showModal({ title: '提示', content: '确认已收货？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmReceipt(item.stockOutId)
        uni.showToast({ title: '确认收货成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('确认收货失败:', e) }
    }
  }})
}

function handleDelete(item) {
  uni.showModal({ title: '提示', content: '确认删除该出库单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockOut(item.stockOutId)
        uni.showToast({ title: '删除成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

function handleShipTypeChange(e) {
  shipForm.value.shipTypeIndex = e.detail.value
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

function previewImage(url) {
  uni.previewImage({ urls: [url], current: url })
}

function handleWarehouseChange(warehouseId) {
  queryParams.warehouseId = warehouseId
  getList()
}

onMounted(async () => {
  await loadWarehouses()
  getList(true)
  getDicts('logistics_company').then(res => {
    logisticsCompanyOptions.value = (res.data || []).map(d => d.dictLabel)
  }).catch(() => { logisticsCompanyOptions.value = [] })
})

onShow(() => {
  loadWarehouses()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.shipment-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 0; }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; box-shadow: 0 2rpx 8rpx rgba(61,109,247,0.06); }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 6rpx; height: 56rpx; padding: 0 22rpx; background: #F5F7FA; border-radius: 28rpx; transition: all 0.2s;
  text { font-size: 26rpx; color: #4E5969; font-weight: 500; white-space: nowrap; }
  &.active { background: #e8f0fe;
    text { color: #3D6DF7; }
  }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent; transition: all 0.2s;
  &.active { background: #e8f0fe; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.drawer-content { background: #fff; border-radius: 16rpx 16rpx 0 0; max-height: 80vh; display: flex; flex-direction: column; box-sizing: border-box; overflow: hidden; }
.drawer-handle { width: 64rpx; height: 8rpx; background: #E5E6EB; border-radius: 4rpx; margin: 16rpx auto 0; }
.drawer-header { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 32rpx 16rpx; }
.drawer-title { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; text-align: center; }
.drawer-close { padding: 8rpx; }
.drawer-back { padding: 8rpx; margin-right: 8rpx; }
.drawer-body { flex: 1; padding: 0 32rpx; max-height: 55vh; box-sizing: border-box; }
.drawer-actions { display: flex; gap: 20rpx; padding: 20rpx 32rpx 40rpx; border-top: 1rpx solid #F2F3F5; box-sizing: border-box; .u-button { flex: 1; } }

.ship-type-options { display: flex; gap: 16rpx; margin-bottom: 16rpx; box-sizing: border-box; }
.ship-type-item { flex: 1; text-align: center; padding: 16rpx 0; border-radius: 12rpx; background: #F7F8FA; font-size: 28rpx; color: #4E5969; transition: all 0.2s;
  &.active { background: #E8F0FE; color: #3D6DF7; font-weight: 600; }
}

.logistics-list-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 0; border-bottom: 1rpx solid #F2F3F5; font-size: 28rpx; color: #1D2129;
  &.active { color: #3D6DF7; font-weight: 500; }
}
.logistics-list-empty { padding: 60rpx 0; text-align: center; font-size: 26rpx; color: #86909C; }

.popup-field { margin-bottom: 8rpx; }
.popup-field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 8rpx; }
.popup-input-box { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; margin-bottom: 16rpx; box-sizing: border-box; }
.popup-input { width: 100%; font-size: 28rpx; color: #1D2129; height: 72rpx; }

.form-picker { background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; font-size: 28rpx; color: #1D2129; margin-bottom: 16rpx; box-sizing: border-box; }
.form-textarea { width: 100%; background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; font-size: 28rpx; color: #1D2129; min-height: 120rpx; box-sizing: border-box; }
.image-upload { display: flex; flex-wrap: wrap; gap: 16rpx; margin-bottom: 16rpx; }
.upload-item { position: relative; width: 140rpx; height: 140rpx; border-radius: 12rpx; overflow: hidden;
  image { width: 100%; height: 100%; }
  .remove-btn { position: absolute; top: 0; right: 0; width: 36rpx; height: 36rpx; background: rgba(0,0,0,0.5); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 24rpx; border-radius: 0 0 0 12rpx; }
}
.upload-add { width: 140rpx; height: 140rpx; border: 2rpx dashed #C9CDD4; border-radius: 12rpx; display: flex; align-items: center; justify-content: center;
  text { font-size: 48rpx; color: #C9CDD4; }
}

.list-scroll { flex: 1; overflow: hidden; padding: 12rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 16rpx; }

.shipment-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.shipment-no { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #e8f0fe; color: #3D6DF7; }
  &.status-3 { background: #F0E8FF; color: #8B5CF6; }
}

.card-body { display: flex; flex-direction: column; gap: 10rpx; }
.info-row { display: flex; gap: 32rpx; align-items: center; }
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129;
  &.enterprise { font-size: 28rpx; font-weight: 500; }
  &.amount { color: #FF6B35; font-weight: 600; }
}
.info-time { font-size: 24rpx; color: #86909C; }

.card-actions { display: flex; flex-wrap: wrap; gap: 12rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.action-tag { padding: 8rpx 20rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.confirm { background: #E8F8F0; color: #00B42A; }
  &.cancel { background: #FFF1E8; color: #FF7D00; }
  &.ship { background: #E8F0FE; color: #3D6DF7; }
  &.receipt { background: #F0E8FF; color: #8B5CF6; }
  &.edit { background: #FFF7E8; color: #FF7D00; }
  &.delete { background: #FFECE8; color: #F53F3F; }
}

.warehouse-picker-list { padding: 20rpx 0; }
.warehouse-picker-item { padding: 24rpx 30rpx; font-size: 28rpx; color: #1D2129; border-bottom: 1rpx solid #F2F3F5;
  &:active { background: #F5F7FA; }
}
.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
</style>
