<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="类型名称" prop="typeName">
        <el-input v-model="queryParams.typeName" placeholder="请输入类型名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width: 160px">
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
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:leave:type:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['business:leave:type:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['business:leave:type:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="leaveTypeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="类型名称" align="center" prop="typeName" min-width="120" />
      <el-table-column label="类型代码" align="center" prop="typeCode" min-width="140" />
      <el-table-column label="是否需审批" align="center" prop="needApproval" min-width="100">
        <template #default="scope">
          <el-tag :type="scope.row.needApproval == 1 ? 'success' : 'warning'">
            {{ scope.row.needApproval == 1 ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="是否公共假期" align="center" prop="isPublic" min-width="110">
        <template #default="scope">
          <el-tag :type="scope.row.isPublic == 1 ? 'success' : 'warning'">
            {{ scope.row.isPublic == 1 ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="显示颜色" align="center" prop="color" min-width="100">
        <template #default="scope">
          <div v-if="scope.row.color" style="display: flex; align-items: center; justify-content: center; gap: 6px;">
            <span :style="{ display: 'inline-block', width: '18px', height: '18px', borderRadius: '4px', backgroundColor: scope.row.color, border: '1px solid #dcdfe6' }"></span>
            <span>{{ scope.row.color }}</span>
          </div>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="排序" align="center" prop="sort" min-width="80" />
      <el-table-column label="状态" align="center" prop="status" min-width="80">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" min-width="160">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:leave:type:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:leave:type:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="560px" append-to-body>
      <el-form ref="leaveTypeRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="类型名称" prop="typeName">
              <el-input v-model="form.typeName" placeholder="请输入类型名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="类型代码" prop="typeCode">
              <el-input v-model="form.typeCode" placeholder="请输入类型代码，如 annual_leave" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="是否需审批" prop="needApproval">
              <el-switch v-model="form.needApproval" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否公共假期" prop="isPublic">
              <el-switch v-model="form.isPublic" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="显示颜色" prop="color">
              <el-color-picker v-model="form.color" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序" prop="sort">
              <el-input-number v-model="form.sort" controls-position="right" :min="0" style="width: 100%" />
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

<script setup name="LeaveType">
import { listLeaveType, getLeaveType, addLeaveType, updateLeaveType, delLeaveType } from "@/api/business/leave"

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict("sys_normal_disable")

const leaveTypeList = ref([])
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
  queryParams: { pageNum: 1, pageSize: 10, typeName: undefined, status: undefined },
  rules: {
    typeName: [{ required: true, message: "类型名称不能为空", trigger: "blur" }],
    typeCode: [{ required: true, message: "类型代码不能为空", trigger: "blur" }]
  }
})

const { queryParams, form, rules } = toRefs(data)

function getList() {
  loading.value = true
  listLeaveType(queryParams.value).then(response => {
    leaveTypeList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.typeId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function reset() {
  form.value = {
    typeId: undefined, typeName: undefined, typeCode: undefined,
    needApproval: 0, isPublic: 0, color: undefined, sort: 0,
    status: "0"
  }
  proxy.resetForm("leaveTypeRef")
}

function handleAdd() { reset(); open.value = true; title.value = "添加休假类型" }

function handleUpdate(row) {
  reset()
  const typeId = row.typeId || ids.value[0]
  getLeaveType(typeId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改休假类型"
  })
}

function submitForm() {
  proxy.$refs["leaveTypeRef"].validate(valid => {
    if (valid) {
      if (form.value.typeId) {
        updateLeaveType(form.value).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() })
      } else {
        addLeaveType(form.value).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
      }
    }
  })
}

function handleDelete(row) {
  const typeIds = row.typeId || ids.value
  proxy.$modal.confirm('是否确认删除所选休假类型？').then(() => delLeaveType(typeIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function cancel() { open.value = false; reset() }

getList()
</script>
