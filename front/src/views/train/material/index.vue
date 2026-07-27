<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="材料标题" prop="title">
        <el-input v-model="queryParams.title" placeholder="请输入材料标题" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="分类" prop="category">
        <el-select v-model="queryParams.category" placeholder="请选择分类" clearable style="width: 160px">
          <el-option v-for="dict in biz_train_material_category" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="文件类型" prop="fileType">
        <el-select v-model="queryParams.fileType" placeholder="请选择类型" clearable style="width: 140px">
          <el-option v-for="dict in biz_train_material_file_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 140px">
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
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['train:material:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['train:material:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['train:material:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['train:material:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="materialList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="标题" prop="title" min-width="160" show-overflow-tooltip />
      <el-table-column label="分类" prop="category" min-width="100" align="center">
        <template #default="scope">
          <dict-tag :options="biz_train_material_category" :value="scope.row.category" />
        </template>
      </el-table-column>
      <el-table-column label="文件类型" prop="fileType" min-width="90" align="center">
        <template #default="scope">
          <dict-tag :options="biz_train_material_file_type" :value="scope.row.fileType" />
        </template>
      </el-table-column>
      <el-table-column label="建议时长" prop="studyDuration" min-width="100" align="center">
        <template #default="scope">{{ formatDuration(scope.row.studyDuration) }}</template>
      </el-table-column>
      <el-table-column label="排序" prop="sort" min-width="70" align="center" />
      <el-table-column label="状态" prop="status" min-width="70" align="center">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1"
            @change="(val) => handleStatusChange(scope.row, val)" v-hasPermi="['train:material:edit']" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" min-width="150" />
      <el-table-column label="操作" min-width="290" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handlePreview(scope.row)" v-hasPermi="['train:material:query']">预览</el-button>
          <el-button link type="primary" icon="Download" @click="handleDownload(scope.row)" v-hasPermi="['train:material:query']">下载</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['train:material:edit']">修改</el-button>
          <el-button link type="primary" icon="Lock" @click="handleAuth(scope.row)" v-hasPermi="['train:material:auth']">授权</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['train:material:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="680px" append-to-body>
      <el-form ref="materialRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="材料标题" prop="title">
              <el-input v-model="form.title" placeholder="请输入材料标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="材料分类" prop="category">
              <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
                <el-option v-for="dict in biz_train_material_category" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文件类型" prop="fileType">
              <el-select v-model="form.fileType" placeholder="请选择类型" style="width: 100%">
                <el-option v-for="dict in biz_train_material_file_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="材料文件" prop="fileUrl">
              <el-upload
                ref="uploadRef"
                :action="uploadUrl"
                :headers="uploadHeaders"
                :show-file-list="false"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                :before-upload="beforeUpload"
              >
                <el-button type="primary" icon="Upload">上传文件</el-button>
              </el-upload>
              <span v-if="form.fileUrl" class="file-name">{{ form.fileUrl }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="封面图" prop="coverUrl">
              <el-upload
                :action="uploadUrl"
                :headers="uploadHeaders"
                :show-file-list="false"
                :on-success="handleCoverSuccess"
                accept="image/*"
              >
                <img v-if="form.coverUrl" :src="coverFullUrl" class="cover-img" />
                <el-button v-else type="primary" plain icon="Picture">上传封面</el-button>
              </el-upload>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="建议时长" prop="studyDuration">
              <el-input-number v-model="form.studyDuration" :min="0" :step="60" style="width: 100%" />
              <span style="margin-left: 8px; color: #909399; font-size: 12px;">秒</span>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序" prop="sort">
              <el-input-number v-model="form.sort" :min="0" style="width: 100%" />
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
            <el-form-item label="材料简介" prop="description">
              <el-input v-model="form.description" type="textarea" placeholder="请输入材料简介" :rows="3" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 授权管理弹窗 -->
    <el-dialog title="材料授权管理" v-model="authOpen" width="600px" append-to-body>
      <el-form label-width="100px">
        <el-form-item label="材料标题">
          <span>{{ authForm.title }}</span>
        </el-form-item>
        <el-form-item label="授权范围">
          <el-radio-group v-model="authForm.authType">
            <el-radio value="all">全员可见</el-radio>
            <el-radio value="custom">指定用户和部门</el-radio>
          </el-radio-group>
        </el-form-item>
        <template v-if="authForm.authType === 'custom'">
          <el-form-item label="授权部门">
            <el-tree-select
              v-model="authForm.deptIds"
              :data="deptOptions"
              :props="{ value: 'id', label: 'label', children: 'children' }"
              multiple
              check-strictly
              node-key="id"
              placeholder="请选择部门"
              style="width: 100%"
              clearable
            />
          </el-form-item>
          <el-form-item label="授权用户">
            <el-select
              v-model="authForm.userIds"
              multiple
              filterable
              automatic-dropdown
              placeholder="请选择用户"
              style="width: 100%"
            >
              <el-option v-for="item in userOptions" :key="item.userId" :label="item.nickName + ' (' + item.userName + ')'" :value="item.userId" />
            </el-select>
          </el-form-item>
        </template>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitAuth">确 定</el-button>
        <el-button @click="authOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="TrainMaterial">
import { listMaterial, getMaterial, delMaterial, addMaterial, updateMaterial } from "@/api/train/material"
import { getMaterialAuth, saveMaterialAuth } from "@/api/train/auth"
import { listUser } from "@/api/system/user"
import { treeselect } from "@/api/system/dept"
import { getToken } from "@/utils/auth"
import { useRouter } from "vue-router"

const { proxy } = getCurrentInstance()
const router = useRouter()
const { sys_normal_disable, biz_train_material_category, biz_train_material_file_type } = useDict("sys_normal_disable", "biz_train_material_category", "biz_train_material_file_type")

const materialList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")

const baseUrl = import.meta.env.VITE_APP_BASE_API
const uploadUrl = ref(baseUrl + '/common/upload')
const uploadHeaders = ref({ Authorization: "Bearer " + getToken() })

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, title: undefined, category: undefined, fileType: undefined, status: undefined },
  rules: {
    title: [{ required: true, message: "材料标题不能为空", trigger: "blur" }],
    category: [{ required: true, message: "材料分类不能为空", trigger: "change" }],
    fileType: [{ required: true, message: "文件类型不能为空", trigger: "change" }],
    fileUrl: [{ required: true, message: "请上传材料文件", trigger: "change" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

const coverFullUrl = computed(() => {
  if (!form.value.coverUrl) return ''
  return form.value.coverUrl.startsWith('http') ? form.value.coverUrl : baseUrl + form.value.coverUrl
})

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

function getList() {
  loading.value = true
  listMaterial(queryParams.value).then(response => {
    materialList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }
function handleSelectionChange(selection) { ids.value = selection.map(item => item.materialId); single.value = selection.length !== 1; multiple.value = !selection.length }

function reset() {
  form.value = { materialId: undefined, title: undefined, category: undefined, fileType: undefined, fileUrl: undefined, fileSize: 0, coverUrl: undefined, description: undefined, studyDuration: 0, sort: 0, status: "0" }
  proxy.resetForm("materialRef")
}

function handleAdd() { reset(); open.value = true; title.value = "添加学习材料" }

function handleUpdate(row) {
  reset()
  const materialId = row.materialId || ids.value
  getMaterial(materialId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改学习材料"
  })
}

function submitForm() {
  proxy.$refs["materialRef"].validate(valid => {
    if (valid) {
      if (form.value.materialId != undefined) {
        updateMaterial(form.value).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() })
      } else {
        addMaterial(form.value).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
      }
    }
  })
}

function handleExport() {
  proxy.download("train/material/export", { ...queryParams.value }, `material_${new Date().getTime()}.xlsx`)
}

function handlePreview(row) {
  router.push({ path: '/train/preview', query: { materialId: row.materialId } })
}

// 下载原始文件（PPT 等），后端带权限和授权校验
function handleDownload(row) {
  if (!row.fileUrl) {
    proxy.$modal.msgError('该材料暂无可下载的文件')
    return
  }
  // 提取扩展名，使用材料标题作为下载文件名
  const ext = row.fileUrl.split('.').pop()
  const safeTitle = (row.title || 'material').replace(/[\\/:*?"<>|]/g, '')
  const fileName = ext ? `${safeTitle}.${ext}` : safeTitle
  proxy.$download.zip('/train/material/download/' + row.materialId, fileName)
}

function handleDelete(row) {
  const materialIds = row.materialId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(() => delMaterial(materialIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function handleStatusChange(row, val) {
  const text = val === '0' ? '启用' : '停用'
  proxy.$modal.confirm('确认要"' + text + '""' + row.title + '"吗？').then(() => {
    return updateMaterial({ materialId: row.materialId, status: val })
  }).then(() => { proxy.$modal.msgSuccess(text + "成功") }).catch(() => {
    row.status = val === '0' ? '1' : '0'
  })
}

function cancel() { open.value = false; reset() }

function beforeUpload(file) {
  const allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt']
  const ext = file.name.split('.').pop().toLowerCase()
  if (!allowedExts.includes(ext)) {
    proxy.$modal.msgError('不支持的文件类型: ' + ext)
    return false
  }
  return true
}

function handleUploadSuccess(res, file) {
  if (res.code === 200) {
    form.value.fileUrl = res.url
    form.value.fileSize = file.size
    proxy.$modal.msgSuccess("文件上传成功")
  } else {
    proxy.$modal.msgError(res.msg || '上传失败')
  }
}

function handleCoverSuccess(res) {
  if (res.code === 200) {
    form.value.coverUrl = res.url
  } else {
    proxy.$modal.msgError(res.msg || '封面上传失败')
  }
}

function handleUploadError() {
  proxy.$modal.msgError("文件上传失败")
}

// ===== 授权管理 =====
const authOpen = ref(false)
const deptOptions = ref([])
const userOptions = ref([])
const userLoading = ref(false)
const authForm = ref({
  materialId: null,
  title: '',
  authType: 'all',
  userIds: [],
  deptIds: [],
})

function handleAuth(row) {
  authForm.value.materialId = row.materialId
  authForm.value.title = row.title
  authForm.value.authType = 'all'
  authForm.value.userIds = []
  authForm.value.deptIds = []
  authOpen.value = true
  // 加载部门树
  treeselect().then(res => {
    deptOptions.value = res.data
  })
  // 加载全部用户列表（最多500条）
  listUser({ pageNum: 1, pageSize: 500 }).then(res => {
    userOptions.value = res.rows || []
  })
  // 加载授权配置
  getMaterialAuth(row.materialId).then(res => {
    const config = res.data || {}
    authForm.value.authType = config.auth_type || 'all'
    authForm.value.userIds = (config.user_ids || []).map(Number)
    authForm.value.deptIds = (config.dept_ids || []).map(Number)
  })
}

// 清理无用函数（原远程搜索已移除）

function submitAuth() {
  const data = {
    materialId: authForm.value.materialId,
    userIds: authForm.value.authType === 'custom' ? authForm.value.userIds : [],
    deptIds: authForm.value.authType === 'custom' ? authForm.value.deptIds : [],
  }
  saveMaterialAuth(data).then(() => {
    proxy.$modal.msgSuccess('授权配置保存成功')
    authOpen.value = false
  })
}

getList()
</script>

<style scoped>
.file-name {
  margin-left: 10px;
  color: #67c23a;
  font-size: 13px;
}
.cover-img {
  width: 120px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
}
</style>
