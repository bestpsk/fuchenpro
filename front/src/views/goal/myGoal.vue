<template>
  <div class="app-container">
    <!-- 顶部周期筛选 -->
    <el-card shadow="never" class="filter-card">
      <el-tabs v-model="activePeriod" @tab-change="handleQuery">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="月度" name="3" />
        <el-tab-pane label="季度" name="2" />
        <el-tab-pane label="年度" name="1" />
        <el-tab-pane label="自定义" name="4" />
      </el-tabs>
    </el-card>

    <!-- 二级 Tab：个人目标 / 团队目标 -->
    <el-card shadow="never" class="scope-card">
      <el-tabs v-model="activeScope" @tab-change="handleQuery">
        <el-tab-pane label="个人目标" name="personal" />
        <el-tab-pane label="团队目标" name="team" />
      </el-tabs>
    </el-card>

    <!-- 加载中 -->
    <div v-loading="loading" style="min-height: 200px">
      <!-- 空状态 -->
      <el-empty v-if="!loading && goalList.length === 0" :description="activeScope === 'team' ? '暂无团队目标（需部门负责人权限）' : '暂无个人目标'">
        <template #image>
          <el-icon :size="64" color="#C0C4CC"><DataLine /></el-icon>
        </template>
        <el-button v-if="activeScope === 'personal'" type="primary" @click="goToList" v-hasPermi="['goal:add']">去设置目标</el-button>
      </el-empty>

      <!-- 目标卡片列表 -->
      <div v-else class="goal-card-list">
        <el-card v-for="item in goalList" :key="item.goalId" class="goal-card" shadow="hover">
          <!-- 卡片头部 -->
          <div class="card-header">
            <div class="header-left">
              <span class="goal-name">{{ item.goalName }}</span>
              <el-tag size="small" effect="plain" :type="metricTagType(item.metricType)">{{ metricLabel(item.metricType) }}</el-tag>
              <el-tag size="small" type="info" effect="plain">{{ periodLabel(item.periodType) }} · {{ item.ownerName }}</el-tag>
            </div>
            <div class="header-right">
              <span class="date-range">{{ item.startDate }} ~ {{ item.endDate }}</span>
            </div>
          </div>

          <!-- 完成率进度条 -->
          <div class="progress-section">
            <el-progress
              :percentage="Math.round((item.completionRate || 0) * 100)"
              :color="getRateColor(item.completionRate)"
              :stroke-width="20"
              :text-inside="true"
              :format="(p) => p + '%'"
            />
          </div>

          <!-- 数据三列：目标值 / 已完成 / 差额 -->
          <el-row :gutter="16" class="data-row">
            <el-col :span="8">
              <div class="data-cell">
                <div class="data-label">目标值</div>
                <div class="data-value target">
                  {{ formatValue(item.targetValue, item.metricType) }}
                  <span class="data-unit" v-if="item.metricType">{{ metricUnit(item.metricType) }}</span>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="data-cell">
                <div class="data-label">已完成</div>
                <div class="data-value completed">
                  {{ formatValue(item.completed, item.metricType) }}
                  <span class="data-unit" v-if="item.metricType">{{ metricUnit(item.metricType) }}</span>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="data-cell">
                <div class="data-label">差额</div>
                <div class="data-value" :class="(item.diff || 0) > 0 ? 'diff-positive' : 'diff-negative'">
                  {{ formatValue(item.diff, item.metricType) }}
                  <span class="data-unit" v-if="item.metricType">{{ metricUnit(item.metricType) }}</span>
                </div>
              </div>
            </el-col>
          </el-row>

          <!-- 今日数据 -->
          <el-divider content-position="left">
            <span class="divider-text">今日数据</span>
          </el-divider>
          <el-row :gutter="16" class="today-row">
            <el-col :span="8">
              <div class="today-cell">
                <span class="today-label">今日目标</span>
                <span class="today-value">{{ formatValue(item.todayTarget, item.metricType) }}</span>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="today-cell">
                <span class="today-label">今日已完成</span>
                <span class="today-value blue">{{ formatValue(item.todayCompleted, item.metricType) }}</span>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="today-cell">
                <span class="today-label">今日差额</span>
                <span class="today-value" :class="todayDiff(item) >= 0 ? 'green' : 'red'">
                  {{ todayDiff(item) >= 0 ? '+' : '' }}{{ formatValue(todayDiff(item), item.metricType) }}
                </span>
              </div>
            </el-col>
          </el-row>

          <!-- 核心指标网格 -->
          <el-divider content-position="left">
            <span class="divider-text">核心指标</span>
          </el-divider>
          <div class="metrics-grid">
            <div class="metric-item">
              <span class="metric-label">已过天数</span>
              <span class="metric-value">{{ item.passedWorkDays ?? 0 }} 天</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">剩余天数</span>
              <span class="metric-value blue">{{ item.remainWorkDays ?? 0 }} 天</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">当前日均产出</span>
              <span class="metric-value">{{ formatValue(item.currentDaily, item.metricType) }}</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">剩余日均需完成</span>
              <span class="metric-value orange">{{ formatValue(item.remainDailyNeed, item.metricType) }}</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">预计达成日</span>
              <span class="metric-value">
                <el-tag v-if="item.expectedAchieveDate" type="success" size="small">{{ item.expectedAchieveDate }}</el-tag>
                <span v-else class="gray">-</span>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">月末预测完成率</span>
              <span class="metric-value" :style="{ color: getRateColor(item.forecastRate) }">
                {{ item.forecastRateText || '0%' }}
              </span>
            </div>
          </div>

          <!-- 团队目标专属：员工明细下钻 -->
          <div v-if="activeScope === 'team' && item.children && item.children.length" class="children-section">
            <el-divider content-position="left">
              <el-button link type="primary" @click="toggleChildren(item)">
                <el-icon><ArrowDown v-if="!item._expanded" /><ArrowUp v-else /></el-icon>
                查看员工明细（{{ item.children.length }}）
              </el-button>
            </el-divider>
            <div v-show="item._expanded" class="children-list">
              <div v-for="child in item.children" :key="child.goalId" class="child-row">
                <div class="child-header">
                  <span class="child-name">{{ child.ownerName || '-' }}</span>
                  <el-tag size="small" :type="child.ownerType === 4 ? 'info' : 'warning'" effect="plain">
                    {{ child.ownerType === 4 ? '员工' : (child.ownerType === 2 ? '子部门' : '其他') }}
                  </el-tag>
                  <span class="child-completed">
                    {{ formatValue(child.completed, child.metricType) }} / {{ formatValue(child.targetValue, child.metricType) }}
                    <span class="data-unit" v-if="child.metricType">{{ metricUnit(child.metricType) }}</span>
                  </span>
                  <span class="child-rate" :style="{ color: getRateColor(child.completionRate) }">
                    {{ Math.round((child.completionRate || 0) * 100) }}%
                  </span>
                </div>
                <el-progress
                  :percentage="Math.round((child.completionRate || 0) * 100)"
                  :color="getRateColor(child.completionRate)"
                  :stroke-width="10"
                  :show-text="false"
                />
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup name="MyGoal">
import { getMyGoals, getTeamGoals } from '@/api/goal'
import { ArrowDown, ArrowUp } from '@element-plus/icons-vue'

const { proxy } = getCurrentInstance()

const loading = ref(false)
const goalList = ref([])
const activePeriod = ref('')
const activeScope = ref('personal')

const metricMap = {
  1: { label: '实收业绩', unit: '元' },
  2: { label: '消耗业绩', unit: '元' },
  3: { label: '出货金额', unit: '元' },
  4: { label: '品项件数', unit: '件' },
  5: { label: '品项金额', unit: '元' },
  6: { label: '到店客次', unit: '人次' },
  7: { label: '新客数', unit: '人次' },
  8: { label: '活跃门店数', unit: '家' }
}

const periodMap = { 1: '年度', 2: '季度', 3: '月度', 4: '自定义' }

function metricLabel(type) {
  return metricMap[type]?.label || '-'
}
function metricUnit(type) {
  return metricMap[type]?.unit || ''
}
function metricTagType(type) {
  return [4, 5].includes(Number(type)) ? 'warning' : 'info'
}
function periodLabel(type) {
  return periodMap[type] || '-'
}

function isMoneyMetric(metricType) {
  return [1, 2, 3, 5].includes(Number(metricType))
}

function formatValue(value, metricType) {
  const num = Number(value || 0)
  if (isNaN(num)) return value
  if (isMoneyMetric(metricType)) {
    return num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
  return num.toLocaleString('zh-CN')
}

function getRateColor(rate) {
  const r = Number(rate) || 0
  if (r < 0.7) return '#f56c6c'
  if (r < 1) return '#e6a23c'
  return '#67c23a'
}

function todayDiff(item) {
  return (Number(item.todayCompleted) || 0) - (Number(item.todayTarget) || 0)
}

function loadData() {
  loading.value = true
  const params = {}
  if (activePeriod.value) params.periodType = activePeriod.value
  const api = activeScope.value === 'team' ? getTeamGoals : getMyGoals
  api(params).then(res => {
    // 团队目标每项追加 _expanded 标志（控制明细展开）
    goalList.value = (res.data || []).map(g => ({ ...g, _expanded: false }))
  }).catch(() => {
    goalList.value = []
  }).finally(() => {
    loading.value = false
  })
}

function toggleChildren(item) {
  item._expanded = !item._expanded
}

function handleQuery() {
  loadData()
}

function goToList() {
  proxy.$router.push('/goal/index')
}

onMounted(() => {
  loadData()
})
</script>

<style scoped lang="scss">
.filter-card {
  margin-bottom: 16px;
}

.goal-card-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.goal-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.goal-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.date-range {
  font-size: 13px;
  color: #909399;
}

.progress-section {
  margin-bottom: 20px;
}

.data-row {
  margin-bottom: 8px;
}

.data-cell {
  text-align: center;
  padding: 12px;
  background: #f7f8fa;
  border-radius: 8px;
}

.data-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 6px;
}

.data-value {
  font-size: 20px;
  font-weight: 600;
  line-height: 1.3;
}

.data-value.target {
  color: #303133;
}

.data-value.completed {
  color: #67c23a;
}

.diff-positive {
  color: #67c23a;
}

.diff-negative {
  color: #f56c6c;
}

.data-unit {
  font-size: 13px;
  color: #909399;
  font-weight: 400;
  margin-left: 4px;
}

.divider-text {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
}

.today-row {
  margin-bottom: 8px;
}

.today-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 10px;
}

.today-label {
  font-size: 13px;
  color: #909399;
}

.today-value {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.today-value.blue { color: #3D6DF7; }
.today-value.green { color: #67c23a; }
.today-value.red { color: #f56c6c; }

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.metric-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px;
  background: #f7f8fa;
  border-radius: 8px;
}

.metric-label {
  font-size: 12px;
  color: #909399;
}

.metric-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.metric-value.blue { color: #3D6DF7; }
.metric-value.orange { color: #e6a23c; }
.metric-value.gray { color: #c0c4cc; }

.scope-card {
  margin-bottom: 16px;
}
.scope-card :deep(.el-tabs__header) {
  margin-bottom: 0;
}

.children-section {
  margin-top: 8px;
}
.children-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-top: 4px;
}
.child-row {
  background: #fafbfc;
  border-radius: 8px;
  padding: 10px 12px;
}
.child-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}
.child-name {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  min-width: 80px;
}
.child-completed {
  font-size: 13px;
  color: #606266;
  margin-left: auto;
}
.child-rate {
  font-size: 14px;
  font-weight: 600;
  min-width: 48px;
  text-align: right;
}
</style>
