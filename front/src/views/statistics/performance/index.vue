<template>
  <div class="app-container" v-hasPermi="['statistics:performance:list']">
    <el-tabs v-model="activeTab" @tab-click="handleTabClick">
      <el-tab-pane label="按部门" name="dept">
        <el-form :inline="true" :model="deptQuery">
          <el-form-item label="日期范围" required>
            <el-date-picker v-model="deptDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="getDeptData">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportDept">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="deptData" border v-loading="deptLoading" style="width: 100%" show-summary :summary-method="getDeptSummary">
          <el-table-column label="部门名称" prop="deptName" min-width="120" show-overflow-tooltip />
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

      <el-tab-pane label="按个人" name="user">
        <el-form :inline="true" :model="userQuery">
          <el-form-item label="日期范围" required>
            <el-date-picker v-model="userDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="getUserData">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportUser">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="userData" border v-loading="userLoading" style="width: 100%" show-summary :summary-method="getUserSummary">
          <el-table-column label="员工姓名" prop="userName" min-width="100" show-overflow-tooltip />
          <el-table-column label="所属部门" prop="deptName" min-width="120" show-overflow-tooltip />
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

<script setup name="PerformanceStats">
import { deptPerformance, userPerformance } from '@/api/statistics/performance'

const { proxy } = getCurrentInstance()

const activeTab = ref('dept')
const deptQuery = ref({})
const deptDateRange = ref([])
const deptData = ref([])
const deptLoading = ref(false)

const userQuery = ref({})
const userDateRange = ref([])
const userData = ref([])
const userLoading = ref(false)

function getDeptData() {
  if (!deptDateRange.value || deptDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  deptLoading.value = true
  const params = {
    startDate: deptDateRange.value[0],
    endDate: deptDateRange.value[1]
  }
  deptPerformance(params).then(res => {
    deptData.value = res.data || []
  }).finally(() => {
    deptLoading.value = false
  })
}

function getUserData() {
  if (!userDateRange.value || userDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  userLoading.value = true
  const params = {
    startDate: userDateRange.value[0],
    endDate: userDateRange.value[1]
  }
  userPerformance(params).then(res => {
    userData.value = res.data || []
  }).finally(() => {
    userLoading.value = false
  })
}

function handleTabClick(tab) {
  // 切换标签页时不自动加载，用户需手动查询
}

function handleExportDept() {
  if (!deptDateRange.value || deptDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  const params = {
    startDate: deptDateRange.value[0],
    endDate: deptDateRange.value[1]
  }
  proxy.download('statistics/performance/exportDept', params, `部门业绩统计_${new Date().getTime()}.xlsx`)
}

function handleExportUser() {
  if (!userDateRange.value || userDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  const params = {
    startDate: userDateRange.value[0],
    endDate: userDateRange.value[1]
  }
  proxy.download('statistics/performance/exportUser', params, `个人业绩统计_${new Date().getTime()}.xlsx`)
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function getDeptSummary({ columns, data }) {
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

function getUserSummary({ columns, data }) {
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
