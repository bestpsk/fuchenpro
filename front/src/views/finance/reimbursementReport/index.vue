<template>
  <div class="app-container">
    <!-- 时间筛选 -->
    <el-form :inline="true" class="mb20">
      <el-form-item label="时间范围">
        <el-button-group>
          <el-button :type="activeQuick === 'today' ? 'primary' : ''" @click="setQuickFilter('today')">今日</el-button>
          <el-button :type="activeQuick === 'month' ? 'primary' : ''" @click="setQuickFilter('month')">本月</el-button>
          <el-button :type="activeQuick === 'year' ? 'primary' : ''" @click="setQuickFilter('year')">本年</el-button>
        </el-button-group>
      </el-form-item>
      <el-form-item>
        <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" @change="onDateRangeChange" />
      </el-form-item>
    </el-form>

    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>报销总额</span>
          </template>
          <div class="card-value">¥{{ formatMoney(totalExpense) }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>报销次数</span>
          </template>
          <div class="card-value">{{ totalCount }} 次</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>员工支出</span>
          </template>
          <div class="card-value" style="color: #e6a23c">¥{{ formatMoney(employeeExpense) }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>公司支出</span>
          </template>
          <div class="card-value" style="color: #67c23a">¥{{ formatMoney(companyExpense) }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>
            <span>月度报销趋势</span>
          </template>
          <div ref="monthChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>
            <span>分类占比</span>
          </template>
          <div ref="categoryChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mt20">
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>
            <span>部门报销排名</span>
          </template>
          <el-table :data="deptData" size="small" max-height="300">
            <el-table-column label="排名" type="index" width="60" />
            <el-table-column label="部门" prop="deptName" />
            <el-table-column label="报销金额" prop="totalExpense" width="150">
              <template #default="scope">¥{{ formatMoney(scope.row.totalExpense) }}</template>
            </el-table-column>
            <el-table-column label="报销次数" prop="count" width="100" />
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>
            <span>个人报销排名</span>
          </template>
          <el-table :data="userData" size="small" max-height="300">
            <el-table-column label="排名" type="index" width="60" />
            <el-table-column label="申请人" prop="applicantName" />
            <el-table-column label="报销金额" prop="totalExpense" width="150">
              <template #default="scope">¥{{ formatMoney(scope.row.totalExpense) }}</template>
            </el-table-column>
            <el-table-column label="报销次数" prop="count" width="100" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup name="FinanceReimbursementReport">
import { reportByMonth, reportByCategory, reportByDept, reportByUser, reportByExpenseType } from '@/api/finance/reimbursement'
import * as echarts from 'echarts'

const monthChartRef = ref()
const categoryChartRef = ref()
const totalExpense = ref(0)
const totalCount = ref(0)
const employeeExpense = ref(0)
const companyExpense = ref(0)
const deptData = ref([])
const userData = ref([])

const activeQuick = ref('month')
const dateRange = ref(null)

let monthChart = null
let categoryChart = null

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function getDateRange(type) {
  const now = new Date()
  const y = now.getFullYear()
  const m = now.getMonth()
  const d = now.getDate()
  const pad = n => String(n).padStart(2, '0')

  if (type === 'today') {
    const date = `${y}-${pad(m + 1)}-${pad(d)}`
    return [date, date]
  } else if (type === 'month') {
    const start = `${y}-${pad(m + 1)}-01`
    const lastDay = new Date(y, m + 1, 0).getDate()
    const end = `${y}-${pad(m + 1)}-${pad(lastDay)}`
    return [start, end]
  } else if (type === 'year') {
    return [`${y}-01-01`, `${y}-12-31`]
  }
  return null
}

function setQuickFilter(type) {
  activeQuick.value = type
  dateRange.value = null
  loadReport()
}

function onDateRangeChange(val) {
  if (val) {
    activeQuick.value = ''
  } else {
    activeQuick.value = 'month'
  }
  loadReport()
}

function loadReport() {
  let applyDateStart = ''
  let applyDateEnd = ''

  if (dateRange.value && dateRange.value.length === 2) {
    applyDateStart = dateRange.value[0]
    applyDateEnd = dateRange.value[1]
  } else if (activeQuick.value) {
    const range = getDateRange(activeQuick.value)
    if (range) {
      applyDateStart = range[0]
      applyDateEnd = range[1]
    }
  }

  const params = { applyDateStart, applyDateEnd }

  reportByMonth(params).then(response => {
    const data = response.data || []
    totalExpense.value = data.reduce((sum, d) => sum + (Number(d.totalExpense) || 0), 0)
    totalCount.value = data.reduce((sum, d) => sum + (Number(d.count) || 0), 0)
    renderMonthChart(data)
  })

  reportByCategory(params).then(response => {
    renderCategoryChart(response.data || [])
  })

  reportByDept(params).then(response => {
    deptData.value = response.data || []
  })

  reportByUser(params).then(response => {
    userData.value = response.data || []
  })

  reportByExpenseType(params).then(response => {
    const data = response.data || []
    employeeExpense.value = data.find(d => d.expenseType === '1')?.totalExpense || 0
    companyExpense.value = data.find(d => d.expenseType === '2')?.totalExpense || 0
  })
}

function renderMonthChart(data) {
  if (!monthChartRef.value) return
  monthChart = echarts.init(monthChartRef.value)
  const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
  const values = new Array(12).fill(0)
  data.forEach(d => {
    values[d.month - 1] = Number(d.totalExpense || 0)
  })
  monthChart.setOption({
    tooltip: { trigger: 'axis', formatter: '{b}: ¥{c}' },
    xAxis: { type: 'category', data: months },
    yAxis: { type: 'value', axisLabel: { formatter: '¥{value}' } },
    series: [{ type: 'bar', data: values, itemStyle: { color: '#409eff' } }]
  })
}

function renderCategoryChart(data) {
  if (!categoryChartRef.value) return
  categoryChart = echarts.init(categoryChartRef.value)
  const categoryNames = { '1': '行程买票', '2': '销售费用', '3': '行政支出', '4': '其它' }
  const pieData = data.map(d => ({ name: categoryNames[d.category] || d.category, value: Number(d.totalExpense || 0) }))
  categoryChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
    legend: { orient: 'vertical', left: 'left' },
    series: [{
      type: 'pie',
      radius: '60%',
      data: pieData,
      emphasis: { itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0, 0, 0, 0.5)' } }
    }]
  })
}

onMounted(() => {
  loadReport()
  window.addEventListener('resize', () => {
    monthChart?.resize()
    categoryChart?.resize()
  })
})

onUnmounted(() => {
  monthChart?.dispose()
  categoryChart?.dispose()
})
</script>

<style scoped>
.card-value {
  font-size: 24px;
  font-weight: bold;
  color: #409eff;
}
.mb20 {
  margin-bottom: 20px;
}
.mt20 {
  margin-top: 20px;
}
</style>
