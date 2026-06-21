<template>
  <div class="app-container" v-hasPermi="['system:backup:list']">
    <!-- 备份配置区域 -->
    <el-card class="mb20" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>备份配置</span>
          <el-button type="primary" size="small" @click="saveConfig">保存配置</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="configForm" label-width="120px">
        <el-form-item label="自动备份">
          <el-switch v-model="configForm.enabled" active-text="启用" inactive-text="停用" />
        </el-form-item>
        <el-form-item label="备份时间">
          <el-time-picker v-model="configForm.backupTimeValue" format="HH:mm" value-format="HH:mm" placeholder="选择备份时间" style="width: 150px" />
        </el-form-item>
        <el-form-item label="保留天数">
          <el-input-number v-model="configForm.retainDays" :min="1" :max="365" style="width: 150px" />
        </el-form-item>
        <el-form-item label="mysqldump路径">
          <el-input v-model="configForm.mysqldumpPath" placeholder="默认mysqldump，Windows需完整路径" style="width: 300px" />
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleExecute" :loading="executeLoading" v-hasPermi="['system:backup:add']">手动备份</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:backup:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Refresh" @click="getList">刷新</el-button>
      </el-col>
    </el-row>

    <!-- 备份记录表格 -->
    <el-table :data="backupList" v-loading="loading" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="文件名" prop="fileName" min-width="220" show-overflow-tooltip />
      <el-table-column label="文件大小" prop="fileSize" min-width="100" align="center">
        <template #default="{ row }">
          {{ formatFileSize(row.fileSize) }}
        </template>
      </el-table-column>
      <el-table-column label="备份类型" prop="backupType" min-width="90" align="center">
        <template #default="{ row }">
          <el-tag :type="row.backupType === 'auto' ? 'info' : 'primary'" size="small">
            {{ row.backupType === 'auto' ? '自动' : '手动' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" min-width="80" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status === 'success' ? 'success' : 'danger'" size="small">
            {{ row.status === 'success' ? '成功' : '失败' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="耗时(秒)" prop="duration" min-width="90" align="center" />
      <el-table-column label="错误信息" prop="errorMessage" min-width="200" show-overflow-tooltip>
        <template #default="{ row }">
          <span class="text-danger">{{ row.errorMessage || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="备份时间" prop="createTime" min-width="160" align="center" />
      <el-table-column label="操作" width="240" align="center" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" icon="View" @click="handlePreview(row)" v-if="row.status === 'success'">预览</el-button>
          <el-button link type="primary" icon="Download" @click="handleDownload(row)" v-if="row.status === 'success'">下载</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(row)" v-hasPermi="['system:backup:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 预览对话框 -->
    <el-dialog v-model="previewOpen" :title="'预览 - ' + previewFileName" width="80%" top="5vh" destroy-on-close>
      <div v-loading="previewLoading">
        <el-alert v-if="previewTruncated" type="warning" :closable="false" style="margin-bottom: 10px">
          文件共 {{ previewTotalLines }} 行，当前仅展示前 {{ previewLines }} 行
        </el-alert>
        <div class="sql-preview">
          <pre><code>{{ previewContent }}</code></pre>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup name="DbBackup">
import { listBackup, executeBackup, delBackup, previewBackup, getBackupConfig, updateBackupConfig } from '@/api/system/backup'

const { proxy } = getCurrentInstance()

const loading = ref(false)
const executeLoading = ref(false)
const backupList = ref([])
const total = ref(0)
const ids = ref([])
const multiple = ref(true)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10
})

const configForm = ref({
  enabled: true,
  backupTimeValue: '02:00',
  retainDays: 30,
  mysqldumpPath: 'mysqldump'
})

const previewOpen = ref(false)
const previewLoading = ref(false)
const previewContent = ref('')
const previewFileName = ref('')
const previewTotalLines = ref(0)
const previewLines = ref(0)
const previewTruncated = ref(false)

function getList() {
  loading.value = true
  listBackup(queryParams.value).then(res => {
    backupList.value = res.rows || []
    total.value = res.total || 0
  }).finally(() => {
    loading.value = false
  })
}

function loadConfig() {
  getBackupConfig().then(res => {
    const config = res.data || res
    if (config) {
      configForm.value.enabled = config.enabled !== false
      configForm.value.backupTimeValue = config.backupTime || '02:00'
      configForm.value.retainDays = config.retainDays || 30
      configForm.value.mysqldumpPath = config.mysqldumpPath || 'mysqldump'
    }
  })
}

function saveConfig() {
  updateBackupConfig({
    enabled: configForm.value.enabled,
    backupTime: configForm.value.backupTimeValue,
    retainDays: configForm.value.retainDays,
    mysqldumpPath: configForm.value.mysqldumpPath
  }).then(() => {
    proxy.$modal.msgSuccess('配置保存成功')
  })
}

function handleExecute() {
  proxy.$modal.confirm('确认执行手动备份？备份过程中请勿关闭页面。').then(() => {
    executeLoading.value = true
    executeBackup().then(res => {
      proxy.$modal.msgSuccess(res.data || res.msg || '备份任务已提交')
      getList()
    }).finally(() => {
      executeLoading.value = false
    })
  }).catch(() => {})
}

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.backupId)
  multiple.value = !selection.length
}

function handleDelete(row) {
  const backupIds = row.backupId ? [row.backupId] : ids.value
  proxy.$modal.confirm('确认删除选中的备份记录？COS上的备份文件也将被删除。').then(() => {
    delBackup(backupIds.join(',')).then(() => {
      proxy.$modal.msgSuccess('删除成功')
      getList()
    })
  }).catch(() => {})
}

function handleDownload(row) {
  proxy.download('system/backup/download', { backupId: row.backupId }, row.fileName, { timeout: 60000 })
}

function handlePreview(row) {
  previewOpen.value = true
  previewLoading.value = true
  previewContent.value = ''
  previewFileName.value = row.fileName
  previewBackup(row.backupId).then(res => {
    const data = res.data || res
    previewContent.value = data.content || ''
    previewTotalLines.value = data.totalLines || 0
    previewLines.value = data.previewLines || 0
    previewTruncated.value = data.truncated || false
  }).catch(() => {
    previewContent.value = '预览加载失败'
  }).finally(() => {
    previewLoading.value = false
  })
}

function formatFileSize(bytes) {
  if (!bytes || bytes === 0) return '0 B'
  if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + ' GB'
  if (bytes >= 1048576) return (bytes / 1048576).toFixed(2) + ' MB'
  if (bytes >= 1024) return (bytes / 1024).toFixed(2) + ' KB'
  return bytes + ' B'
}

onMounted(() => {
  getList()
  loadConfig()
})
</script>

<style scoped lang="scss">
.mb20 {
  margin-bottom: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.text-danger {
  color: #f56c6c;
}
.sql-preview {
  max-height: 70vh;
  overflow: auto;
  background-color: #1e1e1e;
  border-radius: 4px;
  padding: 16px;
  pre {
    margin: 0;
    code {
      color: #d4d4d4;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 13px;
      line-height: 1.5;
      white-space: pre;
    }
  }
}
</style>
