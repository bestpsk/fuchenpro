<template>
  <view class="select-order-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索订单号/客户/企业/门店"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="showFilter = !showFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" color="#3D6DF7" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
      <view v-if="hasActiveFilters" class="active-filters">
        <view v-if="filterParams.prepareStatus" class="filter-tag active" @click="clearFilter('prepareStatus')">
          <text>备货状态: {{ getPrepareStatusLabel(filterParams.prepareStatus) }}</text>
          <u-icon name="close" size="12" color="#3D6DF7"></u-icon>
        </view>
      </view>
    </view>

    <scroll-view scroll-y class="order-list" @scrolltolower="loadMore">
      <view
        v-for="item in list"
        :key="item.orderId"
        class="order-card"
        :class="{ selected: isSelected(item.orderId), disabled: item.prepareStatus === '1' }"
        @click="toggleSelect(item)"
      >
        <view class="card-header">
          <view class="checkbox-area">
            <u-icon
              v-if="item.prepareStatus !== '1' && isSelected(item.orderId)"
              name="checkmark-circle-fill"
              color="#3D6DF7"
              size="22"
            ></u-icon>
            <view
              v-else-if="item.prepareStatus !== '1' && !isSelected(item.orderId)"
              class="circle-placeholder"
            ></view>
            <u-icon
              v-else
              name="checkmark-circle"
              color="#C9CDD4"
              size="22"
            ></u-icon>
          </view>
          <text class="order-no">{{ item.orderNo }}</text>
          <text class="order-amount">¥{{ item.dealAmount }}</text>
        </view>
        <view class="card-body">
          <view class="info-row">
            <text class="label">客户</text>
            <text class="value">{{ item.customerName }}</text>
          </view>
          <view class="info-row">
            <text class="label">企业</text>
            <text class="value">{{ item.enterpriseName }}</text>
          </view>
          <view class="info-row">
            <text class="label">门店</text>
            <text class="value">{{ item.storeName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="label">状态</text>
            <text v-if="item.prepareStatus === '1'" class="status-tag prepared">已备货</text>
            <text v-else class="status-tag unprepared">未备货</text>
          </view>
          <view class="info-row">
            <text class="label">时间</text>
            <text class="value">{{ item.createTime }}</text>
          </view>
        </view>
      </view>
      <u-loadmore :status="loadStatus" />
      <view v-if="list.length === 0 && !loading" class="empty-tip">
        <u-empty text="暂无可备货订单" mode="data"></u-empty>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <view class="select-info">
        <text>已选 {{ selectedIds.length }} 单</text>
      </view>
      <view
        v-if="selectableList.length > 0"
        class="select-all-btn"
        @click="toggleSelectAll"
      >
        <text>{{ isAllSelected ? '取消全选' : '全选' }}</text>
      </view>
      <view class="batch-btn" :class="{ disabled: selectedIds.length === 0 || batchLoading }" @click="handleBatchPrepare">
        <text>{{ batchLoading ? '创建中...' : '批量备货' }}</text>
      </view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="showFilter = false">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <text class="form-label">备货状态</text>
          <view class="form-options">
            <view
              v-for="opt in prepareStatusOptions"
              :key="opt.value"
              class="option-tag"
              :class="{ active: filterParams.prepareStatus === opt.value }"
              @click="setPrepareStatus(opt.value)"
            >
              {{ opt.label }}
            </view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 选择订单备货页 - 从财务已审且未完成备货的订单中批量选择创建备货
 * @description 单搜索框（keyword 搜订单号/客户/企业/门店）+ 筛选按钮（备货状态：全部/未备货/已备货）
 * @description 支持单卡点选与"全选"当前页未备货订单，已备货订单不可选
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { orderListForPrepare, batchCreateFromOrder } from '@/api/business/stockPrepare'

const list = ref([])
const loading = ref(false)
const loadStatus = ref('loadmore')
const selectedIds = ref([])
const batchLoading = ref(false)
const showFilter = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: ''
})

const filterParams = reactive({
  prepareStatus: ''
})

const prepareStatusOptions = [
  { label: '全部', value: '' },
  { label: '未备货', value: 'unprepared' },
  { label: '已备货', value: 'prepared' }
]

const hasActiveFilters = computed(() => !!filterParams.prepareStatus)

/** 当前可见列表中可被选中的订单（未备货） */
const selectableList = computed(() => list.value.filter(i => i.prepareStatus !== '1'))

/** 是否已全选当前可见可选项 */
const isAllSelected = computed(() => {
  return selectableList.value.length > 0 &&
         selectableList.value.every(i => selectedIds.value.includes(i.orderId))
})

let searchTimer = null

onMounted(() => {
  getList(true)
})

async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const params = { ...queryParams }
    if (filterParams.prepareStatus) params.prepareStatus = filterParams.prepareStatus
    const response = await orderListForPrepare(params)
    const data = response.data || response
    const rows = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      list.value = rows
    } else {
      list.value = [...list.value, ...rows]
    }

    if (list.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取可备货订单列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
  }
}

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => getList(true), 500)
}

function handleSearch() {
  getList(true)
}

function clearKeyword() {
  queryParams.keyword = ''
  getList(true)
}

function getPrepareStatusLabel(value) {
  const item = prepareStatusOptions.find(o => o.value === value)
  return item ? item.label : value
}

function setPrepareStatus(value) {
  filterParams.prepareStatus = value
}

function clearFilter(field) {
  filterParams[field] = ''
  getList(true)
}

function resetFilter() {
  filterParams.prepareStatus = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function loadMore() {
  if (loadStatus.value === 'nomore' || loading.value) return
  queryParams.pageNum++
  getList(false)
}

function isSelected(orderId) {
  return selectedIds.value.includes(orderId)
}

function toggleSelect(item) {
  if (item.prepareStatus === '1') return
  const idx = selectedIds.value.indexOf(item.orderId)
  if (idx >= 0) {
    selectedIds.value.splice(idx, 1)
  } else {
    selectedIds.value.push(item.orderId)
  }
}

function toggleSelectAll() {
  const selectable = selectableList.value
  if (isAllSelected.value) {
    const idsToRemove = new Set(selectable.map(i => i.orderId))
    selectedIds.value = selectedIds.value.filter(id => !idsToRemove.has(id))
  } else {
    const newIds = selectable.map(i => i.orderId)
    selectedIds.value = [...new Set([...selectedIds.value, ...newIds])]
  }
}

async function handleBatchPrepare() {
  if (selectedIds.value.length === 0 || batchLoading.value) return
  uni.showModal({
    title: '确认',
    content: `确认为选中的 ${selectedIds.value.length} 个订单创建备货吗？`,
    success: async (res) => {
      if (!res.confirm) return
      batchLoading.value = true
      uni.showLoading({ title: '创建中...' })
      try {
        const response = await batchCreateFromOrder(selectedIds.value)
        uni.hideLoading()
        const successCount = response.successCount || 0
        const skippedCount = response.skippedCount || 0
        const failedCount = response.failedCount || 0
        let msg = '成功 ' + successCount + ' 个'
        if (skippedCount > 0) msg += '，跳过 ' + skippedCount + ' 个'
        if (failedCount > 0) msg += '，失败 ' + failedCount + ' 个'
        selectedIds.value = []
        uni.showToast({ title: msg, icon: 'none' })
        setTimeout(() => {
          uni.navigateBack()
        }, 2000)
      } catch (e) {
        uni.hideLoading()
        uni.showToast({ title: e.message || '创建失败', icon: 'none' })
      } finally {
        setTimeout(() => {
          batchLoading.value = false
        }, 2000)
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.select-order-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f6f7;
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}

.search-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx;
  height: 72rpx;
  gap: 12rpx;
  box-sizing: border-box;
}

.search-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  height: 100%;
  min-width: 0;
}

.search-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.clear-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8rpx;
  flex-shrink: 0;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  background: #E8F0FE;
  border-radius: 28rpx;
  height: 56rpx;
  padding: 0 22rpx;
  font-size: 26rpx;
  color: #3D6DF7;
  font-weight: 500;
  flex-shrink: 0;
}

.icon-rotate {
  transform: rotate(180deg);
  transition: transform 0.3s ease;
}

.active-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-top: 16rpx;
}

.filter-tag.active {
  display: flex;
  align-items: center;
  gap: 6rpx;
  background: #fff;
  color: #3D6DF7;
  padding: 10rpx 20rpx;
  border-radius: 28rpx;
  font-size: 24rpx;
}

.order-list {
  flex: 1;
  padding: 20rpx 24rpx;
  padding-bottom: 140rpx;
}

.order-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  border: 2rpx solid transparent;
  box-sizing: border-box;
}

.order-card.selected {
  border-color: #3D6DF7;
  background: #F0F4FF;
}

.order-card.disabled {
  opacity: 0.6;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #f0f0f0;
  gap: 12rpx;
}

.checkbox-area {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44rpx;
  height: 44rpx;
}

.circle-placeholder {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  border: 2rpx solid #C9CDD4;
  box-sizing: border-box;
}

.order-no {
  flex: 1;
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  min-width: 0;
}

.order-amount {
  font-size: 32rpx;
  font-weight: 600;
  color: #3D6DF7;
  flex-shrink: 0;
}

.card-body {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.info-row {
  display: flex;
  align-items: center;
}

.info-row .label {
  width: 80rpx;
  font-size: 26rpx;
  color: #86909C;
  flex-shrink: 0;
}

.info-row .value {
  flex: 1;
  font-size: 26rpx;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-tag {
  font-size: 24rpx;
  padding: 4rpx 16rpx;
  border-radius: 6rpx;
}

.status-tag.prepared {
  color: #86909C;
  background: #F2F3F5;
}

.status-tag.unprepared {
  color: #3D6DF7;
  background: #E8F0FF;
}

.empty-tip {
  padding: 80rpx 0;
  display: flex;
  justify-content: center;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
}

.select-info {
  font-size: 28rpx;
  color: #86909C;
  flex: 1;
}

.select-all-btn {
  padding: 12rpx 32rpx;
  border: 2rpx solid #3D6DF7;
  border-radius: 40rpx;
  color: #3D6DF7;
  background: #fff;
  font-size: 26rpx;
  font-weight: 500;
  flex-shrink: 0;

  &:active {
    opacity: 0.8;
  }
}

.batch-btn {
  padding: 16rpx 48rpx;
  background: #3D6DF7;
  border-radius: 40rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 500;
  flex-shrink: 0;
}

.batch-btn.disabled {
  background: #C9CDD4;
}

.popup-content {
  padding: 30rpx;
  background: #fff;
}

.popup-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 30rpx;
  text-align: center;
}

.form-item {
  margin-bottom: 30rpx;
}

.form-label {
  display: block;
  font-size: 28rpx;
  font-weight: 500;
  color: #1D2129;
  margin-bottom: 16rpx;
}

.form-options {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.option-tag {
  padding: 14rpx 28rpx;
  background: #F5F7FA;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #4E5969;
  border: 2rpx solid transparent;
}

.option-tag.active {
  background: #E8F0FE;
  color: #3D6DF7;
  border-color: #3D6DF7;
}

.popup-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 40rpx;
  padding-top: 30rpx;
  border-top: 1rpx solid #E5E6EB;
}

.popup-actions .u-button {
  flex: 1;
}
</style>
