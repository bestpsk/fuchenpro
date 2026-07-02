<template>
  <view class="select-order-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.orderNo"
          placeholder="搜索订单编号"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.orderNo" class="clear-btn" @click="clearOrderNo">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
      <view class="search-box" style="margin-top: 12rpx">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.customerName"
          placeholder="搜索客户名称"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.customerName" class="clear-btn" @click="clearCustomerName">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
      <view class="filter-tabs">
        <view class="filter-tab" :class="{ active: queryParams.prepareStatus === '' }" @click="changeFilter('')">全部</view>
        <view class="filter-tab" :class="{ active: queryParams.prepareStatus === 'unprepared' }" @click="changeFilter('unprepared')">未备货</view>
        <view class="filter-tab" :class="{ active: queryParams.prepareStatus === 'prepared' }" @click="changeFilter('prepared')">已备货</view>
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
              v-if="item.prepareStatus !== '1'"
              :name="isSelected(item.orderId) ? 'checkmark-circle-fill' : 'circle'"
              :color="isSelected(item.orderId) ? '#3D6DF7' : '#C9CDD4'"
              size="22"
            ></u-icon>
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
      <view class="batch-btn" :class="{ disabled: selectedIds.length === 0 || batchLoading }" @click="handleBatchPrepare">
        <text>{{ batchLoading ? '创建中...' : '批量备货' }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { orderListForPrepare, batchCreateFromOrder } from '@/api/business/stockPrepare'

const list = ref([])
const loading = ref(false)
const loadStatus = ref('loadmore')
const selectedIds = ref([])
const batchLoading = ref(false)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  customerName: '',
  prepareStatus: ''
})

onLoad(() => {
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
    const response = await orderListForPrepare(queryParams)
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

function handleSearch() {
  getList(true)
}

function clearOrderNo() {
  queryParams.orderNo = ''
  getList(true)
}

function clearCustomerName() {
  queryParams.customerName = ''
  getList(true)
}

function changeFilter(status) {
  queryParams.prepareStatus = status
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
        // 后端 AjaxResult::success 将关联数组 merge 到响应顶层且转驼峰
        const successCount = response.successCount || 0
        const skippedCount = response.skippedCount || 0
        const failedCount = response.failedCount || 0
        let msg = '成功 ' + successCount + ' 个'
        if (skippedCount > 0) msg += '，跳过 ' + skippedCount + ' 个'
        if (failedCount > 0) msg += '，失败 ' + failedCount + ' 个'
        // 先清空选中，防止 2 秒延迟内重复提交
        selectedIds.value = []
        uni.showToast({ title: msg, icon: 'none' })
        setTimeout(() => {
          uni.navigateBack()
        }, 2000)
      } catch (e) {
        uni.hideLoading()
        uni.showToast({ title: e.message || '创建失败', icon: 'none' })
      } finally {
        // batchLoading 延迟 2 秒重置，与 navigateBack 同步，期间按钮保持 disabled
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
  color: #333;
  height: 100%;
}

.search-placeholder {
  color: #C9CDD4;
  font-size: 28rpx;
}

.clear-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8rpx;
}

.filter-tabs {
  display: flex;
  margin-top: 16rpx;
  gap: 16rpx;
}

.filter-tab {
  flex: 1;
  text-align: center;
  padding: 12rpx 0;
  font-size: 26rpx;
  color: #fff;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 8rpx;
}

.filter-tab.active {
  background: #fff;
  color: #3D6DF7;
  font-weight: 600;
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
}

.order-no {
  flex: 1;
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
}

.order-amount {
  font-size: 32rpx;
  font-weight: 600;
  color: #3D6DF7;
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
  justify-content: space-between;
  padding: 20rpx 24rpx;
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
}

.select-info {
  font-size: 28rpx;
  color: #86909C;
}

.batch-btn {
  padding: 16rpx 48rpx;
  background: #3D6DF7;
  border-radius: 40rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 500;
}

.batch-btn.disabled {
  background: #C9CDD4;
}
</style>
