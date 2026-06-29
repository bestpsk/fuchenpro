<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="仓库名称" prop="warehouseName">
        <el-input v-model="queryParams.warehouseName" placeholder="请输入仓库名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="仓库编码" prop="warehouseCode">
        <el-input v-model="queryParams.warehouseCode" placeholder="请输入仓库编码" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 160px">
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
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['wms:warehouse:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['wms:warehouse:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['wms:warehouse:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="warehouseList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="仓库编码" prop="warehouseCode" width="120" />
      <el-table-column label="仓库名称" prop="warehouseName" min-width="140" />
      <el-table-column label="地址" prop="address" min-width="160" show-overflow-tooltip />
      <el-table-column label="联系人" prop="contactPerson" width="100" />
      <el-table-column label="联系电话" prop="contactPhone" width="130" />
      <el-table-column label="状态" prop="status" width="80" align="center">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['wms:warehouse:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['wms:warehouse:remove']">删除</el-button>
          <el-button link type="primary" icon="User" @click="handleAuthUser(scope.row)" v-hasPermi="['wms:warehouse:assign']">用户授权</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 添加或修改仓库对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="warehouseRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="仓库名称" prop="warehouseName">
              <el-input v-model="form.warehouseName" placeholder="请输入仓库名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="仓库编码" prop="warehouseCode">
              <el-input v-model="form.warehouseCode" placeholder="请输入仓库编码" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="地址" prop="address">
              <el-input v-model="form.address" placeholder="请输入地址" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系人" prop="contactPerson">
              <el-input v-model="form.contactPerson" placeholder="请输入联系人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话" prop="contactPhone">
              <el-input v-model="form.contactPhone" placeholder="请输入联系电话" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio v-for="dict in sys_normal_disable" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 用户授权对话框 -->
    <el-dialog title="用户授权" v-model="authOpen" width="800px" append-to-body>
      <el-form :model="authQueryParams" ref="authQueryRef" :inline="true">
        <el-form-item label="用户名称" prop="userName">
          <el-input v-model="authQueryParams.userName" placeholder="请输入用户名称" clearable style="width: 160px" @keyup.enter="handleAuthQuery" />
        </el-form-item>
        <el-form-item label="手机号码" prop="phonenumber">
          <el-input v-model="authQueryParams.phonenumber" placeholder="请输入手机号码" clearable style="width: 160px" @keyup.enter="handleAuthQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleAuthQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetAuthQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button type="primary" plain icon="Plus" @click="handleAddUser">添加用户</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button type="danger" plain icon="Delete" :disabled="authMultiple" @click="handleRemoveUser">批量移除</el-button>
        </el-col>
      </el-row>
      <el-table v-loading="authLoading" :data="authUserList" @selection-change="handleAuthSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="用户名称" prop="userName" :show-overflow-tooltip="true" />
        <el-table-column label="用户昵称" prop="nickName" :show-overflow-tooltip="true" />
        <el-table-column label="手机" prop="phonenumber" :show-overflow-tooltip="true" />
        <el-table-column label="状态" align="center" prop="status">
          <template #default="scope">
            <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template #default="scope">
            <el-button link type="primary" icon="CircleClose" @click="handleRemoveSingleUser(scope.row)">移除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="authTotal > 0" :total="authTotal" v-model:page="authQueryParams.pageNum" v-model:limit="authQueryParams.pageSize" @pagination="getAuthUserList" />
    </el-dialog>

    <!-- 添加用户对话框 -->
    <el-dialog title="添加用户" v-model="addUserOpen" width="800px" append-to-body>
      <el-form :model="addUserQueryParams" ref="addUserQueryRef" :inline="true">
        <el-form-item label="用户名称" prop="userName">
          <el-input v-model="addUserQueryParams.userName" placeholder="请输入用户名称" clearable style="width: 160px" @keyup.enter="handleAddUserQuery" />
        </el-form-item>
        <el-form-item label="手机号码" prop="phonenumber">
          <el-input v-model="addUserQueryParams.phonenumber" placeholder="请输入手机号码" clearable style="width: 160px" @keyup.enter="handleAddUserQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleAddUserQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetAddUserQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table @row-click="clickAddUserRow" ref="addUserTableRef" v-loading="addUserLoading" :data="addUserList" @selection-change="handleAddUserSelectionChange" height="260px">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="用户名称" prop="userName" :show-overflow-tooltip="true" />
        <el-table-column label="用户昵称" prop="nickName" :show-overflow-tooltip="true" />
        <el-table-column label="手机" prop="phonenumber" :show-overflow-tooltip="true" />
        <el-table-column label="状态" align="center" prop="status">
          <template #default="scope">
            <dict-tag :options="sys_normal_disable" :value="scope.row.status" />
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="addUserTotal > 0" :total="addUserTotal" v-model:page="addUserQueryParams.pageNum" v-model:limit="addUserQueryParams.pageSize" @pagination="getAddUserList" />
      <template #footer>
        <el-button type="primary" @click="submitAddUser">确 定</el-button>
        <el-button @click="addUserOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="WmsWarehouse">
/**
 * @description 仓库管理页面 - 仓库CRUD与用户授权
 * @description 提供仓库增删改查、关键词搜索、用户授权管理等功能
 */
import { listWarehouse, getWarehouse, delWarehouse, addWarehouse, updateWarehouse, getWarehouseUsers, assignUsers } from "@/api/wms/warehouse"
import { unallocatedUserList } from "@/api/system/role"

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict("sys_normal_disable")

const warehouseList = ref([])
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
  queryParams: { pageNum: 1, pageSize: 10, warehouseName: undefined, warehouseCode: undefined, status: undefined },
  rules: {
    warehouseName: [{ required: true, message: "仓库名称不能为空", trigger: "blur" }],
    warehouseCode: [{ required: true, message: "仓库编码不能为空", trigger: "blur" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

function getList() {
  loading.value = true
  listWarehouse(queryParams.value).then(response => {
    warehouseList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.warehouseId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function reset() {
  form.value = { warehouseId: undefined, warehouseName: undefined, warehouseCode: undefined, address: undefined, contactPerson: undefined, contactPhone: undefined, status: "0", remark: undefined }
  proxy.resetForm("warehouseRef")
}

function handleAdd() {
  reset()
  open.value = true
  title.value = "添加仓库"
}

function handleUpdate(row) {
  reset()
  const warehouseId = row.warehouseId || ids.value
  getWarehouse(warehouseId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改仓库"
  })
}

function submitForm() {
  proxy.$refs["warehouseRef"].validate(valid => {
    if (valid) {
      if (form.value.warehouseId != undefined) {
        updateWarehouse(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addWarehouse(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row) {
  const warehouseIds = row.warehouseId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(() => {
    return delWarehouse(warehouseIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

function cancel() {
  open.value = false
  reset()
}

// ========== 用户授权相关 ==========
const authOpen = ref(false)
const authLoading = ref(false)
const authUserList = ref([])
const authTotal = ref(0)
const authUserIds = ref([])
const authMultiple = ref(true)
const currentWarehouseId = ref(undefined)

const authQueryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  warehouseId: undefined,
  userName: undefined,
  phonenumber: undefined
})

function handleAuthUser(row) {
  currentWarehouseId.value = row.warehouseId
  authQueryParams.warehouseId = row.warehouseId
  authQueryParams.pageNum = 1
  authQueryParams.userName = undefined
  authQueryParams.phonenumber = undefined
  getAuthUserList()
  authOpen.value = true
}

function getAuthUserList() {
  authLoading.value = true
  getWarehouseUsers(authQueryParams.warehouseId).then(response => {
    authUserList.value = response.rows || response.data || []
    authTotal.value = response.total || 0
    authLoading.value = false
  })
}

function handleAuthQuery() {
  authQueryParams.pageNum = 1
  getAuthUserList()
}

function resetAuthQuery() {
  proxy.resetForm("authQueryRef")
  handleAuthQuery()
}

function handleAuthSelectionChange(selection) {
  authUserIds.value = selection.map(item => item.userId)
  authMultiple.value = !selection.length
}

function handleRemoveSingleUser(row) {
  proxy.$modal.confirm('是否确认移除该用户？').then(() => {
    return assignUsers({ warehouseId: currentWarehouseId.value, userIds: [row.userId], action: 'remove' })
  }).then(() => {
    getAuthUserList()
    proxy.$modal.msgSuccess("移除成功")
  }).catch(() => {})
}

function handleRemoveUser() {
  if (authUserIds.value.length === 0) {
    proxy.$modal.msgError("请选择要移除的用户")
    return
  }
  proxy.$modal.confirm('是否确认批量移除选中的用户？').then(() => {
    return assignUsers({ warehouseId: currentWarehouseId.value, userIds: authUserIds.value, action: 'remove' })
  }).then(() => {
    getAuthUserList()
    proxy.$modal.msgSuccess("移除成功")
  }).catch(() => {})
}

// ========== 添加用户相关 ==========
const addUserOpen = ref(false)
const addUserLoading = ref(false)
const addUserList = ref([])
const addUserTotal = ref(0)
const selectedAddUserIds = ref([])

const addUserQueryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  warehouseId: undefined,
  userName: undefined,
  phonenumber: undefined
})

function handleAddUser() {
  addUserQueryParams.warehouseId = currentWarehouseId.value
  addUserQueryParams.pageNum = 1
  addUserQueryParams.userName = undefined
  addUserQueryParams.phonenumber = undefined
  selectedAddUserIds.value = []
  getAddUserList()
  addUserOpen.value = true
}

function getAddUserList() {
  addUserLoading.value = true
  unallocatedUserList(addUserQueryParams).then(response => {
    addUserList.value = response.rows
    addUserTotal.value = response.total
    addUserLoading.value = false
  })
}

function handleAddUserQuery() {
  addUserQueryParams.pageNum = 1
  getAddUserList()
}

function resetAddUserQuery() {
  proxy.resetForm("addUserQueryRef")
  handleAddUserQuery()
}

function clickAddUserRow(row) {
  proxy.$refs["addUserTableRef"].toggleRowSelection(row)
}

function handleAddUserSelectionChange(selection) {
  selectedAddUserIds.value = selection.map(item => item.userId)
}

function submitAddUser() {
  if (selectedAddUserIds.value.length === 0) {
    proxy.$modal.msgError("请选择要添加的用户")
    return
  }
  assignUsers({ warehouseId: currentWarehouseId.value, userIds: selectedAddUserIds.value, action: 'add' }).then(() => {
    proxy.$modal.msgSuccess("添加成功")
    addUserOpen.value = false
    getAuthUserList()
  })
}

getList()
</script>
