<template>
  <div class="app-container">
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>本月报销总额</span>
          </template>
          <div class="card-value">¥{{ formatMoney(monthTotal) }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <span>本年报销总额</span>
          </template>
          <div class="card-value">¥{{ formatMoney(yearTotal) }}</div>
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
const monthTotal = ref(0)
const yearTotal = ref(0)
const employeeExpense = ref(0)
const companyExpense = ref(0)
const deptData = ref([])
const userData = ref([])

let monthChart = null
let categoryChart = null

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function loadReport() {
  const currentYear = new Date().getFullYear()

  reportByMonth({ year: currentYear }).then(response => {
    const data = response.data || []
    const currentMonth = new Date().getMonth() + 1
    const monthItem = data.find(d => d.month === currentMonth)
    monthTotal.value = monthItem?.total_expense || 0
    yearTotal.value = data.reduce((sum, d) => sum + (d.total_expense || 0), 0)
    renderMonthChart(data)
  })

  reportByCategory({}).then(response => {
    renderCategoryChart(response.data || [])
  })

  reportByDept({}).then(response => {
    deptData.value = response.data || []
  })

  reportByUser({}).then(response => {
    userData.value = response.data || []
  })

  reportByExpenseType({}).then(response => {
    const data = response.data || []
    employeeExpense.value = data.find(d => d.expense_type === '1')?.total_expense || 0
    companyExpense.value = data.find(d => d.expense_type === '2')?.total_expense || 0
  })
}

function renderMonthChart(data) {
  if (!monthChartRef.value) return
  monthChart = echarts.init(monthChartRef.value)
  const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
  const values = new Array(12).fill(0)
  data.forEach(d => {
    values[d.month - 1] = Number(d.total_expense || 0)
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
  const pieData = data.map(d => ({ name: categoryNames[d.category] || d.category, value: Number(d.total_expense || 0) }))
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
