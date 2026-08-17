<template>
  <el-dialog :title="title" v-model="visible" width="720px" append-to-body @close="cancel">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="企业" prop="enterpriseId">
            <el-select v-model="form.enterpriseId" filterable remote reserve-keyword :remote-method="searchEnterprise" :loading="enterpriseLoading" placeholder="输入企业名称搜索" style="width: 100%" @change="onEnterpriseChange">
              <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="回访模板" prop="templateId">
            <el-select v-model="form.templateId" placeholder="请选择模板" style="width: 100%" @change="onTemplateChange">
              <el-option v-for="item in templateOptions" :key="item.templateId" :label="item.templateName" :value="item.templateId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="回访方式" prop="visitMode">
            <el-radio-group v-model="form.visitMode">
              <el-radio value="1">员工填写</el-radio>
              <el-radio value="2">H5链接填写</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="门店" prop="storeId">
            <el-input v-model="form.storeName" placeholder="选填" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" placeholder="选填" />
      </el-form-item>

      <!-- 员工填写模式：展示问卷题目 -->
      <div v-if="form.visitMode === '1' && templateItems.length > 0">
        <el-divider content-position="left">填写问卷</el-divider>
        <el-form-item v-for="item in templateItems" :key="item.itemId" :label="item.questionTitle + (item.required === '0' ? ' *' : '')" :prop="'answers.' + item.itemId" :rules="item.required === '0' ? [{ required: true, message: '此项必填', trigger: 'change' }] : []">
          <!-- 单选题 -->
          <el-radio-group v-if="item.questionType === '1'" v-model="form.answers[item.itemId]">
            <el-radio v-for="opt in item.options" :key="opt" :value="opt">{{ opt }}</el-radio>
          </el-radio-group>
          <!-- 多选题 -->
          <el-checkbox-group v-else-if="item.questionType === '2'" v-model="form.answers[item.itemId]">
            <el-checkbox v-for="opt in item.options" :key="opt" :value="opt" :label="opt" />
          </el-checkbox-group>
          <!-- 评分题 -->
          <el-rate v-else-if="item.questionType === '3'" v-model="form.answers[item.itemId]" :max="5" show-score />
          <!-- 文本题 -->
          <el-input v-else v-model="form.answers[item.itemId]" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" placeholder="请输入" />
        </el-form-item>
      </div>

      <!-- H5模式提示 -->
      <el-alert v-if="form.visitMode === '2'" title="H5链接模式：创建任务后可在列表中点击「生成链接」获取分享链接，发送给企业负责人填写" type="info" :closable="false" show-icon style="margin-top: 12px" />
    </el-form>
    <template #footer>
      <el-button @click="cancel">取 消</el-button>
      <el-button type="primary" @click="submitForm">确 定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { addVisit, updateVisit, getVisit, listVisitTemplate, getVisitTemplate } from '@/api/business/visit'

const { proxy } = getCurrentInstance()
const props = defineProps({ visible: Boolean, visitId: [Number, String] })
const emit = defineEmits(['update:visible', 'success'])

const visible = ref(props.visible)
const title = ref('')
const enterpriseOptions = ref([])
const enterpriseLoading = ref(false)
const templateOptions = ref([])
const templateItems = ref([])

const form = reactive({
  visitId: null,
  enterpriseId: undefined,
  enterpriseName: '',
  templateId: undefined,
  visitMode: '1',
  storeId: undefined,
  storeName: '',
  remark: '',
  answers: {}
})

const rules = {
  enterpriseId: [{ required: true, message: '请选择企业', trigger: 'change' }],
  templateId: [{ required: true, message: '请选择回访模板', trigger: 'change' }],
  visitMode: [{ required: true, message: '请选择回访方式', trigger: 'change' }]
}

watch(() => props.visible, (val) => {
  visible.value = val
  if (val) {
    resetForm()
    loadTemplates()
    if (props.visitId) {
      title.value = '编辑回访'
      loadVisitDetail(props.visitId)
    } else {
      title.value = '新增回访'
    }
  }
})

watch(visible, (val) => {
  emit('update:visible', val)
})

function resetForm() {
  Object.assign(form, {
    visitId: null, enterpriseId: undefined, enterpriseName: '',
    templateId: undefined, visitMode: '1', storeId: undefined,
    storeName: '', remark: '', answers: {}
  })
  templateItems.value = []
  if (proxy.$refs.formRef) proxy.$refs.formRef.resetFields()
}

function loadTemplates() {
  listVisitTemplate({ pageNum: 1, pageSize: 100, status: '0' }).then(res => {
    templateOptions.value = res.rows || []
  })
}

function searchEnterprise(keyword) {
  if (!keyword) return
  enterpriseLoading.value = true
  import('@/api/business/enterprise').then(m => {
    return m.searchEnterprise(keyword)
  }).then(res => {
    enterpriseOptions.value = res.data || []
  }).finally(() => {
    enterpriseLoading.value = false
  })
}

function onEnterpriseChange(val) {
  const ent = enterpriseOptions.value.find(e => e.enterpriseId === val)
  if (ent) form.enterpriseName = ent.enterpriseName
}

async function onTemplateChange(val) {
  if (!val) {
    templateItems.value = []
    return
  }
  const res = await getVisitTemplate(val)
  const data = res.data || res
  templateItems.value = data.items || []
  // 初始化answers结构
  templateItems.value.forEach(item => {
    if (!(item.itemId in form.answers)) {
      form.answers[item.itemId] = item.questionType === '2' ? [] : (item.questionType === '3' ? 0 : '')
    }
  })
}

function loadVisitDetail(visitId) {
  getVisit(visitId).then(res => {
    const data = res.data || res
    const task = data.task
    if (task) {
      Object.assign(form, {
        visitId: task.visitId,
        enterpriseId: task.enterpriseId,
        enterpriseName: task.enterpriseName,
        templateId: task.templateId,
        visitMode: task.visitMode,
        storeId: task.storeId,
        storeName: task.storeName,
        remark: task.remark
      })
      // 加载模板题目
      if (task.templateId) onTemplateChange(task.templateId)
      // 回填答案
      if (data.answers) {
        const answers = {}
        Object.values(data.answers).forEach(ans => {
          let val = ans.answerValue
          if (ans.questionType === '2') {
            val = val ? val.split(',') : []
          } else if (ans.questionType === '3') {
            val = Number(val) || 0
          }
          answers[ans.itemId] = val !== '' && val !== null ? val : (ans.answerText || '')
        })
        form.answers = answers
      }
    }
  })
}

function buildAnswersPayload() {
  const payload = []
  templateItems.value.forEach(item => {
    const val = form.answers[item.itemId]
    if (val !== undefined && val !== '' && !(Array.isArray(val) && val.length === 0)) {
      if (item.questionType === '4') {
        // 文本题：存到answer_text
        payload.push({ item_id: item.itemId, answer_value: '', answer_text: String(val) })
      } else {
        payload.push({ item_id: item.itemId, answer_value: Array.isArray(val) ? val.join(',') : String(val), answer_text: '' })
      }
    }
  })
  return payload
}

function submitForm() {
  proxy.$refs.formRef.validate(valid => {
    if (!valid) return
    const data = {
      enterpriseId: form.enterpriseId,
      enterpriseName: form.enterpriseName,
      templateId: form.templateId,
      visitMode: form.visitMode,
      storeId: form.storeId,
      storeName: form.storeName,
      remark: form.remark
    }
    // 员工填写模式附带答案
    if (form.visitMode === '1' && templateItems.value.length > 0) {
      data.answers = buildAnswersPayload()
    }
    if (form.visitId) {
      data.visitId = form.visitId
      updateVisit(data).then(() => {
        proxy.$modal.msgSuccess('修改成功')
        emit('success')
        visible.value = false
      })
    } else {
      addVisit(data).then(() => {
        proxy.$modal.msgSuccess('新增成功')
        emit('success')
        visible.value = false
      })
    }
  })
}

function cancel() {
  visible.value = false
}
</script>
