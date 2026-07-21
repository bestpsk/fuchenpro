<template>
  <view class="transfer-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索调拨单号" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
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
          <view class="form-label">调拨状态</view>
          <view class="form-options">
            <view v-for="item in statusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="transferList.length > 0" class="card-list">
        <view v-for="item in transferList" :key="item.transferId" class="transfer-card" @click="goDetail(item)">
          <view class="status-bar" :class="'status-' + String(item.status)"></view>
          <view class="card-header">
            <text class="transfer-no">{{ item.transferNo || '-' }}</text>
            <view class="status-badge" :class="'status-' + String(item.status)">{{ getStatusLabel(item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row warehouse-flow">
              <view class="warehouse-tag source">{{ item.fromWarehouseName || '未设置' }}</view>
              <u-icon name="arrow-right" size="18" color="#3D6DF7" style="flex-shrink: 0;"></u-icon>
              <view class="warehouse-tag target">{{ item.toWarehouseName || '未设置' }}</view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">总数量</text>
                <text class="info-value quantity-highlight">{{ item.totalQuantity || 0 }}</text>
              </view>
            </view>
            <view class="info-row datetime-row">
              <text class="info-time">调拨日期：{{ formatTime(item.transferDate) || '-' }}</text>
              <text class="info-divider">|</text>
              <text class="info-time">创建时间：{{ formatTime(item.createTime) || '-' }}</text>
            </view>
          </view>
          <view class="card-actions" @click.stop>
            <view v-if="item.itemCount !== undefined && item.itemCount !== null" class="action-tag info-tag">明细 {{ item.itemCount }} 项</view>
            <view v-if="canDelete(item)" class="action-tag delete" @click.stop="handleDelete(item)">删除</view>
            <view v-if="String(item.status) === '0'" class="action-tag confirm" @click.stop="goDetail(item)">确认</view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无调拨数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onUnmounted, computed } from 'vue'
import { onShow, onPullDownRefresh as onPagePullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { listStockTransfer, delStockTransfer } from '@/api/wms/stockTransfer'
import { useWarehouse } from '@/composables/useWarehouse'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { checkPermi } from '@/utils/permission'

const { currentWarehouseId, loadWarehouses } = useWarehouse()

const transferList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => queryParams.status !== '' && queryParams.status !== undefined)

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '', warehouseId: undefined })

const statusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '已确认', value: '1' },
  { label: '已取消', value: '2' }
])

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认', '2': '已取消' }
  return map[String(status)] || '未知'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

function canDelete(item) { return String(item.status) === '0' && checkPermi('wms:stockTransfer:remove') }

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
    if (queryParams.keyword) params.transferNo = queryParams.keyword
    const wid = queryParams.warehouseId || currentWarehouseId.value
    if (wid) params.warehouseId = wid
    const response = await listStockTransfer(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    transferList.value = isRefresh ? list : [...transferList.value, ...list]
    loadStatus.value = transferList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取调拨列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.status = '' }
function confirmFilter() { showFilter.value = false; getList(true) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/stockTransfer/detail?id=${item.transferId}` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/wms/stockTransfer/form' })
}

function handleDelete(item) {
  uni.showModal({ title: '提示', content: '确认删除该调拨单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockTransfer(item.transferId)
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
.transfer-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
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

.transfer-card { position: relative; padding: 32rpx 32rpx 32rpx 28rpx; overflow: hidden; border-radius: 16rpx; background: #fff; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.status-bar { position: absolute; left: 0; top: 0; bottom: 0; width: 8rpx; border-radius: 8rpx 0 0 8rpx;
  &.status-0 { background-color: #ff9900; }
  &.status-1 { background-color: #00b42a; }
  &.status-2 { background-color: #c9cdd4; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.transfer-no { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #ff9900; }
  &.status-1 { background: #E8F8F0; color: #00b42a; }
  &.status-2 { background: #F2F3F5; color: #86909c; }
}

.card-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; gap: 24rpx; align-items: center; }
.warehouse-flow { gap: 16rpx; }
.warehouse-tag { display: inline-flex; align-items: center; padding: 6rpx 16rpx; border-radius: 8rpx; font-size: 24rpx; font-weight: 500; max-width: 220rpx;
  &.source { background: #E8F3FF; color: #3D6DF7; }
  &.target { background: #F0F9EB; color: #00B42A; }
}
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1;
  &.warehouse-item { min-width: 0; }
}
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.quantity-highlight { color: #FF6B35; font-size: 32rpx; font-weight: 700; }
.datetime-row { gap: 12rpx; }
.info-divider { color: #C9CDD4; font-size: 24rpx; }
.info-time { font-size: 24rpx; color: #86909C; }

.card-actions { display: flex; flex-wrap: wrap; gap: 12rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.action-tag { padding: 8rpx 20rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.delete { background: #FFECE8; color: #F53F3F; }
  &.confirm { background: #E8F0FE; color: #3D6DF7; }
  &.info-tag { background: #F2F3F5; color: #4E5969; }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4); z-index: 100; transition: all 0.2s;
  &:active { transform: scale(0.9); }
}
</style>
