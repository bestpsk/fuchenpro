<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="材料标题" prop="title">
        <el-input v-model="queryParams.title" placeholder="请输入材料标题" clearable style="width: 200px" @keyup.enter="handleQuery" />
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
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="materialList">
      <el-table-column label="标题" prop="title" min-width="200" show-overflow-tooltip />
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
      <el-table-column label="简介" prop="description" min-width="240" show-overflow-tooltip />
      <el-table-column label="建议时长" prop="studyDuration" min-width="100" align="center">
        <template #default="scope">{{ formatDuration(scope.row.studyDuration) }}</template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" min-width="150" />
      <el-table-column label="操作" min-width="120" align="center" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handlePreview(scope.row)" v-hasPermi="['train:study:query']">在线预览</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup name="TrainOnline">
import { listStudyMaterial } from "@/api/train/study"

const { proxy } = getCurrentInstance()
const router = useRouter()
const { biz_train_material_category, biz_train_material_file_type } = useDict("biz_train_material_category", "biz_train_material_file_type")

const materialList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, title: undefined, category: undefined, fileType: undefined }
})
const { queryParams } = toRefs(data)

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

function getList() {
  loading.value = true
  listStudyMaterial(queryParams.value).then(response => {
    materialList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handlePreview(row) {
  router.push({ path: '/train/preview', query: { materialId: row.materialId } })
}

getList()
</script>