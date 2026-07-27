<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="员工姓名" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入员工姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="休假类型" prop="leaveTypeId">
        <el-select v-model="queryParams.leaveTypeId" placeholder="休假类型" clearable style="width: 160px">
          <el-option v-for="item in leaveTypeOptions" :key="item.typeId" :label="item.typeName" :value="item.typeId" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width: 160px">
          <el-option v-for="dict in biz_leave_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="申请日期" prop="dateRange">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:leave:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['business:leave:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="全部" name="all" />
      <el-tab-pane label="待审核" name="0" />
      <el-tab-pane label="已通过" name="1" />
      <el-tab-pane label="已拒绝" name="2" />
    </el-tabs>

    <el-table v-loading="loading" :data="leaveList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="单号" align="center" prop="leaveNo" min-width="170" show-overflow-tooltip />
      <el-table-column label="员工姓名" align="center" prop="userName" min-width="100" />
      <el-table-column label="休假类型" align="center" prop="typeName" min-width="100">
        <template #default="scope">
          <span>{{ scope.row.typeName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="起止日期" align="center" min-width="200">
        <template #default="scope">
          <span>{{ scope.row.startDate }}</span>
          <span style="margin: 0 4px;">~</span>
          <span>{{ scope.row.endDate }}</span>
        </template>
      </el-table-column>
      <el-table-column label="天数" align="center" prop="leaveDays" min-width="70" />
      <el-table-column label="状态" align="center" prop="status" min-width="90">
        <template #default="scope">
          <dict-tag :options="biz_leave_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="审核人" align="center" prop="approverName" min-width="100">
        <template #default="scope">
          <span>{{ scope.row.approverName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="审核时间" align="center" prop="approveTime" min-width="160">
        <template #default="scope">
          <span>{{ scope.row.approveTime || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" min-width="240" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleDetail(scope.row)">详情</el-button>
          <el-button link type="success" icon="Check" @click="handleApprove(scope.row)" v-hasPermi="['business:leave:approve']" v-if="scope.row.status === '0'">通过</el-button>
          <el-button link type="danger" icon="CloseBold" @click="handleReject(scope.row)" v-hasPermi="['business:leave:approve']" v-if="scope.row.status === '0'">驳回</el-button>
          <el-button link type="warning" icon="RefreshLeft" @click="handleCancel(scope.row)" v-if="scope.row.status === '0' && isOwnLeave(scope.row)">撤销</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:leave:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增请假对话框 -->
    <el-dialog :title="title" v-model="open" width="560px" append-to-body>
      <el-form ref="leaveRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="休假类型" prop="leaveTypeId">
          <el-select v-model="form.leaveTypeId" placeholder="请选择休假类型" filterable clearable style="width: 100%">
            <el-option v-for="item in leaveTypeOptions" :key="item.typeId" :label="item.typeName" :value="item.typeId" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker v-model="form.startDate" type="date" value-format="YYYY-MM-DD" placeholder="选择开始日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="开始时段" prop="startTimeType">
          <el-radio-group v-model="form.startTimeType">
            <el-radio v-for="dict in biz_leave_time_type" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="结束日期" prop="endDate">
          <el-date-picker v-model="form.endDate" type="date" value-format="YYYY-MM-DD" placeholder="选择结束日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="结束时段" prop="endTimeType">
          <el-radio-group v-model="form.endTimeType">
            <el-radio v-for="dict in biz_leave_time_type" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="事由" prop="reason">
          <el-input v-model="form.reason" type="textarea" :rows="4" placeholder="请输入请假事由" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 审核对话框 -->
    <el-dialog :title="approveTitle" v-model="approveOpen" width="560px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="单号">{{ currentLeave.leaveNo }}</el-descriptions-item>
        <el-descriptions-item label="员工姓名">{{ currentLeave.userName }}</el-descriptions-item>
        <el-descriptions-item label="休假类型">{{ currentLeave.typeName }}</el-descriptions-item>
        <el-descriptions-item label="天数">{{ currentLeave.leaveDays }}</el-descriptions-item>
        <el-descriptions-item label="起止日期" :span="2">{{ currentLeave.startDate }} ~ {{ currentLeave.endDate }}</el-descriptions-item>
        <el-descriptions-item label="事由" :span="2">{{ currentLeave.reason }}</el-descriptions-item>
      </el-descriptions>
      <el-form ref="approveRef" :model="approveForm" :rules="approveRules" label-width="100px" style="margin-top: 16px;">
        <el-form-item label="审核备注" prop="approveRemark">
          <el-input v-model="approveForm.approveRemark" type="textarea" :rows="3" placeholder="请输入审核备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitApprove">确 定</el-button>
          <el-button @click="approveOpen = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog title="请假详情" v-model="detailOpen" width="640px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="单号">{{ detailData.leaveNo }}</el-descriptions-item>
        <el-descriptions-item label="员工姓名">{{ detailData.userName }}</el-descriptions-item>
        <el-descriptions-item label="休假类型">{{ detailData.typeName }}</el-descriptions-item>
        <el-descriptions-item label="天数">{{ detailData.leaveDays }}</el-descriptions-item>
        <el-descriptions-item label="开始日期">{{ detailData.startDate }}</el-descriptions-item>
        <el-descriptions-item label="开始时段"><dict-tag :options="biz_leave_time_type" :value="detailData.startTimeType" /></el-descriptions-item>
        <el-descriptions-item label="结束日期">{{ detailData.endDate }}</el-descriptions-item>
        <el-descriptions-item label="结束时段"><dict-tag :options="biz_leave_time_type" :value="detailData.endTimeType" /></el-descriptions-item>
        <el-descriptions-item label="状态"><dict-tag :options="biz_leave_status" :value="detailData.status" /></el-descriptions-item>
        <el-descriptions-item label="审核人">{{ detailData.approverName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核时间">{{ detailData.approveTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="事由" :span="2">{{ detailData.reason || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核备注" :span="2">{{ detailData.approveRemark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detailOpen = false">关 闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="LeaveManage">
import { listLeave, getLeave, addLeave, approveLeave, rejectLeave, cancelLeave, delLeave, listAllLeaveType } from "@/api/business/leave"
import useUserStore from '@/store/modules/user'

const { proxy } = getCurrentInstance()
const userStore = useUserStore()
const { biz_leave_status, biz_leave_time_type } = useDict("biz_leave_status", "biz_leave_time_type")

const leaveList = ref([])
const leaveTypeOptions = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")
const dateRange = ref([])
const activeTab = ref("all")
const approveOpen = ref(false)
const approveTitle = ref("")
const approveMode = ref("approve")
const currentLeave = ref({})
const detailOpen = ref(false)
const detailData = ref({})

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, userName: undefined, leaveTypeId: undefined, status: undefined, startDate: undefined, endDate: undefined },
  rules: {
    leaveTypeId: [{ required: true, message: "请选择休假类型", trigger: "change" }],
    startDate: [{ required: true, message: "开始日期不能为空", trigger: "change" }],
    endDate: [{ required: true, message: "结束日期不能为空", trigger: "change" }],
    reason: [{ required: true, message: "事由不能为空", trigger: "blur" }]
  }
})

const { queryParams, form, rules } = toRefs(data)

const approveForm = reactive({ leaveId: undefined, approveRemark: undefined })
const approveRules = { approveRemark: [{ required: false, message: "请输入审核备注", trigger: "blur" }] }

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  } else {
    params.startDate = undefined
    params.endDate = undefined
  }
  listLeave(params).then(response => {
    leaveList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function getLeaveTypeOptions() {
  listAllLeaveType().then(response => {
    leaveTypeOptions.value = response.data || response.rows || []
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery() }

function handleTabChange(name) {
  queryParams.value.status = name === 'all' ? undefined : name
  handleQuery()
}

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.leaveId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function isOwnLeave(row) {
  return row.userId && String(row.userId) === String(userStore.id)
}

function reset() {
  form.value = {
    leaveId: undefined, leaveTypeId: undefined, startDate: undefined, endDate: undefined,
    startTimeType: "0", endTimeType: "0", reason: undefined
  }
  proxy.resetForm("leaveRef")
}

function handleAdd() { reset(); open.value = true; title.value = "新增请假" }

function submitForm() {
  proxy.$refs["leaveRef"].validate(valid => {
    if (valid) {
      addLeave(form.value).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
    }
  })
}

function handleApprove(row) {
  approveMode.value = "approve"
  approveTitle.value = "审核通过"
  currentLeave.value = row
  approveForm.leaveId = row.leaveId
  approveForm.approveRemark = undefined
  approveOpen.value = true
}

function handleReject(row) {
  approveMode.value = "reject"
  approveTitle.value = "审核驳回"
  currentLeave.value = row
  approveForm.leaveId = row.leaveId
  approveForm.approveRemark = undefined
  approveOpen.value = true
}

function submitApprove() {
  proxy.$refs["approveRef"].validate(valid => {
    if (valid) {
      const action = approveMode.value === 'approve' ? approveLeave : rejectLeave
      const msg = approveMode.value === 'approve' ? '审核通过成功' : '驳回成功'
      action(approveForm).then(() => { proxy.$modal.msgSuccess(msg); approveOpen.value = false; getList() })
    }
  })
}

function handleCancel(row) {
  proxy.$modal.confirm('是否确认撤销该请假单？').then(() => cancelLeave({ leaveId: row.leaveId })).then(() => { proxy.$modal.msgSuccess("撤销成功"); getList() }).catch(() => {})
}

function handleDetail(row) {
  getLeave(row.leaveId).then(response => {
    detailData.value = response.data
    detailOpen.value = true
  })
}

function handleDelete(row) {
  const leaveIds = row.leaveId || ids.value
  proxy.$modal.confirm('是否确认删除所选请假单？').then(() => delLeave(leaveIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function cancel() { open.value = false; reset() }

getList()
getLeaveTypeOptions()
</script>
