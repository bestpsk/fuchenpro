<template>
  <view class="report-container">
    <view class="tab-section">
      <u-tabs
        :list="tabList"
        :current="currentTab"
        :activeStyle="{ color: '#3D6DF7', fontWeight: '600', fontSize: '28rpx' }"
        :inactiveStyle="{ color: '#86909C', fontSize: '28rpx' }"
        :lineColor="'#3D6DF7'"
        :lineWidth="'48rpx'"
        :lineHeight="'6rpx'"
        :itemStyle="{ height: '88rpx', padding: '0 16rpx' }"
        @click="onTabChange"
      ></u-tabs>
    </view>

    <view class="filter-section">
      <view class="date-range-picker">
        <view class="date-item" @click="showStartDatePicker = true">
          <u-icon name="calendar" size="14" color="#86909C"></u-icon>
          <text :class="{ 'date-placeholder': !startDate }">{{ startDate || '开始日期' }}</text>
        </view>
        <text class="date-separator">至</text>
        <view class="date-item" @click="showEndDatePicker = true">
          <u-icon name="calendar" size="14" color="#86909C"></u-icon>
          <text :class="{ 'date-placeholder': !endDate }">{{ endDate || '结束日期' }}</text>
        </view>
        <view class="date-confirm-btn" @click="handleQuery">
          <text>查询</text>
        </view>
      </view>

      <view v-if="currentTab === 0 || currentTab === 1" class="category-filter">
        <view class="category-input-box">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="category-input" type="text" v-model="category" placeholder="输入类别筛选" placeholder-class="field-placeholder" confirm-type="search" @confirm="handleQuery" />
          <view v-if="category" class="clear-btn" @click="category = ''; handleQuery()">
            <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
      </view>

      <view v-if="currentTab === 3" class="product-filter">
        <view class="product-input-box" @click="showProductPicker = true">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <text v-if="selectedProduct" class="product-selected">{{ selectedProduct.productName }}</text>
          <text v-else class="product-placeholder">搜索货品</text>
          <view v-if="selectedProduct" class="clear-btn" @click.stop="clearProduct">
            <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
      </view>
    </view>

    <u-datetime-picker
      :show="showStartDatePicker"
      v-model="startDatePickerValue"
      mode="date"
      title="选择开始日期"
      @confirm="onStartDateConfirm"
      @cancel="showStartDatePicker = false"
      @close="showStartDatePicker = false"
    ></u-datetime-picker>

    <u-datetime-picker
      :show="showEndDatePicker"
      v-model="endDatePickerValue"
      mode="date"
      title="选择结束日期"
      @confirm="onEndDateConfirm"
      @cancel="showEndDatePicker = false"
      @close="showEndDatePicker = false"
    ></u-datetime-picker>

    <u-popup :show="showProductPicker" mode="bottom" round="16" @close="showProductPicker = false">
      <view class="product-picker-content">
        <view class="picker-header">
          <text class="picker-title">搜索货品</text>
          <view class="picker-close" @click="showProductPicker = false">
            <u-icon name="close" size="18" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="productKeyword" placeholder="输入货品名称搜索" placeholder-class="field-placeholder" confirm-type="search" @input="onProductSearchInput" @confirm="searchProductList" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in productOptions" :key="item.productId" class="picker-item" :class="{ active: selectedProduct && selectedProduct.productId === item.productId }" @click="onSelectProduct(item)">
            <text class="picker-item-name">{{ item.productName }}</text>
            <u-icon v-if="selectedProduct && selectedProduct.productId === item.productId" name="checkmark" size="16" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="productOptions.length === 0 && !productSearchLoading" mode="search" text="未找到货品" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="content-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <!-- Tab 1: 入库汇总 -->
      <view v-if="currentTab === 0" class="tab-content">
        <view v-if="stockInList.length > 0" class="card-list">
          <view v-for="(item, idx) in stockInList" :key="idx" class="report-card">
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ item.category || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">入库数量</text>
              <text class="card-value bold">{{ item.totalQuantity || 0 }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">入库金额</text>
              <text class="card-value bold amount">¥{{ formatAmount(item.totalAmount) }}</text>
            </view>
          </view>
          <view class="summary-card">
            <view class="summary-row">
              <view class="summary-item">
                <text class="summary-label">总数量</text>
                <text class="summary-value">{{ stockInSummary.totalQuantity }}</text>
              </view>
              <view class="summary-divider"></view>
              <view class="summary-item">
                <text class="summary-label">总金额</text>
                <text class="summary-value amount">¥{{ formatAmount(stockInSummary.totalAmount) }}</text>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无入库汇总数据" :marginTop="100"></u-empty>
      </view>

      <!-- Tab 2: 出库汇总 -->
      <view v-if="currentTab === 1" class="tab-content">
        <view v-if="stockOutList.length > 0" class="card-list">
          <view v-for="(item, idx) in stockOutList" :key="idx" class="report-card">
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ item.category || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">出库数量</text>
              <text class="card-value bold">{{ item.totalQuantity || 0 }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">出库金额</text>
              <text class="card-value bold amount">¥{{ formatAmount(item.totalAmount) }}</text>
            </view>
          </view>
          <view class="summary-card">
            <view class="summary-row">
              <view class="summary-item">
                <text class="summary-label">总数量</text>
                <text class="summary-value">{{ stockOutSummary.totalQuantity }}</text>
              </view>
              <view class="summary-divider"></view>
              <view class="summary-item">
                <text class="summary-label">总金额</text>
                <text class="summary-value amount">¥{{ formatAmount(stockOutSummary.totalAmount) }}</text>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无出库汇总数据" :marginTop="100"></u-empty>
      </view>

      <!-- Tab 3: 库存周转 -->
      <view v-if="currentTab === 2" class="tab-content">
        <view v-if="turnoverList.length > 0" class="card-list">
          <view v-for="(item, idx) in turnoverList" :key="idx" class="report-card turnover-card">
            <view class="card-header-row">
              <text class="card-product-name">{{ item.productName || '-' }}</text>
            </view>
            <view class="turnover-grid">
              <view class="turnover-cell">
                <text class="turnover-label">期初库存</text>
                <text class="turnover-val">{{ item.beginQuantity || 0 }}</text>
              </view>
              <view class="turnover-cell in">
                <text class="turnover-label">期间入库</text>
                <text class="turnover-val">{{ item.periodInQuantity || 0 }}</text>
              </view>
              <view class="turnover-cell out">
                <text class="turnover-label">期间出库</text>
                <text class="turnover-val">{{ item.periodOutQuantity || 0 }}</text>
              </view>
              <view class="turnover-cell">
                <text class="turnover-label">期末库存</text>
                <text class="turnover-val end">{{ item.endQuantity || 0 }}</text>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无库存周转数据" :marginTop="100"></u-empty>
      </view>

      <!-- Tab 4: 货品流水 -->
      <view v-if="currentTab === 3" class="tab-content">
        <view v-if="flowList.length > 0" class="card-list">
          <view v-for="(item, idx) in flowList" :key="idx" class="report-card flow-card">
            <view class="card-header-row">
              <text class="card-order-no">{{ item.orderNo || '-' }}</text>
              <view class="flow-type-badge" :class="item.type === '入库' ? 'type-in' : 'type-out'">{{ item.type || '-' }}</view>
            </view>
            <view class="card-row">
              <text class="card-label">日期</text>
              <text class="card-value">{{ formatDate(item.date) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">数量</text>
              <text class="card-value bold">{{ item.quantity || 0 }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">金额</text>
              <text class="card-value bold amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">结存</text>
              <text class="card-value bold">{{ item.balance || 0 }}</text>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无货品流水数据" :marginTop="100"></u-empty>
        <u-loadmore v-if="flowList.length > 0" :status="flowLoadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
      </view>

      <view class="bottom-spacer"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { stockInSummary, stockOutSummary, inventoryTurnover, productFlow } from '@/api/wms/report'
import { searchProduct } from '@/api/wms/product'
import { checkPermi } from '@/utils/permission'

const currentTab = ref(0)
const tabList = ref([
  { name: '入库汇总' },
  { name: '出库汇总' },
  { name: '库存周转' },
  { name: '货品流水' }
])

const loading = ref(false)
const refreshing = ref(false)

// 日期筛选
const startDate = ref('')
const endDate = ref('')
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)
const startDatePickerValue = ref(Date.now())
const endDatePickerValue = ref(Date.now())

// 类别筛选
const category = ref('')

// 货品筛选
const selectedProduct = ref(null)
const showProductPicker = ref(false)
const productKeyword = ref('')
const productOptions = ref([])
const productSearchLoading = ref(false)
let productSearchTimer = null

// Tab 1: 入库汇总
const stockInList = ref([])
const stockInSummary = computed(() => {
  const totalQuantity = stockInList.value.reduce((s, i) => s + (parseFloat(i.totalQuantity) || 0), 0)
  const totalAmount = stockInList.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  return { totalQuantity, totalAmount }
})

// Tab 2: 出库汇总
const stockOutList = ref([])
const stockOutSummary = computed(() => {
  const totalQuantity = stockOutList.value.reduce((s, i) => s + (parseFloat(i.totalQuantity) || 0), 0)
  const totalAmount = stockOutList.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  return { totalQuantity, totalAmount }
})

// Tab 3: 库存周转
const turnoverList = ref([])

// Tab 4: 货品流水
const flowList = ref([])
const flowPageNum = ref(1)
const flowPageSize = ref(10)
const flowTotal = ref(0)
const flowLoadStatus = ref('loadmore')

function formatDateFromTimestamp(ts) {
  const date = new Date(ts)
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function onStartDateConfirm(e) {
  startDate.value = formatDateFromTimestamp(e.value)
  showStartDatePicker.value = false
}

function onEndDateConfirm(e) {
  endDate.value = formatDateFromTimestamp(e.value)
  showEndDatePicker.value = false
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatDate(time) {
  if (!time) return '-'
  return String(time).substring(0, 10)
}

function onTabChange(item) {
  currentTab.value = item.index
  loadData()
}

function handleQuery() {
  if (!startDate.value || !endDate.value) {
    uni.showToast({ title: '请选择完整日期范围', icon: 'none' })
    return
  }
  if (startDate.value > endDate.value) {
    uni.showToast({ title: '开始日期不能大于结束日期', icon: 'none' })
    return
  }
  loadData()
}

function initDefaultDateRange() {
  const now = new Date()
  const y = now.getFullYear()
  const m = String(now.getMonth() + 1).padStart(2, '0')
  const d = String(now.getDate()).padStart(2, '0')
  const today = `${y}-${m}-${d}`
  const firstDay = `${y}-${m}-01`
  startDate.value = firstDay
  endDate.value = today
  startDatePickerValue.value = new Date(firstDay).getTime()
  endDatePickerValue.value = now.getTime()
}

async function loadData(isRefresh = false) {
  if (loading.value) return
  loading.value = true

  const params = { startDate: startDate.value, endDate: endDate.value }

  try {
    if (currentTab.value === 0) {
      if (category.value) params.category = category.value
      const res = await stockInSummary(params)
      stockInList.value = res.data || res || []
    } else if (currentTab.value === 1) {
      if (category.value) params.category = category.value
      const res = await stockOutSummary(params)
      stockOutList.value = res.data || res || []
    } else if (currentTab.value === 2) {
      const res = await inventoryTurnover(params)
      turnoverList.value = res.data || res || []
    } else if (currentTab.value === 3) {
      if (isRefresh) {
        flowPageNum.value = 1
        flowLoadStatus.value = 'loadmore'
      }
      if (selectedProduct.value) params.productId = selectedProduct.value.productId
      params.pageNum = flowPageNum.value
      params.pageSize = flowPageSize.value
      const res = await productFlow(params)
      const data = res.data || res || {}
      const list = data.rows || data.items || []
      const total = data.total || 0
      flowList.value = isRefresh ? list : [...flowList.value, ...list]
      flowTotal.value = total
      flowLoadStatus.value = flowList.value.length >= total ? 'nomore' : 'loadmore'
    }
  } catch (e) {
    console.error('加载报表数据失败:', e)
    if (currentTab.value === 3) flowLoadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

function loadMore() {
  if (currentTab.value !== 3) return
  if (loading.value || flowLoadStatus.value === 'nomore') return
  flowLoadStatus.value = 'loading'
  flowPageNum.value++
  loadData()
}

function onPullDownRefresh() {
  refreshing.value = true
  loadData(true)
}

// 货品搜索
function onProductSearchInput() {
  if (productSearchTimer) clearTimeout(productSearchTimer)
  productSearchTimer = setTimeout(() => searchProductList(), 500)
}

async function searchProductList() {
  if (!productKeyword.value.trim()) {
    productOptions.value = []
    return
  }
  productSearchLoading.value = true
  try {
    const res = await searchProduct(productKeyword.value.trim())
    productOptions.value = res.data || res || []
  } catch (e) {
    console.error('搜索货品失败:', e)
    productOptions.value = []
  } finally {
    productSearchLoading.value = false
  }
}

function onSelectProduct(item) {
  selectedProduct.value = item
  showProductPicker.value = false
  loadData(true)
}

function clearProduct() {
  selectedProduct.value = null
  loadData(true)
}

onMounted(() => {
  // 权限检查
  if (!checkPermi('wms:report:list')) {
    uni.showToast({ title: '无报表查看权限', icon: 'none' })
    setTimeout(() => {
      const pages = getCurrentPages()
      if (pages.length > 1) uni.navigateBack()
      else uni.switchTab({ url: '/pages/index' })
    }, 1500)
    return
  }
  initDefaultDateRange()
  loadData()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.report-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx; }

.tab-section {
  flex-shrink: 0;
  margin-top: 20rpx;
  background: #fff;
  border-radius: 16rpx;
  padding: 0 8rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  overflow: hidden;
}

.filter-section {
  flex-shrink: 0;
  margin-top: 20rpx;
}

.date-range-picker {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 20rpx;
  background: #fff;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.date-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 16rpx;
  background: #F7F8FA;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #1D2129;
  .date-placeholder { color: #C9CDD4; }
}
.date-separator { font-size: 26rpx; color: #86909C; flex-shrink: 0; }
.date-confirm-btn {
  flex-shrink: 0;
  padding: 12rpx 24rpx;
  background: #3D6DF7;
  border-radius: 8rpx;
  text { font-size: 26rpx; color: #fff; font-weight: 500; }
  &:active { opacity: 0.8; }
}

.category-filter { margin-top: 16rpx; }
.category-input-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 72rpx;
  gap: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.category-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }

.product-filter { margin-top: 16rpx; }
.product-input-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 72rpx;
  gap: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.product-selected { flex: 1; font-size: 28rpx; color: #1D2129; }
.product-placeholder { flex: 1; font-size: 28rpx; color: #C9CDD4; }

.product-picker-content {
  background: #fff;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}
.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx 16rpx;
}
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search {
  display: flex;
  align-items: center;
  margin: 0 32rpx 16rpx;
  padding: 0 20rpx;
  height: 72rpx;
  background: #F7F8FA;
  border-radius: 36rpx;
  gap: 12rpx;
}
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.picker-list { max-height: 50vh; padding: 0 32rpx; }
.picker-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 16rpx;
  border-bottom: 1rpx solid #F2F3F5;
  &.active { background: #E8F0FE; border-radius: 8rpx; }
}
.picker-item-name { font-size: 28rpx; color: #1D2129; }

.content-scroll { flex: 1; overflow: hidden; padding: 12rpx 0; }
.tab-content { min-height: 100%; }

.card-list { display: flex; flex-direction: column; gap: 16rpx; }

.report-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx 32rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.card-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8rpx 0;
}
.card-label { font-size: 26rpx; color: #86909C; }
.card-value { font-size: 28rpx; color: #1D2129;
  &.bold { font-weight: 600; font-size: 30rpx; }
  &.amount { color: #FF6B35; }
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
  padding-bottom: 12rpx;
  border-bottom: 1rpx solid #F2F3F5;
}
.card-product-name { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.card-order-no { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }

.flow-type-badge {
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  font-size: 22rpx;
  font-weight: 500;
  flex-shrink: 0;
  &.type-in { background: #E8F8F0; color: #00B42A; }
  &.type-out { background: #FFECE8; color: #F53F3F; }
}

.turnover-grid {
  display: flex;
  gap: 0;
  width: 100%;
  margin-top: 8rpx;
}
.turnover-cell {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
  &.in .turnover-val { color: #3D6DF7; }
  &.out .turnover-val { color: #FF6B35; }
}
.turnover-label { font-size: 22rpx; color: #C9CDD4; }
.turnover-val {
  font-size: 28rpx;
  color: #4E5969;
  font-weight: 500;
  &.end { color: #3D6DF7; font-weight: 600; font-size: 30rpx; }
}

.summary-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx 32rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  border-left: 6rpx solid #3D6DF7;
}
.summary-row {
  display: flex;
  align-items: center;
}
.summary-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}
.summary-label { font-size: 24rpx; color: #86909C; }
.summary-value { font-size: 36rpx; font-weight: 700; color: #1D2129;
  &.amount { color: #FF6B35; }
}
.summary-divider { width: 2rpx; height: 60rpx; background: #E5E6EB; }

.bottom-spacer { height: 40rpx; }
</style>
