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

    <el-card class="stats-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span class="card-title">数据概览</span>
          <div class="date-filter">
            <el-radio-group v-model="dateRange" size="small" @change="handleDateRangeChange">
              <el-radio-button label="today">今日</el-radio-button>
              <el-radio-button label="week">本周</el-radio-button>
              <el-radio-button label="month">本月</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col :xs="12" :sm="8" :md="6" v-for="item in statsItems" :key="item.key">
          <div class="stat-item">
            <div class="stat-label">{{ item.label }}</div>
            <div class="stat-value primary">{{ item.isAmount ? formatMoney(item.todayValue) : item.todayValue }}</div>
            <div class="stat-sub">本月: {{ item.isAmount ? formatMoney(item.monthValue) : item.monthValue }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="20" class="middle-row">
      <el-col :sm="24" :lg="16">
        <el-card class="rank-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="card-title">企业业绩排行</span>
            </div>
          </template>
          <el-table :data="enterpriseList" stripe size="small" :max-height="360" v-loading="rankLoading">
            <el-table-column label="排名" width="60" align="center">
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
        <el-table-column label="类型" width="80" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="sourceTypeTag(row.sourceType)">{{ sourceTypeLabel(row.sourceType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operatorName" label="操作人" width="90" show-overflow-tooltip />
        <el-table-column prop="archiveDate" label="时间" width="110" />
      </el-table>
    </el-card>

    <notice-detail-view ref="noticeViewRef" />
  </div>
</template>

<script setup name="Index">
import { ref, onMounted } from 'vue'
import { listNoticeTop, markNoticeRead } from '@/api/system/notice'
import { getTodayStats, getEnterpriseStats, listArchive } from '@/api/home'
import NoticeDetailView from '@/layout/components/HeaderNotice/DetailView'

const noticeList = ref([])
const unreadCount = ref(0)
const dateRange = ref('today')
const statsItems = ref([])
const enterpriseList = ref([])
const recentList = ref([])
const statsLoading = ref(false)
const rankLoading = ref(false)
const recentLoading = ref(false)
const { proxy } = getCurrentInstance()

const shortcuts = [
  { name: '销售开单', icon: 'DocumentAdd', bgColor: '#3D6DF7', path: '/business/sales' },
  { name: '订单管理', icon: 'List', bgColor: '#F59E0B', path: '/business/order' },
  { name: '企业管理', icon: 'OfficeBuilding', bgColor: '#FF6B35', path: '/business/enterprise' },
  { name: '行程安排', icon: 'MapLocation', bgColor: '#52c41a', path: '/business/schedule' },
  { name: '方案管理', icon: 'Tickets', bgColor: '#8B5CF6', path: '/business/plan' },
  { name: '供货商管理', icon: 'Van', bgColor: '#3D6DF7', path: '/wms/supplier' }
]

onMounted(() => {
  loadNoticeTop()
  loadStats()
  loadEnterpriseRank()
  loadRecentList()
})

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
}

function getDateParams() {
  const now = new Date()
  let startDate, endDate
  const fmt = (d) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`
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

    statsItems.value = [
      { key: 'dealCustomer', label: '成交客数', todayValue: dealCustomer.today || 0, monthValue: dealCustomer.month || 0, isAmount: false },
      { key: 'dealAmount', label: '成交金额', todayValue: dealAmount.today || 0, monthValue: dealAmount.month || 0, isAmount: true },
      { key: 'paidAmount', label: '实付金额', todayValue: paidAmount.today || 0, monthValue: paidAmount.month || 0, isAmount: true },
      { key: 'owedAmount', label: '欠款金额', todayValue: owedAmount.today || 0, monthValue: owedAmount.month || 0, isAmount: true },
      { key: 'cashAmount', label: '现金金额', todayValue: cashAmount.today || 0, monthValue: cashAmount.month || 0, isAmount: true },
      { key: 'cardAmount', label: '耗卡金额', todayValue: cardAmount.today || 0, monthValue: cardAmount.month || 0, isAmount: true },
      { key: 'giftCount', label: '赠送次数', todayValue: giftCount.today || 0, monthValue: giftCount.month || 0, isAmount: false },
      { key: 'operationCustomer', label: '操作客数', todayValue: operationCustomer.today || 0, monthValue: operationCustomer.month || 0, isAmount: false }
    ]
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
  margin-bottom: 16px;
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

.stats-card {
  margin-bottom: 16px;
}
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
.stat-item {
  padding: 16px 12px;
  border-radius: 8px;
  background: var(--el-bg-color);
  margin-bottom: 12px;
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

.middle-row {
  margin-bottom: 16px;
}
.rank-card {
  margin-bottom: 16px;
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

.shortcut-card {
  margin-bottom: 16px;
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

.recent-card {
  margin-bottom: 16px;
}
</style>
