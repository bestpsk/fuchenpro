<template>
  <div class="app-container" v-hasPermi="['statistics:inventory:list']">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="库存金额" name="summary">
        <el-row :gutter="16" style="margin-bottom: 16px;">
          <el-col :xs="12" :sm="6" v-for="item in summaryCards" :key="item.key">
            <div class="stat-item">
              <div class="stat-label">{{ item.label }}</div>
              <div class="stat-value primary">{{ item.value }}</div>
            </div>
          </el-col>
        </el-row>
        <el-table :data="summaryList" border v-loading="summaryLoading" show-summary :summary-method="getSummaryRow">
          <el-table-column label="仓库" prop="warehouseName" min-width="120" />
          <el-table-column label="货品种类" prop="productCount" min-width="100" align="center" />
          <el-table-column label="库存数量" prop="totalQty" min-width="100" align="center" />
          <el-table-column label="库存金额" min-width="130" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="库存预警" name="warning">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item>
            <el-button type="warning" plain icon="Download" @click="handleExportWarning">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="warningList" border v-loading="warningLoading">
          <el-table-column label="仓库" prop="warehouseName" min-width="100" />
          <el-table-column label="货品名称" prop="productName" min-width="140" show-overflow-tooltip />
          <el-table-column label="货品编码" prop="productCode" min-width="120" />
          <el-table-column label="当前库存" prop="quantity" min-width="90" align="center" />
          <el-table-column label="预警数量" prop="warnQty" min-width="90" align="center" />
          <el-table-column label="缺口数量" min-width="100" align="center">
            <template #default="{ row }">
              <span class="amount-red">{{ row.shortageQty }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="滞销货品" name="slowMoving">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="未出库天数">
            <el-input-number v-model="slowDays" :min="30" :max="365" :step="30" style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadSlowMoving">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportSlowMoving">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="slowMovingList" border v-loading="slowLoading">
          <el-table-column label="仓库" prop="warehouseName" min-width="100" />
          <el-table-column label="货品名称" prop="productName" min-width="140" show-overflow-tooltip />
          <el-table-column label="货品编码" prop="productCode" min-width="120" />
          <el-table-column label="库存数量" prop="quantity" min-width="90" align="center" />
          <el-table-column label="进货价" prop="purchasePrice" min-width="90" align="right" />
          <el-table-column label="库存金额" min-width="110" align="right">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.stockAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="最后出库时间" prop="lastStockOutTime" min-width="150" />
          <el-table-column label="未出库天数" min-width="100" align="center">
            <template #default="{ row }">
              <span :class="row.daysNoOut >= 90 ? 'amount-red' : 'amount-orange'">{{ row.daysNoOut }} 天</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="库存周转率" name="turnover">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围" required>
            <el-button-group style="margin-right: 12px">
              <el-button v-for="opt in shortcutOptions" :key="opt.value" size="small" :type="turnoverShortcut === opt.value ? 'primary' : ''" @click="applyTurnoverShortcut(opt.value)">{{ opt.label }}</el-button>
            </el-button-group>
            <el-date-picker v-model="turnoverDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadTurnover">查询</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="turnoverList" border v-loading="turnoverLoading">
          <el-table-column label="仓库" prop="warehouseName" min-width="120" />
          <el-table-column label="出库数量" prop="totalOutQty" min-width="100" align="center" />
          <el-table-column label="当前库存" prop="currentStockQty" min-width="100" align="center" />
          <el-table-column label="出库货品种类" prop="outProductCount" min-width="120" align="center" />
          <el-table-column label="库存货品种类" prop="productCount" min-width="120" align="center" />
          <el-table-column label="周转率" min-width="100" align="center">
            <template #default="{ row }">
              <span :class="getTurnoverClass(row.turnoverRate)">{{ (row.turnoverRate * 100).toFixed(2) }}%</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="InventoryStats">
import { ref, onMounted } from 'vue'
import { inventorySummary, slowMoving, inventoryWarning, turnover } from '@/api/statistics/wms'

const { proxy } = getCurrentInstance()
const activeTab = ref('summary')

const summaryList = ref([])
const summaryLoading = ref(false)
const summaryCards = ref([])

const warningList = ref([])
const warningLoading = ref(false)

const slowMovingList = ref([])
const slowLoading = ref(false)
const slowDays = ref(90)

const turnoverList = ref([])
const turnoverLoading = ref(false)
const turnoverDateRange = ref([])
const turnoverShortcut = ref('')

const shortcutOptions = [
  { label: '本月', value: 'month' },
  { label: '近3月', value: 'quarter' },
  { label: '近半年', value: 'halfYear' }
]

onMounted(() => {
  loadSummary()
  loadWarning()
  loadSlowMoving()
})

function loadSummary() {
  summaryLoading.value = true
  inventorySummary().then(res => {
    const data = res.data || res || {}
    summaryList.value = data.list || []
    const total = data.total || {}
    summaryCards.value = [
      { key: 'totalAmount', label: '库存总金额', value: formatMoney(total.totalAmount) },
      { key: 'totalQty', label: '库存总数量', value: total.totalQty || 0 },
      { key: 'productCount', label: '货品种类', value: total.productCount || 0 },
      { key: 'warehouseCount', label: '仓库数量', value: summaryList.value.length }
    ]
  }).finally(() => {
    summaryLoading.value = false
  })
}

function loadWarning() {
  warningLoading.value = true
  inventoryWarning().then(res => {
    warningList.value = res.data || res || []
  }).finally(() => {
    warningLoading.value = false
  })
}

function loadSlowMoving() {
  slowLoading.value = true
  slowMoving({ days: slowDays.value }).then(res => {
    slowMovingList.value = res.data || res || []
  }).finally(() => {
    slowLoading.value = false
  })
}

function loadTurnover() {
  if (!turnoverDateRange.value || turnoverDateRange.value.length !== 2) {
    return proxy.$modal.msgWarning('请选择日期范围')
  }
  turnoverLoading.value = true
  turnover({ startDate: turnoverDateRange.value[0], endDate: turnoverDateRange.value[1] }).then(res => {
    turnoverList.value = res.data || res || []
  }).finally(() => {
    turnoverLoading.value = false
  })
}

function applyTurnoverShortcut(value) {
  turnoverShortcut.value = value
  const now = new Date()
  const end = new Date(now)
  const start = new Date(now)
  if (value === 'month') {
    start.setDate(1)
  } else if (value === 'quarter') {
    start.setMonth(now.getMonth() - 3)
  } else if (value === 'halfYear') {
    start.setMonth(now.getMonth() - 6)
  }
  const fmt = (d) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`
  turnoverDateRange.value = [fmt(start), fmt(end)]
  loadTurnover()
}

function handleExportSlowMoving() {
  proxy.download('statistics/wms/exportSlowMoving', { days: slowDays.value }, `滞销货品预警_${new Date().getTime()}.xlsx`)
}

function handleExportWarning() {
  proxy.download('statistics/wms/exportWarning', {}, `库存预警_${new Date().getTime()}.xlsx`)
}

function getTurnoverClass(rate) {
  if (rate >= 0.5) return 'amount-blue'
  if (rate >= 0.1) return 'amount-orange'
  return 'amount-red'
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function getSummaryRow({ columns, data }) {
  const sums = []
  columns.forEach((column, index) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    const fields = ['productCount', 'totalQty', 'totalAmount']
    if (fields.includes(column.property)) {
      const values = data.map(item => Number(item[column.property]))
      const sum = values.reduce((prev, curr) => prev + curr, 0)
      sums[index] = column.property === 'totalAmount' ? formatMoney(sum) : sum
    } else {
      sums[index] = ''
    }
  })
  return sums
}
</script>

<style scoped lang="scss">
.stat-item {
  padding: 16px;
  border-radius: 8px;
  background: var(--el-bg-color);
  margin-bottom: 12px;
  border: 1px solid #ebeef5;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 8px;
}
.stat-value {
  font-size: 22px;
  font-weight: 700;
  &.primary { color: #3D6DF7; }
}
.amount-blue {
  color: #3D6DF7;
  font-weight: 500;
}
.amount-red {
  color: #f56c6c;
  font-weight: 500;
}
.amount-orange {
  color: #e6a23c;
  font-weight: 500;
}
</style>
