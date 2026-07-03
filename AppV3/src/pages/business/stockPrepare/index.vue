<template>
  <view class="stock-prepare-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.prepareNo"
          placeholder="搜索备货编号"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.prepareNo" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
      <view class="prepare-action-btns">
        <view class="action-btn-item" @click="goSelectOrder">
          <u-icon name="plus-circle" size="14" color="#fff"></u-icon>
          <text>订单备货</text>
        </view>
        <view class="action-btn-item" @click="goSelectPlan">
          <u-icon name="file-text" size="14" color="#fff"></u-icon>
          <text>方案备货</text>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view
            v-if="queryParams.enterpriseId"
            class="filter-tag active"
            @click="clearFilter('enterpriseId')"
          >
            <text>{{ getEnterpriseName(queryParams.enterpriseId) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.storeId"
            class="filter-tag active"
            @click="clearFilter('storeId')"
          >
            <text>{{ getStoreName(queryParams.storeId) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ getStatusName(queryParams.status) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">企业</view>
          <view class="form-select" @click="showEnterprisePicker = true">
            <text :class="queryParams.enterpriseId ? 'selected-text' : 'placeholder-text'">
              {{ queryParams.enterpriseId ? getEnterpriseName(queryParams.enterpriseId) : '请选择企业' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">门店</view>
          <view class="form-select" @click="showStorePicker = true">
            <text :class="queryParams.storeId ? 'selected-text' : 'placeholder-text'">
              {{ queryParams.storeId ? getStoreName(queryParams.storeId) : '请选择门店' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view
              v-for="item in statusOptions"
              :key="item.value"
              class="option-tag"
              :class="{ active: queryParams.status === item.value }"
              @click="queryParams.status = queryParams.status === item.value ? '' : item.value"
            >
              {{ item.label }}
            </view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-picker
      :show="showEnterprisePicker"
      :columns="enterprisePickerColumns"
      keyName="enterpriseName"
      @confirm="onEnterprisePickerConfirm"
      @cancel="showEnterprisePicker = false"
      @close="showEnterprisePicker = false"
    ></u-picker>

    <u-picker
      :show="showStorePicker"
      :columns="storePickerColumns"
      keyName="storeName"
      @confirm="onStorePickerConfirm"
      @cancel="showStorePicker = false"
      @close="showStorePicker = false"
    ></u-picker>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="stockPrepareList.length > 0" class="card-list">
        <view
          v-for="(item, index) in stockPrepareList"
          :key="item.prepareId"
          class="prepare-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="prepare-name">
              <u-icon name="file-text-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.prepareNo }}</text>
            </view>
            <view class="status-tag" :class="getStatusClass(item.status)">
              {{ getStatusName(item.status) }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">企业</text>
                <text class="value">{{ item.enterpriseName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">门店</text>
                <text class="value">{{ item.storeName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">货品种类</text>
                <text class="value highlight">{{ item.productCount || 0 }}种</text>
              </view>
              <view class="info-item">
                <text class="label">总数量</text>
                <text class="value">{{ formatMainQty(item.totalQuantity, item.items) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">总金额</text>
                <text class="value highlight">{{ item.totalAmount ? '¥' + item.totalAmount : '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">已出库</text>
                <text class="value shipped">{{ formatMainQty(item.shippedQuantity, item.items) }} / ¥{{ item.shippedAmount || '0' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">待出库</text>
                <text class="value pending">{{ formatMainQty(item.pendingQuantity, item.items) }} / ¥{{ item.pendingAmount || '0' }}</text>
              </view>
            </view>
            <view class="info-row" v-if="item.planId">
              <view class="info-item">
                <text class="label">来源</text>
                <text class="value source">方案编号 {{ item.planNo }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-btns">
              <view v-if="checkPermi('business:stockPrepare:query')" class="action-btn detail" @click.stop="goDetail(item)">
                <u-icon name="eye" size="14"></u-icon>
                <text>详情</text>
              </view>
              <view v-if="item.status === '0'" class="action-btn cancel" @click.stop="handleCancel(item)">
                <u-icon name="close" size="14" color="#f56c6c"></u-icon>
                <text style="color: #f56c6c">取消</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无备货数据"
        :marginTop="100"
      ></u-empty>

      <u-loadmore
        :status="loadStatus"
        :loading-text="'加载中...'"
        :loadmore-text="'上拉加载更多'"
        :nomore-text="'没有更多了'"
        :marginTop="20"
      />
    </scroll-view>
  </view>
</template>

<script setup>
/**
 * @description 备货管理列表页 - 备货管理入口
 * @description 展示备货列表，支持备货编号搜索、按企业/门店/状态筛选、
 * 分页加载、下拉刷新、跳转详情
 */
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listStockPrepare, cancelPrepare } from '@/api/business/stockPrepare'
import { listEnterprise } from '@/api/business/enterprise'
import { listStore } from '@/api/business/store'
import { checkPermi } from '@/utils/permission'

const stockPrepareList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showEnterprisePicker = ref(false)
const showStorePicker = ref(false)

const enterpriseOptions = ref([])
const storeOptions = ref([])

/** 搜索防抖定时器 */
let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const statusOptions = ref([
  { label: '待出库', value: '0' },
  { label: '部分出库', value: '1' },
  { label: '已完成', value: '2' },
  { label: '已取消', value: '3' }
])

/** 是否有激活的筛选条件 */
const hasActiveFilters = computed(() => {
  return queryParams.enterpriseId || queryParams.storeId ||
         (queryParams.status !== '' && queryParams.status !== undefined)
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  prepareNo: '',
  enterpriseId: '',
  storeId: '',
  status: ''
})

/** 企业选择器列数据 */
const enterprisePickerColumns = computed(() => [enterpriseOptions.value])
/** 门店选择器列数据 */
const storePickerColumns = computed(() => [storeOptions.value])

/** 将最小单位数量转换为主单位数量显示
 * 后端统一存储最小单位数量，需通过packQty换算为主单位
 * @param {number} totalQty - 最小单位数量
 * @param {Array} items - 备货明细列表，取items[0].packQty作为换算系数
 * @returns {string} 换算后的主单位数量，带"(整)"标识
 */
function formatMainQty(totalQty, items) {
  if (!totalQty) return '0'
  const packQty = items && items.length > 0 ? (items[0].packQty || 1) : 1
  if (packQty > 1) {
    const mainQty = totalQty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + '(整)'
  }
  return String(totalQty)
}

/** 状态编码映射为中文名称 */
function getStatusName(value) {
  const item = statusOptions.value.find(s => s.value === value)
  return item ? item.label : '-'
}

/** 状态编码映射为样式类名 */
function getStatusClass(value) {
  const map = { '0': 'status-pending', '1': 'status-partial', '2': 'status-done' }
  return map[value] || 'status-pending'
}

/** 根据企业ID获取企业名称 */
function getEnterpriseName(id) {
  const item = enterpriseOptions.value.find(e => String(e.enterpriseId) === String(id))
  return item ? item.enterpriseName : ''
}

/** 根据门店ID获取门店名称 */
function getStoreName(id) {
  const item = storeOptions.value.find(s => String(s.storeId) === String(id))
  return item ? item.storeName : ''
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

/** 加载企业列表用于筛选 */
async function loadEnterpriseOptions() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 100 })
    const data = response.data || response
    enterpriseOptions.value = data.rows || []
  } catch (e) {
    console.error('获取企业列表失败:', e)
  }
}

/** 加载门店列表用于筛选 */
async function loadStoreOptions() {
  try {
    const params = { pageNum: 1, pageSize: 100 }
    if (queryParams.enterpriseId) {
      params.enterpriseId = queryParams.enterpriseId
    }
    const response = await listStore(params)
    const data = response.data || response
    storeOptions.value = data.rows || []
  } catch (e) {
    console.error('获取门店列表失败:', e)
  }
}

/** 企业选择器确认 */
function onEnterprisePickerConfirm({ value }) {
  const selected = value[0]
  if (selected) {
    queryParams.enterpriseId = selected.enterpriseId
    queryParams.storeId = ''
    storeOptions.value = []
    loadStoreOptions()
  }
  showEnterprisePicker.value = false
}

/** 门店选择器确认 */
function onStorePickerConfirm({ value }) {
  const selected = value[0]
  if (selected) {
    queryParams.storeId = selected.storeId
  }
  showStorePicker.value = false
}

/** 加载备货列表，支持分页和搜索，isRefresh为true时重置到第一页 */
async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const params = { ...queryParams }
    const response = await listStockPrepare(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      stockPrepareList.value = list
    } else {
      stockPrepareList.value = [...stockPrepareList.value, ...list]
    }

    if (stockPrepareList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取备货列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

/** 加载更多，翻页并请求下一页数据 */
function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

function onPullDownRefresh() {
  refreshing.value = true
  getList(true)
}

function handleSearch() {
  getList(true)
}

/** 跳转到订单选择页创建备货 */
function goSelectOrder() {
  uni.navigateTo({ url: '/pages/business/stockPrepare/selectOrder' })
}

/** 跳转到方案选择页创建备货 */
function goSelectPlan() {
  uni.navigateTo({ url: '/pages/business/stockPrepare/selectPlan' })
}

/** 搜索输入防抖处理，500ms后触发搜索 */
function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    handleSearch()
  }, 500)
}

function clearKeyword() {
  queryParams.prepareNo = ''
  handleSearch()
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.enterpriseId = ''
  queryParams.storeId = ''
  queryParams.status = ''
  storeOptions.value = []
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'enterpriseId') {
    queryParams.enterpriseId = ''
    queryParams.storeId = ''
    storeOptions.value = []
  } else {
    queryParams[field] = ''
  }
  getList(true)
}

/** 跳转备货详情页 */
function goDetail(item) {
  uni.navigateTo({
    url: `/pages/business/stockPrepare/detail?id=${item.prepareId}`
  })
}

/** 取消备货 */
function handleCancel(item) {
  uni.showModal({
    title: '确认取消',
    content: '取消后可重新备货，确认取消该备货单吗？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        uni.showLoading({ title: '取消中...' })
        await cancelPrepare(item.prepareId)
        uni.showToast({ title: '取消成功', icon: 'success' })
        getList(true)
      } catch (e) {
        uni.showToast({ title: e.message || '取消失败', icon: 'none' })
      } finally {
        uni.hideLoading()
      }
    }
  })
}

onMounted(() => {
  if (checkPermi('business:stockPrepare:list')) {
    loadEnterpriseOptions()
    getList(true)
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.stock-prepare-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;

  :deep(.u-popup) {
    flex: none !important;
  }
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}

.prepare-action-btns {
  display: flex;
  gap: 16rpx;
  margin-top: 16rpx;
}

.action-btn-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  height: 64rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 32rpx;
  color: #fff;
  font-size: 26rpx;
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
  height: 72rpx;
  min-width: 0;
}

.search-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.clear-btn {
  flex-shrink: 0;
  padding: 8rpx;
  display: flex;
  align-items: center;
}

.filter-btn {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4rpx;
  height: 56rpx;
  padding: 0 22rpx;
  background: #E8F0FE;
  border-radius: 28rpx;

  text {
    font-size: 26rpx;
    color: #3D6DF7;
    font-weight: 500;
    white-space: nowrap;
  }

  .icon-rotate {
    transform: rotate(180deg);
    transition: transform 0.3s ease;
  }
}

.active-filters {
  flex-shrink: 0;
  padding: 12rpx 24rpx 16rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%);
}

.filter-scroll {
  white-space: nowrap;
}

.filter-tags {
  display: inline-flex;
  gap: 16rpx;
  padding: 16rpx 0;
}

.filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 20rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 28rpx;
  font-size: 24rpx;
  color: #fff;

  &.active {
    background: #fff;
    color: #3D6DF7;
  }
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
}

.form-item {
  margin-bottom: 30rpx;
}

.form-label {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
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

  &.active {
    background: #E8F0FE;
    color: #3D6DF7;
    border-color: #3D6DF7;
  }
}

.form-select {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 24rpx;
  background: #F5F7FA;
  border-radius: 8rpx;

  .selected-text {
    font-size: 26rpx;
    color: #1D2129;
  }

  .placeholder-text {
    font-size: 26rpx;
    color: #C9CDD4;
  }
}

.popup-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 40rpx;
  padding-top: 30rpx;
  border-top: 1rpx solid #E5E6EB;

  .u-button {
    flex: 1;
  }
}

.list-scroll {
  flex: 1;
  overflow: hidden;
  padding: 20rpx 0;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.prepare-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.prepare-name {
  display: flex;
  align-items: center;
  gap: 12rpx;

  .name-text {
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
  }
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;

  &.status-pending {
    background: #FFF7E8;
    color: #FF7D00;
  }

  &.status-partial {
    background: #E8F0FE;
    color: #3D6DF7;
  }

  &.status-done {
    background: #E8FFEA;
    color: #00B42A;
  }
}

.card-body {
  padding: 20rpx 0;
  border-top: 1rpx solid #F2F3F5;
  border-bottom: 1rpx solid #F2F3F5;
}

.info-row {
  display: flex;
  margin-bottom: 16rpx;

  &:last-child {
    margin-bottom: 0;
  }
}

.info-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;

  &.full {
    flex: none;
    width: 100%;
  }

  .label {
    font-size: 24rpx;
    color: #86909C;
    min-width: 60rpx;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;

    &.highlight {
      color: #FF6B35;
      font-weight: 500;
    }

    &.shipped {
      color: #3D6DF7;
      font-size: 24rpx;
    }

    &.pending {
      color: #FF7D00;
      font-size: 24rpx;
    }

    &.source {
      color: #3D6DF7;
    }
  }
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20rpx;
  padding-top: 16rpx;
}

.time-text {
  font-size: 22rpx;
  color: #C9CDD4;
}

.action-btns {
  display: flex;
  gap: 24rpx;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 24rpx;
  padding: 8rpx 16rpx;
  border-radius: 8rpx;

  &.detail {
    color: #3D6DF7;
    background: #E8F0FE;
  }
}
</style>
