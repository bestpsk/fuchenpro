<template>
   <div class="app-container">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
         <el-form-item label="标题" prop="aboutTitle">
            <el-input
               v-model="queryParams.aboutTitle"
               placeholder="请输入标题"
               clearable
               style="width: 200px"
               @keyup.enter="handleQuery"
            />
         </el-form-item>
         <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
         </el-form-item>
      </el-form>

      <el-row :gutter="10" class="mb8">
         <el-col :span="1.5">
            <el-button
               type="primary"
               plain
               icon="Plus"
               @click="handleAdd"
               v-hasPermi="['admin:about:add']"
            >新增</el-button>
         </el-col>
         <el-col :span="1.5">
            <el-button
               type="success"
               plain
               icon="Edit"
               :disabled="single"
               @click="handleUpdate"
               v-hasPermi="['admin:about:edit']"
            >修改</el-button>
         </el-col>
         <el-col :span="1.5">
            <el-button
               type="danger"
               plain
               icon="Delete"
               :disabled="multiple"
               @click="handleDelete"
               v-hasPermi="['admin:about:remove']"
            >删除</el-button>
         </el-col>
         <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <el-table v-loading="loading" :data="aboutList" @selection-change="handleSelectionChange">
         <el-table-column type="selection" width="55" align="center" />
         <el-table-column label="序号" align="center" prop="aboutId" min-width="100" />
         <el-table-column label="封面" align="center" min-width="80">
            <template #default="scope">
               <el-image v-if="scope.row.coverUrl" :src="baseUrl + scope.row.coverUrl" fit="cover" style="width: 50px; height: 50px; border-radius: 6px" :preview-src-list="[baseUrl + scope.row.coverUrl]" />
               <span v-else>-</span>
            </template>
         </el-table-column>
         <el-table-column label="标题" align="center" :show-overflow-tooltip="true" prop="aboutTitle" />
         <el-table-column label="状态" align="center" prop="status" min-width="100">
            <template #default="scope">
               <el-switch
                  v-model="scope.row.status"
                  :active-value="'0'"
                  :inactive-value="'1'"
                  @change="handleStatusChange(scope.row)"
                  v-hasPermi="['admin:about:edit']"
               />
            </template>
         </el-table-column>
         <el-table-column label="创建者" align="center" prop="createBy" min-width="100" />
         <el-table-column label="创建时间" align="center" prop="createTime" min-width="100">
            <template #default="scope">
               <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
            </template>
         </el-table-column>
         <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
            <template #default="scope">
               <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['admin:about:edit']">修改</el-button>
               <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['admin:about:remove']" >删除</el-button>
            </template>
         </el-table-column>
      </el-table>

      <pagination
         v-show="total > 0"
         :total="total"
         v-model:page="queryParams.pageNum"
         v-model:limit="queryParams.pageSize"
         @pagination="getList"
      />

      <!-- 添加或修改企业小报对话框 -->
      <el-dialog :title="title" v-model="open" width="780px" append-to-body>
         <el-form ref="aboutRef" :model="form" :rules="rules" label-width="80px">
            <el-row>
               <el-col :span="12">
                  <el-form-item label="标题" prop="aboutTitle">
                     <el-input v-model="form.aboutTitle" placeholder="请输入标题" />
                  </el-form-item>
               </el-col>
               <el-col :span="12">
                  <el-form-item label="排序" prop="sort">
                     <el-input-number v-model="form.sort" :min="0" controls-position="right" />
                  </el-form-item>
               </el-col>
               <el-col :span="24">
                  <el-form-item label="封面图" prop="coverUrl">
                    <image-upload v-model="form.coverUrl" :limit="1" :fileSize="5" :fileType="['jpg','jpeg','png','gif']" :isShowTip="false" />
                  </el-form-item>
               </el-col>
               <el-col :span="24">
                  <el-form-item label="状态">
                     <el-radio-group v-model="form.status">
                        <el-radio value="0">正常</el-radio>
                        <el-radio value="1">关闭</el-radio>
                     </el-radio-group>
                  </el-form-item>
               </el-col>
               <el-col :span="24">
                  <el-form-item label="内容">
                    <editor v-model="form.aboutContent" :min-height="192"/>
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

<script setup name="About">
/**
 * @description 企业小报管理页面 - 增删改查
 */
import { listAbout, getAbout, delAbout, addAbout, updateAbout } from "@/api/admin/about"
import ImageUpload from "@/components/ImageUpload"

const { proxy } = getCurrentInstance()
const baseUrl = import.meta.env.VITE_APP_BASE_API

const aboutList = ref([])
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
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    aboutTitle: undefined,
  },
  rules: {
    aboutTitle: [{ required: true, message: "标题不能为空", trigger: "blur" }],
  },
})

const { queryParams, form, rules } = toRefs(data)

/** 查询企业小报列表 */
function getList() {
  loading.value = true
  listAbout(queryParams.value).then(response => {
    aboutList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}

/** 表单重置 */
function reset() {
  form.value = {
    aboutId: undefined,
    aboutTitle: undefined,
    coverUrl: '',
    aboutContent: undefined,
    status: "0",
    sort: 0
  }
  proxy.resetForm("aboutRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.aboutId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加企业小报"
}

/**修改按钮操作 */
function handleUpdate(row) {
  reset()
  const aboutId = row.aboutId || ids.value
  getAbout(aboutId).then(response => {
    const data = response.data || response
    form.value = {
      aboutId: data.aboutId,
      aboutTitle: data.aboutTitle,
      coverUrl: data.coverUrl || '',
      aboutContent: data.aboutContent,
      status: data.status,
      sort: data.sort,
      remark: data.remark
    }
    open.value = true
    title.value = "修改企业小报"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["aboutRef"].validate(valid => {
    if (valid) {
      const submitData = {
        aboutId: form.value.aboutId,
        aboutTitle: form.value.aboutTitle,
        coverUrl: form.value.coverUrl,
        aboutContent: form.value.aboutContent,
        status: form.value.status,
        sort: form.value.sort
      }
      if (form.value.aboutId != undefined) {
        updateAbout(submitData).then(response => {
          if (response.code === 200) {
            proxy.$modal.msgSuccess("修改成功")
            open.value = false
            getList()
          } else {
            proxy.$modal.msgError(response.msg || "修改失败")
          }
        }).catch(err => {
          proxy.$modal.msgError(err.msg || err.message || "修改失败")
        })
      } else {
        addAbout(submitData).then(response => {
          if (response.code === 200) {
            proxy.$modal.msgSuccess("新增成功")
            open.value = false
            getList()
          } else {
            proxy.$modal.msgError(response.msg || "新增失败")
          }
        }).catch(err => {
          proxy.$modal.msgError(err.msg || err.message || "新增失败")
        })
      }
    }
  })
}

function handleStatusChange(row) {
  let text = row.status === "0" ? "启用" : "关闭"
  proxy.$modal.confirm('确认' + text + '企业小报"' + row.aboutTitle + '"？').then(() => {
    return updateAbout({ aboutId: row.aboutId, status: row.status })
  }).then(() => {
    proxy.$modal.msgSuccess(text + "成功")
  }).catch(() => {
    row.status = row.status === "0" ? "1" : "0"
  })
}

/** 删除按钮操作 */
function handleDelete(row) {
  const aboutIds = row.aboutId || ids.value
  proxy.$modal.confirm('是否确认删除企业小报编号为"' + aboutIds + '"的数据项？').then(function() {
    return delAbout(aboutIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

getList()
</script>
