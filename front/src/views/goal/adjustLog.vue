<template>
  <div class="app-container">
    <!-- 搜索表单 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="目标名称" prop="goalName">
        <el-input v-model="queryParams.goalName" placeholder="请输入目标名称" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="操作人" prop="adjustBy">
        <el-input v-model="queryParams.adjustBy" placeholder="请输入操作人" clearable style="width: 140px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="调整日期" prop="dateRange">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width: 240px"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 调整记录表格 -->
    <el-table v-loading="loading" :data="logList">
      <el-table-column label="目标名称" prop="goalName" min-width="160" show-overflow-tooltip />
      <el-table-column label="归属名称" prop="ownerName" min-width="100" show-overflow-tooltip />
      <el-table-column label="口径" align="center" min-width="100">
        <template #default="scope">
          <el-tag size="small" effect="plain">{{ metricLabel(scope.row.metricType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="原值" align="right" min-width="120">
        <template #default="scope">
          <span class="value-old">{{ formatValue(scope.row.oldValue, scope.row.metricType) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="新值" align="right" min-width="120">
        <template #default="scope">
          <span class="value-new">{{ formatValue(scope.row.newValue, scope.row.metricType) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="调整幅度" align="center" min-width="120">
        <template #default="scope">
          <span :class="adjustAmount(scope.row) >= 0 ? 'amount-up' : 'amount-down'">
            {{ adjustAmount(scope.row) >= 0 ? '↑ +' : '↓ ' }}{{ formatValue(Math.abs(adjustAmount(scope.row)), scope.row.metricType) }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="调整原因" prop="reason" min-width="200" show-overflow-tooltip />
      <el-table-column label="操作人" prop="adjustBy" align="center" min-width="100" />
      <el-table-column label="调整时间" prop="adjustTime" align="center" min-width="160">
        <template #default="scope">
          <span>{{ parseTime(scope.row.adjustTime) }}</span>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup name="GoalAdjustLog">
import { listAdjustLog } from '@/api/goal'

const { proxy } = getCurrentInstance()

const loading = ref(true)
const logList = ref([])
const total = ref(0)
const showSearch = ref(true)
const dateRange = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  goalName: undefined,
  adjustBy: undefined
})

const metricMap = {
  1: '实收业绩', 2: '消耗业绩', 3: '出货金额',
  4: '品项件数', 5: '品项金额', 6: '到店客次',
  7: '新客数', 8: '活跃门店数'
}

function metricLabel(type) {
  return metricMap[type] || '-'
}

function isMoneyMetric(type) {
  return [1, 2, 3, 5].includes(Number(type))
}

function formatValue(value, metricType) {
  const num = Number(value || 0)
  if (isNaN(num)) return value
  if (isMoneyMetric(metricType)) {
    return num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
  return num.toLocaleString('zh-CN')
}

function adjustAmount(row) {
  return (Number(row.newValue) || 0) - (Number(row.oldValue) || 0)
}

function getList() {
  loading.value = true
  const params = { ...queryParams }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  listAdjustLog(params).then(response => {
    logList.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  dateRange.value = []
  queryParams.pageNum = 1
  getList()
}

getList()
</script>

<style scoped lang="scss">
.value-old {
  color: #909399;
  text-decoration: line-through;
}

.value-new {
  color: #303133;
  font-weight: 600;
}

.amount-up {
  color: #67c23a;
  font-weight: 500;
}

.amount-down {
  color: #f56c6c;
  font-weight: 500;
}
</style>
