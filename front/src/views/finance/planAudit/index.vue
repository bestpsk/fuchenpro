<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="企业名称" prop="enterpriseName">
        <el-input v-model="queryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="方案名称" prop="planName">
        <el-input v-model="queryParams.planName" placeholder="请输入方案名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="审核状态" prop="auditStatus">
        <el-select v-model="queryParams.auditStatus" placeholder="请选择审核状态" clearable style="width: 150px">
          <el-option v-for="dict in audit_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="planList">
      <el-table-column label="方案编号" align="center" prop="planNo" width="150" />
      <el-table-column label="方案名称" align="center" prop="planName" />
      <el-table-column label="企业名称" align="center" prop="enterpriseName" />
      <el-table-column label="方案金额" align="center" prop="planAmount" width="120">
        <template #default="scope">
          <span style="color: #67c23a; font-weight: bold">¥{{ formatMoney(scope.row.planAmount) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="审核状态" align="center" prop="auditStatus" width="100">
        <template #default="scope">
          <dict-tag v-if="audit_status?.length" :options="audit_status" :value="scope.row.auditStatus" />
          <span v-else>{{ scope.row.auditStatus }}</span>
        </template>
      </el-table-column>
      <el-table-column label="提交时间" align="center" prop="submitTime" width="160" />
      <el-table-column label="操作" align="center" width="250" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button link type="primary" icon="Check" @click="handleAudit(scope.row, true)" v-if="scope.row.auditStatus === '1'" v-hasPermi="['finance:planAudit:audit']">通过</el-button>
          <el-button link type="danger" icon="Close" @click="handleAudit(scope.row, false)" v-if="scope.row.auditStatus === '1'" v-hasPermi="['finance:planAudit:audit']">驳回</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="方案详情" v-model="viewOpen" width="900px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="方案编号">{{ viewForm.planNo }}</el-descriptions-item>
        <el-descriptions-item label="方案名称">{{ viewForm.planName }}</el-descriptions-item>
        <el-descriptions-item label="企业名称">{{ viewForm.enterpriseName }}</el-descriptions-item>
        <el-descriptions-item label="方案金额">¥{{ formatMoney(viewForm.planAmount) }}</el-descriptions-item>
        <el-descriptions-item label="配赠金额">¥{{ formatMoney(viewForm.giftAmount) }}</el-descriptions-item>
        <el-descriptions-item label="剩余金额">¥{{ formatMoney(viewForm.remainingAmount) }}</el-descriptions-item>
        <el-descriptions-item label="生效日期">{{ viewForm.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="失效日期">{{ viewForm.expiryDate }}</el-descriptions-item>
        <el-descriptions-item label="审核状态">
          <dict-tag v-if="audit_status?.length" :options="audit_status" :value="viewForm.auditStatus" />
          <span v-else>{{ viewForm.auditStatus }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ viewForm.remark }}</el-descriptions-item>
      </el-descriptions>
      <el-divider content-position="left">方案明细</el-divider>
      <el-table :data="viewForm.items" border size="small">
        <el-table-column label="产品名称" prop="productName" />
        <el-table-column label="数量" prop="quantity" width="80" />
        <el-table-column label="单价" prop="salePrice" width="100">
          <template #default="scope">¥{{ formatMoney(scope.row.salePrice) }}</template>
        </el-table-column>
        <el-table-column label="金额" prop="amount" width="100">
          <template #default="scope">¥{{ formatMoney(scope.row.amount) }}</template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog title="审核驳回" v-model="rejectOpen" width="500px" append-to-body>
      <el-form ref="rejectRef" :model="rejectForm" label-width="80px">
        <el-form-item label="驳回原因" prop="auditRemark">
          <el-input v-model="rejectForm.auditRemark" type="textarea" :rows="3" placeholder="请输入驳回原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectOpen = false">取消</el-button>
        <el-button type="primary" @click="submitReject">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="FinancePlanAudit">
import { listPlanAudit, getPlanAudit, auditPlan } from '@/api/finance/planAudit'

const { proxy } = getCurrentInstance()
const { audit_status } = proxy.useDict('audit_status')

const planList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const viewOpen = ref(false)
const viewForm = ref({})
const rejectOpen = ref(false)
const rejectForm = ref({})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  enterpriseName: undefined,
  planName: undefined,
  auditStatus: undefined
})

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function getList() {
  loading.value = true
  listPlanAudit(queryParams.value).then(response => {
    planList.value = response.rows
    total.value = response.total
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

function handleView(row) {
  getPlanAudit(row.planId).then(response => {
    viewForm.value = response.data
    viewOpen.value = true
  })
}

function handleAudit(row, passed) {
  if (passed) {
    proxy.$modal.confirm('确认审核通过该方案？').then(() => {
      return auditPlan({ planId: row.planId, passed: true })
    }).then(() => {
      getList()
      proxy.$modal.msgSuccess('审核成功')
    }).catch(() => {})
  } else {
    rejectForm.value = { planId: row.planId, passed: false, auditRemark: '' }
    rejectOpen.value = true
  }
}

function submitReject() {
  auditPlan(rejectForm.value).then(() => {
    rejectOpen.value = false
    getList()
    proxy.$modal.msgSuccess('驳回成功')
  })
}

getList()
</script>
