<template>
  <div class="app-container" v-hasPermi="['statistics:enterprise:list']">
    <el-tabs v-model="activeTab" @tab-click="handleTabClick">
      <el-tab-pane label="按企业" name="enterprise">
        <el-form :inline="true" :model="enterpriseQuery">
          <el-form-item label="日期范围" required>
            <el-date-picker v-model="enterpriseDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="getEnterpriseData">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportEnterprise">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="enterpriseData" border v-loading="enterpriseLoading" style="width: 100%" show-summary :summary-method="getEnterpriseSummary">
          <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
          <el-table-column label="成交客数" prop="dealCustomerCount" min-width="100" align="center" />
          <el-table-column label="成交金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实付金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.paidAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="120" align="right">
            <template #default="{ row }">
              <span :class="row.owedAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.owedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="现金金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.cashAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="耗卡金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.cardAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="赠送次数" prop="giftCount" min-width="100" align="center" />
          <el-table-column label="操作客数" prop="operationCustomerCount" min-width="100" align="center" />
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="按门店" name="store">
        <el-form :inline="true" :model="storeQuery">
          <el-form-item label="日期范围" required>
            <el-date-picker v-model="storeDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="getStoreData">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportStore">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="storeData" border v-loading="storeLoading" style="width: 100%" show-summary :summary-method="getStoreSummary">
          <el-table-column label="门店名称" prop="storeName" min-width="120" show-overflow-tooltip />
          <el-table-column label="所属企业" prop="enterpriseName" min-width="140" show-overflow-tooltip />
          <el-table-column label="成交客数" prop="dealCustomerCount" min-width="100" align="center" />
          <el-table-column label="成交金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.dealAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实付金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.paidAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="120" align="right">
            <template #default="{ row }">
              <span :class="row.owedAmount > 0 ? 'amount-red' : 'amount-gray'">{{ formatMoney(row.owedAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="现金金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.cashAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="耗卡金额" min-width="120" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.cardAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="赠送次数" prop="giftCount" min-width="100" align="center" />
          <el-table-column label="操作客数" prop="operationCustomerCount" min-width="100" align="center" />
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="EnterpriseStats">
import { enterprisePerformance, storePerformance } from '@/api/statistics/performance'

const { proxy } = getCurrentInstance()

const activeTab = ref('enterprise')
const enterpriseQuery = ref({})
const enterpriseDateRange = ref([])
const enterpriseData = ref([])
const enterpriseLoading = ref(false)

const storeQuery = ref({})
const storeDateRange = ref([])
const storeData = ref([])
const storeLoading = ref(false)

function getEnterpriseData() {
  if (!enterpriseDateRange.value || enterpriseDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  enterpriseLoading.value = true
  const params = {
    startDate: enterpriseDateRange.value[0],
    endDate: enterpriseDateRange.value[1]
  }
  enterprisePerformance(params).then(res => {
    enterpriseData.value = res.data || []
  }).finally(() => {
    enterpriseLoading.value = false
  })
}

function getStoreData() {
  if (!storeDateRange.value || storeDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  storeLoading.value = true
  const params = {
    startDate: storeDateRange.value[0],
    endDate: storeDateRange.value[1]
  }
  storePerformance(params).then(res => {
    storeData.value = res.data || []
  }).finally(() => {
    storeLoading.value = false
  })
}

function handleTabClick(tab) {
  // 切换标签页时不自动加载，用户需手动查询
}

function handleExportEnterprise() {
  if (!enterpriseDateRange.value || enterpriseDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  const params = {
    startDate: enterpriseDateRange.value[0],
    endDate: enterpriseDateRange.value[1]
  }
  proxy.download('statistics/performance/exportEnterprise', params, `企业业绩统计_${new Date().getTime()}.xlsx`)
}

function handleExportStore() {
  if (!storeDateRange.value || storeDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  const params = {
    startDate: storeDateRange.value[0],
    endDate: storeDateRange.value[1]
  }
  proxy.download('statistics/performance/exportStore', params, `门店业绩统计_${new Date().getTime()}.xlsx`)
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function getEnterpriseSummary({ columns, data }) {
  const sums = []
  columns.forEach((column, index) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    const fields = ['dealCustomerCount', 'dealAmount', 'paidAmount', 'owedAmount', 'cashAmount', 'cardAmount', 'giftCount', 'operationCustomerCount']
    if (fields.includes(column.property)) {
      const values = data.map(item => Number(item[column.property]))
      const sum = values.reduce((prev, curr) => prev + curr, 0)
      const amountFields = ['dealAmount', 'paidAmount', 'owedAmount', 'cashAmount', 'cardAmount']
      sums[index] = amountFields.includes(column.property) ? formatMoney(sum) : sum
    } else {
      sums[index] = ''
    }
  })
  return sums
}

function getStoreSummary({ columns, data }) {
  const sums = []
  columns.forEach((column, index) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    if (index === 1) {
      sums[index] = ''
      return
    }
    const fields = ['dealCustomerCount', 'dealAmount', 'paidAmount', 'owedAmount', 'cashAmount', 'cardAmount', 'giftCount', 'operationCustomerCount']
    if (fields.includes(column.property)) {
      const values = data.map(item => Number(item[column.property]))
      const sum = values.reduce((prev, curr) => prev + curr, 0)
      const amountFields = ['dealAmount', 'paidAmount', 'owedAmount', 'cashAmount', 'cardAmount']
      sums[index] = amountFields.includes(column.property) ? formatMoney(sum) : sum
    } else {
      sums[index] = ''
    }
  })
  return sums
}
</script>

<style scoped lang="scss">
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
</style>
