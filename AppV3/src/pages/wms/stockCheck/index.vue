<template>
  <view class="stockcheck-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索盘点单号" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
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
          <view class="form-label">盘点状态</view>
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
      <view v-if="stockCheckList.length > 0" class="card-list">
        <view v-for="item in stockCheckList" :key="item.stockCheckId" class="stockcheck-card" @click="goDetail(item)">
          <view class="card-header">
            <text class="check-no">{{ item.stockCheckNo || '-' }}</text>
            <view class="status-badge" :class="'status-' + String(item.status)">{{ getStatusLabel(item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">盘点日期</text>
                <text class="info-value">{{ item.checkDate || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="info-label">操作人</text>
                <text class="info-value">{{ item.operatorName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <text class="info-time">{{ formatTime(item.createTime) }}</text>
            </view>
          </view>
          <view class="card-actions" v-if="hasActions(item)" @click.stop>
            <view v-if="canConfirm(item)" class="action-tag confirm" @click.stop="handleConfirm(item)">确认盘点</view>
            <view v-if="canEdit(item)" class="action-tag edit" @click.stop="goEdit(item)">编辑</view>
            <view v-if="canDelete(item)" class="action-tag delete" @click.stop="handleDelete(item)">删除</view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无盘点数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view v-if="checkPermi('wms:stockCheck:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listStockCheck, delStockCheck, confirmStockCheck } from '@/api/wms/stockCheck'
import { checkPermi } from '@/utils/permission'

const stockCheckList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null

const hasActiveFilters = computed(() => queryParams.status !== '' && queryParams.status !== undefined)

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '' })

const statusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '已确认', value: '1' }
])

function getStatusLabel(status) {
  const map = { '0': '待确认', '1': '已确认' }
  return map[String(status)] || '未知'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

function canConfirm(item) { return String(item.status) === '0' && checkPermi('wms:stockCheck:confirm') }
function canEdit(item) { return String(item.status) === '0' && checkPermi('wms:stockCheck:edit') }
function canDelete(item) { return String(item.status) === '0' && checkPermi('wms:stockCheck:remove') }
function hasActions(item) { return canConfirm(item) || canEdit(item) || canDelete(item) }

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.status !== '' && queryParams.status !== undefined) params.status = queryParams.status
    if (queryParams.keyword) params.stockCheckNo = queryParams.keyword
    const response = await listStockCheck(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    stockCheckList.value = isRefresh ? list : [...stockCheckList.value, ...list]
    loadStatus.value = stockCheckList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取盘点列表失败:', e); loadStatus.value = 'error' }
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
  uni.navigateTo({ url: `/pages/wms/stockCheck/detail?id=${item.stockCheckId}` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/wms/stockCheck/form?mode=add' })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/wms/stockCheck/form?mode=edit&id=${item.stockCheckId}` })
}

function handleConfirm(item) {
  uni.showModal({ title: '提示', content: '确认盘点后将调整库存数量，是否继续？', success: async (res) => {
    if (res.confirm) {
      try {
        await confirmStockCheck(item.stockCheckId)
        uni.showToast({ title: '确认盘点成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('确认盘点失败:', e) }
    }
  }})
}

function handleDelete(item) {
  uni.showModal({ title: '提示', content: '确认删除该盘点单？', success: async (res) => {
    if (res.confirm) {
      try {
        await delStockCheck(item.stockCheckId)
        uni.showToast({ title: '删除成功', icon: 'success' })
        getList(true)
      } catch (e) { console.error('删除失败:', e) }
    }
  }})
}

onMounted(() => { getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.stockcheck-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
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

.stockcheck-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.check-no { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
}

.card-body { display: flex; flex-direction: column; gap: 10rpx; }
.info-row { display: flex; gap: 32rpx; align-items: center; }
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129; }
.info-time { font-size: 24rpx; color: #86909C; }

.card-actions { display: flex; flex-wrap: wrap; gap: 12rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.action-tag { padding: 8rpx 20rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.confirm { background: #E8F8F0; color: #00B42A; }
  &.edit { background: #FFF7E8; color: #FF7D00; }
  &.delete { background: #FFECE8; color: #F53F3F; }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4); z-index: 100; transition: all 0.2s;
  &:active { transform: scale(0.9); }
}
</style>
