<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" type="border-card" @tab-change="handleTabChange">
      <!-- Tab 1: 考勤视图（日历格子） -->
      <el-tab-pane label="考勤视图" name="calendar">
        <div v-show="activeTab === 'calendar'" class="calendar-tab">
          <el-form :model="calendarQuery" :inline="true" label-width="68px">
            <el-form-item label="年月" prop="yearMonth">
              <el-date-picker v-model="calendarQuery.yearMonth" type="month" placeholder="选择年月" value-format="YYYY-MM" style="width: 160px" @change="loadCalendar" />
            </el-form-item>
            <el-form-item label="部门" prop="deptId">
              <el-tree-select v-model="calendarQuery.deptId" :data="deptOptions" :props="{ value: 'id', label: 'label', children: 'children' }" value-key="id" placeholder="请选择部门" clearable check-strictly style="width: 200px" />
            </el-form-item>
            <el-form-item label="员工姓名" prop="userName">
              <el-input v-model="calendarQuery.userName" placeholder="请输入员工姓名" clearable style="width: 160px" @keyup.enter="loadCalendar" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="Search" @click="loadCalendar">搜索</el-button>
              <el-button icon="Refresh" @click="resetCalendarQuery">重置</el-button>
            </el-form-item>
          </el-form>

          <!-- 图例 -->
          <div class="legend-bar">
            <span class="legend-title">图例：</span>
            <span v-for="item in legendList" :key="item.status" class="legend-item">
              <span class="legend-color" :style="{ background: item.color }"></span>
              {{ item.label }}
            </span>
          </div>

          <!-- 日历网格 -->
          <div class="calendar-grid" v-loading="calendarLoading">
            <div class="header-row">
              <div class="name-header">员工姓名</div>
              <div class="days-header">
                <div v-for="day in daysInMonth" :key="day" class="day-header">{{ day }}</div>
              </div>
            </div>
            <div v-if="calendarList.length === 0" class="empty-row">
              <el-empty description="暂无数据" />
            </div>
            <div v-for="row in calendarList" :key="row.userId" class="data-row">
              <div class="name-cell">
                <div class="name-text">{{ row.userName }}</div>
                <el-tag v-if="row.deptName" size="small" type="info" class="mt-1">{{ row.deptName }}</el-tag>
              </div>
              <div class="days-container">
                <el-tooltip
                  v-for="d in row.days"
                  :key="d.date"
                  :content="formatDayTooltip(d)"
                  placement="top"
                  effect="dark"
                  :show-after="200"
                >
                  <div
                    class="day-cell"
                    :style="{ background: d.color + '33', borderColor: d.color }"
                  >
                    <span class="day-label" :style="{ color: d.color }">{{ d.statusLabel }}</span>
                  </div>
                </el-tooltip>
              </div>
            </div>
          </div>

          <!-- 底部统计汇总 -->
          <div class="summary-bar" v-if="calendarSummary">
            <span class="summary-title">本月汇总：</span>
            <span class="summary-item">正常 <b style="color:#67C23A">{{ calendarSummary.normalDays || 0 }}</b></span>
            <span class="summary-item">迟到 <b style="color:#E6A23C">{{ calendarSummary.lateDays || 0 }}</b></span>
            <span class="summary-item">早退 <b style="color:#F56C6C">{{ calendarSummary.earlyLeaveDays || 0 }}</b></span>
            <span class="summary-item">缺勤 <b style="color:#F56C6C">{{ calendarSummary.absentDays || 0 }}</b></span>
            <span class="summary-item">请假 <b style="color:#3D6DF7">{{ calendarSummary.leaveDays || 0 }}</b></span>
            <span class="summary-item">休息日 <b style="color:#909399">{{ calendarSummary.restDays || 0 }}</b></span>
            <span class="summary-item">公共假期 <b style="color:#9C27B0">{{ calendarSummary.holidayDays || 0 }}</b></span>
            <span class="summary-item rate">出勤率 <b :style="{ color: getRateColor(calendarSummary.attendanceRate) }">{{ formatRate(calendarSummary.attendanceRate) }}</b></span>
          </div>
        </div>
      </el-tab-pane>

      <!-- Tab 2: 考勤统计（原有表格统计，完整保留） -->
      <el-tab-pane label="考勤统计" name="stats">
        <div v-show="activeTab === 'stats'">
          <el-form :model="queryParams" ref="queryRef" :inline="true" label-width="68px">
            <el-form-item label="日期范围" prop="dateRange">
              <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
            </el-form-item>
            <el-form-item label="员工姓名" prop="userName">
              <el-input v-model="queryParams.userName" placeholder="请输入员工姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
            </el-form-item>
            <el-form-item label="部门" prop="deptId">
              <el-tree-select v-model="queryParams.deptId" :data="deptOptions" :props="{ value: 'id', label: 'label', children: 'children' }" value-key="id" placeholder="请选择部门" clearable check-strictly style="width: 200px" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
              <el-button icon="Refresh" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>

          <el-row :gutter="10" class="mb8">
            <el-col :span="1.5">
              <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:attendance:stats:export']">导出</el-button>
            </el-col>
          </el-row>

          <el-table v-loading="loading" :data="statsList" border style="width: 100%" show-summary :summary-method="getSummary">
            <el-table-column label="员工" align="center" prop="userName" min-width="100" />
            <el-table-column label="部门" align="center" prop="deptName" min-width="120" show-overflow-tooltip />
            <el-table-column label="应出勤" align="center" prop="shouldAttendDays" min-width="80" />
            <el-table-column label="正常" align="center" prop="normalDays" min-width="70" />
            <el-table-column label="迟到" align="center" prop="lateDays" min-width="70" />
            <el-table-column label="早退" align="center" prop="earlyLeaveDays" min-width="70" />
            <el-table-column label="迟到+早退" align="center" prop="lateEarlyDays" min-width="100" />
            <el-table-column label="缺勤" align="center" prop="absentDays" min-width="70" />
            <el-table-column label="休息日" align="center" prop="restDays" min-width="80" />
            <el-table-column label="请假" align="center" prop="leaveDays" min-width="70" />
            <el-table-column label="公共假期" align="center" prop="holidayDays" min-width="100" />
            <el-table-column label="出勤率" align="center" prop="attendanceRate" min-width="100">
              <template #default="scope">
                <span :style="{ color: getRateColor(scope.row.attendanceRate), fontWeight: 'bold' }">{{ formatRate(scope.row.attendanceRate) }}</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="AttendanceStats">
import { listAttendanceStats, listAttendanceCalendar } from "@/api/business/attendanceStats"
import { treeselect } from "@/api/system/dept"

const { proxy } = getCurrentInstance()

// ============== 公共部分 ==============
const activeTab = ref('calendar')
const deptOptions = ref([])

function getDeptTree() {
  treeselect().then(response => { deptOptions.value = response.data || [] })
}

function handleTabChange() {
  if (activeTab.value === 'calendar') loadCalendar()
  else if (activeTab.value === 'stats') getList()
}

// ============== Tab 1: 考勤视图（日历） ==============
const calendarLoading = ref(false)
const calendarList = ref([])
const calendarSummary = ref(null)
const daysInMonth = ref(31)
const currentYearMonth = ref(new Date().toISOString().slice(0, 7))

const calendarQuery = reactive({
  yearMonth: currentYearMonth.value,
  userName: undefined,
  deptId: undefined
})

const legendList = [
  { status: '0', label: '正常', color: '#67C23A' },
  { status: '1', label: '迟到', color: '#E6A23C' },
  { status: '2', label: '早退', color: '#F56C6C' },
  { status: '3', label: '迟到早退', color: '#F56C6C' },
  { status: '4', label: '缺勤', color: '#F56C6C' },
  { status: '5', label: '公共假期', color: '#9C27B0' },
  { status: '6', label: '休息日', color: '#909399' },
  { status: '7', label: '请假', color: '#3D6DF7' }
]

function loadCalendar() {
  if (!calendarQuery.yearMonth) return
  calendarLoading.value = true
  currentYearMonth.value = calendarQuery.yearMonth
  daysInMonth.value = new Date(calendarQuery.yearMonth.slice(0, 4), calendarQuery.yearMonth.slice(5, 7), 0).getDate()

  listAttendanceCalendar({
    yearMonth: calendarQuery.yearMonth,
    userName: calendarQuery.userName,
    deptId: calendarQuery.deptId
  }).then(response => {
    const data = response.data || response
    calendarList.value = data?.list || []
    calendarSummary.value = data?.summary || null
    calendarLoading.value = false
  }).catch(() => { calendarLoading.value = false })
}

function resetCalendarQuery() {
  calendarQuery.yearMonth = new Date().toISOString().slice(0, 7)
  calendarQuery.userName = undefined
  calendarQuery.deptId = undefined
  loadCalendar()
}

function formatDayTooltip(d) {
  return `${d.date}（${d.statusLabel}）${d.remark ? ' - ' + d.remark : ''}`
}

// ============== Tab 2: 考勤统计（原有表格，完整保留） ==============
const statsList = ref([])
const totals = ref({})
const loading = ref(false)
const dateRange = ref([])

const queryParams = reactive({
  dateRangeStart: undefined,
  dateRangeEnd: undefined,
  userName: undefined,
  deptId: undefined
})

const summaryFields = ['shouldAttendDays', 'normalDays', 'lateDays', 'earlyLeaveDays', 'lateEarlyDays', 'absentDays', 'restDays', 'leaveDays', 'holidayDays']

function getDefaultDateRange() {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  const fmt = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  return [fmt(start), fmt(end)]
}

function getList() {
  loading.value = true
  const params = { ...queryParams }
  if (dateRange.value && dateRange.value.length === 2) {
    params.dateRangeStart = dateRange.value[0]
    params.dateRangeEnd = dateRange.value[1]
  } else {
    params.dateRangeStart = undefined
    params.dateRangeEnd = undefined
  }
  listAttendanceStats(params).then(response => {
    const resData = response.data || response
    statsList.value = resData?.list || []
    totals.value = resData?.totals || {}
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { getList() }

function resetQuery() {
  dateRange.value = getDefaultDateRange()
  queryParams.userName = undefined
  queryParams.deptId = undefined
  handleQuery()
}

function getSummary({ columns }) {
  const sums = []
  columns.forEach((column, index) => {
    if (index === 0) { sums[index] = '合计'; return }
    if (index === 1) { sums[index] = ''; return }
    const prop = column.property
    if (summaryFields.includes(prop)) {
      sums[index] = totals.value[prop] ?? 0
    } else if (prop === 'attendanceRate') {
      sums[index] = formatRate(totals.value[prop])
    } else {
      sums[index] = ''
    }
  })
  return sums
}

// ============== 公共函数 ==============
function getRateColor(rate) {
  const num = Number(rate)
  if (isNaN(num)) return ''
  if (num >= 90) return '#67c23a'
  if (num >= 80) return '#e6a23c'
  return '#f56c6c'
}

function formatRate(rate) {
  const num = Number(rate)
  if (isNaN(num)) return '-'
  return num.toFixed(2) + '%'
}

function handleExport() {
  proxy.$modal.msgWarning("导出功能开发中")
}

// ============== 初始化 ==============
getDeptTree()
loadCalendar()
</script>

<style scoped>
/* 图例 */
.legend-bar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  padding: 8px 12px;
  background: #fafafa;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  margin-bottom: 12px;
  font-size: 13px;
}
.legend-title {
  font-weight: 600;
  color: #303133;
}
.legend-item {
  display: inline-flex;
  align-items: center;
  color: #606266;
}
.legend-color {
  display: inline-block;
  width: 14px;
  height: 14px;
  border-radius: 2px;
  margin-right: 4px;
  border: 1px solid #dcdfe6;
}

/* 日历网格 */
.calendar-grid {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  overflow: hidden;
}
.header-row {
  display: flex;
  background: #f5f7fa;
  border-bottom: 1px solid #ebeef5;
  position: sticky;
  top: 0;
  z-index: 1;
}
.name-header {
  flex: 0 0 120px;
  padding: 8px;
  text-align: center;
  font-weight: 600;
  border-right: 1px solid #ebeef5;
  color: #303133;
}
.days-header {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(31, minmax(34px, 1fr));
  min-width: 0;
}
.day-header {
  padding: 8px 0;
  text-align: center;
  font-size: 12px;
  color: #606266;
  border-right: 1px solid #ebeef5;
}
.data-row {
  display: flex;
  border-bottom: 1px solid #ebeef5;
}
.data-row:hover {
  background: #f5f7fa;
}
.name-cell {
  flex: 0 0 120px;
  padding: 8px 4px;
  text-align: center;
  border-right: 1px solid #ebeef5;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.name-text {
  font-size: 13px;
  font-weight: 600;
  color: #303133;
}
.days-container {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(31, minmax(34px, 1fr));
  min-width: 0;
}
.day-cell {
  border-right: 1px solid #ebeef5;
  border-bottom: 1px solid transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px 0;
  min-height: 36px;
  cursor: default;
}
.day-label {
  font-size: 11px;
  font-weight: 600;
  white-space: nowrap;
}

/* 空数据 */
.empty-row {
  padding: 24px 0;
}

/* 底部汇总 */
.summary-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  padding: 12px 16px;
  background: #fafafa;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  margin-top: 12px;
  font-size: 13px;
  color: #606266;
}
.summary-title {
  font-weight: 600;
  color: #303133;
}
.summary-item b {
  margin-left: 4px;
  font-weight: 600;
}
.summary-item.rate {
  margin-left: auto;
}
.summary-item.rate b {
  font-size: 14px;
}
</style>
