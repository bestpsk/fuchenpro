<template>
  <view class="stats-page">
    <view class="tab-bar">
      <view
        v-for="(tab, idx) in tabs"
        :key="idx"
        class="tab-item"
        :class="{ active: currentTab === idx }"
        @click="switchTab(idx)"
      >
        <text class="tab-text">{{ tab.label }}</text>
        <view v-if="currentTab === idx" class="tab-indicator"></view>
      </view>
    </view>

    <scroll-view scroll-y class="tab-content">

      <view v-if="currentTab === 0" class="biz-section">
        <view class="time-filter">
          <view
            v-for="t in bizTimeOptions"
            :key="t.value"
            class="time-tag"
            :class="{ active: bizTimeType === t.value }"
            @click="selectBizTime(t.value)"
          >{{ t.label }}</view>
        </view>

        <view v-if="bizTimeType === 'custom'" class="date-range-picker">
          <view class="date-item" @click="showStartDatePicker = true">
            <u-icon name="calendar" size="14" color="#86909C"></u-icon>
            <text :class="{ 'date-placeholder': !customStartDate }">{{ customStartDate || '开始日期' }}</text>
          </view>
          <text class="date-separator">至</text>
          <view class="date-item" @click="showEndDatePicker = true">
            <u-icon name="calendar" size="14" color="#86909C"></u-icon>
            <text :class="{ 'date-placeholder': !customEndDate }">{{ customEndDate || '结束日期' }}</text>
          </view>
          <view class="date-confirm-btn" @click="confirmCustomDate">
            <text>查询</text>
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

        <view class="stat-cards-grid">
          <view class="stat-card blue-card">
            <text class="sc-label">成交客数</text>
            <text class="sc-value">{{ currentBizData.dealCustomer }}</text>
          </view>
          <view class="stat-card blue-card">
            <text class="sc-label">成交金额</text>
            <text class="sc-value">{{ currentBizData.dealAmount }}</text>
          </view>
          <view class="stat-card blue-card">
            <text class="sc-label">实付金额</text>
            <text class="sc-value">{{ currentBizData.paidAmount }}</text>
          </view>
          <view class="stat-card orange-card">
            <text class="sc-label">欠款金额</text>
            <text class="sc-value">{{ currentBizData.owedAmount }}</text>
          </view>
          <view class="stat-card orange-card">
            <text class="sc-label">现金</text>
            <text class="sc-value">{{ currentBizData.cashAmount }}</text>
          </view>
          <view class="stat-card orange-card">
            <text class="sc-label">耗卡</text>
            <text class="sc-value">{{ currentBizData.cardAmount }}</text>
          </view>
          <view class="stat-card purple-card">
            <text class="sc-label">赠送</text>
            <text class="sc-value">{{ currentBizData.giftCount }}</text>
          </view>
          <view class="stat-card purple-card">
            <text class="sc-label">操作客数</text>
            <text class="sc-value">{{ currentBizData.operationCustomer }}</text>
          </view>
          <view class="stat-card purple-card">
            <text class="sc-label">操作金额</text>
            <text class="sc-value">{{ currentBizData.operationAmount }}</text>
          </view>
        </view>

        <view class="section-block">
          <view class="block-title">企业数据统计</view>
          <view v-if="enterpriseStats.length > 0" class="enterprise-list">
            <view v-for="item in enterpriseStats" :key="item.enterpriseId" class="enterprise-item">
              <view class="enterprise-header">
                <u-icon name="home" size="16" color="#3D6DF7"></u-icon>
                <text class="enterprise-name">{{ item.enterpriseName }}</text>
              </view>
              <view class="enterprise-stats-grid">
                <view class="es-item">
                  <text class="es-label">成交客户</text>
                  <text class="es-value blue">{{ item.dealCustomerCount }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">成交金额</text>
                  <text class="es-value blue">{{ formatAmount(item.dealAmount) }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">实付金额</text>
                  <text class="es-value blue">{{ formatAmount(item.paidAmount) }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">欠款金额</text>
                  <text class="es-value orange">{{ formatAmount(item.owedAmount) }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">现金</text>
                  <text class="es-value orange">{{ formatAmount(item.cashAmount) }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">耗卡</text>
                  <text class="es-value orange">{{ formatAmount(item.cardAmount) }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">赠送</text>
                  <text class="es-value purple">{{ item.giftCount || 0 }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">操作客数</text>
                  <text class="es-value purple">{{ item.operationCustomerCount }}</text>
                </view>
                <view class="es-item">
                  <text class="es-label">操作金额</text>
                  <text class="es-value purple">{{ formatAmount(item.operationAmount) }}</text>
                </view>
              </view>
            </view>
          </view>
          <view v-else class="empty-block">
            <text class="empty-text">暂无企业统计数据</text>
          </view>
        </view>
      </view>

      <view v-if="currentTab === 1" class="wms-section">
        <view class="time-filter">
          <view
            v-for="t in wmsTimeOptions"
            :key="t.value"
            class="time-tag"
            :class="{ active: wmsTimeType === t.value }"
            @click="changeWmsTime(t.value)"
          >{{ t.label }}</view>
        </view>

        <view class="stat-cards-grid">
          <view class="stat-card green-card">
            <text class="sc-label">入库金额</text>
            <text class="sc-value">{{ wmsSummary.stockInAmount }}</text>
            <text class="sc-sub">{{ wmsSummary.stockInCount }}种货品</text>
          </view>
          <view class="stat-card green-card">
            <text class="sc-label">出库金额</text>
            <text class="sc-value">{{ wmsSummary.stockOutAmount }}</text>
            <text class="sc-sub">{{ wmsSummary.stockOutCount }}种货品</text>
          </view>
        </view>

        <view class="section-block">
          <view class="block-header" @click="stockInExpanded = !stockInExpanded">
            <text class="block-title">入库汇总</text>
            <u-icon :name="stockInExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
          </view>
          <view v-if="stockInExpanded" class="detail-list">
            <view v-for="(item, idx) in stockInData" :key="idx" class="detail-item">
              <view class="detail-left">
                <text class="detail-name">{{ item.productName }}</text>
              </view>
              <view class="detail-right">
                <text class="detail-qty">{{ item.totalQuantity || 0 }}件</text>
                <text class="detail-amount">¥{{ formatNum(item.totalAmount) }}</text>
              </view>
            </view>
            <view v-if="stockInData.length === 0" class="empty-block">
              <text class="empty-text">暂无入库数据</text>
            </view>
          </view>
        </view>

        <view class="section-block">
          <view class="block-header" @click="stockOutExpanded = !stockOutExpanded">
            <text class="block-title">出库汇总</text>
            <u-icon :name="stockOutExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
          </view>
          <view v-if="stockOutExpanded" class="detail-list">
            <view v-for="(item, idx) in stockOutData" :key="idx" class="detail-item">
              <view class="detail-left">
                <text class="detail-name">{{ item.productName }}</text>
              </view>
              <view class="detail-right">
                <text class="detail-qty">{{ item.totalQuantity || 0 }}件</text>
                <text class="detail-amount">¥{{ formatNum(item.totalAmount) }}</text>
              </view>
            </view>
            <view v-if="stockOutData.length === 0" class="empty-block">
              <text class="empty-text">暂无出库数据</text>
            </view>
          </view>
        </view>

        <view class="section-block">
          <view class="block-header" @click="turnoverExpanded = !turnoverExpanded">
            <text class="block-title">库存周转</text>
            <u-icon :name="turnoverExpanded ? 'arrow-up' : 'arrow-down'" size="12" color="#86909C"></u-icon>
          </view>
          <view v-if="turnoverExpanded" class="detail-list">
            <view v-for="(item, idx) in turnoverData" :key="idx" class="detail-item turnover-item">
              <text class="detail-name">{{ item.productName }}</text>
              <view class="turnover-row">
                <view class="turnover-cell">
                  <text class="turnover-label">期初</text>
                  <text class="turnover-val">{{ item.beginQuantity || 0 }}</text>
                </view>
                <view class="turnover-cell in">
                  <text class="turnover-label">入</text>
                  <text class="turnover-val">{{ item.periodInQuantity || 0 }}</text>
                </view>
                <view class="turnover-cell out">
                  <text class="turnover-label">出</text>
                  <text class="turnover-val">{{ item.periodOutQuantity || 0 }}</text>
                </view>
                <view class="turnover-cell">
                  <text class="turnover-label">期末</text>
                  <text class="turnover-val end">{{ item.endQuantity || 0 }}</text>
                </view>
              </view>
            </view>
            <view v-if="turnoverData.length === 0" class="empty-block">
              <text class="empty-text">暂无周转数据</text>
            </view>
          </view>
        </view>
      </view>

      <view v-if="currentTab === 2" class="attend-section">
        <view class="month-selector">
          <view class="month-arrow" @click="changeMonth(-1)"><u-icon name="arrow-left" size="16" color="#4E5969"></u-icon></view>
          <text class="month-text">{{ attendMonthLabel }}</text>
          <view class="month-arrow" @click="changeMonth(1)"><u-icon name="arrow-right" size="16" color="#4E5969"></u-icon></view>
        </view>

        <view class="attend-grid">
          <view class="attend-item">
            <text class="attend-val green">{{ attendStats.normal }}</text>
            <text class="attend-label">正常</text>
          </view>
          <view class="attend-item">
            <text class="attend-val orange">{{ attendStats.late }}</text>
            <text class="attend-label">迟到</text>
          </view>
          <view class="attend-item">
            <text class="attend-val orange">{{ attendStats.early }}</text>
            <text class="attend-label">早退</text>
          </view>
          <view class="attend-item">
            <text class="attend-val red">{{ attendStats.absent }}</text>
            <text class="attend-label">缺勤</text>
          </view>
        </view>

        <view class="section-block">
          <view class="block-title">出勤率</view>
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: attendStats.rate + '%' }"></view>
          </view>
          <text class="progress-text">{{ attendStats.rate }}%</text>
        </view>
      </view>

      <view class="bottom-spacer"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getTodayStats, getEnterpriseStats } from '@/api/home'
import { stockInSummary, stockOutSummary, inventoryTurnover } from '@/api/wms/report'
import { getMonthStats } from '@/api/attendance'

const currentTab = ref(0)
const tabs = [
  { label: '业务统计' },
  { label: '仓储统计' },
  { label: '考勤统计' }
]

const bizStats = reactive({
  dealCustomerToday: '0',
  dealCustomerMonth: '0',
  dealCustomerCustom: '0',
  dealAmountToday: '¥0',
  dealAmountMonth: '¥0',
  dealAmountCustom: '¥0',
  paidAmountToday: '¥0',
  paidAmountMonth: '¥0',
  paidAmountCustom: '¥0',
  owedAmountToday: '¥0',
  owedAmountMonth: '¥0',
  owedAmountCustom: '¥0',
  cashAmountToday: '¥0',
  cashAmountMonth: '¥0',
  cashAmountCustom: '¥0',
  cardAmountToday: '¥0',
  cardAmountMonth: '¥0',
  cardAmountCustom: '¥0',
  giftCountToday: '0',
  giftCountMonth: '0',
  giftCountCustom: '0',
  operationCustomerToday: '0',
  operationCustomerMonth: '0',
  operationCustomerCustom: '0',
  operationAmountToday: '¥0',
  operationAmountMonth: '¥0',
  operationAmountCustom: '¥0'
})

const bizTimeType = ref('today')
const bizTimeOptions = [
  { label: '今日', value: 'today' },
  { label: '本月', value: 'month' },
  { label: '自定义', value: 'custom' }
]

const customStartDate = ref('')
const customEndDate = ref('')
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)
const startDatePickerValue = ref(Date.now())
const endDatePickerValue = ref(Date.now())

const enterpriseStats = ref([])

const currentBizData = computed(() => {
  if (bizTimeType.value === 'custom') {
    return {
      dealCustomer: bizStats.dealCustomerCustom,
      dealAmount: bizStats.dealAmountCustom,
      paidAmount: bizStats.paidAmountCustom,
      owedAmount: bizStats.owedAmountCustom,
      cashAmount: bizStats.cashAmountCustom,
      cardAmount: bizStats.cardAmountCustom,
      giftCount: bizStats.giftCountCustom,
      operationCustomer: bizStats.operationCustomerCustom,
      operationAmount: bizStats.operationAmountCustom
    }
  }
  const isToday = bizTimeType.value === 'today'
  const dealCustomer = isToday ? bizStats.dealCustomerToday : bizStats.dealCustomerMonth
  const dealAmount = isToday ? bizStats.dealAmountToday : bizStats.dealAmountMonth
  const paidAmount = isToday ? bizStats.paidAmountToday : bizStats.paidAmountMonth
  const owedAmount = isToday ? bizStats.owedAmountToday : bizStats.owedAmountMonth
  const cashAmount = isToday ? bizStats.cashAmountToday : bizStats.cashAmountMonth
  const cardAmount = isToday ? bizStats.cardAmountToday : bizStats.cardAmountMonth
  const giftCount = isToday ? bizStats.giftCountToday : bizStats.giftCountMonth
  const operationCustomer = isToday ? bizStats.operationCustomerToday : bizStats.operationCustomerMonth
  const operationAmount = isToday ? bizStats.operationAmountToday : bizStats.operationAmountMonth
  return { dealCustomer, dealAmount, paidAmount, owedAmount, cashAmount, cardAmount, giftCount, operationCustomer, operationAmount }
})

const wmsTimeType = ref('month')
const wmsTimeOptions = [
  { label: '本月', value: 'month' },
  { label: '近3月', value: 'quarter' }
]

const stockInData = ref([])
const stockOutData = ref([])
const turnoverData = ref([])
const stockInExpanded = ref(true)
const stockOutExpanded = ref(true)
const turnoverExpanded = ref(false)

const wmsSummary = computed(() => {
  const inTotal = stockInData.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  const outTotal = stockOutData.value.reduce((s, i) => s + (parseFloat(i.totalAmount) || 0), 0)
  return {
    stockInAmount: '¥' + formatNum(inTotal),
    stockOutAmount: '¥' + formatNum(outTotal),
    stockInCount: stockInData.value.length,
    stockOutCount: stockOutData.value.length
  }
})

const attendMonth = ref(new Date())
const attendStats = reactive({
  normal: 0,
  late: 0,
  early: 0,
  absent: 0,
  rate: 0
})

const attendMonthLabel = computed(() => {
  const d = attendMonth.value
  return d.getFullYear() + '年' + (d.getMonth() + 1) + '月'
})

function switchTab(idx) {
  currentTab.value = idx
  if (idx === 1 && stockInData.value.length === 0) loadWmsData()
  if (idx === 2 && attendStats.normal === 0 && attendStats.late === 0) loadAttendData()
}

function selectBizTime(value) {
  bizTimeType.value = value
  if (value === 'today' || value === 'month') {
    loadEnterpriseStats()
  }
}

function formatDateFromTimestamp(ts) {
  const date = new Date(ts)
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function onStartDateConfirm(e) {
  customStartDate.value = formatDateFromTimestamp(e.value)
  showStartDatePicker.value = false
}

function onEndDateConfirm(e) {
  customEndDate.value = formatDateFromTimestamp(e.value)
  showEndDatePicker.value = false
}

function confirmCustomDate() {
  if (!customStartDate.value || !customEndDate.value) {
    uni.showToast({ title: '请选择完整日期范围', icon: 'none' })
    return
  }
  if (customStartDate.value > customEndDate.value) {
    uni.showToast({ title: '开始日期不能大于结束日期', icon: 'none' })
    return
  }
  loadBizDataCustom()
  loadEnterpriseStats()
}

function formatNum(val) {
  const num = parseFloat(val) || 0
  return num.toFixed(0)
}

function getDateRange(type) {
  const now = new Date()
  const y = now.getFullYear()
  const m = now.getMonth()
  const d = now.getDate()
  const pad = n => String(n).padStart(2, '0')
  const today = `${y}-${pad(m + 1)}-${pad(d)}`

  if (type === 'month') {
    const start = `${y}-${pad(m + 1)}-01`
    return { start, end: today }
  }
  if (type === 'quarter') {
    const qStart = new Date(y, m - 2, 1)
    const start = `${qStart.getFullYear()}-${pad(qStart.getMonth() + 1)}-01`
    return { start, end: today }
  }
  return { start: today, end: today }
}

async function loadBizData() {
  try {
    const res = await getTodayStats()
    const data = res.data || res || {}
    const dc = data.dealCustomerCount || {}
    const da = data.dealAmount || {}
    const pa = data.paidAmount || {}
    const oa_field = data.owedAmount || {}
    const ca = data.cashAmount || {}
    const cda = data.cardAmount || {}
    const gc = data.giftCount || {}
    const oc = data.operationCustomerCount || {}
    const oa = data.operationAmount || {}

    bizStats.dealCustomerToday = String(dc.today || 0)
    bizStats.dealCustomerMonth = String(dc.month || 0)
    bizStats.dealAmountToday = formatAmount(da.today || 0)
    bizStats.dealAmountMonth = formatAmount(da.month || 0)
    bizStats.paidAmountToday = formatAmount(pa.today || 0)
    bizStats.paidAmountMonth = formatAmount(pa.month || 0)
    bizStats.owedAmountToday = formatAmount(oa_field.today || 0)
    bizStats.owedAmountMonth = formatAmount(oa_field.month || 0)
    bizStats.cashAmountToday = formatAmount(ca.today || 0)
    bizStats.cashAmountMonth = formatAmount(ca.month || 0)
    bizStats.cardAmountToday = formatAmount(cda.today || 0)
    bizStats.cardAmountMonth = formatAmount(cda.month || 0)
    bizStats.giftCountToday = String(gc.today || 0)
    bizStats.giftCountMonth = String(gc.month || 0)
    bizStats.operationCustomerToday = String(oc.today || 0)
    bizStats.operationCustomerMonth = String(oc.month || 0)
    bizStats.operationAmountToday = formatAmount(oa.today || 0)
    bizStats.operationAmountMonth = formatAmount(oa.month || 0)
  } catch (e) {
    console.error('加载业务统计失败:', e)
  }
}

async function loadBizDataCustom() {
  try {
    const res = await getTodayStats({
      startDate: customStartDate.value,
      endDate: customEndDate.value
    })
    const data = res.data || res || {}
    const dc = data.dealCustomerCount || {}
    const da = data.dealAmount || {}
    const pa = data.paidAmount || {}
    const oa_field = data.owedAmount || {}
    const ca = data.cashAmount || {}
    const cda = data.cardAmount || {}
    const gc = data.giftCount || {}
    const oc = data.operationCustomerCount || {}
    const oa = data.operationAmount || {}

    bizStats.dealCustomerCustom = String(dc.custom || 0)
    bizStats.dealAmountCustom = formatAmount(da.custom || 0)
    bizStats.paidAmountCustom = formatAmount(pa.custom || 0)
    bizStats.owedAmountCustom = formatAmount(oa_field.custom || 0)
    bizStats.cashAmountCustom = formatAmount(ca.custom || 0)
    bizStats.cardAmountCustom = formatAmount(cda.custom || 0)
    bizStats.giftCountCustom = String(gc.custom || 0)
    bizStats.operationCustomerCustom = String(oc.custom || 0)
    bizStats.operationAmountCustom = formatAmount(oa.custom || 0)
  } catch (e) {
    console.error('加载自定义业务统计失败:', e)
  }
}

async function loadEnterpriseStats() {
  let startDate, endDate
  if (bizTimeType.value === 'custom') {
    startDate = customStartDate.value
    endDate = customEndDate.value
    if (!startDate || !endDate) {
      enterpriseStats.value = []
      return
    }
  } else {
    const range = getDateRange(bizTimeType.value)
    startDate = range.start
    endDate = range.end
  }

  try {
    const res = await getEnterpriseStats({ startDate, endDate })
    enterpriseStats.value = res.data || res || []
  } catch (e) {
    console.error('加载企业统计失败:', e)
    enterpriseStats.value = []
  }
}

async function loadWmsData() {
  const range = getDateRange(wmsTimeType.value)
  try {
    const [inRes, outRes, turnRes] = await Promise.all([
      stockInSummary({ stock_in_date_start: range.start, stock_in_date_end: range.end }),
      stockOutSummary({ stock_out_date_start: range.start, stock_out_date_end: range.end }),
      inventoryTurnover({ start_date: range.start, end_date: range.end })
    ])
    stockInData.value = (inRes.data || inRes || [])
    stockOutData.value = (outRes.data || outRes || [])
    turnoverData.value = (turnRes.data || turnRes || [])
  } catch (e) {
    console.error('加载仓储统计失败:', e)
  }
}

function changeWmsTime(type) {
  wmsTimeType.value = type
  loadWmsData()
}

async function loadAttendData() {
  const d = attendMonth.value
  const monthStr = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0')
  try {
    const res = await getMonthStats({ month: monthStr })
    const data = res.data || res || {}
    attendStats.normal = data.normal || 0
    attendStats.late = data.late || 0
    attendStats.early = data.early || 0
    attendStats.absent = data.absent || 0
    const total = data.total || (attendStats.normal + attendStats.late + attendStats.early + attendStats.absent)
    attendStats.rate = total > 0 ? Math.round((attendStats.normal / total) * 100) : 0
  } catch (e) {
    console.error('加载考勤统计失败:', e)
  }
}

function changeMonth(delta) {
  const d = new Date(attendMonth.value)
  d.setMonth(d.getMonth() + delta)
  attendMonth.value = d
  loadAttendData()
}

function formatAmount(value) {
  const num = Number(value) || 0
  return '¥' + Math.round(num)
}

onMounted(() => {
  loadBizData()
  loadEnterpriseStats()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.stats-page { display: flex; flex-direction: column; height: 100%; background: #F5F7FA; padding: 0 24rpx; overflow: hidden; box-sizing: border-box; }

.tab-bar {
  display: flex;
  margin: 24rpx 0 0;
  background: #fff;
  border-radius: 16rpx;
  padding: 8rpx;
  flex-shrink: 0;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.tab-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16rpx 0;
  position: relative;
  &.active .tab-text { color: #3D6DF7; font-weight: 600; }
}
.tab-text { font-size: 28rpx; color: #86909C; }
.tab-indicator {
  position: absolute;
  bottom: 0;
  width: 48rpx;
  height: 6rpx;
  background: #3D6DF7;
  border-radius: 3rpx;
}

.tab-content { padding: 0; flex: 1; overflow: hidden; }

.time-filter {
  display: flex;
  gap: 16rpx;
  margin: 24rpx 0;
}
.time-tag {
  padding: 10rpx 28rpx;
  border-radius: 24rpx;
  font-size: 24rpx;
  color: #4E5969;
  background: #F2F3F5;
  &.active { background: #E8F0FE; color: #3D6DF7; font-weight: 500; }
}

.date-range-picker {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 20rpx;
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

.stat-cards-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  overflow: hidden;
}
.stat-card {
  flex: 1;
  min-width: calc(33.33% - 12rpx);
  box-sizing: border-box;
  background: #fff;
  border-radius: 16rpx;
  padding: 20rpx 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
  display: flex;
  flex-direction: column;
  gap: 6rpx;
  &.blue-card { border-left: 6rpx solid #3D6DF7; }
  &.green-card { border-left: 6rpx solid #00B42A; }
  &.red-card { border-left: 6rpx solid #F53F3F; }
  &.orange-card { border-left: 6rpx solid #FF6B35; }
  &.purple-card { border-left: 6rpx solid #722ED1; }
}
.sc-label { font-size: 22rpx; color: #86909C; }
.sc-value { font-size: 30rpx; font-weight: 700; color: #1D2129; line-height: 1.2; }
.sc-sub { font-size: 22rpx; color: #C9CDD4; }

.section-block {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-top: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.block-title { font-size: 28rpx; font-weight: 600; color: #1D2129; }
.block-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.enterprise-list { display: flex; flex-direction: column; gap: 16rpx; margin-top: 16rpx; }
.enterprise-item {
  padding: 20rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  border-left: 4rpx solid #3D6DF7;
}
.enterprise-header {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 16rpx;
}
.enterprise-name { font-size: 28rpx; font-weight: 600; color: #1D2129; }
.enterprise-stats-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}
.es-item {
  width: calc(33.33% - 8rpx);
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  padding: 10rpx 12rpx;
  background: #fff;
  border-radius: 8rpx;
  box-sizing: border-box;
}
.es-label { font-size: 20rpx; color: #86909C; }
.es-value {
  font-size: 26rpx; font-weight: 700; line-height: 1.2;
  &.blue { color: #3D6DF7; }
  &.orange { color: #FF6B35; }
  &.green { color: #00B42A; }
  &.red { color: #F53F3F; }
  &.purple { color: #722ED1; }
}

.detail-list { display: flex; flex-direction: column; gap: 12rpx; margin-top: 16rpx; }
.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 20rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
}
.detail-left { flex: 1; }
.detail-name { font-size: 26rpx; color: #1D2129; font-weight: 500; }
.detail-right { display: flex; align-items: center; gap: 20rpx; }
.detail-qty { font-size: 24rpx; color: #4E5969; }
.detail-amount { font-size: 26rpx; color: #3D6DF7; font-weight: 600; }

.turnover-item { flex-direction: column; gap: 12rpx; }
.turnover-row { display: flex; gap: 0; width: 100%; }
.turnover-cell {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rpx;
  &.in .turnover-val { color: #3D6DF7; }
  &.out .turnover-val { color: #FF6B35; }
}
.turnover-label { font-size: 22rpx; color: #C9CDD4; }
.turnover-val { font-size: 26rpx; color: #4E5969; font-weight: 500;
  &.end { color: #3D6DF7; font-weight: 600; }
}

.month-selector {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 32rpx;
  margin: 24rpx 0;
}
.month-arrow { width: 56rpx; height: 56rpx; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: #F2F3F5; }
.month-text { font-size: 30rpx; font-weight: 600; color: #1D2129; }

.attend-grid {
  display: flex;
  gap: 16rpx;
  overflow: hidden;
}
.attend-item {
  flex: 1;
  box-sizing: border-box;
  min-width: 0;
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  box-shadow: 0 2rpx 12rpx rgba(61,109,247,0.06);
}
.attend-val { font-size: 40rpx; font-weight: 700; line-height: 1;
  &.green { color: #3D6DF7; }
  &.orange { color: #FF7D00; }
  &.red { color: #F53F3F; }
}
.attend-label { font-size: 24rpx; color: #86909C; }

.progress-bar {
  height: 16rpx;
  background: #F2F3F5;
  border-radius: 8rpx;
  overflow: hidden;
  margin-top: 16rpx;
}
.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3D6DF7, #6B8FF9);
  border-radius: 8rpx;
  transition: width 0.3s ease;
}
.progress-text {
  display: block;
  text-align: right;
  font-size: 28rpx;
  color: #3D6DF7;
  font-weight: 600;
  margin-top: 8rpx;
}

.empty-block { padding: 32rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }
.bottom-spacer { height: 40rpx; }
</style>
