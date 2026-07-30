<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="方案名称" prop="planName">
        <el-input v-model="queryParams.planName" placeholder="请输入方案名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
          <el-option v-for="dict in sys_normal_disable" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:leave:rest:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['business:leave:rest:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="restPlanList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="方案名称" align="left" prop="planName" min-width="160" show-overflow-tooltip />
      <el-table-column label="关联员工" align="center" min-width="240">
        <template #default="scope">
          <span v-if="scope.row.employeeCount > 0">
            <el-tag size="small" type="info" class="mr-1">{{ scope.row.employeeCount }}人</el-tag>
            <span class="employee-names">{{ scope.row.employeeNames }}</span>
          </span>
          <span v-else class="no-employee">未关联员工</span>
        </template>
      </el-table-column>
      <el-table-column label="生效日期" align="center" prop="effectiveDate" min-width="110" />
      <el-table-column label="状态" align="center" prop="status" min-width="80">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="160">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)" v-hasPermi="['business:leave:rest:list']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:leave:rest:edit']">修改</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" v-model="open" width="780px" append-to-body :close-on-click-modal="false">
      <el-form ref="planRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="方案名称" prop="planName">
          <el-input v-model="form.planName" placeholder="如：销售部休息日配置" maxlength="100" show-word-limit style="width: 100%" />
        </el-form-item>

        <!-- 员工选择 -->
        <el-form-item label="关联员工" prop="userIds">
          <div class="employee-picker">
            <el-button type="primary" plain icon="Plus" @click="openEmployeeSelect">选择员工</el-button>
            <span class="count-text" v-if="selectedEmployees.length > 0">已选 {{ selectedEmployees.length }} 人</span>
            <div class="selected-tags" v-if="selectedEmployees.length > 0">
              <el-tag
                v-for="emp in selectedEmployees.slice(0, 20)"
                :key="emp.userId"
                closable
                @close="removeEmployee(emp.userId)"
                class="mx-1 my-1"
                size="small"
              >
                {{ emp.deptName ? `${emp.deptName}-` : '' }}{{ emp.nickName || emp.userName }}
              </el-tag>
              <el-tooltip v-if="selectedEmployees.length > 20" :content="`还有 ${selectedEmployees.length - 20} 人未显示`" placement="top">
                <el-tag size="small" type="info" class="mx-1 my-1">+{{ selectedEmployees.length - 20 }}</el-tag>
              </el-tooltip>
            </div>
          </div>
        </el-form-item>

        <!-- 按周配置 -->
        <el-form-item v-for="day in weekDays" :key="day.prop" :label="day.label">
          <el-switch v-model="form[day.prop]" active-value="1" inactive-value="0" active-text="休息" inactive-text="上班" />
        </el-form-item>

        <el-form-item label="生效日期" prop="effectiveDate">
          <el-date-picker v-model="form.effectiveDate" type="date" value-format="YYYY-MM-DD" placeholder="选择生效日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dict in sys_normal_disable" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog title="方案详情" v-model="viewOpen" width="780px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="方案名称">{{ viewForm.planName }}</el-descriptions-item>
        <el-descriptions-item label="生效日期">{{ viewForm.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <dict-tag :options="sys_normal_disable" :value="viewForm.status" />
        </el-descriptions-item>
        <el-descriptions-item label="关联员工" :span="2">
          <div v-if="viewForm.employees && viewForm.employees.length">
            <el-tag v-for="emp in viewForm.employees" :key="emp.userId" class="mx-1 my-1" size="small">
              {{ emp.deptName ? `${emp.deptName}-` : '' }}{{ emp.userName }}
            </el-tag>
          </div>
          <span v-else class="no-employee">未关联员工</span>
        </el-descriptions-item>
        <el-descriptions-item label="按周配置" :span="2">
          <el-tag v-for="day in weekDays" :key="day.prop" :type="viewForm[day.prop] === '1' ? 'info' : 'success'" class="mx-1 my-1" size="small">
            {{ day.label }}{{ viewForm[day.prop] === '1' ? '休息' : '上班' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 员工选择弹窗 -->
    <EmployeeSelect v-model="empSelectOpen" :selected="selectedEmployees" @confirm="handleEmployeeConfirm" />
  </div>
</template>

<script setup name="RestPlanConfig">
import { listRestPlan, getRestPlan, addRestPlan, updateRestPlan, delRestPlan } from "@/api/business/leave"
import EmployeeSelect from "@/components/EmployeeSelect/index.vue"

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict("sys_normal_disable")

const restPlanList = ref([])
const open = ref(false)
const viewOpen = ref(false)
const empSelectOpen = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")
const selectedEmployees = ref([])

const weekDays = [
  { prop: 'monday', label: '周一' },
  { prop: 'tuesday', label: '周二' },
  { prop: 'wednesday', label: '周三' },
  { prop: 'thursday', label: '周四' },
  { prop: 'friday', label: '周五' },
  { prop: 'saturday', label: '周六' },
  { prop: 'sunday', label: '周日' }
]

const data = reactive({
  form: {},
  viewForm: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    planName: undefined,
    status: undefined
  },
  rules: {
    planName: [{ required: true, message: "请输入方案名称", trigger: "blur" }],
    userIds: [{ required: true, type: 'array', message: "请选择员工", trigger: "change" }],
    effectiveDate: [{ required: true, message: "生效日期不能为空", trigger: "change" }]
  }
})

const { queryParams, form, viewForm, rules } = toRefs(data)

function getList() {
  loading.value = true
  listRestPlan(queryParams.value).then(response => {
    restPlanList.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.planId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function reset() {
  form.value = {
    planId: undefined,
    planName: '',
    userIds: [],
    monday: '0', tuesday: '0', wednesday: '0', thursday: '0', friday: '0',
    saturday: '1', sunday: '1',
    effectiveDate: proxy.parseTime(new Date(), '{y}-{m}-{d}'),
    status: '0'
  }
  selectedEmployees.value = []
  proxy.resetForm("planRef")
}

function handleAdd() {
  reset()
  open.value = true
  title.value = "新增休息日方案"
}

function handleUpdate(row) {
  reset()
  const planId = row.planId || ids.value[0]
  getRestPlan(planId).then(response => {
    const data = response.data
    form.value = {
      planId: data.planId,
      planName: data.planName,
      userIds: (data.employees || []).map(e => e.userId),
      monday: data.monday, tuesday: data.tuesday, wednesday: data.wednesday,
      thursday: data.thursday, friday: data.friday, saturday: data.saturday, sunday: data.sunday,
      effectiveDate: data.effectiveDate,
      status: data.status
    }
    selectedEmployees.value = (data.employees || []).map(e => ({
      userId: e.userId,
      nickName: e.userName,
      userName: e.userName,
      deptId: e.deptId,
      deptName: e.deptName
    }))
    open.value = true
    title.value = "修改休息日方案"
  })
}

function handleView(row) {
  getRestPlan(row.planId).then(response => {
    viewForm.value = response.data
    viewOpen.value = true
  })
}

function openEmployeeSelect() {
  empSelectOpen.value = true
}

function handleEmployeeConfirm(users) {
  selectedEmployees.value = users
  form.value.userIds = users.map(u => u.userId)
  // 触发校验清除错误
  proxy.$refs["planRef"]?.validateField?.("userIds")
}

function removeEmployee(userId) {
  selectedEmployees.value = selectedEmployees.value.filter(u => u.userId !== userId)
  form.value.userIds = form.value.userIds.filter(id => id !== userId)
}

function submitForm() {
  proxy.$refs["planRef"].validate(valid => {
    if (!valid) return
    if (selectedEmployees.value.length === 0) {
      proxy.$modal.msgError("请选择员工")
      return
    }
    const submitData = {
      ...form.value,
      userIds: form.value.userIds
    }
    if (form.value.planId) {
      updateRestPlan(submitData).then(() => {
        proxy.$modal.msgSuccess("修改成功")
        open.value = false
        getList()
      })
    } else {
      addRestPlan(submitData).then(() => {
        proxy.$modal.msgSuccess("新增成功")
        open.value = false
        getList()
      })
    }
  })
}

function handleDelete(row) {
  const planIds = row.planId || ids.value
  proxy.$modal.confirm('是否确认删除所选休息日方案？删除后关联员工将不再受该方案约束。').then(() => delRestPlan(planIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function cancel() { open.value = false; reset() }

getList()
</script>

<style scoped>
.employee-names {
  color: #606266;
  font-size: 12px;
}
.no-employee {
  color: #c0c4cc;
  font-size: 12px;
}
.employee-picker {
  width: 100%;
}
.employee-picker .count-text {
  margin-left: 12px;
  color: #3D6DF7;
  font-size: 13px;
}
.selected-tags {
  margin-top: 8px;
  padding: 8px;
  background: #fafafa;
  border: 1px dashed #dcdfe6;
  border-radius: 4px;
  max-height: 120px;
  overflow-y: auto;
}
</style>
