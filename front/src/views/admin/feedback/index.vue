<template>
   <div class="app-container">
      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
         <el-form-item label="反馈标题" prop="title">
            <el-input v-model="queryParams.title" placeholder="请输入反馈标题" clearable style="width: 200px" @keyup.enter="handleQuery" />
         </el-form-item>
         <el-form-item label="反馈类型" prop="feedbackType">
            <el-select v-model="queryParams.feedbackType" placeholder="反馈类型" clearable style="width: 200px">
               <el-option v-for="dict in biz_feedback_type" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
         </el-form-item>
         <el-form-item label="处理状态" prop="status">
            <el-select v-model="queryParams.status" placeholder="处理状态" clearable style="width: 200px">
               <el-option v-for="dict in biz_feedback_status" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
         </el-form-item>
         <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
         </el-form-item>
      </el-form>

      <el-row :gutter="10" class="mb8">
         <el-col :span="1.5">
            <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['admin:feedback:remove']">删除</el-button>
         </el-col>
         <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
      </el-row>

      <el-table v-loading="loading" :data="feedbackList" @selection-change="handleSelectionChange">
         <el-table-column type="selection" width="55" align="center" />
         <el-table-column label="反馈ID" align="center" prop="feedbackId" min-width="80" />
         <el-table-column label="反馈标题" align="center" prop="title" :show-overflow-tooltip="true" />
         <el-table-column label="反馈类型" align="center" prop="feedbackType" min-width="100">
            <template #default="scope">
               <dict-tag :options="biz_feedback_type" :value="scope.row.feedbackType" />
            </template>
         </el-table-column>
         <el-table-column label="处理状态" align="center" prop="status" min-width="100">
            <template #default="scope">
               <dict-tag :options="biz_feedback_status" :value="scope.row.status" />
            </template>
         </el-table-column>
         <el-table-column label="创建人" align="center" prop="createBy" min-width="100" />
         <el-table-column label="创建时间" align="center" prop="createTime" min-width="160">
            <template #default="scope">
               <span>{{ parseTime(scope.row.createTime) }}</span>
            </template>
         </el-table-column>
         <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
            <template #default="scope">
               <el-button link type="primary" icon="View" @click="handleDetail(scope.row)">详情</el-button>
               <el-button link type="primary" icon="Edit" @click="handleHandle(scope.row)" v-hasPermi="['admin:feedback:handle']">处理</el-button>
               <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['admin:feedback:remove']">删除</el-button>
            </template>
         </el-table-column>
      </el-table>

      <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

      <el-dialog :title="detailTitle" v-model="detailOpen" width="700px" append-to-body>
         <el-descriptions :column="2" border>
            <el-descriptions-item label="反馈标题">{{ detailForm.title }}</el-descriptions-item>
            <el-descriptions-item label="反馈类型">
               <dict-tag :options="biz_feedback_type" :value="detailForm.feedbackType" />
            </el-descriptions-item>
            <el-descriptions-item label="处理状态">
               <dict-tag :options="biz_feedback_status" :value="detailForm.status" />
            </el-descriptions-item>
            <el-descriptions-item label="创建人">{{ detailForm.createBy }}</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ parseTime(detailForm.createTime) }}</el-descriptions-item>
            <el-descriptions-item label="反馈内容" :span="2">{{ detailForm.content }}</el-descriptions-item>
         </el-descriptions>
         <el-divider content-position="left">回复记录</el-divider>
         <el-timeline v-if="replyList.length > 0">
            <el-timeline-item v-for="reply in replyList" :key="reply.replyId" :timestamp="reply.createTime" placement="top">
               <p style="font-weight: 500; margin-bottom: 4px;">{{ reply.createNickName || reply.createBy }}</p>
               <p>{{ reply.content }}</p>
            </el-timeline-item>
         </el-timeline>
         <el-empty v-else description="暂无回复" :image-size="60" />
      </el-dialog>

      <el-dialog title="处理反馈" v-model="handleOpen" width="600px" append-to-body>
         <el-form ref="handleRef" :model="handleForm" :rules="handleRules" label-width="100px">
            <el-form-item label="反馈标题">
               <span>{{ handleForm.title }}</span>
            </el-form-item>
            <el-form-item label="处理状态" prop="status">
               <el-select v-model="handleForm.status" placeholder="请选择处理状态">
                  <el-option v-for="dict in biz_feedback_status" :key="dict.value" :label="dict.label" :value="dict.value" />
               </el-select>
            </el-form-item>
            <el-form-item label="回复内容" prop="replyContent">
               <el-input v-model="handleForm.replyContent" type="textarea" :rows="4" placeholder="请输入回复内容" />
            </el-form-item>
         </el-form>
         <template #footer>
            <el-button type="primary" @click="submitHandle">确 定</el-button>
            <el-button @click="handleOpen = false">取 消</el-button>
         </template>
      </el-dialog>
   </div>
</template>

<script setup name="Feedback">
import { listFeedback, getFeedback, delFeedback, handleFeedback, listReply } from "@/api/admin/feedback"

const { proxy } = getCurrentInstance()
const { biz_feedback_type, biz_feedback_status } = proxy.useDict("biz_feedback_type", "biz_feedback_status")

const feedbackList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const multiple = ref(true)
const total = ref(0)

const detailOpen = ref(false)
const detailTitle = ref("")
const detailForm = ref({})
const replyList = ref([])

const handleOpen = ref(false)
const handleForm = ref({})
const handleRules = { status: [{ required: true, message: "请选择处理状态", trigger: "change" }] }

const data = reactive({
   queryParams: { pageNum: 1, pageSize: 10, title: undefined, feedbackType: undefined, status: undefined }
})
const { queryParams } = toRefs(data)

function getList() {
   loading.value = true
   listFeedback(queryParams.value).then(response => {
      feedbackList.value = response.rows
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
   ids.value = selection.map(item => item.feedbackId)
   multiple.value = !selection.length
}

function handleDetail(row) {
   getFeedback(row.feedbackId).then(response => {
      detailForm.value = response.data
      replyList.value = response.data.replies || []
      detailTitle.value = "反馈详情"
      detailOpen.value = true
   })
}

function handleHandle(row) {
   handleForm.value = { feedbackId: row.feedbackId, title: row.title, status: row.status, replyContent: "" }
   handleOpen.value = true
}

function submitHandle() {
   proxy.$refs["handleRef"].validate(valid => {
      if (valid) {
         handleFeedback(handleForm.value).then(() => {
            proxy.$modal.msgSuccess("处理成功")
            handleOpen.value = false
            getList()
         })
      }
   })
}

function handleDelete(row) {
   const feedbackIds = row.feedbackId ? [row.feedbackId] : ids.value
   proxy.$modal.confirm('是否确认删除反馈编号为"' + feedbackIds + '"的数据项？').then(() => {
      return delFeedback(feedbackIds)
   }).then(() => {
      getList()
      proxy.$modal.msgSuccess("删除成功")
   }).catch(() => {})
}

getList()
</script>
