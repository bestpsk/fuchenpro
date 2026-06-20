<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="报销单号" prop="reimbursementNo">
        <el-input v-model="queryParams.reimbursementNo" placeholder="请输入报销单号" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="申请人" prop="applicantName">
        <el-input v-model="queryParams.applicantName" placeholder="请输入申请人" clearable style="width: 150px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="分类" prop="category">
        <el-select v-model="queryParams.category" placeholder="请选择分类" clearable style="width: 140px">
          <el-option v-for="dict in fin_reimbursement_category" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 120px">
          <el-option v-for="dict in fin_reimbursement_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['finance:reimbursement:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['finance:reimbursement:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['finance:reimbursement:export']">导出</el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="reimbursementList" @selection-change="handleSelectionChange" style="width: 100%" table-layout="auto">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="报销单号" align="center" prop="reimbursementNo" min-width="150" />
      <el-table-column label="申请人" align="center" prop="applicantName" min-width="100" />
      <el-table-column label="部门" align="center" prop="deptName" min-width="120" />
      <el-table-column label="申请日期" align="center" prop="applyDate" min-width="110" />
      <el-table-column label="分类" align="center" prop="category" min-width="100">
        <template #default="scope">
          <dict-tag v-if="fin_reimbursement_category?.length" :options="fin_reimbursement_category" :value="scope.row.category" />
          <span v-else>{{ scope.row.category }}</span>
        </template>
      </el-table-column>
      <el-table-column label="支出金额" align="center" prop="expenseAmount" min-width="120">
        <template #default="scope">
          <span style="color: #f56c6c; font-weight: bold">¥{{ formatMoney(scope.row.expenseAmount) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="支出类型" align="center" prop="expenseType" min-width="100">
        <template #default="scope">
          <dict-tag v-if="fin_reimbursement_expense_type?.length" :options="fin_reimbursement_expense_type" :value="scope.row.expenseType" />
          <span v-else>{{ scope.row.expenseType }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" min-width="100">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusLabel(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="280" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['finance:reimbursement:edit']">编辑</el-button>
          <el-button link type="success" icon="Check" @click="handleAudit(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['finance:reimbursement:audit']">审核</el-button>
          <el-button link type="warning" icon="Money" @click="handlePay(scope.row)" v-if="scope.row.status === '1'" v-hasPermi="['finance:reimbursement:pay']">支付</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="申请人">
              <el-input :value="userStore.nickName || userStore.name || '当前用户'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属部门">
              <el-input :value="userStore.deptName || '未分配'" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="申请日期" prop="applyDate">
              <el-date-picker v-model="form.applyDate" type="date" value-format="YYYY-MM-DD" placeholder="选择申请日期" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类" prop="category">
              <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
                <el-option v-for="dict in fin_reimbursement_category" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="支出金额" prop="expenseAmount">
              <el-input-number v-model="form.expenseAmount" :precision="2" :min="0" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="收入金额" prop="incomeAmount">
              <el-input-number v-model="form.incomeAmount" :precision="2" :min="0" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="支出类型" prop="expenseType">
              <el-select v-model="form.expenseType" placeholder="请选择支出类型" style="width: 100%">
                <el-option v-for="dict in fin_reimbursement_expense_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="凭证图片" prop="voucherImages">
          <el-upload :action="uploadUrl" list-type="picture-card" :file-list="fileList" :headers="uploadHeaders" :on-success="handleUploadSuccess" :on-remove="handleUploadRemove" :on-preview="handlePreview" accept="image/*">
            <el-icon><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="open = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="报销详情" v-model="viewOpen" width="700px" append-to-body>
      <el-descriptions v-if="viewForm && viewForm.reimbursementNo" :column="2" border>
        <el-descriptions-item label="报销单号">{{ viewForm.reimbursementNo }}</el-descriptions-item>
        <el-descriptions-item label="申请人">{{ viewForm.applicantName }}</el-descriptions-item>
        <el-descriptions-item label="部门">{{ viewForm.deptName }}</el-descriptions-item>
        <el-descriptions-item label="申请日期">{{ viewForm.applyDate }}</el-descriptions-item>
        <el-descriptions-item label="分类">
          <dict-tag v-if="fin_reimbursement_category?.length" :options="fin_reimbursement_category" :value="viewForm.category" />
          <span v-else>{{ viewForm.category }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="支出类型">
          <dict-tag v-if="fin_reimbursement_expense_type?.length" :options="fin_reimbursement_expense_type" :value="viewForm.expenseType" />
          <span v-else>{{ viewForm.expenseType }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="支出金额">¥{{ formatMoney(viewForm.expenseAmount) }}</el-descriptions-item>
        <el-descriptions-item label="收入金额">¥{{ formatMoney(viewForm.incomeAmount) }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <dict-tag v-if="fin_reimbursement_status?.length" :options="fin_reimbursement_status" :value="viewForm.status" />
          <span v-else>{{ viewForm.status }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="审核人">{{ viewForm.auditBy || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核时间">{{ viewForm.auditTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="支付人">{{ viewForm.payBy || '-' }}</el-descriptions-item>
        <el-descriptions-item label="支付时间">{{ viewForm.payTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ viewForm.remark }}</el-descriptions-item>
        <el-descriptions-item label="审核备注" :span="2">{{ viewForm.auditRemark }}</el-descriptions-item>
      </el-descriptions>
      <template v-if="viewForm && viewForm.voucherImages">
      <el-divider content-position="left">凭证图片</el-divider>
      <div style="display: flex; gap: 10px; flex-wrap: wrap">
        <el-image v-for="(img, idx) in parseImages(viewForm.voucherImages)" :key="idx" :src="img" :preview-src-list="parseImages(viewForm.voucherImages)" style="width: 100px; height: 100px" fit="cover" />
      </div>
      </template>
    </el-dialog>

    <el-dialog title="审核报销" v-model="auditOpen" width="500px" append-to-body>
      <el-form ref="auditRef" :model="auditForm" label-width="80px">
        <el-form-item label="是否通过">
          <el-radio-group v-model="auditForm.passed">
            <el-radio :label="true">通过</el-radio>
            <el-radio :label="false">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核备注">
          <el-input v-model="auditForm.auditRemark" type="textarea" :rows="3" placeholder="请输入审核备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditOpen = false">取消</el-button>
        <el-button type="primary" @click="submitAudit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="previewVisible" title="图片预览" width="600px" append-to-body>
      <img :src="previewUrl" style="width: 100%" />
    </el-dialog>
  </div>
</template>

<script setup name="FinanceReimbursement">
import { listReimbursement, getReimbursement, addReimbursement, updateReimbursement, delReimbursement, auditReimbursement, payReimbursement } from '@/api/finance/reimbursement'
import { Plus } from '@element-plus/icons-vue'
import useUserStore from '@/store/modules/user'
import { getToken } from '@/utils/auth'

const { proxy } = getCurrentInstance()
const { fin_reimbursement_category, fin_reimbursement_status, fin_reimbursement_expense_type } = proxy.useDict('fin_reimbursement_category', 'fin_reimbursement_status', 'fin_reimbursement_expense_type')

const userStore = useUserStore()

const reimbursementList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const title = ref('')
const open = ref(false)
const viewOpen = ref(false)
const viewForm = ref({
  reimbursementNo: '',
  applicantName: '',
  deptName: '',
  applyDate: '',
  category: '',
  expenseType: '',
  expenseAmount: 0,
  incomeAmount: 0,
  status: '',
  auditBy: '',
  auditTime: '',
  payBy: '',
  payTime: '',
  remark: '',
  auditRemark: '',
  voucherImages: ''
})
const auditOpen = ref(false)
const auditForm = ref({})
const ids = ref([])
const multiple = ref(true)
const fileList = ref([])
const previewVisible = ref(false)
const previewUrl = ref('')

// 上传配置
const uploadUrl = import.meta.env.VITE_APP_BASE_API + '/common/upload'
const uploadHeaders = {
  Authorization: 'Bearer ' + getToken()
}

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  reimbursementNo: undefined,
  applicantName: undefined,
  category: undefined,
  status: undefined
})

const form = ref({})
const rules = {
  applyDate: [{ required: true, message: '请选择申请日期', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'blur' }],
  expenseAmount: [{ required: true, message: '请输入支出金额', trigger: 'blur' }],
  expenseType: [{ required: true, message: '请选择支出类型', trigger: 'blur' }]
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function getStatusType(status) {
  const types = {
    '0': 'info',
    '1': 'success',
    '2': 'danger',
    '3': 'warning'
  }
  return types[status] || 'info'
}

function getStatusLabel(status) {
  const labels = {
    '0': '待审核',
    '1': '已审核',
    '2': '已拒绝',
    '3': '已支付'
  }
  return labels[status] || status
}

function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) {
      return parsed.filter(url => url && typeof url === 'string')
    }
    return []
  } catch (e) {
    console.error('图片解析失败:', e, jsonStr)
    if (typeof jsonStr === 'string' && (jsonStr.startsWith('http') || jsonStr.startsWith('/'))) {
      return [jsonStr]
    }
    return []
  }
}

function getList() {
  loading.value = true
  listReimbursement(queryParams.value).then(response => {
    reimbursementList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(error => {
    console.error('获取列表失败:', error)
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

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.reimbursementId)
  multiple.value = !selection.length
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新增报销'
}

function handleUpdate(row) {
  reset()
  getReimbursement(row.reimbursementId).then(response => {
    if (response && response.data) {
      const data = response.data
      form.value = {
        ...data,
        expenseAmount: parseFloat(data.expenseAmount || 0),
        incomeAmount: parseFloat(data.incomeAmount || 0),
        applyDate: data.applyDate || ''
      }

      const images = parseImages(data.voucherImages)
      fileList.value = images.map((url, idx) => ({
        name: 'img' + idx,
        url: url,
        response: { url: url }
      }))

      open.value = true
      title.value = '编辑报销'
    } else {
      proxy.$modal.msgError('获取报销详情失败')
    }
  }).catch(error => {
    console.error('获取报销详情失败:', error)
    proxy.$modal.msgError('获取报销详情失败')
  })
}

function handleView(row) {
  getReimbursement(row.reimbursementId).then(response => {
    if (response && response.data) {
      viewForm.value = response.data
      viewOpen.value = true
    } else {
      proxy.$modal.msgError('获取报销详情失败')
    }
  }).catch(error => {
    console.error('获取报销详情失败:', error)
    proxy.$modal.msgError('获取报销详情失败')
  })
}

function handleDelete(row) {
  const reimbursementIds = row.reimbursementId || ids.value
  proxy.$modal.confirm('确认删除该报销单？').then(() => {
    return delReimbursement(reimbursementIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function handleAudit(row) {
  auditForm.value = { reimbursementId: row.reimbursementId, passed: true, auditRemark: '' }
  auditOpen.value = true
}

function submitAudit() {
  auditReimbursement(auditForm.value).then(() => {
    auditOpen.value = false
    getList()
    proxy.$modal.msgSuccess('审核成功')
  })
}

function handlePay(row) {
  proxy.$modal.confirm('确认已支付该报销单？').then(() => {
    return payReimbursement({ reimbursementId: row.reimbursementId })
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('支付成功')
  }).catch(() => {})
}

function handleExport() {
  proxy.download("finance/reimbursement/export", {
    ...queryParams.value,
  }, `reimbursement_${new Date().getTime()}.xlsx`)
}

function reset() {
  form.value = {
    reimbursementId: undefined,
    applyDate: new Date().toISOString().slice(0, 10),
    category: '4',
    expenseAmount: 0,
    incomeAmount: 0,
    expenseType: '1',
    voucherImages: '',
    remark: ''
  }
  fileList.value = []
  proxy.resetForm('formRef')
}

function handleUploadSuccess(response, file, fileList) {
  if (response.code === 200) {
    updateVoucherImages(fileList)
  }
}

function handleUploadRemove(file, fileList) {
  updateVoucherImages(fileList)
}

function handlePreview(file) {
  const url = file.response?.url || file.response?.data?.url || file.url
  if (url && !url.startsWith('blob:')) {
    previewUrl.value = url
    previewVisible.value = true
  }
}

function updateVoucherImages(list) {
  const urls = list.map(f => {
    if (f.response && f.response.url) return f.response.url
    if (f.response && f.response.data && f.response.data.url) return f.response.data.url
    if (f.url && !f.url.startsWith('blob:')) return f.url
    return ''
  }).filter(url => url)
  form.value.voucherImages = JSON.stringify(urls)
}

function submitForm() {
  proxy.$refs.formRef.validate(valid => {
    if (valid) {
      if (form.value.reimbursementId) {
        updateReimbursement(form.value).then(() => {
          open.value = false
          getList()
          proxy.$modal.msgSuccess('修改成功')
        })
      } else {
        addReimbursement(form.value).then(() => {
          open.value = false
          getList()
          proxy.$modal.msgSuccess('新增成功')
        })
      }
    }
  })
}

getList()
</script>
