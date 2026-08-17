<template>
  <el-dialog
    :title="goalId ? '编辑目标' : '新增目标'"
    v-model="visible"
    width="920px"
    append-to-body
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form ref="goalRef" :model="form" :rules="rules" label-width="100px" v-loading="loading">
      <el-row>
        <el-col :span="24">
          <el-form-item label="目标名称" prop="goalName">
            <el-input v-model="form.goalName" placeholder="请输入目标名称" maxlength="100" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="归属层级" prop="ownerType">
            <el-radio-group v-model="form.ownerType" @change="handleOwnerTypeChange">
              <el-radio :value="2">部门</el-radio>
              <el-radio :value="4">个人</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="归属对象" prop="ownerId">
            <!-- 部门：选择部门树 -->
            <el-tree-select
              v-if="form.ownerType === 2"
              v-model="form.ownerId"
              :data="deptOptions"
              :props="{ value: 'id', label: 'label', children: 'children' }"
              value-key="id"
              placeholder="请选择部门"
              check-strictly
              filterable
              clearable
              style="width: 100%"
              @change="(val) => handleDeptChange(val)"
            />
            <!-- 个人：选择用户 -->
            <el-select
              v-else-if="form.ownerType === 4"
              v-model="form.ownerId"
              placeholder="请选择用户"
              filterable
              remote
              :remote-method="loadUserOptions"
              @focus="() => loadUserOptions('')"
              @change="(val) => handleOwnerChange(val, 'user')"
              style="width: 100%"
            >
              <el-option
                v-for="item in userOptions"
                :key="item.userId"
                :label="item.nickName || item.userName"
                :value="item.userId"
              />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="数据权限">
            <span class="perm-tip">归属层级选择受角色数据范围（data_scope）限制，后端将进行权限校验。</span>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="12">
          <el-form-item label="周期" prop="periodType">
            <el-select v-model="form.periodType" placeholder="请选择周期" @change="handlePeriodTypeChange" style="width: 100%">
              <el-option
                v-for="item in periodTypeOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="周期名称" prop="periodName">
            <el-input v-model="form.periodName" placeholder="请输入周期名称" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="起止日期" prop="dateRange">
            <!-- 年度 -->
            <el-date-picker
              v-if="form.periodType === 1"
              v-model="periodYear"
              type="year"
              value-format="YYYY"
              placeholder="请选择年度"
              @change="handleYearChange"
              style="width: 100%"
            />
            <!-- 季度 -->
            <div v-else-if="form.periodType === 2" class="period-quarter-wrap">
              <el-date-picker
                v-model="periodYear"
                type="year"
                value-format="YYYY"
                placeholder="选择年度"
                @change="handleQuarterChange"
                style="width: 50%"
              />
              <el-select v-model="periodQuarter" placeholder="选择季度" @change="handleQuarterChange" style="width: 48%; margin-left: 2%">
                <el-option :value="1" label="第1季度" />
                <el-option :value="2" label="第2季度" />
                <el-option :value="3" label="第3季度" />
                <el-option :value="4" label="第4季度" />
              </el-select>
            </div>
            <!-- 月度 -->
            <el-date-picker
              v-else-if="form.periodType === 3"
              v-model="periodMonth"
              type="month"
              value-format="YYYY-MM"
              placeholder="请选择月份"
              @change="handleMonthChange"
              style="width: 100%"
            />
            <!-- 自定义 -->
            <el-date-picker
              v-else-if="form.periodType === 4"
              v-model="dateRange"
              type="daterange"
              value-format="YYYY-MM-DD"
              range-separator="-"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              @change="handleDateRangeChange"
              style="width: 100%"
            />
            <el-input v-else model-value="请先选择周期" disabled />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="起止日期">
            <span class="date-text">{{ form.startDate || '—' }} ~ {{ form.endDate || '—' }}</span>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="12">
          <el-form-item label="口径" prop="metricType">
            <el-select v-model="form.metricType" placeholder="请选择口径" @change="handleMetricTypeChange" style="width: 100%">
              <el-option
                v-for="item in metricTypeOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="目标值" prop="targetValue">
            <el-input-number
              v-model="form.targetValue"
              :min="0"
              :precision="2"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
        </el-col>
        <el-col :span="4">
          <el-form-item label="单位" prop="unit">
            <el-input v-model="form.unit" placeholder="单位" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row v-if="form.metricType === 4 || form.metricType === 5">
        <el-col :span="24">
          <el-form-item label="品项" prop="cardItemId">
            <el-select
              v-model="form.cardItemId"
              placeholder="请选择品项"
              filterable
              remote
              :remote-method="loadCardItemOptions"
              @focus="() => loadCardItemOptions('')"
              clearable
              style="width: 100%"
            >
              <el-option
                v-for="item in cardItemOptions"
                :key="item.cardItemId"
                :label="item.cardItemName"
                :value="item.cardItemId"
              />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="活动名称" prop="activityName">
            <el-input v-model="form.activityName" placeholder="请输入活动名称（活动专项目标，可选）" maxlength="100" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="24">
          <el-form-item label="备注" prop="remark">
            <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <template #footer>
      <div class="dialog-footer">
        <el-button type="primary" @click="submitForm" :loading="submitting">确 定</el-button>
        <el-button @click="visible = false">取 消</el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup name="GoalForm">
import { addGoal, updateGoal, getGoal } from '@/api/goal'
import { listUser, deptTreeSelect } from '@/api/system/user'
import { listCardItem } from '@/api/business/cardItem'

const props = defineProps({
  visible: { type: Boolean, default: false },
  goalId: { type: [Number, String], default: null }
})
const emit = defineEmits(['update:visible', 'success'])

const { proxy } = getCurrentInstance()
const goalRef = ref()
const loading = ref(false)
const submitting = ref(false)

const visible = computed({
  get: () => props.visible,
  set: v => emit('update:visible', v)
})

// 选项常量
const ownerTypeOptions = [
  { value: 2, label: '部门' },
  { value: 4, label: '个人' }
]
const periodTypeOptions = [
  { value: 1, label: '年度' },
  { value: 2, label: '季度' },
  { value: 3, label: '月度' },
  { value: 4, label: '自定义' }
]
const metricTypeOptions = [
  { value: 1, label: '实收业绩' },
  { value: 2, label: '消耗业绩' },
  { value: 3, label: '出货金额' },
  { value: 4, label: '品项件数' },
  { value: 5, label: '品项金额' },
  { value: 6, label: '到店客次' },
  { value: 7, label: '新客数' },
  { value: 8, label: '活跃门店数' }
]
// 口径 → 单位 映射
const unitMap = {
  1: '元', 2: '元', 3: '元', 5: '元',
  4: '件',
  6: '人次', 7: '人次',
  8: '家'
}

// 周期辅助变量
const periodYear = ref('')
const periodQuarter = ref(null)
const periodMonth = ref('')

// 选择器选项
const userOptions = ref([])
const cardItemOptions = ref([])
const deptOptions = ref([])

const data = reactive({
  form: {
    goalId: undefined,
    goalName: undefined,
    ownerType: 2,
    ownerId: undefined,
    ownerName: undefined,
    periodType: undefined,
    periodName: undefined,
    startDate: undefined,
    endDate: undefined,
    metricType: undefined,
    targetValue: 0,
    unit: undefined,
    cardItemId: undefined,
    activityName: undefined,
    remark: undefined
  },
  rules: {
    goalName: [{ required: true, message: '目标名称不能为空', trigger: 'blur' }],
    ownerType: [{ required: true, message: '请选择归属层级', trigger: 'change' }],
    ownerId: [{ required: true, message: '请选择归属对象', trigger: 'change' }],
    periodType: [{ required: true, message: '请选择周期', trigger: 'change' }],
    metricType: [{ required: true, message: '请选择口径', trigger: 'change' }],
    targetValue: [{ required: true, message: '目标值不能为空', trigger: 'blur' }]
  }
})
const { form, rules } = toRefs(data)

// 自定义日期范围 computed（双向映射到 startDate/endDate）
const dateRange = computed({
  get: () => (form.value.startDate && form.value.endDate) ? [form.value.startDate, form.value.endDate] : [],
  set: (val) => {
    if (val && val.length === 2) {
      form.value.startDate = val[0]
      form.value.endDate = val[1]
    } else {
      form.value.startDate = undefined
      form.value.endDate = undefined
    }
  }
})

/* ============ 日期工具方法 ============ */
function pad(n) {
  return n < 10 ? '0' + n : '' + n
}
function getQuarterStart(year, quarter) {
  const month = (quarter - 1) * 3 + 1
  return `${year}-${pad(month)}-01`
}
function getQuarterEnd(year, quarter) {
  const endMonth = (quarter - 1) * 3 + 3
  const lastDay = new Date(Number(year), endMonth, 0).getDate()
  return `${year}-${pad(endMonth)}-${pad(lastDay)}`
}
function getMonthStart(year, month) {
  return `${year}-${pad(month)}-01`
}
function getMonthEnd(year, month) {
  const lastDay = new Date(Number(year), month, 0).getDate()
  return `${year}-${pad(month)}-${pad(lastDay)}`
}

/* ============ 归属层级相关 ============ */
function handleOwnerTypeChange(val) {
  form.value.ownerId = undefined
  form.value.ownerName = undefined
  if (val === 2) {
    loadDeptOptions()
  } else if (val === 4) {
    loadUserOptions('')
  }
}

function handleOwnerChange(val, type) {
  if (!val) {
    form.value.ownerName = undefined
    return
  }
  if (type === 'user') {
    const user = userOptions.value.find(u => u.userId === val)
    form.value.ownerName = user ? (user.nickName || user.userName) : undefined
  }
}

/* ============ 周期相关 ============ */
function handlePeriodTypeChange() {
  // 切换周期类型时重置周期辅助值与起止日期
  periodYear.value = ''
  periodQuarter.value = null
  periodMonth.value = ''
  form.value.startDate = undefined
  form.value.endDate = undefined
  form.value.periodName = undefined
}

function handleYearChange(val) {
  if (!val) return
  form.value.startDate = `${val}-01-01`
  form.value.endDate = `${val}-12-31`
  form.value.periodName = `${val}年`
}

function handleQuarterChange() {
  const y = periodYear.value
  const q = periodQuarter.value
  if (!y || !q) return
  form.value.startDate = getQuarterStart(y, q)
  form.value.endDate = getQuarterEnd(y, q)
  form.value.periodName = `${y}年第${q}季度`
}

function handleMonthChange(val) {
  if (!val) return
  const [y, m] = val.split('-').map(Number)
  form.value.startDate = getMonthStart(y, m)
  form.value.endDate = getMonthEnd(y, m)
  form.value.periodName = `${y}年${m}月`
}

function handleDateRangeChange(val) {
  if (val && val.length === 2) {
    form.value.startDate = val[0]
    form.value.endDate = val[1]
    form.value.periodName = `${val[0]} ~ ${val[1]}`
  } else {
    form.value.startDate = undefined
    form.value.endDate = undefined
    form.value.periodName = undefined
  }
}

/* ============ 口径相关 ============ */
function handleMetricTypeChange(val) {
  // 自动设置单位
  form.value.unit = unitMap[val] || ''
  // 非品项口径时清空品项
  if (val !== 4 && val !== 5) {
    form.value.cardItemId = undefined
  }
}

/* ============ 远程选项加载 ============ */
function loadUserOptions(keyword = '') {
  listUser({ nickName: keyword, status: '0', pageNum: 1, pageSize: 50 }).then(res => {
    userOptions.value = res.rows || []
  })
}
function loadCardItemOptions(keyword = '') {
  listCardItem({ cardItemName: keyword, pageNum: 1, pageSize: 50 }).then(res => {
    cardItemOptions.value = res.rows || []
  })
}
function loadDeptOptions() {
  deptTreeSelect().then(res => {
    deptOptions.value = res.data || []
  })
}
function handleDeptChange(deptId) {
  if (!deptId) {
    form.value.ownerName = undefined
    return
  }
  form.value.ownerName = findDeptName(deptOptions.value, deptId)
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

/* ============ 表单重置 ============ */
function reset() {
  form.value = {
    goalId: undefined,
    goalName: undefined,
    ownerType: 2,
    ownerId: undefined,
    ownerName: undefined,
    periodType: undefined,
    periodName: undefined,
    startDate: undefined,
    endDate: undefined,
    metricType: undefined,
    targetValue: 0,
    unit: undefined,
    cardItemId: undefined,
    activityName: undefined,
    remark: undefined
  }
  periodYear.value = ''
  periodQuarter.value = null
  periodMonth.value = ''
  proxy.resetForm('goalRef')
}

/* ============ 回显 ============ */
function getGoalInfo(goalId) {
  loading.value = true
  getGoal(goalId).then(res => {
    const data = res.data
    form.value = data
    // 反向同步周期辅助值，便于再次编辑
    syncPeriodFromData()
    // 按归属类型预加载选项，保证回显下拉有数据
    if (form.value.ownerType === 2) {
      loadDeptOptions()
    } else if (form.value.ownerType === 4) {
      loadUserOptions('')
    }
    if (form.value.metricType === 4 || form.value.metricType === 5) {
      loadCardItemOptions('')
    }
  }).finally(() => {
    loading.value = false
  })
}

function syncPeriodFromData() {
  const pt = form.value.periodType
  const start = form.value.startDate
  if (!pt || !start) return
  const yStr = start.substring(0, 4)
  if (pt === 1) {
    periodYear.value = yStr
  } else if (pt === 2) {
    periodYear.value = yStr
    const startMonth = Number(start.substring(5, 7))
    periodQuarter.value = Math.ceil(startMonth / 3)
  } else if (pt === 3) {
    periodMonth.value = start.substring(0, 7)
  }
  // 自定义周期 dateRange 由 computed 自动映射，无需处理
}

/* ============ watch goalId ============ */
watch(() => props.goalId, (val) => {
  if (val) {
    getGoalInfo(val)
  } else {
    reset()
  }
}, { immediate: true })

/* ============ 保存 ============ */
function submitForm() {
  proxy.$refs['goalRef'].validate(valid => {
    if (!valid) return
    submitting.value = true
    const submitData = { ...form.value }
    const action = submitData.goalId != null ? updateGoal(submitData) : addGoal(submitData)
    action.then(() => {
      proxy.$modal.msgSuccess(submitData.goalId != null ? '修改成功' : '新增成功')
      visible.value = false
      emit('success')
    }).finally(() => {
      submitting.value = false
    })
  })
}

function handleClose() {
  reset()
}
</script>

<style scoped>
.perm-tip {
  color: #909399;
  font-size: 12px;
}
.date-text {
  color: #303133;
  font-size: 14px;
}
.period-quarter-wrap {
  display: flex;
  align-items: center;
  width: 100%;
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
