<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="目标名称" prop="goalName">
        <el-input v-model="queryParams.goalName" placeholder="请输入目标名称" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="归属层级" prop="ownerType">
        <el-select v-model="queryParams.ownerType" placeholder="请选择归属层级" clearable style="width: 140px">
          <el-option v-for="item in ownerTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="周期类型" prop="periodType">
        <el-select v-model="queryParams.periodType" placeholder="请选择周期类型" clearable style="width: 140px">
          <el-option v-for="item in periodTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="口径类型" prop="metricType">
        <el-select v-model="queryParams.metricType" placeholder="请选择口径类型" clearable style="width: 160px">
          <el-option v-for="item in metricTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 120px">
          <el-option label="启用" value="0" />
          <el-option label="停用" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['goal:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['goal:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="goalList">
      <el-table-column label="目标名称" prop="goalName" min-width="160" show-overflow-tooltip />
      <el-table-column label="归属层级" align="center" min-width="90">
        <template #default="scope">
          <el-tag :type="getOwnerTypeTagType(scope.row.ownerType)" size="small">{{ getOwnerTypeLabel(scope.row.ownerType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="归属名称" prop="ownerName" min-width="120" show-overflow-tooltip />
      <el-table-column label="周期" align="center" min-width="80">
        <template #default="scope">
          <span>{{ getPeriodTypeLabel(scope.row.periodType) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="周期名称" prop="periodName" min-width="110" show-overflow-tooltip />
      <el-table-column label="口径" align="center" min-width="110">
        <template #default="scope">
          <el-tag :type="getMetricTypeTagType(scope.row.metricType)" size="small" effect="plain">{{ getMetricTypeLabel(scope.row.metricType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="目标值" align="right" min-width="140">
        <template #default="scope">
          <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(scope.row.targetValue) }}</span>
          <span v-if="scope.row.unit" style="color: #909399; margin-left: 4px; font-size: 12px">{{ scope.row.unit }}</span>
        </template>
      </el-table-column>
      <el-table-column label="起止日期" align="center" min-width="200">
        <template #default="scope">
          <span style="font-size: 12px">{{ scope.row.startDate }} ~ {{ scope.row.endDate }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" min-width="80">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="(val) => handleStatusChange(scope.row, val)" v-hasPermi="['goal:edit']" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" min-width="160">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="340" class-name="small-padding fixed-width" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="DataLine" @click="handleProgress(scope.row)" v-hasPermi="['goal:dashboard']">进度</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['goal:edit']">编辑</el-button>
          <el-button link type="primary" icon="Share" @click="handleSplit(scope.row)" v-hasPermi="['goal:add']" v-if="scope.row.ownerType !== 4">拆解</el-button>
          <el-button link type="success" icon="Calendar" @click="handleGenerateDaily(scope.row)" v-hasPermi="['goal:edit']">生成日目标</el-button>
          <el-button link type="primary" icon="Calendar" @click="handleDailyDetail(scope.row)">日目标</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['goal:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/编辑弹窗（form.vue 自带 el-dialog） -->
    <goal-form v-model:visible="dialog.open" :goal-id="dialog.goalId" @success="handleFormSuccess" />

    <!-- 目标拆解弹窗 -->
    <goal-split v-model:visible="splitVisible" :goal-id="splitGoalId" @success="handleSplitSuccess" />

    <!-- 进度查看弹窗 -->
    <el-dialog title="目标进度" v-model="progressOpen" width="680px" append-to-body>
      <div v-loading="progressLoading">
        <el-descriptions :column="2" border v-if="progressData">
          <el-descriptions-item label="目标值">
            <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(progressData.targetValue) }}</span>
            <span v-if="progressData.unit" style="margin-left: 4px; color: #909399">{{ progressData.unit }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="已完成">
            <span style="color: #67c23a; font-weight: 600">{{ formatNumber(progressData.completed) }}</span>
            <span v-if="progressData.unit" style="margin-left: 4px; color: #909399">{{ progressData.unit }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="完成率" :span="2">
            <el-progress :percentage="Math.round((progressData.completionRate || 0) * 100)" :color="'#3D6DF7'" :stroke-width="18" :text-inside="true" />
          </el-descriptions-item>
          <el-descriptions-item label="已过天数">{{ progressData.passedWorkDays ?? 0 }} 天</el-descriptions-item>
          <el-descriptions-item label="剩余天数">{{ progressData.remainWorkDays ?? 0 }} 天</el-descriptions-item>
          <el-descriptions-item label="当前日均">
            {{ formatNumber(progressData.currentDaily) }}
            <span v-if="progressData.unit" style="color: #909399; margin-left: 4px">{{ progressData.unit }}/天</span>
          </el-descriptions-item>
          <el-descriptions-item label="剩余日均">
            {{ formatNumber(progressData.remainDailyNeed) }}
            <span v-if="progressData.unit" style="color: #909399; margin-left: 4px">{{ progressData.unit }}/天</span>
          </el-descriptions-item>
          <el-descriptions-item label="预计达成日" :span="2">
            <el-tag v-if="progressData.expectedAchieveDate" type="success" size="small">{{ progressData.expectedAchieveDate }}</el-tag>
            <span v-else style="color: #909399">-</span>
          </el-descriptions-item>
        </el-descriptions>
        <el-empty v-else-if="!progressLoading" description="暂无进度数据" />
      </div>
      <template #footer>
        <el-button @click="progressOpen = false">关 闭</el-button>
      </template>
    </el-dialog>

    <!-- 日目标明细弹窗 -->
    <el-dialog title="日目标明细" v-model="dailyOpen" width="780px" append-to-body>
      <div v-loading="dailyLoading">
        <el-descriptions :column="3" border size="small" v-if="dailyData && dailyData.goal" style="margin-bottom: 16px">
          <el-descriptions-item label="目标名称" :span="2">{{ dailyData.goal.goalName }}</el-descriptions-item>
          <el-descriptions-item label="目标值">
            <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(dailyData.goal.targetValue) }}</span>
            <span v-if="dailyData.goal.unit" style="margin-left: 4px; color: #909399">{{ dailyData.goal.unit }}</span>
          </el-descriptions-item>
        </el-descriptions>
        <el-table :data="dailyData?.dailyList || []" border max-height="480" size="small">
          <el-table-column label="日期" prop="targetDate" min-width="110" align="center">
            <template #default="scope">
              <span :style="scope.row.targetDate === dailyData?.today ? 'color: #3D6DF7; font-weight: 700' : ''">
                {{ scope.row.targetDate }}
              </span>
              <el-tag v-if="scope.row.targetDate === dailyData?.today" type="primary" size="small" effect="plain" style="margin-left: 4px">今日</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="当日目标值" prop="targetValue" min-width="130" align="right">
            <template #default="scope">
              <span :style="scope.row.isRestDay ? 'color: #c0c4cc' : 'color: #303133; font-weight: 500'">
                {{ formatNumber(scope.row.targetValue) }}
              </span>
            </template>
          </el-table-column>
          <el-table-column label="休息日" prop="isRestDay" min-width="80" align="center">
            <template #default="scope">
              <el-tag v-if="scope.row.isRestDay" type="info" size="small">休息</el-tag>
              <span v-else style="color: #c0c4cc">-</span>
            </template>
          </el-table-column>
          <el-table-column label="备注" prop="remark" min-width="160" show-overflow-tooltip>
            <template #default="scope">
              <span style="color: #909399">{{ scope.row.remark || '-' }}</span>
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-if="!dailyLoading && (!dailyData || !dailyData.dailyList || dailyData.dailyList.length === 0)" description="暂无日目标数据，请先生成日目标" />
      </div>
      <template #footer>
        <el-button @click="dailyOpen = false">关 闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Goal">
import { listGoal, delGoal, generateDaily, getGoalProgress, updateGoal, getDailyDetail } from '@/api/goal'

const GoalForm = defineAsyncComponent(() => import('./form.vue'))
const GoalSplit = defineAsyncComponent(() => import('./split.vue'))
const { proxy } = getCurrentInstance()

const goalList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const progressOpen = ref(false)
const progressLoading = ref(false)
const progressData = ref(null)
const dailyOpen = ref(false)
const dailyLoading = ref(false)
const dailyData = ref(null)
const splitVisible = ref(false)
const splitGoalId = ref(null)

const ownerTypeOptions = [
  { value: 2, label: '部门' },
  { value: 4, label: '个人' }
]

const periodTypeOptions = [
  { value: 1, label: '年度' },
  { value: 2, label: '季度' },
  { value: 3, label: '月度' },
  { value: 4, label: '自定义' }
]

const metricTypeOptions = [
  { value: 1, label: '实收业绩' },
  { value: 2, label: '消耗业绩' },
  { value: 3, label: '出货金额' },
  { value: 4, label: '品项件数' },
  { value: 5, label: '品项金额' },
  { value: 6, label: '到店客次' },
  { value: 7, label: '新客数' },
  { value: 8, label: '活跃门店数' }
]

const ownerTypeMap = {
  2: { label: '部门', tagType: 'warning' },
  4: { label: '个人', tagType: '' }
}

const periodTypeMap = {
  1: '年度',
  2: '季度',
  3: '月度',
  4: '自定义'
}

const metricTypeMap = {
  1: { label: '实收业绩', tagType: '' },
  2: { label: '消耗业绩', tagType: 'success' },
  3: { label: '出货金额', tagType: 'warning' },
  4: { label: '品项件数', tagType: 'info' },
  5: { label: '品项金额', tagType: 'info' },
  6: { label: '到店客次', tagType: 'warning' },
  7: { label: '新客数', tagType: 'success' },
  8: { label: '活跃门店数', tagType: 'info' }
}

function getOwnerTypeLabel(val) {
  return ownerTypeMap[Number(val)]?.label ?? '-'
}

function getOwnerTypeTagType(val) {
  return ownerTypeMap[Number(val)]?.tagType ?? 'info'
}

function getPeriodTypeLabel(val) {
  return periodTypeMap[Number(val)] ?? '-'
}

function getMetricTypeLabel(val) {
  return metricTypeMap[Number(val)]?.label ?? '-'
}

function getMetricTypeTagType(val) {
  return metricTypeMap[Number(val)]?.tagType ?? 'info'
}

function formatNumber(val) {
  const num = Number(val || 0)
  if (isNaN(num)) return val
  return num.toLocaleString('zh-CN', { maximumFractionDigits: 2 })
}

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    goalName: undefined,
    ownerType: undefined,
    periodType: undefined,
    metricType: undefined,
    status: undefined
  },
  dialog: {
    open: false,
    title: '',
    goalId: null
  }
})

const { queryParams, dialog } = toRefs(data)

function getList() {
  loading.value = true
  listGoal(queryParams.value).then(response => {
    goalList.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleAdd() {
  dialog.value = { open: true, title: '新增目标', goalId: null }
}

function handleUpdate(row) {
  dialog.value = { open: true, title: '编辑目标', goalId: row.goalId }
}

function handleFormSuccess() {
  getList()
}

function handleSplit(row) {
  splitGoalId.value = row.goalId
  splitVisible.value = true
}

function handleSplitSuccess() {
  getList()
}

function handleStatusChange(row, val) {
  const text = val === '0' ? '启用' : '停用'
  proxy.$modal.confirm('确认要"' + text + '""' + row.goalName + '"吗？').then(() => {
    return updateGoal({ goalId: row.goalId, status: val })
  }).then(() => {
    proxy.$modal.msgSuccess(text + '成功')
  }).catch(() => {
    row.status = val === '0' ? '1' : '0'
  })
}

function handleDelete(row) {
  const goalIds = row.goalId
  proxy.$modal.confirm('是否确认删除目标"' + row.goalName + '"？').then(() => {
    return delGoal(goalIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function handleGenerateDaily(row) {
  proxy.$modal.confirm('确认为目标"' + row.goalName + '"手动生成日目标吗？').then(() => {
    return generateDaily(row.goalId)
  }).then(() => {
    proxy.$modal.msgSuccess('日目标生成成功')
  }).catch(() => {})
}

function handleProgress(row) {
  progressOpen.value = true
  progressLoading.value = true
  progressData.value = null
  getGoalProgress({ goalId: row.goalId }).then(response => {
    progressData.value = response.data || response
    progressLoading.value = false
  }).catch(() => {
    progressLoading.value = false
  })
}

function handleDailyDetail(row) {
  dailyOpen.value = true
  dailyLoading.value = true
  dailyData.value = null
  getDailyDetail(row.goalId).then(response => {
    dailyData.value = response.data || response
    dailyLoading.value = false
  }).catch(() => {
    dailyLoading.value = false
  })
}

function handleExport() {
  proxy.download('goal/export', {
    ...queryParams.value
  }, `goal_${new Date().getTime()}.xlsx`)
}

getList()
</script>
