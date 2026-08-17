<template>
  <el-dialog
    title="目标拆解"
    v-model="visible"
    width="980px"
    append-to-body
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <div v-loading="loading">
      <!-- 父目标信息 -->
      <el-descriptions :column="3" border size="small" class="parent-info">
        <el-descriptions-item label="目标名称" :span="3">
          <span style="color: #303133; font-weight: 600">{{ parentGoal.goalName || '-' }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="目标值">
          <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(parentGoal.targetValue) }}</span>
          <span v-if="parentGoal.unit" style="color: #909399; margin-left: 4px">{{ parentGoal.unit }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="口径">
          <el-tag size="small" effect="plain" :type="getMetricTypeTagType(parentGoal.metricType)">{{ getMetricTypeLabel(parentGoal.metricType) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="周期">
          <span>{{ getPeriodTypeLabel(parentGoal.periodType) }} · {{ parentGoal.periodName || '-' }}</span>
        </el-descriptions-item>
      </el-descriptions>

      <!-- 拆解方式 -->
      <div class="split-toolbar">
        <el-form :inline="true" class="split-mode-form">
          <el-form-item label="拆解方式">
            <el-radio-group v-model="splitMode" @change="handleSplitModeChange">
              <el-radio :value="1">按历史同期占比</el-radio>
              <el-radio :value="2">均分</el-radio>
              <el-radio :value="3">手动比例</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" plain icon="Plus" @click="addRow">新增子项</el-button>
            <el-button type="info" plain icon="Sort" @click="distributeEvenly" :disabled="splitMode === 3">重新分配</el-button>
          </el-form-item>
        </el-form>
        <div v-if="splitMode === 1" class="history-tip">
          <el-icon><InfoFilled /></el-icon>
          按历史同期完成数据自动分配比例，可在切换为"手动比例"后调整。
        </div>
      </div>

      <!-- 子项表格 -->
      <el-table :data="children" border size="small" class="split-table" max-height="380">
        <el-table-column type="index" label="#" width="48" align="center" />
        <el-table-column label="归属层级" width="120" align="center">
          <template #default="{ row }">
            <el-select v-model="row.ownerType" placeholder="选择层级" size="small" @change="handleRowOwnerTypeChange(row)" style="width: 100%">
              <el-option :value="2" label="部门" />
              <el-option :value="4" label="个人" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="归属对象" min-width="200">
          <template #default="{ row }">
            <el-tree-select
              v-if="row.ownerType === 2"
              v-model="row.ownerId"
              :data="deptOptions"
              :props="{ value: 'id', label: 'label', children: 'children' }"
              value-key="id"
              placeholder="请选择部门"
              check-strictly
              filterable
              clearable
              size="small"
              style="width: 100%"
              @change="(val) => handleRowOwnerChange(row, val)"
            />
            <el-select
              v-else
              v-model="row.ownerId"
              :placeholder="getOwnerPlaceholder(row.ownerType)"
              filterable
              size="small"
              style="width: 100%"
              :disabled="!row.ownerType"
              @change="(val) => handleRowOwnerChange(row, val)"
            >
              <el-option v-for="item in userOptions" :key="item.userId" :label="item.nickName || item.userName" :value="item.userId" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="比例(%)" width="150" align="center">
          <template #default="{ row }">
            <el-input-number
              v-model="row.ratioPercent"
              :min="0"
              :max="100"
              :precision="2"
              :step="5"
              size="small"
              controls-position="right"
              :disabled="splitMode !== 3"
              style="width: 100%"
              @change="handleRatioChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="目标值" width="170" align="right">
          <template #default="{ row }">
            <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(row.targetValue) }}</span>
            <span v-if="parentGoal.unit" style="color: #909399; margin-left: 4px; font-size: 12px">{{ parentGoal.unit }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80" align="center" fixed="right">
          <template #default="{ $index }">
            <el-button link type="danger" icon="Delete" @click="removeRow($index)" :disabled="children.length <= 1">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 底部汇总 -->
      <div class="summary-bar">
        <span class="summary-label">比例合计：</span>
        <span :class="['ratio-total', { warning: !isRatioValid }]">
          {{ formatNumber(ratioTotal) }}%
        </span>
        <span v-if="!isRatioValid" class="warn-text">（建议在 95% ~ 105% 之间）</span>
        <el-divider direction="vertical" />
        <span class="summary-label">目标值合计：</span>
        <span style="color: #3D6DF7; font-weight: 600">{{ formatNumber(targetTotal) }}</span>
        <span v-if="parentGoal.unit" style="color: #909399; margin-left: 4px">{{ parentGoal.unit }}</span>
        <el-divider direction="vertical" />
        <span class="summary-label">父目标值：</span>
        <span style="color: #303133; font-weight: 600">{{ formatNumber(parentGoal.targetValue) }}</span>
        <span v-if="parentGoal.unit" style="color: #909399; margin-left: 4px">{{ parentGoal.unit }}</span>
      </div>
    </div>

    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" @click="submitForm" :loading="submitting">确 定</el-button>
    </template>
  </el-dialog>
</template>

<script setup name="GoalSplit">
import { getGoal, splitGoal, getSplitChildren } from '@/api/goal'
import { listUser, deptTreeSelect } from '@/api/system/user'
import { InfoFilled } from '@element-plus/icons-vue'

const props = defineProps({
  visible: { type: Boolean, default: false },
  goalId: { type: [Number, String], default: null }
})
const emit = defineEmits(['update:visible', 'success'])

const { proxy } = getCurrentInstance()
const loading = ref(false)
const submitting = ref(false)

const visible = computed({
  get: () => props.visible,
  set: v => emit('update:visible', v)
})

// 选项常量
const periodTypeMap = { 1: '年度', 2: '季度', 3: '月度', 4: '自定义' }
const metricTypeMap = {
  1: { label: '实收业绩', tagType: '' },
  2: { label: '消耗业绩', tagType: 'success' },
  3: { label: '出货金额', tagType: 'warning' },
  4: { label: '品项件数', tagType: 'info' },
  5: { label: '品项金额', tagType: 'info' },
  6: { label: '到店客次', tagType: 'warning' },
  7: { label: '新客数', tagType: 'success' },
  8: { label: '活跃门店数', tagType: 'info' }
}

function getPeriodTypeLabel(val) {
  return periodTypeMap[Number(val)] ?? '-'
}
function getMetricTypeLabel(val) {
  return metricTypeMap[Number(val)]?.label ?? '-'
}
function getMetricTypeTagType(val) {
  return metricTypeMap[Number(val)]?.tagType ?? 'info'
}
function formatNumber(val) {
  const num = Number(val || 0)
  if (isNaN(num)) return val
  return num.toLocaleString('zh-CN', { maximumFractionDigits: 2 })
}

// 父目标信息
const parentGoal = ref({})
// 子项列表
const children = ref([])
// 拆解方式：1按历史同期占比 2均分 3手动比例
const splitMode = ref(2)

// 选项
const userOptions = ref([])
const deptOptions = ref([])

// 比例合计
const ratioTotal = computed(() => {
  return children.value.reduce((sum, row) => sum + Number(row.ratioPercent || 0), 0)
})

// 目标值合计
const targetTotal = computed(() => {
  return children.value.reduce((sum, row) => sum + Number(row.targetValue || 0), 0)
})

// 比例是否有效（允许±5%浮动）
const isRatioValid = computed(() => {
  const total = ratioTotal.value
  return total >= 95 && total <= 105
})

// 归属对象 placeholder
function getOwnerPlaceholder(ownerType) {
  if (ownerType === 4) return '请选择用户'
  return '请先选择归属层级'
}

// 加载选项
function loadUserOptions() {
  listUser({ status: '0', pageNum: 1, pageSize: 200 }).then(res => {
    userOptions.value = res.rows || []
  })
}
function loadDeptOptions() {
  deptTreeSelect().then(res => {
    deptOptions.value = res.data || []
  })
}
function findDeptName(tree, targetId) {
  for (const node of tree) {
    if (node.id === targetId) return node.label
    if (node.children) {
      const found = findDeptName(node.children, targetId)
      if (found) return found
    }
  }
  return undefined
}

// 加载父目标
function loadParentGoal(goalId) {
  loading.value = true
  getGoal(goalId).then(async res => {
    parentGoal.value = res.data || {}
    // 回显已存在的拆解子目标
    try {
      const childRes = await getSplitChildren(goalId)
      const existChildren = childRes?.children || []
      if (existChildren.length > 0) {
        const parentValue = Number(parentGoal.value.targetValue || 0)
        children.value = existChildren.map(c => {
          const targetValue = Number(c.targetValue || 0)
          const ratioPercent = parentValue > 0
            ? Number((targetValue / parentValue * 100).toFixed(2))
            : 0
          return {
            ownerType: Number(c.ownerType),
            ownerId: c.ownerId,
            ownerName: c.ownerName,
            ratioPercent,
            targetValue
          }
        })
        // 已有拆解 → 切手动模式保留原比例，避免被均分覆盖
        splitMode.value = 3
      } else {
        // 无拆解 → 默认添加一行
        if (children.value.length === 0) addRow()
      }
    } catch (e) {
      console.error('加载子目标失败', e)
      if (children.value.length === 0) addRow()
    }
  }).finally(() => {
    loading.value = false
  })
}

// 计算目标值（父目标值 * 比例%）
function computeTargetValue(ratioPercent) {
  const parentValue = Number(parentGoal.value.targetValue || 0)
  return Number((parentValue * ratioPercent / 100).toFixed(2))
}

// 新增行
function addRow() {
  children.value.push({
    ownerType: 2,
    ownerId: undefined,
    ownerName: undefined,
    ratioPercent: 0,
    targetValue: 0
  })
  // 均分 / 历史同期 模式下自动分配
  if (splitMode.value === 2) {
    distributeEvenly()
  } else if (splitMode.value === 1) {
    distributeByHistory()
  }
}

// 删除行
function removeRow(index) {
  children.value.splice(index, 1)
  if (splitMode.value === 2) {
    distributeEvenly()
  } else if (splitMode.value === 1) {
    distributeByHistory()
  }
}

// 均分比例
function distributeEvenly() {
  const count = children.value.length
  if (count === 0) return
  const avg = 100 / count
  children.value.forEach(row => {
    row.ratioPercent = Number(avg.toFixed(2))
    row.targetValue = computeTargetValue(row.ratioPercent)
  })
}

// 按历史同期占比分配（暂无历史接口，默认按均分处理，可后续接入历史数据）
function distributeByHistory() {
  // TODO: 接入历史同期完成数据后按实际占比分配，当前占位使用均分
  distributeEvenly()
}

// 拆解方式切换
function handleSplitModeChange(val) {
  if (val === 2) {
    distributeEvenly()
  } else if (val === 1) {
    distributeByHistory()
  }
  // 手动模式不自动分配，保留当前比例
}

// 比例变更时重算目标值
function handleRatioChange(row) {
  row.targetValue = computeTargetValue(row.ratioPercent)
}

// 行归属层级变更
function handleRowOwnerTypeChange(row) {
  row.ownerId = undefined
  row.ownerName = undefined
}

// 行归属对象变更
function handleRowOwnerChange(row, val) {
  if (!val) {
    row.ownerName = undefined
    return
  }
  if (row.ownerType === 2) {
    row.ownerName = findDeptName(deptOptions.value, val)
  } else {
    const user = userOptions.value.find(u => u.userId === val)
    row.ownerName = user ? (user.nickName || user.userName) : undefined
  }
}

// 重置
function reset() {
  parentGoal.value = {}
  children.value = []
  splitMode.value = 2
}

// 关闭弹窗
function handleClose() {
  reset()
}

// 保存
function submitForm() {
  if (children.value.length === 0) {
    proxy.$modal.msgError('请至少添加一个子项')
    return
  }
  // 校验
  for (const row of children.value) {
    if (!row.ownerType) {
      proxy.$modal.msgError('请选择归属层级')
      return
    }
    if (row.ownerId === undefined || row.ownerId === null) {
      proxy.$modal.msgError('请选择归属对象')
      return
    }
    if (Number(row.ratioPercent) <= 0) {
      proxy.$modal.msgError('比例必须大于 0')
      return
    }
  }
  if (!isRatioValid.value) {
    proxy.$modal.msgError('比例合计需在 95% ~ 105% 之间')
    return
  }
  // 构造提交数据：ratio 用 0-1 小数存储
  const submitData = {
    parentGoalId: props.goalId,
    children: children.value.map(row => ({
      owner_type: row.ownerType,
      owner_id: row.ownerId,
      owner_name: row.ownerName,
      ratio: Number(row.ratioPercent) / 100
    }))
  }
  submitting.value = true
  splitGoal(submitData).then(() => {
    proxy.$modal.msgSuccess('拆解成功')
    visible.value = false
    emit('success')
  }).finally(() => {
    submitting.value = false
  })
}

// 监听弹窗显示：加载选项与父目标
watch(() => props.visible, (val) => {
  if (val) {
    if (userOptions.value.length === 0) loadUserOptions()
    if (deptOptions.value.length === 0) loadDeptOptions()
    reset()
    if (props.goalId) {
      loadParentGoal(props.goalId)
    }
  }
})
</script>

<style scoped>
.parent-info {
  margin-bottom: 16px;
}
.split-toolbar {
  margin-bottom: 12px;
}
.split-mode-form {
  margin-bottom: 0;
}
.history-tip {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #909399;
  font-size: 12px;
  padding: 4px 0;
}
.split-table {
  margin-bottom: 12px;
}
.summary-bar {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  background-color: #f5f7fa;
  border-radius: 4px;
  font-size: 14px;
  flex-wrap: wrap;
  gap: 4px;
}
.summary-label {
  color: #606266;
}
.ratio-total {
  color: #67c23a;
  font-weight: 600;
}
.ratio-total.warning {
  color: #f56c6c;
}
.warn-text {
  color: #f56c6c;
  font-size: 12px;
  margin-left: 4px;
}
:deep(.el-radio__input.is-checked .el-radio__inner) {
  background-color: #3D6DF7;
  border-color: #3D6DF7;
}
:deep(.el-radio__input.is-checked + .el-radio__label) {
  color: #3D6DF7;
}
:deep(.el-select .el-input.is-focus .el-input__wrapper) {
  box-shadow: 0 0 0 1px #3D6DF7 inset;
}
:deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #3D6DF7 inset;
}
:deep(.el-button--primary) {
  --el-button-bg-color: #3D6DF7;
  --el-button-border-color: #3D6DF7;
  --el-button-hover-bg-color: #5a85f9;
  --el-button-hover-border-color: #5a85f9;
  --el-button-active-bg-color: #2f57c4;
  --el-button-active-border-color: #2f57c4;
}
</style>
