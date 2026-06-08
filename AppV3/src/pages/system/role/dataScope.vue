<template>
  <view class="scope-container">
    <view class="form-section">
      <view class="section-title">角色信息</view>
      <view class="info-row">
        <view class="info-item">
          <text class="label">角色名称</text>
          <text class="value">{{ roleInfo.roleName || '-' }}</text>
        </view>
      </view>
      <view class="info-row">
        <view class="info-item">
          <text class="label">权限字符</text>
          <text class="value auth-text">{{ roleInfo.roleKey || '-' }}</text>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-title">权限范围</view>
      <view class="scope-options">
        <view
          v-for="item in scopeOptions"
          :key="item.value"
          class="scope-item"
          :class="{ active: formData.dataScope === item.value }"
          @click="selectScope(item.value)"
        >
          <view class="scope-radio" :class="{ checked: formData.dataScope === item.value }"></view>
          <text class="scope-label">{{ item.label }}</text>
        </view>
      </view>
    </view>

    <view v-if="formData.dataScope === '2'" class="form-section">
      <view class="section-title">自定义数据权限</view>
      <view class="dept-tree-toolbar">
        <view class="toolbar-btn" @click="toggleExpandAll">
          <u-icon :name="isExpandAll ? 'fold' : 'unfold'" size="14" color="#3D6DF7"></u-icon>
          <text>{{ isExpandAll ? '全部折叠' : '全部展开' }}</text>
        </view>
        <view class="toolbar-btn" @click="toggleCheckAll">
          <u-icon :name="isCheckAll ? 'checkbox-mark' : 'square'" size="14" color="#3D6DF7"></u-icon>
          <text>{{ isCheckAll ? '取消全选' : '全选' }}</text>
        </view>
      </view>
      <scroll-view scroll-y class="dept-tree-scroll">
        <view v-if="flatDeptList.length > 0" class="dept-tree">
          <view
            v-for="item in flatDeptList"
            :key="item.id"
            class="tree-node-content"
            :style="{ paddingLeft: (item.depth * 40 + 16) + 'rpx' }"
          >
            <view v-if="item.hasChildren" class="expand-icon" @click="toggleExpand(item.id)">
              <u-icon :name="item.expanded ? 'arrow-down' : 'arrow-right'" size="12" color="#86909C"></u-icon>
            </view>
            <view v-else class="expand-placeholder"></view>
            <view class="check-box" :class="{ checked: formData.deptIds.includes(item.id) }" @click="toggleCheck(item.id)">
              <u-icon v-if="formData.deptIds.includes(item.id)" name="checkmark" size="12" color="#fff"></u-icon>
            </view>
            <text class="node-label">{{ item.label }}</text>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无部门数据" :marginTop="40"></u-empty>
      </scroll-view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getRole, dataScope, deptTreeSelect } from '@/api/system/role'

const submitting = ref(false)
const roleId = ref(null)
const roleInfo = ref({})
const deptOptions = ref([])
const expandedIds = ref([])
const isExpandAll = ref(false)

const scopeOptions = [
  { label: '全部数据权限', value: '1' },
  { label: '自定义数据权限', value: '2' },
  { label: '本部门数据权限', value: '3' },
  { label: '本部门及以下数据权限', value: '4' },
  { label: '仅本人数据权限', value: '5' }
]

const formData = reactive({
  roleId: undefined,
  dataScope: '1',
  deptIds: []
})

const isCheckAll = computed(() => {
  const allIds = collectAllIds(deptOptions.value)
  return allIds.length > 0 && allIds.every(id => formData.deptIds.includes(id))
})

const flatDeptList = computed(() => {
  return flattenTree(deptOptions.value, 0)
})

function flattenTree(nodes, depth) {
  const result = []
  if (!nodes || !nodes.length) return result
  for (const node of nodes) {
    const hasChildren = node.children && node.children.length > 0
    const expanded = expandedIds.value.includes(node.id)
    result.push({
      id: node.id,
      label: node.label,
      depth,
      hasChildren,
      expanded
    })
    if (hasChildren && expanded) {
      result.push(...flattenTree(node.children, depth + 1))
    }
  }
  return result
}

function collectAllIds(nodes) {
  let ids = []
  for (const node of nodes) {
    ids.push(node.id)
    if (node.children && node.children.length) {
      ids = ids.concat(collectAllIds(node.children))
    }
  }
  return ids
}

function collectParentIds(nodes) {
  let ids = []
  for (const node of nodes) {
    if (node.children && node.children.length) {
      ids.push(node.id)
      ids = ids.concat(collectParentIds(node.children))
    }
  }
  return ids
}

async function loadDetail() {
  if (!roleId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const [roleRes, deptRes] = await Promise.all([
      getRole(roleId.value),
      deptTreeSelect(roleId.value)
    ])
    const data = roleRes.data || {}
    roleInfo.value = data
    formData.roleId = data.roleId
    formData.dataScope = String(data.dataScope ?? '1')
    const checkedKeys = deptRes.data?.checkedKeys || []
    formData.deptIds = [...checkedKeys]
    deptOptions.value = deptRes.data?.depts || []
    expandedIds.value = collectParentIds(deptOptions.value)
    isExpandAll.value = true
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function selectScope(value) {
  formData.dataScope = value
  if (value !== '2') {
    formData.deptIds = []
  }
}

function toggleExpand(deptId) {
  const idx = expandedIds.value.indexOf(deptId)
  if (idx > -1) {
    expandedIds.value.splice(idx, 1)
  } else {
    expandedIds.value.push(deptId)
  }
}

function toggleCheck(deptId) {
  const idx = formData.deptIds.indexOf(deptId)
  if (idx > -1) {
    formData.deptIds.splice(idx, 1)
  } else {
    formData.deptIds.push(deptId)
  }
}

function toggleExpandAll() {
  isExpandAll.value = !isExpandAll.value
  if (isExpandAll.value) {
    expandedIds.value = collectParentIds(deptOptions.value)
  } else {
    expandedIds.value = []
  }
}

function toggleCheckAll() {
  if (isCheckAll.value) {
    formData.deptIds = []
  } else {
    formData.deptIds = collectAllIds(deptOptions.value)
  }
}

async function submitForm() {
  if (formData.dataScope === '2' && formData.deptIds.length === 0) {
    uni.showToast({ title: '请选择自定义数据权限的部门', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    await dataScope({
      roleId: formData.roleId,
      dataScope: formData.dataScope,
      deptIds: formData.deptIds
    })
    uni.showToast({ title: '设置成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally {
    submitting.value = false
  }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/system/role/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  roleId.value = options.id ? parseInt(options.id) : null

  if (roleId.value) {
    uni.setNavigationBarTitle({ title: '数据权限' })
    loadDetail()
  } else {
    uni.showToast({ title: '缺少角色ID', icon: 'none' })
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.scope-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}
.section-title {
  font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx;
  padding-bottom: 16rpx; border-bottom: 1rpx solid #F2F3F5;
}

.info-row { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  display: flex; align-items: center; gap: 16rpx;
  .label { font-size: 26rpx; color: #86909C; min-width: 120rpx; }
  .value { font-size: 28rpx; color: #1D2129; &.auth-text { color: #3D6DF7; } }
}

.scope-options { display: flex; flex-direction: column; gap: 8rpx; }
.scope-item {
  display: flex; align-items: center; gap: 16rpx; padding: 24rpx 16rpx;
  border-radius: 12rpx; transition: background 0.2s;
  &.active { background: #E8F0FE; }
}
.scope-radio {
  width: 36rpx; height: 36rpx; border-radius: 50%; border: 3rpx solid #C9CDD4; transition: all 0.2s;
  flex-shrink: 0;
  &.checked {
    background: #3D6DF7; border-color: #3D6DF7; position: relative;
    &::after {
      content: ''; position: absolute; top: 50%; left: 50%;
      transform: translate(-50%, -50%); width: 14rpx; height: 14rpx;
      border-radius: 50%; background: #fff;
    }
  }
}
.scope-label { font-size: 28rpx; color: #1D2129; }

.dept-tree-toolbar {
  display: flex; gap: 24rpx; margin-bottom: 20rpx;
}
.toolbar-btn {
  display: flex; align-items: center; gap: 8rpx; font-size: 26rpx; color: #3D6DF7;
  padding: 8rpx 16rpx; background: #E8F0FE; border-radius: 8rpx;
}
.dept-tree-scroll { max-height: 500rpx; }
.dept-tree { display: flex; flex-direction: column; }

.tree-node-content {
  display: flex; align-items: center; gap: 12rpx; padding: 16rpx 16rpx;
  min-height: 72rpx;
}
.expand-icon {
  width: 32rpx; height: 32rpx; display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.expand-placeholder { width: 32rpx; flex-shrink: 0; }
.check-box {
  width: 36rpx; height: 36rpx; border-radius: 6rpx; border: 3rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; transition: all 0.2s;
  flex-shrink: 0;
  &.checked { background: #3D6DF7; border-color: #3D6DF7; }
}
.node-label { font-size: 28rpx; color: #1D2129; flex: 1; }

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
