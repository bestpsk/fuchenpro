<template>
  <div class="app-container home">
    <el-card v-if="noticeList.length > 0" class="notice-card" shadow="hover">
      <div class="notice-bar">
        <div class="notice-bar-left">
          <el-icon :size="18" color="#E6A23C"><Bell /></el-icon>
          <span class="notice-bar-label">通知公告</span>
        </div>
        <div class="notice-bar-content">
          <el-carousel v-if="noticeList.length > 1" height="32px" direction="vertical" :autoplay="true" :interval="3000" indicator-position="none">
            <el-carousel-item v-for="item in noticeList" :key="item.noticeId">
              <div class="notice-item" @click="previewNotice(item)">
                <el-tag size="small" :type="item.noticeType === '1' ? 'warning' : 'success'" class="notice-tag">{{ item.noticeType === '1' ? '通知' : '公告' }}</el-tag>
                <span class="notice-item-title" :class="{ 'is-read': item.isRead }">{{ item.noticeTitle }}</span>
              </div>
            </el-carousel-item>
          </el-carousel>
          <div v-else class="notice-item" @click="previewNotice(noticeList[0])">
            <el-tag size="small" :type="noticeList[0].noticeType === '1' ? 'warning' : 'success'" class="notice-tag">{{ noticeList[0].noticeType === '1' ? '通知' : '公告' }}</el-tag>
            <span class="notice-item-title" :class="{ 'is-read': noticeList[0].isRead }">{{ noticeList[0].noticeTitle }}</span>
          </div>
        </div>
        <div class="notice-bar-right">
          <el-badge v-if="unreadCount > 0" :value="unreadCount" :max="99" class="notice-badge" />
          <el-button link type="primary" @click="goNoticePage">更多</el-button>
        </div>
      </div>
    </el-card>

    <el-card class="stats-card" shadow="hover" v-loading="statsLoading">
      <template #header>
        <div class="card-header">
          <span class="card-title">数据概览</span>
          <div class="date-filter">
            <el-radio-group v-model="dateRange" size="small" @change="handleDateRangeChange">
              <el-radio-button label="today">今日</el-radio-button>
              <el-radio-button label="week">本周</el-radio-button>
              <el-radio-button label="month">本月</el-radio-button>
              <el-radio-button label="custom">自定义</el-radio-button>
            </el-radio-group>
            <el-date-picker
              v-if="dateRange === 'custom'"
              v-model="customDateRange"
              type="daterange"
              range-separator="~"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              size="small"
              style="width: 220px"
              @change="handleCustomDateChange"
            />
          </div>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col :xs="12" :sm="8" :md="6" v-for="item in statsItems" :key="item.key">
          <div class="stat-item">
            <div class="stat-label">{{ item.label }}</div>
            <div class="stat-value primary">{{ item.isAmount ? formatMoney(item.todayValue) : item.todayValue }}</div>
            <div class="stat-sub">{{ item.subLabel }}: {{ item.isAmount ? formatMoney(item.monthValue) : item.monthValue }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="20" class="todo-row">
      <el-col :sm="24" :lg="8">
        <el-card class="todo-card" shadow="hover" v-loading="todoLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">待办事项</span>
            </div>
          </template>
          <div class="todo-list">
            <div v-for="item in todoItems" :key="item.key" class="todo-item" @click="goShortcut(item.path)">
              <div class="todo-info">
                <span class="todo-label">{{ item.label }}</span>
              </div>
              <div class="todo-right">
                <span :class="['todo-count', item.count > 0 ? 'has-pending' : '']">{{ item.count }}</span>
                <el-icon><ArrowRight /></el-icon>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :sm="24" :lg="16">
        <el-card class="trend-card" shadow="hover" v-loading="trendLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">{{ trendCardTitle }}</span>
            </div>
          </template>
          <div ref="trendChartRef" class="trend-chart"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="middle-row">
      <el-col :sm="24" :lg="16">
        <el-card class="rank-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="card-title">企业业绩排行</span>
            </div>
          </template>
          <el-table :data="enterpriseList" stripe size="small" :max-height="360" v-loading="rankLoading">
            <el-table-column label="排名" min-width="60" align="center">
              <template #default="{ $index }">
                <span :class="['rank-num', $index < 3 ? 'rank-top' : '']">{{ $index + 1 }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="enterpriseName" label="企业名称" min-width="120" show-overflow-tooltip />
            <el-table-column label="成交金额" min-width="100" align="right">
              <template #default="{ row }">
                <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="实付金额" min-width="100" align="right">
              <template #default="{ row }">
                <span class="amount-blue">{{ formatMoney(row.paidAmount) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="欠款金额" min-width="100" align="right">
              <template #default="{ row }">
                <span :class="row.owedAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.owedAmount) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="现金金额" min-width="100" align="right">
              <template #default="{ row }">
                <span class="amount-blue">{{ formatMoney(row.cashAmount) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="耗卡金额" min-width="100" align="right">
              <template #default="{ row }">
                <span class="amount-blue">{{ formatMoney(row.cardAmount) }}</span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :sm="24" :lg="8">
        <el-card class="shortcut-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="card-title">快捷入口</span>
            </div>
          </template>
          <div class="shortcut-grid">
            <div class="shortcut-item" v-for="item in shortcuts" :key="item.name" @click="goShortcut(item.path)">
              <div class="shortcut-icon" :style="{ background: item.bgColor }">
                <el-icon :size="22" color="#fff"><component :is="item.icon" /></el-icon>
              </div>
              <span class="shortcut-name">{{ item.name }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="recent-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span class="card-title">最近动态</span>
          <el-button link type="primary" @click="$router.push('/business/sales')">更多</el-button>
        </div>
      </template>
      <el-table :data="recentList" stripe size="small" v-loading="recentLoading">
        <el-table-column prop="customerName" label="客户名称" min-width="120" show-overflow-tooltip />
        <el-table-column prop="storeName" label="门店" min-width="100" show-overflow-tooltip />
        <el-table-column label="金额" min-width="100" align="right">
          <template #default="{ row }">
            <span class="amount-blue">{{ formatMoney(row.amount) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="类型" min-width="80" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="sourceTypeTag(row.sourceType)">{{ sourceTypeLabel(row.sourceType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operatorName" label="操作人" min-width="90" show-overflow-tooltip />
        <el-table-column prop="archiveDate" label="时间" min-width="110" />
      </el-table>
    </el-card>

    <notice-detail-view ref="noticeViewRef" />
  </div>
</template>

<script setup name="Index">
import { ref, onMounted, onActivated, nextTick, onBeforeUnmount, computed, getCurrentInstance } from 'vue'
import * as echarts from 'echarts'
import { listNoticeTop, markNoticeRead } from '@/api/system/notice'
import { getTodayStats, getEnterpriseStats, listArchive, getTodoItems, getSalesTrend } from '@/api/home'
import NoticeDetailView from '@/layout/components/HeaderNotice/DetailView'

const noticeList = ref([])
const unreadCount = ref(0)
const dateRange = ref('today')
const customDateRange = ref([])
const statsItems = ref([])
const enterpriseList = ref([])
const recentList = ref([])
const todoItems = ref([])
const statsLoading = ref(false)
const rankLoading = ref(false)
const recentLoading = ref(false)
const todoLoading = ref(false)
const trendLoading = ref(false)
const trendChartRef = ref(null)
let trendChart = null
const isFirstActivate = ref(true)
const { proxy } = getCurrentInstance()

const trendCardTitle = computed(() => {
  const titleMap = {
    today: '今日销售趋势',
    week: '本周销售趋势',
    month: '本月销售趋势',
    custom: '销售趋势'
  }
  return titleMap[dateRange.value] || '销售趋势'
})

const shortcuts = [
  { name: '销售开单', icon: 'DocumentAdd', bgColor: '#3D6DF7', path: '/business/sales' },
  { name: '订单管理', icon: 'List', bgColor: '#5B85F9', path: '/business/order' },
  { name: '企业管理', icon: 'OfficeBuilding', bgColor: '#3D6DF7', path: '/business/enterprise' },
  { name: '行程安排', icon: 'MapLocation', bgColor: '#5B85F9', path: '/business/schedule' },
  { name: '方案管理', icon: 'Tickets', bgColor: '#3D6DF7', path: '/business/plan' },
  { name: '供货商管理', icon: 'Van', bgColor: '#5B85F9', path: '/wms/supplier' }
]

onMounted(() => {
  loadNoticeTop()
  loadStats()
  loadEnterpriseRank()
  loadRecentList()
  loadTodoItems()
  loadSalesTrend()
  window.addEventListener('resize', handleResize)
})

onActivated(() => {
  // 首次挂载时 onMounted 已加载全部数据，跳过避免重复请求
  if (isFirstActivate.value) {
    isFirstActivate.value = false
    return
  }
  // 后续重新进入首页时刷新所有模块，确保业务流衔接（开单后返回首页数据同步）
  loadNoticeTop()
  loadStats()
  loadEnterpriseRank()
  loadRecentList()
  loadTodoItems()
  loadSalesTrend()
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  if (trendChart) {
    trendChart.dispose()
    trendChart = null
  }
})

function loadTodoItems() {
  todoLoading.value = true
  getTodoItems().then(res => {
    todoItems.value = res.data || res || []
  }).catch(() => {
    todoItems.value = []
  }).finally(() => {
    todoLoading.value = false
  })
}

function loadSalesTrend() {
  trendLoading.value = true
  const params = getDateParams()
  getSalesTrend(params).then(res => {
    const data = res.data || res || {}
    nextTick(() => {
      renderTrendChart(data)
    })
  }).catch(() => {
  }).finally(() => {
    trendLoading.value = false
  })
}

function renderTrendChart(data) {
  if (!trendChartRef.value) return
  if (!trendChart) {
    trendChart = echarts.init(trendChartRef.value)
  }
  const dates = data.dates || []
  const amounts = data.amounts || []
  const orderCounts = data.orderCounts || []
  const shortDates = dates.map(d => d.substring(5))
  const singlePoint = dates.length <= 1

  trendChart.setOption({
    tooltip: {
      trigger: 'axis',
      formatter: (params) => {
        let html = params[0].axisValue + '<br/>'
        params.forEach(p => {
          const val = p.seriesName === '销售额' ? '¥' + Number(p.value).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : p.value + ' 单'
          html += p.marker + p.seriesName + ': ' + val + '<br/>'
        })
        return html
      }
    },
    legend: {
      data: ['销售额', '订单数'],
      bottom: 0,
      textStyle: { fontSize: 12 }
    },
    grid: { left: '3%', right: singlePoint ? '4%' : '8%', bottom: '12%', top: '12%', containLabel: true },
    xAxis: { type: 'category', data: shortDates, boundaryGap: singlePoint },
    yAxis: [
      { type: 'value', name: '销售额', axisLabel: { formatter: '{value}' } },
      {
        type: 'value',
        name: singlePoint ? '' : '订单数',
        splitLine: { show: false },
        axisLine: { show: !singlePoint },
        axisTick: { show: !singlePoint },
        axisLabel: { show: !singlePoint }
      }
    ],
    series: [
      {
        name: '销售额',
        type: 'line',
        smooth: true,
        data: amounts,
        itemStyle: { color: '#3D6DF7' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(61,109,247,0.3)' }, { offset: 1, color: 'rgba(61,109,247,0.02)' }]) },
        yAxisIndex: 0
      },
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: orderCounts,
        itemStyle: { color: '#FF6B35' },
        yAxisIndex: 1
      }
    ]
  })
}

function handleResize() {
  if (trendChart) trendChart.resize()
}

function loadNoticeTop() {
  listNoticeTop().then(res => {
    const list = Array.isArray(res.data?.list) ? res.data.list
               : Array.isArray(res.list) ? res.list
               : (Array.isArray(res.data) ? res.data : [])
    noticeList.value = list
    unreadCount.value = res.data?.unreadCount ?? res.unreadCount ?? list.filter(n => !n.isRead).length
  })
}

function previewNotice(item) {
  if (!item.isRead) {
    markNoticeRead(item.noticeId).catch(() => {})
    const idx = noticeList.value.indexOf(item)
    if (idx !== -1) noticeList.value[idx] = { ...item, isRead: true }
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  }
  proxy.$refs["noticeViewRef"]?.open(item.noticeId)
}

function goNoticePage() {
  proxy.$router.push('/system/notice')
}

function handleDateRangeChange(val) {
  loadStats()
  loadEnterpriseRank()
  loadSalesTrend()
}

function handleCustomDateChange() {
  if (dateRange.value === 'custom' && customDateRange.value && customDateRange.value.length === 2) {
    loadStats()
    loadEnterpriseRank()
    loadSalesTrend()
  }
}

function getDateParams() {
  const now = new Date()
  let startDate, endDate
  const fmt = (d) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`

  if (dateRange.value === 'custom') {
    if (customDateRange.value && customDateRange.value.length === 2) {
      startDate = customDateRange.value[0]
      endDate = customDateRange.value[1]
    } else {
      endDate = fmt(now)
      startDate = endDate
    }
  } else {
    endDate = fmt(now)
    if (dateRange.value === 'today') {
      startDate = endDate
    } else if (dateRange.value === 'week') {
      const day = now.getDay() || 7
      const monday = new Date(now)
      monday.setDate(now.getDate() - day + 1)
      startDate = fmt(monday)
    } else if (dateRange.value === 'month') {
      startDate = fmt(new Date(now.getFullYear(), now.getMonth(), 1))
    }
  }
  return { startDate, endDate }
}

function loadStats() {
  statsLoading.value = true
  const params = getDateParams()
  getTodayStats(params).then(res => {
    const stats = res.data || res || {}
    const dealCustomer = stats.dealCustomerCount || {}
    const dealAmount = stats.dealAmount || {}
    const paidAmount = stats.paidAmount || {}
    const owedAmount = stats.owedAmount || {}
    const cashAmount = stats.cashAmount || {}
    const cardAmount = stats.cardAmount || {}
    const giftCount = stats.giftCount || {}
    const operationCustomer = stats.operationCustomerCount || {}

    // 主值来源：today 用 today，其他用 custom
    const mainKey = dateRange.value === 'today' ? 'today' : 'custom'
    const subKey = dateRange.value === 'month' ? 'year' : 'month'
    const subLabel = dateRange.value === 'month' ? '本年' : '本月'

    statsItems.value = [
      { key: 'dealCustomer', label: '成交客数', subLabel, todayValue: dealCustomer[mainKey] ?? dealCustomer.today ?? 0, monthValue: dealCustomer[subKey] || 0, isAmount: false },
      { key: 'dealAmount', label: '成交金额', subLabel, todayValue: dealAmount[mainKey] ?? dealAmount.today ?? 0, monthValue: dealAmount[subKey] || 0, isAmount: true },
      { key: 'paidAmount', label: '实付金额', subLabel, todayValue: paidAmount[mainKey] ?? paidAmount.today ?? 0, monthValue: paidAmount[subKey] || 0, isAmount: true },
      { key: 'owedAmount', label: '欠款金额', subLabel, todayValue: owedAmount[mainKey] ?? owedAmount.today ?? 0, monthValue: owedAmount[subKey] || 0, isAmount: true },
      { key: 'cashAmount', label: '现金金额', subLabel, todayValue: cashAmount[mainKey] ?? cashAmount.today ?? 0, monthValue: cashAmount[subKey] || 0, isAmount: true },
      { key: 'cardAmount', label: '耗卡金额', subLabel, todayValue: cardAmount[mainKey] ?? cardAmount.today ?? 0, monthValue: cardAmount[subKey] || 0, isAmount: true },
      { key: 'giftCount', label: '赠送次数', subLabel, todayValue: giftCount[mainKey] ?? giftCount.today ?? 0, monthValue: giftCount[subKey] || 0, isAmount: false },
      { key: 'operationCustomer', label: '操作客数', subLabel, todayValue: operationCustomer[mainKey] ?? operationCustomer.today ?? 0, monthValue: operationCustomer[subKey] || 0, isAmount: false }
    ]
  }).catch(() => {
    statsItems.value = []
  }).finally(() => {
    statsLoading.value = false
  })
}

function loadEnterpriseRank() {
  rankLoading.value = true
  const params = getDateParams()
  getEnterpriseStats(params).then(res => {
    enterpriseList.value = (res.data || res || []).slice(0, 10)
  }).catch((err) => {
    console.error('加载企业排行失败:', err)
    enterpriseList.value = []
  }).finally(() => {
    rankLoading.value = false
  })
}

function loadRecentList() {
  recentLoading.value = true
  listArchive({
    pageNum: 1,
    pageSize: 10,
    orderByColumn: 'archive_date',
    isAsc: 'desc'
  }).then(res => {
    const rows = res.rows || []
    recentList.value = rows.filter(item => {
      const st = item.sourceType || item.source_type
      return st !== '3'
    }).slice(0, 10).map(item => ({
      archiveId: item.archiveId || item.archive_id,
      customerName: item.customerName || item.customer_name || '',
      storeName: [item.enterpriseName || item.enterprise_name, item.storeName || item.store_name].filter(Boolean).join('·'),
      amount: item.amount || 0,
      sourceType: item.sourceType || item.source_type,
      operatorName: item.operatorUserName || item.operator_user_name || '',
      archiveDate: (item.archiveDate || item.archive_date || item.createTime || '').substring(0, 10)
    }))
  }).catch(() => {
    recentList.value = []
  }).finally(() => {
    recentLoading.value = false
  })
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function sourceTypeLabel(type) {
  const map = { '0': '开单', '1': '操作', '2': '还款', '3': '手动' }
  return map[type] || '未知'
}

function sourceTypeTag(type) {
  const map = { '0': '', '1': 'success', '2': 'warning', '3': 'info' }
  return map[type] || 'info'
}

function goShortcut(path) {
  if (path) {
    proxy.$router.push(path)
  }
}
</script>

<style scoped lang="scss">
.notice-card {
  :deep(.el-card__body) { padding: 0; }
}
.notice-bar {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  gap: 16px;
}
.notice-bar-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}
.notice-bar-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}
.notice-bar-content {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}
.notice-item {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 32px;
  cursor: pointer;
  &:hover .notice-item-title { color: var(--el-color-primary); }
}
.notice-tag { flex-shrink: 0; }
.notice-item-title {
  font-size: 13px;
  color: #333;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  &.is-read { color: #999; opacity: 0.7; }
}
.notice-bar-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
.notice-badge { :deep(.el-badge__content) { top: -2px; } }

.notice-card,
.stats-card,
.todo-card,
.trend-card,
.rank-card,
.shortcut-card,
.recent-card {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
}
.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  flex-shrink: 0;
}
.date-filter {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}
.stat-item {
  padding: 16px 12px 16px 10px;
  border-radius: 8px;
  background: var(--el-bg-color);
  margin-bottom: 12px;
  border-left: 4px solid #3D6DF7;
  transition: box-shadow 0.2s;
  &:hover {
    box-shadow: 0 2px 8px rgba(61, 109, 247, 0.12);
  }
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 8px;
}
.stat-value {
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 4px;
  &.primary { color: #3D6DF7; }
}
.stat-sub {
  font-size: 12px;
  color: #c0c4cc;
}

.todo-row,
.middle-row {
  .el-col {
    display: flex;
  }
}

.todo-card,
.trend-card,
.rank-card,
.shortcut-card {
  flex: 1;
  min-height: 360px;
  display: flex;
  flex-direction: column;
}

.todo-card,
.rank-card,
.shortcut-card {
  :deep(.el-card__body) {
    flex: 1;
  }
}

.todo-card {
  :deep(.el-card__body) { padding: 0; }
}

.todo-list {
  display: flex;
  flex-direction: column;
  min-height: 308px;
}
.todo-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
  transition: background 0.2s;
  &:last-child { border-bottom: none; }
  &:hover { background: #f8f9fa; }
}
.todo-info {
  display: flex;
  align-items: center;
  gap: 8px;
}
.todo-label {
  font-size: 14px;
  color: #303133;
}
.todo-right {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #c0c4cc;
}
.todo-count {
  font-size: 18px;
  font-weight: 700;
  color: #909399;
  min-width: 24px;
  text-align: right;
  &.has-pending {
    color: #f56c6c;
  }
}

.trend-chart {
  width: 100%;
  height: 320px;
}
.rank-num {
  font-weight: 600;
  color: #909399;
}
.rank-top {
  color: #3D6DF7;
  font-size: 15px;
}
.amount-blue {
  color: #3D6DF7;
  font-weight: 500;
}
.amount-red {
  color: #f56c6c;
  font-weight: 500;
}
.amount-gray {
  color: #c0c4cc;
}

.shortcut-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 8px 0;
}
.shortcut-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  &:hover .shortcut-icon {
    transform: scale(1.08);
  }
}
.shortcut-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s;
}
.shortcut-name {
  font-size: 13px;
  color: #606266;
}

</style>
