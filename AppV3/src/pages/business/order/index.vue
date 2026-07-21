<template>
  <view class="order-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索订单编号/客户" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view v-if="queryParams.enterpriseId" class="filter-tag active" @click="clearFilter('enterpriseId')">
            <text>{{ getEnterpriseName(queryParams.enterpriseId) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.storeId" class="filter-tag active" @click="clearFilter('storeId')">
            <text>{{ getStoreName(queryParams.storeId) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.creatorUserId" class="filter-tag active" @click="clearFilter('creatorUserId')">
            <text>{{ getEmployeeName(queryParams.creatorUserId) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.sourceType" class="filter-tag active" @click="clearFilter('sourceType')">
            <text>{{ getSourceTypeName(queryParams.sourceType) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.beginTime" class="filter-tag active" @click="clearFilter('beginTime')">
            <text>起:{{ queryParams.beginTime }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.endTime" class="filter-tag active" @click="clearFilter('endTime')">
            <text>止:{{ queryParams.endTime }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.status !== '' && queryParams.status !== undefined" class="filter-tag active" @click="clearFilter('status')">
            <text>{{ getOrderStatusName(queryParams.status) }}</text><u-icon name="close" size="12"></u-icon>
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
          <view class="form-label">开单员工</view>
          <view class="form-select" @click="showEmployeePicker = true">
            <text :class="queryParams.creatorUserId ? 'selected-text' : 'placeholder-text'">
              {{ queryParams.creatorUserId ? getEmployeeName(queryParams.creatorUserId) : '请选择员工' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">来源类型</view>
          <view class="form-options">
            <view v-for="item in sourceTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.sourceType === item.value }" @click="queryParams.sourceType = queryParams.sourceType === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">开始日期</view>
          <view class="form-select" @click="showStartDatePicker = true">
            <text :class="queryParams.beginTime ? 'selected-text' : 'placeholder-text'">
              {{ queryParams.beginTime || '请选择开始日期' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">结束日期</view>
          <view class="form-select" @click="showEndDatePicker = true">
            <text :class="queryParams.endTime ? 'selected-text' : 'placeholder-text'">
              {{ queryParams.endTime || '请选择结束日期' }}
            </text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">订单状态</view>
          <view class="form-options">
            <view v-for="item in orderStatusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-picker :show="showEnterprisePicker" :columns="enterprisePickerColumns" keyName="enterpriseName" @confirm="onEnterprisePickerConfirm" @cancel="showEnterprisePicker = false" @close="showEnterprisePicker = false"></u-picker>
    <u-picker :show="showStorePicker" :columns="storePickerColumns" keyName="storeName" @confirm="onStorePickerConfirm" @cancel="showStorePicker = false" @close="showStorePicker = false"></u-picker>
    <u-picker :show="showEmployeePicker" :columns="employeePickerColumns" keyName="nickName" @confirm="onEmployeePickerConfirm" @cancel="showEmployeePicker = false" @close="showEmployeePicker = false"></u-picker>

    <u-datetime-picker :show="showStartDatePicker" mode="date" :value="queryParams.beginTime ? new Date(queryParams.beginTime).getTime() : Date.now()" @confirm="onStartDateConfirm" @cancel="showStartDatePicker = false" @close="showStartDatePicker = false"></u-datetime-picker>
    <u-datetime-picker :show="showEndDatePicker" mode="date" :value="queryParams.endTime ? new Date(queryParams.endTime).getTime() : Date.now()" @confirm="onEndDateConfirm" @cancel="showEndDatePicker = false" @close="showEndDatePicker = false"></u-datetime-picker>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="orderList.length > 0" class="card-list">
        <view v-for="item in orderList" :key="item.order_id || item.orderId" class="order-card" @click="goDetail(item)">
          <view class="card-header">
            <view class="header-left">
              <text class="order-no">{{ displayOrderNo(item) }}</text>
              <u-tag :text="getSourceTypeLabel(item)" size="mini" :type="getSourceTagType(item)" />
              <u-tag v-if="getPaymentMethodLabel(item)" :text="getPaymentMethodLabel(item)" size="mini" :type="getPaymentMethodTagType(item)" />
            </view>
            <view class="status-tag" :class="'status-' + (item.order_status ?? item.orderStatus ?? item.status)">{{ getOrderStatusName(item.order_status ?? item.orderStatus ?? item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item"><text class="label">客户</text><text class="value">{{ item.customer_name || item.customerName || '-' }}</text></view>
              <view class="info-item"><text class="label">门店</text><text class="value">{{ getStoreDisplay(item) }}</text></view>
            </view>
            <view class="info-row">
              <view class="info-item"><text class="label">门店管理</text><text class="value">{{ item.store_dealer || item.storeDealer || '-' }}</text></view>
              <view class="info-item"><text class="label">开单员工</text><text class="value">{{ item.creator_user_name || item.creatorUserName || '-' }}</text></view>
            </view>
            <view class="info-row">
              <view class="info-item"><text class="label">金额</text><text class="value amount">¥{{ getDisplayAmount(item) }}</text></view>
              <view class="info-item"><text class="label">时间</text><text class="value">{{ formatTime(item.create_time || item.createTime) }}</text></view>
            </view>
          </view>
          <view class="card-actions" v-if="checkPermi('business:order:cancel') && ['0','1'].includes(String(item.order_status ?? item.orderStatus ?? item.status))">
            <view class="action-btn cancel" @click.stop="cancelOrder(item)">取消订单</view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无订单数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listSalesOrder, cancelOrder as cancelOrderApi } from '@/api/business/salesOrder'
import { listEnterprise } from '@/api/business/enterprise'
import { listStore } from '@/api/business/store'
import { listEmployeeConfig } from '@/api/business/employeeConfig'
import { useDictStore } from '@/store/modules/dict'
import { checkPermi } from '@/utils/permission'


const dictStore = useDictStore()
const orderList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showEnterprisePicker = ref(false)
const showStorePicker = ref(false)
const showEmployeePicker = ref(false)

const enterpriseOptions = ref([])
const storeOptions = ref([])
const employeeOptions = ref([])

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => queryParams.enterpriseId || queryParams.storeId || queryParams.creatorUserId || queryParams.sourceType || queryParams.beginTime || queryParams.endTime || (queryParams.status !== '' && queryParams.status !== undefined))

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', enterpriseId: '', storeId: '', creatorUserId: '', sourceType: '', beginTime: '', endTime: '', status: '' })

const orderStatusOptions = ref([
  { label: '待确认', value: '0' },
  { label: '企业已审', value: '1' },
  { label: '财务已审', value: '2' },
  { label: '已取消', value: '4' }
])

const sourceTypeOptions = ref([
  { label: '开单', value: '0' },
  { label: '操作', value: '1' },
  { label: '还款', value: '2' },
  { label: '手动', value: '3' }
])

const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)

function getSourceTypeName(value) {
  const item = sourceTypeOptions.value.find(t => t.value === String(value))
  return item ? item.label : ''
}

function formatDate(timestamp) {
  const d = new Date(timestamp)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function onStartDateConfirm(e) {
  queryParams.beginTime = formatDate(e.value)
  showStartDatePicker.value = false
}

function onEndDateConfirm(e) {
  queryParams.endTime = formatDate(e.value)
  showEndDatePicker.value = false
}

const enterprisePickerColumns = computed(() => [enterpriseOptions.value])
const storePickerColumns = computed(() => [storeOptions.value])
const employeePickerColumns = computed(() => [employeeOptions.value])

function displayOrderNo(item) {
  const no = item.order_no || item.orderNo
  if (no) return no
  const id = item.order_id || item.orderId
  if (!id) return '-'
  return 'SO' + String(id).padStart(8, '0')
}

function getSourceTypeLabel(item) {
  const source = String(item.source_type || item.sourceType || '0')
  return dictStore.getDictLabel('biz_source_type', source)
}

function getSourceTagType(item) {
  const source = String(item.source_type || item.sourceType || '0')
  return dictStore.getDictTagType('biz_source_type', source)
}

function getPaymentMethodLabel(item) {
  const method = item.payment_method || item.paymentMethod
  if (!method) return ''
  const map = { cash: '现金', card: '耗卡', gift: '赠送' }
  return map[method] || ''
}

function getPaymentMethodTagType(item) {
  const method = item.payment_method || item.paymentMethod
  const map = { cash: 'warning', card: 'success', gift: '' }
  return map[method] || 'info'
}

function getOrderStatusName(status) {
  const s = String(status === null || status === undefined ? '' : status)
  const item = orderStatusOptions.value.find(opt => opt.value === s)
  return item ? item.label : '未知'
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function getStoreDisplay(item) {
  const enterprise = item.enterprise_name || item.enterpriseName || ''
  const store = item.store_name || item.storeName || ''
  if (enterprise && store) return `${enterprise}·${store}`
  if (store) return store
  return '-'
}

async function loadEnterpriseOptions() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 100 })
    const data = response.data || response
    enterpriseOptions.value = data.rows || []
  } catch (e) { console.error('获取企业列表失败:', e) }
}

async function loadStoreOptions() {
  try {
    const params = { pageNum: 1, pageSize: 100, ...(queryParams.enterpriseId ? { enterpriseId: queryParams.enterpriseId } : {}) }
    const response = await listStore(params)
    const data = response.data || response
    storeOptions.value = data.rows || []
  } catch (e) { console.error('获取门店列表失败:', e) }
}

async function loadEmployeeOptions() {
  try {
    const response = await listEmployeeConfig({ pageNum: 1, pageSize: 100 })
    const data = response.data || response
    employeeOptions.value = data.rows || []
  } catch (e) { console.error('获取员工列表失败:', e) }
}

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

function onStorePickerConfirm({ value }) {
  const selected = value[0]
  if (selected) {
    queryParams.storeId = selected.storeId
  }
  showStorePicker.value = false
}

function onEmployeePickerConfirm({ value }) {
  const selected = value[0]
  if (selected) {
    queryParams.creatorUserId = selected.userId
  }
  showEmployeePicker.value = false
}

function getEnterpriseName(id) {
  const item = enterpriseOptions.value.find(e => String(e.enterpriseId) === String(id))
  return item ? item.enterpriseName : ''
}

function getStoreName(id) {
  const item = storeOptions.value.find(s => String(s.storeId) === String(id))
  return item ? item.storeName : ''
}

function getEmployeeName(id) {
  const item = employeeOptions.value.find(e => String(e.userId) === String(id))
  return item ? (item.nickName || item.userName || '') : ''
}

function getDisplayAmount(item) {
  const sourceType = item.source_type || item.sourceType
  if (sourceType === '2') {
    return Number(item.paid_amount || item.paidAmount || 0).toFixed(2)
  }
  return Number(item.deal_amount || item.dealAmount || 0).toFixed(2)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { ...queryParams }
    if (params.keyword) { params.orderNo = params.keyword; params.customerName = params.keyword }
    delete params.keyword
    const response = await listSalesOrder(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    orderList.value = isRefresh ? list : [...orderList.value, ...list]
    loadStatus.value = orderList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取订单列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.enterpriseId = ''; queryParams.storeId = ''; queryParams.creatorUserId = ''; queryParams.sourceType = ''; queryParams.beginTime = ''; queryParams.endTime = ''; queryParams.status = ''; storeOptions.value = [] }
function confirmFilter() { showFilter.value = false; getList(true) }
function clearFilter(field) {
  if (field === 'enterpriseId') {
    queryParams.enterpriseId = ''
    queryParams.storeId = ''
    storeOptions.value = []
    loadStoreOptions()
  } else {
    queryParams[field] = ''
  }
  getList(true)
}

function goDetail(item) {
  const sourceType = String(item.source_type || item.sourceType || '0')
  const id = item.order_id || item.orderId
  if (sourceType === '1') {
    const cid = item.customer_id || item.customerId || ''
    const cname = encodeURIComponent(item.customer_name || item.customerName || '')
    const sname = encodeURIComponent(item.store_name || item.storeName || '')
    const ename = encodeURIComponent(item.enterprise_name || item.enterpriseName || '')
    uni.navigateTo({ url: `/pages/business/sales/operation?customerId=${cid}&customerName=${cname}&storeName=${sname}&enterpriseName=${ename}` })
  } else {
    uni.navigateTo({ url: `/pages/business/order/detail?id=${id}` })
  }
}

async function cancelOrder(item) {
  try {
    uni.showModal({
      title: '提示',
      content: '确定要取消该订单吗？',
      success: async (res) => {
        if (res.confirm) {
          await cancelOrderApi(item.order_id || item.orderId)
          uni.$u.toast('取消成功')
          getList(true)
        }
      }
    })
  } catch (e) {
    uni.$u.toast(e.message || '取消失败')
  }
}

onMounted(() => { dictStore.loadDict('biz_source_type'); loadEnterpriseOptions(); loadStoreOptions(); loadEmployeeOptions(); getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.order-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%); }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 4rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  .icon-rotate { transform: rotate(180deg); transition: transform 0.3s ease; }
}

.active-filters { flex-shrink: 0; padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%); }
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag { display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx; background: rgba(255,255,255,0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-select { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 24rpx; background: #F5F7FA; border-radius: 8rpx; }
.selected-text { font-size: 26rpx; color: #1D2129; }
.placeholder-text { font-size: 26rpx; color: #C9CDD4; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.order-card { background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }

.header-left { display: flex; align-items: center; gap: 12rpx; flex: 1; min-width: 0;
  .order-no { font-size: 28rpx; font-weight: 600; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.status-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #E8FFEA; color: #00B42A; }
  &.status-4 { background: #F2F3F5; color: #86909C; }
}

.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; }
.card-actions { display: flex; justify-content: flex-end; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; margin-top: 16rpx; }
.action-btn { padding: 10rpx 24rpx; border-radius: 8rpx; font-size: 26rpx; font-weight: 500;
  &.cancel { color: #F53F3F; background: #FFF2F0; }
}
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item { flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; }
  .value { font-size: 26rpx; color: #1D2129;
    &.amount { color: #FF6B35; font-weight: 600; font-size: 30rpx; }
  }
}
</style>
