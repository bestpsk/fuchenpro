<template>
  <div class="app-container" v-hasPermi="['statistics:prepare:list']">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="备货金额" name="amount">
        <el-table :data="amountList" border v-loading="amountLoading" show-summary :summary-method="getAmountSummary">
          <el-table-column label="状态" prop="statusName" min-width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)">{{ row.statusName }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="备货单数" prop="prepareCount" min-width="100" align="center" />
          <el-table-column label="备货金额" min-width="130" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="已出库金额" min-width="130" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.shippedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="待出库金额" min-width="130" align="right">
            <template #default="{ row }">
              <span :class="row.remainingAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.remainingAmount) }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="方案执行" name="plan">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item>
            <el-button type="warning" plain icon="Download" @click="handleExportPlan">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="planList" border v-loading="planLoading">
          <el-table-column label="方案编号" prop="planNo" min-width="140" show-overflow-tooltip />
          <el-table-column label="方案名称" prop="planName" min-width="140" show-overflow-tooltip />
          <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
          <el-table-column label="配赠金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.giftAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="备货中金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-orange">{{ formatMoney(row.activeAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="已出库金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.stockPrepareShipped) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="剩余可备货" min-width="120" align="right">
            <template #default="{ row }">
              <span :class="row.remainingAvailable <= 0 ? 'amount-red' : 'amount-green'">{{ formatMoney(row.remainingAvailable) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="执行率" min-width="100" align="center">
            <template #default="{ row }">
              <span :class="getRateClass(row.executionRate)">{{ row.executionRate }}%</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="出库率" name="shipment">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="shipDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadShipmentRate">查询</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="shipList" border v-loading="shipLoading">
          <el-table-column label="企业名称" prop="enterpriseName" min-width="160" show-overflow-tooltip />
          <el-table-column label="备货单数" prop="prepareCount" min-width="100" align="center" />
          <el-table-column label="备货金额" min-width="130" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="已出库金额" min-width="130" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.shippedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="待出库金额" min-width="130" align="right">
            <template #default="{ row }">
              <span :class="row.remainingAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.remainingAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="出库率" min-width="100" align="center">
            <template #default="{ row }">
              <span :class="getRateClass(row.shipmentRate * 100)">{{ (row.shipmentRate * 100).toFixed(2) }}%</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="PrepareStats">
import { ref, onMounted } from 'vue'
import { prepareAmountStats, planExecution, shipmentRate } from '@/api/statistics/prepare'

const { proxy } = getCurrentInstance()
const activeTab = ref('amount')

const amountList = ref([])
const amountLoading = ref(false)
const amountTotal = ref({})

const planList = ref([])
const planLoading = ref(false)

const shipList = ref([])
const shipLoading = ref(false)
const shipDateRange = ref([])

onMounted(() => {
  loadAmount()
  loadPlan()
})

function loadAmount() {
  amountLoading.value = true
  prepareAmountStats().then(res => {
    const data = res.data || res || {}
    amountList.value = data.list || []
    amountTotal.value = data.total || {}
  }).finally(() => {
    amountLoading.value = false
  })
}

function loadPlan() {
  planLoading.value = true
  planExecution().then(res => {
    planList.value = res.data || res || []
  }).finally(() => {
    planLoading.value = false
  })
}

function loadShipmentRate() {
  shipLoading.value = true
  const params = {}
  if (shipDateRange.value && shipDateRange.value.length === 2) {
    params.startDate = shipDateRange.value[0]
    params.endDate = shipDateRange.value[1]
  }
  shipmentRate(params).then(res => {
    shipList.value = res.data || res || []
  }).finally(() => {
    shipLoading.value = false
  })
}

function handleExportPlan() {
  proxy.download('statistics/prepare/exportPlanExecution', {}, `方案执行统计_${new Date().getTime()}.xlsx`)
}

function getStatusType(status) {
  const map = { '0': 'warning', '1': 'primary', '2': 'success', '3': 'info' }
  return map[status] || ''
}

function getRateClass(rate) {
  if (rate >= 80) return 'amount-green'
  if (rate >= 50) return 'amount-blue'
  if (rate >= 20) return 'amount-orange'
  return 'amount-red'
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function getAmountSummary({ columns, data }) {
  const sums = []
  const total = amountTotal.value || {}
  columns.forEach((column, index) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    const map = { prepareCount: total.prepareCount, totalAmount: total.totalAmount, shippedAmount: total.shippedAmount, remainingAmount: total.remainingAmount }
    if (map[column.property] !== undefined) {
      const val = map[column.property]
      sums[index] = ['totalAmount', 'shippedAmount', 'remainingAmount'].includes(column.property) ? formatMoney(val) : val
    } else {
      sums[index] = ''
    }
  })
  return sums
}
</script>

<style scoped lang="scss">
.amount-blue { color: #3D6DF7; font-weight: 500; }
.amount-red { color: #f56c6c; font-weight: 500; }
.amount-orange { color: #e6a23c; font-weight: 500; }
.amount-green { color: #67c23a; font-weight: 500; }
.amount-gray { color: #c0c4cc; }
</style>
