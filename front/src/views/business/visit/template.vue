<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="模板名称" prop="templateName">
        <el-input v-model="queryParams.templateName" placeholder="请输入模板名称" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="回访类型" prop="visitType">
        <el-select v-model="queryParams.visitType" placeholder="请选择" clearable style="width: 140px">
          <el-option v-for="dict in visit_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:visit:template:add']">新增模板</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="templateList">
      <el-table-column label="模板名称" prop="templateName" min-width="180" show-overflow-tooltip />
      <el-table-column label="回访类型" align="center" min-width="120">
        <template #default="scope">
          <el-tag size="small">{{ getVisitTypeLabel(scope.row.visitType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="题目数量" prop="itemCount" align="center" width="90">
        <template #default="scope">
          <span style="color: #3D6DF7; font-weight: 600">{{ scope.row.itemsCount || 0 }}</span>
        </template>
      </el-table-column>
      <el-table-column label="说明" prop="description" min-width="200" show-overflow-tooltip />
      <el-table-column label="状态" align="center" width="80">
        <template #default="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'info'" size="small">{{ scope.row.status === '0' ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" min-width="150">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200" class-name="small-padding fixed-width" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:visit:template:edit']">编辑</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:visit:template:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/编辑模板弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogOpen" width="860px" append-to-body>
      <el-form ref="templateFormRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="模板名称" prop="templateName">
              <el-input v-model="form.templateName" placeholder="如：服务后回访问卷" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="回访类型" prop="visitType">
              <el-select v-model="form.visitType" placeholder="请选择回访类型" style="width: 100%">
                <el-option v-for="dict in visit_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="说明" prop="description">
          <el-input v-model="form.description" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" placeholder="选填" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="0">启用</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-divider content-position="left">题目设置</el-divider>
        <div style="margin-bottom: 12px">
          <el-button type="primary" plain icon="Plus" size="small" @click="addItem">添加题目</el-button>
        </div>
        <el-table :data="form.items" border size="small" style="width: 100%">
          <el-table-column label="序号" type="index" width="50" align="center" />
          <el-table-column label="题目内容" min-width="200">
            <template #default="scope">
              <el-input v-model="scope.row.questionTitle" placeholder="请输入题目" size="small" />
            </template>
          </el-table-column>
          <el-table-column label="题型" width="100">
            <template #default="scope">
              <el-select v-model="scope.row.questionType" placeholder="选择" size="small" style="width: 100%">
                <el-option label="单选" value="1" />
                <el-option label="多选" value="2" />
                <el-option label="评分" value="3" />
                <el-option label="文本" value="4" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="选项(逗号分隔)" min-width="200">
            <template #default="scope">
              <el-input v-model="scope.row.optionsText" placeholder="如：满意,基本满意,不满意" size="small" :disabled="scope.row.questionType === '3' || scope.row.questionType === '4'" />
            </template>
          </el-table-column>
          <el-table-column label="必填" width="60" align="center">
            <template #default="scope">
              <el-checkbox v-model="scope.row.required" true-value="0" false-value="1" />
            </template>
          </el-table-column>
          <el-table-column label="排序" width="70" align="center">
            <template #default="scope">
              <el-input-number v-model="scope.row.sortOrder" :min="0" :max="999" size="small" controls-position="right" style="width: 60px" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="70" align="center">
            <template #default="scope">
              <el-button link type="danger" icon="Delete" size="small" @click="removeItem(scope.$index)" />
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-if="form.items.length === 0" description="请添加题目" :image-size="60" />
      </el-form>
      <template #footer>
        <el-button @click="dialogOpen = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="VisitTemplate">
import { listVisitTemplate, getVisitTemplate, addVisitTemplate, updateVisitTemplate, delVisitTemplate } from '@/api/business/visit'

const { proxy } = getCurrentInstance()
const { biz_visit_type: visit_type } = proxy.useDict('biz_visit_type')

const templateList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dialogOpen = ref(false)
const dialogTitle = ref('')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  templateName: undefined,
  visitType: undefined
})

const form = reactive({
  templateId: null,
  templateName: '',
  visitType: 'after_service',
  description: '',
  status: '0',
  items: []
})

const rules = {
  templateName: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  visitType: [{ required: true, message: '请选择回访类型', trigger: 'change' }]
}

function getVisitTypeLabel(val) {
  const item = visit_type.value?.find(d => d.value === val)
  return item ? item.label : (val || '-')
}

function parseTime(time) {
  return time ? String(time).replace('T', ' ').substring(0, 19) : '-'
}

function getList() {
  loading.value = true
  listVisitTemplate(queryParams).then(res => {
    templateList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleAdd() {
  resetForm()
  dialogTitle.value = '新增模板'
  dialogOpen.value = true
}

function handleUpdate(row) {
  resetForm()
  dialogTitle.value = '编辑模板'
  getVisitTemplate(row.templateId).then(res => {
    const data = res.data || res
    const tpl = data.template
    if (tpl) {
      Object.assign(form, {
        templateId: tpl.templateId,
        templateName: tpl.templateName,
        visitType: tpl.visitType,
        description: tpl.description,
        status: tpl.status
      })
    }
    form.items = (data.items || []).map(item => ({
      itemId: item.itemId,
      questionTitle: item.questionTitle,
      questionType: item.questionType,
      optionsText: Array.isArray(item.options) ? item.options.join(',') : (item.options || ''),
      required: item.required || '0',
      sortOrder: item.sortOrder || 0
    }))
    dialogOpen.value = true
  })
}

function resetForm() {
  Object.assign(form, {
    templateId: null,
    templateName: '',
    visitType: 'after_service',
    description: '',
    status: '0',
    items: []
  })
  if (proxy.$refs.templateFormRef) proxy.$refs.templateFormRef.resetFields()
}

function addItem() {
  form.items.push({
    questionTitle: '',
    questionType: '1',
    optionsText: '',
    required: '0',
    sortOrder: form.items.length + 1
  })
}

function removeItem(index) {
  form.items.splice(index, 1)
}

function submitForm() {
  proxy.$refs.templateFormRef.validate(valid => {
    if (!valid) return
    if (form.items.length === 0) {
      proxy.$modal.msgError('请至少添加一道题目')
      return
    }
    // 校验题目内容
    for (const item of form.items) {
      if (!item.questionTitle) {
        proxy.$modal.msgError('题目内容不能为空')
        return
      }
      if ((item.questionType === '1' || item.questionType === '2') && !item.optionsText) {
        proxy.$modal.msgError('单选/多选题必须填写选项')
        return
      }
    }
    // 构建 items payload
    const itemsPayload = form.items.map(item => ({
      question_title: item.questionTitle,
      question_type: item.questionType,
      options: (item.questionType === '1' || item.questionType === '2') ? item.optionsText.split(',').map(s => s.trim()).filter(s => s) : [],
      sort_order: item.sortOrder || 0,
      required: item.required
    }))

    const data = {
      templateName: form.templateName,
      visitType: form.visitType,
      description: form.description,
      status: form.status,
      items: itemsPayload
    }

    if (form.templateId) {
      data.templateId = form.templateId
      updateVisitTemplate(data).then(() => {
        proxy.$modal.msgSuccess('修改成功')
        dialogOpen.value = false
        getList()
      })
    } else {
      addVisitTemplate(data).then(() => {
        proxy.$modal.msgSuccess('新增成功')
        dialogOpen.value = false
        getList()
      })
    }
  })
}

function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除模板"' + row.templateName + '"？').then(() => {
    return delVisitTemplate(row.templateId)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

getList()
</script>
