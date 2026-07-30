<template>
  <div class="app-container" v-hasPermi="['train:stats:list']">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="日期范围" required>
        <el-button-group style="margin-right: 12px">
          <el-button
            v-for="opt in shortcutOptions"
            :key="opt.value"
            size="small"
            :type="shortcut === opt.value ? 'primary' : ''"
            @click="applyShortcut(opt.value)"
          >{{ opt.label }}</el-button>
        </el-button-group>
        <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" @change="onDateChange" />
      </el-form-item>
      <el-form-item label="材料标题" prop="materialTitle">
        <el-input v-model="queryParams.materialTitle" placeholder="请输入材料标题" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="用户姓名" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入用户姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['train:stats:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 汇总卡片 -->
    <el-row :gutter="16" class="summary-row" v-if="summary">
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-label">总学习时长</div>
          <div class="summary-value">{{ formatDuration(summary.totalDuration) }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-label">总学习次数</div>
          <div class="summary-value">{{ summary.totalCount || 0 }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-label">涉及用户</div>
          <div class="summary-value">{{ summary.userCount || 0 }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-label">涉及材料</div>
          <div class="summary-value">{{ summary.materialCount || 0 }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="statsList" border style="width: 100%; margin-top: 16px" show-summary :summary-method="getSummary">
      <el-table-column label="用户姓名" prop="userName" min-width="100" show-overflow-tooltip />
      <el-table-column label="所属部门" prop="deptName" min-width="120" show-overflow-tooltip />
      <el-table-column label="材料标题" prop="materialTitle" min-width="180" show-overflow-tooltip />
      <el-table-column label="累计学习时长" prop="totalDuration" min-width="130" align="center">
        <template #default="scope">{{ formatDuration(scope.row.totalDuration) }}</template>
      </el-table-column>
      <el-table-column label="学习次数" prop="studyCount" min-width="90" align="center" />
      <el-table-column label="最后学习时间" prop="lastStudyTime" min-width="160" />
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup name="TrainStats">
import { listStudyStats, getStudyStatsSummary } from "@/api/train/stats"

const { proxy } = getCurrentInstance()

const statsList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const summary = ref(null)
const dateRange = ref([])
const shortcut = ref('')

const shortcutOptions = [
  { label: '今天', value: 'today' },
  { label: '本周', value: 'week' },
  { label: '本月', value: 'month' },
  { label: '上月', value: 'lastMonth' },
]

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, materialTitle: undefined, userName: undefined }
})
const { queryParams } = toRefs(data)

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  seconds = parseInt(seconds)
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  if (h > 0) return `${h}时${m}分${s}秒`
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

function applyShortcut(val) {
  shortcut.value = val
  const now = new Date()
  let start, end
  switch (val) {
    case 'today':
      start = end = now
      break
    case 'week': {
      const day = now.getDay() || 7
      start = new Date(now)
      start.setDate(now.getDate() - day + 1)
      end = now
      break
    }
    case 'month':
      start = new Date(now.getFullYear(), now.getMonth(), 1)
      end = now
      break
    case 'lastMonth':
      start = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      end = new Date(now.getFullYear(), now.getMonth(), 0)
      break
  }
  dateRange.value = [formatDate(start), formatDate(end)]
  handleQuery()
}

function formatDate(d) {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function onDateChange() {
  shortcut.value = ''
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  listStudyStats(params).then(response => {
    statsList.value = response.rows
    total.value = response.total
    loading.value = false
  })
  getStudyStatsSummary(params).then(response => {
    summary.value = response.data
  })
}

function getSummary({ columns, data }) {
  const sums = []
  columns.forEach((col, index) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    if (col.property === 'totalDuration') {
      const total = data.reduce((sum, row) => sum + (parseInt(row.totalDuration) || 0), 0)
      sums[index] = formatDuration(total)
    } else if (col.property === 'studyCount') {
      const total = data.reduce((sum, row) => sum + (parseInt(row.studyCount) || 0), 0)
      sums[index] = total
    } else {
      sums[index] = ''
    }
  })
  return sums
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); dateRange.value = []; shortcut.value = ''; handleQuery() }

function handleExport() {
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  proxy.download("train/stats/export", params, `学习统计_${new Date().getTime()}.xlsx`)
}

getList()
</script>

<style scoped>
.summary-row {
  margin-bottom: 0;
}
.summary-card {
  text-align: center;
}
.summary-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 8px;
}
.summary-value {
  font-size: 20px;
  font-weight: 600;
  color: #3D6DF7;
}
</style>
