<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="企业名称" prop="enterpriseName">
        <el-input v-model="queryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="回访类型" prop="visitType">
        <el-select v-model="queryParams.visitType" placeholder="请选择回访类型" clearable style="width: 140px">
          <el-option v-for="dict in visit_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="回访方式" prop="visitMode">
        <el-select v-model="queryParams.visitMode" placeholder="请选择回访方式" clearable style="width: 120px">
          <el-option label="员工填写" value="1" />
          <el-option label="H5链接" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="visitStatus">
        <el-select v-model="queryParams.visitStatus" placeholder="请选择状态" clearable style="width: 120px">
          <el-option label="待回访" value="0" />
          <el-option label="已完成" value="1" />
          <el-option label="已取消" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item label="创建时间" style="width: 308px">
        <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:visit:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="DataAnalysis" @click="handleStats">满意度统计</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:visit:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="visitList">
      <el-table-column label="企业名称" prop="enterpriseName" min-width="160" show-overflow-tooltip />
      <el-table-column label="门店" prop="storeName" min-width="120" show-overflow-tooltip>
        <template #default="scope">
          <span>{{ scope.row.storeName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="回访类型" align="center" min-width="100">
        <template #default="scope">
          <el-tag size="small">{{ getVisitTypeLabel(scope.row.visitType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="回访方式" align="center" min-width="90">
        <template #default="scope">
          <el-tag :type="scope.row.visitMode === '1' ? '' : 'success'" size="small">{{ scope.row.visitMode === '1' ? '员工填写' : 'H5链接' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" min-width="80">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.visitStatus)" size="small">{{ getStatusLabel(scope.row.visitStatus) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="满意度" align="center" min-width="120">
        <template #default="scope">
          <el-rate v-if="scope.row.satisfactionScore" :model-value="Number(scope.row.satisfactionScore)" disabled show-score :max="5" />
          <span v-else style="color: #c0c4cc">-</span>
        </template>
      </el-table-column>
      <el-table-column label="回访员工" prop="visitorUserName" align="center" min-width="90" />
      <el-table-column label="回访时间" align="center" prop="visitTime" min-width="150">
        <template #default="scope">
          <span v-if="scope.row.visitTime">{{ parseTime(scope.row.visitTime) }}</span>
          <span v-else style="color: #c0c4cc">-</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="280" class-name="small-padding fixed-width" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleDetail(scope.row)">详情</el-button>
          <el-button link type="success" icon="Share" @click="handleLink(scope.row)" v-if="scope.row.visitStatus !== '1'" v-hasPermi="['business:visit:edit']">生成链接</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:visit:edit']">编辑</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:visit:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/编辑弹窗 -->
    <visit-form v-model:visible="dialog.open" :visit-id="dialog.visitId" @success="handleFormSuccess" />

    <!-- 详情弹窗 -->
    <visit-detail v-model:visible="detailOpen" :visit-id="detailVisitId" />

    <!-- H5链接弹窗 -->
    <el-dialog title="H5回访链接" v-model="linkOpen" width="560px" append-to-body>
      <div v-loading="linkLoading">
        <el-alert title="将以下链接发送给企业负责人，负责人打开后即可填写回访问卷（链接7天内有效）" type="info" :closable="false" show-icon style="margin-bottom: 16px" />
        <el-input v-model="linkUrl" readonly type="textarea" :rows="3" />
        <div style="margin-top: 12px; text-align: right">
          <el-button type="primary" icon="DocumentCopy" @click="copyLink">复制链接</el-button>
        </div>
        <el-descriptions :column="1" border size="small" style="margin-top: 16px" v-if="linkTask">
          <el-descriptions-item label="企业">{{ linkTask.enterpriseName }}</el-descriptions-item>
          <el-descriptions-item label="过期时间">{{ parseTime(linkTask.tokenExpireTime) }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(linkTask.visitStatus)" size="small">{{ getStatusLabel(linkTask.visitStatus) }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="linkOpen = false">关 闭</el-button>
      </template>
    </el-dialog>

    <!-- 满意度统计弹窗 -->
    <el-dialog title="满意度统计" v-model="statsOpen" width="780px" append-to-body>
      <div v-loading="statsLoading">
        <el-form :inline="true" style="margin-bottom: 12px">
          <el-form-item label="回访类型">
            <el-select v-model="statsQuery.visitType" placeholder="全部" clearable style="width: 140px" @change="loadStats">
              <el-option v-for="dict in visit_type" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
        </el-form>
        <el-table :data="statsData" border size="small">
          <el-table-column label="企业名称" prop="enterpriseName" min-width="180" show-overflow-tooltip />
          <el-table-column label="回访次数" prop="totalCount" align="center" width="90" />
          <el-table-column label="平均满意度" align="center" width="180">
            <template #default="scope">
              <el-rate :model-value="Number(scope.row.avgScore || 0)" disabled show-score :max="5" />
            </template>
          </el-table-column>
          <el-table-column label="满意次数(≥4分)" prop="satisfiedCount" align="center" width="120" />
          <el-table-column label="满意率" align="center" width="100">
            <template #default="scope">
              <span style="color: #3D6DF7; font-weight: 600">{{ scope.row.totalCount > 0 ? Math.round(scope.row.satisfiedCount / scope.row.totalCount * 100) : 0 }}%</span>
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-if="!statsLoading && statsData.length === 0" description="暂无统计数据" />
      </div>
      <template #footer>
        <el-button @click="statsOpen = false">关 闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Visit">
import { listVisit, delVisit, generateVisitLink, getVisitStats } from '@/api/business/visit'

const VisitForm = defineAsyncComponent(() => import('./form.vue'))
const VisitDetail = defineAsyncComponent(() => import('./detail.vue'))
const { proxy } = getCurrentInstance()
const { biz_visit_type: visit_type } = proxy.useDict('biz_visit_type')

const visitList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dateRange = ref([])
const linkOpen = ref(false)
const linkLoading = ref(false)
const linkUrl = ref('')
const linkTask = ref(null)
const statsOpen = ref(false)
const statsLoading = ref(false)
const statsData = ref([])
const statsQuery = reactive({ visitType: undefined })
const detailOpen = ref(false)
const detailVisitId = ref(null)

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    enterpriseName: undefined,
    visitType: undefined,
    visitMode: undefined,
    visitStatus: undefined
  },
  dialog: {
    open: false,
    visitId: null
  }
})

const { queryParams, dialog } = toRefs(data)

function getVisitTypeLabel(val) {
  const item = visit_type.value?.find(d => d.value === val)
  return item ? item.label : (val || '-')
}

function getStatusType(status) {
  return { '0': 'warning', '1': 'success', '2': 'info' }[status] || 'info'
}

function getStatusLabel(status) {
  return { '0': '待回访', '1': '已完成', '2': '已取消' }[status] || '-'
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  listVisit(params).then(response => {
    visitList.value = response.rows
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
  dateRange.value = []
  handleQuery()
}

function handleAdd() {
  dialog.value = { open: true, visitId: null }
}

function handleUpdate(row) {
  dialog.value = { open: true, visitId: row.visitId }
}

function handleFormSuccess() {
  getList()
}

function handleDetail(row) {
  detailVisitId.value = row.visitId
  detailOpen.value = true
}

function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除该回访记录？').then(() => {
    return delVisit(row.visitId)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function handleLink(row) {
  proxy.$modal.confirm('确认为该回访生成/刷新H5链接吗？').then(() => {
    linkLoading.value = true
    linkOpen.value = true
    return generateVisitLink(row.visitId)
  }).then(response => {
    const task = response.data || response
    linkTask.value = task
    // 构建H5链接（支持环境变量配置H5基础路径）
    const h5Base = import.meta.env.VITE_APP_H5_BASE || (window.location.origin + '/h5/')
    linkUrl.value = `${h5Base.replace(/\/$/, '')}/#/pages/visit/fill?token=${task.visitToken}`
    linkLoading.value = false
  }).catch(() => {
    linkLoading.value = false
    linkOpen.value = false
  })
}

function copyLink() {
  if (!linkUrl.value) return
  navigator.clipboard.writeText(linkUrl.value).then(() => {
    proxy.$modal.msgSuccess('链接已复制到剪贴板')
  }).catch(() => {
    // 兜底方案
    const textarea = document.createElement('textarea')
    textarea.value = linkUrl.value
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    proxy.$modal.msgSuccess('链接已复制')
  })
}

function handleStats() {
  statsOpen.value = true
  loadStats()
}

function loadStats() {
  statsLoading.value = true
  const query = {}
  if (statsQuery.visitType) query.visitType = statsQuery.visitType
  getVisitStats(query).then(response => {
    statsData.value = response.data || []
    statsLoading.value = false
  }).catch(() => {
    statsLoading.value = false
  })
}

function handleExport() {
  proxy.download('business/visit/export', {
    ...queryParams.value,
    ...(dateRange.value && dateRange.value.length === 2 ? { startDate: dateRange.value[0], endDate: dateRange.value[1] } : {})
  }, `满意度回访_${new Date().getTime()}.csv`)
}

getList()
</script>
