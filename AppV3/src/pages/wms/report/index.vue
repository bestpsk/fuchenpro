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
      <view class="warehouse-filter" v-if="warehouseList.length > 1">
        <scroll-view scroll-x class="warehouse-scroll">
          <view class="warehouse-tags">
            <view v-for="item in warehouseList" :key="item.warehouseId" class="warehouse-tag" :class="{ active: currentWarehouseId === item.warehouseId }" @click="onWarehouseChange(item.warehouseId)">
              <text>{{ item.warehouseName }}</text>
            </view>
          </view>
        </scroll-view>
      </view>

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

      <view v-if="currentTab === 0 || currentTab === 1 || currentTab === 2" class="category-filter">
        <view class="category-input-box" @click="showCategoryPicker = true">
          <u-icon name="list" size="14" color="#86909C"></u-icon>
          <text v-if="category" class="category-selected">{{ getCategoryLabel(category) }}</text>
          <text v-else class="category-placeholder">全部类别</text>
          <view v-if="category" class="clear-btn" @click.stop="category = ''; handleQuery()">
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

      <view v-if="currentTab === 4" class="expiry-status-filter">
        <view class="expiry-status-input-box" @click="showExpiryStatusPicker = true">
          <u-icon name="list" size="14" color="#86909C"></u-icon>
          <text v-if="expiryStatusFilter" class="expiry-status-selected">{{ getExpiryStatusText(expiryStatusFilter) }}</text>
          <text v-else class="expiry-status-placeholder">到期状态筛选</text>
          <view v-if="expiryStatusFilter" class="clear-btn" @click.stop="expiryStatusFilter = ''; loadExpiryData()">
            <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
      </view>
    </view>

    <scroll-view scroll-y class="content-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <!-- Tab 1: 入库汇总 -->
      <view v-if="currentTab === 0" class="tab-content">
        <view v-if="stockInList.length > 0" class="card-list">
          <view v-for="(item, idx) in stockInList" :key="idx" class="report-card">
            <view class="card-header-row">
              <text class="card-product-name">{{ item.productName || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ getCategoryLabel(item.category) || '-' }}</text>
            </view>
            <view class="card-row" v-if="item.packQty > 1">
              <text class="card-label">换算</text>
              <text class="card-value">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">入库数量</text>
              <text class="card-value bold">{{ formatQty(item.totalQuantity, item) }}</text>
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
                <text class="summary-value">{{ stockInSummaryData.totalQuantity }}</text>
              </view>
              <view class="summary-divider"></view>
              <view class="summary-item">
                <text class="summary-label">总金额</text>
                <text class="summary-value amount">¥{{ formatAmount(stockInSummaryData.totalAmount) }}</text>
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
            <view class="card-header-row">
              <text class="card-product-name">{{ item.productName || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ getCategoryLabel(item.category) || '-' }}</text>
            </view>
            <view class="card-row" v-if="item.packQty > 1">
              <text class="card-label">换算</text>
              <text class="card-value">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">出库数量</text>
              <text class="card-value bold">{{ formatQty(item.totalQuantity, item) }}</text>
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
                <text class="summary-value">{{ stockOutSummaryData.totalQuantity }}</text>
              </view>
              <view class="summary-divider"></view>
              <view class="summary-item">
                <text class="summary-label">总金额</text>
                <text class="summary-value amount">¥{{ formatAmount(stockOutSummaryData.totalAmount) }}</text>
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
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ getCategoryLabel(item.category) || '-' }}</text>
            </view>
            <view class="card-row" v-if="item.packQty > 1">
              <text class="card-label">换算</text>
              <text class="card-value">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
            </view>
            <view class="turnover-grid">
              <!-- 第一行 -->
              <view class="turnover-cell">
                <text class="turnover-label">期初库存</text>
                <text class="turnover-val">{{ formatQty(item.beginQuantity, item) }}</text>
              </view>
              <view class="turnover-cell in">
                <text class="turnover-label">期间入库</text>
                <text class="turnover-val">{{ formatQty(item.periodInQuantity, item) }}</text>
              </view>
              <!-- 第二行 -->
              <view class="turnover-cell out">
                <text class="turnover-label">期间出库</text>
                <text class="turnover-val">{{ formatQty(item.periodOutQuantity, item) }}</text>
              </view>
              <view class="turnover-cell end">
                <text class="turnover-label">期末库存</text>
                <text class="turnover-val">{{ formatQty(item.endQuantity, item) }}</text>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无库存周转数据" :marginTop="100"></u-empty>
      </view>

      <!-- Tab 4: 货品收发存 -->
      <view v-if="currentTab === 3" class="tab-content">
        <view v-if="flowList.length > 0" class="card-list">
          <view v-for="(item, idx) in flowList" :key="idx" class="report-card flow-card">
            <view class="card-header-row">
              <text class="card-order-no">{{ item.docNo || '-' }}</text>
              <view class="flow-type-badge" :class="item.flowType === '入库' ? 'type-in' : 'type-out'">{{ item.flowType || '-' }}</view>
            </view>
            <view class="card-row">
              <text class="card-label">日期</text>
              <text class="card-value">{{ formatDate(item.flowDate) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">数量</text>
              <text class="card-value bold">{{ formatQty(item.quantity, item) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">金额</text>
              <text class="card-value bold amount">¥{{ formatAmount(item.amount) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">结存</text>
              <text class="card-value bold">{{ formatQty(item.balance, item) }}</text>
            </view>
            <view class="card-row" v-if="item.packQty > 1">
              <text class="card-label">换算</text>
              <text class="card-value">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading && selectedProduct" mode="data" text="暂无货品收发存数据" :marginTop="100"></u-empty>
        <view v-else-if="!selectedProduct" class="empty-tip">
          <u-icon name="search" size="28" color="#C9CDD4"></u-icon>
          <text class="empty-tip-text">请先选择货品查看收发存明细</text>
        </view>
      </view>

      <!-- Tab 5: 有效期盘点 -->
      <view v-if="currentTab === 4" class="tab-content">
        <view v-if="expiryList.length > 0" class="card-list">
          <view v-for="(item, idx) in expiryList" :key="idx" class="report-card expiry-card">
            <view class="card-header-row">
              <text class="card-product-name">{{ item.productName || '-' }}</text>
              <view class="expiry-status-badge" :style="{ backgroundColor: getExpiryStatusColor(item.expiryStatus) + '1A', color: getExpiryStatusColor(item.expiryStatus) }">{{ item.expiryStatusText || item.expiryStatus || '-' }}</view>
            </view>
            <view class="card-row">
              <text class="card-label">类别</text>
              <text class="card-value">{{ getCategoryLabel(item.category) || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">单据编号</text>
              <text class="card-value">{{ item.stockInNo || '-' }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">批次数量</text>
              <text class="card-value bold">{{ formatQty(item.remainingQuantity, item) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">生产日期</text>
              <text class="card-value">{{ formatDate(item.productionDate) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">到期日期</text>
              <text class="card-value">{{ formatDate(item.expiryDate) }}</text>
            </view>
            <view class="card-row">
              <text class="card-label">剩余天数</text>
              <text class="card-value bold" :style="{ color: getExpiryStatusColor(item.expiryStatus) }">{{ item.remainingDays != null ? item.remainingDays + '天' : '-' }}</text>
            </view>
          </view>
        </view>
        <u-empty v-else-if="!loading" mode="data" text="暂无有效期盘点数据" :marginTop="100"></u-empty>
      </view>

      <view class="bottom-spacer"></view>
    </scroll-view>
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

  <u-popup :show="showCategoryPicker" mode="bottom" round="16" @close="showCategoryPicker = false">
    <view class="expiry-picker-content">
      <view class="picker-header">
        <text class="picker-title">选择类别</text>
        <view class="picker-close" @click="showCategoryPicker = false">
          <u-icon name="close" size="18" color="#86909C"></u-icon>
        </view>
      </view>
      <scroll-view scroll-y class="picker-list">
        <view class="picker-item" @click="category = ''; showCategoryPicker = false; handleQuery()">
          <text class="picker-item-name">全部类别</text>
          <u-icon v-if="!category" name="checkmark" size="16" color="#3D6DF7"></u-icon>
        </view>
        <view v-for="item in categoryOptions" :key="item.dictValue" class="picker-item" :class="{ active: category === item.dictValue }" @click="onSelectCategory(item.dictValue)">
          <text class="picker-item-name">{{ item.dictLabel }}</text>
          <u-icon v-if="category === item.dictValue" name="checkmark" size="16" color="#3D6DF7"></u-icon>
        </view>
      </scroll-view>
    </view>
  </u-popup>

  <u-popup :show="showExpiryStatusPicker" mode="bottom" round="16" @close="showExpiryStatusPicker = false">
    <view class="expiry-picker-content">
      <view class="picker-header">
        <text class="picker-title">选择到期状态</text>
        <view class="picker-close" @click="showExpiryStatusPicker = false">
          <u-icon name="close" size="18" color="#86909C"></u-icon>
        </view>
      </view>
      <scroll-view scroll-y class="picker-list">
        <view v-for="item in expiryStatusOptions" :key="item.value" class="picker-item" :class="{ active: expiryStatusFilter === item.value }" @click="onSelectExpiryStatus(item.value)">
          <text class="picker-item-name">{{ item.label }}</text>
          <u-icon v-if="expiryStatusFilter === item.value" name="checkmark" size="16" color="#3D6DF7"></u-icon>
        </view>
      </scroll-view>
    </view>
  </u-popup>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { stockInSummary, stockOutSummary, inventoryTurnover, productFlow, expiryInventory } from '@/api/wms/report'
import { searchProduct } from '@/api/wms/product'
import { useWarehouse } from '@/composables/useWarehouse'
import { checkPermi } from '@/utils/permission'
import { getDicts } from '@/api/system/dictData'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const unitOptions = ref([])
const specOptions = ref([])
const categoryOptions = ref([])

function getUnitLabel(value) {
  if (!value) return ''
  const dict = unitOptions.value.find(d => d.dictValue === value)
  return dict ? dict.dictLabel : ''
}
function getSpecLabel(value) {
  if (!value) return ''
  const dict = specOptions.value.find(d => d.dictValue === value)
  return dict ? dict.dictLabel : ''
}
function getCategoryLabel(value) {
  if (!value) return ''
  const dict = categoryOptions.value.find(d => d.dictValue === value)
  return dict ? dict.dictLabel : ''
}

function formatQty(qty, row) {
  const packQty = row.packQty || 1
  const unitLabel = getUnitLabel(row.unit)
  const specLabel = getSpecLabel(row.spec)
  qty = qty || 0
  if (packQty > 1 && specLabel) {
    const mainQty = qty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + unitLabel + '（' + qty + specLabel + '）'
  } else if (unitLabel) {
    return qty + unitLabel
  } else {
    return String(qty)
  }
}

const currentTab = ref(0)
const tabList = ref([
  { name: '入库汇总' },
  { name: '出库汇总' },
  { name: '库存周转' },
  { name: '货品收发存' },
  { name: '有效期盘点' }
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
const showCategoryPicker = ref(false)

// 货品筛选
const selectedProduct = ref(null)
const showProductPicker = ref(false)
const productKeyword = ref('')
const productOptions = ref([])
const productSearchLoading = ref(false)
let productSearchTimer = null

// Tab 1: 入库汇总
const stockInList = ref([])
const stockInSummaryData = computed(() => {
  const totalQuantity = stockInList.value.reduce((s, i) => s + (parseFloat(i.totalQuantity) || 0), 0)
  const totalAmount = stockInList.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  return { totalQuantity, totalAmount }
})

// Tab 2: 出库汇总
const stockOutList = ref([])
const stockOutSummaryData = computed(() => {
  const totalQuantity = stockOutList.value.reduce((s, i) => s + (parseFloat(i.totalQuantity) || 0), 0)
  const totalAmount = stockOutList.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  return { totalQuantity, totalAmount }
})

// Tab 3: 库存周转
const turnoverList = ref([])

// Tab 4: 货品收发存
const flowList = ref([])

// Tab 5: 有效期盘点
const expiryList = ref([])
const expiryStatusFilter = ref('')
const showExpiryStatusPicker = ref(false)
const expiryStatusOptions = [
  { label: '已过期', value: 'expired' },
  { label: '30天内到期', value: '30' },
  { label: '60天内到期', value: '60' },
  { label: '90天内到期', value: '90' },
  { label: '正常', value: 'normal' }
]

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

function onWarehouseChange(warehouseId) {
  currentWarehouseId.value = warehouseId
  loadData(true)
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

  try {
    if (currentTab.value === 0) {
      const params = { stockInDateStart: startDate.value, stockInDateEnd: endDate.value }
      if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
      if (category.value) params.category = category.value
      const res = await stockInSummary(params)
      stockInList.value = res.data || res || []
    } else if (currentTab.value === 1) {
      const params = { stockOutDateStart: startDate.value, stockOutDateEnd: endDate.value }
      if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
      if (category.value) params.category = category.value
      const res = await stockOutSummary(params)
      stockOutList.value = res.data || res || []
    } else if (currentTab.value === 2) {
      const params = { startDate: startDate.value, endDate: endDate.value }
      if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
      if (category.value) params.category = category.value
      const res = await inventoryTurnover(params)
      turnoverList.value = res.data || res || []
    } else if (currentTab.value === 3) {
      if (!selectedProduct.value) {
        flowList.value = []
        return
      }
      const params = { flowDateStart: startDate.value, flowDateEnd: endDate.value }
      if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
      params.productId = selectedProduct.value.productId
      const res = await productFlow(params)
      flowList.value = res.data || res || []
    } else if (currentTab.value === 4) {
      loadExpiryData()
    }
  } catch (e) {
    console.error('加载报表数据失败:', e)
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

function loadMore() {
  // 货品收发存不支持分页，无需加载更多
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

function onSelectCategory(value) {
  category.value = value
  showCategoryPicker.value = false
  handleQuery()
}

function clearProduct() {
  selectedProduct.value = null
  loadData(true)
}

function loadExpiryData() {
  const params = {}
  if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
  if (expiryStatusFilter.value) params.expiryStatus = expiryStatusFilter.value
  expiryInventory(params).then(res => {
    expiryList.value = res.data || []
  })
}

function getExpiryStatusColor(status) {
  switch (status) {
    case 'expired': return '#F56C6C'
    case '30': return '#E6A23C'
    case '60': return '#e6a23c'
    case '90': return '#409EFF'
    default: return '#67C23A'
  }
}

function getExpiryStatusText(value) {
  const option = expiryStatusOptions.find(o => o.value === value)
  return option ? option.label : value
}

function onSelectExpiryStatus(value) {
  expiryStatusFilter.value = value
  showExpiryStatusPicker.value = false
  loadExpiryData()
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
  loadWarehouses()
  initDefaultDateRange()
  getDicts('biz_product_unit').then(res => { unitOptions.value = res.data || [] })
  getDicts('biz_product_spec').then(res => { specOptions.value = res.data || [] })
  getDicts('biz_product_category').then(res => { categoryOptions.value = res.data || [] })
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
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
  overflow: hidden;
}

.filter-section {
  flex-shrink: 0;
  margin-top: 20rpx;
}

.warehouse-filter { margin-bottom: 16rpx; }
.warehouse-scroll { white-space: nowrap; }
.warehouse-tags { display: inline-flex; gap: 16rpx; padding: 4rpx 0; }
.warehouse-tag {
  display: inline-flex; align-items: center; justify-content: center;
  padding: 12rpx 28rpx; background: #fff; border-radius: 28rpx;
  font-size: 26rpx; color: #4E5969; border: 2rpx solid #E5E6EB;
  box-shadow: 0 2rpx 8rpx rgba(61,109,247,0.06); white-space: nowrap;
  transition: all 0.2s;
  &.active { background: #3D6DF7; color: #fff; border-color: #3D6DF7; }
}

.date-range-picker {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 20rpx;
  background: #fff;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
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
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.category-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.category-selected { flex: 1; font-size: 28rpx; color: #1D2129; }
.category-placeholder { flex: 1; font-size: 28rpx; color: #C9CDD4; }
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
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.product-selected { flex: 1; font-size: 28rpx; color: #1D2129; }
.product-placeholder { flex: 1; font-size: 28rpx; color: #C9CDD4; }

.expiry-status-filter { margin-top: 16rpx; }
.expiry-status-input-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 72rpx;
  gap: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.expiry-status-selected { flex: 1; font-size: 28rpx; color: #1D2129; }
.expiry-status-placeholder { flex: 1; font-size: 28rpx; color: #C9CDD4; }

.expiry-picker-content {
  background: #fff;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}

.expiry-status-badge {
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  font-size: 22rpx;
  font-weight: 500;
  flex-shrink: 0;
}

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
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
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
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12rpx;
  width: 100%;
  margin-top: 16rpx;
}
.turnover-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx 12rpx;
  gap: 6rpx;
  &.in .turnover-val { color: #3D6DF7; }
  &.out .turnover-val { color: #FF6B35; }
  &.end .turnover-val { color: #3D6DF7; font-weight: 600; font-size: 30rpx; }
}
.turnover-label { font-size: 22rpx; color: #86909C; }
.turnover-val {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
}

.summary-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx 32rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
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
.summary-label { font-size: 24rpx; color: #86909C; white-space: nowrap; }
.summary-value { font-size: 36rpx; font-weight: 700; color: #1D2129;
  &.amount { color: #FF6B35; }
}
.summary-divider { width: 2rpx; height: 60rpx; background: #E5E6EB; }

.bottom-spacer { height: 40rpx; }

.empty-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 0;
  gap: 20rpx;
}
.empty-tip-text { font-size: 26rpx; color: #C9CDD4; }
</style>
