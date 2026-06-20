<template>
  <view class="stock-container">
    <view class="warehouse-row">
      <WarehouseSelector @change="handleWarehouseChange" />
      <view class="warn-switch-row">
        <text class="warn-switch-label">仅看预警</text>
        <u-switch v-model="warnOnly" activeColor="#3D6DF7" size="20" @change="onWarnSwitchChange"></u-switch>
      </view>
    </view>
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索品名/货品编码" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
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
          <view class="form-label">类别</view>
          <view class="form-options">
            <view v-for="item in categoryOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.category === item.value }" @click="queryParams.category = queryParams.category === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="inventoryList.length > 0" class="card-list">
        <view v-for="item in inventoryList" :key="item.productId" class="stock-card" @click="goDetail(item)">
          <view class="card-header">
            <view class="product-name-row">
              <text class="product-name">{{ item.productName || '-' }}</text>
              <text class="warehouse-tag" v-if="item.warehouseName">{{ item.warehouseName }}</text>
            </view>
            <view class="status-badge" :class="isWarn(item) ? 'status-warn' : 'status-normal'">{{ isWarn(item) ? '预警' : '正常' }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">货品编码</text>
                <text class="info-value">{{ item.productCode || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">类别</text>
                <text class="info-value">{{ getCategoryLabel(item.category) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">库存数量</text>
                <text class="info-value quantity">{{ formatInventoryQty(item) }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">预警数量</text>
                <text class="info-value">{{ formatWarnQty(item) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">单位类型</text>
                <text class="info-value">{{ getUnitTypeLabel(item) }}</text>
              </view>
              <view class="info-item" v-if="item.packQty && item.packQty > 1">
                <text class="info-label">换算</text>
                <text class="info-value">1{{ getUnitLabel(item) }}={{ item.packQty }}{{ getSpecLabel(item) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">进货价</text>
                <text class="info-value price">¥{{ formatAmount(item.purchasePrice) }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">出货价</text>
                <text class="info-value price">¥{{ formatAmount(item.salePrice) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">最后入库</text>
                <text class="info-value">{{ formatTime(item.lastStockInTime) }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">最后出库</text>
                <text class="info-value">{{ formatTime(item.lastStockOutTime) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无库存数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listInventory, listWarnInventory } from '@/api/wms/inventory'
import { checkPermi } from '@/utils/permission'
import { useWarehouse } from '@/composables/useWarehouse'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { getDicts } from '@/api/system/dictData'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const inventoryList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const warnOnly = ref(false)

let searchTimer = null

const hasActiveFilters = computed(() => queryParams.category !== '' && queryParams.category !== undefined)

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', category: '' })

const categoryOptions = ref([])
const unitOptions = ref([])
const specOptions = ref([])

function isWarn(item) {
  return item.quantity !== undefined && item.quantity !== null && item.warnQty !== undefined && item.warnQty !== null && item.quantity <= item.warnQty
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function getCategoryLabel(val) {
  if (!val) return '-'
  const opt = categoryOptions.value.find(o => o.value === String(val))
  return opt ? opt.label : val
}

function getUnitLabel(item) {
  if (!item.unit) return ''
  const opt = unitOptions.value.find(o => o.value === String(item.unit))
  return opt ? opt.label : item.unit
}

function getSpecLabel(item) {
  if (!item.spec) return ''
  const opt = specOptions.value.find(o => o.value === String(item.spec))
  return opt ? opt.label : item.spec
}

function getUnitTypeLabel(item) {
  if (item.packQty && item.packQty > 1) return '主单位(整)'
  return '副单位(拆)'
}

function formatInventoryQty(item) {
  const packQty = item.packQty || 1
  const unitLabel = getUnitLabel(item)
  const specLabel = getSpecLabel(item)
  const qty = item.quantity || 0
  if (packQty > 1 && specLabel) {
    const mainQty = qty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + unitLabel + '（' + qty + specLabel + '）'
  } else if (unitLabel) {
    return qty + unitLabel
  } else {
    return qty
  }
}

function formatWarnQty(item) {
  if (item.warnQty === undefined || item.warnQty === null || item.warnQty === '') return '-'
  const specLabel = getSpecLabel(item)
  return item.warnQty + (specLabel || '')
}

function formatTime(time) {
  if (!time) return '-'
  return String(time).substring(0, 16)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.category !== '' && queryParams.category !== undefined) params.category = queryParams.category
    if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
    if (queryParams.keyword) { params.productName = queryParams.keyword; params.productCode = queryParams.keyword }
    const apiFn = warnOnly.value ? listWarnInventory : listInventory
    const response = await apiFn(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    inventoryList.value = isRefresh ? list : [...inventoryList.value, ...list]
    loadStatus.value = inventoryList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取库存列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.category = '' }
function confirmFilter() { showFilter.value = false; getList(true) }
function onWarnSwitchChange() { getList(true) }

function handleWarehouseChange(warehouseId) {
  queryParams.warehouseId = warehouseId
  getList(true)
}

async function loadCategoryDict() {
  try {
    const [catRes, unitRes, specRes] = await Promise.all([
      getDicts('biz_product_category'),
      getDicts('biz_product_unit'),
      getDicts('biz_product_spec')
    ])
    categoryOptions.value = (catRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    unitOptions.value = (unitRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    specOptions.value = (specRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error('加载字典失败:', e)
  }
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/stock/detail?productId=${item.productId}` })
}

onMounted(async () => {
  // 权限检查
  if (!checkPermi('wms:inventory:list')) {
    uni.showToast({ title: '无库存查看权限', icon: 'none' })
    setTimeout(() => {
      const pages = getCurrentPages()
      if (pages.length > 1) uni.navigateBack()
      else uni.switchTab({ url: '/pages/index' })
    }, 1500)
    return
  }
  loadCategoryDict()
  await loadWarehouses()
  getList(true)
})

onShow(async () => {
  await loadWarehouses()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.stock-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 0; }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04); }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 6rpx; height: 56rpx; padding: 0 22rpx; background: #F5F7FA; border-radius: 28rpx; transition: all 0.2s;
  text { font-size: 26rpx; color: #4E5969; font-weight: 500; white-space: nowrap; }
  &.active { background: #e8f0fe;
    text { color: #3D6DF7; }
  }
}

.warehouse-row { display: flex; align-items: center; justify-content: space-between; background: #fff; padding: 10rpx 20rpx; }
.warn-switch-row { display: flex; align-items: center; gap: 12rpx; flex-shrink: 0; }
.warn-switch-label { font-size: 26rpx; color: #4E5969; font-weight: 500; }

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent; transition: all 0.2s;
  &.active { background: #e8f0fe; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.list-scroll { flex: 1; overflow: hidden; padding: 12rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 16rpx; }

.stock-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.product-name-row { display: flex; align-items: center; flex: 1; min-width: 0; gap: 12rpx; }
.product-name { font-size: 30rpx; font-weight: 600; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.warehouse-tag { flex-shrink: 0; font-size: 20rpx; color: #3D6DF7; background: #e8f0fe; padding: 4rpx 12rpx; border-radius: 6rpx; white-space: nowrap; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-normal { background: #e8f0fe; color: #00B42A; }
  &.status-warn { background: #FFECE8; color: #F53F3F; }
}

.card-body { display: flex; flex-direction: column; gap: 12rpx; }
.info-row { display: flex; gap: 32rpx; }
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; min-width: 0; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  &.quantity { font-weight: 600; }
  &.price { color: #FF6B35; font-weight: 500; }
}
.unit-label { font-size: 22rpx; color: #86909C; margin-left: 4rpx; }
</style>
