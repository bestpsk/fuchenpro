<template>
  <view class="stockin-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索入库单号" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
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
          <view class="form-label">入库状态</view>
          <view class="form-options">
            <view v-for="item in statusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">入库类型</view>
          <view class="form-options">
            <view v-for="item in stockInTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.stockInType === item.value }" @click="queryParams.stockInType = queryParams.stockInType === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="stockInList.length > 0" class="card-list">
        <view v-for="item in stockInList" :key="item.stockInId" class="stockin-card" @click="goDetail(item)">
          <view class="card-header">
            <text class="stockin-no">{{ item.stockInNo || '-' }}</text>
            <view class="status-badge" :class="'status-' + String(item.status)">{{ getStatusLabel(item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">入库类型</text>
                <text class="info-value">{{ getStockInTypeLabel(item.stockInType) }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">操作人</text>
                <text class="info-value">{{ item.operatorName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">总数量</text>
                <text class="info-value">{{ item.totalQuantity || 0 }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">总金额</text>
                <text class="info-value amount">¥{{ formatAmount(item.totalAmount) }}</text>
              </view>
            </view>
            <view class="info-row" v-if="item.earliestExpiry">
              <view class="info-item">
                <text class="info-label">有效期预警</text>
                <view class="expiry-tag" :class="getExpiryClass(item.earliestExpiry)">
                  <u-icon :name="getExpiryClass(item.earliestExpiry) === 'expired' ? 'warning' : 'clock'" size="12" :color="getExpiryClass(item.earliestExpiry) === 'expired' ? '#F53F3F' : '#FF7D00'"></u-icon>
                  <text>{{ getExpiryText(item.earliestExpiry) }}</text>
                </view>
              </view>
            </view>
            <view class="info-row">
              <text class="info-time">{{ formatTime(item.createTime) }}</text>
            </view>
          </view>
          <view class="card-actions" v-if="hasActions(item)" @click.stop>
            <view v-if="canConfirm(item)" class="action-tag confirm" @click.stop="handleConfirm(item)">确认入库</view>
            <view v-if="canCancelConfirm(item)" class="action-tag cancel" @click.stop="handleCancelConfirm(item)">取消确认</view>
            <view v-if="canEdit(item)" class="action-tag edit" @click.stop="goEdit(item)">编辑</view>
            <view v-if="canDelete(item)" class="action-tag delete" @click.stop="handleDelete(item)">删除</view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无入库数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view v-if="checkPermi('wms:stockIn:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listStockIn, delStockIn, confirmStockIn, cancelConfirmStockIn } from '@/api/wms/stockIn'
import { checkPermi } from '@/utils/permission'
import { useWarehouse } from '@/composables/useWarehouse'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const stockInList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null

const hasActiveFilters = computed(() => (queryParams.status !== '' && queryParams.status !== undefined) || (queryParams.stockInType !== '' && queryParams.stockInType !== undefined))

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '', stockInType: '', warehouseId: undefined })

const statusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '已确认', value: '1' }
])

const stockInTypeOptions = ref([
  { label: '采购入库', value: '1' },
  { label: '退货入库', value: '2' },
  { label: '其他入库', value: '3' }
])

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

function getExpiryText(expiryDate) {
  if (!expiryDate) return ''
  const now = new Date()
  const expiry = new Date(expiryDate)
  const diffDays = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24))
  if (diffDays < 0) return '已过期' + Math.abs(diffDays) + '天'
  if (diffDays <= 30) return '即将到期(' + diffDays + '天)'
  return ''
}

function canConfirm(item) { return String(item.status) === '0' && checkPermi('wms:stockIn:confirm') }
function canCancelConfirm(item) { return String(item.status) === '1' && checkPermi('wms:stockIn:edit') }
function canEdit(item) { return String(item.status) === '0' && checkPermi('wms:stockIn:edit') }
function canDelete(item) { return String(item.status) === '0' && checkPermi('wms:stockIn:remove') }
function hasActions(item) { return canConfirm(item) || canCancelConfirm(item) || canEdit(item) || canDelete(item) }

function handleWarehouseChange(warehouseId) {
  queryParams.warehouseId = warehouseId
  getList(true)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.status !== '' && queryParams.status !== undefined) params.status = queryParams.status
    if (queryParams.stockInType !== '' && queryParams.stockInType !== undefined) params.stockInType = queryParams.stockInType
    if (queryParams.keyword) params.stockInNo = queryParams.keyword
    const wid = queryParams.warehouseId || currentWarehouseId.value
    if (wid) params.warehouseId = wid
    const response = await listStockIn(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    stockInList.value = isRefresh ? list : [...stockInList.value, ...list]
    loadStatus.value = stockInList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取入库列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.status = ''; queryParams.stockInType = '' }
function confirmFilter() { showFilter.value = false; getList(true) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/stockIn/detail?id=${item.stockInId}` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/wms/stockIn/form?mode=add' })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/wms/stockIn/form?mode=edit&id=${item.stockInId}` })
}

function handleConfirm(item) {
  uni.showModal({ title: '提示', content: '确认入库后将增加库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockIn(item.stockInId)
        uni.showToast({ title: '确认入库成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('确认入库失败:', e) }
    }
  }})
}

function handleCancelConfirm(item) {
  uni.showModal({
    title: '提示',
    content: '确认取消入库？取消后将恢复库存',
    success: (res) => {
      if (res.confirm) {
        cancelConfirmStockIn(item.stockInId).then(() => {
          uni.showToast({ title: '取消确认成功', icon: 'success' })
          getList()
        })
      }
    }
  })
}

function handleDelete(item) {
  uni.showModal({ title: '提示', content: '确认删除该入库单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockIn(item.stockInId)
        uni.showToast({ title: '删除成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

onShow(async () => { await loadWarehouses(); queryParams.warehouseId = currentWarehouseId.value; getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.stockin-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
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

.stockin-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.stockin-no { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
}

.card-body { display: flex; flex-direction: column; gap: 10rpx; }
.info-row { display: flex; gap: 32rpx; align-items: center; }
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129;
  &.amount { color: #FF6B35; font-weight: 600; }
}
.info-time { font-size: 24rpx; color: #86909C; }

.expiry-tag { display: flex; align-items: center; gap: 6rpx; padding: 4rpx 12rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.warning { background: #FFF7E8; color: #FF7D00; }
  &.expired { background: #FFECE8; color: #F53F3F; }
}

.card-actions { display: flex; flex-wrap: wrap; gap: 12rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.action-tag { padding: 8rpx 20rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.confirm { background: #E8F8F0; color: #00B42A; }
  &.cancel { background: #FFF7E8; color: #FF7D00; }
  &.edit { background: #FFF7E8; color: #FF7D00; }
  &.delete { background: #FFECE8; color: #F53F3F; }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4); z-index: 100; transition: all 0.2s;
  &:active { transform: scale(0.9); }
}
</style>
