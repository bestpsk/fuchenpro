<template>
  <div class="app-container" v-hasPermi="['statistics:customer:list']">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="新增趋势" name="trend">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="统计月份">
            <el-input-number v-model="trendMonths" :min="3" :max="36" :step="3" style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadTrend">查询</el-button>
          </el-form-item>
        </el-form>
        <div ref="trendChartRef" class="chart-container" v-loading="trendLoading"></div>
      </el-tab-pane>

      <el-tab-pane label="价值分布" name="value">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="valueDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadValueDistribution">查询</el-button>
          </el-form-item>
        </el-form>
        <el-row :gutter="16">
          <el-col :sm="24" :lg="10">
            <div ref="valueChartRef" class="chart-container" v-loading="valueLoading"></div>
          </el-col>
          <el-col :sm="24" :lg="14">
            <el-table :data="valueTableData" border style="margin-top: 12px">
              <el-table-column label="层级" min-width="100">
                <template #default="{ row }">
                  <el-tag :type="row.tagType" effect="dark">{{ row.label }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="客户数" prop="count" min-width="80" align="center" />
              <el-table-column label="占比" min-width="90" align="center">
                <template #default="{ row }">
                  <span class="amount-blue">{{ row.rate }}%</span>
                </template>
              </el-table-column>
              <el-table-column label="金额区间" min-width="180" align="center">
                <template #default="{ row }">
                  <span>{{ row.range }}</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" min-width="100" align="center">
                <template #default="{ row }">
                  <el-button link type="primary" @click="openCustomerDialog(row.level)">查看明细</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-col>
        </el-row>
      </el-tab-pane>

      <el-tab-pane label="流失预警" name="churn">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="未下单天数">
            <el-input-number v-model="churnDays" :min="30" :max="365" :step="30" style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadChurnWarning">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportChurn">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="churnList" border v-loading="churnLoading">
          <el-table-column label="客户名称" prop="customerName" min-width="140" show-overflow-tooltip />
          <el-table-column label="联系电话" prop="phone" min-width="120" />
          <el-table-column label="累计消费" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="订单数" prop="orderCount" min-width="80" align="center" />
          <el-table-column label="最后下单时间" prop="lastOrderTime" min-width="160" />
          <el-table-column label="未下单天数" min-width="100" align="center">
            <template #default="{ row }">
              <span :class="row.daysSinceOrder >= 180 ? 'amount-red' : 'amount-orange'">{{ row.daysSinceOrder }} 天</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="消费频次" name="frequency">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="freqDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadFrequency">查询</el-button>
          </el-form-item>
        </el-form>
        <div ref="freqChartRef" class="chart-container" v-loading="freqLoading"></div>
      </el-tab-pane>
    </el-tabs>

    <!-- 价值层级客户明细 Dialog -->
    <el-dialog v-model="customerDialogVisible" :title="customerDialogTitle" width="800px" append-to-body>
      <el-table :data="customerList" border v-loading="customerListLoading" max-height="500">
        <el-table-column label="排名" min-width="60" align="center">
          <template #default="{ $index }">{{ $index + 1 }}</template>
        </el-table-column>
        <el-table-column label="客户名称" prop="customerName" min-width="140" show-overflow-tooltip />
        <el-table-column label="累计消费" min-width="120" align="right">
          <template #default="{ row }">
            <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="订单数" prop="orderCount" min-width="80" align="center" />
        <el-table-column label="最后下单时间" prop="lastOrderTime" min-width="160" />
        <el-table-column label="联系电话" prop="phone" min-width="120" />
        <el-table-column label="状态" min-width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'info'" size="small">{{ row.status === '0' ? '正常' : '禁用' }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup name="CustomerStats">
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { newCustomerTrend, valueDistribution, customerListByLevel, churnWarning, orderFrequency } from '@/api/statistics/customer'

const { proxy } = getCurrentInstance()
const activeTab = ref('trend')

// 新增趋势
const trendChartRef = ref(null)
let trendChart = null
const trendLoading = ref(false)
const trendMonths = ref(12)

// 价值分布
const valueChartRef = ref(null)
let valueChart = null
const valueLoading = ref(false)
const valueDateRange = ref([])
const valueTableData = ref([])

// 流失预警
const churnLoading = ref(false)
const churnList = ref([])
const churnDays = ref(90)

// 消费频次
const freqChartRef = ref(null)
let freqChart = null
const freqLoading = ref(false)
const freqDateRange = ref([])

// 客户明细 Dialog
const customerDialogVisible = ref(false)
const customerDialogTitle = ref('')
const customerList = ref([])
const customerListLoading = ref(false)

onMounted(() => {
  loadTrend()
})

onBeforeUnmount(() => {
  if (trendChart) { trendChart.dispose(); trendChart = null }
  if (valueChart) { valueChart.dispose(); valueChart = null }
  if (freqChart) { freqChart.dispose(); freqChart = null }
})

function handleTabChange(tab) {
  if (tab === 'trend' && !trendChart) {
    nextTick(() => loadTrend())
  } else if (tab === 'value' && !valueChart) {
    nextTick(() => loadValueDistribution())
  } else if (tab === 'churn' && churnList.value.length === 0) {
    loadChurnWarning()
  } else if (tab === 'frequency' && !freqChart) {
    nextTick(() => loadFrequency())
  }
}

// 新增趋势
function loadTrend() {
  trendLoading.value = true
  newCustomerTrend({ months: trendMonths.value }).then(res => {
    const data = res.data || res || []
    nextTick(() => renderTrendChart(data))
  }).finally(() => {
    trendLoading.value = false
  })
}

function renderTrendChart(data) {
  if (!trendChartRef.value) return
  if (!trendChart) {
    trendChart = echarts.init(trendChartRef.value)
  }
  const months = data.map(d => d.month)
  const counts = data.map(d => d.newCount)

  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '8%', top: '8%', containLabel: true },
    xAxis: { type: 'category', data: months, axisLabel: { rotate: 30 } },
    yAxis: { type: 'value', name: '新增客户数' },
    series: [{
      name: '新增客户数',
      type: 'line',
      smooth: true,
      data: counts,
      itemStyle: { color: '#3D6DF7' },
      areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(61,109,247,0.3)' }, { offset: 1, color: 'rgba(61,109,247,0.02)' }]) },
      label: { show: true, position: 'top' }
    }]
  })
}

// 价值分布
function loadValueDistribution() {
  valueLoading.value = true
  const params = {}
  if (valueDateRange.value && valueDateRange.value.length === 2) {
    params.startDate = valueDateRange.value[0]
    params.endDate = valueDateRange.value[1]
  }
  valueDistribution(params).then(res => {
    const data = res.data || res || {}
    const total = data.totalCustomers || 0
    valueTableData.value = [
      {
        level: 'high', label: '高价值', tagType: 'danger',
        count: data.highValue || 0,
        rate: total > 0 ? ((data.highValue / total) * 100).toFixed(2) : '0.00',
        range: `≥ ¥${(data.highThreshold || 10000).toLocaleString()}`
      },
      {
        level: 'mid', label: '中价值', tagType: 'warning',
        count: data.midValue || 0,
        rate: total > 0 ? ((data.midValue / total) * 100).toFixed(2) : '0.00',
        range: `¥${(data.midThreshold || 1000).toLocaleString()} ~ ¥${(data.highThreshold || 10000).toLocaleString()}`
      },
      {
        level: 'low', label: '低价值', tagType: 'info',
        count: data.lowValue || 0,
        rate: total > 0 ? ((data.lowValue / total) * 100).toFixed(2) : '0.00',
        range: `< ¥${(data.midThreshold || 1000).toLocaleString()}`
      }
    ]
    nextTick(() => renderValueChart(valueTableData.value))
  }).finally(() => {
    valueLoading.value = false
  })
}

function renderValueChart(data) {
  if (!valueChartRef.value) return
  if (!valueChart) {
    valueChart = echarts.init(valueChartRef.value)
  }
  valueChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0, textStyle: { fontSize: 12 } },
    series: [{
      name: '客户价值分布',
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['50%', '45%'],
      data: [
        { value: data[0].count, name: '高价值', itemStyle: { color: '#f56c6c' } },
        { value: data[1].count, name: '中价值', itemStyle: { color: '#e6a23c' } },
        { value: data[2].count, name: '低价值', itemStyle: { color: '#909399' } }
      ],
      label: { formatter: '{b}\n{c} 人' },
      emphasis: { itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.5)' } }
    }]
  })
}

// 客户明细 Dialog
function openCustomerDialog(level) {
  const labels = { high: '高价值', mid: '中价值', low: '低价值' }
  customerDialogTitle.value = `${labels[level] || ''}客户明细`
  customerDialogVisible.value = true
  customerListLoading.value = true
  customerList.value = []

  const params = { level }
  if (valueDateRange.value && valueDateRange.value.length === 2) {
    params.startDate = valueDateRange.value[0]
    params.endDate = valueDateRange.value[1]
  }
  customerListByLevel(params).then(res => {
    customerList.value = res.data || res || []
  }).finally(() => {
    customerListLoading.value = false
  })
}

// 流失预警
function loadChurnWarning() {
  churnLoading.value = true
  churnWarning({ days: churnDays.value }).then(res => {
    churnList.value = res.data || res || []
  }).finally(() => {
    churnLoading.value = false
  })
}

function handleExportChurn() {
  proxy.download('statistics/customer/exportChurn', { days: churnDays.value }, `客户流失预警_${new Date().getTime()}.xlsx`)
}

// 消费频次
function loadFrequency() {
  freqLoading.value = true
  const params = {}
  if (freqDateRange.value && freqDateRange.value.length === 2) {
    params.startDate = freqDateRange.value[0]
    params.endDate = freqDateRange.value[1]
  }
  orderFrequency(params).then(res => {
    const data = res.data || res || {}
    nextTick(() => renderFreqChart(data))
  }).finally(() => {
    freqLoading.value = false
  })
}

function renderFreqChart(data) {
  if (!freqChartRef.value) return
  if (!freqChart) {
    freqChart = echarts.init(freqChartRef.value)
  }
  const categories = ['1次', '2-5次', '6-10次', '10次以上']
  const values = [data.oneTime || 0, data.twoToFive || 0, data.sixToTen || 0, data.overTen || 0]

  freqChart.setOption({
    tooltip: { trigger: 'axis', formatter: '{b}: {c} 人' },
    grid: { left: '3%', right: '4%', bottom: '8%', top: '8%', containLabel: true },
    xAxis: { type: 'category', data: categories },
    yAxis: { type: 'value', name: '客户数' },
    series: [{
      name: '客户数',
      type: 'bar',
      data: values,
      itemStyle: { color: '#3D6DF7', borderRadius: [4, 4, 0, 0] },
      label: { show: true, position: 'top' }
    }]
  })
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<style scoped lang="scss">
.chart-container {
  width: 100%;
  height: 400px;
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: var(--el-bg-color);
}
.amount-blue {
  color: #3D6DF7;
  font-weight: 500;
}
.amount-red {
  color: #f56c6c;
  font-weight: 500;
}
.amount-orange {
  color: #e6a23c;
  font-weight: 500;
}
</style>
