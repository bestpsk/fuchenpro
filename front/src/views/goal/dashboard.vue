<template>
  <div class="app-container">
    <!-- 顶部筛选 -->
    <el-card class="filter-card" shadow="never">
      <el-form :inline="true" :model="queryParams" size="default">
        <el-form-item label="口径类型">
          <el-select v-model="queryParams.metricType" placeholder="全部口径" clearable style="width: 160px" @change="handleQuery">
            <el-option v-for="opt in metricOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="周期类型">
          <el-select v-model="queryParams.periodType" placeholder="全部周期" clearable style="width: 140px" @change="handleQuery">
            <el-option v-for="opt in periodOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="归属层级">
          <el-select v-model="queryParams.ownerType" placeholder="全部层级" clearable style="width: 140px" @change="handleQuery">
            <el-option v-for="opt in ownerOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="活动名称">
          <el-input v-model="queryParams.activityName" placeholder="可选" clearable style="width: 180px" @keyup.enter="handleQuery" @clear="handleQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">查询</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          <el-button :type="rankingMode ? 'success' : 'warning'" plain icon="Sort" @click="toggleRanking">
            {{ rankingMode ? '退出排名' : '按完成率排名' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 汇总卡片 -->
    <el-row :gutter="16" class="summary-row">
      <el-col :xs="12" :sm="6">
        <div class="summary-card summary-total">
          <div class="summary-label">目标总数</div>
          <div class="summary-value">{{ summary.total }}</div>
          <div class="summary-sub">个目标</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="summary-card summary-avg">
          <div class="summary-label">平均完成率</div>
          <div class="summary-value">{{ summary.avgRateText }}</div>
          <div class="summary-sub">整体进度</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="summary-card summary-achieved">
          <div class="summary-label">已达成数</div>
          <div class="summary-value">{{ summary.achieved }}</div>
          <div class="summary-sub">完成率 ≥ 100%</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="summary-card summary-warning">
          <div class="summary-label">预警数</div>
          <div class="summary-value">{{ summary.warning }}</div>
          <div class="summary-sub">完成率 &lt; 70%</div>
        </div>
      </el-col>
    </el-row>

    <!-- 主体表格 -->
    <el-table :data="tableData" border v-loading="loading" style="width: 100%" :row-class-name="rowClassName">
      <el-table-column v-if="rankingMode" label="排名" type="index" width="70" align="center" />
      <el-table-column label="目标名称" prop="goalName" min-width="160" show-overflow-tooltip />
      <el-table-column label="归属" min-width="130" align="center">
        <template #default="{ row }">
          <el-tag :type="ownerTagType(row.ownerType)" effect="plain">
            {{ ownerLabel(row.ownerType) }} · {{ row.ownerName }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="口径" min-width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="metricTagType(row.metricType)" effect="plain">{{ metricLabel(row.metricType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="目标值" min-width="110" align="right">
        <template #default="{ row }">
          {{ formatValue(row.targetValue, row.metricType) }}
        </template>
      </el-table-column>
      <el-table-column label="已完成" min-width="110" align="right">
        <template #default="{ row }">
          <span class="amount-blue">{{ formatValue(row.completed, row.metricType) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="完成率" min-width="220" align="center">
        <template #default="{ row }">
          <div class="progress-cell">
            <el-progress
              :percentage="Math.round(row.completionRate * 100)"
              :color="getRateColor(row.completionRate)"
              :stroke-width="14"
              :text-inside="true"
            />
            <div v-if="isItemGoal(row.metricType)" class="dual-metric">
              <span class="dual-item">件数: <b>{{ formatNum(row.completed) }}</b></span>
              <span class="dual-item">金额: <b>{{ formatMoney(row.targetValue) }}</b></span>
            </div>
            <div v-else class="rate-text">{{ row.completionRateText }}</div>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="已过/剩余天数" min-width="120" align="center">
        <template #default="{ row }">
          <span class="days-passed">{{ row.passedWorkDays }}</span>
          <span class="days-sep"> / </span>
          <span class="days-remain">{{ row.remainWorkDays }}</span>
        </template>
      </el-table-column>
      <el-table-column label="当前日均" min-width="110" align="right">
        <template #default="{ row }">
          {{ formatValue(row.currentDaily, row.metricType) }}
        </template>
      </el-table-column>
      <el-table-column label="剩余日均需" min-width="120" align="right">
        <template #default="{ row }">
          <span :class="row.remainDailyNeed > 0 ? 'amount-red' : 'amount-gray'">
            {{ formatValue(row.remainDailyNeed, row.metricType) }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="预计达成日" prop="expectedAchieveDate" min-width="120" align="center">
        <template #default="{ row }">
          <span>{{ row.expectedAchieveDate || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="月末预测" min-width="180" align="center">
        <template #default="{ row }">
          <div class="progress-cell">
            <el-progress
              :percentage="Math.round(row.forecastRate * 100)"
              :color="getRateColor(row.forecastRate)"
              :stroke-width="12"
            />
            <div class="rate-text">{{ row.forecastRateText }}</div>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="今日目标" min-width="110" align="right">
        <template #default="{ row }">
          <span v-if="row.ownerType === 4" class="personal-value">{{ formatValue(row.todayTarget, row.metricType) }}</span>
          <span v-else class="amount-gray">-</span>
        </template>
      </el-table-column>
      <el-table-column label="今日已完成" min-width="110" align="right">
        <template #default="{ row }">
          <span v-if="row.ownerType === 4" class="personal-value">{{ formatValue(row.todayCompleted, row.metricType) }}</span>
          <span v-else class="amount-gray">-</span>
        </template>
      </el-table-column>
      <el-table-column label="今日差额" min-width="110" align="right">
        <template #default="{ row }">
          <span v-if="row.ownerType === 4" :class="row.diff >= 0 ? 'amount-green' : 'amount-red'">
            {{ formatValue(row.diff, row.metricType) }}
          </span>
          <span v-else class="amount-gray">-</span>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup name="GoalDashboard">
import { getGoalProgress, getGoalRanking } from '@/api/goal'

const { proxy } = getCurrentInstance()

const loading = ref(false)
const tableData = ref([])
const rankingMode = ref(false)

const queryParams = ref({
  metricType: undefined,
  periodType: undefined,
  ownerType: undefined,
  activityName: undefined
})

// 口径类型
const metricOptions = [
  { value: 1, label: '实收' },
  { value: 2, label: '消耗' },
  { value: 3, label: '出货' },
  { value: 4, label: '品项件数' },
  { value: 5, label: '品项金额' },
  { value: 6, label: '到店客次' },
  { value: 7, label: '新客数' },
  { value: 8, label: '活跃门店数' }
]

// 周期类型
const periodOptions = [
  { value: '1', label: '年度' },
  { value: '2', label: '季度' },
  { value: '3', label: '月度' },
  { value: '4', label: '自定义' }
]

// 归属层级
const ownerOptions = [
  { value: 2, label: '部门' },
  { value: 4, label: '个人' }
]

const ownerLabelMap = { 2: '部门', 4: '个人' }
const metricLabelMap = {
  1: '实收', 2: '消耗', 3: '出货', 4: '品项件数',
  5: '品项金额', 6: '到店客次', 7: '新客数', 8: '活跃门店数'
}

function ownerLabel(type) {
  return ownerLabelMap[type] || '-'
}
function metricLabel(type) {
  return metricLabelMap[type] || '-'
}
function ownerTagType(type) {
  // 2部门 success, 4个人 danger
  return { 1: 'primary', 2: 'success', 3: 'warning', 4: 'danger' }[type] || 'info'
}
function metricTagType(type) {
  return [4, 5].includes(type) ? 'warning' : 'info'
}

// 金额类口径：1实收 2消耗 3出货 5品项金额
function isMoneyMetric(metricType) {
  return [1, 2, 3, 5].includes(metricType)
}
// 品项目标：4件数 5金额
function isItemGoal(metricType) {
  return [4, 5].includes(metricType)
}

// 完成率颜色：<0.7 红，0.7-1 橙，>=1 绿
function getRateColor(rate) {
  const r = Number(rate) || 0
  if (r < 0.7) return '#f56c6c'
  if (r < 1) return '#e6a23c'
  return '#67c23a'
}

function formatNum(value) {
  const num = Number(value) || 0
  return num.toLocaleString('zh-CN')
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function formatValue(value, metricType) {
  const num = Number(value) || 0
  if (isMoneyMetric(metricType)) {
    return formatMoney(num)
  }
  return formatNum(num)
}

// 汇总
const summary = computed(() => {
  const list = tableData.value || []
  const total = list.length
  const achieved = list.filter(i => Number(i.completionRate) >= 1).length
  const warning = list.filter(i => Number(i.completionRate) < 0.7).length
  const avgRate = total > 0
    ? list.reduce((s, i) => s + (Number(i.completionRate) || 0), 0) / total
    : 0
  return {
    total,
    achieved,
    warning,
    avgRate,
    avgRateText: (avgRate * 100).toFixed(1) + '%'
  }
})

// 个人目标行高亮
function rowClassName({ row }) {
  if (row.ownerType === 4) return 'personal-row'
  return ''
}

function buildParams() {
  const p = {}
  if (queryParams.value.metricType !== undefined && queryParams.value.metricType !== null && queryParams.value.metricType !== '') {
    p.metricType = queryParams.value.metricType
  }
  if (queryParams.value.periodType) p.periodType = queryParams.value.periodType
  if (queryParams.value.ownerType !== undefined && queryParams.value.ownerType !== null && queryParams.value.ownerType !== '') {
    p.ownerType = queryParams.value.ownerType
  }
  if (queryParams.value.activityName) p.activityName = queryParams.value.activityName
  return p
}

function loadData() {
  loading.value = true
  const params = buildParams()
  const api = rankingMode.value ? getGoalRanking(params) : getGoalProgress(params)
  api.then(res => {
    let list = res.data || []
    if (rankingMode.value) {
      // 排名模式：按完成率降序
      list = [...list].sort((a, b) => (Number(b.completionRate) || 0) - (Number(a.completionRate) || 0))
    }
    tableData.value = list
  }).catch(() => {
    tableData.value = []
  }).finally(() => {
    loading.value = false
  })
}

function handleQuery() {
  loadData()
}

function resetQuery() {
  queryParams.value = {
    metricType: undefined,
    periodType: undefined,
    ownerType: undefined,
    activityName: undefined
  }
  loadData()
}

function toggleRanking() {
  rankingMode.value = !rankingMode.value
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped lang="scss">
.filter-card {
  margin-bottom: 12px;
}

.summary-row {
  margin-bottom: 16px;
}

.summary-card {
  padding: 16px 20px;
  border-radius: 8px;
  color: #fff;
  position: relative;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);

  .summary-label {
    font-size: 14px;
    opacity: 0.9;
  }
  .summary-value {
    font-size: 28px;
    font-weight: 600;
    margin-top: 6px;
    line-height: 1.2;
  }
  .summary-sub {
    font-size: 12px;
    opacity: 0.8;
    margin-top: 4px;
  }
}

.summary-total {
  background: linear-gradient(135deg, #3D6DF7, #5b87fa);
}
.summary-avg {
  background: linear-gradient(135deg, #6a8df7, #8aa9ff);
}
.summary-achieved {
  background: linear-gradient(135deg, #67c23a, #85ce61);
}
.summary-warning {
  background: linear-gradient(135deg, #f56c6c, #f78989);
}

.progress-cell {
  width: 100%;
  .rate-text {
    font-size: 12px;
    color: #909399;
    margin-top: 2px;
  }
  .dual-metric {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    margin-top: 4px;
    color: #606266;
    .dual-item b {
      color: #3D6DF7;
      font-weight: 500;
    }
  }
}

.days-passed {
  color: #909399;
}
.days-sep {
  color: #c0c4cc;
}
.days-remain {
  color: #3D6DF7;
  font-weight: 500;
}

.amount-blue {
  color: #3D6DF7;
  font-weight: 500;
}
.amount-red {
  color: #f56c6c;
  font-weight: 500;
}
.amount-green {
  color: #67c23a;
  font-weight: 500;
}
.amount-gray {
  color: #c0c4cc;
}

.personal-value {
  color: #3D6DF7;
  font-weight: 600;
}

:deep(.personal-row) {
  background-color: #f0f5ff !important;
}
:deep(.personal-row:hover > td) {
  background-color: #e0ecff !important;
}
</style>
