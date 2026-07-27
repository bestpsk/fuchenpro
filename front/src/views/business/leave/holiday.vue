<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="假期名称" prop="holidayName">
        <el-input v-model="queryParams.holidayName" placeholder="请输入假期名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="年份" prop="year">
        <el-date-picker v-model="queryParams.year" type="year" value-format="YYYY" placeholder="选择年份" clearable style="width: 160px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:leave:holiday:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['business:leave:holiday:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['business:leave:holiday:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="holidayList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="假期名称" align="center" prop="holidayName" min-width="140" />
      <el-table-column label="开始日期" align="center" prop="startDate" min-width="120" />
      <el-table-column label="结束日期" align="center" prop="endDate" min-width="120" />
      <el-table-column label="关联休假类型" align="center" prop="leaveTypeName" min-width="140">
        <template #default="scope">
          <span>{{ scope.row.leaveTypeName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="年份" align="center" prop="year" min-width="80" />
      <el-table-column label="状态" align="center" prop="status" min-width="80">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" min-width="160">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:leave:holiday:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:leave:holiday:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="holidayRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="假期名称" prop="holidayName">
              <el-input v-model="form.holidayName" placeholder="请输入假期名称，如 国庆节" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="开始日期" prop="startDate">
              <el-date-picker v-model="form.startDate" type="date" value-format="YYYY-MM-DD" placeholder="选择开始日期" style="width: 100%" @change="onStartDateChange" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束日期" prop="endDate">
              <el-date-picker v-model="form.endDate" type="date" value-format="YYYY-MM-DD" placeholder="选择结束日期" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="关联休假类型" prop="leaveTypeId">
              <el-select v-model="form.leaveTypeId" placeholder="请选择休假类型" filterable clearable style="width: 100%">
                <el-option v-for="item in leaveTypeOptions" :key="item.typeId" :label="item.typeName" :value="item.typeId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="年份" prop="year">
              <el-input v-model="form.year" placeholder="根据开始日期自动计算" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio v-for="dict in sys_normal_disable" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="LeaveHoliday">
import { listHoliday, getHoliday, addHoliday, updateHoliday, delHoliday, listAllLeaveType } from "@/api/business/leave"

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict("sys_normal_disable")

const holidayList = ref([])
const leaveTypeOptions = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, holidayName: undefined, year: undefined },
  rules: {
    holidayName: [{ required: true, message: "假期名称不能为空", trigger: "blur" }],
    startDate: [{ required: true, message: "开始日期不能为空", trigger: "change" }],
    endDate: [{ required: true, message: "结束日期不能为空", trigger: "change" }],
    leaveTypeId: [{ required: true, message: "请选择关联休假类型", trigger: "change" }]
  }
})

const { queryParams, form, rules } = toRefs(data)

function getList() {
  loading.value = true
  listHoliday(queryParams.value).then(response => {
    holidayList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function getLeaveTypeOptions() {
  listAllLeaveType().then(response => {
    const list = response.data || response.rows || []
    leaveTypeOptions.value = list
  })
}

function onStartDateChange(val) {
  if (val) {
    form.value.year = val.substring(0, 4)
  }
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.holidayId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function reset() {
  form.value = {
    holidayId: undefined, holidayName: undefined, startDate: undefined, endDate: undefined,
    leaveTypeId: undefined, year: undefined, status: "0"
  }
  proxy.resetForm("holidayRef")
}

function handleAdd() { reset(); open.value = true; title.value = "添加假期" }

function handleUpdate(row) {
  reset()
  const holidayId = row.holidayId || ids.value[0]
  getHoliday(holidayId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改假期"
  })
}

function submitForm() {
  proxy.$refs["holidayRef"].validate(valid => {
    if (valid) {
      if (form.value.holidayId) {
        updateHoliday(form.value).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() })
      } else {
        addHoliday(form.value).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
      }
    }
  })
}

function handleDelete(row) {
  const holidayIds = row.holidayId || ids.value
  proxy.$modal.confirm('是否确认删除所选假期？').then(() => delHoliday(holidayIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function cancel() { open.value = false; reset() }

getList()
getLeaveTypeOptions()
</script>
