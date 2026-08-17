<template>
  <el-dialog title="回访详情" v-model="visible" width="720px" append-to-body>
    <div v-loading="loading">
      <el-descriptions :column="2" border size="small" v-if="task">
        <el-descriptions-item label="企业名称">{{ task.enterpriseName }}</el-descriptions-item>
        <el-descriptions-item label="门店">{{ task.storeName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="回访类型">
          <el-tag size="small">{{ getVisitTypeLabel(task.visitType) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="回访方式">
          <el-tag :type="task.visitMode === '1' ? '' : 'success'" size="small">{{ task.visitMode === '1' ? '员工填写' : 'H5链接' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(task.visitStatus)" size="small">{{ getStatusLabel(task.visitStatus) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="满意度">
          <el-rate v-if="task.satisfactionScore" :model-value="Number(task.satisfactionScore)" disabled show-score :max="5" />
          <span v-else style="color: #c0c4cc">-</span>
        </el-descriptions-item>
        <el-descriptions-item label="回访员工">{{ task.visitorUserName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="回访时间">{{ task.visitTime ? parseTime(task.visitTime) : '-' }}</el-descriptions-item>
        <el-descriptions-item label="企业负责人" v-if="task.contactName">{{ task.contactName }} {{ task.contactPhone }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ task.remark || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left" v-if="items.length > 0">问卷答案</el-divider>
      <div v-if="items.length > 0" style="padding: 0 8px">
        <div v-for="(item, idx) in items" :key="item.itemId" style="margin-bottom: 20px">
          <div style="font-weight: 600; margin-bottom: 8px">
            <span style="color: #3D6DF7; margin-right: 6px">{{ idx + 1 }}.</span>
            {{ item.questionTitle }}
            <el-tag size="small" style="margin-left: 8px">{{ getQuestionTypeLabel(item.questionType) }}</el-tag>
          </div>
          <div style="padding-left: 24px; color: #606266">
            <!-- 评分题 -->
            <el-rate v-if="item.questionType === '3'" :model-value="Number(getAnswerValue(item.itemId))" disabled show-score :max="5" />
            <!-- 单选/多选 -->
            <el-tag v-else-if="getAnswerValue(item.itemId)" type="success" size="small">{{ getAnswerValue(item.itemId) }}</el-tag>
            <!-- 文本 -->
            <div v-else-if="getAnswerText(item.itemId)" style="white-space: pre-wrap; line-height: 1.6">{{ getAnswerText(item.itemId) }}</div>
            <span v-else style="color: #c0c4cc">未作答</span>
          </div>
        </div>
      </div>
      <el-empty v-if="!loading && items.length === 0" description="暂无问卷数据" />
    </div>
    <template #footer>
      <el-button @click="visible = false">关 闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { getVisit } from '@/api/business/visit'

const { proxy } = getCurrentInstance()
const props = defineProps({ visible: Boolean, visitId: [Number, String] })
const emit = defineEmits(['update:visible'])

const visible = ref(props.visible)
const loading = ref(false)
const task = ref(null)
const items = ref([])
const answers = ref({})

watch(() => props.visible, (val) => {
  visible.value = val
  if (val && props.visitId) loadData()
})

watch(visible, (val) => emit('update:visible', val))

function loadData() {
  loading.value = true
  getVisit(props.visitId).then(res => {
    const data = res.data || res
    task.value = data.task || null
    items.value = data.items || []
    answers.value = data.answers || {}
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function getAnswerValue(itemId) {
  return answers.value[itemId]?.answerValue || ''
}

function getAnswerText(itemId) {
  return answers.value[itemId]?.answerText || ''
}

function getVisitTypeLabel(val) {
  const map = { after_service: '服务后回访', monthly: '月度回访', quarterly: '季度回访', custom: '自定义' }
  return map[val] || val || '-'
}

function getStatusType(status) {
  return { '0': 'warning', '1': 'success', '2': 'info' }[status] || 'info'
}

function getStatusLabel(status) {
  return { '0': '待回访', '1': '已完成', '2': '已取消' }[status] || '-'
}

function getQuestionTypeLabel(type) {
  return { '1': '单选', '2': '多选', '3': '评分', '4': '文本' }[type] || '-'
}

function parseTime(time) {
  return time ? String(time).replace('T', ' ').substring(0, 19) : '-'
}
</script>
