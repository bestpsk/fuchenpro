<template>
  <div class="app-container" v-hasPermi="['statistics:product:list']">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="销售排行" name="ranking">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="rankingDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item label="显示数量">
            <el-input-number v-model="rankingLimit" :min="5" :max="100" :step="5" style="width: 120px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadRanking">查询</el-button>
            <el-button type="warning" plain icon="Download" @click="handleExportRanking">导出</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="rankingList" border v-loading="rankingLoading">
          <el-table-column label="排名" min-width="60" align="center">
            <template #default="{ $index }">
              <span :class="$index < 3 ? 'rank-top' : ''">{{ $index + 1 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="货品名称" prop="productName" min-width="160" show-overflow-tooltip />
          <el-table-column label="销售数量" prop="totalQty" min-width="100" align="center" sortable />
          <el-table-column label="销售金额" min-width="130" align="right" sortable :sort-method="(a,b) => a.totalAmount - b.totalAmount">
            <template #default="{ row }">
              <span class="amount-blue">{{ formatMoney(row.totalAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="平均单价" min-width="100" align="right">
            <template #default="{ row }">
              <span>{{ formatMoney(row.avgPrice) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="订单数" prop="orderCount" min-width="80" align="center" />
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="取消率" name="cancel">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="cancelDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadCancelRate">查询</el-button>
          </el-form-item>
        </el-form>
        <el-row :gutter="16" style="margin-bottom: 16px">
          <el-col :xs="12" :sm="6">
            <div class="summary-card">
              <div class="summary-label">成交数量</div>
              <div class="summary-value amount-green">{{ cancelTotal.dealQty || 0 }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6">
            <div class="summary-card">
              <div class="summary-label">取消数量</div>
              <div class="summary-value amount-red">{{ cancelTotal.cancelQty || 0 }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6">
            <div class="summary-card">
              <div class="summary-label">总数量</div>
              <div class="summary-value">{{ cancelTotal.totalQty || 0 }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6">
            <div class="summary-card">
              <div class="summary-label">综合取消率</div>
              <div class="summary-value amount-red">{{ cancelTotal.cancelRate || 0 }}%</div>
            </div>
          </el-col>
        </el-row>
        <el-table :data="cancelList" border v-loading="cancelLoading">
          <el-table-column label="货品名称" prop="productName" min-width="160" show-overflow-tooltip />
          <el-table-column label="成交数量" prop="dealQty" min-width="100" align="center" />
          <el-table-column label="取消数量" prop="cancelQty" min-width="100" align="center" />
          <el-table-column label="总数量" prop="totalQty" min-width="100" align="center" />
          <el-table-column label="取消率" min-width="120" align="center">
            <template #default="{ row }">
              <span :class="getCancelRateClass(row.cancelRate)">{{ row.cancelRate }}%</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="利润分析" name="profit">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="日期范围">
            <el-date-picker v-model="profitDateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="loadProfit">查询</el-button>
          </el-form-item>
        </el-form>
        <el-table :data="profitList" border v-loading="profitLoading" max-height="600">
          <el-table-column label="货品名称" prop="productName" min-width="140" show-overflow-tooltip />
          <el-table-column label="编码" prop="productCode" min-width="100" show-overflow-tooltip />
          <el-table-column label="规格" prop="spec" min-width="80" />
          <el-table-column label="销售数" prop="totalQty" min-width="70" align="center" />
          <el-table-column label="成本价" min-width="90" align="right">
            <template #default="{ row }">
              <span>{{ formatMoney(row.purchasePrice) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实际均价" min-width="90" align="right">
            <template #default="{ row }">
              <span>{{ formatMoney(row.avgActualPrice) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="挂牌价" min-width="90" align="right">
            <template #default="{ row }">
              <span>{{ formatMoney(row.salePrice) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实际利润" min-width="110" align="right">
            <template #default="{ row }">
              <span :class="row.profitActual >= 0 ? 'amount-green' : 'amount-red'">{{ formatMoney(row.profitActual) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实际利润率" min-width="100" align="center">
            <template #default="{ row }">
              <span class="amount-blue">{{ row.profitRateActual }}%</span>
            </template>
          </el-table-column>
          <el-table-column label="挂牌利润" min-width="110" align="right">
            <template #default="{ row }">
              <span class="amount-gray">{{ formatMoney(row.profitListed) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="挂牌利润率" min-width="100" align="center">
            <template #default="{ row }">
              <span class="amount-gray">{{ row.profitRateListed }}%</span>
            </template>
          </el-table-column>
          <el-table-column label="折扣影响" min-width="110" align="right">
            <template #default="{ row }">
              <span :class="row.discountImpact >= 0 ? 'amount-gray' : 'amount-red'">{{ formatMoney(row.discountImpact) }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="ProductStats">
import { ref, onMounted } from 'vue'
import { salesRanking, cancelRate, profitAnalysis } from '@/api/statistics/product'

const { proxy } = getCurrentInstance()
const activeTab = ref('ranking')

// 销售排行
const rankingList = ref([])
const rankingLoading = ref(false)
const rankingDateRange = ref([])
const rankingLimit = ref(20)

// 取消率
const cancelList = ref([])
const cancelLoading = ref(false)
const cancelDateRange = ref([])
const cancelTotal = ref({})

// 利润分析
const profitList = ref([])
const profitLoading = ref(false)
const profitDateRange = ref([])

onMounted(() => {
  loadRanking()
})

function handleTabChange(tab) {
  if (tab === 'ranking' && rankingList.value.length === 0) loadRanking()
  else if (tab === 'cancel' && cancelList.value.length === 0) loadCancelRate()
  else if (tab === 'profit' && profitList.value.length === 0) loadProfit()
}

function getParams(dateRange) {
  const params = {}
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  return params
}

// 销售排行
function loadRanking() {
  rankingLoading.value = true
  const params = { ...getParams(rankingDateRange), limit: rankingLimit.value }
  salesRanking(params).then(res => {
    rankingList.value = res.data || res || []
  }).finally(() => {
    rankingLoading.value = false
  })
}

function handleExportRanking() {
  const params = { ...getParams(rankingDateRange), limit: rankingLimit.value }
  proxy.download('statistics/product/exportRanking', params, `货品销售排行_${new Date().getTime()}.xlsx`)
}

// 取消率
function loadCancelRate() {
  cancelLoading.value = true
  cancelRate(getParams(cancelDateRange)).then(res => {
    const data = res.data || res || {}
    cancelList.value = data.list || []
    cancelTotal.value = data.total || {}
  }).finally(() => {
    cancelLoading.value = false
  })
}

function getCancelRateClass(rate) {
  if (rate >= 20) return 'amount-red'
  if (rate >= 10) return 'amount-orange'
  if (rate >= 5) return 'amount-yellow'
  return 'amount-green'
}

// 利润分析
function loadProfit() {
  profitLoading.value = true
  profitAnalysis(getParams(profitDateRange)).then(res => {
    profitList.value = res.data || res || []
  }).finally(() => {
    profitLoading.value = false
  })
}

function formatMoney(value) {
  const num = Number(value) || 0
  return '¥' + num.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<style scoped lang="scss">
.summary-card {
  padding: 16px;
  border-radius: 8px;
  background: var(--el-bg-color);
  border: 1px solid #ebeef5;
  text-align: center;
  margin-bottom: 12px;
}
.summary-label { font-size: 13px; color: #909399; margin-bottom: 8px; }
.summary-value { font-size: 22px; font-weight: 700; }
.amount-blue { color: #3D6DF7; font-weight: 500; }
.amount-green { color: #52c41a; font-weight: 500; }
.amount-red { color: #f56c6c; font-weight: 500; }
.amount-orange { color: #e6a23c; font-weight: 500; }
.amount-yellow { color: #d4b106; font-weight: 500; }
.amount-gray { color: #909399; }
.rank-top { color: #f56c6c; font-weight: 700; }
</style>
