<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="用户姓名" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入用户姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="材料标题" prop="materialTitle">
        <el-input v-model="queryParams.materialTitle" placeholder="请输入材料标题" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="学习时间">
        <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="logList">
      <el-table-column label="用户" prop="userName" min-width="100" />
      <el-table-column label="材料标题" prop="materialTitle" min-width="160" show-overflow-tooltip />
      <el-table-column label="开始时间" prop="startTime" min-width="150" />
      <el-table-column label="结束时间" prop="endTime" min-width="150" />
      <el-table-column label="有效时长" prop="validDuration" min-width="110" align="center">
        <template #default="scope">{{ formatDuration(scope.row.validDuration) }}</template>
      </el-table-column>
      <el-table-column label="暂停次数" prop="pauseCount" min-width="90" align="center" />
      <el-table-column label="切屏次数" prop="switchCount" min-width="90" align="center" />
      <el-table-column label="状态" prop="status" min-width="90" align="center">
        <template #default="scope">
          <dict-tag :options="biz_train_study_status" :value="scope.row.status" />
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup name="TrainStudyLog">
import { listStudyLog } from "@/api/train/material"

const { proxy } = getCurrentInstance()
const { biz_train_study_status } = useDict("biz_train_study_status")

const logList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dateRange = ref([])

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, userName: undefined, materialTitle: undefined }
})
const { queryParams } = toRefs(data)

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  if (h > 0) return `${h}时${m}分${s}秒`
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.startDate = dateRange.value[0]
    params.endDate = dateRange.value[1]
  }
  listStudyLog(params).then(response => {
    logList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); dateRange.value = []; handleQuery() }

getList()
</script>
