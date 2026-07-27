<template>
  <el-dialog
    v-model="visible"
    title="选择员工"
    width="900px"
    append-to-body
    :close-on-click-modal="false"
    @open="handleOpen"
  >
    <div class="employee-select-container">
      <!-- 已选员工区 -->
      <div class="selected-bar">
        <span class="label">已选员工（{{ selectedUsers.length }}人）：</span>
        <div class="tags-wrap">
          <el-tag
            v-for="user in selectedUsers"
            :key="user.userId"
            closable
            @close="removeUser(user.userId)"
            class="mx-1 my-1"
          >
            {{ user.deptName ? `${user.deptName}-` : '' }}{{ user.nickName || user.userName }}
          </el-tag>
          <el-button v-if="selectedUsers.length > 0" link type="danger" @click="clearAll" class="ml-2">清空</el-button>
        </div>
      </div>

      <el-row :gutter="12" class="main-area">
        <!-- 左侧部门树 -->
        <el-col :span="8">
          <div class="panel-title">部门</div>
          <div class="tree-wrap">
            <el-input v-model="deptKeyword" placeholder="搜索部门" clearable size="small" class="mb-2" />
            <el-tree
              ref="deptTreeRef"
              :data="deptTree"
              :props="{ label: 'deptName', children: 'children' }"
              node-key="deptId"
              highlight-current
              :filter-node-method="filterDeptNode"
              @node-click="handleDeptClick"
              default-expand-all
            />
          </div>
        </el-col>

        <!-- 右侧员工列表 -->
        <el-col :span="16">
          <div class="panel-title">
            <span>员工列表</span>
            <div class="ops">
              <span v-if="currentDeptName" class="current-dept">当前：{{ currentDeptName }}</span>
              <el-button v-if="currentDeptId" link type="primary" @click="selectAllInDept">全选当前部门</el-button>
            </div>
          </div>
          <el-table
            ref="userTableRef"
            :data="filteredUsers"
            v-loading="loading"
            height="360"
            @selection-change="handleTableSelectionChange"
            row-key="userId"
          >
            <el-table-column type="selection" width="45" :reserve-selection="true" />
            <el-table-column label="员工姓名" prop="nickName" min-width="100">
              <template #default="{ row }">
                {{ row.nickName || row.userName }}
              </template>
            </el-table-column>
            <el-table-column label="账号" prop="userName" min-width="100" />
            <el-table-column label="部门" prop="deptName" min-width="120" show-overflow-tooltip />
          </el-table>
        </el-col>
      </el-row>
    </div>

    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" @click="confirm">确 认</el-button>
    </template>
  </el-dialog>
</template>

<script setup name="EmployeeSelect">
import { getDeptTreeWithUsers } from '@/api/business/leave'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  // 已选中的员工（用于回显）
  selected: { type: Array, default: () => [] }
})
const emit = defineEmits(['update:modelValue', 'confirm'])

const visible = computed({
  get: () => props.modelValue,
  set: v => emit('update:modelValue', v)
})

const deptTreeRef = ref()
const userTableRef = ref()
const loading = ref(false)
const deptKeyword = ref('')
const deptTree = ref([])
const allUsers = ref([])        // 所有员工
const filteredUsers = ref([])   // 当前显示的员工
const currentDeptId = ref(null)
const currentDeptName = ref('')

// 选中状态管理（用 Map 维护，避免依赖 el-table 的 selection）
const selectedMap = ref(new Map())  // userId -> userObj
// 回显过程中的标志位，防止 selection-change 事件误删 selectedMap
const isRestoring = ref(false)

const selectedUsers = computed(() => Array.from(selectedMap.value.values()))

// 监听 selected 变化进行回显
watch(() => props.selected, (val) => {
  selectedMap.value = new Map()
  ;(val || []).forEach(u => {
    selectedMap.value.set(u.userId, u)
  })
}, { immediate: true, deep: true })

// 监听部门关键字过滤
watch(deptKeyword, (val) => {
  deptTreeRef.value?.filter(val)
})

function filterDeptNode(value, data) {
  if (!value) return true
  return data.deptName?.includes(value)
}

async function handleOpen() {
  if (deptTree.value.length === 0) {
    await loadData()
  }
  // 显示全部员工
  currentDeptId.value = null
  currentDeptName.value = ''
  filteredUsers.value = allUsers.value
  // 下一帧回显勾选
  await nextTick()
  restoreSelection()
}

async function loadData() {
  loading.value = true
  try {
    const res = await getDeptTreeWithUsers()
    const data = res.data || res
    // 构建部门树
    const deptList = data.depts || []
    const userList = data.users || []

    // 为每个员工附加 deptName
    const deptMap = new Map()
    deptList.forEach(d => deptMap.set(d.deptId, d.deptName))
    userList.forEach(u => {
      u.deptName = deptMap.get(u.deptId) || ''
      // 兼容显示：如果没有 nickName 用 userName
      if (!u.nickName) u.nickName = u.userName
    })

    allUsers.value = userList
    deptTree.value = buildTree(deptList)
  } finally {
    loading.value = false
  }
}

function buildTree(list) {
  const map = new Map()
  list.forEach(item => {
    map.set(item.deptId, { ...item, children: [] })
  })
  const roots = []
  map.forEach(item => {
    if (item.parentId && map.has(item.parentId)) {
      map.get(item.parentId).children.push(item)
    } else {
      roots.push(item)
    }
  })
  return roots
}

function handleDeptClick(node) {
  currentDeptId.value = node.deptId
  currentDeptName.value = node.deptName
  // 显示该部门及其子部门的所有员工
  const deptIds = collectDeptIds(node)
  filteredUsers.value = allUsers.value.filter(u => deptIds.includes(u.deptId))
  nextTick(() => restoreSelection())
}

function collectDeptIds(node) {
  const ids = [node.deptId]
  if (node.children) {
    node.children.forEach(c => ids.push(...collectDeptIds(c)))
  }
  return ids
}

function selectAllInDept() {
  filteredUsers.value.forEach(u => {
    selectedMap.value.set(u.userId, u)
  })
  nextTick(() => restoreSelection())
}

function handleTableSelectionChange(selection) {
  // 回显过程中不处理 selection-change，避免误删 selectedMap
  if (isRestoring.value) return
  // selection 是当前页所有选中的行
  // 用一个简单策略：以当前 filteredUsers 为参照，
  // selection 中的加入 map，未在 selection 中的（属于当前 filteredUsers）从 map 移除
  const currentSelectedIds = new Set(selection.map(s => s.userId))
  filteredUsers.value.forEach(u => {
    if (currentSelectedIds.has(u.userId)) {
      selectedMap.value.set(u.userId, u)
    } else if (selectedMap.value.has(u.userId)) {
      // 当前页未选但之前选过：从 map 移除（取消选中）
      selectedMap.value.delete(u.userId)
    }
  })
}

function restoreSelection() {
  if (!userTableRef.value) return
  // 标记回显过程开始，防止 selection-change 事件误删 selectedMap
  isRestoring.value = true
  // 清空之前的 selection（不触发事件）
  // 注：el-table 没有提供 silent 选项，但当前页数据切换后 selection 会自动清空
  filteredUsers.value.forEach(row => {
    if (selectedMap.value.has(row.userId)) {
      userTableRef.value.toggleRowSelection(row, true)
    }
  })
  // 下一帧后恢复 selection-change 事件处理
  nextTick(() => {
    isRestoring.value = false
  })
}

function removeUser(userId) {
  selectedMap.value.delete(userId)
  // 同步取消表格勾选
  const row = filteredUsers.value.find(u => u.userId === userId)
  if (row && userTableRef.value) {
    userTableRef.value.toggleRowSelection(row, false)
  }
}

function clearAll() {
  selectedMap.value.clear()
  if (userTableRef.value) {
    userTableRef.value.clearSelection()
  }
}

function confirm() {
  const list = Array.from(selectedMap.value.values()).map(u => ({
    userId: u.userId,
    nickName: u.nickName || u.userName,
    userName: u.userName,
    deptId: u.deptId,
    deptName: u.deptName || ''
  }))
  emit('confirm', list)
  visible.value = false
}
</script>

<style scoped>
.employee-select-container {
  font-size: 14px;
}
.selected-bar {
  border: 1px dashed #dcdfe6;
  background: #fafafa;
  padding: 8px 12px;
  border-radius: 4px;
  margin-bottom: 12px;
}
.selected-bar .label {
  font-weight: 600;
  color: #303133;
  display: block;
  margin-bottom: 6px;
}
.tags-wrap {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}
.main-area {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 8px;
}
.panel-title {
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.panel-title .ops {
  display: flex;
  align-items: center;
  gap: 12px;
}
.current-dept {
  color: #909399;
  font-weight: normal;
  font-size: 12px;
}
.tree-wrap {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 8px;
  height: 360px;
  overflow: auto;
}
</style>
