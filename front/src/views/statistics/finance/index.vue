<template>
  <div class="app-container" v-hasPermi="['statistics:finance:list']">
    <!-- 统一筛选区 -->
    <el-card class="filter-card" shadow="never">
      <el-form :inline="true" size="default">
        <el-form-item label="企业">
          <el-select v-model="filter.enterprise_id" placeholder="全部企业" clearable filterable style="width: 180px" @change="handleFilterChange">
            <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
          </el-select>
        </el-form-item>
        <el-form-item label="门店">
          <el-select v-model="filter.store_id" placeholder="全部门店" clearable filterable style="width: 180px" @change="handleFilterChange">
            <el-option v-for="item in storeOptions" :key="item.storeId" :label="item.storeName" :value="item.storeId" />
          </el-select>
        </el-form-item>
        <el-form-item label="业务员">
          <el-select v-model="filter.creator_user_id" placeholder="全部业务员" clearable filterable style="width: 160px" @change="handleFilterChange">
            <el-option v-for="item in userOptions" :key="item.userId" :label="item.nickName || item.userName" :value="item.userId" />
          </el-select>
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" @change="handleFilterChange" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="loadCurrentTab">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-tabs v-model="activeTab" @tab-change="handleTabChange" style="margin-top: 12px">
      <el-tab-pane label="应收账款" name="receivable">
        <div style="margin-bottom: 12px">
          <el-button type="warning" plain icon="Download" @click="handleExportReceivable">导出</el-button>
        </div>
        <el-table :data="receivableList" border v-loading="receivableLoading" show-summary :summary-method="getReceivableSummary">
          <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
          <el-table-column label="门店名称" prop="storeName" min-width="120" show-overflow-tooltip />
          <el-table-column label="业务员" prop="creatorUserName" min-width="100" show-overflow-tooltip />
          <el-table-column label="成交金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实付金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-green">{{ formatMoney(row.paidAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="120" align="right">
            <template #default="{ row }">
              <span :class="row.owedAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.owedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="订单数" prop="orderCount" min-width="80" align="center" />
          <el-table-column label="最后下单时间" prop="lastOrderTime" min-width="160" />
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="账龄分析" name="aging">
        <el-row :gutter="16" style="margin-bottom: 16px">
          <el-col :xs="12" :sm="6" v-for="item in agingSummary" :key="item.range">
            <div class="aging-card" :class="item.class">
              <div class="aging-range">{{ item.range }}</div>
              <div class="aging-count">{{ item.count }} 笔</div>
              <div class="aging-amount">{{ formatMoney(item.amount) }}</div>
            </div>
          </el-col>
        </el-row>
        <el-table :data="agingList" border v-loading="agingLoading" max-height="500">
          <el-table-column label="订单编号" prop="orderNo" min-width="140" show-overflow-tooltip />
          <el-table-column label="客户名称" prop="customerName" min-width="120" show-overflow-tooltip />
          <el-table-column label="企业名称" prop="enterpriseName" min-width="120" show-overflow-tooltip />
          <el-table-column label="门店名称" prop="storeName" min-width="100" show-overflow-tooltip />
          <el-table-column label="业务员" prop="creatorUserName" min-width="90" show-overflow-tooltip />
          <el-table-column label="成交金额" min-width="100" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="已付金额" min-width="100" align="right">
            <template #default="{ row }">
              <span class="amount-green">{{ formatMoney(row.paidAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="100" align="right">
            <template #default="{ row }">
              <span class="amount-red">{{ formatMoney(row.owedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="下单时间" prop="createTime" min-width="150" />
          <el-table-column label="账龄天数" min-width="90" align="center">
            <template #default="{ row }">
              <span :class="getAgingClass(row.agingDays)">{{ row.agingDays }} 天</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="支付方式" name="payment">
        <el-row :gutter="16">
          <el-col :sm="24" :lg="10">
            <div ref="paymentChartRef" class="chart-container" v-loading="paymentLoading"></div>
          </el-col>
          <el-col :sm="24" :lg="14">
            <el-table :data="paymentList" border style="margin-top: 12px">
              <el-table-column label="支付方式" min-width="100">
                <template #default="{ row }">
                  <el-tag :type="getPaymentTagType(row.method)" effect="dark">{{ row.label }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="成交金额" min-width="120" align="right">
                <template #default="{ row }">
                  <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="实付金额" min-width="120" align="right">
                <template #default="{ row }">
                  <span class="amount-green">{{ formatMoney(row.paidAmount) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="订单明细数" prop="itemCount" min-width="100" align="center" />
              <el-table-column label="占比" min-width="90" align="center">
                <template #default="{ row }">
                  <span class="amount-blue">{{ row.rate }}%</span>
                </template>
              </el-table-column>
            </el-table>
          </el-col>
        </el-row>
      </el-tab-pane>

      <el-tab-pane label="回款率" name="collection">
        <el-row :gutter="16" style="margin-bottom: 16px">
          <el-col :xs="12" :sm="8">
            <div class="rate-card">
              <div class="rate-label">总成交金额</div>
              <div class="rate-value amount-blue">{{ formatMoney(collectionTotal.dealAmount) }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="8">
            <div class="rate-card">
              <div class="rate-label">总实付金额</div>
              <div class="rate-value amount-green">{{ formatMoney(collectionTotal.paidAmount) }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="8">
            <div class="rate-card">
              <div class="rate-label">综合回款率</div>
              <div class="rate-value" :class="getRateClass(collectionTotal.collectionRate)">{{ collectionTotal.collectionRate }}%</div>
            </div>
          </el-col>
        </el-row>
        <el-table :data="collectionList" border v-loading="collectionLoading">
          <el-table-column label="排名" min-width="60" align="center">
            <template #default="{ $index }">
              <span :class="$index < 3 ? 'rank-top' : ''">{{ $index + 1 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
          <el-table-column label="成交金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实付金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-green">{{ formatMoney(row.paidAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="120" align="right">
            <template #default="{ row }">
              <span :class="row.owedAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.owedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="订单数" prop="orderCount" min-width="80" align="center" />
          <el-table-column label="回款率" min-width="120" align="center">
            <template #default="{ row }">
              <el-progress :percentage="Math.min(row.collectionRate, 100)" :color="getProgressColor(row.collectionRate)" :stroke-width="14" :text-inside="true">
                {{ row.collectionRate }}%
              </el-progress>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="FinanceStats">
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { receivableStats, agingAnalysis, paymentMethodStats, collectionRate } from '@/api/statistics/finance'
import { listEnterprise } from '@/api/business/enterprise'
import { listUser } from '@/api/system/user'

const { proxy } = getCurrentInstance()
const activeTab = ref('receivable')

// 筛选条件
const filter = ref({
  enterprise_id: '',
  store_id: '',
  creator_user_id: ''
})
const dateRange = ref([])
const enterpriseOptions = ref([])
const storeOptions = ref([])
const userOptions = ref([])

// 应收账款
const receivableList = ref([])
const receivableLoading = ref(false)

// 账龄分析
const agingList = ref([])
const agingLoading = ref(false)
const agingSummary = ref([])

// 支付方式
const paymentChartRef = ref(null)
let paymentChart = null
const paymentLoading = ref(false)
const paymentList = ref([])

// 回款率
const collectionList = ref([])
const collectionLoading = ref(false)
const collectionTotal = ref({ dealAmount: 0, paidAmount: 0, owedAmount: 0, collectionRate: 0 })

onMounted(() => {
  loadFilterOptions()
  loadReceivable()
})

onBeforeUnmount(() => {
  if (paymentChart) { paymentChart.dispose(); paymentChart = null }
})

// 加载筛选下拉选项
function loadFilterOptions() {
  listEnterprise({ pageNum: 1, pageSize: 9999 }).then(res => {
    enterpriseOptions.value = res.rows || res.data?.rows || []
  }).catch(() => {})
  listUser({ pageNum: 1, pageSize: 9999 }).then(res => {
    userOptions.value = res.rows || res.data?.rows || []
  }).catch(() => {})
}

function getFilterParams() {
  const params = { ...filter.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  return params
}

function handleFilterChange() {
  loadCurrentTab()
}

function handleTabChange(tab) {
  if (tab === 'receivable') loadReceivable()
  else if (tab === 'aging') loadAging()
  else if (tab === 'payment') loadPayment()
  else if (tab === 'collection') loadCollection()
}

function loadCurrentTab() {
  if (activeTab.value === 'receivable') loadReceivable()
  else if (activeTab.value === 'aging') loadAging()
  else if (activeTab.value === 'payment') loadPayment()
  else if (activeTab.value === 'collection') loadCollection()
}

// 应收账款
function loadReceivable() {
  receivableLoading.value = true
  receivableStats(getFilterParams()).then(res => {
    const data = res.data || res || {}
    receivableList.value = data.list || []
  }).finally(() => {
    receivableLoading.value = false
  })
}

function getReceivableSummary({ columns, data }) {
  const sums = []
  columns.forEach((column, index) => {
    if (index === 0) { sums[index] = '合计'; return }
    const fields = ['dealAmount', 'paidAmount', 'owedAmount', 'orderCount']
    if (fields.includes(column.property)) {
      const values = data.map(item => Number(item[column.property]))
      const sum = values.reduce((prev, curr) => prev + curr, 0)
      sums[index] = column.property === 'orderCount' ? sum : formatMoney(sum)
    } else {
      sums[index] = ''
    }
  })
  return sums
}

function handleExportReceivable() {
  proxy.download('statistics/finance/exportReceivable', getFilterParams(), `应收账款明细_${new Date().getTime()}.xlsx`)
}

// 账龄分析
function loadAging() {
  agingLoading.value = true
  agingAnalysis(getFilterParams()).then(res => {
    const data = res.data || res || {}
    agingList.value = data.list || []
    const dist = data.distribution || []
    agingSummary.value = dist.map((item, idx) => ({
      ...item,
      class: ['aging-normal', 'aging-warning', 'aging-danger', 'aging-critical'][idx] || ''
    }))
  }).finally(() => {
    agingLoading.value = false
  })
}

function getAgingClass(days) {
  if (days >= 90) return 'amount-red'
  if (days >= 60) return 'amount-orange'
  if (days >= 30) return 'amount-yellow'
  return 'amount-green'
}

// 支付方式
function loadPayment() {
  paymentLoading.value = true
  paymentMethodStats(getFilterParams()).then(res => {
    const data = res.data || res || {}
    paymentList.value = data.list || []
    nextTick(() => renderPaymentChart(paymentList.value))
  }).finally(() => {
    paymentLoading.value = false
  })
}

function renderPaymentChart(data) {
  if (!paymentChartRef.value) return
  if (!paymentChart) {
    paymentChart = echarts.init(paymentChartRef.value)
  }
  const colors = { cash: '#3D6DF7', card: '#FF6B35', gift: '#909399' }
  paymentChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
    legend: { bottom: 0, textStyle: { fontSize: 12 } },
    series: [{
      name: '支付方式占比',
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['50%', '45%'],
      data: data.map(item => ({
        value: item.dealAmount,
        name: item.label,
        itemStyle: { color: colors[item.method] || '#909399' }
      })),
      label: { formatter: '{b}\n¥{c}' },
      emphasis: { itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.5)' } }
    }]
  })
}

function getPaymentTagType(method) {
  if (method === 'cash') return 'primary'
  if (method === 'card') return 'warning'
  if (method === 'gift') return 'info'
  return ''
}

// 回款率
function loadCollection() {
  collectionLoading.value = true
  collectionRate(getFilterParams()).then(res => {
    const data = res.data || res || {}
    collectionList.value = data.list || []
    collectionTotal.value = data.total || { dealAmount: 0, paidAmount: 0, owedAmount: 0, collectionRate: 0 }
  }).finally(() => {
    collectionLoading.value = false
  })
}

function getRateClass(rate) {
  if (rate >= 80) return 'amount-green'
  if (rate >= 50) return 'amount-orange'
  return 'amount-red'
}

function getProgressColor(rate) {
  if (rate >= 80) return '#52c41a'
  if (rate >= 50) return '#e6a23c'
  return '#f56c6c'
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<style scoped lang="scss">
.filter-card {
  margin-bottom: 12px;
  :deep(.el-card__body) { padding: 12px 16px 0; }
}
.chart-container {
  width: 100%;
  height: 400px;
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: var(--el-bg-color);
}
.amount-blue { color: #3D6DF7; font-weight: 500; }
.amount-green { color: #52c41a; font-weight: 500; }
.amount-red { color: #f56c6c; font-weight: 500; }
.amount-orange { color: #e6a23c; font-weight: 500; }
.amount-yellow { color: #d4b106; font-weight: 500; }
.amount-gray { color: #909399; }
.rank-top { color: #f56c6c; font-weight: 700; }

.aging-card {
  padding: 16px;
  border-radius: 8px;
  text-align: center;
  margin-bottom: 12px;
  border: 1px solid #ebeef5;
  &.aging-normal { background: #f0f9eb; .aging-amount { color: #52c41a; } }
  &.aging-warning { background: #fdf6ec; .aging-amount { color: #e6a23c; } }
  &.aging-danger { background: #fef0f0; .aging-amount { color: #f56c6c; } }
  &.aging-critical { background: #fef0f0; border: 2px solid #f56c6c; .aging-amount { color: #f56c6c; } }
}
.aging-range { font-size: 14px; color: #606266; margin-bottom: 8px; }
.aging-count { font-size: 13px; color: #909399; margin-bottom: 4px; }
.aging-amount { font-size: 20px; font-weight: 700; }

.rate-card {
  padding: 20px;
  border-radius: 8px;
  background: var(--el-bg-color);
  border: 1px solid #ebeef5;
  text-align: center;
  margin-bottom: 12px;
}
.rate-label { font-size: 13px; color: #909399; margin-bottom: 8px; }
.rate-value { font-size: 24px; font-weight: 700; }
</style>
